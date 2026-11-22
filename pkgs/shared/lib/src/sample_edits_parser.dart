import 'package:source_span/source_span.dart';
import 'package:yaml/yaml.dart';

import 'inline_markup.dart';
import 'sample_edit.dart';

/// Reads the list of sample edits from the YAML file the site manager edits.
///
/// The expected format:
///
/// ```yaml
/// sample_edits:
///   - vimeo_id: 1110117832
///     vimeo_access_key: 4e7e3098ae   # only for unlisted videos
///     vimeo_title: Salieri and Mozart (Short Film)
///     thumbnail_image: thumbnail_salieri.jpg
///     title:
///       - Award winning short film
///       - <b><i>Salieri and Mozart</i></b>
///     description:
///       - Distributed by <a href="https://example.com">a company</a>.
/// ```
///
/// `title` and `description` take one line or a list of lines, formatted as
/// described in [parseInlineMarkup]. `description` is optional.
///
/// [sourceUrl] names the file in error messages. When [thumbnailExists] is
/// given, it is called with each `thumbnail_image` to check that the image is
/// there.
///
/// Throws a [SourceSpanFormatException] that points at the problem in the file.
List<SampleEdit> parseSampleEdits(String source, {Uri? sourceUrl, bool Function(String fileName)? thumbnailExists}) {
  final root = loadYamlNode(source, sourceUrl: sourceUrl);
  final rootMap = _expectMap(root, 'The file should start with "sample_edits:".');
  _checkKeys(rootMap, const {'sample_edits'}, 'at the top of the file');

  final listNode = rootMap.nodes['sample_edits'];
  if (listNode == null) {
    throw SourceSpanFormatException('The file should start with "sample_edits:".', rootMap.span);
  }
  if (listNode is! YamlList) {
    throw SourceSpanFormatException(
      'Put each sample edit under "sample_edits:" as a list item starting with "- ".',
      listNode.span,
    );
  }

  return [
    for (final (index, node) in listNode.nodes.indexed) _parseSampleEdit(node, index + 1, thumbnailExists),
  ];
}

const _sampleEditKeys = {'vimeo_id', 'vimeo_access_key', 'vimeo_title', 'thumbnail_image', 'title', 'description'};

final _vimeoIdPattern = RegExp(r'^[0-9]+$');
final _privacyHashPattern = RegExp(r'^[0-9a-zA-Z]+$');
final _thumbnailPattern = RegExp(r'^[\w.-]+\.(jpe?g|png|webp|avif)$', caseSensitive: false);

SampleEdit _parseSampleEdit(YamlNode node, int number, bool Function(String)? thumbnailExists) {
  final where = 'in sample edit $number';
  final map = _expectMap(node, 'Sample edit $number should be a set of "field: value" lines.');
  _checkKeys(map, _sampleEditKeys, where);

  final idNode = _required(map, 'vimeo_id', where);
  final id = _scalarText(idNode, 'vimeo_id', where);
  if (!_vimeoIdPattern.hasMatch(id)) {
    throw SourceSpanFormatException(
      'vimeo_id $where should be the number from the video\'s address, like 1110117832.',
      idNode.span,
    );
  }

  String? privacyHash;
  if (map.nodes['vimeo_access_key'] case final hashNode? when !_isNull(hashNode)) {
    final hash = _scalarText(hashNode, 'vimeo_access_key', where);
    if (const {'none', 'null', 'no', '-'}.contains(hash.toLowerCase())) {
      throw SourceSpanFormatException(
        'Leave out the vimeo_access_key line $where if the video is public.',
        hashNode.span,
      );
    }
    if (!_privacyHashPattern.hasMatch(hash)) {
      throw SourceSpanFormatException(
        'vimeo_access_key $where should be the code after the video number in an unlisted video\'s '
        'address, like 4e7e3098ae.',
        hashNode.span,
      );
    }
    privacyHash = hash;
  }

  final videoTitle = _scalarText(_required(map, 'vimeo_title', where), 'vimeo_title', where).trim();

  final thumbnailNode = _required(map, 'thumbnail_image', where);
  final thumbnail = _scalarText(thumbnailNode, 'thumbnail_image', where).trim();
  if (!_thumbnailPattern.hasMatch(thumbnail)) {
    throw SourceSpanFormatException(
      'thumbnail_image $where should be an image file name, like thumbnail_salieri.jpg.',
      thumbnailNode.span,
    );
  }
  if (thumbnailExists != null && !thumbnailExists(thumbnail)) {
    throw SourceSpanFormatException('Can\'t find the image "$thumbnail" $where.', thumbnailNode.span);
  }

  final title = _parseLines(_required(map, 'title', where), 'title', where);
  if (title.isEmpty) {
    throw SourceSpanFormatException('title $where needs at least one line.', map.nodes['title']!.span);
  }
  final descriptionNode = map.nodes['description'];
  final description = descriptionNode == null ? <RichLine>[] : _parseLines(descriptionNode, 'description', where);

  return SampleEdit(
    video: VimeoVideo(id: id, privacyHash: privacyHash, title: videoTitle),
    thumbnail: thumbnail,
    title: title,
    description: description,
  );
}

List<RichLine> _parseLines(YamlNode node, String field, String where) {
  if (_isNull(node)) return [];
  final lineNodes = node is YamlList ? node.nodes : [node];
  return [for (final lineNode in lineNodes) _parseLine(lineNode, field, where)];
}

RichLine _parseLine(YamlNode node, String field, String where) {
  if (node is YamlMap) {
    throw SourceSpanFormatException(
      'A line of $field $where contains ": ", which YAML reads as a field name. '
      "Put the whole line in single quotes, like '...'.",
      node.span,
    );
  }
  final text = _scalarText(node, field, where);
  try {
    return parseInlineMarkup(text.trim());
  } on FormatException catch (e) {
    final leadingSpaces = text.length - text.trimLeft().length;
    throw SourceSpanFormatException('$field $where: ${e.message}', _spanAt(node, (e.offset ?? 0) + leadingSpaces));
  }
}

/// The span of the character at [offset] in [node]'s text, or all of [node]
/// when the text in the file doesn't map one-to-one to the value.
SourceSpan _spanAt(YamlNode node, int offset) {
  final span = node.span;
  final isVerbatim = node is YamlScalar && node.style == ScalarStyle.PLAIN && !span.text.contains('\n');
  final isQuoted =
      node is YamlScalar &&
      node.style == ScalarStyle.SINGLE_QUOTED &&
      !span.text.contains('\n') &&
      !span.text.contains("''");
  final start = isVerbatim ? offset : (isQuoted ? offset + 1 : null);
  if (start == null || start >= span.length) return span;
  // The FileSpan version of subspan keeps the file, so error messages can
  // quote the line from the file.
  return span is FileSpan ? span.subspan(start, start + 1) : span.subspan(start, start + 1);
}

YamlMap _expectMap(YamlNode node, String message) {
  if (node is YamlMap) return node;
  throw SourceSpanFormatException(message, node.span);
}

void _checkKeys(YamlMap map, Set<String> allowed, String where) {
  for (final key in map.nodes.keys) {
    final name = key is YamlNode ? key.value : key;
    if (!allowed.contains(name)) {
      final span = key is YamlNode ? key.span : map.span;
      throw SourceSpanFormatException(
        'Unknown field "$name" $where. Fields you can use: ${allowed.join(', ')}.',
        span,
      );
    }
  }
}

YamlNode _required(YamlMap map, String key, String where) {
  final node = map.nodes[key];
  if (node == null || _isNull(node)) {
    throw SourceSpanFormatException('Add "$key:" $where.', node?.span ?? map.span);
  }
  return node;
}

bool _isNull(YamlNode node) => node is YamlScalar && node.value == null;

/// The text of a scalar as the manager typed it.
///
/// YAML reads unquoted `0123` as the number 123 and `1.50` as 1.5. For
/// one-line unquoted values the text comes straight from the file instead, so
/// IDs, codes and lines of text keep every character.
String _scalarText(YamlNode node, String field, String where) {
  if (node is! YamlScalar || node.value == null) {
    throw SourceSpanFormatException('$field $where should be a single line of text.', node.span);
  }
  if (node.style == ScalarStyle.PLAIN && !node.span.text.contains('\n')) {
    return node.span.text;
  }
  return node.value.toString();
}

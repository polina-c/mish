/// A line of formatted text: plain text mixed with bold, italic and links.
typedef RichLine = List<InlineNode>;

/// A piece of a [RichLine].
sealed class InlineNode {
  const InlineNode();
}

/// Plain text.
final class TextNode extends InlineNode {
  const TextNode(this.text);

  final String text;

  @override
  bool operator ==(Object other) => other is TextNode && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'TextNode(${_quote(text)})';
}

/// How a [StyledNode] changes the look of its children.
enum InlineStyle { bold, italic }

/// Children shown in bold or italic.
final class StyledNode extends InlineNode {
  const StyledNode(this.style, this.children);

  final InlineStyle style;
  final List<InlineNode> children;

  @override
  bool operator ==(Object other) =>
      other is StyledNode && other.style == style && _listEquals(other.children, children);

  @override
  int get hashCode => Object.hash(style, Object.hashAll(children));

  @override
  String toString() => 'StyledNode(${style.name}, $children)';
}

/// Children that link to [href].
final class LinkNode extends InlineNode {
  const LinkNode(this.href, this.children);

  final Uri href;
  final List<InlineNode> children;

  @override
  bool operator ==(Object other) => other is LinkNode && other.href == href && _listEquals(other.children, children);

  @override
  int get hashCode => Object.hash(href, Object.hashAll(children));

  @override
  String toString() => 'LinkNode($href, $children)';
}

/// Parses a line of text that may contain a small subset of HTML.
///
/// Supported tags:
/// - `<b>` and `<strong>`: bold;
/// - `<i>` and `<em>`: italic;
/// - `<a href="...">`: a link to an `http`, `https` or `mailto` address.
///
/// The entities `&amp;`, `&lt;`, `&gt;`, `&quot;`, `&apos;`, `&nbsp;` and
/// numeric ones like `&#8212;` are decoded. Any other tag, a tag that is not
/// closed, or a link without a valid `href` is a [FormatException].
RichLine parseInlineMarkup(String source) {
  final root = <InlineNode>[];
  final stack = <_OpenTag>[];
  var children = root;
  var position = 0;

  void addText(int end) {
    if (end > position) {
      children.add(TextNode(_decodeEntities(source.substring(position, end))));
    }
  }

  for (final match in _tagPattern.allMatches(source)) {
    addText(match.start);
    position = match.end;

    final isClosing = match.group(1)!.isNotEmpty;
    final name = match.group(2)!.toLowerCase();
    final attributes = match.group(3)!;
    final kind = _tagKinds[name];
    if (kind == null) {
      throw FormatException(
        'Unsupported tag <${match.group(2)}>. Use <b>, <i> or <a href="...">.',
        source,
        match.start,
      );
    }

    if (isClosing) {
      if (stack.isEmpty) {
        throw FormatException('Found </$name> without a matching <$name>.', source, match.start);
      }
      final open = stack.removeLast();
      if (open.kind != kind) {
        throw FormatException('Expected </${open.name}> but found </$name>.', source, match.start);
      }
      final node = switch (open.kind) {
        _TagKind.bold => StyledNode(InlineStyle.bold, open.children),
        _TagKind.italic => StyledNode(InlineStyle.italic, open.children),
        _TagKind.link => LinkNode(open.href!, open.children),
      };
      children = stack.isEmpty ? root : stack.last.children;
      children.add(node);
      continue;
    }

    final Uri? href;
    if (kind == _TagKind.link) {
      href = _parseHref(attributes, source, match.start);
    } else {
      if (attributes.trim().isNotEmpty) {
        throw FormatException('<$name> does not take attributes.', source, match.start);
      }
      href = null;
    }
    final open = _OpenTag(name, kind, href, match.start);
    stack.add(open);
    children = open.children;
  }

  addText(source.length);
  if (stack.isNotEmpty) {
    final open = stack.last;
    throw FormatException('<${open.name}> is never closed. Add </${open.name}>.', source, open.offset);
  }
  return root;
}

enum _TagKind { bold, italic, link }

const _tagKinds = {
  'b': _TagKind.bold,
  'strong': _TagKind.bold,
  'i': _TagKind.italic,
  'em': _TagKind.italic,
  'a': _TagKind.link,
};

class _OpenTag {
  _OpenTag(this.name, this.kind, this.href, this.offset);

  final String name;
  final _TagKind kind;
  final Uri? href;
  final int offset;
  final children = <InlineNode>[];
}

/// Matches `<name ...>` and `</name>`. A lone `<` (as in `a < b`) is text.
final _tagPattern = RegExp(r'<(/?)\s*([a-zA-Z][a-zA-Z0-9]*)([^<>]*)>');

final _hrefPattern = RegExp(r'''^\s*href\s*=\s*(?:"([^"]*)"|'([^']*)')\s*$''');

const _allowedSchemes = {'http', 'https', 'mailto'};

Uri _parseHref(String attributes, String source, int offset) {
  final match = _hrefPattern.firstMatch(attributes);
  if (match == null) {
    throw FormatException('A link needs exactly one attribute: href="https://...".', source, offset);
  }
  final value = _decodeEntities(match.group(1) ?? match.group(2)!).trim();
  final uri = Uri.tryParse(value);
  if (uri == null || !_allowedSchemes.contains(uri.scheme) || (uri.scheme != 'mailto' && uri.host.isEmpty)) {
    throw FormatException(
      'Link address "$value" must be a full address starting with https://, http:// or mailto:.',
      source,
      offset,
    );
  }
  return uri;
}

final _entityPattern = RegExp(r'&(#[0-9]+|#[xX][0-9a-fA-F]+|[a-zA-Z]+);');

const _namedEntities = {'amp': '&', 'lt': '<', 'gt': '>', 'quot': '"', 'apos': "'", 'nbsp': ' '};

String _decodeEntities(String text) {
  return text.replaceAllMapped(_entityPattern, (match) {
    final entity = match.group(1)!;
    if (entity.startsWith('#')) {
      final isHex = entity.length > 1 && (entity[1] == 'x' || entity[1] == 'X');
      final code = int.tryParse(isHex ? entity.substring(2) : entity.substring(1), radix: isHex ? 16 : 10);
      if (code == null || code > 0x10FFFF) return match.group(0)!;
      return String.fromCharCode(code);
    }
    return _namedEntities[entity] ?? match.group(0)!;
  });
}

bool _listEquals(List<Object?> a, List<Object?> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

String _quote(String text) => "'${text.replaceAll("'", r"\'")}'";

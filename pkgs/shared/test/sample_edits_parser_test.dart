import 'package:shared/shared.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

const _validYaml = '''
sample_edits:
  - vimeo_id: 1110117832
    vimeo_access_key: 4e7e3098ae
    vimeo_title: Salieri and Mozart (Short Film)
    thumbnail_image: thumbnail_salieri.jpg
    title:
      - Award winning short film
      - <b><i>Salieri and Mozart</i></b>
    description:
      - Distributed by <a href="https://www.7palmsentertainment.com/">7 Palms</a>. <i>"Young actor develops</i>
      - <i>a profound character—only to trigger the show manager."</i>
  - vimeo_id: 1249036004
    vimeo_title: Previs Reel 2026
    thumbnail_image: thumbnail_previsreel.jpg
    title: <b>Professional Reel</b>
''';

void main() {
  group('parseSampleEdits', () {
    test('reads every field', () {
      final edits = parseSampleEdits(_validYaml);
      expect(edits, hasLength(2));

      final first = edits[0];
      expect(first.video.id, '1110117832');
      expect(first.video.privacyHash, '4e7e3098ae');
      expect(first.video.title, 'Salieri and Mozart (Short Film)');
      expect(first.thumbnail, 'thumbnail_salieri.jpg');
      expect(first.title, [
        [const TextNode('Award winning short film')],
        [
          const StyledNode(InlineStyle.bold, [
            StyledNode(InlineStyle.italic, [TextNode('Salieri and Mozart')]),
          ]),
        ],
      ]);
      expect(first.description, hasLength(2));
      expect(first.description[1], [
        const StyledNode(InlineStyle.italic, [TextNode('a profound character—only to trigger the show manager."')]),
      ]);
    });

    test('allows a one-line title, no description and no access key', () {
      final second = parseSampleEdits(_validYaml)[1];
      expect(second.video.privacyHash, isNull);
      expect(second.title, [
        [
          const StyledNode(InlineStyle.bold, [TextNode('Professional Reel')]),
        ],
      ]);
      expect(second.description, isEmpty);
    });

    test('keeps codes exactly as typed', () {
      final edits = parseSampleEdits('''
sample_edits:
  - vimeo_id: 0123
    vimeo_access_key: 1234e5678
    vimeo_title: 2024
    thumbnail_image: a.jpg
    title: 1.50
''');
      expect(edits.single.video.id, '0123');
      expect(edits.single.video.privacyHash, '1234e5678');
      expect(edits.single.video.title, '2024');
      expect(edits.single.title.single, [const TextNode('1.50')]);
    });

    test('allows an empty list', () {
      expect(parseSampleEdits('sample_edits: []'), isEmpty);
    });

    group('reports', () {
      void expectError(String yaml, String messagePart, {int? line, bool Function(String)? thumbnailExists}) {
        expect(
          () => parseSampleEdits(yaml, sourceUrl: Uri.file('sample_edits.yaml'), thumbnailExists: thumbnailExists),
          throwsA(
            isA<SourceSpanFormatException>()
                .having((e) => e.message, 'message', contains(messagePart))
                .having((e) => e.span?.start.line, 'line (0-based)', line ?? anything),
          ),
        );
      }

      const header = 'sample_edits:\n';

      test('a missing sample_edits key', () => expectError('foo: 1', 'Unknown field "foo"'));
      test('an empty file', () => expectError('', 'should start with "sample_edits:"'));
      test('a map instead of a list', () {
        expectError('$header  sample_edit_1:\n    vimeo_id: 1\n', 'list item starting with "- "');
      });
      test('unknown fields', () {
        expectError(
          '$header  - vimeo_id: 1\n    vimeo_title: t\n    thumbnail_image: a.jpg\n    title_line_1: x\n',
          'Unknown field "title_line_1" in sample edit 1',
          line: 4,
        );
      });
      test('missing fields', () {
        expectError('$header  - vimeo_id: 1\n    thumbnail_image: a.jpg\n    title: x\n', 'Add "vimeo_title:"');
      });
      test('a bad vimeo_id', () {
        expectError(
          '$header  - vimeo_id: abc\n    vimeo_title: t\n    thumbnail_image: a.jpg\n    title: x\n',
          'vimeo_id in sample edit 1',
          line: 1,
        );
      });
      test('"none" as an access key', () {
        expectError(
          '$header  - vimeo_id: 1\n    vimeo_access_key: none\n    vimeo_title: t\n    thumbnail_image: a.jpg\n'
              '    title: x\n',
          'Leave out the vimeo_access_key line',
          line: 2,
        );
      });
      test('a thumbnail that is not an image', () {
        expectError(
          '$header  - vimeo_id: 1\n    vimeo_title: t\n    thumbnail_image: notes.txt\n    title: x\n',
          'image file name',
        );
      });
      test('a missing thumbnail', () {
        expectError(
          '$header  - vimeo_id: 1\n    vimeo_title: t\n    thumbnail_image: a.jpg\n    title: x\n',
          'Can\'t find the image "a.jpg"',
          line: 3,
          thumbnailExists: (_) => false,
        );
      });
      test('bad markup, pointing at the tag', () {
        expect(
          () => parseSampleEdits(
            '$header  - vimeo_id: 1\n    vimeo_title: t\n    thumbnail_image: a.jpg\n    title: a <u>b</u>\n',
          ),
          throwsA(
            isA<SourceSpanFormatException>()
                .having((e) => e.message, 'message', startsWith('title in sample edit 1: Unsupported tag <u>.'))
                .having((e) => e.span?.start.line, 'line', 4)
                .having((e) => e.span?.start.column, 'column', 13)
                // The message quotes the line from the file.
                .having((e) => e.toString(), 'toString()', contains('5 │     title: a <u>b</u>')),
          ),
        );
      });
      test('a line with ": " that YAML reads as a field', () {
        expectError(
          '$header  - vimeo_id: 1\n    vimeo_title: t\n    thumbnail_image: a.jpg\n    title:\n      - Runtime: 12 minutes\n',
          'Put the whole line in single quotes',
          line: 5,
        );
      });
      test('YAML syntax errors', () {
        expectError('$header  - vimeo_id: 1\n   bad indent: [\n', '');
      });
    });
  });

  group('VimeoVideo.embedUrl', () {
    test('includes the privacy hash for unlisted videos', () {
      expect(
        const VimeoVideo(id: '1110117832', privacyHash: '4e7e3098ae', title: 't').embedUrl.toString(),
        'https://player.vimeo.com/video/1110117832?h=4e7e3098ae&autoplay=1',
      );
    });

    test('leaves the hash out for public videos', () {
      expect(
        const VimeoVideo(id: '1111856817', title: 't').embedUrl.toString(),
        'https://player.vimeo.com/video/1111856817?autoplay=1',
      );
    });
  });
}

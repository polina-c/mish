import 'package:shared/shared.dart';
import 'package:test/test.dart';

void main() {
  group('parseInlineMarkup', () {
    test('returns plain text as one node', () {
      expect(parseInlineMarkup('Award winning short film'), [const TextNode('Award winning short film')]);
    });

    test('returns nothing for an empty line', () {
      expect(parseInlineMarkup(''), isEmpty);
    });

    test('parses nested bold and italic', () {
      expect(parseInlineMarkup('<b><i>Salieri and Mozart</i></b>'), [
        const StyledNode(InlineStyle.bold, [
          StyledNode(InlineStyle.italic, [TextNode('Salieri and Mozart')]),
        ]),
      ]);
    });

    test('treats strong and em like b and i', () {
      expect(parseInlineMarkup('<strong>a</strong><em>b</em>'), [
        const StyledNode(InlineStyle.bold, [TextNode('a')]),
        const StyledNode(InlineStyle.italic, [TextNode('b')]),
      ]);
    });

    test('ignores tag case', () {
      expect(parseInlineMarkup('<B>a</b>'), [
        const StyledNode(InlineStyle.bold, [TextNode('a')]),
      ]);
    });

    test('parses a link with text around it', () {
      expect(
        parseInlineMarkup(
          'Distributed by <a href="https://www.7palmsentertainment.com/"><b><i>7 Palms Entertainment</i></b></a>. '
          '<i>"Young actor develops</i>',
        ),
        [
          const TextNode('Distributed by '),
          LinkNode(Uri.parse('https://www.7palmsentertainment.com/'), const [
            StyledNode(InlineStyle.bold, [
              StyledNode(InlineStyle.italic, [TextNode('7 Palms Entertainment')]),
            ]),
          ]),
          const TextNode('. '),
          const StyledNode(InlineStyle.italic, [TextNode('"Young actor develops')]),
        ],
      );
    });

    test('accepts single-quoted and mailto links', () {
      expect(parseInlineMarkup("<a href='mailto:mish@cutforchange.com'>mail</a>"), [
        LinkNode(Uri.parse('mailto:mish@cutforchange.com'), const [TextNode('mail')]),
      ]);
    });

    test('keeps a lone < as text', () {
      expect(parseInlineMarkup('cut < 5 min'), [const TextNode('cut < 5 min')]);
    });

    test('decodes entities', () {
      expect(parseInlineMarkup('Tom &amp; Jerry &#8212; &quot;hi&quot; &#x2014; &unknown;'), [
        const TextNode('Tom & Jerry — "hi" — &unknown;'),
      ]);
    });

    group('rejects', () {
      void expectError(String source, String messagePart, int offset) {
        expect(
          () => parseInlineMarkup(source),
          throwsA(
            isA<FormatException>()
                .having((e) => e.message, 'message', contains(messagePart))
                .having((e) => e.offset, 'offset', offset),
          ),
        );
      }

      test('unsupported tags', () => expectError('a <u>b</u>', 'Unsupported tag <u>', 2));
      test('unclosed tags', () => expectError('a <b>b', '<b> is never closed', 2));
      test('mismatched closing tags', () => expectError('<b><i>x</b></i>', 'Expected </i> but found </b>', 7));
      test('stray closing tags', () => expectError('x</i>', 'without a matching', 1));
      test('links without href', () => expectError('<a>x</a>', 'href', 0));
      test('relative links', () => expectError('<a href="7palms.com">x</a>', 'full address', 0));
      test('javascript links', () => expectError('<a href="javascript:alert(1)">x</a>', 'full address', 0));
      test('attributes on b', () => expectError('<b class="x">y</b>', 'does not take attributes', 0));
    });
  });
}

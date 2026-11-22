import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:shared/shared.dart';

/// Renders lines of formatted text.
///
/// Each line is a `<span class="line">`. The stylesheet decides whether lines
/// stack, as in the design, or run together on narrow screens. The space
/// between lines keeps words apart when they run together.
class RichLines extends StatelessComponent {
  const RichLines(this.lines, {super.key});

  /// Lines of plain text.
  RichLines.plain(List<String> lines, {Key? key})
    : this([
        for (final line in lines) [TextNode(line)],
      ], key: key);

  final List<RichLine> lines;

  @override
  Component build(BuildContext context) {
    return .fragment([
      for (final (index, line) in lines.indexed) ...[
        if (index > 0) const .text(' '),
        span(classes: 'line', [for (final node in line) _inline(node)]),
      ],
    ]);
  }
}

Component _inline(InlineNode node) {
  return switch (node) {
    TextNode(:final text) => .text(text),
    StyledNode(style: .bold, :final children) => b([for (final child in children) _inline(child)]),
    StyledNode(style: .italic, :final children) => i([for (final child in children) _inline(child)]),
    LinkNode(:final href, :final children) => a(
      href: href.toString(),
      target: .blank,
      attributes: const {'rel': 'noopener'},
      [for (final child in children) _inline(child)],
    ),
  };
}

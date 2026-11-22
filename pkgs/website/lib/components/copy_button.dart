import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../styles/theme.dart';

/// An icon button that puts [text] on the clipboard, then shows a check mark
/// for a moment.
///
/// This runs in the browser.
@client
class CopyButton extends StatefulComponent {
  const CopyButton({required this.text, required this.label, super.key});

  /// What the button copies.
  final String text;

  /// What the button does, for screen readers and as a tooltip, like
  /// "Copy email address".
  final String label;

  @override
  State<CopyButton> createState() => _CopyButtonState();

  // The icon is sized and placed for a line of intermediate text.
  static final _iconSize = du(96);
  static final _padding = du(16);

  @css
  static List<StyleRule> get styles => [
    css('.copy-button', [
      css('&').styles(
        display: .inlineFlex,
        position: .relative(top: du(-12)),
        padding: .all(_padding),
        // The padding makes the button easier to hit without moving the icon
        // away from the address. The vertical margins cancel the button's
        // height, so it doesn't make the line of text taller.
        margin: .only(
          left: du(12),
          right: Unit.expression('calc(-1 * ${_padding.value})'),
          top: Unit.expression('calc(-0.5 * (${_iconSize.value} + 2 * ${_padding.value}))'),
          bottom: Unit.expression('calc(-0.5 * (${_iconSize.value} + 2 * ${_padding.value}))'),
        ),
        border: .unset,
        cursor: .pointer,
        color: Palette.greyLight,
        backgroundColor: Colors.transparent,
        raw: {
          // With the 12 canvas pixel lift above, centers the icon on the
          // height of capital letters.
          'vertical-align': 'middle',
          'transition': 'color 150ms',
        },
      ),
      css('&:hover').styles(color: Palette.white),
      css('&.copied').styles(color: Palette.accentBright),
      css('svg').styles(
        display: .block,
        width: _iconSize,
        height: _iconSize,
        raw: {
          'fill': 'none',
          'stroke': 'currentColor',
          'stroke-width': '1.75',
          'stroke-linecap': 'square',
        },
      ),
    ]),
  ];
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;
  Timer? _resetIcon;

  Future<void> _copy() async {
    try {
      await web.window.navigator.clipboard.writeText(component.text).toDart;
    } catch (_) {
      // The browser refused, for example on a page served over plain http.
      return;
    }
    if (!mounted) return;
    setState(() => _copied = true);
    _resetIcon?.cancel();
    _resetIcon = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  void dispose() {
    _resetIcon?.cancel();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    final label = _copied ? 'Copied' : component.label;
    return button(
      classes: _copied ? 'copy-button copied' : 'copy-button',
      type: .button,
      attributes: {'aria-label': label, 'title': label},
      onClick: _copy,
      [
        svg(viewBox: '0 0 24 24', attributes: const {'aria-hidden': 'true'}, [
          // A check mark, or two overlapping sheets.
          path(d: _copied ? 'M4 12.5l5 5L20 6.5' : 'M8 8h13v13H8zM16 8V3H3v13h5', []),
        ]),
      ],
    );
  }
}

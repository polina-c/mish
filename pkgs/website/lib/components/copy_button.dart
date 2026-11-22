import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../styles/theme.dart';

/// A "copy" button that puts [text] on the clipboard, then says "copied" for
/// a moment.
///
/// This runs in the browser.
@client
class CopyButton extends StatefulComponent {
  const CopyButton({required this.text, required this.label, super.key});

  /// What the button copies.
  final String text;

  /// What the button does, for screen readers, like "Copy email address".
  final String label;

  @override
  State<CopyButton> createState() => _CopyButtonState();

  @css
  static List<StyleRule> get styles => [
    css('.copy-button', [
      css('&').styles(
        padding: .symmetric(vertical: du(12), horizontal: du(32)),
        // The negative margins cancel the vertical padding, so the button
        // doesn't make the line of text it sits in taller.
        margin: .only(left: du(40), top: du(-12), bottom: du(-12)),
        border: .unset,
        cursor: .pointer,
        userSelect: .none,
        color: Palette.greyLight,
        fontFamily: .inherit,
        fontSize: TextSize.small,
        fontWeight: .w500,
        lineHeight: du(88),
        backgroundColor: Palette.greyDark,
        raw: {
          // Both labels share one grid cell, so the button keeps its width
          // when the label changes.
          'display': 'inline-grid',
          'vertical-align': 'baseline',
          'transition': 'color 150ms, background-color 150ms',
        },
      ),
      css('&:hover').styles(color: Palette.white, backgroundColor: Palette.greyMedium),
      css('& > span').styles(raw: {'grid-area': '1 / 1'}),
      css('&:not(.copied) .copy-button-done, &.copied .copy-button-idle').styles(visibility: .hidden),
    ]),
  ];
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;
  Timer? _resetLabel;

  Future<void> _copy() async {
    try {
      await web.window.navigator.clipboard.writeText(component.text).toDart;
    } catch (_) {
      // The browser refused, for example on a page served over plain http.
      return;
    }
    if (!mounted) return;
    setState(() => _copied = true);
    _resetLabel?.cancel();
    _resetLabel = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  void dispose() {
    _resetLabel?.cancel();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return button(
      classes: _copied ? 'copy-button copied' : 'copy-button',
      type: .button,
      attributes: {'aria-label': _copied ? 'Copied' : component.label},
      onClick: _copy,
      [
        span(classes: 'copy-button-idle', [.text('copy')]),
        span(classes: 'copy-button-done', [.text('copied')]),
      ],
    );
  }
}

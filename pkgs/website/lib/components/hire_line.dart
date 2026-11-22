import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../styles/theme.dart';
import 'copy_button.dart';

/// "Hire Mikhail: Mish@cutforchange.com", with the address as a mail link
/// and a button that copies it.
class HireLine extends StatelessComponent {
  const HireLine({super.key});

  static const _mailbox = 'Mish';
  static const _domain = 'cutforchange.com';

  @override
  Component build(BuildContext context) {
    return p(classes: 'hire', [
      .text('Hire Mikhail: '),
      // Keeps the copy button on the same line as the address.
      span(classes: 'hire-contact', [
        a(href: 'mailto:$_mailbox@$_domain', classes: 'hire-email', [
          span(classes: 'hire-mailbox', [.text(_mailbox)]),
          .text('@$_domain'),
        ]),
        const CopyButton(text: '$_mailbox@$_domain', label: 'Copy email address'),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.hire', [
      css('&').styles(
        margin: .only(top: du(108.65)),
        color: Palette.accentBright,
        textAlign: .center,
        fontSize: TextSize.intermediate,
        lineHeight: du(114.4),
      ),
      css('.hire-contact').styles(whiteSpace: .noWrap),
      css('.hire-email').styles(
        color: Palette.greyLight,
        textDecoration: .none,
        raw: {'text-underline-offset': '0.15em'},
      ),
      css('.hire-email:hover').styles(raw: {'text-decoration-line': 'underline'}),
      css('.hire-mailbox').styles(color: Palette.white),
    ]),
  ];
}

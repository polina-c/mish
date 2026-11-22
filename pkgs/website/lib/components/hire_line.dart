import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../styles/theme.dart';

/// "Hire Mikhail: Mish@cutforchange.com", with the address as a mail link.
class HireLine extends StatelessComponent {
  const HireLine({super.key});

  static const _mailbox = 'Mish';
  static const _domain = 'cutforchange.com';

  @override
  Component build(BuildContext context) {
    return p(classes: 'hire', [
      .text('Hire Mikhail: '),
      a(href: 'mailto:$_mailbox@$_domain', classes: 'hire-email', [
        span(classes: 'hire-mailbox', [.text(_mailbox)]),
        .text('@$_domain'),
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

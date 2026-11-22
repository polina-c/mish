import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../styles/theme.dart';
import 'rich_lines.dart';

/// Mikhail's photo, name, short bio, tools and languages.
class PersonCard extends StatelessComponent {
  const PersonCard({super.key});

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'person',
      attributes: const {'aria-labelledby': 'person-name'},
      [
        img(
          classes: 'person-photo',
          src: 'images/headshot.jpg',
          alt: 'Portrait of Mikhail Cherkasov',
          width: 768,
          height: 1024,
        ),
        div(classes: 'person-intro', [
          h2(id: 'person-name', classes: 'person-name', [.text('Mikhail Cherkasov')]),
          p(classes: 'person-role', [
            .text('film editor '),
            span(classes: 'person-role-dot', [.text('•')]),
            .text(' story artist'),
          ]),
        ]),
        p(classes: 'person-bio', [
          RichLines.plain(const [
            'Crafting narratives for 11 years, Mikhail fights not only',
            'for powerful moments—but for wholesome worlds.',
            'He cuts for change both fictional and real.',
          ]),
        ]),
        div(classes: 'person-skills', [
          ul(
            classes: 'person-tools',
            attributes: const {'aria-label': 'Editing software'},
            [
              li([
                img(
                  src: 'images/icons/avid.svg',
                  alt: 'Avid Media Composer',
                  width: 258,
                  height: 258,
                  attributes: const {'title': 'Avid Media Composer'},
                ),
              ]),
              li([
                img(
                  src: 'images/icons/resolve.webp',
                  alt: 'DaVinci Resolve',
                  width: 258,
                  height: 258,
                  attributes: const {'title': 'DaVinci Resolve'},
                ),
              ]),
            ],
          ),
          ul(classes: 'person-languages', [
            li([.text('Fluent in Russian')]),
            li([.text('Intermediate in French')]),
          ]),
        ]),
      ],
    );
  }

  // Measurements are from design/d03__local-measurments__person.jpg. Each
  // text block's padding puts its first baseline where the design has it.
  @css
  static List<StyleRule> get styles => [
    css('.person', [
      css('&').styles(
        display: .grid,
        width: du(2762),
        maxWidth: 100.percent,
        margin: .only(top: du(183)),
        raw: {
          'grid-template-columns': '${du(784).value} 1fr',
          'grid-template-rows':
              'minmax(${du(347).value}, auto) minmax(${du(346).value}, auto) minmax(${du(347).value}, auto)',
          'grid-template-areas': '"photo intro" "photo bio" "photo skills"',
        },
      ),
      css('.person-photo').styles(
        display: .block,
        boxSizing: .borderBox,
        width: 100.percent,
        height: 100.percent,
        border: .all(style: .solid, color: Palette.accentBright, width: du(8)),
        raw: {'grid-area': 'photo', 'object-fit': 'cover'},
      ),
      css('.person-intro').styles(
        padding: .only(top: du(27.33), left: du(46), right: du(46)),
        backgroundColor: Palette.accentMedium,
        raw: {'grid-area': 'intro'},
      ),
      css('.person-name').styles(
        margin: .zero,
        fontSize: TextSize.large,
        fontWeight: .w500,
        lineHeight: du(171.2),
      ),
      css('.person-role').styles(
        margin: .zero,
        color: Palette.accentBright,
        fontSize: TextSize.intermediate,
        lineHeight: du(122.7),
      ),
      css('.person-role-dot').styles(color: Palette.greyLight),
      css('.person-bio', [
        css('&').styles(
          margin: .zero,
          padding: .only(top: du(14.07), left: du(46), right: du(46)),
          color: Palette.greyLight,
          raw: {'grid-area': 'bio'},
        ),
        css('.line').styles(display: .block),
      ]),
      css('.person-skills').styles(
        display: .flex,
        padding: .symmetric(horizontal: du(46)),
        alignItems: .center,
        backgroundColor: Palette.accentDark,
        raw: {'grid-area': 'skills'},
      ),
      css('.person-tools', [
        css('&').styles(
          display: .flex,
          margin: .only(right: du(60)),
          padding: .zero,
          gap: .column(du(50)),
          listStyle: .none,
        ),
        css('img').styles(display: .block, width: du(258), height: du(258)),
      ]),
      css('.person-languages').styles(
        margin: .only(bottom: du(11.42)),
        padding: .zero,
        listStyle: .none,
        fontSize: TextSize.intermediate,
        lineHeight: TextSize.intermediateLineHeight,
      ),
    ]),
    css.media(narrowScreen, [
      css('.person', [
        css('&').styles(
          width: 100.percent,
          maxWidth: 560.px,
          raw: {
            'grid-template-columns': '1fr',
            'grid-template-rows': 'auto',
            'grid-template-areas': '"photo" "intro" "bio" "skills"',
          },
        ),
        css('.person-photo').styles(height: .auto, raw: {'aspect-ratio': '784 / 1040'}),
        css('.person-intro').styles(padding: .fromLTRB(du(88), du(66), du(88), du(77))),
        css('.person-bio', [
          css('&').styles(padding: .fromLTRB(du(88), du(66), du(88), du(77))),
          css('.line').styles(display: .inline),
        ]),
        css('.person-skills').styles(
          padding: .fromLTRB(du(88), du(66), du(88), du(66)),
          flexWrap: .wrap,
          gap: Gap(row: du(66), column: du(66)),
        ),
        css('.person-tools').styles(margin: .zero),
        css('.person-languages').styles(margin: .zero),
      ]),
    ]),
  ];
}

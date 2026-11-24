import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'components/hire_line.dart';
import 'components/person_card.dart';
import 'components/rich_lines.dart';
import 'components/sample_edit_card.dart';
import 'content.dart';
import 'styles/theme.dart';

/// The whole page, laid out as in design/d01__design.jpg.
///
/// Renders on the server. Only [SampleEditCard] runs in the browser.
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    final sampleEdits = loadSampleEdits();

    return div(classes: 'page', [
      header([
        p(classes: 'welcome', [.text('Welcome')]),
        h1(classes: 'logo', [
          img(src: 'images/logo.svg', alt: 'Cut for Change: Editing & Story Services', width: 2048, height: 576),
        ]),
      ]),
      main_([
        const PersonCard(),
        const HireLine(),
        section(
          classes: 'sample-edits',
          attributes: const {'aria-labelledby': 'sample-edits-heading'},
          [
            h2(id: 'sample-edits-heading', classes: 'sample-edits-heading', [.text("Mikhail's sample edits:")]),
            ul(classes: 'sample-edit-list', [
              for (final edit in sampleEdits)
                li([
                  SampleEditCard(
                    videoTitle: edit.video.title,
                    embedUrl: edit.video.embedUrl.toString(),
                    thumbnailSrc: '$thumbnailsPath/${edit.thumbnail}',
                    title: RichLines(edit.title),
                    description: RichLines(edit.description),
                  ),
                ]),
            ]),
          ],
        ),
      ]),
      footer([
        const HireLine(),
        p(classes: 'version', [.text('v 1.02')]),
      ]),
    ]);
  }

  // Vertical spacing is from design/d02__global-measurments.jpg, which
  // measures between baselines. Each margin is that distance minus the space
  // the line box adds above and below its baseline.
  @css
  static List<StyleRule> get styles => [
    css('.page', [
      css('&').styles(
        display: .flex,
        padding: .only(top: du(150.35), bottom: du(218)),
        flexDirection: .column,
        alignItems: .center,
      ),
      css('& > header, & > main, & > footer').styles(
        display: .flex,
        width: 100.percent,
        flexDirection: .column,
        alignItems: .center,
      ),
    ]),
    css('.welcome').styles(
      margin: .zero,
      color: Palette.greyLight,
      fontSize: TextSize.large,
      fontWeight: .w500,
      lineHeight: du(171.2),
    ),
    css('.logo', [
      css('&').styles(
        width: du(2664),
        maxWidth: 100.percent,
        margin: .only(top: du(73.45)),
      ),
      css('img').styles(display: .block, width: 100.percent, height: .auto),
    ]),
    css('.sample-edits').styles(
      width: du(3274),
      maxWidth: 100.percent,
      margin: .only(top: du(251.3)),
    ),
    css('.sample-edits-heading').styles(
      margin: .zero,
      fontSize: TextSize.large,
      fontWeight: .w500,
      lineHeight: du(171.2),
    ),
    css('.version').styles(
      margin: .only(top: du(500)),
      color: Palette.greyMedium,
      fontSize: du(66),
      lineHeight: du(75.9),
    ),
    css('.sample-edit-list').styles(
      display: .flex,
      padding: .zero,
      margin: .only(top: du(100.45)),
      flexDirection: .column,
      gap: .row(du(158)),
      listStyle: .none,
    ),
    css.media(narrowScreen, [
      css('.page').styles(padding: .symmetric(horizontal: narrowGutter)),
      css('.sample-edits').styles(width: 100.percent, maxWidth: 560.px),
    ]),
  ];
}

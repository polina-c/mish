import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import '../styles/theme.dart';

/// A sample edit: thumbnail, title, "Click to watch" button and description.
///
/// Clicking the thumbnail or the button opens the Vimeo player on top of the
/// page. Clicking anywhere around the player, the close button or pressing
/// Escape closes it, which also stops the video.
///
/// This runs in the browser. [title] and [description] are rendered on the
/// server and passed in as they are.
@client
class SampleEditCard extends StatefulComponent {
  const SampleEditCard({
    required this.videoTitle,
    required this.embedUrl,
    required this.thumbnailSrc,
    required this.title,
    required this.description,
    super.key,
  });

  /// The video's name, for screen readers.
  final String videoTitle;

  /// Address of the Vimeo player.
  final String embedUrl;

  final String thumbnailSrc;

  final Component title;

  final Component description;

  @override
  State<SampleEditCard> createState() => _SampleEditCardState();

  // Measurements are from design/d04__local-measurments__sample-edit.jpg.
  // Text blocks are centered, then nudged up a few canvas pixels to sit
  // where the design has their baselines.
  @css
  static List<StyleRule> get styles => [
    css('.sample-edit', [
      css('&').styles(
        display: .grid,
        raw: {
          'grid-template-columns': '${du(1040).value} 1fr ${du(677).value}',
          'grid-template-rows': 'minmax(${du(296).value}, auto) minmax(${du(296).value}, auto)',
          'grid-template-areas': '"thumbnail title cta" "thumbnail description description"',
        },
      ),
      css('.sample-edit-thumbnail', [
        css('&').styles(
          display: .block,
          boxSizing: .borderBox,
          width: 100.percent,
          height: 100.percent,
          padding: .zero,
          margin: .zero,
          border: .all(style: .solid, color: Palette.white, width: du(8)),
          cursor: .pointer,
          backgroundColor: const Color('#000'),
          raw: {'grid-area': 'thumbnail', 'transition': 'border-color 150ms'},
        ),
        css('&:hover').styles(raw: {'border-color': Palette.accentBright.value}),
        css('img').styles(display: .block, width: 100.percent, height: 100.percent, raw: {'object-fit': 'cover'}),
      ]),
      css('.sample-edit-title', [
        css('&').styles(
          display: .flex,
          padding: .only(left: du(46), right: du(46), bottom: du(14.3)),
          margin: .zero,
          flexDirection: .column,
          justifyContent: .center,
          backgroundColor: Palette.greyMedium,
          fontSize: TextSize.intermediate,
          fontWeight: .w500,
          lineHeight: TextSize.intermediateLineHeight,
          raw: {'grid-area': 'title'},
        ),
        css('b, strong').styles(fontWeight: .w700),
      ]),
      css('.sample-edit-cta', [
        css('&').styles(
          display: .flex,
          padding: .zero,
          margin: .zero,
          border: .unset,
          cursor: .pointer,
          flexDirection: .column,
          justifyContent: .center,
          alignItems: .center,
          color: Palette.greyMedium,
          fontFamily: .inherit,
          fontSize: TextSize.large,
          fontWeight: .w700,
          textTransform: .upperCase,
          lineHeight: TextSize.largeLineHeight,
          backgroundColor: Palette.accentBright,
          raw: {'grid-area': 'cta', 'transition': 'color 150ms'},
        ),
        css('&:hover').styles(color: Palette.nearlyBlack),
      ]),
      css('.sample-edit-description', [
        css('&').styles(
          display: .flex,
          padding: .only(left: du(46), right: du(46), bottom: du(11)),
          flexDirection: .column,
          justifyContent: .center,
          color: Palette.greyLight,
          backgroundColor: Palette.greyDark,
          raw: {'grid-area': 'description'},
        ),
        css('b, strong').styles(fontWeight: .w500),
        css('a').styles(color: .inherit, raw: {'text-underline-offset': '0.12em', 'transition': 'color 150ms'}),
        css('a:hover').styles(color: Palette.white),
      ]),
    ]),
    css('.player', [
      css('&').styles(
        width: const .variable('--player-width'),
        height: const .expression('calc(var(--player-width) * 9 / 16)'),
        maxWidth: const .expression('none'),
        maxHeight: const .expression('none'),
        padding: .zero,
        border: .unset,
        overflow: .visible,
        color: Palette.white,
        backgroundColor: const Color('#000'),
        raw: {'--player-width': 'min(90vw, (100dvh - 128px) * 16 / 9)'},
      ),
      css('&::backdrop').styles(backgroundColor: const Color('rgb(8 8 8 / 0.88)')),
      css('iframe').styles(
        display: .block,
        width: 100.percent,
        height: 100.percent,
        border: .unset,
        // Vimeo's page is light. With the page's dark color scheme, browsers
        // would paint a white canvas behind it, showing as white letterbox bars.
        raw: {'color-scheme': 'light'},
      ),
    ]),
    css('.player-close', [
      css('&').styles(
        position: .absolute(right: .zero, bottom: 100.percent),
        width: 48.px,
        height: 48.px,
        padding: .zero,
        margin: .only(bottom: 8.px),
        border: .unset,
        cursor: .pointer,
        color: Palette.greyLight,
        fontFamily: .inherit,
        fontSize: 44.px,
        lineHeight: 48.px,
        backgroundColor: Colors.transparent,
      ),
      css('&:hover').styles(color: Palette.white),
    ]),
    css.media(narrowScreen, [
      css('.sample-edit', [
        css('&').styles(
          raw: {
            'grid-template-columns': '1fr',
            'grid-template-rows': 'auto',
            'grid-template-areas': '"thumbnail" "title" "description" "cta"',
          },
        ),
        css('.sample-edit-thumbnail').styles(height: .auto, raw: {'aspect-ratio': '1040 / 592'}),
        css('.sample-edit-title').styles(padding: .fromLTRB(du(88), du(66), du(88), du(77))),
        css('.sample-edit-description', [
          css('&').styles(display: .block, padding: .fromLTRB(du(88), du(66), du(88), du(77))),
          css('&:empty').styles(display: .none),
          css('.line').styles(display: .inline),
        ]),
        css('.sample-edit-cta', [
          css('&').styles(
            display: .block,
            padding: .symmetric(vertical: du(50), horizontal: du(88)),
          ),
          css('.line').styles(display: .inline),
        ]),
      ]),
    ]),
  ];
}

class _SampleEditCardState extends State<SampleEditCard> {
  final _player = GlobalNodeKey<web.HTMLDialogElement>();

  /// Whether the player's iframe is in the page. Removing it stops the video.
  bool _playing = false;

  void _open() {
    setState(() => _playing = true);
    _player.currentNode?.showModal();
  }

  void _close() => _player.currentNode?.close();

  @override
  Component build(BuildContext context) {
    return article(classes: 'sample-edit', [
      button(
        classes: 'sample-edit-thumbnail',
        type: .button,
        attributes: {'aria-label': 'Watch ${component.videoTitle}'},
        onClick: _open,
        [img(src: component.thumbnailSrc, alt: '', width: 1024, height: 576, loading: .lazy)],
      ),
      h3(classes: 'sample-edit-title', [component.title]),
      button(
        classes: 'sample-edit-cta',
        type: .button,
        attributes: {'aria-label': 'Click to watch: ${component.videoTitle}'},
        onClick: _open,
        [
          span(classes: 'line', [.text('Click to')]),
          .text(' '),
          span(classes: 'line', [.text('watch')]),
        ],
      ),
      div(classes: 'sample-edit-description', [component.description]),
      dialog(
        key: _player,
        classes: 'player',
        attributes: {'aria-label': component.videoTitle},
        events: {
          'close': (_) => setState(() => _playing = false),
          // The iframe fills the dialog and keeps its own clicks, so a click
          // that reaches the dialog landed on the backdrop around the player.
          'click': (_) => _close(),
        },
        [
          button(
            classes: 'player-close',
            type: .button,
            attributes: const {'aria-label': 'Close video'},
            onClick: _close,
            [.text('×')],
          ),
          if (_playing)
            iframe(
              src: component.embedUrl,
              allow: 'autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share',
              referrerPolicy: .strictOriginWhenCrossOrigin,
              attributes: {'title': component.videoTitle},
              [],
            ),
        ],
      ),
    ]);
  }
}

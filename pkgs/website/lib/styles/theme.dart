import 'package:jaspr/dom.dart';

/// The palette from `docs/specs/01_delivery-package/design/colors`.
abstract final class Palette {
  /// The page background.
  static const nearlyBlack = Color('#080808');
  static const greyDark = Color('#262626');
  static const greyMedium = Color('#575757');
  static const greyLight = Color('#A8A8A8');
  static const white = Color('#FFFFFF');
  static const accentDark = Color('#2A1706');
  static const accentMedium = Color('#402309');
  static const accentBright = Color('#EB8220');
}

/// A length from the design, in pixels of its 4000 px wide canvas.
///
/// The CSS variable `--u` holds the size of one canvas pixel. On wide screens
/// it scales with the window so the page keeps the design's proportions, and
/// stops growing at 1600 px, the window width the design was drawn at. On
/// narrow screens it has a floor so text stays readable.
Unit du(num canvasPixels) => Unit.expression('calc(${_number(canvasPixels)} * var(--u))');

String _number(num value) => value == value.roundToDouble() ? value.toInt().toString() : value.toString();

/// The design's three text sizes, SMALL : INTERMEDIATE : LARGE = 110 : 143 : 214.
///
/// Those numbers are Blender font sizes. One Blender unit is 0.8 canvas
/// pixels of em, so the CSS sizes are 88, 114.4 and 171.2 canvas pixels.
/// The line heights follow the design's Blender line spacing (92, 88, 63.3).
abstract final class TextSize {
  static final small = du(88);
  static final smallLineHeight = du(101.2);

  static final intermediate = du(114.4);
  static final intermediateLineHeight = du(125.84);

  static final large = du(171.2);
  static final largeLineHeight = du(135.5);
}

/// Layout switches to a single column below this width.
const narrowScreen = MediaQuery.raw('(max-width: 719.98px)');

/// Side margin of the page on narrow screens.
final narrowGutter = 16.px;

@css
List<StyleRule> get globalStyles => [
  const _AfacadFontFace(url: 'fonts/Afacad-Variable.woff2', style: 'normal'),
  const _AfacadFontFace(url: 'fonts/Afacad-Italic-Variable.woff2', style: 'italic'),
  css(':root').styles(raw: {'--u': 'min(0.4px, 100vw / 4000)', 'color-scheme': 'dark'}),
  css.media(narrowScreen, [
    css(':root').styles(raw: {'--u': 'max(0.182px, 100vw / 4000)'}),
  ]),
  css('html').styles(
    backgroundColor: Palette.nearlyBlack,
    raw: {'scrollbar-gutter': 'stable', '-webkit-text-size-adjust': '100%', 'text-size-adjust': '100%'},
  ),
  // Keeps the page still while a video plays on top of it.
  css('html:has(dialog[open])').styles(overflow: .hidden),
  // Components set the spacing they need; browser defaults would add to it.
  css('h1, h2, h3, p, ul').styles(margin: .zero),
  css('ul').styles(padding: .zero, listStyle: .none),
  css('body').styles(
    margin: .zero,
    color: Palette.white,
    fontFamily: const .list([FontFamily('Afacad'), FontFamilies.sansSerif]),
    fontSize: TextSize.small,
    lineHeight: TextSize.smallLineHeight,
  ),
  css(':focus-visible').styles(
    outline: Outline(color: Palette.white, style: .solid, width: OutlineWidth(2.px), offset: 3.px),
  ),
];

/// `@font-face` for the variable Afacad font, which covers weights 400 to 700.
///
/// Jaspr's `css.fontFace` can't set a weight range or `font-display`.
class _AfacadFontFace implements StyleRule {
  const _AfacadFontFace({required this.url, required this.style});

  final String url;
  final String style;

  @override
  String toCss([String indent = '']) =>
      '$indent@font-face { font-family: "Afacad"; src: url("$url") format("woff2"); '
      'font-weight: 400 700; font-style: $style; font-display: swap; }';
}

# mish

The Cut for Change website, a one-page business card for film editor Mikhail Cherkasov. It implements the design and assets in [docs/specs/01_delivery-package](docs/specs/01_delivery-package/readme.md) with the stack in [docs/blueprints/non_functional.md](docs/blueprints/non_functional.md).

To update the list of sample edits, see [pkgs/website/content/README.md](pkgs/website/content/README.md).

## Packages

1. [pkgs/website](pkgs/website) is the site, built with [Jaspr](https://jaspr.site) in static mode: the page is rendered to HTML at build time, and only the video player runs in the browser.
2. [pkgs/shared](pkgs/shared) is plain Dart: the content model, the parser for `sample_edits.yaml`, and the parser for the HTML tags allowed in titles and descriptions. The unit tests are here.

## Development

You need the Dart SDK 3.13 or later and the Jaspr CLI 0.24 beta. The 0.23 CLI refuses projects on Jaspr 0.24.

```sh
dart pub global activate jaspr_cli 0.24.0-beta.2
```

In `pkgs/website`:

1. `dart pub get` installs dependencies.
2. `jaspr serve` starts a development server at http://localhost:8080. Changes to `content/sample_edits.yaml` show up on reload.
3. `jaspr build` writes the site to `build/jaspr/`.

In `pkgs/shared`, `dart test` runs the tests. `dart analyze` checks either package.

## Deploying

Upload the contents of `pkgs/website/build/jaspr/` to any static host. The page sets `<base href="/">`, so serve it from the root of the domain. The `packages/` and `.dart_tool/` folders in the build output are build leftovers that the page doesn't load.

## How the page works

1. Layout. The design is drawn on a 4000 px wide canvas, and the styles give lengths in canvas pixels with `du()` from [theme.dart](pkgs/website/lib/styles/theme.dart). The CSS variable `--u` converts them: it is `100vw / 4000`, so the page keeps the design's proportions, and it stops growing at a 1600 px window, the width the design was drawn at. Below 720 px the cards stack in one column, and `--u` has a floor that keeps body text at 16 px.
2. Text. The design's font sizes, 110 : 143 : 214, are Blender units. Matching Afacad's cap height in the design gives CSS sizes of 88, 114.4 and 171.2 canvas pixels, and the design's Blender line spacing gives the line heights. At a 1600 px window, text baselines and boxes land within about 1 CSS px of the design.
3. Video player. [SampleEditCard](pkgs/website/lib/components/sample_edit_card.dart) is the one `@client` component. The thumbnail and the "Click to watch" button open a modal `<dialog>` with the Vimeo player. A click outside the player, the close button or Escape closes it and removes the iframe, which stops the video. The title and description are rendered on the server and passed to the card.
4. Content. The page reads `content/sample_edits.yaml` on every render with `loadSampleEdits()` from [content.dart](pkgs/website/lib/content.dart). A mistake in the file stops `jaspr build` with a message that quotes the line.
5. Assets. The images come from the delivery package: `logo.svg` is `title_tagline.svg`, the DaVinci Resolve icon is resized to a 320 px WebP, and the favicons are rendered from `logo_cutforchange_favicon.svg`. The Afacad fonts are converted to WOFF2 and keep their license in `web/fonts/OFL.txt`.

<sub><!-- agent-generated --><kbd>🤖 Agent-generated</kbd></sub>

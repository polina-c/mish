# mish

The Cut for Change website, a one-page business card for film editor Mikhail Cherkasov. It implements the design and assets in [docs/specs/01_delivery-package](docs/specs/01_delivery-package/readme.md) with the stack in [docs/blueprints/non_functional.blueprint.md](docs/blueprints/non_functional.blueprint.md).

To update the list of sample edits, see [pkgs/website/content/README.md](pkgs/website/content/README.md).

## Packages

1. [pkgs/website](pkgs/website) is the site, built with [Jaspr](https://jaspr.site) in static mode: the page is rendered to HTML at build time, and only the video player and the copy button run in the browser.
2. [pkgs/shared](pkgs/shared) is plain Dart: the content model, the parser for `sample_edits.yaml`, and the parser for the HTML tags allowed in titles and descriptions. The unit tests are here.

## Development

You need the Dart SDK 3.13 or later and the Jaspr CLI 0.24 beta. The 0.23 CLI refuses projects on Jaspr 0.24.

```sh
dart pub global activate jaspr_cli 0.24.0-beta.2
```

The repository is a [pub workspace](https://dart.dev/tools/pub/workspaces): the root [pubspec.yaml](pubspec.yaml) lists both packages, and they share one `pubspec.lock` at the root. `dart pub get` in any folder installs dependencies for both.

In `pkgs/website`:

1. `jaspr serve` starts a development server at http://localhost:8080. Changes to `content/sample_edits.yaml` show up on reload.
2. `jaspr build` writes the site to `build/jaspr/`.

In `pkgs/shared`, `dart test` runs the tests. `dart analyze` checks either package.

## Deploying

The site is on Firebase Hosting in the [mish-web](https://console.firebase.google.com/project/mish-web) project, at https://mish-web.web.app. [.firebaserc](.firebaserc) selects the project, and [firebase.json](firebase.json) configures the hosting.

You need the [Firebase CLI](https://firebase.google.com/docs/cli), logged in with `firebase login` to an account that has access to the project.

To deploy, run the "deploy" configuration in VS Code, or `firebase deploy --only hosting` in the repository root. Both run `jaspr build` first, as the predeploy hook in `firebase.json`, so the deploy has whatever is in the working tree, committed or not.

The deploy uploads `pkgs/website/build/jaspr/` without the `packages/` folder and the dot-files, which are build leftovers that the page doesn't load. The page sets `<base href="/">`, so a different host has to serve it from the root of the domain too.

## How the page works

1. Layout. The design is drawn on a 4000 px wide canvas, and the styles give lengths in canvas pixels with `du()` from [theme.dart](pkgs/website/lib/styles/theme.dart). The CSS variable `--u` converts them: it is `100vw / 4000`, so the page keeps the design's proportions, and it stops growing at a 1600 px window, the width the design was drawn at. Below 720 px the cards stack in one column, and `--u` has a floor that keeps body text at 16 px.
2. Text. The design's font sizes, 110 : 143 : 214, are Blender units. Matching Afacad's cap height in the design gives CSS sizes of 88, 114.4 and 171.2 canvas pixels, and the design's Blender line spacing gives the line heights. At a 1600 px window, text baselines and boxes land within about 1 CSS px of the design.
3. Video player. [SampleEditCard](pkgs/website/lib/components/sample_edit_card.dart) is a `@client` component. The thumbnail and the "Click to watch" button open a modal `<dialog>` with the Vimeo player. A click outside the player, the close button or Escape closes it and removes the iframe, which stops the video. The title and description are rendered on the server and passed to the card.
4. Copy button. [CopyButton](pkgs/website/lib/components/copy_button.dart), the other `@client` component, sits after the email address in both "Hire Mikhail" lines. It copies the address with the Clipboard API and says "copied" for 2 seconds. Browsers allow that only on https pages and on localhost.
5. Content. The page reads `content/sample_edits.yaml` on every render with `loadSampleEdits()` from [content.dart](pkgs/website/lib/content.dart). A mistake in the file stops `jaspr build` with a message that quotes the line.
6. Assets. The images come from the delivery package: `logo.svg` is `title_tagline.svg`, the DaVinci Resolve icon is resized to a 320 px WebP, and the favicons are rendered from `logo_cutforchange_favicon.svg`. The Afacad fonts are converted to WOFF2 and keep their license in `web/fonts/OFL.txt`.

<sub><!-- agent-generated --><kbd>🤖 Agent-generated</kbd></sub>

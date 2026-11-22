/// Entry point for the server, which pre-renders the page at build time.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'app.dart';
import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(
    Document(
      title: 'Cut for Change: Mikhail Cherkasov, film editor and story artist',
      lang: 'en',
      meta: const {
        'description':
            'Mikhail Cherkasov is a film editor and story artist. Watch his sample edits and hire him for editing '
            'and story services.',
        'theme-color': '#080808',
      },
      head: [
        link(rel: 'icon', href: 'favicon.ico', attributes: const {'sizes': '32x32'}),
        link(rel: 'icon', href: 'favicon.svg', type: 'image/svg+xml'),
        link(rel: 'apple-touch-icon', href: 'apple-touch-icon.png'),
        link(
          rel: 'preload',
          href: 'fonts/Afacad-Variable.woff2',
          as: 'font',
          type: 'font/woff2',
          attributes: const {'crossorigin': ''},
        ),
      ],
      body: const App(),
    ),
  );
}

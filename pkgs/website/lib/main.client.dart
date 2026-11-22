/// Entry point for the browser. Starts the components marked with `@client`.
library;

import 'package:jaspr/client.dart';

import 'main.client.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultClientOptions);

  runApp(const ClientApp());
}

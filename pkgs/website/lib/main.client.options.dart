// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:website/components/copy_button.dart' deferred as _copy_button;
import 'package:website/components/sample_edit_card.dart'
    deferred as _sample_edit_card;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(
  clients: {
    'copy_button': ClientLoader(
      (p) => _copy_button.CopyButton(
        text: p.get<String>('text'),
        label: p.get<String>('label'),
      ),
      loader: _copy_button.loadLibrary,
    ),
    'sample_edit_card': ClientLoader(
      (p) => _sample_edit_card.SampleEditCard(
        videoTitle: p.get<String>('videoTitle'),
        embedUrl: p.get<String>('embedUrl'),
        thumbnailSrc: p.get<String>('thumbnailSrc'),
        title: p.mount(p.get<String>('title')),
        description: p.mount(p.get<String>('description')),
      ),
      loader: _sample_edit_card.loadLibrary,
    ),
  },
);

// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:website/components/copy_button.dart' as _copy_button;
import 'package:website/components/hire_line.dart' as _hire_line;
import 'package:website/components/person_card.dart' as _person_card;
import 'package:website/components/sample_edit_card.dart' as _sample_edit_card;
import 'package:website/styles/theme.dart' as _theme;
import 'package:website/app.dart' as _app;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {
    _copy_button.CopyButton: ClientTarget<_copy_button.CopyButton>(
      'copy_button',
      params: __copy_buttonCopyButton,
    ),
    _sample_edit_card.SampleEditCard:
        ClientTarget<_sample_edit_card.SampleEditCard>(
          'sample_edit_card',
          params: __sample_edit_cardSampleEditCard,
        ),
  },
  styles: () => [
    ..._theme.globalStyles,
    ..._app.App.styles,
    ..._copy_button.CopyButton.styles,
    ..._hire_line.HireLine.styles,
    ..._person_card.PersonCard.styles,
    ..._sample_edit_card.SampleEditCard.styles,
  ],
);

Map<String, Object?> __copy_buttonCopyButton(_copy_button.CopyButton c) => {
  'text': c.text,
  'label': c.label,
};
Map<String, Object?> __sample_edit_cardSampleEditCard(
  _sample_edit_card.SampleEditCard c,
) => {
  'videoTitle': c.videoTitle,
  'embedUrl': c.embedUrl,
  'thumbnailSrc': c.thumbnailSrc,
  'title': c.title,
  'description': c.description,
};

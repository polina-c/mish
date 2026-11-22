/// Reads the content files. Server only: uses `dart:io`.
library;

import 'dart:io';

import 'package:shared/shared.dart';
import 'package:source_span/source_span.dart';

/// The list of sample edits the site manager keeps up to date.
const sampleEditsFile = 'content/sample_edits.yaml';

/// Where thumbnails live, relative to the site root (the `web/` folder).
const thumbnailsPath = 'images/thumbnails';

/// Reads and checks [sampleEditsFile].
///
/// This runs on every page render, so during `jaspr serve` changes to the
/// file show up on reload. During `jaspr build` a mistake in the file stops
/// the build with a message that points at the problem.
List<SampleEdit> loadSampleEdits() {
  final file = File(sampleEditsFile);
  try {
    return parseSampleEdits(
      file.readAsStringSync(),
      sourceUrl: Uri.file(sampleEditsFile),
      thumbnailExists: (fileName) => File('web/$thumbnailsPath/$fileName').existsSync(),
    );
  } on SourceSpanFormatException catch (e) {
    // A mistake in the content file, not in the code: a stack trace would
    // only bury the message.
    Error.throwWithStackTrace(ContentException(e.toString()), StackTrace.empty);
  }
}

/// A mistake in a content file.
class ContentException implements Exception {
  ContentException(this.message);

  final String message;

  @override
  String toString() => message;
}

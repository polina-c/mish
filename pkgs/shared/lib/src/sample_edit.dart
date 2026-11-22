import 'inline_markup.dart';

/// A video on the website, with a thumbnail and a short pitch.
final class SampleEdit {
  const SampleEdit({required this.video, required this.thumbnail, required this.title, this.description = const []});

  final VimeoVideo video;

  /// File name of the thumbnail image, such as `thumbnail_salieri.jpg`.
  final String thumbnail;

  /// Title lines, shown on the grey bar next to the "Click to watch" button.
  final List<RichLine> title;

  /// Description lines, shown under the title.
  final List<RichLine> description;
}

/// A video hosted on Vimeo.
final class VimeoVideo {
  const VimeoVideo({required this.id, this.privacyHash, required this.title});

  /// The number in the video's address, such as `1110117832`.
  final String id;

  /// The extra code in an unlisted video's address (the `h` parameter).
  ///
  /// Public videos don't have one.
  final String? privacyHash;

  /// The video's name, read out by screen readers.
  final String title;

  /// The address of Vimeo's player for this video, set to start playing
  /// as soon as it opens.
  Uri get embedUrl => Uri.https('player.vimeo.com', '/video/$id', {'h': ?privacyHash, 'autoplay': '1'});
}

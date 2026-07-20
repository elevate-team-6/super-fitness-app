/// Turns the YouTube watch links TheMealDB returns into embeddable ones.
///
/// A plain `watch?v=` URL loaded in a WebView renders the full YouTube page —
/// cookie banners, sign-in prompts and all. The `/embed/` player is what we
/// actually want inside the app.
abstract class YoutubeUrl {
  /// Extracts the 11-character video id from the URL shapes TheMealDB uses:
  /// `youtube.com/watch?v=ID`, `youtu.be/ID` and `youtube.com/embed/ID`.
  /// Returns null when [url] isn't a YouTube link we recognize.
  static String? videoIdOf(String? url) {
    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;

    final host = uri.host.toLowerCase();

    if (host.endsWith('youtu.be')) {
      return _nonEmpty(uri.pathSegments.firstOrNull);
    }

    if (!host.endsWith('youtube.com')) return null;

    final fromQuery = _nonEmpty(uri.queryParameters['v']);
    if (fromQuery != null) return fromQuery;

    // `/embed/ID` and `/v/ID` both put the id in the segment after the marker.
    final segments = uri.pathSegments;
    for (final marker in const ['embed', 'v', 'shorts']) {
      final index = segments.indexOf(marker);
      if (index != -1 && index + 1 < segments.length) {
        return _nonEmpty(segments[index + 1]);
      }
    }

    return null;
  }

  /// A normalized `watch?v=` URL for [url], or null when there's no video —
  /// what the details screen hands to `url_launcher` to open YouTube.
  static String? watchUrlOf(String? url) {
    final id = videoIdOf(url);
    if (id == null) return null;
    return 'https://www.youtube.com/watch?v=$id';
  }

  static String? _nonEmpty(String? value) =>
      (value != null && value.isNotEmpty) ? value : null;
}

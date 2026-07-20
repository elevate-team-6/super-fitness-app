import 'package:flutter_test/flutter_test.dart';
import 'package:super_fitness/core/utils/youtube_url.dart';

void main() {
  group('YoutubeUrl.videoIdOf', () {
    test('reads the id from the watch links TheMealDB returns', () {
      expect(
        YoutubeUrl.videoIdOf('https://www.youtube.com/watch?v=xvPR2Tfw5k0'),
        'xvPR2Tfw5k0',
      );
    });

    test('reads the id from share, embed and shorts links', () {
      expect(YoutubeUrl.videoIdOf('https://youtu.be/xvPR2Tfw5k0'), 'xvPR2Tfw5k0');
      expect(
        YoutubeUrl.videoIdOf('https://www.youtube.com/embed/xvPR2Tfw5k0'),
        'xvPR2Tfw5k0',
      );
      expect(
        YoutubeUrl.videoIdOf('https://www.youtube.com/shorts/xvPR2Tfw5k0'),
        'xvPR2Tfw5k0',
      );
    });

    test('keeps working when the watch link carries extra query params', () {
      expect(
        YoutubeUrl.videoIdOf(
          'https://www.youtube.com/watch?v=xvPR2Tfw5k0&t=42s&list=PL123',
        ),
        'xvPR2Tfw5k0',
      );
    });

    // TheMealDB leaves `strYoutube` blank for a good share of its recipes, so
    // these are the everyday cases rather than edge cases.
    test('returns null when there is no usable video link', () {
      expect(YoutubeUrl.videoIdOf(null), isNull);
      expect(YoutubeUrl.videoIdOf(''), isNull);
      expect(YoutubeUrl.videoIdOf('   '), isNull);
      expect(YoutubeUrl.videoIdOf('https://vimeo.com/12345'), isNull);
    });

    test('returns null for a youtube link with no id in it', () {
      expect(YoutubeUrl.videoIdOf('https://www.youtube.com/watch'), isNull);
      expect(YoutubeUrl.videoIdOf('https://www.youtube.com/embed/'), isNull);
      expect(YoutubeUrl.videoIdOf('https://youtu.be/'), isNull);
    });
  });

  group('YoutubeUrl.watchUrlOf', () {
    test('normalizes any recognized link into a canonical watch url', () {
      expect(
        YoutubeUrl.watchUrlOf('https://youtu.be/xvPR2Tfw5k0'),
        'https://www.youtube.com/watch?v=xvPR2Tfw5k0',
      );
      expect(
        YoutubeUrl.watchUrlOf('https://www.youtube.com/embed/xvPR2Tfw5k0'),
        'https://www.youtube.com/watch?v=xvPR2Tfw5k0',
      );
    });

    test('returns null when there is no video, so callers can hide the player', () {
      expect(YoutubeUrl.watchUrlOf(null), isNull);
      expect(YoutubeUrl.watchUrlOf('not a url at all'), isNull);
    });
  });
}

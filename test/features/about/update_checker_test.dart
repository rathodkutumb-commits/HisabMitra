import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/about/domain/release_info.dart';

void main() {
  group('AppVersion', () {
    test('parses tags with v prefix and build numbers', () {
      expect(AppVersion.tryParse('v1.2.3'), const AppVersion(1, 2, 3, 0));
      expect(AppVersion.tryParse('1.2.3+45'), const AppVersion(1, 2, 3, 45));
      expect(AppVersion.tryParse('release-1.2'), isNull);
    });

    test('compares semantically, then by build', () {
      expect(
        AppVersion.tryParse('1.10.0')! > AppVersion.tryParse('1.9.9')!,
        isTrue,
      );
      expect(
        AppVersion.tryParse('1.2.3+2')! > AppVersion.tryParse('1.2.3+1')!,
        isTrue,
      );
      expect(
        AppVersion.tryParse('1.2.3')! > AppVersion.tryParse('1.2.3')!,
        isFalse,
      );
    });
  });

  group('ReleaseInfo.fromGitHub', () {
    final json = {
      'tag_name': 'v1.1.0+7',
      'name': 'HisabMitra 1.1.0',
      'body': 'Bug fixes',
      'html_url': 'https://github.com/o/r/releases/tag/v1.1.0',
      'published_at': '2026-11-10T10:00:00Z',
      'draft': false,
      'prerelease': false,
      'assets': [
        {
          'name': 'hisabmitra-1.1.0.apk',
          'browser_download_url': 'https://example/apk',
          'size': 25000000,
        },
        {
          'name': 'hisabmitra-1.1.0.apk.sha256',
          'browser_download_url': 'https://example/sha',
          'size': 90,
        },
      ],
    };

    test('finds the APK and checksum assets', () {
      final r = ReleaseInfo.fromGitHub(json)!;
      expect(r.version, const AppVersion(1, 1, 0, 7));
      expect(r.apkUrl, 'https://example/apk');
      expect(r.checksumUrl, 'https://example/sha');
      expect(r.notes, 'Bug fixes');
    });

    test('ignores drafts, pre-releases and releases without an APK', () {
      expect(ReleaseInfo.fromGitHub({...json, 'prerelease': true}), isNull);
      expect(ReleaseInfo.fromGitHub({...json, 'assets': <Object>[]}), isNull);
    });

    // Releases from 1.2.1 also carry a fixed-name copy (hisabmitra.apk, for
    // the website's download link). Whichever APK comes first, the app must
    // pair it with its own checksum — installed apps rely on this.
    test('a fixed-name copy keeps each APK with its own checksum', () {
      Map<String, Object?> asset(String name) => {
        'name': name,
        'browser_download_url': 'https://example/$name',
        'size': 25000000,
      };
      for (final first in [
        ['hisabmitra.apk', 'hisabmitra.apk.sha256'],
        ['hisabmitra-1.1.0.apk', 'hisabmitra-1.1.0.apk.sha256'],
      ]) {
        final rest = first[0] == 'hisabmitra.apk'
            ? ['hisabmitra-1.1.0.apk', 'hisabmitra-1.1.0.apk.sha256']
            : ['hisabmitra.apk', 'hisabmitra.apk.sha256'];
        final r = ReleaseInfo.fromGitHub({
          ...json,
          'assets': [
            for (final n in [...first, ...rest]) asset(n),
          ],
        })!;
        expect(r.checksumUrl, 'https://example/${r.apkName}.sha256');
      }
    });
  });

  group('checksum file', () {
    const hash =
        'a3f5c0e9d1b2a4c6e8f0a1b3c5d7e9f1a2b4c6d8e0f2a4b6c8d0e2f4a6b8c0d2';

    test('reads sha256sum output', () {
      expect(
        parseSha256('$hash  hisabmitra-1.1.0.apk\n', 'hisabmitra-1.1.0.apk'),
        hash,
      );
      expect(
        parseSha256('$hash *hisabmitra-1.1.0.apk', 'hisabmitra-1.1.0.apk'),
        hash,
      );
    });

    test('reads a bare hash and normalises case', () {
      expect(parseSha256(hash.toUpperCase(), 'x.apk'), hash);
    });

    test('rejects malformed content', () {
      expect(parseSha256('not a hash', 'x.apk'), isNull);
      expect(parseSha256('$hash  other.apk', 'x.apk'), isNull);
    });
  });
}

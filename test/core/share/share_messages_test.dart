import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/share/share_messages.dart';
import 'package:hisabmitra/l10n/app_localizations.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final gu = lookupAppLocalizations(const Locale('gu'));
  const url = 'https://example.com/releases/latest';

  group('group invite', () {
    test('English layout with spacing, emojis and bold', () {
      final m = inviteMessage(
        en,
        group: 'Goa Trip',
        code: 'HSQPP7G9VD',
        date: '22 Nov 2026',
        downloadUrl: url,
      );
      expect(m, startsWith('👋 *Join my group on HisabMitra!*'));
      expect(m, contains('👥 Group: *Goa Trip*'));
      expect(m, contains('🔑 Invite code: *HSQPP7G9VD*'));
      expect(m, contains('⏳ The code is valid till *22 Nov 2026*.'));
      expect(m, isNot(contains('hisabmitra://')));
      expect(m.split('\n\n'), hasLength(5));
      expect(m, endsWith("📲 Don't have the app? Download it free: $url"));
    });

    test('Gujarati layout', () {
      final m = inviteMessage(
        gu,
        group: 'રોજબરોજ ના ખર્ચા',
        code: 'HSQPP7G9VD',
        date: '22 નવે 2026',
        downloadUrl: url,
      );
      expect(m, startsWith('👋 *હિસાબમિત્રમાં મારા ગ્રુપમાં જોડાઓ!*'));
      expect(m, contains('👥 ગ્રુપ: *રોજબરોજ ના ખર્ચા*'));
      expect(m, contains('🔑 આમંત્રણ કોડ: *HSQPP7G9VD*'));
      expect(m, contains('⏳ કોડ *22 નવે 2026* સુધી માન્ય છે.'));
      expect(m, endsWith('📲 એપ નથી? મફત ડાઉનલોડ કરો: $url'));
    });

    test('no download line when the build has no repository', () {
      final m = inviteMessage(
        en,
        group: 'Goa Trip',
        code: 'HSQPP7G9VD',
        date: '22 Nov 2026',
        downloadUrl: null,
      );
      expect(m, isNot(contains('📲')));
      expect(m.split('\n\n'), hasLength(4));
      expect(appDownloadUrl(), isNull, reason: 'tests run without a repo');
    });
  });

  group('share the app', () {
    test('English layout', () {
      final m = appShareMessage(en, downloadUrl: url);
      expect(m, startsWith('📒 *HisabMitra — Smart Hisab, Happy Family*'));
      expect(m, contains('✅ Daily income and expenses'));
      expect(m, contains('📊 Reports in English and ગુજરાતી'));
      expect(m, endsWith('📲 Download free: $url'));
    });

    test('no download line without a repository', () {
      final m = appShareMessage(en, downloadUrl: null);
      expect(m, isNot(contains('📲')));
    });
  });

  test('file captions', () {
    expect(
      en.shareReportCaption('Reports', '01/11/2026 – 30/11/2026'),
      '📊 *HisabMitra report* · Reports · 01/11/2026 – 30/11/2026',
    );
    expect(en.shareBackupCaption('20/11/2026'), contains('backup password'));
    expect(
      en.shareBackupCaptionPlain('20/11/2026'),
      isNot(contains('password')),
    );
  });
}

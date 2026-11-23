import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/synchronization/presentation/sync_screen.dart';
import 'package:hisabmitra/l10n/app_localizations.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final gu = lookupAppLocalizations(const Locale('gu'));

  test('Family hisab conflicts say what they are about', () {
    String label(AppLocalizations l, String type) =>
        conflictEntityLabel(l, scope: 'family', entityType: type);
    expect(
      [label(en, 'family'), label(en, 'member'), label(en, 'entry')],
      ['Family hisab details', 'Person in Family hisab', 'Family hisab entry'],
    );
    expect(label(gu, 'entry'), 'પરિવારના હિસાબની એન્ટ્રી');
    expect(
      conflictEntityLabel(en, scope: 'group', entityType: 'member'),
      en.entityMember,
    );
    expect(
      conflictEntityLabel(en, scope: 'personal', entityType: 'person'),
      en.entityPerson,
    );
  });

  test('a Family hisab entry shows its amount and date', () {
    final s = conflictSummary(en, {
      'amount_paise': 6200000,
      'entry_date': '2026-11-01',
    });
    expect(s, contains('62,000'));
    expect(s, contains('2026-11-01'));
  });
}

// Captures screenshots of key screens on a device or emulator, with sample
// data in an in-memory database (the device's real data is not touched):
//
//   flutter drive -d emulator-5554 \
//     --driver=screenshots/driver.dart \
//     --target=screenshots/app_screenshots_test.dart
//
// PNGs are written to build/screenshots/.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabmitra/app/router/routes.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/gujarati_input/presentation/gujarati_keypad.dart';
import 'package:hisabmitra/features/gujarati_input/presentation/gujarati_text_field.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/features/transactions/data/transaction_repository.dart';
import 'package:hisabmitra/features/transactions/domain/transaction_models.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/app_harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    await binding.takeScreenshot(name);
  }

  Future<void> seed(AppDatabase db) async {
    final repo = TransactionRepository(db, const Clock(), const IdGenerator());
    final now = DateTime.now();
    final entries = [
      (TransactionType.income, 4500000, 'cat_salary', 1, 'પગાર'),
      (TransactionType.expense, 125050, 'cat_groceries', 3, 'કરિયાણું'),
      (TransactionType.expense, 1500000, 'cat_rent', 5, 'Rent'),
      (TransactionType.expense, 89900, 'cat_mobile', 8, 'Mobile recharge'),
      (TransactionType.expense, 240000, 'cat_festivals', 10, 'દિવાળી મીઠાઈ'),
    ];
    for (final (type, paise, category, day, text) in entries) {
      await repo.save(
        TransactionDraft(
          type: type,
          amountPaise: paise,
          categoryId: category,
          date: DateTime(now.year, now.month, day.clamp(1, now.day)),
          paymentMethod: PaymentMethod.upi,
          description: text,
        ),
      );
    }
  }

  testWidgets('screenshots', (tester) async {
    await binding.convertFlutterSurfaceToImage();
    final db = await pumpHisabMitra(
      tester,
      prefs: AppPreferences.fromMap(const {}).copyWith(
        onboardingComplete: true,
        languageCode: 'gu',
        gujaratiInputMode: GujaratiInputMode.keypad,
      ),
    );
    // The harness fixes a phone size for host tests; use the real screen.
    tester.view.reset();
    await seed(db);
    await shot(tester, '01_dashboard_rann_utsav_gu');

    GoRouter router() =>
        GoRouter.of(tester.element(find.byType(Scaffold).first));

    // Transactions tab, switched to the Excel-like sheet.
    router().go(Routes.transactions);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.table_chart_rounded));
    await shot(tester, '02_transactions_sheet');

    // New expense; focus the description to open the Gujarati keypad.
    unawaited(router().push(Routes.newTransaction()));
    await tester.pumpAndSettle();
    final description = find.descendant(
      of: find.byType(GujaratiTextField).first,
      matching: find.byType(TextFormField),
    );
    await tester.ensureVisible(description);
    await tester.tap(description);
    await tester.pumpAndSettle();
    await shot(tester, '03_keypad_vowels');
    await tester.tap(
      find.descendant(
        of: find.byType(GujaratiKeypad),
        matching: find.text('પ'),
      ),
    );
    await shot(tester, '04_keypad_barakhadi');
  });
}

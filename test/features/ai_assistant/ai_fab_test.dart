import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabmitra/app/router/routes.dart';
import 'package:hisabmitra/features/gujarati_input/presentation/gujarati_keypad.dart';
import 'package:hisabmitra/features/gujarati_input/presentation/gujarati_text_field.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/features/transactions/presentation/transaction_form_screen.dart';

import '../../helpers/app_harness.dart';

final _aiButton = find.byTooltip('Ask HisabMitra AI');

AppPreferences _prefs({bool ai = true}) =>
    AppPreferences.fromMap(const {})
        .copyWith(onboardingComplete: true, aiEnabled: ai);

void main() {
  testApp('shows on Home and opens the assistant chat', (tester) async {
    await pumpHisabMitra(tester, prefs: _prefs());
    expect(_aiButton, findsOneWidget);

    await tester.tap(_aiButton);
    await tester.pumpAndSettle();
    expect(find.textContaining('I can answer questions'), findsOneWidget);
    expect(_aiButton, findsNothing, reason: 'not on the chat itself');
  });

  testApp('sits above the page\'s own button without overlap', (tester) async {
    await pumpHisabMitra(tester, prefs: _prefs());
    await tester.tap(find.text('Groups').last);
    await tester.pumpAndSettle();

    final create = find.widgetWithText(FloatingActionButton, 'Create group');
    expect(_aiButton, findsOneWidget);
    expect(create, findsOneWidget);
    expect(
      tester.getRect(_aiButton).bottom,
      lessThanOrEqualTo(tester.getRect(create).top),
    );
  });

  testApp('hidden on the add-expense form', (tester) async {
    await pumpHisabMitra(tester, prefs: _prefs());
    await tester.tap(find.text('Add expense').first);
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsOneWidget);
    expect(_aiButton, findsNothing);
  });

  testApp('hidden when the assistant is turned off', (tester) async {
    await pumpHisabMitra(tester, prefs: _prefs(ai: false));
    expect(_aiButton, findsNothing);
  });

  testApp('hidden while the keyboard is open', (tester) async {
    await pumpHisabMitra(tester, prefs: _prefs());
    tester.view.viewInsets = const FakeViewPadding(bottom: 900);
    await tester.pumpAndSettle();
    expect(_aiButton, findsNothing);
  });

  testApp('hidden while the Gujarati keypad is open', (tester) async {
    await pumpHisabMitra(tester, prefs: _prefs());
    addTearDown(() => GujaratiTextField.openKeypads.value = 0);
    GujaratiTextField.openKeypads.value = 1;
    await tester.pumpAndSettle();
    expect(_aiButton, findsNothing);
  });

  testApp('comes back after leaving a form with the keypad still open', (
    tester,
  ) async {
    await pumpHisabMitra(
      tester,
      prefs: _prefs().copyWith(gujaratiInputMode: GujaratiInputMode.keypad),
    );
    addTearDown(() => GujaratiTextField.openKeypads.value = 0);
    await tester.tap(find.text('Add expense').first);
    await tester.pumpAndSettle();
    final description = find.widgetWithText(TextFormField, 'Description');
    await tester.ensureVisible(description);
    await tester.tap(description);
    await tester.pumpAndSettle();
    expect(find.byType(GujaratiKeypad), findsOneWidget);
    expect(GujaratiTextField.openKeypads.value, 1);

    // Replace the whole page stack while the keypad is open.
    GoRouter.of(tester.element(find.byType(TransactionFormScreen)))
        .go(Routes.home);
    await tester.pumpAndSettle();

    expect(GujaratiTextField.openKeypads.value, 0);
    expect(_aiButton, findsOneWidget);
  });
}

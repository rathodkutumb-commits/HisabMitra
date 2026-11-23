import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/app/theme/palettes.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/core/widgets/common_widgets.dart';
import 'package:hisabmitra/features/tour/presentation/tour_overlay.dart';
import 'package:hisabmitra/features/transactions/data/transaction_repository.dart';
import 'package:hisabmitra/features/transactions/domain/transaction_models.dart';
import 'package:hisabmitra/features/gujarati_input/presentation/gujarati_keypad.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/features/synchronization/application/sync_controller.dart';
import 'package:hisabmitra/features/synchronization/data/sync_service.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_auth_gateway.dart';

void main() {
  testApp('onboarding: Gujarati language, intro, profile → dashboard', (
    tester,
  ) async {
    await pumpHisabMitra(
      tester,
      prefs: AppPreferences.fromMap(const {}),
      profileName: null,
    );

    expect(find.text('Choose your language'), findsOneWidget);
    await tester.tap(find.text('ગુજરાતી (Gujarati)'));
    await tester.pumpAndSettle();
    expect(
      find.text('તમારી ભાષા પસંદ કરો'),
      findsOneWidget,
      reason: 'language switches live',
    );

    await tester.tap(find.text('આગળ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('છોડો'));
    await tester.pumpAndSettle();

    // Name, email and mobile number are compulsory.
    await tester.enterText(find.byType(TextFormField).at(0), 'Hemang');
    await tester.tap(find.text('હિસાબમિત્ર વાપરવાનું શરૂ કરો'));
    await tester.pumpAndSettle();
    expect(find.text('સાચું ઇમેઇલ સરનામું લખો'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'hemang@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), '98765 43210');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('નમસ્તે, Hemang'), findsOneWidget);
    expect(find.text('આ સમયગાળાની બચત'), findsOneWidget);
  });

  testApp('add an expense from the dashboard updates the totals', (
    tester,
  ) async {
    final db = await pumpHisabMitra(tester);
    expect(find.text('Namaste, Hemang'), findsOneWidget);

    await tester.tap(find.text('Add expense').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '1250.50');
    await tester.tap(find.text('Groceries'));
    await tester.pump();
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final rows = await db.select(db.transactions).get();
    expect(rows.single.amountPaise, 125050);
    expect(rows.single.categoryId, 'cat_groceries');
    expect(find.text('-₹1,250.50'), findsOneWidget, reason: 'savings hero');
    expect(find.text('₹1,250.50'), findsWidgets);
  });

  testApp('saving without a category shows a validation message', (
    tester,
  ) async {
    final db = await pumpHisabMitra(tester);
    await tester.tap(find.text('Add expense').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '10');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a category'), findsOneWidget);
    expect(await db.select(db.transactions).get(), isEmpty);
  });

  testApp('create a group, split an expense equally, see balances', (
    tester,
  ) async {
    final db = await pumpHisabMitra(tester);
    await tester.tap(find.text('Groups').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create group').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Goa Trip');
    await tester.enterText(
      find.widgetWithText(TextField, 'Member name'),
      'Bhavna',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Goa Trip'), findsWidgets);

    // The FAB moves above the "Group saved" snackbar; the empty-state button
    // can be covered by it on shorter screens.
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Add expense'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Hotel');
    await tester.enterText(find.byType(TextFormField).at(1), '1000');
    await tester.pumpAndSettle();
    final preview = find.textContaining('₹1,000.00 = ₹1,000.00');
    await tester.scrollUntilVisible(
      preview,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(preview, findsOneWidget, reason: 'split preview reconciles');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final splits = await db.select(db.groupExpenseSplitsCache).get();
    expect(splits.map((s) => s.sharePaise).toSet(), {50000});

    await tester.tap(find.text('Balances'));
    await tester.pumpAndSettle();
    expect(find.text('Suggested settlements'), findsOneWidget);
    expect(find.text('Settle up'), findsOneWidget);
  });

  testApp('settings screen lists every section in Gujarati', (tester) async {
    await pumpHisabMitra(
      tester,
      prefs: AppPreferences.fromMap(const {})
          .copyWith(onboardingComplete: true, languageCode: 'gu'),
    );
    await tester.tap(find.text('વધુ'));
    await tester.pumpAndSettle();
    // The Settings item, not the section header above it.
    final settings = find.widgetWithIcon(ListTile, Icons.settings_rounded);
    await tester.scrollUntilVisible(
      settings,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(settings);
    await tester.pumpAndSettle();
    for (final title in [
      'દેખાવ',
      'નાણાં',
      'ગ્રુપ',
      'સૂચનાઓ',
      'બેકઅપ અને રિસ્ટોર',
      'AI સહાયક',
      'એકાઉન્ટ',
    ]) {
      final header = find.descendant(
        of: find.byType(SectionHeader),
        matching: find.text(title),
      );
      await tester.scrollUntilVisible(header, 200);
      expect(header, findsOneWidget, reason: title);
    }
  });

  testApp('the chosen palette colours the app and stays light', (tester) async {
    await pumpHisabMitra(
      tester,
      prefs: AppPreferences.fromMap(const {})
          .copyWith(onboardingComplete: true, palette: AppPalette.patolaRani),
    );
    final context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.light);
    expect(
      Theme.of(context).scaffoldBackgroundColor,
      AppPalette.patolaRani.spec.background,
    );
    expect(
      Theme.of(context).colorScheme.primary,
      AppPalette.patolaRani.spec.primary,
    );
  });

  testApp('transactions switch to an Excel-like sheet with running balance', (
    tester,
  ) async {
    final db = await pumpHisabMitra(tester);
    final repo = TransactionRepository(db, const Clock(), const IdGenerator());
    final today = DateTime.now();
    await repo.save(
      TransactionDraft(
        type: TransactionType.income,
        amountPaise: 4500000,
        categoryId: 'cat_salary',
        date: DateTime(today.year, today.month, 1),
        paymentMethod: PaymentMethod.bankTransfer,
        description: 'Pay',
      ),
    );
    await repo.save(
      TransactionDraft(
        type: TransactionType.expense,
        amountPaise: 125050,
        categoryId: 'cat_groceries',
        date: DateTime(today.year, today.month, 1),
        paymentMethod: PaymentMethod.upi,
        description: 'Kirana',
      ),
    );

    await tester.tap(find.text('Hisab').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Show as sheet'));
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Running balance'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    // Running balance after "Kirana" and the totals-row net are the same.
    expect(
      find.descendant(
        of: find.byType(DataTable),
        matching: find.text('₹43,749.50'),
      ),
      findsNWidgets(2),
    );

    await tester.tap(find.text('Kirana'));
    await tester.pumpAndSettle();
    expect(find.text('₹1,250.50'), findsWidgets, reason: 'detail screen');
    await tester.pageBack();
    await tester.pumpAndSettle();

    // The choice is remembered; switch back to the list.
    expect(find.byType(DataTable), findsOneWidget);
    await tester.tap(find.byTooltip('Show as list'));
    await tester.pumpAndSettle();
    expect(find.byType(DataTable), findsNothing);
  });

  testApp('the Gujarati keypad types પુણ્ય into an expense description', (
    tester,
  ) async {
    final db = await pumpHisabMitra(
      tester,
      prefs: AppPreferences.fromMap(const {}).copyWith(
        onboardingComplete: true,
        gujaratiInputMode: GujaratiInputMode.keypad,
      ),
    );
    await tester.tap(find.text('Add expense').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '101');
    await tester.tap(find.text('Groceries'));
    await tester.pump();

    final description = find.widgetWithText(TextFormField, 'Description');
    await tester.ensureVisible(description);
    await tester.tap(description);
    await tester.pumpAndSettle();
    expect(find.byType(GujaratiKeypad), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    // The field must stay visible above the keypad while typing.
    expect(
      tester.getRect(description).bottom,
      lessThanOrEqualTo(tester.getRect(find.byType(GujaratiKeypad)).top),
    );

    Finder key(String label) => find.descendant(
      of: find.byType(GujaratiKeypad),
      matching: find.text(label),
    );
    for (final label in ['પ', 'પુ', 'ણ', 'ણ્', 'ય']) {
      await tester.tap(key(label));
      await tester.pump();
    }
    await tester.tap(find.byKey(GujaratiKeypad.closeKey));
    await tester.pumpAndSettle();
    expect(find.byType(GujaratiKeypad), findsNothing);

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final rows = await db.select(db.transactions).get();
    expect(rows.single.description, 'પુણ્ય');
    expect(rows.single.amountPaise, 10100);
  });

  testApp('sign-up: name, email and phone, verified by the emailed code', (
    tester,
  ) async {
    final cloud = FakeAuthGateway();
    final db = await pumpHisabMitra(
      tester,
      prefs: AppPreferences.fromMap(const {}),
      profileName: null,
      overrides: [
        cloudGatewayProvider.overrideWithValue(cloud),
        // Sync after sign-up is covered by the sync tests; here its outbox
        // watcher would keep the database open under the fake clock.
        syncControllerProvider.overrideWith(_NoSyncController.new),
      ],
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Hemang');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Hemang@Example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), '98765 43210');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    // The verify screen runs a resend countdown, so pump in steps instead
    // of waiting for it to settle.
    await pumpFor(tester, const Duration(seconds: 1));
    expect(cloud.codeRequests.single.$1, 'hemang@example.com');

    expect(find.text('Verify your email'), findsOneWidget);
    expect(find.textContaining('hemang@example.com'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '00000000');
    await tester.tap(find.text('Verify'));
    await pumpFor(tester, const Duration(seconds: 1));
    expect(
      find.text('That code is not correct. Please check and try again.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), cloud.validCode);
    await tester.tap(find.text('Verify'));
    await pumpFor(tester, const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Namaste, Hemang'), findsOneWidget, reason: 'dashboard');
    final profile = await db.select(db.localUserProfile).getSingle();
    expect(profile.email, 'hemang@example.com');
    expect(profile.phone, '+919876543210');
    expect(profile.remoteUserId, 'user-1');
    expect(cloud.profileUpserts.single['phone'], '+919876543210');
  });

  testApp('an install without a verified email is asked to verify first', (
    tester,
  ) async {
    await pumpHisabMitra(
      tester,
      overrides: [cloudGatewayProvider.overrideWithValue(FakeAuthGateway())],
    );
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Hemang'), findsOneWidget, reason: 'name kept');
    expect(find.text('Namaste, Hemang'), findsNothing);
  });

  testApp('first-run tour with sample data, then remove the sample data', (
    tester,
  ) async {
    final db = await pumpHisabMitra(
      tester,
      prefs: AppPreferences.fromMap(const {})
          .copyWith(onboardingComplete: true, tourPending: true),
    );
    expect(find.text('Take a quick tour?'), findsOneWidget);
    await tester.tap(find.text('Start tour'));
    await pumpFor(tester, const Duration(milliseconds: 1500));

    final titles = [
      'Your month at a glance',
      'Money to receive and to pay',
      'Quick actions',
      'Your hisab, also as a sheet',
      'Khata: people and loans',
      'Groups: split and settle',
      'More tools',
    ];
    for (final (i, title) in titles.indexed) {
      Finder inTour(String text) => find.descendant(
        of: find.byType(TourOverlay),
        matching: find.text(text),
      );
      expect(inTour(title), findsOneWidget, reason: 'step ${i + 1}');
      expect(inTour('${i + 1} of 7'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await pumpFor(tester, const Duration(milliseconds: 1500));
    }
    expect(find.text('You are all set!'), findsOneWidget);
    expect((await db.select(db.transactions).get()).length, 14);

    await tester.tap(find.text('Remove sample data'));
    await pumpFor(tester, const Duration(milliseconds: 1500));
    expect(find.text('You are all set!'), findsNothing);
    expect(await db.select(db.transactions).get(), isEmpty);
    expect(await db.select(db.persons).get(), isEmpty);
    expect(find.text('You are looking at sample data.'), findsNothing);
  });

  testApp('keep the sample data, remove it later from the banner', (
    tester,
  ) async {
    final db = await pumpHisabMitra(
      tester,
      prefs: AppPreferences.fromMap(const {})
          .copyWith(onboardingComplete: true, tourPending: true),
    );
    await tester.tap(find.text('Start tour'));
    await pumpFor(tester, const Duration(milliseconds: 1500));
    await tester.tap(find.text('Skip tour'));
    await pumpFor(tester, const Duration(milliseconds: 1500));
    await tester.tap(find.text('Keep for now'));
    await pumpFor(tester, const Duration(milliseconds: 1500));
    expect(find.text('Namaste, Hemang'), findsOneWidget);
    expect((await db.select(db.groupsCache).get()).single.name, 'Goa Trip');

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove').last);
    await tester.pumpAndSettle();
    expect(await db.select(db.groupsCache).get(), isEmpty);
    expect(find.text('You are looking at sample data.'), findsNothing);
  });

  testApp('opening a page after visiting several tabs has no hero clash', (
    tester,
  ) async {
    // Found on the emulator: tabs with floating buttons stay alive in the
    // shell, and identical default hero tags broke page transitions.
    await pumpHisabMitra(tester);
    for (final tab in ['Hisab', 'Khata', 'Groups']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Create group'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Create group'), findsWidgets);

    // The AI buttons on those tabs must not clash either.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ask HisabMitra AI'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

class _NoSyncController extends SyncController {
  @override
  SyncStatus build() => const SyncStatus();

  @override
  Future<SyncReport?> syncNow({bool silent = false}) async => null;
}

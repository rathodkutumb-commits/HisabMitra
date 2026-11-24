import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/app/app.dart';
import 'package:hisabmitra/app/router/routes.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/core/widgets/form_fields.dart';
import 'package:hisabmitra/features/family/data/family_repository.dart';
import 'package:hisabmitra/features/family/presentation/family_home_screen.dart';
import 'package:hisabmitra/features/reminders/application/notification_service.dart';
import 'package:hisabmitra/features/reminders/data/reminder_repository.dart';
import 'package:hisabmitra/features/reminders/domain/reminder_schedule.dart';

import '../helpers/app_harness.dart';

/// The phone's notification system is not there in widget tests.
class _QuietNotifications extends NotificationService {
  _QuietNotifications(super.ref);

  @override
  Future<bool> initialize() async => false;
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> schedule(ReminderRow r) async {}
  @override
  Future<void> cancel(int notificationId) async {}
}

class _NoScheduler implements ReminderScheduler {
  @override
  Future<void> schedule(ReminderRow reminder) async {}
  @override
  Future<void> cancel(int notificationId) async {}
}

void main() {
  late AppDatabase db;
  late String home;

  Future<void> open(WidgetTester tester) async {
    db = await pumpHisabMitra(
      tester,
      overrides: [
        notificationServiceProvider.overrideWith(_QuietNotifications.new),
      ],
    );
    home = await FamilyRepository(
      db,
      const Clock(),
      const IdGenerator(),
    ).createFamily(const FamilyDraft(name: 'Home'), selfName: 'Hemang');
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  Finder button(String label) => find.ancestor(
    of: find.text(label),
    matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
  );

  Future<void> openReminders(WidgetTester tester) async {
    await tap(tester, find.text('More').last);
    await tap(tester, find.text('Reminders'));
  }

  testApp('a reminder added from the Family hisab is linked to it', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, find.text('More').last);
    await tap(tester, find.byKey(const Key('more-family')));
    await tap(
      tester,
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(PopupMenuButton<String>),
      ),
    );
    await tap(tester, find.text('Add reminder'));
    expect(find.widgetWithText(TextFormField, 'Rent'), findsOneWidget);
    final amount = find.descendant(
      of: find.byType(MoneyFormField),
      matching: find.byType(EditableText),
    );
    await tester.ensureVisible(amount);
    await tester.pumpAndSettle();
    await tester.tap(amount);
    await tester.pumpAndSettle();
    await tester.enterText(amount, '15000');
    await tester.pumpAndSettle();
    expect(find.text('15000'), findsOneWidget);
    await tap(tester, button('Save'));
    expect(find.byType(FamilyHomeScreen), findsOneWidget);

    final r = await db.select(db.reminders).getSingle();
    expect((r.title, r.familyId, r.amountPaise), ('Rent', home, 1500000));
    await tap(tester, find.byType(BackButton));
    await tap(tester, find.text('Reminders'));
    expect(find.textContaining('Home'), findsOneWidget);
  });

  testApp('recording its payment adds money out to the Family hisab', (
    tester,
  ) async {
    await open(tester);
    final now = DateTime.now();
    await ReminderRepository(
      db,
      const Clock(),
      const IdGenerator(),
      _NoScheduler(),
    ).save(
      ReminderDraft(
        kind: ReminderKind.rent,
        title: 'Rent',
        dueAt: DateTime(now.year, now.month, now.day, now.hour + 1),
        repeat: ReminderRepeat.monthly,
        amountPaise: 1500000,
        categoryId: 'cat_rent',
        familyId: home,
      ),
    );
    await tester.pumpAndSettle();
    await openReminders(tester);
    await tap(
      tester,
      find.descendant(
        of: find.widgetWithText(ListTile, 'Rent'),
        matching: find.byType(PopupMenuButton<String>),
      ),
    );
    await tap(tester, find.text('Mark paid'));
    await tap(tester, find.text('Add as expense'));

    expect(
      tester
          .widget<MoneyFormField>(find.byKey(const Key('family-amount')))
          .controller
          .text,
      '15000',
    );
    await tap(tester, button('Save'));

    final entry = await db.select(db.familyEntriesCache).getSingle();
    expect(
      (entry.kind, entry.amountPaise, entry.categoryId),
      ('expense', 1500000, 'cat_rent'),
    );
    expect(await db.select(db.transactions).get(), isEmpty);
    final r = await db.select(db.reminders).getSingle();
    expect(r.completedOccurrences, 1);
  });

  testApp('tapping a reminder notification opens its Family hisab', (
    tester,
  ) async {
    await open(tester);
    final c = ProviderScope.containerOf(
      tester.element(find.byType(HisabMitraApp)),
    );
    c.read(notificationRouteProvider.notifier).open(Routes.familyHome(home));
    await tester.pumpAndSettle();
    expect(find.byType(FamilyHomeScreen), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Home')),
      findsOneWidget,
    );

    await tap(tester, find.byType(BackButton));
    c.read(notificationRouteProvider.notifier).open(Routes.familyHome('gone'));
    await tester.pumpAndSettle();
    expect(find.text('This record no longer exists.'), findsOneWidget);
  });
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/app/app.dart';
import 'package:hisabmitra/app/router/app_router.dart';
import 'package:hisabmitra/app/router/routes.dart';
import 'package:hisabmitra/features/settings/application/settings_controller.dart';

import '../helpers/app_harness.dart';

void main() {
  Finder field(String label) =>
      find.ancestor(of: find.text(label), matching: find.byType(TextField));

  Future<void> tapSave(WidgetTester tester) async {
    final save = find.widgetWithText(FilledButton, 'Save');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
  }

  testApp('new category asks for both names', (tester) async {
    final db = await pumpHisabMitra(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HisabMitraApp)),
    );
    unawaited(
      container.read(routerProvider).push(Routes.newCategory('expense')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(field('Name (English)'), 'Pooja');
    await tapSave(tester);
    expect(find.text('This field is required'), findsOneWidget);
    expect(
      await (db.select(
        db.categories,
      )..where((c) => c.name.equals('Pooja'))).get(),
      isEmpty,
    );

    await tester.enterText(field('Name (Gujarati)'), 'પૂજા');
    await tapSave(tester);
    final saved = await (db.select(
      db.categories,
    )..where((c) => c.name.equals('Pooja'))).getSingle();
    expect(saved.nameGu, 'પૂજા');

    await container
        .read(settingsControllerProvider.notifier)
        .update((p) => p.copyWith(languageCode: 'gu'));
    container.read(routerProvider).go(Routes.categories);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('પૂજા'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('પૂજા'), findsOneWidget);
  });

  testApp('changing only the colour keeps a built-in category translated', (
    tester,
  ) async {
    final db = await pumpHisabMitra(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HisabMitraApp)),
    );
    unawaited(
      container.read(routerProvider).push(Routes.editCategory('cat_groceries')),
    );
    await tester.pumpAndSettle();

    final colours = find.descendant(
      of: find.byType(Wrap).last,
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(colours.at(3));
    await tester.tap(colours.at(3));
    await tester.pumpAndSettle();
    await tapSave(tester);

    final groceries = await (db.select(
      db.categories,
    )..where((c) => c.id.equals('cat_groceries'))).getSingle();
    expect(groceries.systemKey, 'groceries');
    expect(groceries.nameGu, isNull);
  });
}

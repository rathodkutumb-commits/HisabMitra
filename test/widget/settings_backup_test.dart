import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabmitra/app/router/routes.dart';
import 'package:hisabmitra/features/dashboard/presentation/dashboard_screen.dart';

import '../helpers/app_harness.dart';

void main() {
  testApp('Settings has no automatic backup option any more', (tester) async {
    await pumpHisabMitra(tester);
    unawaited(
      GoRouter.of(tester.element(find.byType(DashboardScreen)))
          .push(Routes.settings),
    );
    await tester.pumpAndSettle();
    final backup = find.widgetWithText(ListTile, 'Backup & restore');
    await tester.scrollUntilVisible(
      backup,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(backup, findsWidgets);
    expect(find.text('Automatic backup'), findsNothing);
  });
}

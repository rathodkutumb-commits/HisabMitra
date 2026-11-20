import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/dashboard/presentation/dashboard_screen.dart';
import 'package:hisabmitra/features/groups/presentation/groups_screen.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';

import '../helpers/app_harness.dart';

/// Records `SystemNavigator.pop` (the app closing) instead of running it.
List<String> _recordSystemCalls(WidgetTester tester) {
  final calls = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      calls.add(call.method);
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return calls;
}

Future<void> _back(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

const _exitTitle = 'Exit HisabMitra?';

void main() {
  testApp('back on Home asks; Stay keeps the app open', (tester) async {
    await pumpHisabMitra(tester);
    final calls = _recordSystemCalls(tester);

    await _back(tester);
    expect(find.text(_exitTitle), findsOneWidget);

    await tester.tap(find.text('Stay'));
    await tester.pumpAndSettle();
    expect(find.text(_exitTitle), findsNothing);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(calls, isNot(contains('SystemNavigator.pop')));
  });

  testApp('Exit closes the app', (tester) async {
    await pumpHisabMitra(tester);
    final calls = _recordSystemCalls(tester);

    await _back(tester);
    await tester.tap(find.text('Exit'));
    await tester.pumpAndSettle();
    expect(calls, contains('SystemNavigator.pop'));
  });

  testApp('back on another tab goes to Home without asking', (tester) async {
    await pumpHisabMitra(tester);
    await tester.tap(find.text('Groups').last);
    await tester.pumpAndSettle();
    expect(find.byType(GroupsScreen), findsOneWidget);

    await _back(tester);
    expect(find.text(_exitTitle), findsNothing);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(GroupsScreen), findsNothing);
  });

  testApp('back on a pushed page returns without asking', (tester) async {
    await pumpHisabMitra(tester);
    await tester.tap(find.byTooltip('Calculator').first);
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsNothing);

    await _back(tester);
    expect(find.text(_exitTitle), findsNothing);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testApp('back with a dialog open closes only the dialog', (tester) async {
    await pumpHisabMitra(tester);
    unawaited(
      showDialog<void>(
        context: tester.element(find.byType(DashboardScreen)),
        builder: (_) => const AlertDialog(title: Text('Hello')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);

    await _back(tester);
    expect(find.text('Hello'), findsNothing);
    expect(find.text(_exitTitle), findsNothing);
  });

  testApp('a quick second back closes the exit dialog, never stacks one', (
    tester,
  ) async {
    await pumpHisabMitra(tester);
    final calls = _recordSystemCalls(tester);
    await tester.binding.handlePopRoute();
    await tester.pump(); // one frame: the dialog is opening
    expect(find.text(_exitTitle), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(_exitTitle), findsNothing);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(calls, isNot(contains('SystemNavigator.pop')));
  });

  testApp('back on the language screen asks before exiting', (tester) async {
    await pumpHisabMitra(
      tester,
      prefs: AppPreferences.fromMap(const {}),
      profileName: null,
    );
    expect(find.text('Choose your language'), findsOneWidget);

    await _back(tester);
    expect(find.text(_exitTitle), findsOneWidget);
  });
}

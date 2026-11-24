import 'package:flutter/material.dart';
import 'package:hisabmitra/features/tour/application/tour_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/dashboard/presentation/income_expense_chart.dart';

import '../features/dashboard/combined_totals_test.dart' show seedNovember;
import '../helpers/app_harness.dart';

void main() {
  testApp('the Home screen adds Family hisab and says how much', (
    tester,
  ) async {
    final db = await pumpHisabMitra(tester);
    await seedNovember(db);
    await tester.pumpAndSettle();

    expect(find.text('₹1,60,000.00'), findsOneWidget, reason: 'income');
    expect(find.text('₹98,500.00'), findsOneWidget, reason: 'expense');
    expect(find.text('₹61,500.00'), findsOneWidget, reason: 'savings');
    expect(
      find.text('Includes Family hisab: in ₹1,10,000.00 · out ₹78,500.00'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byType(IncomeExpenseChart),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final chart = tester.widget<IncomeExpenseChart>(
      find.byType(IncomeExpenseChart),
    );
    expect(
      (chart.months.last.incomePaise, chart.months.last.expensePaise),
      (16000000, 9850000),
    );
  });

  testApp('without a Family hisab there is no "includes" line', (tester) async {
    final db = await pumpHisabMitra(tester);
    await seedNovember(db, family: false);
    await tester.pumpAndSettle();
    expect(find.text('₹50,000.00'), findsOneWidget);
    expect(find.textContaining('Includes Family hisab'), findsNothing);
  });

  testApp('Home has eight quick actions in two full rows', (tester) async {
    await pumpHisabMitra(tester);
    final actions = find.byKey(TourTargets.quickActions);
    await tester.ensureVisible(actions);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: actions, matching: find.byType(InkWell)),
      findsNWidgets(8),
    );
    expect(
      find.descendant(of: actions, matching: find.text('Family hisab')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: actions, matching: find.text('Calculator')),
      findsNothing,
      reason: 'the calculator stays in the top bar and in More',
    );
    expect(find.byTooltip('Calculator'), findsWidgets);
  });
}

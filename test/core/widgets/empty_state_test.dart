import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/app/theme/app_theme.dart';
import 'package:hisabmitra/core/widgets/common_widgets.dart';

Widget _host(double height) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(
    body: Column(
      children: [
        SizedBox(
          height: height,
          child: EmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'No expenses yet',
            message:
                'Add the first expense — the split will be calculated for '
                'everyone automatically.',
            actionLabel: 'Add expense',
            onAction: () {},
          ),
        ),
      ],
    ),
  ),
);

void main() {
  // Found on a 1080×2340 emulator: the group screen's empty state overflowed
  // below the hero card and filters.
  testWidgets('scrolls instead of overflowing when space is short', (
    tester,
  ) async {
    await tester.pumpWidget(_host(150));
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(EmptyState), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Add expense'), findsOneWidget);
  });

  testWidgets('stays centred when there is room', (tester) async {
    await tester.pumpWidget(_host(500));
    expect(tester.takeException(), isNull);
    final box = tester.getRect(find.byType(EmptyState));
    final title = tester.getCenter(find.text('No expenses yet'));
    expect((title.dy - box.center.dy).abs(), lessThan(120));
  });
}

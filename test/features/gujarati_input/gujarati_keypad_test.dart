import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/gujarati_input/presentation/gujarati_keypad.dart';

Future<TextEditingController> _pump(WidgetTester tester) async {
  final controller = TextEditingController();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: GujaratiKeypad(controller: controller),
        ),
      ),
    ),
  );
  return controller;
}

Future<void> _tapAll(WidgetTester tester, List<String> labels) async {
  for (final label in labels) {
    await tester.tap(find.text(label));
    await tester.pump();
  }
}

void main() {
  testWidgets('after a consonant the top rows show its barakhadi', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('અ'), findsOneWidget, reason: 'vowels at the start');
    await _tapAll(tester, ['ક']);
    for (final form in ['કા', 'કિ', 'કી', 'કુ', 'કૂ', 'કે', 'કૈ', 'કો']) {
      expect(find.text(form), findsOneWidget, reason: form);
    }
    expect(find.text('ક્'), findsOneWidget);
    expect(find.text('અ'), findsNothing);
  });

  testWidgets('types પુણ્ય and હર્ષ without switching pages', (tester) async {
    final c = await _pump(tester);
    await _tapAll(tester, ['પ', 'પુ', 'ણ', 'ણ્', 'ય']);
    expect(c.text, 'પુણ્ય');

    c.clear();
    await tester.pump();
    await _tapAll(tester, ['હ', 'ર', 'ર્', 'ષ']);
    expect(c.text, 'હર્ષ');
  });

  testWidgets('the vowel key gives independent vowels after a consonant', (
    tester,
  ) async {
    final c = await _pump(tester);
    await _tapAll(tester, ['ગ']);
    await tester.tap(find.byKey(GujaratiKeypad.vowelsKey));
    await tester.pump();
    await _tapAll(tester, ['ઈ']);
    expect(c.text, 'ગઈ');
  });

  testWidgets('backspace removes one sign and brings the barakhadi back', (
    tester,
  ) async {
    final c = await _pump(tester);
    await _tapAll(tester, ['ક', 'કા']);
    expect(c.text, 'કા');
    expect(find.text('કા'), findsNothing, reason: 'vowels shown after a matra');

    await tester.tap(find.byKey(GujaratiKeypad.backspaceKey));
    await tester.pump();
    expect(c.text, 'ક');
    expect(find.text('કા'), findsOneWidget);
  });

  testWidgets('space, digits and punctuation', (tester) async {
    final c = await _pump(tester);
    await _tapAll(tester, ['મ']);
    await tester.tap(find.byKey(GujaratiKeypad.spaceKey));
    await tester.pump();
    await tester.tap(find.byKey(GujaratiKeypad.symbolsKey));
    await tester.pump();
    await _tapAll(tester, ['₹', '૫', '0']);
    expect(c.text, 'મ ₹૫0');

    await tester.tap(find.byKey(GujaratiKeypad.symbolsKey));
    await tester.pump();
    expect(find.text('ક'), findsOneWidget, reason: 'letters are back');
  });

  testWidgets('types at the cursor, not only at the end', (tester) async {
    final c = await _pump(tester);
    c.value = const TextEditingValue(
      text: 'રમ',
      selection: TextSelection.collapsed(offset: 1),
    );
    await tester.pump();
    // The cursor is after ર, so its barakhadi is offered.
    await _tapAll(tester, ['રા']);
    expect(c.text, 'રામ');
    expect(c.selection.baseOffset, 2);
  });
}

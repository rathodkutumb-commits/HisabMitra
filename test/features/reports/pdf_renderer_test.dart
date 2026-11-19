import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/reports/data/pdf_renderer.dart';

ReportDocument _doc(int rows) => ReportDocument(
  title: 'માસિક રિપોર્ટ',
  subtitle: 'March 2026',
  footer: 'Generated',
  pageLabel: (p, t) => '$p / $t',
  blocks: [
    const HeadingBlock('સારાંશ'),
    const KeyValueBlock([('આવક', '₹50,000.00'), ('ખર્ચ', '₹3,570.00')]),
    TableBlock(
      headers: const ['Date', 'Description', 'Amount'],
      numericColumns: const {2},
      rows: [
        for (var i = 0; i < rows; i++) ['01/03/2026', 'Entry $i', '₹1,000.00'],
      ],
    ),
  ],
);

void main() {
  test('short report fits on one page', () {
    expect(PdfReportRenderer(fontFamily: 'Roboto').pageCount(_doc(5)), 1);
  });

  test('long tables flow onto more pages', () {
    expect(
      PdfReportRenderer(fontFamily: 'Roboto').pageCount(_doc(200)),
      greaterThan(3),
    );
  });

  testWidgets('renders a valid PDF file', (tester) async {
    final bytes = await tester.runAsync(
      () => PdfReportRenderer(fontFamily: 'Roboto').render(_doc(30)),
    );
    expect(ascii.decode(bytes!.sublist(0, 4)), '%PDF');
  });
}

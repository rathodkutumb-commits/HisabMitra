import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/reports/data/csv_writer.dart';

void main() {
  test('starts with a UTF-8 BOM so Excel detects Gujarati text', () {
    final bytes = CsvWriter.encode([
      ['નામ', 'Amount'],
    ]);
    expect(bytes.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
    expect(utf8.decode(bytes.sublist(3)), 'નામ,Amount\r\n');
  });

  test('quotes fields with commas, quotes and newlines', () {
    final text = CsvWriter.build([
      ['a,b', 'say "hi"', 'line1\nline2', 'plain'],
    ]);
    expect(text, '"a,b","say ""hi""","line1\nline2",plain\r\n');
  });

  test('neutralises spreadsheet formula injection', () {
    final text = CsvWriter.build([
      ['=SUM(A1)', '+1', '-cmd', '@x', 'ok'],
    ]);
    expect(text, "'=SUM(A1),'+1,'-cmd,'@x,ok\r\n");
  });

  test('does not alter plain negative numbers used as amounts', () {
    expect(
      CsvWriter.build([
        ['-150.50'],
      ]),
      '-150.50\r\n',
    );
  });
}

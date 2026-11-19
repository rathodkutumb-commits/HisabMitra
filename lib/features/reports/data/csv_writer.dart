import 'dart:convert';
import 'dart:typed_data';

/// RFC 4180 CSV with CRLF line endings, written as UTF-8 with a BOM so that
/// Excel opens Gujarati text correctly ("Excel-compatible export").
abstract final class CsvWriter {
  static final _needsQuote = RegExp(r'[",\r\n]');
  static final _plainNumber = RegExp(r'^-?\d+(\.\d+)?$');

  static String _field(String value) {
    var v = value;
    // Cells starting with = + - @ are formulas in spreadsheets; prefix them
    // with an apostrophe unless they are plain numbers (CSV injection).
    if (v.isNotEmpty && '=+-@'.contains(v[0]) && !_plainNumber.hasMatch(v)) {
      v = "'$v";
    }
    if (_needsQuote.hasMatch(v)) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  static String build(List<List<String>> rows) {
    final out = StringBuffer();
    for (final row in rows) {
      out
        ..write(row.map(_field).join(','))
        ..write('\r\n');
    }
    return out.toString();
  }

  static Uint8List encode(List<List<String>> rows) {
    final body = utf8.encode(build(rows));
    return Uint8List.fromList([0xEF, 0xBB, 0xBF, ...body]);
  }
}

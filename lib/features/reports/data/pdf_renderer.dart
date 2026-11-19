import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../app/theme/palettes.dart';

/// Content blocks of a printable report.
sealed class ReportBlock {
  const ReportBlock();
}

class HeadingBlock extends ReportBlock {
  const HeadingBlock(this.text);
  final String text;
}

class NoteBlock extends ReportBlock {
  const NoteBlock(this.text);
  final String text;
}

class KeyValueBlock extends ReportBlock {
  const KeyValueBlock(this.rows);
  final List<(String, String)> rows;
}

class TableBlock extends ReportBlock {
  const TableBlock({
    required this.headers,
    required this.rows,
    this.numericColumns = const {},
    this.flex,
  });
  final List<String> headers;
  final List<List<String>> rows;
  final Set<int> numericColumns;

  /// Relative column widths; equal when null.
  final List<int>? flex;
}

class ReportDocument {
  const ReportDocument({
    required this.title,
    required this.subtitle,
    required this.blocks,
    required this.footer,
    required this.pageLabel,
  });

  final String title;
  final String subtitle;
  final List<ReportBlock> blocks;
  final String footer;

  /// Builds "Page x of y".
  final String Function(int page, int total) pageLabel;
}

/// Renders reports with Flutter's text engine (HarfBuzz shaping, so Gujarati
/// conjuncts and matras are correct) onto A4 canvases, then wraps each page
/// image into a PDF. See TD-09: text in the PDF is not selectable; CSV
/// export carries the machine-readable data.
class PdfReportRenderer {
  PdfReportRenderer({
    required this.fontFamily,
    this.fallback = const [],
    AppPalette palette = AppPalette.defaultPalette,
  }) : _c = palette.spec;

  final String fontFamily;
  final List<String> fallback;

  /// Colours follow the user's palette so exports match the app.
  final PaletteSpec _c;

  static const _pageW = 595.0;
  static const _pageH = 842.0;
  static const _margin = 36.0;
  static const _scale = 2.0;

  Color get _band => _c.heroStart;
  Color get _accent => _c.secondary;
  Color get _gold => _c.highlight;
  Color get _ink => _c.onSurface;
  Color get _muted => _c.onSurfaceVariant;
  Color get _rule => _c.outlineVariant;
  Color get _zebra => _c.background;

  TextStyle _style(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fallback,
    fontSize: size,
    fontWeight: weight,
    color: color ?? _ink,
    height: 1.3,
  );

  TextPainter _paint(
    String text,
    TextStyle style,
    double maxWidth, {
    TextAlign align = TextAlign.left,
    int? maxLines,
  }) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: maxLines,
      ellipsis: maxLines == null ? null : '…',
    )..layout(maxWidth: maxWidth);
  }

  /// Lays the document out into page drawing commands, then rasterises.
  Future<Uint8List> render(ReportDocument doc) async {
    final pages = _layout(doc);
    final pdf = pw.Document(title: doc.title, creator: 'HisabMitra');
    for (var i = 0; i < pages.length; i++) {
      final png = await _rasterise(doc, pages[i], i + 1, pages.length);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Image(pw.MemoryImage(png), fit: pw.BoxFit.fill),
        ),
      );
    }
    return pdf.save();
  }

  /// Number of pages the document will need (for tests and progress).
  int pageCount(ReportDocument doc) => _layout(doc).length;

  List<List<void Function(Canvas, double)>> _layout(ReportDocument doc) {
    const contentW = _pageW - 2 * _margin;
    const top = 104.0;
    const bottom = _pageH - 48;
    final pages = <List<void Function(Canvas, double)>>[[]];
    var y = top;

    void ensure(double h) {
      if (y + h > bottom) {
        pages.add([]);
        y = top;
      }
    }

    void add(void Function(Canvas c, double y) draw, double h) {
      ensure(h);
      final at = y;
      pages.last.add((c, _) => draw(c, at));
      y += h;
    }

    for (final block in doc.blocks) {
      switch (block) {
        case HeadingBlock(:final text):
          final tp = _paint(
            text,
            _style(13, weight: FontWeight.w700, color: _accent),
            contentW,
          );
          ensure(tp.height + 40);
          y += 10;
          add((c, at) {
            tp.paint(c, Offset(_margin, at));
            c.drawRect(
              Rect.fromLTWH(_margin, at + tp.height + 3, 36, 2.5),
              Paint()..color = _gold,
            );
          }, tp.height + 12);
        case NoteBlock(:final text):
          final tp = _paint(text, _style(8.5, color: _muted), contentW);
          add((c, at) => tp.paint(c, Offset(_margin, at)), tp.height + 6);
        case KeyValueBlock(:final rows):
          for (final (k, v) in rows) {
            final kp = _paint(k, _style(10, color: _muted), contentW * 0.6);
            final vp = _paint(
              v,
              _style(10, weight: FontWeight.w600),
              contentW * 0.4,
              align: TextAlign.right,
            );
            final h = (kp.height > vp.height ? kp.height : vp.height) + 6;
            add((c, at) {
              kp.paint(c, Offset(_margin, at));
              vp.paint(c, Offset(_margin + contentW - vp.width, at));
              c.drawLine(
                Offset(_margin, at + h - 2),
                Offset(_margin + contentW, at + h - 2),
                Paint()
                  ..color = _rule
                  ..strokeWidth = 0.5,
              );
            }, h);
          }
        case TableBlock(
          :final headers,
          :final rows,
          :final numericColumns,
          :final flex,
        ):
          final weights = flex ?? List.filled(headers.length, 1);
          final total = weights.fold<int>(0, (a, b) => a + b);
          final widths = [for (final w in weights) contentW * w / total];
          double rowHeight(List<String> cells, TextStyle style) {
            var h = 0.0;
            for (var i = 0; i < cells.length; i++) {
              final tp = _paint(cells[i], style, widths[i] - 8, maxLines: 3);
              if (tp.height > h) h = tp.height;
            }
            return h + 8;
          }

          void drawRow(
            Canvas c,
            double at,
            List<String> cells,
            TextStyle style,
            Color? bg,
            double h,
          ) {
            if (bg != null) {
              c.drawRect(
                Rect.fromLTWH(_margin, at, contentW, h),
                Paint()..color = bg,
              );
            }
            var x = _margin;
            for (var i = 0; i < cells.length; i++) {
              final numeric = numericColumns.contains(i);
              final tp = _paint(
                cells[i],
                style,
                widths[i] - 8,
                align: numeric ? TextAlign.right : TextAlign.left,
                maxLines: 3,
              );
              tp.paint(
                c,
                Offset(numeric ? x + widths[i] - 4 - tp.width : x + 4, at + 4),
              );
              x += widths[i];
            }
          }

          final headerStyle = _style(
            9,
            weight: FontWeight.w700,
            color: Colors.white,
          );
          final headerH = rowHeight(headers, headerStyle);
          void header() => add(
            (c, at) => drawRow(c, at, headers, headerStyle, _band, headerH),
            headerH,
          );
          ensure(headerH * 2);
          header();
          for (var r = 0; r < rows.length; r++) {
            final style = _style(9);
            final h = rowHeight(rows[r], style);
            if (y + h > bottom) {
              pages.add([]);
              y = top;
              header();
            }
            final cells = rows[r];
            final zebra = r.isOdd ? _zebra : null;
            add((c, at) => drawRow(c, at, cells, style, zebra, h), h);
          }
          y += 6;
      }
    }
    return pages;
  }

  Future<Uint8List> _rasterise(
    ReportDocument doc,
    List<void Function(Canvas, double)> commands,
    int page,
    int total,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(_scale);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _pageW, _pageH),
      Paint()..color = Colors.white,
    );
    // Header band with brand colours and a Patola-style lozenge row.
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _pageW, 72),
      Paint()..color = _band,
    );
    final lozenge = Paint()..color = _gold;
    for (var x = 8.0; x < _pageW; x += 16) {
      final p = Path()
        ..moveTo(x, 72)
        ..lineTo(x + 5, 76)
        ..lineTo(x, 80)
        ..lineTo(x - 5, 76)
        ..close();
      canvas.drawPath(p, lozenge);
    }
    _paint(
      'HisabMitra · હિસાબમિત્ર',
      _style(9, color: _c.onHero.withValues(alpha: 0.85)),
      300,
    ).paint(canvas, const Offset(_margin, 14));
    _paint(
      doc.title,
      _style(17, weight: FontWeight.w700, color: Colors.white),
      _pageW - 2 * _margin,
      maxLines: 1,
    ).paint(canvas, const Offset(_margin, 28));
    _paint(
      doc.subtitle,
      _style(9, color: _c.onHero.withValues(alpha: 0.9)),
      _pageW - 2 * _margin,
      maxLines: 1,
    ).paint(canvas, const Offset(_margin, 52));
    for (final draw in commands) {
      draw(canvas, 0);
    }
    final footer = _paint(doc.footer, _style(8, color: _muted), 360);
    footer.paint(canvas, const Offset(_margin, _pageH - 30));
    final label = _paint(
      doc.pageLabel(page, total),
      _style(8, color: _muted),
      160,
      align: TextAlign.right,
    );
    label.paint(canvas, Offset(_pageW - _margin - label.width, _pageH - 30));

    final image = await recorder.endRecording().toImage(
      (_pageW * _scale).round(),
      (_pageH * _scale).round(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return bytes!.buffer.asUint8List();
  }
}

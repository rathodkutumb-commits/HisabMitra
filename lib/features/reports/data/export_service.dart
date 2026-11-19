import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../categories/presentation/category_labels.dart';
import '../../settings/application/settings_controller.dart';
import '../../transactions/domain/transaction_models.dart';
import 'csv_writer.dart';
import 'pdf_renderer.dart';
import 'report_service.dart';

/// Builds CSV / PDF exports into the app cache and opens the share sheet.
/// Files are written only when the user asks for an export.
class ExportService {
  /// Plain machine-readable amount: `-1234.50` (no grouping, no symbol).
  static String plainAmount(int paise) {
    final sign = paise < 0 ? '-' : '';
    final abs = paise.abs();
    return '$sign${abs ~/ 100}.${(abs % 100).toString().padLeft(2, '0')}';
  }

  static String percentOf(int part, int total) {
    if (total == 0) return '0.0';
    final tenths = part * 1000 ~/ total;
    return '${tenths ~/ 10}.${tenths % 10}';
  }

  Future<File> _write(String baseName, String ext, Uint8List bytes) async {
    try {
      final dir = Directory(
        p.join((await getTemporaryDirectory()).path, 'exports'),
      );
      if (dir.existsSync()) dir.deleteSync(recursive: true);
      dir.createSync(recursive: true);
      final safe = baseName.replaceAll(RegExp(r'[^\w\-]+'), '_');
      final file = File(p.join(dir.path, '$safe.$ext'));
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } on FileSystemException {
      throw const StorageFailure();
    }
  }

  Future<void> share(File file, String mime, {String? subject}) =>
      SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: mime)],
          subject: subject,
        ),
      );

  PdfReportRenderer _renderer(Formatters fmt) => fmt.prefs.languageCode == 'gu'
      ? PdfReportRenderer(
          fontFamily: 'NotoSansGujarati',
          fallback: const ['Poppins'],
          palette: fmt.prefs.palette,
        )
      : PdfReportRenderer(
          fontFamily: 'Poppins',
          fallback: const ['NotoSansGujarati'],
          palette: fmt.prefs.palette,
        );

  List<String> _txnHeaders(AppLocalizations l) => [
    l.date,
    l.colType,
    l.category,
    l.description,
    l.amount,
    l.paymentMethod,
    l.person,
    l.notes,
  ];

  // ------------------------------------------------------------ transactions

  Future<File> transactionsCsv(
    List<TransactionView> items,
    AppLocalizations l,
    Formatters fmt,
  ) {
    final rows = [
      _txnHeaders(l),
      for (final v in items)
        [
          fmt.date(v.txn.txnDate),
          v.txn.type == TransactionType.income ? l.income : l.expense,
          v.category.label(l),
          v.txn.description,
          plainAmount(v.signedPaise),
          v.txn.paymentMethod.label(l),
          v.person?.name ?? '',
          v.txn.notes ?? '',
        ],
    ];
    return _write('hisabmitra_transactions', 'csv', CsvWriter.encode(rows));
  }

  Future<File> transactionsPdf(
    List<TransactionView> items,
    AppLocalizations l,
    Formatters fmt, {
    required String subtitle,
  }) async {
    var income = 0;
    var expense = 0;
    for (final v in items) {
      if (v.txn.type == TransactionType.income) {
        income += v.txn.amountPaise;
      } else {
        expense += v.txn.amountPaise;
      }
    }
    final doc = ReportDocument(
      title: l.transactionsExportTitle,
      subtitle: subtitle,
      footer: l.generatedOn(fmt.dateTime(DateTime.now())),
      pageLabel: (page, total) => l.pageOf(page, total),
      blocks: [
        KeyValueBlock([
          (l.income, fmt.money(income)),
          (l.expense, fmt.money(expense)),
          (l.balance, fmt.money(income - expense)),
        ]),
        TableBlock(
          headers: [
            l.date,
            l.category,
            l.description,
            l.paymentMethod,
            l.amount,
          ],
          numericColumns: const {4},
          flex: const [3, 4, 6, 3, 4],
          rows: [
            for (final v in items)
              [
                fmt.date(v.txn.txnDate),
                v.category.label(l),
                [
                  v.txn.description,
                  if (v.person != null) v.person!.name,
                ].where((s) => s.isNotEmpty).join(' · '),
                v.txn.paymentMethod.label(l),
                fmt.money(v.signedPaise, signed: true),
              ],
          ],
        ),
      ],
    );
    final bytes = await _renderer(fmt).render(doc);
    return _write('hisabmitra_transactions', 'pdf', bytes);
  }

  // ----------------------------------------------------------------- report

  Future<File> reportCsv(ReportData r, AppLocalizations l, Formatters fmt) {
    final s = r.summary;
    final rows = <List<String>>[
      [
        l.fullReportTitle,
        l.reportPeriod(fmt.date(r.range.start), fmt.date(r.range.endInclusive)),
      ],
      [],
      [l.reportOverview],
      [l.income, plainAmount(s.incomePaise)],
      [l.expense, plainAmount(s.expensePaise)],
      [l.savings, plainAmount(s.balancePaise)],
      [],
      [l.monthlyBreakdown],
      [l.colMonth, l.income, l.expense, l.savings],
      for (final m in r.monthly)
        [
          fmt.monthYear(m.month.start),
          plainAmount(m.incomePaise),
          plainAmount(m.expensePaise),
          plainAmount(m.incomePaise - m.expensePaise),
        ],
      [],
      [l.reportCategories],
      [l.category, l.colType, l.colCount, l.amount, l.colShare],
      for (final c in r.expenseByCategory)
        [
          c.category.label(l),
          l.expense,
          '${c.count}',
          plainAmount(c.totalPaise),
          percentOf(c.totalPaise, s.expensePaise),
        ],
      for (final c in r.incomeByCategory)
        [
          c.category.label(l),
          l.income,
          '${c.count}',
          plainAmount(c.totalPaise),
          percentOf(c.totalPaise, s.incomePaise),
        ],
      [],
      [l.reportPaymentMethods],
      [l.paymentMethod, l.colCount, l.amount],
      for (final m in r.expenseByMethod)
        [m.method.label(l), '${m.count}', plainAmount(m.totalPaise)],
      [],
      [l.reportPeople],
      [
        l.person,
        l.loansGiven,
        l.loansTaken,
        l.repaymentsReceived,
        l.repaymentsPaid,
        l.dashboardToReceive,
        l.dashboardToPay,
      ],
      for (final pr in r.people)
        [
          pr.person.name,
          plainAmount(pr.givenPaise),
          plainAmount(pr.takenPaise),
          plainAmount(pr.receivedBackPaise),
          plainAmount(pr.paidBackPaise),
          plainAmount(pr.outstandingReceivablePaise),
          plainAmount(pr.outstandingPayablePaise),
        ],
      [],
      [l.reportGroups],
      [
        l.groupName,
        l.colCount,
        l.totalSpent,
        l.myShare,
        l.iPaid,
        l.groupSettlementsLabel,
      ],
      for (final g in r.groups)
        [
          g.group.name,
          '${g.expenseCount}',
          plainAmount(g.spentPaise),
          plainAmount(g.mySharePaise),
          plainAmount(g.myPaidPaise),
          plainAmount(g.settlementsPaise),
        ],
      [],
      [l.reportSeparationNote],
    ];
    return _write('hisabmitra_report', 'csv', CsvWriter.encode(rows));
  }

  Future<File> reportPdf(
    ReportData r,
    AppLocalizations l,
    Formatters fmt,
  ) async {
    final s = r.summary;
    final doc = ReportDocument(
      title: l.fullReportTitle,
      subtitle: l.reportPeriod(
        fmt.date(r.range.start),
        fmt.date(r.range.endInclusive),
      ),
      footer: l.generatedOn(fmt.dateTime(DateTime.now())),
      pageLabel: (page, total) => l.pageOf(page, total),
      blocks: [
        HeadingBlock(l.reportOverview),
        KeyValueBlock([
          (l.income, fmt.money(s.incomePaise)),
          (l.expense, fmt.money(s.expensePaise)),
          (l.savings, fmt.money(s.balancePaise)),
        ]),
        if (r.monthly.length > 1) ...[
          HeadingBlock(l.monthlyBreakdown),
          TableBlock(
            headers: [l.colMonth, l.income, l.expense, l.savings],
            numericColumns: const {1, 2, 3},
            rows: [
              for (final m in r.monthly)
                [
                  fmt.monthYear(m.month.start),
                  fmt.money(m.incomePaise),
                  fmt.money(m.expensePaise),
                  fmt.money(m.incomePaise - m.expensePaise),
                ],
            ],
          ),
        ],
        HeadingBlock(l.reportCategories),
        if (r.expenseByCategory.isEmpty)
          NoteBlock(l.noDataForPeriod)
        else
          TableBlock(
            headers: [l.category, l.colCount, l.amount, l.colShare],
            numericColumns: const {1, 2, 3},
            flex: const [5, 2, 4, 2],
            rows: [
              for (final c in r.expenseByCategory)
                [
                  c.category.label(l),
                  '${c.count}',
                  fmt.money(c.totalPaise),
                  '${percentOf(c.totalPaise, s.expensePaise)}%',
                ],
            ],
          ),
        HeadingBlock(l.reportPaymentMethods),
        if (r.expenseByMethod.isEmpty)
          NoteBlock(l.noDataForPeriod)
        else
          TableBlock(
            headers: [l.paymentMethod, l.colCount, l.amount],
            numericColumns: const {1, 2},
            rows: [
              for (final m in r.expenseByMethod)
                [m.method.label(l), '${m.count}', fmt.money(m.totalPaise)],
            ],
          ),
        HeadingBlock(l.reportPeople),
        KeyValueBlock([
          (l.loansGiven, fmt.money(r.loansGivenPaise)),
          (l.loansTaken, fmt.money(r.loansTakenPaise)),
          (l.repaymentsReceived, fmt.money(r.repaymentsReceivedPaise)),
          (l.repaymentsPaid, fmt.money(r.repaymentsPaidPaise)),
        ]),
        if (r.people.isNotEmpty)
          TableBlock(
            headers: [
              l.person,
              l.loansGiven,
              l.loansTaken,
              l.dashboardToReceive,
              l.dashboardToPay,
            ],
            numericColumns: const {1, 2, 3, 4},
            flex: const [4, 3, 3, 3, 3],
            rows: [
              for (final pr in r.people)
                [
                  pr.person.name,
                  fmt.money(pr.givenPaise),
                  fmt.money(pr.takenPaise),
                  fmt.money(pr.outstandingReceivablePaise),
                  fmt.money(pr.outstandingPayablePaise),
                ],
            ],
          ),
        HeadingBlock(l.reportGroups),
        if (r.groups.isEmpty)
          NoteBlock(l.noDataForPeriod)
        else
          TableBlock(
            headers: [
              l.groupName,
              l.totalSpent,
              l.myShare,
              l.groupSettlementsLabel,
            ],
            numericColumns: const {1, 2, 3},
            flex: const [4, 3, 3, 3],
            rows: [
              for (final g in r.groups)
                [
                  g.group.name,
                  fmt.money(g.spentPaise),
                  fmt.money(g.mySharePaise),
                  fmt.money(g.settlementsPaise),
                ],
            ],
          ),
        NoteBlock(l.reportSeparationNote),
      ],
    );
    final bytes = await _renderer(fmt).render(doc);
    return _write('hisabmitra_report', 'pdf', bytes);
  }
}

final exportServiceProvider = Provider<ExportService>((ref) => ExportService());

import '../../../core/l10n/l10n_x.dart';
import '../../../core/utils/phone.dart';
import '../../reports/data/pdf_renderer.dart';
import '../../settings/application/settings_controller.dart';
import '../domain/family_models.dart';
import '../presentation/family_labels.dart';

/// One person's money in of one kind within a month.
typedef MoneyInLine = ({String memberId, FamilyEntryKind kind, int paise});

/// The month's money in, summed by person (in the statement's person
/// order) and kind.
List<MoneyInLine> moneyInLines(MonthStatement s) {
  final sums = <(String, FamilyEntryKind), int>{};
  for (final e in s.entries.where((e) => e.kind.isMoneyIn)) {
    sums.update(
      (e.memberId, e.kind),
      (v) => v + e.amountPaise,
      ifAbsent: () => e.amountPaise,
    );
  }
  return [
    for (final p in s.byPerson)
      for (final k in FamilyEntryKind.moneyIn)
        if (sums[(p.memberId, k)] case final paise?)
          (memberId: p.memberId, kind: k, paise: paise),
  ];
}

/// The month's money out by category name (in [languageCode]), largest
/// first.
List<(String, int)> moneyOutByCategory(MonthStatement s, String languageCode) {
  final sums = <String, int>{};
  for (final e in s.entries.where((e) => !e.kind.isMoneyIn)) {
    final name = e.categoryLabel(languageCode) ?? '—';
    sums.update(name, (v) => v + e.amountPaise, ifAbsent: () => e.amountPaise);
  }
  return [for (final x in sums.entries) (x.key, x.value)]
    ..sort((a, b) => b.$2.compareTo(a.$2));
}

/// Short statement for WhatsApp (*bold* headers).
String familyStatementText(
  AppLocalizations l,
  Formatters fmt, {
  required String familyName,
  required MonthStatement s,
  required String Function(String memberId) name,
}) {
  final month = fmt.monthYear(DateTime(s.year, s.month));
  return [
    '🏠 *$familyName — $month*',
    '${l.familyOpening}: ${fmt.money(s.openingPaise)}',
    '${l.familyMoneyIn}: ${fmt.money(s.moneyInPaise)}',
    '${l.familyMoneyOut}: ${fmt.money(s.moneyOutPaise)}',
    '${l.familyClosing}: ${fmt.money(s.closingPaise)}',
    if (s.byPerson.isNotEmpty) ...[
      '',
      '*${l.familyByPerson}*',
      for (final p in s.byPerson)
        l.familyPersonLine(
          name(p.memberId),
          fmt.money(p.moneyInPaise),
          fmt.money(p.paidPaise),
        ),
    ],
  ].join('\n');
}

/// The full statement as a printable document (PDF).
ReportDocument familyStatementDocument(
  AppLocalizations l,
  Formatters fmt, {
  required String familyName,
  required MonthStatement s,
  required String Function(String memberId) name,
}) {
  final month = fmt.monthYear(DateTime(s.year, s.month));
  return ReportDocument(
    title: '$familyName — $month',
    subtitle: l.familyStatementTitle,
    footer: l.generatedOn(fmt.dateTime(DateTime.now())),
    pageLabel: (page, total) => l.pageOf(page, total),
    blocks: [
      KeyValueBlock([
        (l.familyOpening, fmt.money(s.openingPaise)),
        (l.familyMoneyInCredit, fmt.money(s.moneyInPaise)),
        (l.familyMoneyOutDebit, fmt.money(s.moneyOutPaise)),
        (l.familyClosing, fmt.money(s.closingPaise)),
      ]),
      HeadingBlock(l.familyMoneyInCredit),
      TableBlock(
        headers: [l.familyPerson, l.familyKind, l.amount],
        rows: [
          for (final x in moneyInLines(s))
            [name(x.memberId), x.kind.label(l), fmt.money(x.paise)],
        ],
        numericColumns: const {2},
        flex: const [3, 3, 2],
      ),
      HeadingBlock(l.familyMoneyOutDebit),
      TableBlock(
        headers: [l.category, l.amount],
        rows: [
          for (final (category, paise) in moneyOutByCategory(s, l.localeName))
            [category, fmt.money(paise)],
        ],
        numericColumns: const {1},
        flex: const [5, 2],
      ),
      HeadingBlock(l.familyByPerson),
      TableBlock(
        headers: [l.familyPerson, l.familyMoneyIn, l.familyPaidForHome],
        rows: [
          for (final p in s.byPerson)
            [
              name(p.memberId),
              fmt.money(p.moneyInPaise),
              fmt.money(p.paidPaise),
            ],
        ],
        numericColumns: const {1, 2},
        flex: const [3, 2, 2],
      ),
    ],
  );
}

/// A WhatsApp chat with [phone], with [text] ready to send. Indian 10-digit
/// numbers get the country code 91.
Uri waMeUrl(String phone, String text) {
  final normalized = PhoneNumbers.normalize(phone);
  var digits = (normalized ?? phone).replaceAll(RegExp(r'\D'), '');
  if (normalized == null && digits.length == 10) digits = '91$digits';
  return Uri.parse('https://wa.me/$digits?text=${Uri.encodeComponent(text)}');
}

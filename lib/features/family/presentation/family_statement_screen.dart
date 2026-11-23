import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/hm_colors.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../reports/data/export_service.dart';
import '../../settings/application/settings_controller.dart';
import '../data/family_repository.dart';
import '../data/family_statement_export.dart';
import 'family_labels.dart';

/// A month's statement of a Family hisab: totals, money in by person and
/// kind, money out by category, and each person's part. Shared as a PDF
/// with a short text, or as WhatsApp text to a person with a number.
class FamilyStatementScreen extends ConsumerWidget {
  const FamilyStatementScreen({
    super.key,
    required this.familyId,
    required this.year,
    required this.month,
  });

  final String familyId;
  final int year;
  final int month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    final hm = HmColors.of(context);
    final detail = ref.watch(familyDetailProvider(familyId)).value;
    if (detail == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.familyStatement)),
        body: const LoadingView(),
      );
    }
    final s = detail.month(year, month);
    String name(String id) => detail.memberName(id, l);
    final text = familyStatementText(
      l,
      fmt,
      familyName: detail.family.name,
      s: s,
      name: name,
    );

    Future<void> share() async {
      try {
        final export = ref.read(exportServiceProvider);
        final file = await export.pdf(
          'hisabmitra_family_${year}_$month',
          familyStatementDocument(
            l,
            fmt,
            familyName: detail.family.name,
            s: s,
            name: name,
          ),
          fmt,
        );
        await export.share(
          file,
          'application/pdf',
          subject: l.familyStatementTitle,
          text: text,
        );
      } catch (e) {
        if (context.mounted) showFailure(context, e);
      }
    }

    // Everyone still in the Family hisab, and removed people with entries
    // this month.
    final lines = {for (final p in s.byPerson) p.memberId: p};
    final people = [
      for (final m in detail.members)
        if (m.status == 'active' || lines.containsKey(m.id)) m,
    ];
    final t = Theme.of(context).textTheme;

    Widget row(String label, String value, {bool bold = false, Color? color}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: bold ? t.titleMedium : t.bodyLarge),
              ),
              Text(
                value,
                style: (bold ? t.titleMedium : t.bodyLarge)?.copyWith(
                  color: color,
                  fontWeight: bold ? FontWeight.w700 : null,
                ),
              ),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(l.familyStatement),
        actions: [
          IconButton(
            tooltip: l.share,
            icon: const Icon(Icons.share_rounded),
            onPressed: share,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            '${detail.family.name} — ${fmt.monthYear(DateTime(year, month))}',
            style: t.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  row(l.familyOpening, fmt.money(s.openingPaise)),
                  row(
                    l.familyMoneyInCredit,
                    fmt.money(s.moneyInPaise),
                    color: hm.income,
                  ),
                  row(
                    l.familyMoneyOutDebit,
                    fmt.money(s.moneyOutPaise),
                    color: hm.expense,
                  ),
                  const Divider(),
                  row(l.familyClosing, fmt.money(s.closingPaise), bold: true),
                ],
              ),
            ),
          ),
          SectionHeader(title: l.familyMoneyInCredit),
          for (final x in moneyInLines(s))
            row('${name(x.memberId)} · ${x.kind.label(l)}', fmt.money(x.paise)),
          if (s.moneyInPaise != 0)
            row('', fmt.money(s.moneyInPaise), bold: true),
          SectionHeader(title: l.familyMoneyOutDebit),
          for (final (category, paise) in moneyOutByCategory(s, l.localeName))
            row(category, fmt.money(paise)),
          if (s.moneyOutPaise != 0)
            row('', fmt.money(s.moneyOutPaise), bold: true),
          SectionHeader(title: l.familyByPerson),
          for (final m in people)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: InitialsAvatar(name: m.name),
              title: Text(name(m.id)),
              subtitle: Text(
                '${l.familyMoneyIn} ${fmt.money(lines[m.id]?.moneyInPaise ?? 0)}'
                ' · ${l.familyPaidForHome} '
                '${fmt.money(lines[m.id]?.paidPaise ?? 0)}',
              ),
              trailing: m.phone == null || m.isSelf
                  ? null
                  : IconButton(
                      tooltip: l.familySendWhatsApp(m.name),
                      icon: const Icon(Icons.chat_rounded),
                      color: hm.income,
                      onPressed: () async {
                        final ok = await launchUrl(
                          waMeUrl(m.phone!, text),
                          mode: LaunchMode.externalApplication,
                        );
                        if (!ok && context.mounted) {
                          showAppSnack(context, l.genericError, error: true);
                        }
                      },
                    ),
            ),
        ],
      ),
    );
  }
}

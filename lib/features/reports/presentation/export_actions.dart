import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_x.dart';
import '../../../core/security/safe_logger.dart';
import '../../../core/widgets/dialogs.dart';
import '../../settings/application/settings_controller.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/transaction_models.dart';
import '../data/export_service.dart';

/// Runs an export with a blocking progress dialog, then opens the share
/// sheet. Errors are shown as friendly messages.
Future<void> runExport(
  BuildContext context,
  Future<File> Function() build, {
  required String mime,
  String? caption,
}) async {
  final l = context.l10n;
  final navigator = Navigator.of(context, rootNavigator: true);
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    ),
  );
  File? file;
  Object? error;
  try {
    file = await build();
  } catch (e, s) {
    SafeLogger.error('export_failed', e, s);
    error = e;
  } finally {
    navigator.pop();
  }
  if (!context.mounted) return;
  if (file == null) {
    showAppSnack(
      context,
      error == null ? l.exportFailed : failureMessage(l, error),
      error: true,
    );
    return;
  }
  final container = ProviderScope.containerOf(context);
  await container.read(exportServiceProvider).share(file, mime, text: caption);
}

/// App-bar menu exporting the currently filtered transactions.
class ExportMenuButton extends ConsumerWidget {
  const ExportMenuButton({super.key, required this.filter});

  final TransactionFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return PopupMenuButton<String>(
      tooltip: l.export,
      icon: const Icon(Icons.ios_share_rounded),
      onSelected: (kind) async {
        final fmt = ref.read(formattersProvider);
        final exporter = ref.read(exportServiceProvider);
        final items = await ref
            .read(transactionRepositoryProvider)
            .watch(filter)
            .first;
        if (!context.mounted) return;
        final range = filter.range;
        final subtitle = range == null
            ? l.filterAll
            : l.reportPeriod(
                fmt.date(range.start),
                fmt.date(range.endInclusive),
              );
        if (kind == 'csv') {
          await runExport(
            context,
            () => exporter.transactionsCsv(items, l, fmt),
            mime: 'text/csv',
            caption: l.shareReportCaption(l.navTransactions, subtitle),
          );
        } else {
          await runExport(
            context,
            () => exporter.transactionsPdf(items, l, fmt, subtitle: subtitle),
            mime: 'application/pdf',
            caption: l.shareReportCaption(l.navTransactions, subtitle),
          );
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'csv',
          child: ListTile(
            leading: const Icon(Icons.table_view_rounded),
            title: Text(l.exportCsv),
          ),
        ),
        PopupMenuItem(
          value: 'pdf',
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf_rounded),
            title: Text(l.exportPdf),
          ),
        ),
      ],
    );
  }
}

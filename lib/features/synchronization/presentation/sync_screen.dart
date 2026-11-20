import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/money/money.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../settings/application/settings_controller.dart';
import '../../authentication/application/auth_controller.dart';
import '../application/sync_controller.dart';

class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    final status = ref.watch(syncControllerProvider);
    final overview = ref.watch(syncOverviewProvider).value;
    final conflicts =
        ref.watch(openConflictsProvider).value ?? const <ConflictRow>[];
    final online = ref.watch(connectivityProvider).value ?? true;
    final session = ref.watch(cloudSessionProvider).value;
    String? blocker;
    if (session == null) {
      blocker = l.syncSignInNeeded;
    } else if (!online) {
      blocker = l.syncOffline;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.syncTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (blocker != null)
            Card(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: ListTile(
                leading: Icon(
                  online ? Icons.info_outline_rounded : Icons.cloud_off_rounded,
                ),
                title: Text(blocker),
                trailing: session == null
                    ? TextButton(
                        onPressed: () =>
                            ref.read(authControllerProvider).markSessionLost(),
                        child: Text(l.verifyEmailAction),
                      )
                    : null,
              ),
            ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.schedule_rounded),
                  title: Text(
                    overview?.lastSuccessAt == null
                        ? l.syncNever
                        : l.syncLastSuccess(
                            fmt.dateTime(overview!.lastSuccessAt!),
                          ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.outbox_rounded),
                  title: Text(l.syncPending(overview?.pendingOps ?? 0)),
                ),
                if ((overview?.failedOps ?? 0) > 0)
                  ListTile(
                    leading: Icon(
                      Icons.error_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(l.syncFailed(overview!.failedOps)),
                    trailing: TextButton(
                      onPressed: () =>
                          ref.read(syncServiceProvider).retryFailed(),
                      child: Text(l.syncRetry),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: status.running || blocker != null
                ? null
                : () async {
                    try {
                      await ref.read(syncControllerProvider.notifier).syncNow();
                      if (context.mounted) showAppSnack(context, l.syncDone);
                    } catch (e) {
                      if (context.mounted) showFailure(context, e);
                    }
                  },
            icon: status.running
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync_rounded),
            label: Text(status.running ? l.syncRunning : l.syncNow),
          ),
          if (conflicts.isNotEmpty) ...[
            SectionHeader(
              title: l.syncConflicts,
              padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
            ),
            Text(
              l.syncConflictHelp,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            for (final c in conflicts) _ConflictCard(conflict: c),
          ],
        ],
      ),
    );
  }
}

class _ConflictCard extends ConsumerWidget {
  const _ConflictCard({required this.conflict});

  final ConflictRow conflict;

  /// Human-readable summary of a payload (no raw JSON on screen).
  static String summary(AppLocalizations l, Map<String, Object?>? p) {
    if (p == null) return '—';
    if (p['deleted_at'] != null) return l.delete;
    final parts = <String>[
      if (p['description'] != null) p['description']! as String,
      if (p['name'] != null) p['name']! as String,
      if (p['display_name'] != null) p['display_name']! as String,
      if (p['amount_paise'] is num)
        Money.format((p['amount_paise']! as num).toInt()),
      if (p['expense_date'] != null) p['expense_date']! as String,
      if (p['settled_on'] != null) p['settled_on']! as String,
    ];
    return parts.isEmpty ? '—' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final local = (jsonDecode(conflict.localPayload) as Map)
        .cast<String, Object?>();
    final localPayload = local['op_type'] == 'delete'
        ? <String, Object?>{'deleted_at': 'now'}
        : (local['payload'] as Map?)?.cast<String, Object?>();
    final remote = conflict.remotePayload == null
        ? null
        : (jsonDecode(conflict.remotePayload!) as Map).cast<String, Object?>();
    final type = conflict.scope == 'personal'
        ? switch (conflict.entityType) {
            'person' => l.entityPerson,
            'ledger_entry' => l.entityLedgerEntry,
            'ledger_repayment' => l.entityRepayment,
            'reminder' => l.entityReminder,
            'attachment' => l.entityBill,
            _ => l.entityTransaction,
          }
        : switch (conflict.entityType) {
            'group' => l.entityGroup,
            'member' => l.entityMember,
            'settlement' => l.entitySettlement,
            _ => l.entityExpense,
          };
    Future<void> resolve(bool keepLocal) async {
      try {
        await ref
            .read(syncServiceProvider)
            .resolveConflict(conflict.id, keepLocal: keepLocal);
        await ref.read(syncControllerProvider.notifier).syncNow(silent: true);
      } catch (e) {
        if (context.mounted) showFailure(context, e);
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(type, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              l.syncYourVersion,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(summary(l, localPayload)),
            const SizedBox(height: 8),
            Text(
              l.syncOtherVersion,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(summary(l, remote)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => resolve(false),
                    child: Text(l.syncKeepTheirs),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => resolve(true),
                    child: Text(l.syncKeepMine),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

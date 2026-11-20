import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../main.dart';
import '../../settings/application/settings_controller.dart';
import '../application/backup_providers.dart';
import '../data/backup_service.dart';
import '../../synchronization/application/sync_controller.dart';
import '../data/restore_sync.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  var _busy = false;

  Future<T?> _guard<T>(Future<T> Function() action) async {
    setState(() => _busy = true);
    try {
      return await action();
    } catch (e) {
      if (mounted) showFailure(context, e);
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askPassword({required bool confirm}) async {
    final l = context.l10n;
    final pass = TextEditingController();
    final again = TextEditingController();
    final form = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(confirm ? l.backupEncrypt : l.backupPassword),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: pass,
                obscureText: true,
                autofocus: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(labelText: l.backupPassword),
                validator: (v) => confirm && (v ?? '').length < 8
                    ? l.backupPasswordTooShort
                    : null,
              ),
              if (confirm) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: again,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: l.backupPasswordConfirm,
                  ),
                  validator: (v) =>
                      v != pass.text ? l.backupPasswordMismatch : null,
                ),
                const SizedBox(height: 12),
                Text(
                  l.backupPasswordWarning,
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(ctx, pass.text);
            },
            child: Text(l.ok),
          ),
        ],
      ),
    );
    pass.dispose();
    again.dispose();
    return result;
  }

  Future<void> _backupNow() async {
    final l = context.l10n;
    final encrypt = await showDialog<bool>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.backupNow),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, false),
            child: ListTile(
              leading: const Icon(Icons.folder_zip_rounded),
              title: Text(l.backupKindManual),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, true),
            child: ListTile(
              leading: const Icon(Icons.lock_rounded),
              title: Text(l.backupEncrypt),
            ),
          ),
        ],
      ),
    );
    if (encrypt == null) return;
    String? password;
    if (encrypt) {
      password = await _askPassword(confirm: true);
      if (password == null) return;
    }
    final row = await _guard(
      () => ref.read(backupServiceProvider).createBackup(password: password),
    );
    if (row != null && mounted) showAppSnack(context, l.backupCreated);
  }

  Future<void> _restoreFrom(File file) async {
    final l = context.l10n;
    final fmt = ref.read(formattersProvider);
    final service = ref.read(backupServiceProvider);
    // A restore replaces the hisab saved in the account, so it needs the
    // internet to finish.
    final inAccount =
        ref.read(cloudGatewayProvider).isConfigured &&
        ref.read(cloudGatewayProvider).currentSession != null;
    if (inAccount && ref.read(connectivityProvider).value == false) {
      showAppSnack(context, l.restoreNeedsInternet, error: true);
      return;
    }
    String? password;
    BackupInspection? inspection;
    while (inspection == null) {
      try {
        setState(() => _busy = true);
        inspection = await service.inspect(file, password: password);
      } on BackupFailure catch (f) {
        if (!mounted) return;
        setState(() => _busy = false);
        if (f.code == 'password_required' || f.code == 'wrong_password') {
          if (f.code == 'wrong_password') showFailure(context, f);
          password = await _askPassword(confirm: false);
          if (password == null) return;
          continue;
        }
        showFailure(context, f);
        return;
      } catch (e) {
        if (mounted) {
          setState(() => _busy = false);
          showFailure(context, e);
        }
        return;
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }
    if (!mounted) return;
    final ok = await confirmAction(
      context,
      title: l.backupRestoreConfirmTitle,
      message: [
        l.backupRestoreConfirmBody(
          fmt.dateTime(inspection.createdAt),
          inspection.counts['transactions'] ?? 0,
          inspection.counts['persons'] ?? 0,
          inspection.counts['groups'] ?? 0,
        ),
        if (inAccount) l.restoreReplacesAccount,
      ].join('\n\n'),
      confirmLabel: l.backupRestore,
      destructive: true,
    );
    if (!ok || !mounted) {
      await service.discardInspection(inspection);
      return;
    }
    final missing = inspection.missingAttachments;
    final done = missing > 0
        ? '${l.backupRestoreDone}. ${l.backupRestoreMissingAttachments(missing)}'
        : l.backupRestoreDone;
    final bootstrapContext = context;
    setState(() => _busy = true);
    // The whole app is rebuilt after the database is swapped, so the result
    // is handed to the new app instance as a one-time notice.
    try {
      await service.restore(
        inspection,
        // Queue the restored records for the account before they go live.
        prepareRestoredDatabase: inAccount
            ? (path) async {
                final restored = AppDatabase(NativeDatabase(File(path)));
                try {
                  await RestoreSync(
                    restored,
                    ref.read(clockProvider),
                    ref.read(idGeneratorProvider),
                  ).afterRestore();
                } finally {
                  await restored.close();
                }
              }
            : null,
        replaceDatabase: (whileClosed) =>
            AppBootstrap.replaceDatabase(bootstrapContext, () async {
              AppBootstrap.noticeAfterRestart = l.genericError;
              await whileClosed();
              AppBootstrap.noticeAfterRestart = done;
            }),
      );
    } catch (e) {
      AppBootstrap.noticeAfterRestart = failureMessage(l, e);
      if (mounted) {
        setState(() => _busy = false);
        showFailure(context, e);
      }
    }
  }

  Future<void> _pickAndRestore() async {
    final picked = await FilePicker.pickFile(type: FileType.any);
    final path = picked?.path;
    if (path == null || !mounted) return;
    await _restoreFrom(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.backupTitle)),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l.backupWhere)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _busy ? null : _backupNow,
                icon: const Icon(Icons.backup_rounded),
                label: Text(l.backupNow),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _busy ? null : _pickAndRestore,
                icon: const Icon(Icons.restore_rounded),
                label: Text(l.backupRestoreFromFile),
              ),
              SectionHeader(
                title: l.backupHistory,
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
              ),
              AsyncValueView(
                value: ref.watch(backupHistoryProvider),
                data: (rows) => rows.isEmpty
                    ? Text(l.backupNone)
                    : Column(
                        children: [
                          for (final r in rows)
                            _HistoryTile(row: r, onRestore: _restoreFrom),
                        ],
                      ),
              ),
            ],
          ),
          if (_busy)
            const Positioned.fill(
              child: ColoredBox(color: Color(0x33000000), child: LoadingView()),
            ),
        ],
      ),
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.row, required this.onRestore});

  final BackupHistoryRow row;
  final Future<void> Function(File) onRestore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    final file = File(row.filePath);
    final exists = file.existsSync();
    final kind = switch (row.kind) {
      BackupKind.manual => l.backupKindManual,
      BackupKind.automatic => l.backupKindAutomatic,
      BackupKind.safety => l.backupKindSafety,
    };
    final size = row.sizeBytes < 1024 * 1024
        ? '${(row.sizeBytes / 1024).toStringAsFixed(0)} KB'
        : '${(row.sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          row.encrypted ? Icons.lock_rounded : Icons.folder_zip_rounded,
        ),
        title: Text(fmt.dateTime(row.createdAt)),
        subtitle: Text(
          [
            kind,
            size,
            if (row.encrypted) l.backupEncryptedLabel,
            if (!exists) l.backupFileMissing,
          ].join(' · '),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (a) async {
            switch (a) {
              case 'share':
                final date = fmt.date(row.createdAt);
                await SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(file.path)],
                    text: row.encrypted
                        ? l.shareBackupCaption(date)
                        : l.shareBackupCaptionPlain(date),
                  ),
                );
              case 'restore':
                await onRestore(file);
              case 'delete':
                final ok = await confirmDelete(
                  context,
                  message: l.backupDeleteConfirm,
                );
                if (ok) {
                  await ref.read(backupServiceProvider).deleteBackup(row.id);
                }
            }
          },
          itemBuilder: (_) => [
            if (exists)
              PopupMenuItem(value: 'share', child: Text(l.backupExport)),
            if (exists)
              PopupMenuItem(value: 'restore', child: Text(l.backupRestore)),
            PopupMenuItem(value: 'delete', child: Text(l.delete)),
          ],
        ),
      ),
    );
  }
}

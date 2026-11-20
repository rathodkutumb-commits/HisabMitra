import 'package:flutter/material.dart';

import '../l10n/l10n_x.dart';

/// Confirmation dialog for destructive or important actions.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  String? message,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final l = context.l10n;
  final scheme = Theme.of(context).colorScheme;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelLabel ?? l.cancel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                )
              : null,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel ?? l.confirm),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<bool> confirmDelete(BuildContext context, {String? message}) {
  final l = context.l10n;
  return confirmAction(
    context,
    title: l.confirmDeleteTitle,
    message: message ?? l.confirmDeleteMessage,
    confirmLabel: l.delete,
    destructive: true,
  );
}

void showAppSnack(BuildContext context, String message, {bool error = false}) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? scheme.error : null,
        showCloseIcon: error,
      ),
    );
}

void showFailure(BuildContext context, Object error) =>
    showAppSnack(context, failureMessage(context.l10n, error), error: true);

/// Guards a form against leaving with unsaved changes.
class UnsavedChangesGuard extends StatelessWidget {
  const UnsavedChangesGuard({
    super.key,
    required this.hasChanges,
    required this.child,
  });

  final bool hasChanges;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final l = context.l10n;
        final leave = await confirmAction(
          context,
          title: l.discardChangesTitle,
          message: l.discardChangesMessage,
          confirmLabel: l.discard,
          destructive: true,
        );
        if (leave && context.mounted) Navigator.of(context).pop();
      },
      child: child,
    );
  }
}

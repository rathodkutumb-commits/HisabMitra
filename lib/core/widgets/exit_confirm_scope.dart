import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n_x.dart';
import 'dialogs.dart';

/// Stops the system back button from closing the app by surprise.
///
/// On a page that can go back, back works as usual. On the bottom-most page
/// (the home tabs, onboarding and sign-in) back runs [onBack] when given
/// (e.g. switch to the Home tab), otherwise it asks "Exit HisabMitra?" and
/// closes the app only after the user confirms.
class ExitConfirmScope extends StatefulWidget {
  const ExitConfirmScope({super.key, required this.child, this.onBack});

  final Widget child;
  final VoidCallback? onBack;

  @override
  State<ExitConfirmScope> createState() => _ExitConfirmScopeState();
}

class _ExitConfirmScopeState extends State<ExitConfirmScope> {
  var _asking = false;

  Future<void> _blockedBack() async {
    final onBack = widget.onBack;
    if (onBack != null) {
      onBack();
      return;
    }
    if (_asking) return;
    _asking = true;
    try {
      final l = context.l10n;
      final exit = await confirmAction(
        context,
        title: l.exitAppTitle,
        confirmLabel: l.exitAppConfirm,
        cancelLabel: l.exitAppStay,
      );
      if (exit) await SystemNavigator.pop();
    } finally {
      _asking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFirst = ModalRoute.of(context)?.isFirst ?? true;
    return PopScope(
      canPop: !isFirst,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _blockedBack();
      },
      child: widget.child,
    );
  }
}

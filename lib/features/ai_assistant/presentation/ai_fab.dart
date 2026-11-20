import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../gujarati_input/presentation/gujarati_text_field.dart';
import '../../settings/application/settings_controller.dart';

/// A page's floating buttons with the AI assistant button on top, like
/// WhatsApp's AI button above "new chat".
///
/// Use as `floatingActionButton: AiFabStack(child: <the page's own FAB>)`,
/// or `const AiFabStack()` on pages without one. The AI button shows only
/// while the assistant is on, and hides while the keyboard or the Gujarati
/// keypad is open. Tapping it opens the assistant chat.
class AiFabStack extends ConsumerStatefulWidget {
  const AiFabStack({super.key, this.child});

  final Widget? child;

  @override
  ConsumerState<AiFabStack> createState() => _AiFabStackState();
}

class _AiFabStackState extends ConsumerState<AiFabStack>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // The keyboard changes the window insets; rebuild to show/hide.
  @override
  void didChangeMetrics() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final aiOn = ref.watch(
      settingsControllerProvider.select((p) => p.aiEnabled),
    );
    // Read the window itself: pages inside the tab shell get a MediaQuery
    // with the keyboard inset already removed by the outer Scaffold.
    final keyboardOpen = View.of(context).viewInsets.bottom > 0;
    return ValueListenableBuilder<int>(
      valueListenable: GujaratiTextField.openKeypads,
      builder: (context, keypads, _) {
        final showAi = aiOn && !keyboardOpen && keypads == 0;
        final pageFab = widget.child;
        if (!showAi) return pageFab ?? const SizedBox.shrink();
        final ai = FloatingActionButton.small(
          heroTag: null,
          tooltip: context.l10n.aiOpenAssistant,
          onPressed: () => context.push(Routes.ai),
          child: const Icon(Icons.auto_awesome_rounded),
        );
        if (pageFab == null) return ai;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [ai, const SizedBox(height: 12), pageFab],
        );
      },
    );
  }
}

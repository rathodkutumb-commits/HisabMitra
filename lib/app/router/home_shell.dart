import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_x.dart';
import '../../core/widgets/exit_confirm_scope.dart';
import '../../features/reminders/application/notification_service.dart';
import '../../features/tour/application/tour_controller.dart';

/// Bottom navigation scaffold for the five main tabs.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    // Back on a tab other than Home goes to Home; back on Home asks before
    // closing the app.
    return ExitConfirmScope(
      onBack: navigationShell.currentIndex == 0
          ? null
          : () => navigationShell.goBranch(0),
      child: _NotificationOpener(child: _scaffold(l)),
    );
  }

  Widget _scaffold(AppLocalizations l) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        key: TourTargets.navBar,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long_rounded),
            label: l.navTransactions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book_rounded),
            label: l.navPeople,
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            selectedIcon: const Icon(Icons.groups_rounded),
            label: l.navGroups,
          ),
          NavigationDestination(
            icon: const Icon(Icons.apps_outlined),
            selectedIcon: const Icon(Icons.apps_rounded),
            label: l.navMore,
          ),
        ],
      ),
    );
  }
}

/// Opens the page a tapped reminder notification asked for, once the tabs
/// are on screen (also when the tap started the app).
class _NotificationOpener extends ConsumerStatefulWidget {
  const _NotificationOpener({required this.child});

  final Widget child;

  @override
  ConsumerState<_NotificationOpener> createState() =>
      _NotificationOpenerState();
}

class _NotificationOpenerState extends ConsumerState<_NotificationOpener> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openWaiting());
  }

  void _openWaiting() {
    if (!mounted) return;
    final route = ref.read(notificationRouteProvider.notifier).take();
    if (route != null) context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(notificationRouteProvider, (_, route) {
      if (route != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _openWaiting());
      }
    });
    return widget.child;
  }
}

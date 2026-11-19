import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/decor.dart';
import '../../../core/widgets/hm_logo.dart';
import '../../settings/application/settings_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(const Duration(milliseconds: 1500), _continue);
  }

  void _continue() {
    if (!mounted) return;
    final done = ref.read(settingsControllerProvider).onboardingComplete;
    context.go(done ? Routes.home : Routes.language);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    return Scaffold(
      body: BandhaniBackground(
        child: SafeArea(
          child: Column(
            children: [
              const ToranStrip(height: 46),
              const Spacer(flex: 2),
              ScaleTransition(
                scale: reduceMotion ? const AlwaysStoppedAnimation(1) : curve,
                child: const HmLogo(size: 128),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: reduceMotion
                    ? const AlwaysStoppedAnimation(1)
                    : _controller,
                child: Column(
                  children: [
                    Text(
                      'HisabMitra',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'હિસાબમિત્ર',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: 'NotoSansGujarati',
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const PatolaDivider(height: 8, width: 120),
                    const SizedBox(height: 12),
                    Text(
                      l.appTagline,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

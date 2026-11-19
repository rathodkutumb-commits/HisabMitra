import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/decor.dart';
import '../../../core/widgets/hm_logo.dart';
import '../../settings/application/settings_controller.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final current = ref.watch(settingsControllerProvider).languageCode;

    Widget option(String code, String title, String sample) {
      final selected = current == code;
      return Card(
        color: selected ? theme.colorScheme.primaryContainer : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => ref
              .read(settingsControllerProvider.notifier)
              .update((p) => p.copyWith(languageCode: code)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Text(
                    sample,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSecondaryContainer,
                      fontFamily: code == 'gu' ? 'NotoSansGujarati' : 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: BandhaniBackground(
        opacity: 0.6,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Center(child: HmLogo(size: 72)),
                const SizedBox(height: 24),
                Text(
                  l.languageTitle,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l.languageSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                option('gu', l.languageGujarati, 'ગુ'),
                const SizedBox(height: 12),
                option('en', l.languageEnglish, 'En'),
                const Spacer(),
                FilledButton(
                  onPressed: () => context.go(Routes.intro),
                  child: Text(l.next),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

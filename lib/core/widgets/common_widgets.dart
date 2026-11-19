import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/hm_colors.dart';
import '../../features/settings/application/settings_controller.dart';
import '../l10n/l10n_x.dart';
import 'decor.dart';

/// Section title with a small Patola accent and optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(16, 20, 8, 8),
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                const SizedBox(height: 4),
                const PatolaDivider(height: 6, width: 42),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

/// Friendly empty state with Bandhani backdrop.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: compact ? 20 : 40,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 56 : 84,
            height: compact ? 56 : 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primaryContainer,
              border: Border.all(
                color: HmColors.of(context).highlight,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: compact ? 28 : 40,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
    // Centred when there is room; scrolls instead of overflowing on short
    // screens or when it shares the height with headers (e.g. group detail).
    return BandhaniBackground(
      opacity: 0.8,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedHeight) return Center(child: content);
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: Center(child: content),
            ),
          );
        },
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: context.l10n.loading,
      child: const CircularProgressIndicator(),
    ),
  );
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: failureMessage(l, error),
      actionLabel: onRetry == null ? null : l.retry,
      onAction: onRetry,
      compact: true,
    );
  }
}

/// Renders an [AsyncValue] with consistent loading / error states.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(error: e, onRetry: onRetry),
    );
  }
}

/// Formatted amount. [colorize] tints positive as income / negative as
/// expense.
class AmountText extends ConsumerWidget {
  const AmountText(
    this.paise, {
    super.key,
    this.style,
    this.colorize = false,
    this.color,
    this.signed = false,
    this.compact = false,
  });

  final int paise;
  final TextStyle? style;
  final bool colorize;
  final Color? color;
  final bool signed;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hm = HmColors.of(context);
    final text = ref.fmt.money(paise, signed: signed, compact: compact);
    Color? c = color;
    if (colorize && c == null) {
      c = paise > 0
          ? hm.income
          : paise < 0
          ? hm.expense
          : null;
    }
    return Text(
      text,
      style: (style ?? Theme.of(context).textTheme.bodyLarge)?.copyWith(
        color: c,
        fontFeatures: const [FontFeature.tabularFigures()],
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Gradient hero card with a faint Bandhani texture.
class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final hm = HmColors.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [hm.heroStart, hm.heroEnd],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _HeroDots(hm.onHero.withValues(alpha: 0.07)),
              ),
            ),
            Padding(
              padding: padding ?? const EdgeInsets.all(20),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: hm.onHero),
                child: IconTheme.merge(
                  data: IconThemeData(color: hm.onHero),
                  child: child,
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: PatolaDivider(height: 7),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroDots extends CustomPainter {
  _HeroDots(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var x = size.width * 0.55; x < size.width + 20; x += 18) {
      for (var y = 0.0; y < size.height; y += 18) {
        canvas.drawCircle(Offset(x, y), 2.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_HeroDots oldDelegate) => oldDelegate.color != color;
}

/// Coloured circular icon used for categories, people avatars, etc.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: color, size: size * 0.55),
    );
  }
}

/// Initials avatar for people / members.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.radius = 20});

  final String name;
  final double radius;

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final chars = parts
        .take(2)
        .map((p) => String.fromCharCodes(p.runes.take(1)));
    final result = chars.join().toUpperCase();
    return result.isEmpty ? '?' : result;
  }

  @override
  Widget build(BuildContext context) {
    final palette = HmColors.of(context).chartPalette;
    final color = palette[name.hashCode.abs() % palette.length];
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.18),
      child: Text(
        initials(name),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.75,
        ),
      ),
    );
  }
}

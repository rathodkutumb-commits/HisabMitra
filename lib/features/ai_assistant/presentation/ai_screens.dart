import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/hm_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/hm_logo.dart';
import '../../gujarati_input/presentation/gujarati_text_field.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../application/ai_chat_controller.dart';
import '../data/claude_answer_service.dart';
import 'ai_examples.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  var _sending = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _sending) return;
    setState(() => _sending = true);
    _input.clear();
    await ref.read(aiChatControllerProvider.notifier).ask(text, context.l10n);
    if (!mounted) return;
    setState(() => _sending = false);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (_scroll.hasClients) {
      await _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final prefs = ref.watch(settingsControllerProvider);
    final messages = ref.watch(aiChatControllerProvider);
    final names = ref.watch(aiExampleNamesProvider).value;
    final sections = buildAiExamples(
      l,
      personName: names?.person,
      groupName: names?.group,
      familyName: names?.family,
      familyPersonName: names?.familyPerson,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const HmLogo(size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text(l.aiTitle, overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              tooltip: l.clear,
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () =>
                  ref.read(aiChatControllerProvider.notifier).clear(),
            ),
          IconButton(
            tooltip: l.aiSettingsTitle,
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => context.push('${Routes.ai}/settings'),
          ),
        ],
      ),
      body: !prefs.aiEnabled
          ? EmptyState(
              icon: Icons.auto_awesome_rounded,
              title: l.aiDisabledTitle,
              message: l.aiDisabledBody,
              actionLabel: l.aiEnable,
              onAction: () => ref
                  .read(settingsControllerProvider.notifier)
                  .update((p) => p.copyWith(aiEnabled: true)),
            )
          : Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Text(
                              l.aiHelp,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            for (final section in sections) ...[
                              const SizedBox(height: 16),
                              Text(
                                section.title,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final e in section.examples)
                                    ActionChip(
                                      label: Text(e.text),
                                      onPressed: () => _send(e.text),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        )
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                          itemCount: messages.length + (_sending ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i == messages.length) {
                              return const Padding(
                                padding: EdgeInsets.all(12),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final m = messages[i];
                            return m.fromUser
                                ? _UserBubble(text: m.text)
                                : _AnswerBubble(message: m);
                          },
                        ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: GujaratiTextField(
                            controller: _input,
                            textInputAction: TextInputAction.send,
                            decoration: InputDecoration(
                              hintText: l.aiInputHint,
                            ),
                            maxLength: 300,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          tooltip: l.next,
                          onPressed: _sending ? null : () => _send(_input.text),
                          icon: const Icon(Icons.send_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 48, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(text, style: TextStyle(color: scheme.onPrimary)),
      ),
    );
  }
}

class _AnswerBubble extends StatelessWidget {
  const _AnswerBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final hm = HmColors.of(context);
    final a = message.answer!;
    Widget badge(IconData icon, String text, Color color) => Container(
      margin: const EdgeInsets.only(right: 6, top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: theme.textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 32, bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.onlineText != null) ...[
              Text(message.onlineText!, style: theme.textTheme.bodyLarge),
              const Divider(height: 20),
              Text(a.text, style: theme.textTheme.bodySmall),
            ] else
              Text(a.text, style: theme.textTheme.bodyLarge),
            for (final b in a.bullets)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7, right: 8),
                      child: Icon(Icons.circle, size: 6, color: hm.highlight),
                    ),
                    Expanded(child: Text(b)),
                  ],
                ),
              ),
            Wrap(
              children: [
                if (a.isSuggestion)
                  badge(
                    Icons.lightbulb_outline_rounded,
                    l.aiSuggestionBadge,
                    theme.colorScheme.tertiary,
                  )
                else
                  badge(
                    Icons.verified_rounded,
                    l.aiCalculatedOnPhone,
                    hm.income,
                  ),
                if (a.periodLabel != null)
                  badge(
                    Icons.date_range_rounded,
                    l.aiPeriodLabel(a.periodLabel!),
                    theme.colorScheme.primary,
                  ),
                if (message.onlineText != null)
                  badge(
                    Icons.cloud_rounded,
                    l.aiOnlineBadge,
                    theme.colorScheme.secondary,
                  ),
              ],
            ),
            if (message.onlineFailed)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(l.aiOnlineFailed, style: theme.textTheme.bodySmall),
              ),
            if (a.draft != null) ...[
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () => context.push(
                  Routes.newTransaction(
                    type: a.draft!.type == TransactionType.income
                        ? 'income'
                        : 'expense',
                    amountPaise: a.draft!.amountPaise,
                    categoryId: a.draft!.categoryId,
                  ),
                ),
                icon: const Icon(Icons.edit_note_rounded),
                label: Text(l.aiReviewDraft),
              ),
              const SizedBox(height: 4),
              Text(l.aiDraftNote, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class AiSettingsScreen extends ConsumerStatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  ConsumerState<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends ConsumerState<AiSettingsScreen> {
  final _key = TextEditingController();

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final hasKey = ref.watch(aiKeyPresentProvider).value ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(l.aiSettingsTitle)),
      body: RadioGroup<AiProvider>(
        groupValue: p.aiProvider,
        onChanged: (v) {
          if (v != null) controller.update((x) => x.copyWith(aiProvider: v));
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.auto_awesome_rounded),
              title: Text(l.settingsAiEnabled),
              subtitle: Text(l.settingsAiEnabledDesc),
              value: p.aiEnabled,
              onChanged: (v) =>
                  controller.update((x) => x.copyWith(aiEnabled: v)),
            ),
            SectionHeader(title: l.settingsAiProvider),
            RadioListTile<AiProvider>(
              value: AiProvider.local,
              enabled: p.aiEnabled,
              title: Text(l.aiProviderLocal),
            ),
            RadioListTile<AiProvider>(
              value: AiProvider.online,
              enabled: p.aiEnabled,
              title: Text(l.aiProviderOnline),
            ),
            if (p.aiProvider == AiProvider.online && p.aiEnabled) ...[
              SwitchListTile(
                title: Text(l.settingsAiConsent),
                subtitle: Text(l.settingsAiConsentDesc),
                value: p.aiConsent,
                onChanged: (v) async {
                  if (v) {
                    final ok = await confirmAction(
                      context,
                      title: l.settingsAiConsent,
                      message: l.aiPrivacyExplanation,
                    );
                    if (!ok) return;
                  }
                  await controller.update((x) => x.copyWith(aiConsent: v));
                },
              ),
              SwitchListTile(
                title: Text(l.settingsAiShareNames),
                value: p.aiShareNames,
                onChanged: p.aiConsent
                    ? (v) =>
                          controller.update((x) => x.copyWith(aiShareNames: v))
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${l.settingsAiApiKey}: ${hasKey ? l.settingsAiApiKeySet : l.settingsAiApiKeyMissing}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _key,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(hintText: l.aiApiKeyHint),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              if (_key.text.trim().length < 20) return;
                              await ref
                                  .read(aiKeyStoreProvider)
                                  .write(_key.text);
                              _key.clear();
                              ref.invalidate(aiKeyPresentProvider);
                              if (context.mounted) {
                                showAppSnack(context, l.savedMessage);
                              }
                            },
                            child: Text(l.aiApiKeySave),
                          ),
                        ),
                        if (hasKey) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await ref.read(aiKeyStoreProvider).delete();
                                ref.invalidate(aiKeyPresentProvider);
                              },
                              child: Text(l.aiApiKeyRemove),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.aiApiKeyNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
            SectionHeader(title: l.settingsAiPrivacy),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(l.aiPrivacyExplanation),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_x.dart';
import '../../../core/providers.dart';
import '../../../core/security/safe_logger.dart';
import '../../categories/data/category_repository.dart';
import '../../groups/data/group_repository.dart';
import '../../money_ledger/data/ledger_repository.dart';
import '../../people/data/people_repository.dart';
import '../../settings/application/settings_controller.dart';
import '../../transactions/data/transaction_repository.dart';
import '../data/claude_answer_service.dart';
import '../domain/local_ai_engine.dart';

@immutable
class ChatMessage {
  const ChatMessage.user(this.text)
    : fromUser = true,
      answer = null,
      onlineText = null,
      onlineFailed = false;

  const ChatMessage.assistant(
    this.answer, {
    this.onlineText,
    this.onlineFailed = false,
  }) : fromUser = false,
       text = '';

  final bool fromUser;
  final String text;
  final AiAnswer? answer;

  /// Wording from the optional online model (display only).
  final String? onlineText;
  final bool onlineFailed;
}

final localAiEngineProvider = Provider<LocalAiEngine>(
  (ref) => LocalAiEngine(
    txns: ref.watch(transactionRepositoryProvider),
    people: ref.watch(peopleRepositoryProvider),
    ledger: ref.watch(ledgerRepositoryProvider),
    groups: ref.watch(groupRepositoryProvider),
    categories: ref.watch(categoryRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Chat history lives in memory only and disappears when the app closes.
class AiChatController extends Notifier<List<ChatMessage>> {
  var _busy = false;

  @override
  List<ChatMessage> build() => const [];

  bool get busy => _busy;

  Future<void> ask(String question, AppLocalizations l) async {
    final q = question.trim();
    if (q.isEmpty || _busy) return;
    _busy = true;
    state = [...state, ChatMessage.user(q)];
    try {
      final prefs = ref.read(settingsControllerProvider);
      final fmt = ref.read(formattersProvider);
      final answer = await ref
          .read(localAiEngineProvider)
          .ask(q, l: l, fmt: fmt, shareNames: prefs.aiShareNames);
      String? online;
      var failed = false;
      final wantsOnline =
          prefs.canUseOnlineAi &&
          answer.draft == null &&
          answer.modelFacts.length > 2;
      if (wantsOnline) {
        final key = await ref.read(aiKeyStoreProvider).read();
        if (key != null && key.isNotEmpty) {
          try {
            online = await ref
                .read(claudeAnswerServiceProvider)
                .rephrase(
                  apiKey: key,
                  question: answer.redactedQuestion,
                  facts: answer.modelFacts,
                  languageCode: prefs.languageCode,
                  isSuggestion: answer.isSuggestion,
                );
          } catch (e, s) {
            SafeLogger.error('ai_online', e, s);
            failed = true;
          }
        }
      }
      state = [
        ...state,
        ChatMessage.assistant(answer, onlineText: online, onlineFailed: failed),
      ];
    } catch (e, s) {
      SafeLogger.error('ai_local', e, s);
      state = [...state, ChatMessage.assistant(AiAnswer(text: l.genericError))];
    } finally {
      _busy = false;
    }
  }

  void clear() => state = const [];
}

final aiChatControllerProvider =
    NotifierProvider<AiChatController, List<ChatMessage>>(AiChatController.new);

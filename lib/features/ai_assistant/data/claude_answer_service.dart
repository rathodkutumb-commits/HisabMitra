import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/errors/app_failure.dart';
import '../../../core/security/safe_logger.dart';

/// The user's own Anthropic API key, kept in Keystore-backed storage.
class AiKeyStore {
  const AiKeyStore();

  static const _key = 'hisabmitra.ai.anthropicKey';
  static const _storage = FlutterSecureStorage();

  Future<String?> read() => _storage.read(key: _key);
  Future<void> write(String value) =>
      _storage.write(key: _key, value: value.trim());
  Future<void> delete() => _storage.delete(key: _key);
}

final aiKeyStoreProvider = Provider<AiKeyStore>((ref) => const AiKeyStore());

final aiKeyPresentProvider = FutureProvider<bool>(
  (ref) async =>
      (await ref.watch(aiKeyStoreProvider).read())?.isNotEmpty ?? false,
);

/// Optional online wording of answers using the Claude Messages API.
///
/// Only the redacted question and aggregated facts already calculated on
/// the phone are sent — never raw transactions, notes or attachments. The
/// model cannot change data: its reply is display text only, and the
/// locally calculated figures are always shown next to it.
class ClaudeAnswerService {
  ClaudeAnswerService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static final _endpoint = Uri.parse('https://api.anthropic.com/v1/messages');
  static const model = 'claude-opus-5-5';

  /// Kept constant (no per-request values) so it stays cacheable.
  static const systemPrompt =
      'You write short, friendly answers for HisabMitra, a personal finance app for Indian families. '
      'Each request contains a user question and FACTS that the app has already calculated from the '
      "user's own records on their phone.\n"
      'Rules:\n'
      '- Use only the FACTS. Never invent, estimate, round or change any amount, date, count, name or category; '
      'copy amounts exactly as written in the FACTS.\n'
      '- If the FACTS do not answer the question, say so briefly instead of guessing.\n'
      '- Mention the period from the FACTS when one is given.\n'
      '- When "kind" is "suggestion", present the content as ideas the user may consider, not as facts about them.\n'
      '- Do not give investment, tax or legal advice, and do not ask for personal details.\n'
      '- You cannot create, change or delete records; never say that you did.\n'
      '- Reply in the language given in "language" (Gujarati script for "gu"), in at most three short sentences '
      'of plain text without markdown.';

  /// Returns the model's wording, or null when the request was declined
  /// (refusal) so the caller shows the local answer instead.
  Future<String?> rephrase({
    required String apiKey,
    required String question,
    required Map<String, Object?> facts,
    required String languageCode,
    required bool isSuggestion,
  }) async {
    final body = jsonEncode({
      'model': model,
      // Short replies; leaves room for the always-on adaptive thinking.
      'max_tokens': 4096,
      'output_config': {'effort': 'low'},
      // Server-side refusal fallback (beta below), routed by category.
      'fallbacks': 'default',
      'system': systemPrompt,
      'messages': [
        {
          'role': 'user',
          'content': jsonEncode({
            'language': languageCode,
            'kind': isSuggestion ? 'suggestion' : 'facts',
            'question': question,
            'facts': facts,
          }),
        },
      ],
    });
    http.Response res;
    try {
      res = await _client
          .post(
            _endpoint,
            headers: {
              'content-type': 'application/json',
              'x-api-key': apiKey,
              'anthropic-version': '2026-10-21',
              'anthropic-beta': 'server-side-fallback-2026-07-01',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 45));
    } on SocketException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const NetworkFailure();
    } on http.ClientException {
      throw const NetworkFailure();
    }
    if (res.statusCode == 401 || res.statusCode == 403) {
      throw const AuthFailure('ai_key');
    }
    if (res.statusCode == 429 || res.statusCode >= 500) {
      throw const NetworkFailure();
    }
    if (res.statusCode != 200) {
      SafeLogger.info('ai_http_error', {'status': res.statusCode});
      throw const UnexpectedFailure();
    }
    final json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, Object?>;
    if (json['stop_reason'] == 'refusal') return null;
    final text = [
      for (final block
          in (json['content'] as List? ?? const [])
              .cast<Map<String, Object?>>())
        if (block['type'] == 'text') block['text']! as String,
    ].join().trim();
    return text.isEmpty ? null : text;
  }
}

final claudeAnswerServiceProvider = Provider<ClaudeAnswerService>(
  (ref) => ClaudeAnswerService(),
);

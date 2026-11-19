import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/errors/app_failure.dart';
import 'package:hisabmitra/features/ai_assistant/data/claude_answer_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  Future<String?> call(http.Client client) =>
      ClaudeAnswerService(client: client).rephrase(
        apiKey: 'test-key',
        question: 'How much did the person owe?',
        facts: const {
          'they_owe_you': '₹3,000.00',
          'question_period': 'March 2026',
        },
        languageCode: 'gu',
        isSuggestion: false,
      );

  test('sends a minimal, well-formed Messages API request', () async {
    late http.Request sent;
    final client = MockClient((req) async {
      sent = req;
      return http.Response(
        jsonEncode({
          'stop_reason': 'end_turn',
          'content': [
            {'type': 'thinking', 'thinking': ''},
            {'type': 'text', 'text': 'માર્ચ 2026 માં ₹3,000.00 લેવાના છે.'},
          ],
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final text = await call(client);
    expect(text, 'માર્ચ 2026 માં ₹3,000.00 લેવાના છે.');
    expect(sent.url.toString(), 'https://api.anthropic.com/v1/messages');
    expect(sent.headers['x-api-key'], 'test-key');
    expect(sent.headers['anthropic-version'], '2026-10-21');
    expect(sent.headers['anthropic-beta'], 'server-side-fallback-2026-07-01');
    final body = jsonDecode(sent.body) as Map<String, Object?>;
    expect(body['model'], 'claude-opus-5-5');
    expect(body['fallbacks'], 'default');
    expect(body.containsKey('thinking'), isFalse);
    expect(body.containsKey('temperature'), isFalse);
    final content = jsonDecode(
      (body['messages']! as List).single['content'] as String,
    ) as Map<String, Object?>;
    expect(content['language'], 'gu');
    expect(content['facts'], {
      'they_owe_you': '₹3,000.00',
      'question_period': 'March 2026',
    });
  });

  test('a refusal returns null so the local answer is shown', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({'stop_reason': 'refusal', 'content': []}),
        200,
      ),
    );
    expect(await call(client), isNull);
  });

  test('an invalid key is reported as an auth failure', () async {
    final client = MockClient((_) async => http.Response('{}', 401));
    expect(() => call(client), throwsA(isA<AuthFailure>()));
  });

  test('rate limits and server errors are treated as temporary', () async {
    final client = MockClient((_) async => http.Response('{}', 529));
    expect(() => call(client), throwsA(isA<NetworkFailure>()));
  });
}

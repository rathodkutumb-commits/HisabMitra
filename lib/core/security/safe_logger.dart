import 'package:flutter/foundation.dart';

/// Privacy-conscious logger.
///
/// Rules (docs/PRIVACY_AND_SECURITY.md):
///  * never log OTPs, tokens, passwords, API keys, amounts, names, phone
///    numbers, notes or attachment contents;
///  * log only event names, error *types* and counts;
///  * nothing is logged in release builds.
abstract final class SafeLogger {
  static final _sensitive = RegExp(
    r'(eyJ[\w-]+\.[\w-]+\.[\w-]+)' // JWTs
    r'|(sk-[\w-]{8,})' // API keys
    r'|(\+?\d[\d\s-]{7,}\d)' // phone numbers / long digit runs
    r'|(₹\s?[\d,]+(\.\d+)?)', // amounts
  );

  static String redact(String message) =>
      message.replaceAll(_sensitive, '[redacted]');

  static void info(String event, [Map<String, Object?> context = const {}]) {
    if (!kDebugMode) return;
    debugPrint(redact('[HM] $event ${context.isEmpty ? '' : context}'));
  }

  /// Logs only the runtime type of [error]; messages may contain user data.
  static void error(String event, Object error, [StackTrace? stack]) {
    if (!kDebugMode) return;
    debugPrint('[HM][error] $event: ${error.runtimeType}');
    if (stack != null) {
      debugPrint(redact(stack.toString().split('\n').take(6).join('\n')));
    }
  }
}

/// User-presentable failures. Raw database / API exceptions are mapped to
/// one of these before reaching the UI, and the UI shows a localised
/// message (see `failure_messages.dart`). Never surface `e.toString()`.
sealed class AppFailure implements Exception {
  const AppFailure();
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(this.code);

  /// Stable code mapped to a localised message.
  final String code;
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure();
}

/// The record is referenced elsewhere (e.g. category in use).
class InUseFailure extends AppFailure {
  const InUseFailure(this.count);
  final int count;
}

class StorageFailure extends AppFailure {
  const StorageFailure();
}

class NetworkFailure extends AppFailure {
  const NetworkFailure();
}

class NotConfiguredFailure extends AppFailure {
  const NotConfiguredFailure();
}

class AuthFailure extends AppFailure {
  const AuthFailure(this.code);

  /// `name_required`, `invalid_email`, `invalid_phone`, `invalid_otp`,
  /// `otp_expired`, `link_invalid`, `no_pending`, `rate_limited`,
  /// `email_not_authorized`, `session_expired`, `unknown`.
  final String code;
}

class PermissionFailure extends AppFailure {
  const PermissionFailure();
}

class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure();
}

/// A repayment is larger than what is still owed (TD-12). The UI offers to
/// record the excess as a separate advance/credit entry instead.
class RepaymentExceedsFailure extends AppFailure {
  const RepaymentExceedsFailure(this.excessPaise);
  final int excessPaise;
}

/// A group expense split did not validate. [error] is a `SplitError` from
/// the split calculator; forms validate before saving, so this is a guard.
class SplitValidationFailure extends AppFailure {
  const SplitValidationFailure(this.error);
  final Object error;
}

/// Attachment rejected: `too_large`, `type`, or `missing` (file gone).
class AttachmentFailure extends AppFailure {
  const AttachmentFailure(this.code);
  final String code;
}

/// Backup/restore problems: `not_backup`, `password_required`,
/// `wrong_password`, `corrupt`, `newer_schema`, `db_integrity`, `io`.
class BackupFailure extends AppFailure {
  const BackupFailure(this.code);
  final String code;
}

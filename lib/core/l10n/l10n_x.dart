import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../domain/enums.dart';
import '../errors/app_failure.dart';

export '../../l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension PaymentMethodL10n on PaymentMethod {
  String label(AppLocalizations l) => switch (this) {
    PaymentMethod.cash => l.pmCash,
    PaymentMethod.upi => l.pmUpi,
    PaymentMethod.bankTransfer => l.pmBankTransfer,
    PaymentMethod.creditCard => l.pmCreditCard,
    PaymentMethod.debitCard => l.pmDebitCard,
    PaymentMethod.other => l.pmOther,
  };
}

/// Localised, non-technical message for any error reaching the UI.
String failureMessage(AppLocalizations l, Object error) {
  if (error is! AppFailure) return l.genericError;
  return switch (error) {
    ValidationFailure(:final code) => switch (code) {
      'amount' => l.validationAmount,
      'amount_positive' => l.validationAmountPositive,
      'required' => l.validationRequired,
      'phone' => l.validationPhone,
      'email' => l.validationEmail,
      'category_type' => l.errorCategoryType,
      'payment_count' => l.errorPaymentCount,
      'person_outstanding' => l.errorPersonOutstanding,
      'principal_below_repaid' => l.errorPrincipalBelowRepaid,
      'member_in_use' || 'member_self' => l.errorMemberInUse,
      'settlement_exceeds' => l.errorSettlementExceeds,
      'settlement_same_member' => l.errorSameMember,
      'group_shared' => l.errorGroupShared,
      'invalid_code' => l.errInvalidCode,
      'expired' => l.errExpiredCode,
      'already_member' => l.errAlreadyMember,
      'invitation_pending' => l.errInvitationPending,
      'forbidden' || 'invalid_member' => l.errForbidden,
      'cloud_storage' => l.errCloudStorage,
      _ => l.genericError,
    },
    NotFoundFailure() => l.errorNotFound,
    InUseFailure(:final count) => l.errorInUse(count),
    StorageFailure() => l.errorStorage,
    NetworkFailure() => l.errorNetwork,
    NotConfiguredFailure() => l.errorCloudNotConfigured,
    AuthFailure(:final code) => switch (code) {
      'invalid_otp' => l.authInvalidOtp,
      'otp_expired' => l.authOtpExpired,
      'rate_limited' => l.authRateLimited,
      'invalid_phone' => l.validationPhone,
      'invalid_email' => l.validationEmail,
      'name_required' => l.validationRequired,
      'email_not_authorized' => l.authEmailNotAuthorized,
      'link_invalid' => l.authLinkInvalid,
      'no_pending' => l.authNoPending,
      'session_expired' => l.authSessionExpired,
      _ => l.authGenericError,
    },
    PermissionFailure() => l.errorPermission,
    RepaymentExceedsFailure() => l.errorRepaymentExceeds,
    SplitValidationFailure() => l.errorSplitInvalid,
    AttachmentFailure(:final code) => switch (code) {
      'too_large' => l.attachmentTooLarge,
      'missing' => l.attachmentMissing,
      _ => l.attachmentType,
    },
    BackupFailure(:final code) => switch (code) {
      'password_required' => l.backupPasswordRequired,
      'wrong_password' => l.backupWrongPassword,
      'corrupt' => l.backupCorrupt,
      'newer_schema' => l.backupNewerSchema,
      'db_integrity' => l.backupIntegrity,
      'not_backup' => l.backupNotBackup,
      _ => l.errorStorage,
    },
    UnexpectedFailure() => l.genericError,
  };
}

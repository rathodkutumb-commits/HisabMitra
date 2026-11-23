// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutTitle => 'About HisabMitra';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutDescription =>
      'HisabMitra keeps your daily hisab, personal khata and family group expenses in your account, with a copy on your phone so it works without internet.';

  @override
  String get checkUpdates => 'Check for updates';

  @override
  String get updateUpToDate => 'You have the latest version.';

  @override
  String updateAvailable(String version) {
    return 'Version $version is available';
  }

  @override
  String get updateNotConfigured =>
      'Update checks are not set up in this build.';

  @override
  String get updateDownloadInstall => 'Download & install';

  @override
  String updateDownloading(int percent) {
    return 'Downloading… $percent%';
  }

  @override
  String get updateInstallSteps =>
      'The file was verified (checksum, package and signature). Android will now ask you to confirm the installation. Your hisab stays safe in your account and on this phone.';

  @override
  String get updateAllowInstall =>
      'Allow HisabMitra to install updates in the next screen, then tap Download & install again.';

  @override
  String get updateNoChecksum =>
      'This release has no published checksum, so it cannot be installed from inside the app. Open the release page instead.';

  @override
  String get updateChecksumMismatch =>
      'The downloaded file did not match its published checksum and was deleted.';

  @override
  String get updateWrongPackage =>
      'The downloaded file is not a HisabMitra update.';

  @override
  String get updateNotNewer =>
      'The downloaded version is not newer than the installed one.';

  @override
  String get updateSignatureMismatch =>
      'The update is not signed with the same key as this app, so Android would refuse it. Install it manually from the release page only if you trust the source.';

  @override
  String get updateUnreadable => 'The downloaded file could not be read.';

  @override
  String get releaseNotes => 'Release notes';

  @override
  String get openWebsite => 'HisabMitra website';

  @override
  String get shareApp => 'Share HisabMitra';

  @override
  String get shareAppText =>
      '📒 *HisabMitra — Smart Hisab, Happy Family*\n\nI keep my family\'s hisab in HisabMitra:\n✅ Daily income and expenses\n🤝 Money given and taken (khata)\n👨‍👩‍👧 Family and trip expense splitting\n📊 Reports in English and ગુજરાતી';

  @override
  String get licenses => 'Open-source licences';

  @override
  String get privacySummary =>
      'Your personal records, people, khata, reminders and bills are saved to your HisabMitra account, and only you can see them. Group expenses are shared with that group\'s members. Your phone keeps a copy so the app works offline; signing out removes it. Optional online AI receives summary figures only after your consent. No advertising or tracking SDKs are included.';

  @override
  String get termsSummary =>
      'HisabMitra is a record-keeping tool. Please check important figures yourself; it does not provide financial, tax or legal advice.';

  @override
  String shareAppDownload(String url) {
    return '📲 Download free: $url';
  }

  @override
  String get aiTitle => 'HisabMitra assistant';

  @override
  String get aiDisabledTitle => 'The assistant is off';

  @override
  String get aiDisabledBody =>
      'Turn it on to ask questions about your hisab. Answers are calculated on this phone.';

  @override
  String get aiEnable => 'Turn on';

  @override
  String get aiInputHint => 'Ask about your money…';

  @override
  String get aiCalculatedOnPhone => 'Calculated on this phone';

  @override
  String get aiSuggestionBadge => 'Suggestion — not your data';

  @override
  String get aiOnlineBadge => 'Worded by online AI';

  @override
  String aiPeriodLabel(String period) {
    return 'Period: $period';
  }

  @override
  String get aiReviewDraft => 'Review & save';

  @override
  String get aiDraftNote => 'Nothing is saved until you check and save it.';

  @override
  String get aiOnlineFailed =>
      'Online AI is unavailable, so this answer was written on your phone.';

  @override
  String get aiExample1 => 'How much did I spend this month?';

  @override
  String get aiExample2 => 'What is my biggest expense category?';

  @override
  String get aiExample3 => 'Compare this month with last month';

  @override
  String get aiExample4 => 'Show my top five expenses';

  @override
  String get aiExample5 => 'How much do people owe me?';

  @override
  String get aiExample6 => 'How can I reduce my expenses?';

  @override
  String get aiHelp =>
      'I can answer questions about your own records, for example: spending or income in a period, your biggest category, top expenses, how much a person owes you, what a group trip cost, or who owes whom in a group. Try one of the suggestions below.';

  @override
  String aiSpend(String amount, String period, int count) {
    return 'You spent $amount in $period across $count entries.';
  }

  @override
  String aiIncome(String amount, String period) {
    return 'Your income in $period was $amount.';
  }

  @override
  String aiSavings(
    String period,
    String income,
    String expense,
    String savings,
  ) {
    return 'In $period you earned $income and spent $expense, so you saved $savings.';
  }

  @override
  String aiTopCategory(
    String period,
    String category,
    String amount,
    String percent,
  ) {
    return 'Your biggest expense category in $period was $category: $amount ($percent% of spending).';
  }

  @override
  String aiNoExpenses(String period) {
    return 'There are no expenses recorded in $period.';
  }

  @override
  String aiPersonOwesYou(String name, String amount) {
    return '$name owes you $amount in total (all open khata entries).';
  }

  @override
  String aiYouOwePerson(String name, String amount) {
    return 'You owe $name $amount in total (all open khata entries).';
  }

  @override
  String aiPersonSettled(String name) {
    return 'You and $name are all settled — nothing is pending.';
  }

  @override
  String aiGroupTotal(String group, String amount, int count, String share) {
    return '$group has cost $amount so far across $count expenses. Your share is $share.';
  }

  @override
  String aiWhoOwesNone(String group) {
    return 'Everyone in $group is settled up.';
  }

  @override
  String aiWhoOwesIntro(String group) {
    return 'To settle $group:';
  }

  @override
  String aiCompare(
    String current,
    String currentAmount,
    String previous,
    String previousAmount,
    String change,
  ) {
    return '$current: spent $currentAmount. $previous: spent $previousAmount. That is $change.';
  }

  @override
  String aiMore(String amount) {
    return '$amount more';
  }

  @override
  String aiLess(String amount) {
    return '$amount less';
  }

  @override
  String get aiSame => 'the same';

  @override
  String aiTopExpensesIntro(String period) {
    return 'Your top expenses in $period:';
  }

  @override
  String aiReceivables(String receivable, String payable) {
    return 'People owe you $receivable and you owe others $payable (all open khata entries).';
  }

  @override
  String aiTipsIntro(String period) {
    return 'Based on $period, a few ideas (suggestions, not facts):';
  }

  @override
  String aiTipCategory(String category, String percent, String amount) {
    return '$category took $percent% of your spending ($amount). Setting a monthly limit for it would have the biggest effect.';
  }

  @override
  String aiTipFrequent(int count, String amount) {
    return 'You made $count small expenses under ₹200 — together $amount. Small daily spends add up.';
  }

  @override
  String get aiTipSavings =>
      'You spent more than you earned this period. Reviewing the top categories first usually helps most.';

  @override
  String get aiTipGeneral =>
      'Record every expense for a month, then compare months here to see what changed.';

  @override
  String aiDraftExpense(String amount, String category) {
    return 'I prepared an expense of $amount$category. Please review it before saving.';
  }

  @override
  String aiDraftIncome(String amount, String category) {
    return 'I prepared an income entry of $amount$category. Please review it before saving.';
  }

  @override
  String get aiDraftNeedsAmount =>
      'Tell me the amount too, for example: “add expense 250 for groceries”. I will not guess amounts.';

  @override
  String get aiNoPerson => 'I could not find that person in your khata.';

  @override
  String get aiNoGroup => 'I could not find that group.';

  @override
  String get aiTodayLabel => 'today';

  @override
  String get aiSettingsTitle => 'AI assistant settings';

  @override
  String get aiApiKeySave => 'Save key';

  @override
  String get aiApiKeyRemove => 'Remove key';

  @override
  String get aiApiKeyHint => 'Paste your Anthropic API key';

  @override
  String get aiApiKeyNote =>
      'The key is stored encrypted on this phone and is used only for online answers. Online usage is billed to your Anthropic account.';

  @override
  String get aiOpenAssistant => 'Ask HisabMitra AI';

  @override
  String get aiExamplesSpending => 'Spending';

  @override
  String get aiExamplesIncome => 'Income & savings';

  @override
  String get aiExamplesKhata => 'Khata';

  @override
  String get aiExamplesGroups => 'Groups';

  @override
  String get aiExamplesAdd => 'Add an entry';

  @override
  String get aiExample7 => 'How much did I spend today?';

  @override
  String get aiExample8 => 'How much did I spend last month?';

  @override
  String get aiExample9 => 'What is my income this month?';

  @override
  String get aiExample10 => 'What was my income last month?';

  @override
  String get aiExample11 => 'What are my savings this month?';

  @override
  String get aiExample12 => 'What are my savings this year?';

  @override
  String get aiExample13 => 'Add 250 for groceries';

  @override
  String get aiExample14 => 'Add salary 25000';

  @override
  String get aiExample15 => 'Add 500 for fuel';

  @override
  String aiExamplePerson(String name) {
    return 'What is my balance with $name?';
  }

  @override
  String aiExampleGroupTotal(String group) {
    return 'How much did $group cost?';
  }

  @override
  String aiExampleGroupOwes(String group) {
    return 'Who owes whom in $group?';
  }

  @override
  String get attachments => 'Bills & attachments';

  @override
  String get attachCamera => 'Camera';

  @override
  String get attachGallery => 'Gallery';

  @override
  String get attachPdf => 'PDF';

  @override
  String get attachmentTooLarge => 'This file is larger than 10 MB.';

  @override
  String get attachmentType =>
      'Only JPG, PNG, WEBP, HEIC images and PDF files can be attached.';

  @override
  String get attachmentMissing =>
      'This file is no longer available on the phone.';

  @override
  String get attachmentOpenExternal => 'Open in another app';

  @override
  String get attachmentDeleteConfirm => 'Remove this attachment?';

  @override
  String get attachmentViewerTitle => 'Attachment';

  @override
  String get attachmentPrivateNote => 'Saved to your HisabMitra account.';

  @override
  String get attachmentShareToGroup => 'Share with group';

  @override
  String get attachmentSharedToGroup => 'Shared with group';

  @override
  String get attachmentRemove => 'Remove';

  @override
  String get photoRecovered =>
      'We saved the photo you took. Add it to a new expense?';

  @override
  String get photoRecoveredAction => 'Add expense';

  @override
  String get attachmentDownloadRetry =>
      'Couldn\'t load this bill. Check your internet and try again.';

  @override
  String get backupTitle => 'Backup & restore';

  @override
  String get backupNow => 'Back up now';

  @override
  String get backupEncrypt => 'Protect with a password';

  @override
  String get backupPassword => 'Backup password';

  @override
  String get backupPasswordConfirm => 'Confirm password';

  @override
  String get backupPasswordMismatch => 'Passwords do not match';

  @override
  String get backupPasswordTooShort => 'Use at least 8 characters';

  @override
  String get backupPasswordWarning =>
      'HisabMitra does not store this password. Without it, this backup cannot be restored.';

  @override
  String get backupCreated => 'Backup created';

  @override
  String get backupHistory => 'Backup history';

  @override
  String get backupNone => 'No backups yet';

  @override
  String get backupKindManual => 'Manual';

  @override
  String get backupKindAutomatic => 'Automatic';

  @override
  String get backupKindSafety => 'Before restore';

  @override
  String get backupEncryptedLabel => 'Encrypted';

  @override
  String get backupExport => 'Save / share copy';

  @override
  String get backupRestore => 'Restore';

  @override
  String get backupRestoreFromFile => 'Restore from a file';

  @override
  String get backupRestoreConfirmTitle => 'Replace current data?';

  @override
  String backupRestoreConfirmBody(
    String date,
    int transactions,
    int people,
    int groups,
  ) {
    return 'This backup from $date contains $transactions entries, $people people and $groups groups. Your current data will be replaced. A safety backup of your current data is made first.';
  }

  @override
  String get backupRestoreDone => 'Restore complete';

  @override
  String backupRestoreMissingAttachments(int count) {
    return '$count attachment files were not in the backup.';
  }

  @override
  String get backupWhere =>
      'Your hisab is saved in your account. A backup is an extra copy, stored privately in HisabMitra\'s app storage on this phone; uninstalling the app deletes it, so use “Save / share copy” to keep it elsewhere (for example Google Drive or a computer).';

  @override
  String get backupFileMissing => 'File no longer on this phone';

  @override
  String get backupDeleteConfirm => 'Delete this backup file?';

  @override
  String get backupPasswordRequired =>
      'This backup is encrypted. Enter its password.';

  @override
  String get backupWrongPassword => 'Wrong password, or the file is damaged.';

  @override
  String get backupCorrupt =>
      'The backup file is damaged or was modified, so it cannot be restored.';

  @override
  String get backupNewerSchema =>
      'This backup was made by a newer version of HisabMitra. Update the app first.';

  @override
  String get backupIntegrity =>
      'The data inside the backup failed its integrity check.';

  @override
  String get backupNotBackup => 'This file is not a HisabMitra backup.';

  @override
  String shareBackupCaption(String date) {
    return '🔒 *HisabMitra backup* · $date — keep this file safe; you\'ll need your backup password to restore it.';
  }

  @override
  String shareBackupCaptionPlain(String date) {
    return '🔒 *HisabMitra backup* · $date — keep this file safe.';
  }

  @override
  String get restoreNeedsInternet => 'Connect to the internet to restore.';

  @override
  String get restoreReplacesAccount =>
      'This replaces the hisab saved in your account with this backup. Groups are not changed.';

  @override
  String get authSendOtp => 'Send verification code';

  @override
  String get authVerify => 'Verify';

  @override
  String get authResend => 'Resend code';

  @override
  String authResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get authCodeSent => 'Code sent';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileName => 'Display name';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get deleteAccountConfirm =>
      'Delete your account? Your saved hisab, bills and group memberships are deleted from the account and from this phone. This cannot be undone.';

  @override
  String get accountDeleted => 'Cloud account deleted';

  @override
  String get signedOut => 'Signed out';

  @override
  String get syncTitle => 'Sync status';

  @override
  String get syncNow => 'Sync now';

  @override
  String syncLastSuccess(String date) {
    return 'Last synced $date';
  }

  @override
  String get syncNever => 'Not synced yet';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting to sync',
      one: '1 change waiting to sync',
      zero: 'Everything is up to date',
    );
    return '$_temp0';
  }

  @override
  String syncFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes could not be synced',
      one: '1 change could not be synced',
    );
    return '$_temp0';
  }

  @override
  String get syncRetry => 'Retry';

  @override
  String get syncConflicts => 'Needs your decision';

  @override
  String get syncConflictHelp =>
      'This record was changed on another device while you were also changing it. Nothing has been overwritten — choose which version to keep.';

  @override
  String get syncKeepMine => 'Keep mine';

  @override
  String get syncKeepTheirs => 'Use the other version';

  @override
  String get syncYourVersion => 'Your version';

  @override
  String get syncOtherVersion => 'Other device\'s version';

  @override
  String get syncOffline =>
      'Offline — changes will sync when you are back online.';

  @override
  String get syncSignInNeeded => 'Sign in to sync shared groups.';

  @override
  String get syncDone => 'Sync complete';

  @override
  String get syncRunning => 'Syncing…';

  @override
  String get entityGroup => 'Group details';

  @override
  String get entityMember => 'Member';

  @override
  String get entityExpense => 'Expense';

  @override
  String get entitySettlement => 'Settlement';

  @override
  String get inviteTitle => 'Invite members';

  @override
  String get inviteFor => 'Invite for';

  @override
  String get inviteNewMember => 'Someone new';

  @override
  String get inviteCreate => 'Create invitation code';

  @override
  String inviteShareText(String group, String code, String date) {
    return '👋 *Join my group on HisabMitra!*\n\n👥 Group: *$group*\n🔑 Invite code: *$code*\n\nOpen HisabMitra → Groups → Join a group, and enter the code.\n\n⏳ The code is valid till *$date*.';
  }

  @override
  String inviteShareTextLink(
    String group,
    String code,
    String link,
    String date,
  ) {
    return '👋 *Join my group on HisabMitra!*\n\n👥 Group: *$group*\n🔑 Invite code: *$code*\n\n👉 Tap to join: $link\nOr open HisabMitra → Groups → Join a group, and enter the code.\n\n⏳ The code is valid till *$date*.';
  }

  @override
  String inviteExpires(String date) {
    return 'Expires $date';
  }

  @override
  String get inviteStatusPending => 'Waiting';

  @override
  String get inviteStatusAccepted => 'Joined';

  @override
  String get inviteStatusCancelled => 'Cancelled';

  @override
  String get inviteStatusExpired => 'Expired';

  @override
  String get inviteCancel => 'Cancel invitation';

  @override
  String get invitesEmpty => 'No invitations yet';

  @override
  String get inviteCodeOnce =>
      'Share this code now. For security it is shown only once.';

  @override
  String get joinTitle => 'Join with a code';

  @override
  String get joinCode => 'Invitation code';

  @override
  String get joinButton => 'Join';

  @override
  String joinDone(String group) {
    return 'You joined $group';
  }

  @override
  String get joinNeedsSignIn => 'Verify your email to join a shared group.';

  @override
  String get errInvalidCode => 'This invitation code is not valid.';

  @override
  String get errExpiredCode =>
      'This invitation has expired. Ask for a new one.';

  @override
  String get errAlreadyMember => 'You are already a member of this group.';

  @override
  String get errInvitationPending =>
      'There is already an open invitation for this member.';

  @override
  String get errForbidden => 'You do not have permission to do this.';

  @override
  String get errCloudStorage => 'Could not upload or download the file.';

  @override
  String get emailAddress => 'Email address';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get verifyEmailTitle => 'Verify your email';

  @override
  String verifyEmailSubtitle(String email) {
    return 'We sent a code to $email. Type it below, or tap the link in that email on this phone.';
  }

  @override
  String get verificationCode => 'Verification code';

  @override
  String get verifyEmailSpamHint =>
      'Didn\'t get it? Look in Spam or Promotions, or resend after a minute.';

  @override
  String get changeDetails => 'Change details';

  @override
  String get emailVerified => 'Email verified. Welcome to HisabMitra!';

  @override
  String get verifyingLink => 'Checking the link…';

  @override
  String get authEmailNotAuthorized =>
      'We can\'t send email to this address yet: the app\'s email sender is not set up. Please try again later.';

  @override
  String get authLinkInvalid =>
      'This link has expired or was opened on another phone. Type the code instead, or send a new one.';

  @override
  String get authNoPending => 'Please enter your details again.';

  @override
  String get accountOfflineNote =>
      'This build has no cloud connection, so your email cannot be verified now. Your details are saved on this phone.';

  @override
  String accountVerifiedAs(String email) {
    return 'Verified: $email';
  }

  @override
  String get verifyEmailAction => 'Verify email';

  @override
  String inviteShareDownload(String url) {
    return '📲 Don\'t have the app? Download it free: $url';
  }

  @override
  String get entityPerson => 'Person';

  @override
  String get entityTransaction => 'Income or expense';

  @override
  String get entityLedgerEntry => 'Khata entry';

  @override
  String get entityRepayment => 'Repayment';

  @override
  String get entityReminder => 'Reminder';

  @override
  String get entityBill => 'Bill';

  @override
  String get inviteSampleGroup => 'Sample groups cannot be shared.';

  @override
  String get accountSyncUploadTitle => 'Saving your hisab to your account';

  @override
  String get accountSyncDownloadTitle => 'Getting your hisab';

  @override
  String accountSyncProgress(String done, String total) {
    return '$done of $total';
  }

  @override
  String get accountSyncOffline =>
      'No internet. Your hisab will be saved to your account when you\'re back online.';

  @override
  String get accountSyncContinue => 'Continue in background';

  @override
  String get appName => 'HisabMitra';

  @override
  String get appNameGujarati => 'હિસાબમિત્ર';

  @override
  String get appTagline => 'Smart Hisab, Happy Family.';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get clear => 'Clear';

  @override
  String get apply => 'Apply';

  @override
  String get share => 'Share';

  @override
  String get export => 'Export';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get loading => 'Loading…';

  @override
  String get optional => 'Optional';

  @override
  String get notes => 'Notes';

  @override
  String get description => 'Description';

  @override
  String get date => 'Date';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get person => 'Person';

  @override
  String get total => 'Total';

  @override
  String get viewAll => 'View all';

  @override
  String get none => 'None';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get balance => 'Balance';

  @override
  String get details => 'Details';

  @override
  String get more => 'More';

  @override
  String get selectDate => 'Select date';

  @override
  String createdOn(String date) {
    return 'Created $date';
  }

  @override
  String updatedOn(String date) {
    return 'Updated $date';
  }

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get savedMessage => 'Saved';

  @override
  String get deletedMessage => 'Deleted';

  @override
  String get confirmDeleteTitle => 'Delete this?';

  @override
  String get confirmDeleteMessage => 'This cannot be undone.';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesMessage => 'Your unsaved changes will be lost.';

  @override
  String get discard => 'Discard';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get offlineBanner =>
      'You are offline. Your changes are saved on this phone and will reach your account when you are back online.';

  @override
  String get pmCash => 'Cash';

  @override
  String get pmUpi => 'UPI';

  @override
  String get pmBankTransfer => 'Bank transfer';

  @override
  String get pmCreditCard => 'Credit card';

  @override
  String get pmDebitCard => 'Debit card';

  @override
  String get pmOther => 'Other';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationAmount => 'Enter a valid amount (up to 2 decimals)';

  @override
  String get validationAmountPositive => 'Amount must be more than zero';

  @override
  String get validationPhone => 'Enter a valid mobile number';

  @override
  String get validationEmail => 'Enter a valid email address';

  @override
  String validationTooLong(int max) {
    return 'Too long (maximum $max characters)';
  }

  @override
  String get openCalculator => 'Open calculator';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get comingFromDate => 'From';

  @override
  String get toDate => 'To';

  @override
  String get periodThisMonth => 'This month';

  @override
  String get periodLastMonth => 'Last month';

  @override
  String get periodThisYear => 'This year';

  @override
  String get periodCustom => 'Custom range';

  @override
  String get notConfigured => 'Not configured';

  @override
  String get privateOnDevice => 'Private · saved to your account';

  @override
  String get exitAppTitle => 'Exit HisabMitra?';

  @override
  String get exitAppConfirm => 'Exit';

  @override
  String get exitAppStay => 'Stay';

  @override
  String get errorNotFound => 'This record no longer exists.';

  @override
  String errorInUse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'It is used by $count records.',
      one: 'It is used by 1 record.',
    );
    return '$_temp0';
  }

  @override
  String get errorStorage =>
      'Could not save to phone storage. Check free space and try again.';

  @override
  String get errorNetwork =>
      'No internet connection. Your change is saved on this phone and will sync later.';

  @override
  String get errorCloudNotConfigured =>
      'Cloud features are not set up in this build of the app.';

  @override
  String get errorPermission => 'Permission was not granted.';

  @override
  String get authInvalidOtp =>
      'That code is not correct. Please check and try again.';

  @override
  String get authOtpExpired => 'The code has expired. Request a new one.';

  @override
  String get authRateLimited =>
      'Too many attempts. Please wait a minute and try again.';

  @override
  String get authSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get authGenericError =>
      'Could not sign in right now. Please try again.';

  @override
  String get errorPaymentCount =>
      'The number of payments must be more than those already paid.';

  @override
  String familyPersonRemoved(String name) {
    return '$name (removed)';
  }

  @override
  String get entityFamily => 'Family hisab details';

  @override
  String get entityFamilyPerson => 'Person in Family hisab';

  @override
  String get entityFamilyEntry => 'Family hisab entry';

  @override
  String get familyHisab => 'Family hisab';

  @override
  String get familyHisabs => 'Family hisabs';

  @override
  String get familyButton => 'Family';

  @override
  String get familyMoreSubtitle =>
      'Home money together: salaries, contributions and expenses';

  @override
  String get familyCreate => 'Create Family hisab';

  @override
  String get familyEdit => 'Edit Family hisab';

  @override
  String get familyNew => 'New Family hisab';

  @override
  String get familyDelete => 'Delete Family hisab';

  @override
  String get familyDeleteMessage =>
      'Its people and every entry are deleted from the account.';

  @override
  String get familyEmptyTitle => 'Keep the home\'s hisab together';

  @override
  String get familyEmptyMessage =>
      'Add everyone\'s salary and contributions, write down every home expense and get a passbook statement every month.';

  @override
  String get familyName => 'Name';

  @override
  String get familyNameHint => 'e.g. Home';

  @override
  String get familyStartingBalance => 'Starting balance (optional)';

  @override
  String get familyStartingBalanceHelp => 'Money already in the home today';

  @override
  String get familyPeople => 'People';

  @override
  String get familyPersonName => 'Person\'s name';

  @override
  String get familyAddPerson => 'Add person';

  @override
  String get familyEditPerson => 'Edit person';

  @override
  String get familyDeletePerson => 'Delete person';

  @override
  String familyDeletePersonMessage(String name) {
    return 'Their entries stay in the hisab and show as \"$name (removed)\".';
  }

  @override
  String get familyHasApp => 'Has the app';

  @override
  String get familyNotJoined => 'Not joined';

  @override
  String familyShowRemoved(int count) {
    return 'Show removed ($count)';
  }

  @override
  String get familyHideRemoved => 'Hide removed';

  @override
  String get familySaved => 'Family hisab saved';

  @override
  String get familyPersonSaved => 'Person saved';

  @override
  String get familyPersonDeleted => 'Person deleted. Their entries stay.';

  @override
  String get familyNoEntriesYet => 'No entries this month yet';

  @override
  String get familyOpening => 'Opening balance';

  @override
  String get familyClosing => 'Closing balance';

  @override
  String get familyMoneyIn => 'Money in';

  @override
  String get familyMoneyOut => 'Money out';

  @override
  String get familyAddMoneyIn => 'Add money in';

  @override
  String get familyAddMoneyOut => 'Add money out';

  @override
  String get familyEditMoneyIn => 'Edit money in';

  @override
  String get familyEditMoneyOut => 'Edit money out';

  @override
  String get familyKindSalary => 'Salary';

  @override
  String get familyKindExtraIncome => 'Extra income';

  @override
  String get familyKindContribution => 'Contribution';

  @override
  String get familyPerson => 'Person';

  @override
  String get familyKind => 'Type';

  @override
  String get familyDoubleCountNote =>
      'Money here already counts on your Home screen — don\'t add your salary again in Hisab.';

  @override
  String get familyEntrySaved => 'Entry saved';

  @override
  String get familyEntryDeleted => 'Entry deleted';

  @override
  String get familyPreviousMonth => 'Previous month';

  @override
  String get familyNextMonth => 'Next month';

  @override
  String get familyStatement => 'Statement';

  @override
  String get familyStatementTitle => 'Family hisab statement';

  @override
  String get familyByPerson => 'By person';

  @override
  String get familyPaidForHome => 'Paid for home';

  @override
  String familyPersonLine(String name, String moneyIn, String paid) {
    return '$name — in $moneyIn · paid $paid';
  }

  @override
  String familySendWhatsApp(String name) {
    return 'Send on WhatsApp to $name';
  }

  @override
  String get familyMoneyInCredit => 'Money in (credit)';

  @override
  String get familyMoneyOutDebit => 'Money out (debit)';

  @override
  String familyIncludesLine(String moneyIn, String moneyOut) {
    return 'Includes Family hisab: in $moneyIn · out $moneyOut';
  }

  @override
  String get familyInvite => 'Invite';

  @override
  String get familyInviteTitle => 'Invite to Family hisab';

  @override
  String get familyMakeAdmin => 'Make admin';

  @override
  String get familyRemoveAdmin => 'Remove admin';

  @override
  String familyNowAdmin(String name) {
    return '$name is now an admin';
  }

  @override
  String familyNowMember(String name) {
    return '$name is now a member';
  }

  @override
  String get familyJoinWithCode => 'Join with a code';

  @override
  String familyInviteShareText(String family, String code, String date) {
    return '👋 *Join our Family hisab on HisabMitra!*\n\n🏠 Family hisab: *$family*\n🔑 Invite code: *$code*\n\nOpen HisabMitra → More → Family hisab → Join with a code, and enter the code.\n\n⏳ The code is valid till *$date*.';
  }

  @override
  String familyInviteShareTextLink(
    String family,
    String code,
    String link,
    String date,
  ) {
    return '👋 *Join our Family hisab on HisabMitra!*\n\n🏠 Family hisab: *$family*\n🔑 Invite code: *$code*\n\n👉 Tap to join: $link\nOr open HisabMitra → More → Family hisab → Join with a code, and enter the code.\n\n⏳ The code is valid till *$date*.';
  }

  @override
  String greeting(String name) {
    return 'Namaste, $name';
  }

  @override
  String get greetingNoName => 'Namaste!';

  @override
  String get dashboardBalanceLabel => 'Savings this period';

  @override
  String get dashboardToReceive => 'To receive';

  @override
  String get dashboardToPay => 'To pay';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get actionAddIncome => 'Add income';

  @override
  String get actionAddExpense => 'Add expense';

  @override
  String get actionGiveMoney => 'Give money';

  @override
  String get actionReceiveMoney => 'Receive money';

  @override
  String get actionCreateGroup => 'Create group';

  @override
  String get actionGroupExpense => 'Group expense';

  @override
  String get actionReports => 'Reports';

  @override
  String get incomeVsExpense => 'Income vs expense';

  @override
  String get lastSixMonths => 'Last 6 months';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get pendingRepayments => 'Pending repayments';

  @override
  String get upcomingReminders => 'Upcoming reminders';

  @override
  String get groupSummaryTitle => 'Your groups';

  @override
  String groupSummaryLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active groups',
      one: '1 active group',
      zero: 'No active groups',
    );
    return '$_temp0';
  }

  @override
  String get youOwe => 'You owe';

  @override
  String get youAreOwed => 'You are owed';

  @override
  String get welcomeEmptyTitle => 'Let\'s start your hisab';

  @override
  String get welcomeEmptyBody =>
      'Add your first expense or income. It takes just a few seconds.';

  @override
  String get noTransactionsTitle => 'No entries yet';

  @override
  String get noTransactionsBody =>
      'Entries you add will appear here, grouped by date.';

  @override
  String get noResultsTitle => 'Nothing matches';

  @override
  String get noResultsBody => 'Try a different search or clear the filters.';

  @override
  String get selectPickPeriod => 'Choose period';

  @override
  String get transactionsTitle => 'Hisab';

  @override
  String get searchTransactionsHint =>
      'Search description, notes, category, person';

  @override
  String get filterAll => 'All';

  @override
  String get filterType => 'Type';

  @override
  String get filterClearAll => 'Clear filters';

  @override
  String get addIncomeTitle => 'Add income';

  @override
  String get addExpenseTitle => 'Add expense';

  @override
  String get editTransactionTitle => 'Edit entry';

  @override
  String get transactionDetailsTitle => 'Entry details';

  @override
  String get amountHint => '0.00';

  @override
  String get descriptionHint => 'e.g. Vegetables from market';

  @override
  String get personOptional => 'Person (optional)';

  @override
  String get addNewPerson => 'Add new person';

  @override
  String get manageCategories => 'Manage';

  @override
  String get chooseCategory => 'Choose a category';

  @override
  String get transactionSaved => 'Entry saved';

  @override
  String get transactionDeleted => 'Entry deleted';

  @override
  String get deleteTransactionMessage =>
      'This entry and its attachments will be deleted from your account and this phone.';

  @override
  String dayNet(String amount) {
    return 'Net $amount';
  }

  @override
  String get monthIncomeShort => 'In';

  @override
  String get monthExpenseShort => 'Out';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get addCategory => 'Add category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryNameEnglish => 'Name (English)';

  @override
  String get categoryNameGujarati => 'Name (Gujarati)';

  @override
  String get categoryIcon => 'Icon';

  @override
  String get categoryColor => 'Colour';

  @override
  String get categoryType => 'Type';

  @override
  String categoryUsage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Used in $count entries',
      one: 'Used in 1 entry',
      zero: 'Not used yet',
    );
    return '$_temp0';
  }

  @override
  String get categoryDeleteInUseTitle => 'Move entries before deleting';

  @override
  String categoryDeleteInUseBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries use this category.',
      one: '1 entry uses this category.',
    );
    return '$_temp0 Choose where to move them.';
  }

  @override
  String get categoryMoveAndDelete => 'Move & delete';

  @override
  String get calculatorTitle => 'Calculator';

  @override
  String get calculatorBasic => 'Calculator';

  @override
  String get calculatorUnit => 'Price × Qty';

  @override
  String get unitPrice => 'Unit price';

  @override
  String get quantity => 'Quantity';

  @override
  String calculatorUseAmount(String amount) {
    return 'Use $amount';
  }

  @override
  String get calculatorInvalid => 'Incomplete expression';

  @override
  String get calculatorCopy => 'Copy result';

  @override
  String get copied => 'Copied';

  @override
  String get catFood => 'Food & Dining';

  @override
  String get catGroceries => 'Groceries';

  @override
  String get catTransport => 'Transport';

  @override
  String get catFuel => 'Fuel';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catBills => 'Bills & Utilities';

  @override
  String get catRent => 'Rent';

  @override
  String get catHealth => 'Health';

  @override
  String get catEducation => 'Education';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catTravel => 'Travel';

  @override
  String get catFestivals => 'Festivals & Gifts';

  @override
  String get catHousehold => 'Household';

  @override
  String get catMobile => 'Mobile & Internet';

  @override
  String get catPersonalCare => 'Personal Care';

  @override
  String get catDonation => 'Donation';

  @override
  String get catOtherExpense => 'Other Expense';

  @override
  String get catSalary => 'Salary';

  @override
  String get catBusiness => 'Business';

  @override
  String get catFreelance => 'Freelance';

  @override
  String get catInterest => 'Interest';

  @override
  String get catRentalIncome => 'Rental Income';

  @override
  String get catGiftsReceived => 'Gifts Received';

  @override
  String get catRefund => 'Refunds';

  @override
  String get catOtherIncome => 'Other Income';

  @override
  String get errorRepaymentExceeds =>
      'The amount is more than what is still due.';

  @override
  String get errorSplitInvalid => 'The split does not add up to the total.';

  @override
  String get errorCategoryType => 'Choose a category of the same type.';

  @override
  String get errorPersonOutstanding =>
      'Settle all pending amounts with this person before deleting.';

  @override
  String get errorPrincipalBelowRepaid =>
      'The amount cannot be less than what has already been repaid.';

  @override
  String get errorMemberInUse =>
      'This member has expenses or settlements, so they cannot be removed.';

  @override
  String get errorSettlementExceeds =>
      'This is more than the payer owes or the receiver is owed.';

  @override
  String get errorSameMember => 'Payer and receiver must be different.';

  @override
  String get errorGroupShared =>
      'Shared groups cannot be deleted. Archive it instead.';

  @override
  String get transactionsShowList => 'Show as list';

  @override
  String get transactionsShowSheet => 'Show as sheet';

  @override
  String get runningBalance => 'Running balance';

  @override
  String get sheetTip => 'Oldest first, like a khata. Tap a row to open it.';

  @override
  String get groupsTitle => 'Groups';

  @override
  String get createGroup => 'Create group';

  @override
  String get editGroup => 'Edit group';

  @override
  String get groupName => 'Group name';

  @override
  String get groupNameHint => 'e.g. Goa trip 2026';

  @override
  String get groupType => 'Group type';

  @override
  String get groupTypeTrip => 'Trip';

  @override
  String get groupTypeFamily => 'Family';

  @override
  String get groupTypeFriends => 'Friends';

  @override
  String get groupTypeEvent => 'Event';

  @override
  String get groupTypeHousehold => 'Household';

  @override
  String get groupTypeOther => 'Other';

  @override
  String get groupMembers => 'Members';

  @override
  String get addMember => 'Add member';

  @override
  String get memberName => 'Member name';

  @override
  String memberYou(String name) {
    return '$name (you)';
  }

  @override
  String get fromPeople => 'From people';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get totalSpent => 'Total spent';

  @override
  String get yourBalance => 'Your balance';

  @override
  String get showArchived => 'Show archived';

  @override
  String get archived => 'Archived';

  @override
  String get archiveGroup => 'Archive group';

  @override
  String get unarchiveGroup => 'Restore group';

  @override
  String get deleteGroup => 'Delete group';

  @override
  String get deleteGroupMessage =>
      'This group and all its expenses will be deleted from this phone.';

  @override
  String get noGroupsTitle => 'No groups yet';

  @override
  String get noGroupsBody =>
      'Create a group for a trip, family or event and split expenses fairly.';

  @override
  String get groupSaved => 'Group saved';

  @override
  String get groupExpenses => 'Expenses';

  @override
  String get groupBalances => 'Balances';

  @override
  String get addGroupExpense => 'Add expense';

  @override
  String get editGroupExpense => 'Edit expense';

  @override
  String get groupExpenseDetail => 'Expense details';

  @override
  String get paidBy => 'Paid by';

  @override
  String paidByName(String name) {
    return 'Paid by $name';
  }

  @override
  String get splitMethod => 'Split method';

  @override
  String get splitEqual => 'Equally';

  @override
  String get splitExact => 'Exact amounts';

  @override
  String get splitPercentage => 'Percentages';

  @override
  String get splitRatio => 'Ratio / shares';

  @override
  String get splitAdjustment => 'Unequal (+/−)';

  @override
  String get splitEqualHelp => 'Split equally among the selected people.';

  @override
  String get splitExactHelp =>
      'Enter how much each person owes. It must add up to the total.';

  @override
  String get splitPercentageHelp =>
      'Enter a percentage for each person. It must add up to 100%.';

  @override
  String get splitRatioHelp =>
      'Enter shares, e.g. 2 for a couple and 1 for a single person.';

  @override
  String get splitAdjustmentHelp =>
      'Equal split, plus or minus an extra amount for some people.';

  @override
  String get participants => 'Split between';

  @override
  String get selectAll => 'Select all';

  @override
  String get splitPreview => 'Split preview';

  @override
  String splitRemaining(String amount) {
    return 'Remaining $amount';
  }

  @override
  String splitOver(String amount) {
    return 'Over by $amount';
  }

  @override
  String percentTotal(String percent) {
    return 'Total $percent%';
  }

  @override
  String get splitNeedsParticipants => 'Select at least one person.';

  @override
  String get splitAdjustmentsTooBig => 'Adjustments are larger than the total.';

  @override
  String get splitNegativeShare =>
      'An adjustment makes someone\'s share negative.';

  @override
  String get splitZeroShares => 'Enter at least one share.';

  @override
  String get groupExpenseSaved => 'Expense saved';

  @override
  String get deleteGroupExpenseMessage =>
      'This expense will be removed from the group balances.';

  @override
  String get owes => 'owes';

  @override
  String get getsBack => 'gets back';

  @override
  String get settledUp => 'settled up';

  @override
  String get suggestedSettlements => 'Suggested settlements';

  @override
  String get settleUp => 'Settle up';

  @override
  String get recordSettlement => 'Record settlement';

  @override
  String get settlementFrom => 'Who paid';

  @override
  String get settlementTo => 'Who received';

  @override
  String get settlementSaved => 'Settlement recorded';

  @override
  String get settlementHistory => 'Settlement history';

  @override
  String get noSettlements => 'No settlements yet';

  @override
  String get deleteSettlementConfirm =>
      'Delete this settlement? Balances will change back.';

  @override
  String get groupAllSettled => 'Everyone is settled up';

  @override
  String paysTo(String from, String to) {
    return '$from pays $to';
  }

  @override
  String maxSettlement(String amount) {
    return 'Up to $amount';
  }

  @override
  String get paid => 'Paid';

  @override
  String get memberShare => 'Share';

  @override
  String get net => 'Net';

  @override
  String get settlementStatus => 'Status';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusPartlySettled => 'Partly settled';

  @override
  String get statusSettledShort => 'Settled';

  @override
  String get viewSpreadsheet => 'Sheet';

  @override
  String get viewCards => 'Cards';

  @override
  String get viewTimeline => 'Timeline';

  @override
  String get filterMember => 'Member';

  @override
  String get filterDate => 'Date';

  @override
  String get noGroupExpensesTitle => 'No expenses yet';

  @override
  String get noGroupExpensesBody =>
      'Add the first expense — the split will be calculated for you.';

  @override
  String get gcatFood => 'Food';

  @override
  String get gcatTravel => 'Travel';

  @override
  String get gcatStay => 'Stay';

  @override
  String get gcatTickets => 'Tickets';

  @override
  String get gcatShopping => 'Shopping';

  @override
  String get gcatGroceries => 'Groceries';

  @override
  String get gcatFuel => 'Fuel';

  @override
  String get gcatEntertainment => 'Fun';

  @override
  String get gcatGifts => 'Gifts';

  @override
  String get gcatUtilities => 'Utilities';

  @override
  String get gcatRent => 'Rent';

  @override
  String get gcatOther => 'Other';

  @override
  String get removeMember => 'Remove member';

  @override
  String get renameMember => 'Rename';

  @override
  String get memberRemoved => 'Member removed';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleMember => 'Member';

  @override
  String get localParticipant => 'On this phone only';

  @override
  String get cloudMember => 'Joined via app';

  @override
  String get sharedGroup => 'Shared';

  @override
  String get localGroup => 'On this phone';

  @override
  String get pickGroup => 'Choose a group';

  @override
  String timelineSettlement(String from, String to) {
    return '$from paid $to';
  }

  @override
  String expensesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses',
      one: '1 expense',
      zero: 'No expenses',
    );
    return '$_temp0';
  }

  @override
  String get inviteMembers => 'Invite members';

  @override
  String get joinGroup => 'Join a group';

  @override
  String get khataTitle => 'Khata';

  @override
  String get ledgerGivenLabel => 'I gave';

  @override
  String get ledgerTakenLabel => 'I took';

  @override
  String get ledgerGivenLong => 'Money given — they owe you';

  @override
  String get ledgerTakenLong => 'Money taken — you owe them';

  @override
  String get netBalance => 'Net balance';

  @override
  String owesYou(String name) {
    return '$name owes you';
  }

  @override
  String youOweName(String name) {
    return 'You owe $name';
  }

  @override
  String get allSettled => 'All settled';

  @override
  String get statusOpen => 'Pending';

  @override
  String get statusPartial => 'Partly paid';

  @override
  String get statusSettled => 'Settled';

  @override
  String dueOn(String date) {
    return 'Due $date';
  }

  @override
  String get overdue => 'Overdue';

  @override
  String get principal => 'Amount';

  @override
  String get repaid => 'Repaid';

  @override
  String get outstanding => 'Outstanding';

  @override
  String get recordRepayment => 'Record repayment';

  @override
  String get repaymentReceivedTitle => 'Money received back';

  @override
  String get repaymentPaidTitle => 'Money returned';

  @override
  String get repaymentSaved => 'Repayment recorded';

  @override
  String get repaymentExceedsTitle => 'More than the due amount';

  @override
  String repaymentExceedsBody(String due, String extra) {
    return 'Only $due is due. Record the extra $extra as an advance / credit in the other direction?';
  }

  @override
  String get recordAsAdvance => 'Record as advance';

  @override
  String get advanceCredit => 'Advance / credit';

  @override
  String get repaymentHistory => 'Repayment history';

  @override
  String get noRepayments => 'No repayments yet';

  @override
  String get ledgerEntries => 'Entries';

  @override
  String get noLedgerTitle => 'Your khata is empty';

  @override
  String get noLedgerBody =>
      'Record money you give or take and keep track of repayments.';

  @override
  String get dueDateOptional => 'Due date (optional)';

  @override
  String get ledgerEntryTitleNew => 'New khata entry';

  @override
  String get ledgerEntryTitleEdit => 'Edit khata entry';

  @override
  String get ledgerEntryDetailTitle => 'Khata entry';

  @override
  String get ledgerSaved => 'Khata entry saved';

  @override
  String get deleteLedgerMessage =>
      'This entry and its repayment history will be deleted.';

  @override
  String get deleteRepaymentConfirm =>
      'Delete this repayment? The outstanding amount will go up again.';

  @override
  String get filterToReceive => 'To receive';

  @override
  String get filterToPay => 'To pay';

  @override
  String get filterSettled => 'Settled';

  @override
  String get peopleTitle => 'People';

  @override
  String get addPerson => 'Add person';

  @override
  String get editPerson => 'Edit person';

  @override
  String get personName => 'Name';

  @override
  String get mobileNumber => 'Mobile number';

  @override
  String get emailOptional => 'Email (optional)';

  @override
  String get pickFromContacts => 'Choose from contacts';

  @override
  String get contactsHint =>
      'Only the contact you choose is read. HisabMitra cannot see your other contacts.';

  @override
  String get personSaved => 'Person saved';

  @override
  String get deletePersonMessage =>
      'This person and their settled khata history will be deleted.';

  @override
  String get noPeopleTitle => 'No people yet';

  @override
  String get noPeopleBody => 'Add people you lend money to or borrow from.';

  @override
  String get searchPeople => 'Search people';

  @override
  String get totalGiven => 'Total given';

  @override
  String get totalTaken => 'Total taken';

  @override
  String get personTransactions => 'Income & expenses';

  @override
  String get callPerson => 'Call';

  @override
  String get selectPerson => 'Select person';

  @override
  String get addEntry => 'Add entry';

  @override
  String get remindLater => 'Set reminder';

  @override
  String repaymentFor(String description) {
    return 'For: $description';
  }

  @override
  String repaidProgress(String repaid, String total) {
    return '$repaid of $total repaid';
  }

  @override
  String get settlementHistoryTitle => 'Settlement history';

  @override
  String get ledgerNotIncomeNote =>
      'Khata entries are loans, not income or expense, so they do not change your savings.';

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'Hisab';

  @override
  String get navPeople => 'Khata';

  @override
  String get navGroups => 'Groups';

  @override
  String get navMore => 'More';

  @override
  String get languageTitle => 'Choose your language';

  @override
  String get languageSubtitle => 'You can change this any time in Settings.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGujarati => 'ગુજરાતી (Gujarati)';

  @override
  String get onboardTitle1 => 'Your daily hisab, made simple';

  @override
  String get onboardBody1 =>
      'Record income and expenses in seconds. Saved to your account, and it works without internet too.';

  @override
  String get onboardTitle2 => 'Lend, borrow, settle';

  @override
  String get onboardBody2 =>
      'Keep a clear khata of money given and taken, with partial repayments and gentle reminders.';

  @override
  String get onboardTitle3 => 'Share expenses with family & friends';

  @override
  String get onboardBody3 =>
      'Split trip, festival and household costs fairly — right down to the last paisa.';

  @override
  String get getStarted => 'Get started';

  @override
  String get profileSetupTitle => 'Create your account';

  @override
  String get profileSetupSubtitle =>
      'Name, email and mobile number are required. We verify your email; your hisab is saved to this account.';

  @override
  String get yourName => 'Your name';

  @override
  String get startUsing => 'Start using HisabMitra';

  @override
  String get privacyPromise =>
      'Your hisab is saved to your account, and only you can see it.';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get addReminder => 'Add reminder';

  @override
  String get editReminder => 'Edit reminder';

  @override
  String get reminderTitle => 'What to remember';

  @override
  String get reminderTime => 'Time';

  @override
  String get reminderRepeat => 'Repeat';

  @override
  String get repeatNone => 'Once';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String get repeatMonthly => 'Monthly';

  @override
  String get reminderKind => 'Type';

  @override
  String get kindRepayment => 'Repay money';

  @override
  String get kindCollection => 'Collect money';

  @override
  String get kindGroupSettlement => 'Group settlement';

  @override
  String get kindCustom => 'Other';

  @override
  String get reminderSaved => 'Reminder set';

  @override
  String get reminderDone => 'Mark done';

  @override
  String get reminderCancel => 'Cancel reminder';

  @override
  String get reminderUpcoming => 'Upcoming';

  @override
  String get reminderHistory => 'Done & cancelled';

  @override
  String get noRemindersTitle => 'No reminders';

  @override
  String get noRemindersBody =>
      'Set reminders for repayments, collections or bills.';

  @override
  String get reminderPast => 'This time has already passed.';

  @override
  String get notificationsDenied =>
      'Notifications are off for HisabMitra. You can turn them on in Android settings.';

  @override
  String get notificationGenericTitle => 'HisabMitra reminder';

  @override
  String get notificationGenericBody => 'Open HisabMitra to see your reminder.';

  @override
  String reminderCollectTitle(String amount, String name) {
    return 'Collect $amount from $name';
  }

  @override
  String reminderRepayTitle(String amount, String name) {
    return 'Repay $amount to $name';
  }

  @override
  String reminderSettleTitle(String group) {
    return 'Settle up in $group';
  }

  @override
  String get statusDone => 'Done';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get kindEmi => 'EMI';

  @override
  String get kindSip => 'SIP';

  @override
  String get kindInstallment => 'Installment';

  @override
  String get kindMaintenance => 'Maintenance';

  @override
  String get kindInsurance => 'Insurance premium';

  @override
  String get kindRent => 'Rent';

  @override
  String get kindSubscription => 'Subscription';

  @override
  String get kindBill => 'Bill';

  @override
  String get repeatQuarterly => 'Every 3 months';

  @override
  String get repeatHalfYearly => 'Every 6 months';

  @override
  String get repeatYearly => 'Yearly';

  @override
  String get reminderTypePayment => 'Recurring payment';

  @override
  String get reminderTypeReminder => 'Reminder';

  @override
  String get paymentType => 'Payment type';

  @override
  String get paymentAmount => 'Fixed amount';

  @override
  String get paymentCategory => 'Expense category';

  @override
  String get paymentCategoryHint => 'Used when you record the payment';

  @override
  String get paymentEnds => 'Ends';

  @override
  String get paymentEndsNever => 'No end date';

  @override
  String get paymentEndsAfter => 'After a number of payments';

  @override
  String get paymentCount => 'Total number of payments';

  @override
  String paymentProgress(int done, int total) {
    return '$done of $total paid';
  }

  @override
  String paymentsPaidSoFar(int count) {
    return '$count paid so far';
  }

  @override
  String get markPaid => 'Mark paid';

  @override
  String get recordPaymentTitle => 'Record this payment?';

  @override
  String recordPaymentBody(String amount, String title) {
    return '$amount for $title. Add it to your Hisab as an expense?';
  }

  @override
  String get recordAsExpense => 'Add as expense';

  @override
  String get justMarkPaid => 'Only mark paid';

  @override
  String get paymentsDueThisMonth => 'Payments due this month';

  @override
  String get addRecurringPayment => 'Add recurring payment';

  @override
  String notificationPaymentBody(String amount) {
    return '$amount due';
  }

  @override
  String get reminderBatteryTip =>
      'On some phones (Xiaomi, Oppo, Vivo and others) battery saving can stop reminders. Allow HisabMitra to run in the background so they arrive on time.';

  @override
  String get reminderBatteryTipOpen => 'Open settings';

  @override
  String get reminderBatteryTipDismiss => 'Got it';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportOverview => 'Income & expense';

  @override
  String get reportOverviewDesc => 'Monthly income, expense and savings';

  @override
  String get reportCategories => 'Category-wise spending';

  @override
  String get reportCategoriesDesc => 'Where your money went';

  @override
  String get reportPaymentMethods => 'Payment methods';

  @override
  String get reportPaymentMethodsDesc => 'Cash, UPI, cards and bank';

  @override
  String get reportPeople => 'Lending & borrowing';

  @override
  String get reportPeopleDesc => 'Person-wise khata for the period';

  @override
  String get reportGroups => 'Group expenses';

  @override
  String get reportGroupsDesc => 'Spending and settlements in groups';

  @override
  String get savings => 'Savings';

  @override
  String get exportCsv => 'Export CSV (Excel)';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get exportFailed => 'Could not create the export file.';

  @override
  String get monthlyBreakdown => 'Monthly breakdown';

  @override
  String get topExpenses => 'Top expenses';

  @override
  String get loansGiven => 'Money given (loans)';

  @override
  String get loansTaken => 'Money taken (loans)';

  @override
  String get repaymentsReceived => 'Repayments received';

  @override
  String get repaymentsPaid => 'Repayments made';

  @override
  String get groupSettlementsLabel => 'Group settlements';

  @override
  String get reportSeparationNote =>
      'Loans, repayments and group settlements are shown separately. They are not counted as income or expense.';

  @override
  String generatedOn(String date) {
    return 'Generated on $date by HisabMitra';
  }

  @override
  String pageOf(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String reportPeriod(String from, String to) {
    return '$from – $to';
  }

  @override
  String get colType => 'Type';

  @override
  String get colMonth => 'Month';

  @override
  String get colCount => 'Entries';

  @override
  String get colShare => '% of total';

  @override
  String get myShare => 'My share';

  @override
  String get iPaid => 'I paid';

  @override
  String get noDataForPeriod => 'No records in this period';

  @override
  String get transactionsExportTitle => 'Transactions';

  @override
  String get fullReportTitle => 'Financial report';

  @override
  String get settlementSummary => 'Settlement summary';

  @override
  String shareReportCaption(String title, String period) {
    return '📊 *HisabMitra report* · $title · $period';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Colour theme';

  @override
  String get paletteRannUtsav => 'Rann Utsav';

  @override
  String get paletteRannUtsavDesc =>
      'Navy, silver and red of the white Rann under a full moon';

  @override
  String get paletteBandhaniLal => 'Bandhani Lal';

  @override
  String get paletteBandhaniLalDesc => 'Maroon and kesar of the red chopda';

  @override
  String get paletteKesariyo => 'Kesariyo';

  @override
  String get paletteKesariyoDesc => 'Saffron and plum of Navratri';

  @override
  String get palettePatolaRani => 'Patola Rani';

  @override
  String get palettePatolaRaniDesc =>
      'Rani pink, turmeric and aubergine of Patan Patola';

  @override
  String get paletteNeelGagan => 'Neel Gagan';

  @override
  String get paletteNeelGaganDesc => 'Sky blue and indigo of the Uttarayan sky';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsFinance => 'Finance';

  @override
  String get settingsCurrency => 'Default currency';

  @override
  String get currencyInr => 'Indian Rupee (₹)';

  @override
  String get settingsDateFormat => 'Date format';

  @override
  String get settingsNumberFormat => 'Number format';

  @override
  String get numberFormatIndian => 'Indian (1,23,456.00)';

  @override
  String get numberFormatInternational => 'International (123,456.00)';

  @override
  String get settingsCalculatorAuto => 'Auto-calculate total';

  @override
  String get settingsCalculatorAutoDesc =>
      'Update the amount when unit price or quantity changes';

  @override
  String get settingsGroupSection => 'Groups';

  @override
  String get settingsDefaultGroupView => 'Default group view';

  @override
  String get groupViewSpreadsheet => 'Spreadsheet';

  @override
  String get groupViewCards => 'Cards';

  @override
  String get groupViewTimeline => 'Timeline';

  @override
  String get settingsGroupNotifications => 'Group settlement reminders';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsReminderNotifications => 'Reminder notifications';

  @override
  String get settingsHideAmounts => 'Hide amounts in notifications';

  @override
  String get settingsHideAmountsDesc =>
      'Notifications show only a generic message';

  @override
  String get settingsSync => 'Cloud sync';

  @override
  String get settingsSyncStatus => 'Sync status';

  @override
  String get settingsBackup => 'Backup & restore';

  @override
  String get settingsBackupDesc => 'Manual, automatic and encrypted backups';

  @override
  String get autoBackupOff => 'Off';

  @override
  String get settingsAi => 'AI assistant';

  @override
  String get settingsAiEnabled => 'Enable AI assistant';

  @override
  String get settingsAiEnabledDesc =>
      'Answers questions using calculations done on this device';

  @override
  String get settingsAiProvider => 'Answer engine';

  @override
  String get aiProviderLocal => 'On-device (private)';

  @override
  String get aiProviderOnline => 'Online AI (Claude)';

  @override
  String get settingsAiConsent => 'Allow sharing summaries with online AI';

  @override
  String get settingsAiConsentDesc =>
      'Only totals needed to answer your question are sent. Raw transactions, notes and attachments are never sent.';

  @override
  String get settingsAiShareNames => 'Include people & group names';

  @override
  String get settingsAiApiKey => 'Online AI API key';

  @override
  String get settingsAiApiKeySet => 'Key saved securely';

  @override
  String get settingsAiApiKeyMissing => 'No key saved';

  @override
  String get settingsAiPrivacy => 'How AI uses your data';

  @override
  String get aiPrivacyExplanation =>
      'All amounts are calculated by HisabMitra on your phone. With the on-device engine nothing leaves your phone. If you enable online AI and give consent, only the summary figures for your question (for example \'expenses this month by category\') are sent to the provider to phrase the answer. The AI can never add, change or delete your records.';

  @override
  String get settingsGujaratiInput => 'Gujarati typing';

  @override
  String get inputModeSystem => 'Phone keyboard';

  @override
  String get inputModeTransliteration =>
      'English → ગુજરાતી (type \'kem chho\')';

  @override
  String get inputModeKeypad => 'Gujarati keypad';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsLogoutConfirm =>
      'Log out? Your hisab stays saved in your account and is removed from this phone. Categories and settings stay on the phone.';

  @override
  String get settingsDeleteAccount => 'Delete cloud account';

  @override
  String get settingsDeleteAccountDesc =>
      'Deletes your account, its saved hisab and bills, and your group memberships.';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsCategories => 'Categories';

  @override
  String get settingsReminders => 'Reminders';

  @override
  String get settingsCalculator => 'Calculator';

  @override
  String get settingsReports => 'Reports';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsTerms => 'Terms & conditions';

  @override
  String get signOutUnsentTitle => 'Not saved yet';

  @override
  String signOutUnsentBody(String count) {
    return '$count changes haven\'t been saved to your account yet. Logging out now loses them.';
  }

  @override
  String get signOutWaitSync => 'Wait and sync';

  @override
  String get signOutAnyway => 'Log out anyway';

  @override
  String get tourPromptTitle => 'Take a quick tour?';

  @override
  String get tourPromptBody =>
      'See HisabMitra with sample data: two months of income and expenses, money lent and borrowed, and a Goa trip split with friends. You can remove the sample data at the end.';

  @override
  String get tourStart => 'Start tour';

  @override
  String get tourNotNow => 'Not now';

  @override
  String get tourLoading => 'Adding sample data…';

  @override
  String tourStepOf(int current, int total) {
    return '$current of $total';
  }

  @override
  String get tourNext => 'Next';

  @override
  String get tourBack => 'Back';

  @override
  String get tourSkip => 'Skip tour';

  @override
  String get tour1Title => 'Your month at a glance';

  @override
  String get tour1Body =>
      'Savings = income − expenses for the period. Switch between this month, last month and this year with the chips above.';

  @override
  String get tour2Title => 'Money to receive and to pay';

  @override
  String get tour2Body =>
      'Totals from your khata: money you lent and money you borrowed. Loans are kept separate from income and expenses.';

  @override
  String get tour3Title => 'Quick actions';

  @override
  String get tour3Body =>
      'Add income or an expense, give or receive money, create a group, split a group expense or open reports — one tap each.';

  @override
  String get tour4Title => 'Your hisab, also as a sheet';

  @override
  String get tour4Body =>
      'Every entry, day by day. Tap this table icon for an Excel-like sheet with income, expense and a running balance.';

  @override
  String get tour5Title => 'Khata: people and loans';

  @override
  String get tour5Body =>
      'See who owes you and whom you owe. Open a person for the full ledger, partial repayments and due dates.';

  @override
  String get tour6Title => 'Groups: split and settle';

  @override
  String get tour6Body =>
      'Split trips and family costs equally, by amounts, percentages or shares. Open the sample Goa Trip to see balances and settle-ups.';

  @override
  String get tour7Title => 'More tools';

  @override
  String get tour7Body =>
      'Reports with PDF and CSV export, calculator, reminders, backup, the AI assistant, and settings for colour theme, language and the Gujarati keyboard.';

  @override
  String get tourFinishTitle => 'You are all set!';

  @override
  String get tourFinishBody =>
      'Keep the sample data to explore a little more, or remove it and start your own hisab. You can replay the tour any time from More.';

  @override
  String get tourRemoveSample => 'Remove sample data';

  @override
  String get tourKeepSample => 'Keep for now';

  @override
  String get sampleBanner => 'You are looking at sample data.';

  @override
  String get sampleRemove => 'Remove';

  @override
  String get sampleRemoveTitle => 'Remove sample data?';

  @override
  String get sampleRemoveBody =>
      'Sample entries, people and the sample group are removed. Everything you added yourself stays — a sample person or group you used is kept.';

  @override
  String get sampleRemoved => 'Sample data removed';

  @override
  String get moreAppTour => 'App tour';

  @override
  String get moreAppTourDesc => 'A one-minute guided tour with sample data';
}

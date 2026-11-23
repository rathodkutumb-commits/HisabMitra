import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
  ];

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About HisabMitra'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'HisabMitra keeps your daily hisab, personal khata and family group expenses in your account, with a copy on your phone so it works without internet.'**
  String get aboutDescription;

  /// No description provided for @checkUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkUpdates;

  /// No description provided for @updateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You have the latest version.'**
  String get updateUpToDate;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is available'**
  String updateAvailable(String version);

  /// No description provided for @updateNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Update checks are not set up in this build.'**
  String get updateNotConfigured;

  /// No description provided for @updateDownloadInstall.
  ///
  /// In en, this message translates to:
  /// **'Download & install'**
  String get updateDownloadInstall;

  /// No description provided for @updateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}%'**
  String updateDownloading(int percent);

  /// No description provided for @updateInstallSteps.
  ///
  /// In en, this message translates to:
  /// **'The file was verified (checksum, package and signature). Android will now ask you to confirm the installation. Your hisab stays safe in your account and on this phone.'**
  String get updateInstallSteps;

  /// No description provided for @updateAllowInstall.
  ///
  /// In en, this message translates to:
  /// **'Allow HisabMitra to install updates in the next screen, then tap Download & install again.'**
  String get updateAllowInstall;

  /// No description provided for @updateNoChecksum.
  ///
  /// In en, this message translates to:
  /// **'This release has no published checksum, so it cannot be installed from inside the app. Open the release page instead.'**
  String get updateNoChecksum;

  /// No description provided for @updateChecksumMismatch.
  ///
  /// In en, this message translates to:
  /// **'The downloaded file did not match its published checksum and was deleted.'**
  String get updateChecksumMismatch;

  /// No description provided for @updateWrongPackage.
  ///
  /// In en, this message translates to:
  /// **'The downloaded file is not a HisabMitra update.'**
  String get updateWrongPackage;

  /// No description provided for @updateNotNewer.
  ///
  /// In en, this message translates to:
  /// **'The downloaded version is not newer than the installed one.'**
  String get updateNotNewer;

  /// No description provided for @updateSignatureMismatch.
  ///
  /// In en, this message translates to:
  /// **'The update is not signed with the same key as this app, so Android would refuse it. Install it manually from the release page only if you trust the source.'**
  String get updateSignatureMismatch;

  /// No description provided for @updateUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The downloaded file could not be read.'**
  String get updateUnreadable;

  /// No description provided for @releaseNotes.
  ///
  /// In en, this message translates to:
  /// **'Release notes'**
  String get releaseNotes;

  /// No description provided for @openWebsite.
  ///
  /// In en, this message translates to:
  /// **'HisabMitra website'**
  String get openWebsite;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share HisabMitra'**
  String get shareApp;

  /// No description provided for @shareAppText.
  ///
  /// In en, this message translates to:
  /// **'📒 *HisabMitra — Smart Hisab, Happy Family*\n\nI keep my family\'s hisab in HisabMitra:\n✅ Daily income and expenses\n🤝 Money given and taken (khata)\n👨‍👩‍👧 Family and trip expense splitting\n📊 Reports in English and ગુજરાતી'**
  String get shareAppText;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get licenses;

  /// No description provided for @privacySummary.
  ///
  /// In en, this message translates to:
  /// **'Your personal records, people, khata, reminders and bills are saved to your HisabMitra account, and only you can see them. Group expenses are shared with that group\'s members. Your phone keeps a copy so the app works offline; signing out removes it. Optional online AI receives summary figures only after your consent. No advertising or tracking SDKs are included.'**
  String get privacySummary;

  /// No description provided for @termsSummary.
  ///
  /// In en, this message translates to:
  /// **'HisabMitra is a record-keeping tool. Please check important figures yourself; it does not provide financial, tax or legal advice.'**
  String get termsSummary;

  /// No description provided for @shareAppDownload.
  ///
  /// In en, this message translates to:
  /// **'📲 Download free: {url}'**
  String shareAppDownload(String url);

  /// No description provided for @aiTitle.
  ///
  /// In en, this message translates to:
  /// **'HisabMitra assistant'**
  String get aiTitle;

  /// No description provided for @aiDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'The assistant is off'**
  String get aiDisabledTitle;

  /// No description provided for @aiDisabledBody.
  ///
  /// In en, this message translates to:
  /// **'Turn it on to ask questions about your hisab. Answers are calculated on this phone.'**
  String get aiDisabledBody;

  /// No description provided for @aiEnable.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get aiEnable;

  /// No description provided for @aiInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about your money…'**
  String get aiInputHint;

  /// No description provided for @aiCalculatedOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Calculated on this phone'**
  String get aiCalculatedOnPhone;

  /// No description provided for @aiSuggestionBadge.
  ///
  /// In en, this message translates to:
  /// **'Suggestion — not your data'**
  String get aiSuggestionBadge;

  /// No description provided for @aiOnlineBadge.
  ///
  /// In en, this message translates to:
  /// **'Worded by online AI'**
  String get aiOnlineBadge;

  /// No description provided for @aiPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period: {period}'**
  String aiPeriodLabel(String period);

  /// No description provided for @aiReviewDraft.
  ///
  /// In en, this message translates to:
  /// **'Review & save'**
  String get aiReviewDraft;

  /// No description provided for @aiDraftNote.
  ///
  /// In en, this message translates to:
  /// **'Nothing is saved until you check and save it.'**
  String get aiDraftNote;

  /// No description provided for @aiOnlineFailed.
  ///
  /// In en, this message translates to:
  /// **'Online AI is unavailable, so this answer was written on your phone.'**
  String get aiOnlineFailed;

  /// No description provided for @aiExample1.
  ///
  /// In en, this message translates to:
  /// **'How much did I spend this month?'**
  String get aiExample1;

  /// No description provided for @aiExample2.
  ///
  /// In en, this message translates to:
  /// **'What is my biggest expense category?'**
  String get aiExample2;

  /// No description provided for @aiExample3.
  ///
  /// In en, this message translates to:
  /// **'Compare this month with last month'**
  String get aiExample3;

  /// No description provided for @aiExample4.
  ///
  /// In en, this message translates to:
  /// **'Show my top five expenses'**
  String get aiExample4;

  /// No description provided for @aiExample5.
  ///
  /// In en, this message translates to:
  /// **'How much do people owe me?'**
  String get aiExample5;

  /// No description provided for @aiExample6.
  ///
  /// In en, this message translates to:
  /// **'How can I reduce my expenses?'**
  String get aiExample6;

  /// No description provided for @aiHelp.
  ///
  /// In en, this message translates to:
  /// **'I can answer questions about your own records, for example: spending or income in a period, your biggest category, top expenses, how much a person owes you, what a group trip cost, or who owes whom in a group. Try one of the suggestions below.'**
  String get aiHelp;

  /// No description provided for @aiSpend.
  ///
  /// In en, this message translates to:
  /// **'You spent {amount} in {period} across {count} entries.'**
  String aiSpend(String amount, String period, int count);

  /// No description provided for @aiIncome.
  ///
  /// In en, this message translates to:
  /// **'Your income in {period} was {amount}.'**
  String aiIncome(String amount, String period);

  /// No description provided for @aiSavings.
  ///
  /// In en, this message translates to:
  /// **'In {period} you earned {income} and spent {expense}, so you saved {savings}.'**
  String aiSavings(
    String period,
    String income,
    String expense,
    String savings,
  );

  /// No description provided for @aiTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Your biggest expense category in {period} was {category}: {amount} ({percent}% of spending).'**
  String aiTopCategory(
    String period,
    String category,
    String amount,
    String percent,
  );

  /// No description provided for @aiNoExpenses.
  ///
  /// In en, this message translates to:
  /// **'There are no expenses recorded in {period}.'**
  String aiNoExpenses(String period);

  /// No description provided for @aiPersonOwesYou.
  ///
  /// In en, this message translates to:
  /// **'{name} owes you {amount} in total (all open khata entries).'**
  String aiPersonOwesYou(String name, String amount);

  /// No description provided for @aiYouOwePerson.
  ///
  /// In en, this message translates to:
  /// **'You owe {name} {amount} in total (all open khata entries).'**
  String aiYouOwePerson(String name, String amount);

  /// No description provided for @aiPersonSettled.
  ///
  /// In en, this message translates to:
  /// **'You and {name} are all settled — nothing is pending.'**
  String aiPersonSettled(String name);

  /// No description provided for @aiGroupTotal.
  ///
  /// In en, this message translates to:
  /// **'{group} has cost {amount} so far across {count} expenses. Your share is {share}.'**
  String aiGroupTotal(String group, String amount, int count, String share);

  /// No description provided for @aiWhoOwesNone.
  ///
  /// In en, this message translates to:
  /// **'Everyone in {group} is settled up.'**
  String aiWhoOwesNone(String group);

  /// No description provided for @aiWhoOwesIntro.
  ///
  /// In en, this message translates to:
  /// **'To settle {group}:'**
  String aiWhoOwesIntro(String group);

  /// No description provided for @aiCompare.
  ///
  /// In en, this message translates to:
  /// **'{current}: spent {currentAmount}. {previous}: spent {previousAmount}. That is {change}.'**
  String aiCompare(
    String current,
    String currentAmount,
    String previous,
    String previousAmount,
    String change,
  );

  /// No description provided for @aiMore.
  ///
  /// In en, this message translates to:
  /// **'{amount} more'**
  String aiMore(String amount);

  /// No description provided for @aiLess.
  ///
  /// In en, this message translates to:
  /// **'{amount} less'**
  String aiLess(String amount);

  /// No description provided for @aiSame.
  ///
  /// In en, this message translates to:
  /// **'the same'**
  String get aiSame;

  /// No description provided for @aiTopExpensesIntro.
  ///
  /// In en, this message translates to:
  /// **'Your top expenses in {period}:'**
  String aiTopExpensesIntro(String period);

  /// No description provided for @aiReceivables.
  ///
  /// In en, this message translates to:
  /// **'People owe you {receivable} and you owe others {payable} (all open khata entries).'**
  String aiReceivables(String receivable, String payable);

  /// No description provided for @aiTipsIntro.
  ///
  /// In en, this message translates to:
  /// **'Based on {period}, a few ideas (suggestions, not facts):'**
  String aiTipsIntro(String period);

  /// No description provided for @aiTipCategory.
  ///
  /// In en, this message translates to:
  /// **'{category} took {percent}% of your spending ({amount}). Setting a monthly limit for it would have the biggest effect.'**
  String aiTipCategory(String category, String percent, String amount);

  /// No description provided for @aiTipFrequent.
  ///
  /// In en, this message translates to:
  /// **'You made {count} small expenses under ₹200 — together {amount}. Small daily spends add up.'**
  String aiTipFrequent(int count, String amount);

  /// No description provided for @aiTipSavings.
  ///
  /// In en, this message translates to:
  /// **'You spent more than you earned this period. Reviewing the top categories first usually helps most.'**
  String get aiTipSavings;

  /// No description provided for @aiTipGeneral.
  ///
  /// In en, this message translates to:
  /// **'Record every expense for a month, then compare months here to see what changed.'**
  String get aiTipGeneral;

  /// No description provided for @aiDraftExpense.
  ///
  /// In en, this message translates to:
  /// **'I prepared an expense of {amount}{category}. Please review it before saving.'**
  String aiDraftExpense(String amount, String category);

  /// No description provided for @aiDraftIncome.
  ///
  /// In en, this message translates to:
  /// **'I prepared an income entry of {amount}{category}. Please review it before saving.'**
  String aiDraftIncome(String amount, String category);

  /// No description provided for @aiDraftNeedsAmount.
  ///
  /// In en, this message translates to:
  /// **'Tell me the amount too, for example: “add expense 250 for groceries”. I will not guess amounts.'**
  String get aiDraftNeedsAmount;

  /// No description provided for @aiNoPerson.
  ///
  /// In en, this message translates to:
  /// **'I could not find that person in your khata.'**
  String get aiNoPerson;

  /// No description provided for @aiNoGroup.
  ///
  /// In en, this message translates to:
  /// **'I could not find that group.'**
  String get aiNoGroup;

  /// No description provided for @aiTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get aiTodayLabel;

  /// No description provided for @aiSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI assistant settings'**
  String get aiSettingsTitle;

  /// No description provided for @aiApiKeySave.
  ///
  /// In en, this message translates to:
  /// **'Save key'**
  String get aiApiKeySave;

  /// No description provided for @aiApiKeyRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove key'**
  String get aiApiKeyRemove;

  /// No description provided for @aiApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your Anthropic API key'**
  String get aiApiKeyHint;

  /// No description provided for @aiApiKeyNote.
  ///
  /// In en, this message translates to:
  /// **'The key is stored encrypted on this phone and is used only for online answers. Online usage is billed to your Anthropic account.'**
  String get aiApiKeyNote;

  /// No description provided for @aiOpenAssistant.
  ///
  /// In en, this message translates to:
  /// **'Ask HisabMitra AI'**
  String get aiOpenAssistant;

  /// No description provided for @aiExamplesSpending.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get aiExamplesSpending;

  /// No description provided for @aiExamplesIncome.
  ///
  /// In en, this message translates to:
  /// **'Income & savings'**
  String get aiExamplesIncome;

  /// No description provided for @aiExamplesKhata.
  ///
  /// In en, this message translates to:
  /// **'Khata'**
  String get aiExamplesKhata;

  /// No description provided for @aiExamplesGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get aiExamplesGroups;

  /// No description provided for @aiExamplesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add an entry'**
  String get aiExamplesAdd;

  /// No description provided for @aiExample7.
  ///
  /// In en, this message translates to:
  /// **'How much did I spend today?'**
  String get aiExample7;

  /// No description provided for @aiExample8.
  ///
  /// In en, this message translates to:
  /// **'How much did I spend last month?'**
  String get aiExample8;

  /// No description provided for @aiExample9.
  ///
  /// In en, this message translates to:
  /// **'What is my income this month?'**
  String get aiExample9;

  /// No description provided for @aiExample10.
  ///
  /// In en, this message translates to:
  /// **'What was my income last month?'**
  String get aiExample10;

  /// No description provided for @aiExample11.
  ///
  /// In en, this message translates to:
  /// **'What are my savings this month?'**
  String get aiExample11;

  /// No description provided for @aiExample12.
  ///
  /// In en, this message translates to:
  /// **'What are my savings this year?'**
  String get aiExample12;

  /// No description provided for @aiExample13.
  ///
  /// In en, this message translates to:
  /// **'Add 250 for groceries'**
  String get aiExample13;

  /// No description provided for @aiExample14.
  ///
  /// In en, this message translates to:
  /// **'Add salary 25000'**
  String get aiExample14;

  /// No description provided for @aiExample15.
  ///
  /// In en, this message translates to:
  /// **'Add 500 for fuel'**
  String get aiExample15;

  /// No description provided for @aiExamplePerson.
  ///
  /// In en, this message translates to:
  /// **'What is my balance with {name}?'**
  String aiExamplePerson(String name);

  /// No description provided for @aiExampleGroupTotal.
  ///
  /// In en, this message translates to:
  /// **'How much did {group} cost?'**
  String aiExampleGroupTotal(String group);

  /// No description provided for @aiExampleGroupOwes.
  ///
  /// In en, this message translates to:
  /// **'Who owes whom in {group}?'**
  String aiExampleGroupOwes(String group);

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Bills & attachments'**
  String get attachments;

  /// No description provided for @attachCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get attachCamera;

  /// No description provided for @attachGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get attachGallery;

  /// No description provided for @attachPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get attachPdf;

  /// No description provided for @attachmentTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This file is larger than 10 MB.'**
  String get attachmentTooLarge;

  /// No description provided for @attachmentType.
  ///
  /// In en, this message translates to:
  /// **'Only JPG, PNG, WEBP, HEIC images and PDF files can be attached.'**
  String get attachmentType;

  /// No description provided for @attachmentMissing.
  ///
  /// In en, this message translates to:
  /// **'This file is no longer available on the phone.'**
  String get attachmentMissing;

  /// No description provided for @attachmentOpenExternal.
  ///
  /// In en, this message translates to:
  /// **'Open in another app'**
  String get attachmentOpenExternal;

  /// No description provided for @attachmentDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this attachment?'**
  String get attachmentDeleteConfirm;

  /// No description provided for @attachmentViewerTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachmentViewerTitle;

  /// No description provided for @attachmentPrivateNote.
  ///
  /// In en, this message translates to:
  /// **'Saved to your HisabMitra account.'**
  String get attachmentPrivateNote;

  /// No description provided for @attachmentShareToGroup.
  ///
  /// In en, this message translates to:
  /// **'Share with group'**
  String get attachmentShareToGroup;

  /// No description provided for @attachmentSharedToGroup.
  ///
  /// In en, this message translates to:
  /// **'Shared with group'**
  String get attachmentSharedToGroup;

  /// No description provided for @attachmentRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get attachmentRemove;

  /// No description provided for @photoRecovered.
  ///
  /// In en, this message translates to:
  /// **'We saved the photo you took. Add it to a new expense?'**
  String get photoRecovered;

  /// No description provided for @photoRecoveredAction.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get photoRecoveredAction;

  /// No description provided for @attachmentDownloadRetry.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this bill. Check your internet and try again.'**
  String get attachmentDownloadRetry;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupTitle;

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backupNow;

  /// No description provided for @backupEncrypt.
  ///
  /// In en, this message translates to:
  /// **'Protect with a password'**
  String get backupEncrypt;

  /// No description provided for @backupPassword.
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get backupPassword;

  /// No description provided for @backupPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get backupPasswordConfirm;

  /// No description provided for @backupPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get backupPasswordMismatch;

  /// No description provided for @backupPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get backupPasswordTooShort;

  /// No description provided for @backupPasswordWarning.
  ///
  /// In en, this message translates to:
  /// **'HisabMitra does not store this password. Without it, this backup cannot be restored.'**
  String get backupPasswordWarning;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Backup created'**
  String get backupCreated;

  /// No description provided for @backupHistory.
  ///
  /// In en, this message translates to:
  /// **'Backup history'**
  String get backupHistory;

  /// No description provided for @backupNone.
  ///
  /// In en, this message translates to:
  /// **'No backups yet'**
  String get backupNone;

  /// No description provided for @backupKindManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get backupKindManual;

  /// No description provided for @backupKindAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get backupKindAutomatic;

  /// No description provided for @backupKindSafety.
  ///
  /// In en, this message translates to:
  /// **'Before restore'**
  String get backupKindSafety;

  /// No description provided for @backupEncryptedLabel.
  ///
  /// In en, this message translates to:
  /// **'Encrypted'**
  String get backupEncryptedLabel;

  /// No description provided for @backupExport.
  ///
  /// In en, this message translates to:
  /// **'Save / share copy'**
  String get backupExport;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupRestore;

  /// No description provided for @backupRestoreFromFile.
  ///
  /// In en, this message translates to:
  /// **'Restore from a file'**
  String get backupRestoreFromFile;

  /// No description provided for @backupRestoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace current data?'**
  String get backupRestoreConfirmTitle;

  /// No description provided for @backupRestoreConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This backup from {date} contains {transactions} entries, {people} people and {groups} groups. Your current data will be replaced. A safety backup of your current data is made first.'**
  String backupRestoreConfirmBody(
    String date,
    int transactions,
    int people,
    int groups,
  );

  /// No description provided for @backupRestoreDone.
  ///
  /// In en, this message translates to:
  /// **'Restore complete'**
  String get backupRestoreDone;

  /// No description provided for @backupRestoreMissingAttachments.
  ///
  /// In en, this message translates to:
  /// **'{count} attachment files were not in the backup.'**
  String backupRestoreMissingAttachments(int count);

  /// No description provided for @backupWhere.
  ///
  /// In en, this message translates to:
  /// **'Your hisab is saved in your account. A backup is an extra copy, stored privately in HisabMitra\'s app storage on this phone; uninstalling the app deletes it, so use “Save / share copy” to keep it elsewhere (for example Google Drive or a computer).'**
  String get backupWhere;

  /// No description provided for @backupFileMissing.
  ///
  /// In en, this message translates to:
  /// **'File no longer on this phone'**
  String get backupFileMissing;

  /// No description provided for @backupDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this backup file?'**
  String get backupDeleteConfirm;

  /// No description provided for @backupPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'This backup is encrypted. Enter its password.'**
  String get backupPasswordRequired;

  /// No description provided for @backupWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password, or the file is damaged.'**
  String get backupWrongPassword;

  /// No description provided for @backupCorrupt.
  ///
  /// In en, this message translates to:
  /// **'The backup file is damaged or was modified, so it cannot be restored.'**
  String get backupCorrupt;

  /// No description provided for @backupNewerSchema.
  ///
  /// In en, this message translates to:
  /// **'This backup was made by a newer version of HisabMitra. Update the app first.'**
  String get backupNewerSchema;

  /// No description provided for @backupIntegrity.
  ///
  /// In en, this message translates to:
  /// **'The data inside the backup failed its integrity check.'**
  String get backupIntegrity;

  /// No description provided for @backupNotBackup.
  ///
  /// In en, this message translates to:
  /// **'This file is not a HisabMitra backup.'**
  String get backupNotBackup;

  /// No description provided for @shareBackupCaption.
  ///
  /// In en, this message translates to:
  /// **'🔒 *HisabMitra backup* · {date} — keep this file safe; you\'ll need your backup password to restore it.'**
  String shareBackupCaption(String date);

  /// No description provided for @shareBackupCaptionPlain.
  ///
  /// In en, this message translates to:
  /// **'🔒 *HisabMitra backup* · {date} — keep this file safe.'**
  String shareBackupCaptionPlain(String date);

  /// No description provided for @restoreNeedsInternet.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to restore.'**
  String get restoreNeedsInternet;

  /// No description provided for @restoreReplacesAccount.
  ///
  /// In en, this message translates to:
  /// **'This replaces the hisab saved in your account with this backup. Groups are not changed.'**
  String get restoreReplacesAccount;

  /// No description provided for @authSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get authSendOtp;

  /// No description provided for @authVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerify;

  /// No description provided for @authResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authResend;

  /// No description provided for @authResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String authResendIn(int seconds);

  /// No description provided for @authCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent'**
  String get authCodeSent;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get profileName;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete your account? Your saved hisab, bills and group memberships are deleted from the account and from this phone. This cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Cloud account deleted'**
  String get accountDeleted;

  /// No description provided for @signedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get signedOut;

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync status'**
  String get syncTitle;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncLastSuccess.
  ///
  /// In en, this message translates to:
  /// **'Last synced {date}'**
  String syncLastSuccess(String date);

  /// No description provided for @syncNever.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get syncNever;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Everything is up to date} =1{1 change waiting to sync} other{{count} changes waiting to sync}}'**
  String syncPending(int count);

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change could not be synced} other{{count} changes could not be synced}}'**
  String syncFailed(int count);

  /// No description provided for @syncRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get syncRetry;

  /// No description provided for @syncConflicts.
  ///
  /// In en, this message translates to:
  /// **'Needs your decision'**
  String get syncConflicts;

  /// No description provided for @syncConflictHelp.
  ///
  /// In en, this message translates to:
  /// **'This record was changed on another device while you were also changing it. Nothing has been overwritten — choose which version to keep.'**
  String get syncConflictHelp;

  /// No description provided for @syncKeepMine.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get syncKeepMine;

  /// No description provided for @syncKeepTheirs.
  ///
  /// In en, this message translates to:
  /// **'Use the other version'**
  String get syncKeepTheirs;

  /// No description provided for @syncYourVersion.
  ///
  /// In en, this message translates to:
  /// **'Your version'**
  String get syncYourVersion;

  /// No description provided for @syncOtherVersion.
  ///
  /// In en, this message translates to:
  /// **'Other device\'s version'**
  String get syncOtherVersion;

  /// No description provided for @syncOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline — changes will sync when you are back online.'**
  String get syncOffline;

  /// No description provided for @syncSignInNeeded.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync shared groups.'**
  String get syncSignInNeeded;

  /// No description provided for @syncDone.
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get syncDone;

  /// No description provided for @syncRunning.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncRunning;

  /// No description provided for @entityGroup.
  ///
  /// In en, this message translates to:
  /// **'Group details'**
  String get entityGroup;

  /// No description provided for @entityMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get entityMember;

  /// No description provided for @entityExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get entityExpense;

  /// No description provided for @entitySettlement.
  ///
  /// In en, this message translates to:
  /// **'Settlement'**
  String get entitySettlement;

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite members'**
  String get inviteTitle;

  /// No description provided for @inviteFor.
  ///
  /// In en, this message translates to:
  /// **'Invite for'**
  String get inviteFor;

  /// No description provided for @inviteNewMember.
  ///
  /// In en, this message translates to:
  /// **'Someone new'**
  String get inviteNewMember;

  /// No description provided for @inviteCreate.
  ///
  /// In en, this message translates to:
  /// **'Create invitation code'**
  String get inviteCreate;

  /// No description provided for @inviteShareText.
  ///
  /// In en, this message translates to:
  /// **'👋 *Join my group on HisabMitra!*\n\n👥 Group: *{group}*\n🔑 Invite code: *{code}*\n\nOpen HisabMitra → Groups → Join a group, and enter the code.\n\n⏳ The code is valid till *{date}*.'**
  String inviteShareText(String group, String code, String date);

  /// No description provided for @inviteShareTextLink.
  ///
  /// In en, this message translates to:
  /// **'👋 *Join my group on HisabMitra!*\n\n👥 Group: *{group}*\n🔑 Invite code: *{code}*\n\n👉 Tap to join: {link}\nOr open HisabMitra → Groups → Join a group, and enter the code.\n\n⏳ The code is valid till *{date}*.'**
  String inviteShareTextLink(
    String group,
    String code,
    String link,
    String date,
  );

  /// No description provided for @inviteExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String inviteExpires(String date);

  /// No description provided for @inviteStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get inviteStatusPending;

  /// No description provided for @inviteStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get inviteStatusAccepted;

  /// No description provided for @inviteStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get inviteStatusCancelled;

  /// No description provided for @inviteStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get inviteStatusExpired;

  /// No description provided for @inviteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel invitation'**
  String get inviteCancel;

  /// No description provided for @invitesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No invitations yet'**
  String get invitesEmpty;

  /// No description provided for @inviteCodeOnce.
  ///
  /// In en, this message translates to:
  /// **'Share this code now. For security it is shown only once.'**
  String get inviteCodeOnce;

  /// No description provided for @joinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join with a code'**
  String get joinTitle;

  /// No description provided for @joinCode.
  ///
  /// In en, this message translates to:
  /// **'Invitation code'**
  String get joinCode;

  /// No description provided for @joinButton.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinButton;

  /// No description provided for @joinDone.
  ///
  /// In en, this message translates to:
  /// **'You joined {group}'**
  String joinDone(String group);

  /// No description provided for @joinNeedsSignIn.
  ///
  /// In en, this message translates to:
  /// **'Verify your email to join a shared group.'**
  String get joinNeedsSignIn;

  /// No description provided for @errInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'This invitation code is not valid.'**
  String get errInvalidCode;

  /// No description provided for @errExpiredCode.
  ///
  /// In en, this message translates to:
  /// **'This invitation has expired. Ask for a new one.'**
  String get errExpiredCode;

  /// No description provided for @errAlreadyMember.
  ///
  /// In en, this message translates to:
  /// **'You are already a member of this group.'**
  String get errAlreadyMember;

  /// No description provided for @errInvitationPending.
  ///
  /// In en, this message translates to:
  /// **'There is already an open invitation for this member.'**
  String get errInvitationPending;

  /// No description provided for @errForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do this.'**
  String get errForbidden;

  /// No description provided for @errCloudStorage.
  ///
  /// In en, this message translates to:
  /// **'Could not upload or download the file.'**
  String get errCloudStorage;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {email}. Type it below, or tap the link in that email on this phone.'**
  String verifyEmailSubtitle(String email);

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCode;

  /// No description provided for @verifyEmailSpamHint.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it? Look in Spam or Promotions, or resend after a minute.'**
  String get verifyEmailSpamHint;

  /// No description provided for @changeDetails.
  ///
  /// In en, this message translates to:
  /// **'Change details'**
  String get changeDetails;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified. Welcome to HisabMitra!'**
  String get emailVerified;

  /// No description provided for @verifyingLink.
  ///
  /// In en, this message translates to:
  /// **'Checking the link…'**
  String get verifyingLink;

  /// No description provided for @authEmailNotAuthorized.
  ///
  /// In en, this message translates to:
  /// **'We can\'t send email to this address yet: the app\'s email sender is not set up. Please try again later.'**
  String get authEmailNotAuthorized;

  /// No description provided for @authLinkInvalid.
  ///
  /// In en, this message translates to:
  /// **'This link has expired or was opened on another phone. Type the code instead, or send a new one.'**
  String get authLinkInvalid;

  /// No description provided for @authNoPending.
  ///
  /// In en, this message translates to:
  /// **'Please enter your details again.'**
  String get authNoPending;

  /// No description provided for @accountOfflineNote.
  ///
  /// In en, this message translates to:
  /// **'This build has no cloud connection, so your email cannot be verified now. Your details are saved on this phone.'**
  String get accountOfflineNote;

  /// No description provided for @accountVerifiedAs.
  ///
  /// In en, this message translates to:
  /// **'Verified: {email}'**
  String accountVerifiedAs(String email);

  /// No description provided for @verifyEmailAction.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get verifyEmailAction;

  /// No description provided for @inviteShareDownload.
  ///
  /// In en, this message translates to:
  /// **'📲 Don\'t have the app? Download it free: {url}'**
  String inviteShareDownload(String url);

  /// No description provided for @entityPerson.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get entityPerson;

  /// No description provided for @entityTransaction.
  ///
  /// In en, this message translates to:
  /// **'Income or expense'**
  String get entityTransaction;

  /// No description provided for @entityLedgerEntry.
  ///
  /// In en, this message translates to:
  /// **'Khata entry'**
  String get entityLedgerEntry;

  /// No description provided for @entityRepayment.
  ///
  /// In en, this message translates to:
  /// **'Repayment'**
  String get entityRepayment;

  /// No description provided for @entityReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get entityReminder;

  /// No description provided for @entityBill.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get entityBill;

  /// No description provided for @inviteSampleGroup.
  ///
  /// In en, this message translates to:
  /// **'Sample groups cannot be shared.'**
  String get inviteSampleGroup;

  /// No description provided for @accountSyncUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Saving your hisab to your account'**
  String get accountSyncUploadTitle;

  /// No description provided for @accountSyncDownloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting your hisab'**
  String get accountSyncDownloadTitle;

  /// No description provided for @accountSyncProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String accountSyncProgress(String done, String total);

  /// No description provided for @accountSyncOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet. Your hisab will be saved to your account when you\'re back online.'**
  String get accountSyncOffline;

  /// No description provided for @accountSyncContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue in background'**
  String get accountSyncContinue;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'HisabMitra'**
  String get appName;

  /// No description provided for @appNameGujarati.
  ///
  /// In en, this message translates to:
  /// **'હિસાબમિત્ર'**
  String get appNameGujarati;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Smart Hisab, Happy Family.'**
  String get appTagline;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @person.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get person;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created {date}'**
  String createdOn(String date);

  /// No description provided for @updatedOn.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String updatedOn(String date);

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @savedMessage.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedMessage;

  /// No description provided for @deletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deletedMessage;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this?'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get confirmDeleteMessage;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'Your unsaved changes will be lost.'**
  String get discardChangesMessage;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Your changes are saved on this phone and will reach your account when you are back online.'**
  String get offlineBanner;

  /// No description provided for @pmCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get pmCash;

  /// No description provided for @pmUpi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get pmUpi;

  /// No description provided for @pmBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get pmBankTransfer;

  /// No description provided for @pmCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get pmCreditCard;

  /// No description provided for @pmDebitCard.
  ///
  /// In en, this message translates to:
  /// **'Debit card'**
  String get pmDebitCard;

  /// No description provided for @pmOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get pmOther;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount (up to 2 decimals)'**
  String get validationAmount;

  /// No description provided for @validationAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be more than zero'**
  String get validationAmountPositive;

  /// No description provided for @validationPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid mobile number'**
  String get validationPhone;

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmail;

  /// No description provided for @validationTooLong.
  ///
  /// In en, this message translates to:
  /// **'Too long (maximum {max} characters)'**
  String validationTooLong(int max);

  /// No description provided for @openCalculator.
  ///
  /// In en, this message translates to:
  /// **'Open calculator'**
  String get openCalculator;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @comingFromDate.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get comingFromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toDate;

  /// No description provided for @periodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get periodThisMonth;

  /// No description provided for @periodLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get periodLastMonth;

  /// No description provided for @periodThisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get periodThisYear;

  /// No description provided for @periodCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get periodCustom;

  /// No description provided for @notConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get notConfigured;

  /// No description provided for @privateOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Private · saved to your account'**
  String get privateOnDevice;

  /// No description provided for @exitAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit HisabMitra?'**
  String get exitAppTitle;

  /// No description provided for @exitAppConfirm.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitAppConfirm;

  /// No description provided for @exitAppStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get exitAppStay;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'This record no longer exists.'**
  String get errorNotFound;

  /// No description provided for @errorInUse.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{It is used by 1 record.} other{It is used by {count} records.}}'**
  String errorInUse(int count);

  /// No description provided for @errorStorage.
  ///
  /// In en, this message translates to:
  /// **'Could not save to phone storage. Check free space and try again.'**
  String get errorStorage;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Your change is saved on this phone and will sync later.'**
  String get errorNetwork;

  /// No description provided for @errorCloudNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Cloud features are not set up in this build of the app.'**
  String get errorCloudNotConfigured;

  /// No description provided for @errorPermission.
  ///
  /// In en, this message translates to:
  /// **'Permission was not granted.'**
  String get errorPermission;

  /// No description provided for @authInvalidOtp.
  ///
  /// In en, this message translates to:
  /// **'That code is not correct. Please check and try again.'**
  String get authInvalidOtp;

  /// No description provided for @authOtpExpired.
  ///
  /// In en, this message translates to:
  /// **'The code has expired. Request a new one.'**
  String get authOtpExpired;

  /// No description provided for @authRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a minute and try again.'**
  String get authRateLimited;

  /// No description provided for @authSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get authSessionExpired;

  /// No description provided for @authGenericError.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in right now. Please try again.'**
  String get authGenericError;

  /// No description provided for @errorPaymentCount.
  ///
  /// In en, this message translates to:
  /// **'The number of payments must be more than those already paid.'**
  String get errorPaymentCount;

  /// No description provided for @familyPersonRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} (removed)'**
  String familyPersonRemoved(String name);

  /// No description provided for @entityFamily.
  ///
  /// In en, this message translates to:
  /// **'Family hisab details'**
  String get entityFamily;

  /// No description provided for @entityFamilyPerson.
  ///
  /// In en, this message translates to:
  /// **'Person in Family hisab'**
  String get entityFamilyPerson;

  /// No description provided for @entityFamilyEntry.
  ///
  /// In en, this message translates to:
  /// **'Family hisab entry'**
  String get entityFamilyEntry;

  /// No description provided for @familyHisab.
  ///
  /// In en, this message translates to:
  /// **'Family hisab'**
  String get familyHisab;

  /// No description provided for @familyHisabs.
  ///
  /// In en, this message translates to:
  /// **'Family hisabs'**
  String get familyHisabs;

  /// No description provided for @familyButton.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get familyButton;

  /// No description provided for @familyMoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Home money together: salaries, contributions and expenses'**
  String get familyMoreSubtitle;

  /// No description provided for @familyCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Family hisab'**
  String get familyCreate;

  /// No description provided for @familyEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Family hisab'**
  String get familyEdit;

  /// No description provided for @familyNew.
  ///
  /// In en, this message translates to:
  /// **'New Family hisab'**
  String get familyNew;

  /// No description provided for @familyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Family hisab'**
  String get familyDelete;

  /// No description provided for @familyDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Its people and every entry are deleted from the account.'**
  String get familyDeleteMessage;

  /// No description provided for @familyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the home\'s hisab together'**
  String get familyEmptyTitle;

  /// No description provided for @familyEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add everyone\'s salary and contributions, write down every home expense and get a passbook statement every month.'**
  String get familyEmptyMessage;

  /// No description provided for @familyName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get familyName;

  /// No description provided for @familyNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Home'**
  String get familyNameHint;

  /// No description provided for @familyStartingBalance.
  ///
  /// In en, this message translates to:
  /// **'Starting balance (optional)'**
  String get familyStartingBalance;

  /// No description provided for @familyStartingBalanceHelp.
  ///
  /// In en, this message translates to:
  /// **'Money already in the home today'**
  String get familyStartingBalanceHelp;

  /// No description provided for @familyPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get familyPeople;

  /// No description provided for @familyPersonName.
  ///
  /// In en, this message translates to:
  /// **'Person\'s name'**
  String get familyPersonName;

  /// No description provided for @familyAddPerson.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get familyAddPerson;

  /// No description provided for @familyEditPerson.
  ///
  /// In en, this message translates to:
  /// **'Edit person'**
  String get familyEditPerson;

  /// No description provided for @familyDeletePerson.
  ///
  /// In en, this message translates to:
  /// **'Delete person'**
  String get familyDeletePerson;

  /// No description provided for @familyDeletePersonMessage.
  ///
  /// In en, this message translates to:
  /// **'Their entries stay in the hisab and show as \"{name} (removed)\".'**
  String familyDeletePersonMessage(String name);

  /// No description provided for @familyHasApp.
  ///
  /// In en, this message translates to:
  /// **'Has the app'**
  String get familyHasApp;

  /// No description provided for @familyNotJoined.
  ///
  /// In en, this message translates to:
  /// **'Not joined'**
  String get familyNotJoined;

  /// No description provided for @familyShowRemoved.
  ///
  /// In en, this message translates to:
  /// **'Show removed ({count})'**
  String familyShowRemoved(int count);

  /// No description provided for @familyHideRemoved.
  ///
  /// In en, this message translates to:
  /// **'Hide removed'**
  String get familyHideRemoved;

  /// No description provided for @familySaved.
  ///
  /// In en, this message translates to:
  /// **'Family hisab saved'**
  String get familySaved;

  /// No description provided for @familyPersonSaved.
  ///
  /// In en, this message translates to:
  /// **'Person saved'**
  String get familyPersonSaved;

  /// No description provided for @familyPersonDeleted.
  ///
  /// In en, this message translates to:
  /// **'Person deleted. Their entries stay.'**
  String get familyPersonDeleted;

  /// No description provided for @familyNoEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No entries this month yet'**
  String get familyNoEntriesYet;

  /// No description provided for @familyOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get familyOpening;

  /// No description provided for @familyClosing.
  ///
  /// In en, this message translates to:
  /// **'Closing balance'**
  String get familyClosing;

  /// No description provided for @familyMoneyIn.
  ///
  /// In en, this message translates to:
  /// **'Money in'**
  String get familyMoneyIn;

  /// No description provided for @familyMoneyOut.
  ///
  /// In en, this message translates to:
  /// **'Money out'**
  String get familyMoneyOut;

  /// No description provided for @familyAddMoneyIn.
  ///
  /// In en, this message translates to:
  /// **'Add money in'**
  String get familyAddMoneyIn;

  /// No description provided for @familyAddMoneyOut.
  ///
  /// In en, this message translates to:
  /// **'Add money out'**
  String get familyAddMoneyOut;

  /// No description provided for @familyEditMoneyIn.
  ///
  /// In en, this message translates to:
  /// **'Edit money in'**
  String get familyEditMoneyIn;

  /// No description provided for @familyEditMoneyOut.
  ///
  /// In en, this message translates to:
  /// **'Edit money out'**
  String get familyEditMoneyOut;

  /// No description provided for @familyKindSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get familyKindSalary;

  /// No description provided for @familyKindExtraIncome.
  ///
  /// In en, this message translates to:
  /// **'Extra income'**
  String get familyKindExtraIncome;

  /// No description provided for @familyKindContribution.
  ///
  /// In en, this message translates to:
  /// **'Contribution'**
  String get familyKindContribution;

  /// No description provided for @familyPerson.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get familyPerson;

  /// No description provided for @familyKind.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get familyKind;

  /// No description provided for @familyDoubleCountNote.
  ///
  /// In en, this message translates to:
  /// **'Money here already counts on your Home screen — don\'t add your salary again in Hisab.'**
  String get familyDoubleCountNote;

  /// No description provided for @familyEntrySaved.
  ///
  /// In en, this message translates to:
  /// **'Entry saved'**
  String get familyEntrySaved;

  /// No description provided for @familyEntryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get familyEntryDeleted;

  /// No description provided for @familyPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get familyPreviousMonth;

  /// No description provided for @familyNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get familyNextMonth;

  /// No description provided for @familyStatement.
  ///
  /// In en, this message translates to:
  /// **'Statement'**
  String get familyStatement;

  /// No description provided for @familyStatementTitle.
  ///
  /// In en, this message translates to:
  /// **'Family hisab statement'**
  String get familyStatementTitle;

  /// No description provided for @familyByPerson.
  ///
  /// In en, this message translates to:
  /// **'By person'**
  String get familyByPerson;

  /// No description provided for @familyPaidForHome.
  ///
  /// In en, this message translates to:
  /// **'Paid for home'**
  String get familyPaidForHome;

  /// No description provided for @familyPersonLine.
  ///
  /// In en, this message translates to:
  /// **'{name} — in {moneyIn} · paid {paid}'**
  String familyPersonLine(String name, String moneyIn, String paid);

  /// No description provided for @familySendWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Send on WhatsApp to {name}'**
  String familySendWhatsApp(String name);

  /// No description provided for @familyMoneyInCredit.
  ///
  /// In en, this message translates to:
  /// **'Money in (credit)'**
  String get familyMoneyInCredit;

  /// No description provided for @familyMoneyOutDebit.
  ///
  /// In en, this message translates to:
  /// **'Money out (debit)'**
  String get familyMoneyOutDebit;

  /// No description provided for @familyIncludesLine.
  ///
  /// In en, this message translates to:
  /// **'Includes Family hisab: in {moneyIn} · out {moneyOut}'**
  String familyIncludesLine(String moneyIn, String moneyOut);

  /// No description provided for @familyInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get familyInvite;

  /// No description provided for @familyInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite to Family hisab'**
  String get familyInviteTitle;

  /// No description provided for @familyMakeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make admin'**
  String get familyMakeAdmin;

  /// No description provided for @familyRemoveAdmin.
  ///
  /// In en, this message translates to:
  /// **'Remove admin'**
  String get familyRemoveAdmin;

  /// No description provided for @familyNowAdmin.
  ///
  /// In en, this message translates to:
  /// **'{name} is now an admin'**
  String familyNowAdmin(String name);

  /// No description provided for @familyNowMember.
  ///
  /// In en, this message translates to:
  /// **'{name} is now a member'**
  String familyNowMember(String name);

  /// No description provided for @familyJoinWithCode.
  ///
  /// In en, this message translates to:
  /// **'Join with a code'**
  String get familyJoinWithCode;

  /// No description provided for @familyInviteShareText.
  ///
  /// In en, this message translates to:
  /// **'👋 *Join our Family hisab on HisabMitra!*\n\n🏠 Family hisab: *{family}*\n🔑 Invite code: *{code}*\n\nOpen HisabMitra → More → Family hisab → Join with a code, and enter the code.\n\n⏳ The code is valid till *{date}*.'**
  String familyInviteShareText(String family, String code, String date);

  /// No description provided for @familyInviteShareTextLink.
  ///
  /// In en, this message translates to:
  /// **'👋 *Join our Family hisab on HisabMitra!*\n\n🏠 Family hisab: *{family}*\n🔑 Invite code: *{code}*\n\n👉 Tap to join: {link}\nOr open HisabMitra → More → Family hisab → Join with a code, and enter the code.\n\n⏳ The code is valid till *{date}*.'**
  String familyInviteShareTextLink(
    String family,
    String code,
    String link,
    String date,
  );

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Namaste, {name}'**
  String greeting(String name);

  /// No description provided for @greetingNoName.
  ///
  /// In en, this message translates to:
  /// **'Namaste!'**
  String get greetingNoName;

  /// No description provided for @dashboardBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Savings this period'**
  String get dashboardBalanceLabel;

  /// No description provided for @dashboardToReceive.
  ///
  /// In en, this message translates to:
  /// **'To receive'**
  String get dashboardToReceive;

  /// No description provided for @dashboardToPay.
  ///
  /// In en, this message translates to:
  /// **'To pay'**
  String get dashboardToPay;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @actionAddIncome.
  ///
  /// In en, this message translates to:
  /// **'Add income'**
  String get actionAddIncome;

  /// No description provided for @actionAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get actionAddExpense;

  /// No description provided for @actionGiveMoney.
  ///
  /// In en, this message translates to:
  /// **'Give money'**
  String get actionGiveMoney;

  /// No description provided for @actionReceiveMoney.
  ///
  /// In en, this message translates to:
  /// **'Receive money'**
  String get actionReceiveMoney;

  /// No description provided for @actionCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get actionCreateGroup;

  /// No description provided for @actionGroupExpense.
  ///
  /// In en, this message translates to:
  /// **'Group expense'**
  String get actionGroupExpense;

  /// No description provided for @actionReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get actionReports;

  /// No description provided for @incomeVsExpense.
  ///
  /// In en, this message translates to:
  /// **'Income vs expense'**
  String get incomeVsExpense;

  /// No description provided for @lastSixMonths.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get lastSixMonths;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get recentTransactions;

  /// No description provided for @pendingRepayments.
  ///
  /// In en, this message translates to:
  /// **'Pending repayments'**
  String get pendingRepayments;

  /// No description provided for @upcomingReminders.
  ///
  /// In en, this message translates to:
  /// **'Upcoming reminders'**
  String get upcomingReminders;

  /// No description provided for @groupSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your groups'**
  String get groupSummaryTitle;

  /// No description provided for @groupSummaryLine.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No active groups} =1{1 active group} other{{count} active groups}}'**
  String groupSummaryLine(int count);

  /// No description provided for @youOwe.
  ///
  /// In en, this message translates to:
  /// **'You owe'**
  String get youOwe;

  /// No description provided for @youAreOwed.
  ///
  /// In en, this message translates to:
  /// **'You are owed'**
  String get youAreOwed;

  /// No description provided for @welcomeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start your hisab'**
  String get welcomeEmptyTitle;

  /// No description provided for @welcomeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense or income. It takes just a few seconds.'**
  String get welcomeEmptyBody;

  /// No description provided for @noTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noTransactionsTitle;

  /// No description provided for @noTransactionsBody.
  ///
  /// In en, this message translates to:
  /// **'Entries you add will appear here, grouped by date.'**
  String get noTransactionsBody;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get noResultsTitle;

  /// No description provided for @noResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or clear the filters.'**
  String get noResultsBody;

  /// No description provided for @selectPickPeriod.
  ///
  /// In en, this message translates to:
  /// **'Choose period'**
  String get selectPickPeriod;

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Hisab'**
  String get transactionsTitle;

  /// No description provided for @searchTransactionsHint.
  ///
  /// In en, this message translates to:
  /// **'Search description, notes, category, person'**
  String get searchTransactionsHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterType;

  /// No description provided for @filterClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get filterClearAll;

  /// No description provided for @addIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add income'**
  String get addIncomeTitle;

  /// No description provided for @addExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpenseTitle;

  /// No description provided for @editTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editTransactionTitle;

  /// No description provided for @transactionDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Entry details'**
  String get transactionDetailsTitle;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get amountHint;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Vegetables from market'**
  String get descriptionHint;

  /// No description provided for @personOptional.
  ///
  /// In en, this message translates to:
  /// **'Person (optional)'**
  String get personOptional;

  /// No description provided for @addNewPerson.
  ///
  /// In en, this message translates to:
  /// **'Add new person'**
  String get addNewPerson;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manageCategories;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseCategory;

  /// No description provided for @transactionSaved.
  ///
  /// In en, this message translates to:
  /// **'Entry saved'**
  String get transactionSaved;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get transactionDeleted;

  /// No description provided for @deleteTransactionMessage.
  ///
  /// In en, this message translates to:
  /// **'This entry and its attachments will be deleted from your account and this phone.'**
  String get deleteTransactionMessage;

  /// No description provided for @dayNet.
  ///
  /// In en, this message translates to:
  /// **'Net {amount}'**
  String dayNet(String amount);

  /// No description provided for @monthIncomeShort.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get monthIncomeShort;

  /// No description provided for @monthExpenseShort.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get monthExpenseShort;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @categoryNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'Name (English)'**
  String get categoryNameEnglish;

  /// No description provided for @categoryNameGujarati.
  ///
  /// In en, this message translates to:
  /// **'Name (Gujarati)'**
  String get categoryNameGujarati;

  /// No description provided for @categoryIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get categoryIcon;

  /// No description provided for @categoryColor.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get categoryColor;

  /// No description provided for @categoryType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get categoryType;

  /// No description provided for @categoryUsage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Not used yet} =1{Used in 1 entry} other{Used in {count} entries}}'**
  String categoryUsage(int count);

  /// No description provided for @categoryDeleteInUseTitle.
  ///
  /// In en, this message translates to:
  /// **'Move entries before deleting'**
  String get categoryDeleteInUseTitle;

  /// No description provided for @categoryDeleteInUseBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry uses this category.} other{{count} entries use this category.}} Choose where to move them.'**
  String categoryDeleteInUseBody(int count);

  /// No description provided for @categoryMoveAndDelete.
  ///
  /// In en, this message translates to:
  /// **'Move & delete'**
  String get categoryMoveAndDelete;

  /// No description provided for @calculatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculatorTitle;

  /// No description provided for @calculatorBasic.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculatorBasic;

  /// No description provided for @calculatorUnit.
  ///
  /// In en, this message translates to:
  /// **'Price × Qty'**
  String get calculatorUnit;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get unitPrice;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @calculatorUseAmount.
  ///
  /// In en, this message translates to:
  /// **'Use {amount}'**
  String calculatorUseAmount(String amount);

  /// No description provided for @calculatorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Incomplete expression'**
  String get calculatorInvalid;

  /// No description provided for @calculatorCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy result'**
  String get calculatorCopy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food & Dining'**
  String get catFood;

  /// No description provided for @catGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get catGroceries;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get catFuel;

  /// No description provided for @catShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// No description provided for @catBills.
  ///
  /// In en, this message translates to:
  /// **'Bills & Utilities'**
  String get catBills;

  /// No description provided for @catRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get catRent;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @catEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get catEducation;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @catTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get catTravel;

  /// No description provided for @catFestivals.
  ///
  /// In en, this message translates to:
  /// **'Festivals & Gifts'**
  String get catFestivals;

  /// No description provided for @catHousehold.
  ///
  /// In en, this message translates to:
  /// **'Household'**
  String get catHousehold;

  /// No description provided for @catMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile & Internet'**
  String get catMobile;

  /// No description provided for @catPersonalCare.
  ///
  /// In en, this message translates to:
  /// **'Personal Care'**
  String get catPersonalCare;

  /// No description provided for @catDonation.
  ///
  /// In en, this message translates to:
  /// **'Donation'**
  String get catDonation;

  /// No description provided for @catOtherExpense.
  ///
  /// In en, this message translates to:
  /// **'Other Expense'**
  String get catOtherExpense;

  /// No description provided for @catSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get catSalary;

  /// No description provided for @catBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get catBusiness;

  /// No description provided for @catFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get catFreelance;

  /// No description provided for @catInterest.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get catInterest;

  /// No description provided for @catRentalIncome.
  ///
  /// In en, this message translates to:
  /// **'Rental Income'**
  String get catRentalIncome;

  /// No description provided for @catGiftsReceived.
  ///
  /// In en, this message translates to:
  /// **'Gifts Received'**
  String get catGiftsReceived;

  /// No description provided for @catRefund.
  ///
  /// In en, this message translates to:
  /// **'Refunds'**
  String get catRefund;

  /// No description provided for @catOtherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other Income'**
  String get catOtherIncome;

  /// No description provided for @errorRepaymentExceeds.
  ///
  /// In en, this message translates to:
  /// **'The amount is more than what is still due.'**
  String get errorRepaymentExceeds;

  /// No description provided for @errorSplitInvalid.
  ///
  /// In en, this message translates to:
  /// **'The split does not add up to the total.'**
  String get errorSplitInvalid;

  /// No description provided for @errorCategoryType.
  ///
  /// In en, this message translates to:
  /// **'Choose a category of the same type.'**
  String get errorCategoryType;

  /// No description provided for @errorPersonOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Settle all pending amounts with this person before deleting.'**
  String get errorPersonOutstanding;

  /// No description provided for @errorPrincipalBelowRepaid.
  ///
  /// In en, this message translates to:
  /// **'The amount cannot be less than what has already been repaid.'**
  String get errorPrincipalBelowRepaid;

  /// No description provided for @errorMemberInUse.
  ///
  /// In en, this message translates to:
  /// **'This member has expenses or settlements, so they cannot be removed.'**
  String get errorMemberInUse;

  /// No description provided for @errorSettlementExceeds.
  ///
  /// In en, this message translates to:
  /// **'This is more than the payer owes or the receiver is owed.'**
  String get errorSettlementExceeds;

  /// No description provided for @errorSameMember.
  ///
  /// In en, this message translates to:
  /// **'Payer and receiver must be different.'**
  String get errorSameMember;

  /// No description provided for @errorGroupShared.
  ///
  /// In en, this message translates to:
  /// **'Shared groups cannot be deleted. Archive it instead.'**
  String get errorGroupShared;

  /// No description provided for @transactionsShowList.
  ///
  /// In en, this message translates to:
  /// **'Show as list'**
  String get transactionsShowList;

  /// No description provided for @transactionsShowSheet.
  ///
  /// In en, this message translates to:
  /// **'Show as sheet'**
  String get transactionsShowSheet;

  /// No description provided for @runningBalance.
  ///
  /// In en, this message translates to:
  /// **'Running balance'**
  String get runningBalance;

  /// No description provided for @sheetTip.
  ///
  /// In en, this message translates to:
  /// **'Oldest first, like a khata. Tap a row to open it.'**
  String get sheetTip;

  /// No description provided for @groupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupsTitle;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroup;

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get editGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Goa trip 2026'**
  String get groupNameHint;

  /// No description provided for @groupType.
  ///
  /// In en, this message translates to:
  /// **'Group type'**
  String get groupType;

  /// No description provided for @groupTypeTrip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get groupTypeTrip;

  /// No description provided for @groupTypeFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get groupTypeFamily;

  /// No description provided for @groupTypeFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get groupTypeFriends;

  /// No description provided for @groupTypeEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get groupTypeEvent;

  /// No description provided for @groupTypeHousehold.
  ///
  /// In en, this message translates to:
  /// **'Household'**
  String get groupTypeHousehold;

  /// No description provided for @groupTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get groupTypeOther;

  /// No description provided for @groupMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get groupMembers;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get addMember;

  /// No description provided for @memberName.
  ///
  /// In en, this message translates to:
  /// **'Member name'**
  String get memberName;

  /// No description provided for @memberYou.
  ///
  /// In en, this message translates to:
  /// **'{name} (you)'**
  String memberYou(String name);

  /// No description provided for @fromPeople.
  ///
  /// In en, this message translates to:
  /// **'From people'**
  String get fromPeople;

  /// No description provided for @memberCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String memberCount(int count);

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get totalSpent;

  /// No description provided for @yourBalance.
  ///
  /// In en, this message translates to:
  /// **'Your balance'**
  String get yourBalance;

  /// No description provided for @showArchived.
  ///
  /// In en, this message translates to:
  /// **'Show archived'**
  String get showArchived;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @archiveGroup.
  ///
  /// In en, this message translates to:
  /// **'Archive group'**
  String get archiveGroup;

  /// No description provided for @unarchiveGroup.
  ///
  /// In en, this message translates to:
  /// **'Restore group'**
  String get unarchiveGroup;

  /// No description provided for @deleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete group'**
  String get deleteGroup;

  /// No description provided for @deleteGroupMessage.
  ///
  /// In en, this message translates to:
  /// **'This group and all its expenses will be deleted from this phone.'**
  String get deleteGroupMessage;

  /// No description provided for @noGroupsTitle.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get noGroupsTitle;

  /// No description provided for @noGroupsBody.
  ///
  /// In en, this message translates to:
  /// **'Create a group for a trip, family or event and split expenses fairly.'**
  String get noGroupsBody;

  /// No description provided for @groupSaved.
  ///
  /// In en, this message translates to:
  /// **'Group saved'**
  String get groupSaved;

  /// No description provided for @groupExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get groupExpenses;

  /// No description provided for @groupBalances.
  ///
  /// In en, this message translates to:
  /// **'Balances'**
  String get groupBalances;

  /// No description provided for @addGroupExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addGroupExpense;

  /// No description provided for @editGroupExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get editGroupExpense;

  /// No description provided for @groupExpenseDetail.
  ///
  /// In en, this message translates to:
  /// **'Expense details'**
  String get groupExpenseDetail;

  /// No description provided for @paidBy.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get paidBy;

  /// No description provided for @paidByName.
  ///
  /// In en, this message translates to:
  /// **'Paid by {name}'**
  String paidByName(String name);

  /// No description provided for @splitMethod.
  ///
  /// In en, this message translates to:
  /// **'Split method'**
  String get splitMethod;

  /// No description provided for @splitEqual.
  ///
  /// In en, this message translates to:
  /// **'Equally'**
  String get splitEqual;

  /// No description provided for @splitExact.
  ///
  /// In en, this message translates to:
  /// **'Exact amounts'**
  String get splitExact;

  /// No description provided for @splitPercentage.
  ///
  /// In en, this message translates to:
  /// **'Percentages'**
  String get splitPercentage;

  /// No description provided for @splitRatio.
  ///
  /// In en, this message translates to:
  /// **'Ratio / shares'**
  String get splitRatio;

  /// No description provided for @splitAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Unequal (+/−)'**
  String get splitAdjustment;

  /// No description provided for @splitEqualHelp.
  ///
  /// In en, this message translates to:
  /// **'Split equally among the selected people.'**
  String get splitEqualHelp;

  /// No description provided for @splitExactHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter how much each person owes. It must add up to the total.'**
  String get splitExactHelp;

  /// No description provided for @splitPercentageHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter a percentage for each person. It must add up to 100%.'**
  String get splitPercentageHelp;

  /// No description provided for @splitRatioHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter shares, e.g. 2 for a couple and 1 for a single person.'**
  String get splitRatioHelp;

  /// No description provided for @splitAdjustmentHelp.
  ///
  /// In en, this message translates to:
  /// **'Equal split, plus or minus an extra amount for some people.'**
  String get splitAdjustmentHelp;

  /// No description provided for @participants.
  ///
  /// In en, this message translates to:
  /// **'Split between'**
  String get participants;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @splitPreview.
  ///
  /// In en, this message translates to:
  /// **'Split preview'**
  String get splitPreview;

  /// No description provided for @splitRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining {amount}'**
  String splitRemaining(String amount);

  /// No description provided for @splitOver.
  ///
  /// In en, this message translates to:
  /// **'Over by {amount}'**
  String splitOver(String amount);

  /// No description provided for @percentTotal.
  ///
  /// In en, this message translates to:
  /// **'Total {percent}%'**
  String percentTotal(String percent);

  /// No description provided for @splitNeedsParticipants.
  ///
  /// In en, this message translates to:
  /// **'Select at least one person.'**
  String get splitNeedsParticipants;

  /// No description provided for @splitAdjustmentsTooBig.
  ///
  /// In en, this message translates to:
  /// **'Adjustments are larger than the total.'**
  String get splitAdjustmentsTooBig;

  /// No description provided for @splitNegativeShare.
  ///
  /// In en, this message translates to:
  /// **'An adjustment makes someone\'s share negative.'**
  String get splitNegativeShare;

  /// No description provided for @splitZeroShares.
  ///
  /// In en, this message translates to:
  /// **'Enter at least one share.'**
  String get splitZeroShares;

  /// No description provided for @groupExpenseSaved.
  ///
  /// In en, this message translates to:
  /// **'Expense saved'**
  String get groupExpenseSaved;

  /// No description provided for @deleteGroupExpenseMessage.
  ///
  /// In en, this message translates to:
  /// **'This expense will be removed from the group balances.'**
  String get deleteGroupExpenseMessage;

  /// No description provided for @owes.
  ///
  /// In en, this message translates to:
  /// **'owes'**
  String get owes;

  /// No description provided for @getsBack.
  ///
  /// In en, this message translates to:
  /// **'gets back'**
  String get getsBack;

  /// No description provided for @settledUp.
  ///
  /// In en, this message translates to:
  /// **'settled up'**
  String get settledUp;

  /// No description provided for @suggestedSettlements.
  ///
  /// In en, this message translates to:
  /// **'Suggested settlements'**
  String get suggestedSettlements;

  /// No description provided for @settleUp.
  ///
  /// In en, this message translates to:
  /// **'Settle up'**
  String get settleUp;

  /// No description provided for @recordSettlement.
  ///
  /// In en, this message translates to:
  /// **'Record settlement'**
  String get recordSettlement;

  /// No description provided for @settlementFrom.
  ///
  /// In en, this message translates to:
  /// **'Who paid'**
  String get settlementFrom;

  /// No description provided for @settlementTo.
  ///
  /// In en, this message translates to:
  /// **'Who received'**
  String get settlementTo;

  /// No description provided for @settlementSaved.
  ///
  /// In en, this message translates to:
  /// **'Settlement recorded'**
  String get settlementSaved;

  /// No description provided for @settlementHistory.
  ///
  /// In en, this message translates to:
  /// **'Settlement history'**
  String get settlementHistory;

  /// No description provided for @noSettlements.
  ///
  /// In en, this message translates to:
  /// **'No settlements yet'**
  String get noSettlements;

  /// No description provided for @deleteSettlementConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this settlement? Balances will change back.'**
  String get deleteSettlementConfirm;

  /// No description provided for @groupAllSettled.
  ///
  /// In en, this message translates to:
  /// **'Everyone is settled up'**
  String get groupAllSettled;

  /// No description provided for @paysTo.
  ///
  /// In en, this message translates to:
  /// **'{from} pays {to}'**
  String paysTo(String from, String to);

  /// No description provided for @maxSettlement.
  ///
  /// In en, this message translates to:
  /// **'Up to {amount}'**
  String maxSettlement(String amount);

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @memberShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get memberShare;

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get net;

  /// No description provided for @settlementStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get settlementStatus;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusPartlySettled.
  ///
  /// In en, this message translates to:
  /// **'Partly settled'**
  String get statusPartlySettled;

  /// No description provided for @statusSettledShort.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get statusSettledShort;

  /// No description provided for @viewSpreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Sheet'**
  String get viewSpreadsheet;

  /// No description provided for @viewCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get viewCards;

  /// No description provided for @viewTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get viewTimeline;

  /// No description provided for @filterMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get filterMember;

  /// No description provided for @filterDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get filterDate;

  /// No description provided for @noGroupExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noGroupExpensesTitle;

  /// No description provided for @noGroupExpensesBody.
  ///
  /// In en, this message translates to:
  /// **'Add the first expense — the split will be calculated for you.'**
  String get noGroupExpensesBody;

  /// No description provided for @gcatFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get gcatFood;

  /// No description provided for @gcatTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get gcatTravel;

  /// No description provided for @gcatStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get gcatStay;

  /// No description provided for @gcatTickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get gcatTickets;

  /// No description provided for @gcatShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get gcatShopping;

  /// No description provided for @gcatGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get gcatGroceries;

  /// No description provided for @gcatFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get gcatFuel;

  /// No description provided for @gcatEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get gcatEntertainment;

  /// No description provided for @gcatGifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get gcatGifts;

  /// No description provided for @gcatUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get gcatUtilities;

  /// No description provided for @gcatRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get gcatRent;

  /// No description provided for @gcatOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get gcatOther;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get removeMember;

  /// No description provided for @renameMember.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameMember;

  /// No description provided for @memberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Member removed'**
  String get memberRemoved;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get roleMember;

  /// No description provided for @localParticipant.
  ///
  /// In en, this message translates to:
  /// **'On this phone only'**
  String get localParticipant;

  /// No description provided for @cloudMember.
  ///
  /// In en, this message translates to:
  /// **'Joined via app'**
  String get cloudMember;

  /// No description provided for @sharedGroup.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get sharedGroup;

  /// No description provided for @localGroup.
  ///
  /// In en, this message translates to:
  /// **'On this phone'**
  String get localGroup;

  /// No description provided for @pickGroup.
  ///
  /// In en, this message translates to:
  /// **'Choose a group'**
  String get pickGroup;

  /// No description provided for @timelineSettlement.
  ///
  /// In en, this message translates to:
  /// **'{from} paid {to}'**
  String timelineSettlement(String from, String to);

  /// No description provided for @expensesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No expenses} =1{1 expense} other{{count} expenses}}'**
  String expensesCount(int count);

  /// No description provided for @inviteMembers.
  ///
  /// In en, this message translates to:
  /// **'Invite members'**
  String get inviteMembers;

  /// No description provided for @joinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join a group'**
  String get joinGroup;

  /// No description provided for @khataTitle.
  ///
  /// In en, this message translates to:
  /// **'Khata'**
  String get khataTitle;

  /// No description provided for @ledgerGivenLabel.
  ///
  /// In en, this message translates to:
  /// **'I gave'**
  String get ledgerGivenLabel;

  /// No description provided for @ledgerTakenLabel.
  ///
  /// In en, this message translates to:
  /// **'I took'**
  String get ledgerTakenLabel;

  /// No description provided for @ledgerGivenLong.
  ///
  /// In en, this message translates to:
  /// **'Money given — they owe you'**
  String get ledgerGivenLong;

  /// No description provided for @ledgerTakenLong.
  ///
  /// In en, this message translates to:
  /// **'Money taken — you owe them'**
  String get ledgerTakenLong;

  /// No description provided for @netBalance.
  ///
  /// In en, this message translates to:
  /// **'Net balance'**
  String get netBalance;

  /// No description provided for @owesYou.
  ///
  /// In en, this message translates to:
  /// **'{name} owes you'**
  String owesYou(String name);

  /// No description provided for @youOweName.
  ///
  /// In en, this message translates to:
  /// **'You owe {name}'**
  String youOweName(String name);

  /// No description provided for @allSettled.
  ///
  /// In en, this message translates to:
  /// **'All settled'**
  String get allSettled;

  /// No description provided for @statusOpen.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusOpen;

  /// No description provided for @statusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partly paid'**
  String get statusPartial;

  /// No description provided for @statusSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get statusSettled;

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOn(String date);

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @principal.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get principal;

  /// No description provided for @repaid.
  ///
  /// In en, this message translates to:
  /// **'Repaid'**
  String get repaid;

  /// No description provided for @outstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// No description provided for @recordRepayment.
  ///
  /// In en, this message translates to:
  /// **'Record repayment'**
  String get recordRepayment;

  /// No description provided for @repaymentReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Money received back'**
  String get repaymentReceivedTitle;

  /// No description provided for @repaymentPaidTitle.
  ///
  /// In en, this message translates to:
  /// **'Money returned'**
  String get repaymentPaidTitle;

  /// No description provided for @repaymentSaved.
  ///
  /// In en, this message translates to:
  /// **'Repayment recorded'**
  String get repaymentSaved;

  /// No description provided for @repaymentExceedsTitle.
  ///
  /// In en, this message translates to:
  /// **'More than the due amount'**
  String get repaymentExceedsTitle;

  /// No description provided for @repaymentExceedsBody.
  ///
  /// In en, this message translates to:
  /// **'Only {due} is due. Record the extra {extra} as an advance / credit in the other direction?'**
  String repaymentExceedsBody(String due, String extra);

  /// No description provided for @recordAsAdvance.
  ///
  /// In en, this message translates to:
  /// **'Record as advance'**
  String get recordAsAdvance;

  /// No description provided for @advanceCredit.
  ///
  /// In en, this message translates to:
  /// **'Advance / credit'**
  String get advanceCredit;

  /// No description provided for @repaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Repayment history'**
  String get repaymentHistory;

  /// No description provided for @noRepayments.
  ///
  /// In en, this message translates to:
  /// **'No repayments yet'**
  String get noRepayments;

  /// No description provided for @ledgerEntries.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get ledgerEntries;

  /// No description provided for @noLedgerTitle.
  ///
  /// In en, this message translates to:
  /// **'Your khata is empty'**
  String get noLedgerTitle;

  /// No description provided for @noLedgerBody.
  ///
  /// In en, this message translates to:
  /// **'Record money you give or take and keep track of repayments.'**
  String get noLedgerBody;

  /// No description provided for @dueDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Due date (optional)'**
  String get dueDateOptional;

  /// No description provided for @ledgerEntryTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New khata entry'**
  String get ledgerEntryTitleNew;

  /// No description provided for @ledgerEntryTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit khata entry'**
  String get ledgerEntryTitleEdit;

  /// No description provided for @ledgerEntryDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Khata entry'**
  String get ledgerEntryDetailTitle;

  /// No description provided for @ledgerSaved.
  ///
  /// In en, this message translates to:
  /// **'Khata entry saved'**
  String get ledgerSaved;

  /// No description provided for @deleteLedgerMessage.
  ///
  /// In en, this message translates to:
  /// **'This entry and its repayment history will be deleted.'**
  String get deleteLedgerMessage;

  /// No description provided for @deleteRepaymentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this repayment? The outstanding amount will go up again.'**
  String get deleteRepaymentConfirm;

  /// No description provided for @filterToReceive.
  ///
  /// In en, this message translates to:
  /// **'To receive'**
  String get filterToReceive;

  /// No description provided for @filterToPay.
  ///
  /// In en, this message translates to:
  /// **'To pay'**
  String get filterToPay;

  /// No description provided for @filterSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get filterSettled;

  /// No description provided for @peopleTitle.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get peopleTitle;

  /// No description provided for @addPerson.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get addPerson;

  /// No description provided for @editPerson.
  ///
  /// In en, this message translates to:
  /// **'Edit person'**
  String get editPerson;

  /// No description provided for @personName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get personName;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumber;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @pickFromContacts.
  ///
  /// In en, this message translates to:
  /// **'Choose from contacts'**
  String get pickFromContacts;

  /// No description provided for @contactsHint.
  ///
  /// In en, this message translates to:
  /// **'Only the contact you choose is read. HisabMitra cannot see your other contacts.'**
  String get contactsHint;

  /// No description provided for @personSaved.
  ///
  /// In en, this message translates to:
  /// **'Person saved'**
  String get personSaved;

  /// No description provided for @deletePersonMessage.
  ///
  /// In en, this message translates to:
  /// **'This person and their settled khata history will be deleted.'**
  String get deletePersonMessage;

  /// No description provided for @noPeopleTitle.
  ///
  /// In en, this message translates to:
  /// **'No people yet'**
  String get noPeopleTitle;

  /// No description provided for @noPeopleBody.
  ///
  /// In en, this message translates to:
  /// **'Add people you lend money to or borrow from.'**
  String get noPeopleBody;

  /// No description provided for @searchPeople.
  ///
  /// In en, this message translates to:
  /// **'Search people'**
  String get searchPeople;

  /// No description provided for @totalGiven.
  ///
  /// In en, this message translates to:
  /// **'Total given'**
  String get totalGiven;

  /// No description provided for @totalTaken.
  ///
  /// In en, this message translates to:
  /// **'Total taken'**
  String get totalTaken;

  /// No description provided for @personTransactions.
  ///
  /// In en, this message translates to:
  /// **'Income & expenses'**
  String get personTransactions;

  /// No description provided for @callPerson.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callPerson;

  /// No description provided for @selectPerson.
  ///
  /// In en, this message translates to:
  /// **'Select person'**
  String get selectPerson;

  /// No description provided for @addEntry.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get addEntry;

  /// No description provided for @remindLater.
  ///
  /// In en, this message translates to:
  /// **'Set reminder'**
  String get remindLater;

  /// No description provided for @repaymentFor.
  ///
  /// In en, this message translates to:
  /// **'For: {description}'**
  String repaymentFor(String description);

  /// No description provided for @repaidProgress.
  ///
  /// In en, this message translates to:
  /// **'{repaid} of {total} repaid'**
  String repaidProgress(String repaid, String total);

  /// No description provided for @settlementHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Settlement history'**
  String get settlementHistoryTitle;

  /// No description provided for @ledgerNotIncomeNote.
  ///
  /// In en, this message translates to:
  /// **'Khata entries are loans, not income or expense, so they do not change your savings.'**
  String get ledgerNotIncomeNote;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTransactions.
  ///
  /// In en, this message translates to:
  /// **'Hisab'**
  String get navTransactions;

  /// No description provided for @navPeople.
  ///
  /// In en, this message translates to:
  /// **'Khata'**
  String get navPeople;

  /// No description provided for @navGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get navGroups;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this any time in Settings.'**
  String get languageSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGujarati.
  ///
  /// In en, this message translates to:
  /// **'ગુજરાતી (Gujarati)'**
  String get languageGujarati;

  /// No description provided for @onboardTitle1.
  ///
  /// In en, this message translates to:
  /// **'Your daily hisab, made simple'**
  String get onboardTitle1;

  /// No description provided for @onboardBody1.
  ///
  /// In en, this message translates to:
  /// **'Record income and expenses in seconds. Saved to your account, and it works without internet too.'**
  String get onboardBody1;

  /// No description provided for @onboardTitle2.
  ///
  /// In en, this message translates to:
  /// **'Lend, borrow, settle'**
  String get onboardTitle2;

  /// No description provided for @onboardBody2.
  ///
  /// In en, this message translates to:
  /// **'Keep a clear khata of money given and taken, with partial repayments and gentle reminders.'**
  String get onboardBody2;

  /// No description provided for @onboardTitle3.
  ///
  /// In en, this message translates to:
  /// **'Share expenses with family & friends'**
  String get onboardTitle3;

  /// No description provided for @onboardBody3.
  ///
  /// In en, this message translates to:
  /// **'Split trip, festival and household costs fairly — right down to the last paisa.'**
  String get onboardBody3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get profileSetupTitle;

  /// No description provided for @profileSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, email and mobile number are required. We verify your email; your hisab is saved to this account.'**
  String get profileSetupSubtitle;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @startUsing.
  ///
  /// In en, this message translates to:
  /// **'Start using HisabMitra'**
  String get startUsing;

  /// No description provided for @privacyPromise.
  ///
  /// In en, this message translates to:
  /// **'Your hisab is saved to your account, and only you can see it.'**
  String get privacyPromise;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addReminder;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get editReminder;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'What to remember'**
  String get reminderTitle;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reminderTime;

  /// No description provided for @reminderRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get reminderRepeat;

  /// No description provided for @repeatNone.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get repeatNone;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get repeatMonthly;

  /// No description provided for @reminderKind.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get reminderKind;

  /// No description provided for @kindRepayment.
  ///
  /// In en, this message translates to:
  /// **'Repay money'**
  String get kindRepayment;

  /// No description provided for @kindCollection.
  ///
  /// In en, this message translates to:
  /// **'Collect money'**
  String get kindCollection;

  /// No description provided for @kindGroupSettlement.
  ///
  /// In en, this message translates to:
  /// **'Group settlement'**
  String get kindGroupSettlement;

  /// No description provided for @kindCustom.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get kindCustom;

  /// No description provided for @reminderSaved.
  ///
  /// In en, this message translates to:
  /// **'Reminder set'**
  String get reminderSaved;

  /// No description provided for @reminderDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get reminderDone;

  /// No description provided for @reminderCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel reminder'**
  String get reminderCancel;

  /// No description provided for @reminderUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get reminderUpcoming;

  /// No description provided for @reminderHistory.
  ///
  /// In en, this message translates to:
  /// **'Done & cancelled'**
  String get reminderHistory;

  /// No description provided for @noRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'No reminders'**
  String get noRemindersTitle;

  /// No description provided for @noRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'Set reminders for repayments, collections or bills.'**
  String get noRemindersBody;

  /// No description provided for @reminderPast.
  ///
  /// In en, this message translates to:
  /// **'This time has already passed.'**
  String get reminderPast;

  /// No description provided for @notificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for HisabMitra. You can turn them on in Android settings.'**
  String get notificationsDenied;

  /// No description provided for @notificationGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'HisabMitra reminder'**
  String get notificationGenericTitle;

  /// No description provided for @notificationGenericBody.
  ///
  /// In en, this message translates to:
  /// **'Open HisabMitra to see your reminder.'**
  String get notificationGenericBody;

  /// No description provided for @reminderCollectTitle.
  ///
  /// In en, this message translates to:
  /// **'Collect {amount} from {name}'**
  String reminderCollectTitle(String amount, String name);

  /// No description provided for @reminderRepayTitle.
  ///
  /// In en, this message translates to:
  /// **'Repay {amount} to {name}'**
  String reminderRepayTitle(String amount, String name);

  /// No description provided for @reminderSettleTitle.
  ///
  /// In en, this message translates to:
  /// **'Settle up in {group}'**
  String reminderSettleTitle(String group);

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @kindEmi.
  ///
  /// In en, this message translates to:
  /// **'EMI'**
  String get kindEmi;

  /// No description provided for @kindSip.
  ///
  /// In en, this message translates to:
  /// **'SIP'**
  String get kindSip;

  /// No description provided for @kindInstallment.
  ///
  /// In en, this message translates to:
  /// **'Installment'**
  String get kindInstallment;

  /// No description provided for @kindMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get kindMaintenance;

  /// No description provided for @kindInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance premium'**
  String get kindInsurance;

  /// No description provided for @kindRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get kindRent;

  /// No description provided for @kindSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get kindSubscription;

  /// No description provided for @kindBill.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get kindBill;

  /// No description provided for @repeatQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Every 3 months'**
  String get repeatQuarterly;

  /// No description provided for @repeatHalfYearly.
  ///
  /// In en, this message translates to:
  /// **'Every 6 months'**
  String get repeatHalfYearly;

  /// No description provided for @repeatYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get repeatYearly;

  /// No description provided for @reminderTypePayment.
  ///
  /// In en, this message translates to:
  /// **'Recurring payment'**
  String get reminderTypePayment;

  /// No description provided for @reminderTypeReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminderTypeReminder;

  /// No description provided for @paymentType.
  ///
  /// In en, this message translates to:
  /// **'Payment type'**
  String get paymentType;

  /// No description provided for @paymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Fixed amount'**
  String get paymentAmount;

  /// No description provided for @paymentCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense category'**
  String get paymentCategory;

  /// No description provided for @paymentCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Used when you record the payment'**
  String get paymentCategoryHint;

  /// No description provided for @paymentEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get paymentEnds;

  /// No description provided for @paymentEndsNever.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get paymentEndsNever;

  /// No description provided for @paymentEndsAfter.
  ///
  /// In en, this message translates to:
  /// **'After a number of payments'**
  String get paymentEndsAfter;

  /// No description provided for @paymentCount.
  ///
  /// In en, this message translates to:
  /// **'Total number of payments'**
  String get paymentCount;

  /// No description provided for @paymentProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} paid'**
  String paymentProgress(int done, int total);

  /// No description provided for @paymentsPaidSoFar.
  ///
  /// In en, this message translates to:
  /// **'{count} paid so far'**
  String paymentsPaidSoFar(int count);

  /// No description provided for @markPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark paid'**
  String get markPaid;

  /// No description provided for @recordPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Record this payment?'**
  String get recordPaymentTitle;

  /// No description provided for @recordPaymentBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} for {title}. Add it to your Hisab as an expense?'**
  String recordPaymentBody(String amount, String title);

  /// No description provided for @recordAsExpense.
  ///
  /// In en, this message translates to:
  /// **'Add as expense'**
  String get recordAsExpense;

  /// No description provided for @justMarkPaid.
  ///
  /// In en, this message translates to:
  /// **'Only mark paid'**
  String get justMarkPaid;

  /// No description provided for @paymentsDueThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Payments due this month'**
  String get paymentsDueThisMonth;

  /// No description provided for @addRecurringPayment.
  ///
  /// In en, this message translates to:
  /// **'Add recurring payment'**
  String get addRecurringPayment;

  /// No description provided for @notificationPaymentBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} due'**
  String notificationPaymentBody(String amount);

  /// No description provided for @reminderBatteryTip.
  ///
  /// In en, this message translates to:
  /// **'On some phones (Xiaomi, Oppo, Vivo and others) battery saving can stop reminders. Allow HisabMitra to run in the background so they arrive on time.'**
  String get reminderBatteryTip;

  /// No description provided for @reminderBatteryTipOpen.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get reminderBatteryTipOpen;

  /// No description provided for @reminderBatteryTipDismiss.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get reminderBatteryTipDismiss;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @reportOverview.
  ///
  /// In en, this message translates to:
  /// **'Income & expense'**
  String get reportOverview;

  /// No description provided for @reportOverviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Monthly income, expense and savings'**
  String get reportOverviewDesc;

  /// No description provided for @reportCategories.
  ///
  /// In en, this message translates to:
  /// **'Category-wise spending'**
  String get reportCategories;

  /// No description provided for @reportCategoriesDesc.
  ///
  /// In en, this message translates to:
  /// **'Where your money went'**
  String get reportCategoriesDesc;

  /// No description provided for @reportPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get reportPaymentMethods;

  /// No description provided for @reportPaymentMethodsDesc.
  ///
  /// In en, this message translates to:
  /// **'Cash, UPI, cards and bank'**
  String get reportPaymentMethodsDesc;

  /// No description provided for @reportPeople.
  ///
  /// In en, this message translates to:
  /// **'Lending & borrowing'**
  String get reportPeople;

  /// No description provided for @reportPeopleDesc.
  ///
  /// In en, this message translates to:
  /// **'Person-wise khata for the period'**
  String get reportPeopleDesc;

  /// No description provided for @reportGroups.
  ///
  /// In en, this message translates to:
  /// **'Group expenses'**
  String get reportGroups;

  /// No description provided for @reportGroupsDesc.
  ///
  /// In en, this message translates to:
  /// **'Spending and settlements in groups'**
  String get reportGroupsDesc;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV (Excel)'**
  String get exportCsv;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the export file.'**
  String get exportFailed;

  /// No description provided for @monthlyBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Monthly breakdown'**
  String get monthlyBreakdown;

  /// No description provided for @topExpenses.
  ///
  /// In en, this message translates to:
  /// **'Top expenses'**
  String get topExpenses;

  /// No description provided for @loansGiven.
  ///
  /// In en, this message translates to:
  /// **'Money given (loans)'**
  String get loansGiven;

  /// No description provided for @loansTaken.
  ///
  /// In en, this message translates to:
  /// **'Money taken (loans)'**
  String get loansTaken;

  /// No description provided for @repaymentsReceived.
  ///
  /// In en, this message translates to:
  /// **'Repayments received'**
  String get repaymentsReceived;

  /// No description provided for @repaymentsPaid.
  ///
  /// In en, this message translates to:
  /// **'Repayments made'**
  String get repaymentsPaid;

  /// No description provided for @groupSettlementsLabel.
  ///
  /// In en, this message translates to:
  /// **'Group settlements'**
  String get groupSettlementsLabel;

  /// No description provided for @reportSeparationNote.
  ///
  /// In en, this message translates to:
  /// **'Loans, repayments and group settlements are shown separately. They are not counted as income or expense.'**
  String get reportSeparationNote;

  /// No description provided for @generatedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated on {date} by HisabMitra'**
  String generatedOn(String date);

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String pageOf(int page, int total);

  /// No description provided for @reportPeriod.
  ///
  /// In en, this message translates to:
  /// **'{from} – {to}'**
  String reportPeriod(String from, String to);

  /// No description provided for @colType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get colType;

  /// No description provided for @colMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get colMonth;

  /// No description provided for @colCount.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get colCount;

  /// No description provided for @colShare.
  ///
  /// In en, this message translates to:
  /// **'% of total'**
  String get colShare;

  /// No description provided for @myShare.
  ///
  /// In en, this message translates to:
  /// **'My share'**
  String get myShare;

  /// No description provided for @iPaid.
  ///
  /// In en, this message translates to:
  /// **'I paid'**
  String get iPaid;

  /// No description provided for @noDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No records in this period'**
  String get noDataForPeriod;

  /// No description provided for @transactionsExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsExportTitle;

  /// No description provided for @fullReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial report'**
  String get fullReportTitle;

  /// No description provided for @settlementSummary.
  ///
  /// In en, this message translates to:
  /// **'Settlement summary'**
  String get settlementSummary;

  /// No description provided for @shareReportCaption.
  ///
  /// In en, this message translates to:
  /// **'📊 *HisabMitra report* · {title} · {period}'**
  String shareReportCaption(String title, String period);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Colour theme'**
  String get settingsTheme;

  /// No description provided for @paletteRannUtsav.
  ///
  /// In en, this message translates to:
  /// **'Rann Utsav'**
  String get paletteRannUtsav;

  /// No description provided for @paletteRannUtsavDesc.
  ///
  /// In en, this message translates to:
  /// **'Navy, silver and red of the white Rann under a full moon'**
  String get paletteRannUtsavDesc;

  /// No description provided for @paletteBandhaniLal.
  ///
  /// In en, this message translates to:
  /// **'Bandhani Lal'**
  String get paletteBandhaniLal;

  /// No description provided for @paletteBandhaniLalDesc.
  ///
  /// In en, this message translates to:
  /// **'Maroon and kesar of the red chopda'**
  String get paletteBandhaniLalDesc;

  /// No description provided for @paletteKesariyo.
  ///
  /// In en, this message translates to:
  /// **'Kesariyo'**
  String get paletteKesariyo;

  /// No description provided for @paletteKesariyoDesc.
  ///
  /// In en, this message translates to:
  /// **'Saffron and plum of Navratri'**
  String get paletteKesariyoDesc;

  /// No description provided for @palettePatolaRani.
  ///
  /// In en, this message translates to:
  /// **'Patola Rani'**
  String get palettePatolaRani;

  /// No description provided for @palettePatolaRaniDesc.
  ///
  /// In en, this message translates to:
  /// **'Rani pink, turmeric and aubergine of Patan Patola'**
  String get palettePatolaRaniDesc;

  /// No description provided for @paletteNeelGagan.
  ///
  /// In en, this message translates to:
  /// **'Neel Gagan'**
  String get paletteNeelGagan;

  /// No description provided for @paletteNeelGaganDesc.
  ///
  /// In en, this message translates to:
  /// **'Sky blue and indigo of the Uttarayan sky'**
  String get paletteNeelGaganDesc;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get settingsFinance;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default currency'**
  String get settingsCurrency;

  /// No description provided for @currencyInr.
  ///
  /// In en, this message translates to:
  /// **'Indian Rupee (₹)'**
  String get currencyInr;

  /// No description provided for @settingsDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get settingsDateFormat;

  /// No description provided for @settingsNumberFormat.
  ///
  /// In en, this message translates to:
  /// **'Number format'**
  String get settingsNumberFormat;

  /// No description provided for @numberFormatIndian.
  ///
  /// In en, this message translates to:
  /// **'Indian (1,23,456.00)'**
  String get numberFormatIndian;

  /// No description provided for @numberFormatInternational.
  ///
  /// In en, this message translates to:
  /// **'International (123,456.00)'**
  String get numberFormatInternational;

  /// No description provided for @settingsCalculatorAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto-calculate total'**
  String get settingsCalculatorAuto;

  /// No description provided for @settingsCalculatorAutoDesc.
  ///
  /// In en, this message translates to:
  /// **'Update the amount when unit price or quantity changes'**
  String get settingsCalculatorAutoDesc;

  /// No description provided for @settingsGroupSection.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get settingsGroupSection;

  /// No description provided for @settingsDefaultGroupView.
  ///
  /// In en, this message translates to:
  /// **'Default group view'**
  String get settingsDefaultGroupView;

  /// No description provided for @groupViewSpreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet'**
  String get groupViewSpreadsheet;

  /// No description provided for @groupViewCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get groupViewCards;

  /// No description provided for @groupViewTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get groupViewTimeline;

  /// No description provided for @settingsGroupNotifications.
  ///
  /// In en, this message translates to:
  /// **'Group settlement reminders'**
  String get settingsGroupNotifications;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsReminderNotifications.
  ///
  /// In en, this message translates to:
  /// **'Reminder notifications'**
  String get settingsReminderNotifications;

  /// No description provided for @settingsHideAmounts.
  ///
  /// In en, this message translates to:
  /// **'Hide amounts in notifications'**
  String get settingsHideAmounts;

  /// No description provided for @settingsHideAmountsDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications show only a generic message'**
  String get settingsHideAmountsDesc;

  /// No description provided for @settingsSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync'**
  String get settingsSync;

  /// No description provided for @settingsSyncStatus.
  ///
  /// In en, this message translates to:
  /// **'Sync status'**
  String get settingsSyncStatus;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get settingsBackup;

  /// No description provided for @settingsBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Manual, automatic and encrypted backups'**
  String get settingsBackupDesc;

  /// No description provided for @autoBackupOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get autoBackupOff;

  /// No description provided for @settingsAi.
  ///
  /// In en, this message translates to:
  /// **'AI assistant'**
  String get settingsAi;

  /// No description provided for @settingsAiEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable AI assistant'**
  String get settingsAiEnabled;

  /// No description provided for @settingsAiEnabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Answers questions using calculations done on this device'**
  String get settingsAiEnabledDesc;

  /// No description provided for @settingsAiProvider.
  ///
  /// In en, this message translates to:
  /// **'Answer engine'**
  String get settingsAiProvider;

  /// No description provided for @aiProviderLocal.
  ///
  /// In en, this message translates to:
  /// **'On-device (private)'**
  String get aiProviderLocal;

  /// No description provided for @aiProviderOnline.
  ///
  /// In en, this message translates to:
  /// **'Online AI (Claude)'**
  String get aiProviderOnline;

  /// No description provided for @settingsAiConsent.
  ///
  /// In en, this message translates to:
  /// **'Allow sharing summaries with online AI'**
  String get settingsAiConsent;

  /// No description provided for @settingsAiConsentDesc.
  ///
  /// In en, this message translates to:
  /// **'Only totals needed to answer your question are sent. Raw transactions, notes and attachments are never sent.'**
  String get settingsAiConsentDesc;

  /// No description provided for @settingsAiShareNames.
  ///
  /// In en, this message translates to:
  /// **'Include people & group names'**
  String get settingsAiShareNames;

  /// No description provided for @settingsAiApiKey.
  ///
  /// In en, this message translates to:
  /// **'Online AI API key'**
  String get settingsAiApiKey;

  /// No description provided for @settingsAiApiKeySet.
  ///
  /// In en, this message translates to:
  /// **'Key saved securely'**
  String get settingsAiApiKeySet;

  /// No description provided for @settingsAiApiKeyMissing.
  ///
  /// In en, this message translates to:
  /// **'No key saved'**
  String get settingsAiApiKeyMissing;

  /// No description provided for @settingsAiPrivacy.
  ///
  /// In en, this message translates to:
  /// **'How AI uses your data'**
  String get settingsAiPrivacy;

  /// No description provided for @aiPrivacyExplanation.
  ///
  /// In en, this message translates to:
  /// **'All amounts are calculated by HisabMitra on your phone. With the on-device engine nothing leaves your phone. If you enable online AI and give consent, only the summary figures for your question (for example \'expenses this month by category\') are sent to the provider to phrase the answer. The AI can never add, change or delete your records.'**
  String get aiPrivacyExplanation;

  /// No description provided for @settingsGujaratiInput.
  ///
  /// In en, this message translates to:
  /// **'Gujarati typing'**
  String get settingsGujaratiInput;

  /// No description provided for @inputModeSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone keyboard'**
  String get inputModeSystem;

  /// No description provided for @inputModeTransliteration.
  ///
  /// In en, this message translates to:
  /// **'English → ગુજરાતી (type \'kem chho\')'**
  String get inputModeTransliteration;

  /// No description provided for @inputModeKeypad.
  ///
  /// In en, this message translates to:
  /// **'Gujarati keypad'**
  String get inputModeKeypad;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Log out? Your hisab stays saved in your account and is removed from this phone. Categories and settings stay on the phone.'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete cloud account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Deletes your account, its saved hisab and bills, and your group memberships.'**
  String get settingsDeleteAccountDesc;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get settingsCategories;

  /// No description provided for @settingsReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsReminders;

  /// No description provided for @settingsCalculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get settingsCalculator;

  /// No description provided for @settingsReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get settingsReports;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & conditions'**
  String get settingsTerms;

  /// No description provided for @signOutUnsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Not saved yet'**
  String get signOutUnsentTitle;

  /// No description provided for @signOutUnsentBody.
  ///
  /// In en, this message translates to:
  /// **'{count} changes haven\'t been saved to your account yet. Logging out now loses them.'**
  String signOutUnsentBody(String count);

  /// No description provided for @signOutWaitSync.
  ///
  /// In en, this message translates to:
  /// **'Wait and sync'**
  String get signOutWaitSync;

  /// No description provided for @signOutAnyway.
  ///
  /// In en, this message translates to:
  /// **'Log out anyway'**
  String get signOutAnyway;

  /// No description provided for @tourPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a quick tour?'**
  String get tourPromptTitle;

  /// No description provided for @tourPromptBody.
  ///
  /// In en, this message translates to:
  /// **'See HisabMitra with sample data: two months of income and expenses, money lent and borrowed, and a Goa trip split with friends. You can remove the sample data at the end.'**
  String get tourPromptBody;

  /// No description provided for @tourStart.
  ///
  /// In en, this message translates to:
  /// **'Start tour'**
  String get tourStart;

  /// No description provided for @tourNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get tourNotNow;

  /// No description provided for @tourLoading.
  ///
  /// In en, this message translates to:
  /// **'Adding sample data…'**
  String get tourLoading;

  /// No description provided for @tourStepOf.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String tourStepOf(int current, int total);

  /// No description provided for @tourNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tourNext;

  /// No description provided for @tourBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get tourBack;

  /// No description provided for @tourSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip tour'**
  String get tourSkip;

  /// No description provided for @tour1Title.
  ///
  /// In en, this message translates to:
  /// **'Your month at a glance'**
  String get tour1Title;

  /// No description provided for @tour1Body.
  ///
  /// In en, this message translates to:
  /// **'Savings = income − expenses for the period. Switch between this month, last month and this year with the chips above.'**
  String get tour1Body;

  /// No description provided for @tour2Title.
  ///
  /// In en, this message translates to:
  /// **'Money to receive and to pay'**
  String get tour2Title;

  /// No description provided for @tour2Body.
  ///
  /// In en, this message translates to:
  /// **'Totals from your khata: money you lent and money you borrowed. Loans are kept separate from income and expenses.'**
  String get tour2Body;

  /// No description provided for @tour3Title.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get tour3Title;

  /// No description provided for @tour3Body.
  ///
  /// In en, this message translates to:
  /// **'Add income or an expense, give or receive money, create a group, split a group expense or open reports — one tap each.'**
  String get tour3Body;

  /// No description provided for @tour4Title.
  ///
  /// In en, this message translates to:
  /// **'Your hisab, also as a sheet'**
  String get tour4Title;

  /// No description provided for @tour4Body.
  ///
  /// In en, this message translates to:
  /// **'Every entry, day by day. Tap this table icon for an Excel-like sheet with income, expense and a running balance.'**
  String get tour4Body;

  /// No description provided for @tour5Title.
  ///
  /// In en, this message translates to:
  /// **'Khata: people and loans'**
  String get tour5Title;

  /// No description provided for @tour5Body.
  ///
  /// In en, this message translates to:
  /// **'See who owes you and whom you owe. Open a person for the full ledger, partial repayments and due dates.'**
  String get tour5Body;

  /// No description provided for @tour6Title.
  ///
  /// In en, this message translates to:
  /// **'Groups: split and settle'**
  String get tour6Title;

  /// No description provided for @tour6Body.
  ///
  /// In en, this message translates to:
  /// **'Split trips and family costs equally, by amounts, percentages or shares. Open the sample Goa Trip to see balances and settle-ups.'**
  String get tour6Body;

  /// No description provided for @tour7Title.
  ///
  /// In en, this message translates to:
  /// **'More tools'**
  String get tour7Title;

  /// No description provided for @tour7Body.
  ///
  /// In en, this message translates to:
  /// **'Reports with PDF and CSV export, calculator, reminders, backup, the AI assistant, and settings for colour theme, language and the Gujarati keyboard.'**
  String get tour7Body;

  /// No description provided for @tourFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'You are all set!'**
  String get tourFinishTitle;

  /// No description provided for @tourFinishBody.
  ///
  /// In en, this message translates to:
  /// **'Keep the sample data to explore a little more, or remove it and start your own hisab. You can replay the tour any time from More.'**
  String get tourFinishBody;

  /// No description provided for @tourRemoveSample.
  ///
  /// In en, this message translates to:
  /// **'Remove sample data'**
  String get tourRemoveSample;

  /// No description provided for @tourKeepSample.
  ///
  /// In en, this message translates to:
  /// **'Keep for now'**
  String get tourKeepSample;

  /// No description provided for @sampleBanner.
  ///
  /// In en, this message translates to:
  /// **'You are looking at sample data.'**
  String get sampleBanner;

  /// No description provided for @sampleRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get sampleRemove;

  /// No description provided for @sampleRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove sample data?'**
  String get sampleRemoveTitle;

  /// No description provided for @sampleRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Sample entries, people and the sample group are removed. Everything you added yourself stays — a sample person or group you used is kept.'**
  String get sampleRemoveBody;

  /// No description provided for @sampleRemoved.
  ///
  /// In en, this message translates to:
  /// **'Sample data removed'**
  String get sampleRemoved;

  /// No description provided for @moreAppTour.
  ///
  /// In en, this message translates to:
  /// **'App tour'**
  String get moreAppTour;

  /// No description provided for @moreAppTourDesc.
  ///
  /// In en, this message translates to:
  /// **'A one-minute guided tour with sample data'**
  String get moreAppTourDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

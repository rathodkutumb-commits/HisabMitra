// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get aboutTitle => 'હિસાબમિત્ર વિશે';

  @override
  String aboutVersion(String version) {
    return 'વર્ઝન $version';
  }

  @override
  String get aboutDescription =>
      'હિસાબમિત્ર તમારો રોજનો હિસાબ, અંગત ખાતું અને પરિવારના ગ્રુપ ખર્ચ તમારા એકાઉન્ટમાં સાચવે છે, અને ફોનમાં તેની નકલ રાખે છે જેથી ઇન્ટરનેટ વિના પણ ચાલે.';

  @override
  String get checkUpdates => 'અપડેટ તપાસો';

  @override
  String get updateUpToDate => 'તમારી પાસે નવીનતમ વર્ઝન છે.';

  @override
  String updateAvailable(String version) {
    return 'વર્ઝન $version ઉપલબ્ધ છે';
  }

  @override
  String get updateNotConfigured => 'આ બિલ્ડમાં અપડેટ તપાસ ગોઠવાયેલી નથી.';

  @override
  String get updateDownloadInstall => 'ડાઉનલોડ કરીને ઇન્સ્ટોલ કરો';

  @override
  String updateDownloading(int percent) {
    return 'ડાઉનલોડ થઈ રહ્યું છે… $percent%';
  }

  @override
  String get updateInstallSteps =>
      'ફાઇલ ચકાસાઈ ગઈ છે (ચેકસમ, પેકેજ અને સહી). હવે Android તમને ઇન્સ્ટોલેશનની પુષ્ટિ કરવા પૂછશે. તમારો હિસાબ તમારા એકાઉન્ટમાં અને આ ફોનમાં સુરક્ષિત રહેશે.';

  @override
  String get updateAllowInstall =>
      'હવે પછીની સ્ક્રીનમાં હિસાબમિત્રને અપડેટ ઇન્સ્ટોલ કરવાની મંજૂરી આપો, પછી ફરી ડાઉનલોડ કરીને ઇન્સ્ટોલ કરો દબાવો.';

  @override
  String get updateNoChecksum =>
      'આ રિલીઝમાં ચેકસમ પ્રકાશિત થયો નથી, તેથી એપમાંથી ઇન્સ્ટોલ થઈ શકશે નહીં. રિલીઝ પેજ ખોલો.';

  @override
  String get updateChecksumMismatch =>
      'ડાઉનલોડ થયેલી ફાઇલ પ્રકાશિત ચેકસમ સાથે મેળ ખાતી નહોતી, તેથી કાઢી નાખી.';

  @override
  String get updateWrongPackage =>
      'ડાઉનલોડ થયેલી ફાઇલ હિસાબમિત્રનું અપડેટ નથી.';

  @override
  String get updateNotNewer =>
      'ડાઉનલોડ થયેલું વર્ઝન ઇન્સ્ટોલ થયેલા વર્ઝન કરતાં નવું નથી.';

  @override
  String get updateSignatureMismatch =>
      'આ અપડેટ આ એપની જ કીથી સહી થયેલું નથી, તેથી Android તેને નકારશે. તમે સ્રોત પર વિશ્વાસ કરતા હો તો જ રિલીઝ પેજ પરથી જાતે ઇન્સ્ટોલ કરો.';

  @override
  String get updateUnreadable => 'ડાઉનલોડ થયેલી ફાઇલ વાંચી શકાઈ નહીં.';

  @override
  String get releaseNotes => 'રિલીઝ નોંધ';

  @override
  String get openWebsite => 'હિસાબમિત્ર વેબસાઇટ';

  @override
  String get shareApp => 'હિસાબમિત્ર શેર કરો';

  @override
  String get shareAppText =>
      '📒 *હિસાબમિત્ર — સ્માર્ટ હિસાબ, ખુશ પરિવાર*\n\nહું મારા પરિવારનો હિસાબ હિસાબમિત્રમાં રાખું છું:\n✅ રોજની આવક અને ખર્ચ\n🤝 આપેલા અને લીધેલા પૈસા (ખાતું)\n👨‍👩‍👧 પરિવાર અને પ્રવાસના ખર્ચની વહેંચણી\n📊 ગુજરાતી અને English માં રિપોર્ટ';

  @override
  String get licenses => 'ઓપન-સોર્સ લાઇસન્સ';

  @override
  String get privacySummary =>
      'તમારી અંગત નોંધો, લોકો, ખાતું, રિમાઇન્ડર અને બિલ તમારા હિસાબમિત્ર એકાઉન્ટમાં સચવાય છે, અને ફક્ત તમે જ જોઈ શકો છો. ગ્રુપના ખર્ચ એ ગ્રુપના સભ્યો સાથે શેર થાય છે. એપ ઑફલાઇન ચાલે તે માટે ફોનમાં નકલ રહે છે; લૉગ આઉટ કરવાથી તે દૂર થાય છે. વૈકલ્પિક ઓનલાઇન AI ને તમારી મંજૂરી પછી જ સારાંશ આંકડા મળે છે. કોઈ જાહેરાત કે ટ્રેકિંગ SDK સામેલ નથી.';

  @override
  String get termsSummary =>
      'હિસાબમિત્ર નોંધ રાખવાનું સાધન છે. મહત્ત્વના આંકડા જાતે તપાસી લો; તે નાણાકીય, કર કે કાનૂની સલાહ આપતું નથી.';

  @override
  String shareAppDownload(String url) {
    return '📲 મફત ડાઉનલોડ કરો: $url';
  }

  @override
  String get aiTitle => 'હિસાબમિત્ર સહાયક';

  @override
  String get aiDisabledTitle => 'સહાયક બંધ છે';

  @override
  String get aiDisabledBody =>
      'તમારા હિસાબ વિશે પ્રશ્નો પૂછવા તેને ચાલુ કરો. જવાબની ગણતરી આ ફોનમાં જ થાય છે.';

  @override
  String get aiEnable => 'ચાલુ કરો';

  @override
  String get aiInputHint => 'તમારા પૈસા વિશે પૂછો…';

  @override
  String get aiCalculatedOnPhone => 'આ ફોનમાં ગણતરી થઈ';

  @override
  String get aiSuggestionBadge => 'સૂચન — તમારો ડેટા નથી';

  @override
  String get aiOnlineBadge => 'ઓનલાઇન AI એ લખ્યું';

  @override
  String aiPeriodLabel(String period) {
    return 'સમયગાળો: $period';
  }

  @override
  String get aiReviewDraft => 'તપાસો અને સાચવો';

  @override
  String get aiDraftNote =>
      'તમે તપાસીને સાચવો નહીં ત્યાં સુધી કશું સચવાતું નથી.';

  @override
  String get aiOnlineFailed =>
      'ઓનલાઇન AI ઉપલબ્ધ નથી, તેથી આ જવાબ તમારા ફોનમાં લખાયો છે.';

  @override
  String get aiExample1 => 'આ મહિને મેં કેટલો ખર્ચ કર્યો?';

  @override
  String get aiExample2 => 'મારી સૌથી મોટી ખર્ચની શ્રેણી કઈ છે?';

  @override
  String get aiExample3 => 'આ મહિનાની ગયા મહિના સાથે સરખામણી કરો';

  @override
  String get aiExample4 => 'મારા સૌથી મોટા પાંચ ખર્ચ બતાવો';

  @override
  String get aiExample5 => 'લોકો પાસેથી મારે કેટલા લેવાના છે?';

  @override
  String get aiExample6 => 'હું ખર્ચ કેવી રીતે ઘટાડું?';

  @override
  String get aiHelp =>
      'હું તમારી પોતાની નોંધો વિશેના પ્રશ્નોના જવાબ આપી શકું છું, જેમ કે: કોઈ સમયગાળાનો ખર્ચ કે આવક, સૌથી મોટી શ્રેણી, મોટા ખર્ચ, કોઈ વ્યક્તિ પાસેથી કેટલા લેવાના, ગ્રુપ પ્રવાસનો ખર્ચ, અથવા ગ્રુપમાં કોણે કોને આપવાના. નીચેનું કોઈ સૂચન અજમાવો.';

  @override
  String aiSpend(String amount, String period, int count) {
    return '$period તમે $count નોંધોમાં $amount ખર્ચ્યા.';
  }

  @override
  String aiIncome(String amount, String period) {
    return '$period તમારી આવક $amount હતી.';
  }

  @override
  String aiSavings(
    String period,
    String income,
    String expense,
    String savings,
  ) {
    return '$period તમે $income કમાયા અને $expense ખર્ચ્યા, એટલે $savings બચ્યા.';
  }

  @override
  String aiTopCategory(
    String period,
    String category,
    String amount,
    String percent,
  ) {
    return '$period તમારી સૌથી મોટી ખર્ચની શ્રેણી $category હતી: $amount (કુલ ખર્ચના $percent%).';
  }

  @override
  String aiNoExpenses(String period) {
    return '$period કોઈ ખર્ચ નોંધાયો નથી.';
  }

  @override
  String aiPersonOwesYou(String name, String amount) {
    return '$name પાસેથી તમારે કુલ $amount લેવાના છે (બધી ખુલ્લી નોંધો).';
  }

  @override
  String aiYouOwePerson(String name, String amount) {
    return 'તમારે $name ને કુલ $amount આપવાના છે (બધી ખુલ્લી નોંધો).';
  }

  @override
  String aiPersonSettled(String name) {
    return 'તમારો અને $name નો હિસાબ ચૂકતે છે — કશું બાકી નથી.';
  }

  @override
  String aiGroupTotal(String group, String amount, int count, String share) {
    return '$group માં અત્યાર સુધી $count ખર્ચમાં $amount થયા. તમારો ભાગ $share છે.';
  }

  @override
  String aiWhoOwesNone(String group) {
    return '$group માં બધાનો હિસાબ ચૂકતે છે.';
  }

  @override
  String aiWhoOwesIntro(String group) {
    return '$group નો હિસાબ ચૂકતે કરવા:';
  }

  @override
  String aiCompare(
    String current,
    String currentAmount,
    String previous,
    String previousAmount,
    String change,
  ) {
    return '$current: ખર્ચ $currentAmount. $previous: ખર્ચ $previousAmount. એટલે $change.';
  }

  @override
  String aiMore(String amount) {
    return '$amount વધુ';
  }

  @override
  String aiLess(String amount) {
    return '$amount ઓછો';
  }

  @override
  String get aiSame => 'સરખો';

  @override
  String aiTopExpensesIntro(String period) {
    return '$period તમારા સૌથી મોટા ખર્ચ:';
  }

  @override
  String aiReceivables(String receivable, String payable) {
    return 'લોકો પાસેથી તમારે $receivable લેવાના છે અને તમારે બીજાને $payable આપવાના છે (બધી ખુલ્લી નોંધો).';
  }

  @override
  String aiTipsIntro(String period) {
    return '$period ના આધારે થોડા વિચારો (સૂચનો છે, હકીકત નહીં):';
  }

  @override
  String aiTipCategory(String category, String percent, String amount) {
    return '$category માં તમારા ખર્ચના $percent% ($amount) ગયા. તેના માટે માસિક મર્યાદા રાખવાથી સૌથી વધુ ફરક પડશે.';
  }

  @override
  String aiTipFrequent(int count, String amount) {
    return 'તમે ₹200 થી ઓછા $count નાના ખર્ચ કર્યા — કુલ $amount. રોજના નાના ખર્ચ ભેગા થઈને મોટા બને છે.';
  }

  @override
  String get aiTipSavings =>
      'આ સમયગાળામાં તમે કમાણી કરતાં વધુ ખર્ચ કર્યો. પહેલાં મોટી શ્રેણીઓ તપાસવાથી સૌથી વધુ મદદ મળે છે.';

  @override
  String get aiTipGeneral =>
      'એક મહિનો દરેક ખર્ચ નોંધો, પછી અહીં મહિનાઓની સરખામણી કરીને જુઓ કે શું બદલાયું.';

  @override
  String aiDraftExpense(String amount, String category) {
    return 'મેં $amount$category નો ખર્ચ તૈયાર કર્યો છે. સાચવતાં પહેલાં તપાસી લો.';
  }

  @override
  String aiDraftIncome(String amount, String category) {
    return 'મેં $amount$category ની આવક તૈયાર કરી છે. સાચવતાં પહેલાં તપાસી લો.';
  }

  @override
  String get aiDraftNeedsAmount =>
      'રકમ પણ જણાવો, જેમ કે: “add expense 250 for groceries”. હું રકમનું અનુમાન નહીં કરું.';

  @override
  String get aiNoPerson => 'તમારા ખાતામાં એ વ્યક્તિ મળી નહીં.';

  @override
  String get aiNoGroup => 'એ ગ્રુપ મળ્યું નહીં.';

  @override
  String get aiTodayLabel => 'આજે';

  @override
  String get aiSettingsTitle => 'AI સહાયક સેટિંગ્સ';

  @override
  String get aiApiKeySave => 'કી સાચવો';

  @override
  String get aiApiKeyRemove => 'કી દૂર કરો';

  @override
  String get aiApiKeyHint => 'તમારી Anthropic API કી પેસ્ટ કરો';

  @override
  String get aiApiKeyNote =>
      'કી આ ફોનમાં એન્ક્રિપ્ટેડ રૂપે સચવાય છે અને ફક્ત ઓનલાઇન જવાબો માટે વપરાય છે. ઓનલાઇન વપરાશનું બિલ તમારા Anthropic એકાઉન્ટમાં આવશે.';

  @override
  String get aiOpenAssistant => 'હિસાબમિત્ર AI ને પૂછો';

  @override
  String get aiExamplesSpending => 'ખર્ચ';

  @override
  String get aiExamplesIncome => 'આવક અને બચત';

  @override
  String get aiExamplesKhata => 'ખાતું';

  @override
  String get aiExamplesGroups => 'ગ્રુપ';

  @override
  String get aiExamplesAdd => 'નોંધ ઉમેરો';

  @override
  String get aiExample7 => 'આજે મેં કેટલો ખર્ચ કર્યો?';

  @override
  String get aiExample8 => 'ગયા મહિને મેં કેટલો ખર્ચ કર્યો?';

  @override
  String get aiExample9 => 'આ મહિને મારી આવક કેટલી છે?';

  @override
  String get aiExample10 => 'ગયા મહિને મારી આવક કેટલી હતી?';

  @override
  String get aiExample11 => 'આ મહિને મારી બચત કેટલી છે?';

  @override
  String get aiExample12 => 'આ વર્ષે મારી બચત કેટલી છે?';

  @override
  String get aiExample13 => 'કરિયાણું 250 ઉમેરો';

  @override
  String get aiExample14 => 'પગાર 25000 ઉમેરો';

  @override
  String get aiExample15 => 'પેટ્રોલ-ડીઝલ 500 ઉમેરો';

  @override
  String aiExamplePerson(String name) {
    return '$name સાથે મારો હિસાબ કેટલો છે?';
  }

  @override
  String aiExampleGroupTotal(String group) {
    return '$group માં કુલ કેટલો ખર્ચ થયો?';
  }

  @override
  String aiExampleGroupOwes(String group) {
    return '$group માં કોણે કોને કેટલા આપવાના છે?';
  }

  @override
  String get attachments => 'બિલ અને જોડાણો';

  @override
  String get attachCamera => 'કૅમેરા';

  @override
  String get attachGallery => 'ગેલેરી';

  @override
  String get attachPdf => 'PDF';

  @override
  String get attachmentTooLarge => 'આ ફાઇલ 10 MB કરતાં મોટી છે.';

  @override
  String get attachmentType =>
      'ફક્ત JPG, PNG, WEBP, HEIC ફોટા અને PDF ફાઇલ જ જોડી શકાય છે.';

  @override
  String get attachmentMissing => 'આ ફાઇલ હવે ફોનમાં ઉપલબ્ધ નથી.';

  @override
  String get attachmentOpenExternal => 'બીજી એપમાં ખોલો';

  @override
  String get attachmentDeleteConfirm => 'આ જોડાણ દૂર કરવું છે?';

  @override
  String get attachmentViewerTitle => 'જોડાણ';

  @override
  String get attachmentPrivateNote => 'તમારા હિસાબમિત્ર એકાઉન્ટમાં સચવાય છે.';

  @override
  String get attachmentShareToGroup => 'ગ્રુપ સાથે શેર કરો';

  @override
  String get attachmentSharedToGroup => 'ગ્રુપ સાથે શેર કરેલું';

  @override
  String get attachmentRemove => 'દૂર કરો';

  @override
  String get photoRecovered =>
      'તમે લીધેલો ફોટો સાચવી રાખ્યો છે. તેને નવા ખર્ચમાં ઉમેરવો છે?';

  @override
  String get photoRecoveredAction => 'ખર્ચ ઉમેરો';

  @override
  String get attachmentDownloadRetry =>
      'આ બિલ ખૂલ્યું નહીં. ઇન્ટરનેટ તપાસીને ફરી પ્રયત્ન કરો.';

  @override
  String get backupTitle => 'બેકઅપ અને રિસ્ટોર';

  @override
  String get backupNow => 'હમણાં બેકઅપ લો';

  @override
  String get backupEncrypt => 'પાસવર્ડથી સુરક્ષિત કરો';

  @override
  String get backupPassword => 'બેકઅપ પાસવર્ડ';

  @override
  String get backupPasswordConfirm => 'પાસવર્ડ ફરી લખો';

  @override
  String get backupPasswordMismatch => 'પાસવર્ડ મેળ ખાતા નથી';

  @override
  String get backupPasswordTooShort => 'ઓછામાં ઓછા 8 અક્ષર વાપરો';

  @override
  String get backupPasswordWarning =>
      'હિસાબમિત્ર આ પાસવર્ડ સાચવતું નથી. તેના વિના આ બેકઅપ રિસ્ટોર થઈ શકશે નહીં.';

  @override
  String get backupCreated => 'બેકઅપ બન્યું';

  @override
  String get backupHistory => 'બેકઅપનો ઇતિહાસ';

  @override
  String get backupNone => 'હજી કોઈ બેકઅપ નથી';

  @override
  String get backupKindManual => 'જાતે';

  @override
  String get backupKindAutomatic => 'આપમેળે';

  @override
  String get backupKindSafety => 'રિસ્ટોર પહેલાંનું';

  @override
  String get backupEncryptedLabel => 'એન્ક્રિપ્ટેડ';

  @override
  String get backupExport => 'નકલ સાચવો / શેર કરો';

  @override
  String get backupRestore => 'રિસ્ટોર કરો';

  @override
  String get backupRestoreFromFile => 'ફાઇલમાંથી રિસ્ટોર કરો';

  @override
  String get backupRestoreConfirmTitle => 'હાલનો ડેટા બદલવો છે?';

  @override
  String backupRestoreConfirmBody(
    String date,
    int transactions,
    int people,
    int groups,
  ) {
    return '$date ના આ બેકઅપમાં $transactions નોંધો, $people વ્યક્તિઓ અને $groups ગ્રુપ છે. તમારો હાલનો ડેટા બદલાઈ જશે. તે પહેલાં હાલના ડેટાનું સુરક્ષા બેકઅપ લેવાશે.';
  }

  @override
  String get backupRestoreDone => 'રિસ્ટોર પૂર્ણ';

  @override
  String backupRestoreMissingAttachments(int count) {
    return '$count જોડાણ ફાઇલો બેકઅપમાં નહોતી.';
  }

  @override
  String get backupWhere =>
      'તમારો હિસાબ તમારા એકાઉન્ટમાં સચવાયેલો છે. બેકઅપ એ વધારાની નકલ છે, જે આ ફોનમાં હિસાબમિત્રના ખાનગી સ્ટોરેજમાં રહે છે; એપ અનઇન્સ્ટોલ કરવાથી તે કાઢી નખાય છે, તેથી બીજે રાખવા “નકલ સાચવો / શેર કરો” વાપરો (દા.ત. Google Drive કે કમ્પ્યુટર).';

  @override
  String get backupFileMissing => 'ફાઇલ હવે આ ફોનમાં નથી';

  @override
  String get backupDeleteConfirm => 'આ બેકઅપ ફાઇલ કાઢી નાખવી છે?';

  @override
  String get backupPasswordRequired =>
      'આ બેકઅપ એન્ક્રિપ્ટેડ છે. તેનો પાસવર્ડ લખો.';

  @override
  String get backupWrongPassword => 'પાસવર્ડ ખોટો છે અથવા ફાઇલ બગડેલી છે.';

  @override
  String get backupCorrupt =>
      'બેકઅપ ફાઇલ બગડેલી છે અથવા બદલાયેલી છે, તેથી રિસ્ટોર થઈ શકશે નહીં.';

  @override
  String get backupNewerSchema =>
      'આ બેકઅપ હિસાબમિત્રના નવા વર્ઝનથી બન્યું છે. પહેલાં એપ અપડેટ કરો.';

  @override
  String get backupIntegrity => 'બેકઅપમાંનો ડેટા ચકાસણીમાં નિષ્ફળ ગયો.';

  @override
  String get backupNotBackup => 'આ ફાઇલ હિસાબમિત્રનું બેકઅપ નથી.';

  @override
  String shareBackupCaption(String date) {
    return '🔒 *હિસાબમિત્ર બેકઅપ* · $date — આ ફાઇલ સાચવીને રાખો; રિસ્ટોર કરવા માટે બેકઅપ પાસવર્ડ જોઈશે.';
  }

  @override
  String shareBackupCaptionPlain(String date) {
    return '🔒 *હિસાબમિત્ર બેકઅપ* · $date — આ ફાઇલ સાચવીને રાખો.';
  }

  @override
  String get restoreNeedsInternet => 'રિસ્ટોર કરવા ઇન્ટરનેટ ચાલુ કરો.';

  @override
  String get restoreReplacesAccount =>
      'આ બેકઅપ તમારા એકાઉન્ટમાં સચવાયેલા હિસાબની જગ્યા લેશે. ગ્રુપ બદલાશે નહીં.';

  @override
  String get authSendOtp => 'ચકાસણી કોડ મોકલો';

  @override
  String get authVerify => 'ચકાસો';

  @override
  String get authResend => 'કોડ ફરી મોકલો';

  @override
  String authResendIn(int seconds) {
    return '$seconds સેકન્ડમાં ફરી મોકલો';
  }

  @override
  String get authCodeSent => 'કોડ મોકલ્યો';

  @override
  String get profileTitle => 'પ્રોફાઇલ';

  @override
  String get profileName => 'દેખાતું નામ';

  @override
  String get profileSaved => 'પ્રોફાઇલ સાચવી';

  @override
  String get deleteAccountConfirm =>
      'તમારું એકાઉન્ટ કાઢી નાખવું છે? તમારો સચવાયેલો હિસાબ, બિલ અને ગ્રુપ સભ્યપદ એકાઉન્ટમાંથી અને આ ફોનમાંથી કાઢી નખાશે. આ પાછું લાવી શકાશે નહીં.';

  @override
  String get accountDeleted => 'ક્લાઉડ એકાઉન્ટ કાઢી નાખ્યું';

  @override
  String get signedOut => 'લૉગ આઉટ થયું';

  @override
  String get syncTitle => 'સિંકની સ્થિતિ';

  @override
  String get syncNow => 'હમણાં સિંક કરો';

  @override
  String syncLastSuccess(String date) {
    return 'છેલ્લે સિંક: $date';
  }

  @override
  String get syncNever => 'હજી સિંક થયું નથી';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ફેરફાર સિંક થવાના બાકી',
      one: '1 ફેરફાર સિંક થવાનો બાકી',
      zero: 'બધું અદ્યતન છે',
    );
    return '$_temp0';
  }

  @override
  String syncFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ફેરફાર સિંક થઈ શક્યા નહીં',
      one: '1 ફેરફાર સિંક થઈ શક્યો નહીં',
    );
    return '$_temp0';
  }

  @override
  String get syncRetry => 'ફરી પ્રયાસ કરો';

  @override
  String get syncConflicts => 'તમારો નિર્ણય જરૂરી';

  @override
  String get syncConflictHelp =>
      'તમે ફેરફાર કરતા હતા ત્યારે જ આ નોંધ બીજા ફોન પર પણ બદલાઈ. કશું ભૂંસાયું નથી — કયું વર્ઝન રાખવું તે પસંદ કરો.';

  @override
  String get syncKeepMine => 'મારું રાખો';

  @override
  String get syncKeepTheirs => 'બીજું વર્ઝન વાપરો';

  @override
  String get syncYourVersion => 'તમારું વર્ઝન';

  @override
  String get syncOtherVersion => 'બીજા ફોનનું વર્ઝન';

  @override
  String get syncOffline => 'ઑફલાઇન — ઇન્ટરનેટ પાછું આવતાં ફેરફારો સિંક થશે.';

  @override
  String get syncSignInNeeded => 'શેર કરેલાં ગ્રુપ સિંક કરવા સાઇન ઇન કરો.';

  @override
  String get syncDone => 'સિંક પૂર્ણ';

  @override
  String get syncRunning => 'સિંક થઈ રહ્યું છે…';

  @override
  String get entityGroup => 'ગ્રુપની વિગત';

  @override
  String get entityMember => 'સભ્ય';

  @override
  String get entityExpense => 'ખર્ચ';

  @override
  String get entitySettlement => 'ચુકવણી';

  @override
  String get inviteTitle => 'સભ્યોને આમંત્રણ';

  @override
  String get inviteFor => 'કોના માટે આમંત્રણ';

  @override
  String get inviteNewMember => 'નવી વ્યક્તિ';

  @override
  String get inviteCreate => 'આમંત્રણ કોડ બનાવો';

  @override
  String inviteShareText(String group, String code, String date) {
    return '👋 *હિસાબમિત્રમાં મારા ગ્રુપમાં જોડાઓ!*\n\n👥 ગ્રુપ: *$group*\n🔑 આમંત્રણ કોડ: *$code*\n\nહિસાબમિત્ર ખોલો → ગ્રુપ → ગ્રુપમાં જોડાઓ, અને કોડ લખો.\n\n⏳ કોડ *$date* સુધી માન્ય છે.';
  }

  @override
  String inviteShareTextLink(
    String group,
    String code,
    String link,
    String date,
  ) {
    return '👋 *હિસાબમિત્રમાં મારા ગ્રુપમાં જોડાઓ!*\n\n👥 ગ્રુપ: *$group*\n🔑 આમંત્રણ કોડ: *$code*\n\n👉 જોડાવા માટે ટેપ કરો: $link\nઅથવા હિસાબમિત્ર ખોલો → ગ્રુપ → ગ્રુપમાં જોડાઓ, અને કોડ લખો.\n\n⏳ કોડ *$date* સુધી માન્ય છે.';
  }

  @override
  String inviteExpires(String date) {
    return '$date સુધી માન્ય';
  }

  @override
  String get inviteStatusPending => 'રાહ જોવાય છે';

  @override
  String get inviteStatusAccepted => 'જોડાયા';

  @override
  String get inviteStatusCancelled => 'રદ';

  @override
  String get inviteStatusExpired => 'મુદત પૂરી';

  @override
  String get inviteCancel => 'આમંત્રણ રદ કરો';

  @override
  String get invitesEmpty => 'હજી કોઈ આમંત્રણ નથી';

  @override
  String get inviteCodeOnce =>
      'આ કોડ હમણાં જ શેર કરો. સુરક્ષા માટે તે ફક્ત એક જ વાર દેખાય છે.';

  @override
  String get joinTitle => 'ગ્રુપમાં જોડાઓ';

  @override
  String get joinCode => 'આમંત્રણ કોડ';

  @override
  String get joinButton => 'ગ્રુપમાં જોડાઓ';

  @override
  String joinDone(String group) {
    return 'તમે $group માં જોડાયા';
  }

  @override
  String get joinNeedsSignIn => 'શેર કરેલા ગ્રુપમાં જોડાવા તમારો ઇમેઇલ ચકાસો.';

  @override
  String get errInvalidCode => 'આ આમંત્રણ કોડ માન્ય નથી.';

  @override
  String get errExpiredCode => 'આ આમંત્રણની મુદત પૂરી થઈ ગઈ છે. નવું માંગો.';

  @override
  String get errAlreadyMember => 'તમે પહેલેથી આ ગ્રુપના સભ્ય છો.';

  @override
  String get errInvitationPending =>
      'આ સભ્ય માટે પહેલેથી એક ખુલ્લું આમંત્રણ છે.';

  @override
  String get errForbidden => 'તમને આ કરવાની પરવાનગી નથી.';

  @override
  String get errCloudStorage => 'ફાઇલ અપલોડ કે ડાઉનલોડ થઈ શકી નહીં.';

  @override
  String get emailAddress => 'ઇમેઇલ સરનામું';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get verifyEmailTitle => 'તમારો ઇમેઇલ ચકાસો';

  @override
  String verifyEmailSubtitle(String email) {
    return 'અમે $email પર કોડ મોકલ્યો છે. તે નીચે લખો, અથવા આ જ ફોનમાં તે ઇમેઇલની લિંક પર ટૅપ કરો.';
  }

  @override
  String get verificationCode => 'ચકાસણી કોડ';

  @override
  String get verifyEmailSpamHint =>
      'ઇમેઇલ ન મળ્યો? Spam કે Promotions જુઓ, અથવા એક મિનિટ પછી ફરી મોકલો.';

  @override
  String get changeDetails => 'વિગતો બદલો';

  @override
  String get emailVerified => 'ઇમેઇલ ચકાસાયો. હિસાબમિત્રમાં આપનું સ્વાગત છે!';

  @override
  String get verifyingLink => 'લિંક તપાસી રહ્યા છીએ…';

  @override
  String get authEmailNotAuthorized =>
      'આ સરનામે હજુ ઇમેઇલ મોકલી શકાતો નથી: એપનો ઇમેઇલ મોકલનાર હજુ ગોઠવાયો નથી. થોડી વાર પછી પ્રયાસ કરો.';

  @override
  String get authLinkInvalid =>
      'આ લિંકની મુદત પૂરી થઈ છે અથવા બીજા ફોનમાં ખોલી છે. તેના બદલે કોડ લખો, અથવા નવો મોકલો.';

  @override
  String get authNoPending => 'કૃપા કરીને તમારી વિગતો ફરી લખો.';

  @override
  String get accountOfflineNote =>
      'આ બિલ્ડમાં ક્લાઉડ જોડાણ નથી, તેથી હમણાં ઇમેઇલ ચકાસી શકાતો નથી. તમારી વિગતો આ ફોનમાં સચવાઈ છે.';

  @override
  String accountVerifiedAs(String email) {
    return 'ચકાસાયેલ: $email';
  }

  @override
  String get verifyEmailAction => 'ઇમેઇલ ચકાસો';

  @override
  String inviteShareDownload(String url) {
    return '📲 એપ નથી? મફત ડાઉનલોડ કરો: $url';
  }

  @override
  String get entityPerson => 'વ્યક્તિ';

  @override
  String get entityTransaction => 'આવક કે ખર્ચ';

  @override
  String get entityLedgerEntry => 'ખાતાની નોંધ';

  @override
  String get entityRepayment => 'પરત ચુકવણી';

  @override
  String get entityReminder => 'રિમાઇન્ડર';

  @override
  String get entityBill => 'બિલ';

  @override
  String get inviteSampleGroup => 'નમૂનાના ગ્રુપ શેર કરી શકાતા નથી.';

  @override
  String get accountSyncUploadTitle =>
      'તમારો હિસાબ તમારા એકાઉન્ટમાં સાચવી રહ્યા છીએ';

  @override
  String get accountSyncDownloadTitle => 'તમારો હિસાબ લાવી રહ્યા છીએ';

  @override
  String accountSyncProgress(String done, String total) {
    return '$total માંથી $done';
  }

  @override
  String get accountSyncOffline =>
      'ઇન્ટરનેટ નથી. ઇન્ટરનેટ આવતાં જ તમારો હિસાબ તમારા એકાઉન્ટમાં સચવાઈ જશે.';

  @override
  String get accountSyncContinue => 'બેકગ્રાઉન્ડમાં ચાલુ રાખો';

  @override
  String get appName => 'હિસાબમિત્ર';

  @override
  String get appNameGujarati => 'હિસાબમિત્ર';

  @override
  String get appTagline => 'સ્માર્ટ હિસાબ, ખુશ પરિવાર.';

  @override
  String get save => 'સાચવો';

  @override
  String get cancel => 'રદ કરો';

  @override
  String get delete => 'કાઢી નાખો';

  @override
  String get edit => 'ફેરફાર કરો';

  @override
  String get add => 'ઉમેરો';

  @override
  String get done => 'થઈ ગયું';

  @override
  String get next => 'આગળ';

  @override
  String get back => 'પાછળ';

  @override
  String get skip => 'છોડો';

  @override
  String get retry => 'ફરી પ્રયાસ કરો';

  @override
  String get close => 'બંધ કરો';

  @override
  String get confirm => 'પુષ્ટિ કરો';

  @override
  String get search => 'શોધો';

  @override
  String get filter => 'ફિલ્ટર';

  @override
  String get clear => 'સાફ કરો';

  @override
  String get apply => 'લાગુ કરો';

  @override
  String get share => 'શેર કરો';

  @override
  String get export => 'નિકાસ કરો';

  @override
  String get yes => 'હા';

  @override
  String get no => 'ના';

  @override
  String get ok => 'બરાબર';

  @override
  String get loading => 'લોડ થઈ રહ્યું છે…';

  @override
  String get optional => 'વૈકલ્પિક';

  @override
  String get notes => 'નોંધ';

  @override
  String get description => 'વર્ણન';

  @override
  String get date => 'તારીખ';

  @override
  String get amount => 'રકમ';

  @override
  String get category => 'શ્રેણી';

  @override
  String get paymentMethod => 'ચુકવણીની રીત';

  @override
  String get person => 'વ્યક્તિ';

  @override
  String get total => 'કુલ';

  @override
  String get viewAll => 'બધું જુઓ';

  @override
  String get none => 'કોઈ નહીં';

  @override
  String get today => 'આજે';

  @override
  String get yesterday => 'ગઈકાલે';

  @override
  String get income => 'આવક';

  @override
  String get expense => 'ખર્ચ';

  @override
  String get balance => 'સિલક';

  @override
  String get details => 'વિગતો';

  @override
  String get more => 'વધુ';

  @override
  String get selectDate => 'તારીખ પસંદ કરો';

  @override
  String createdOn(String date) {
    return '$date ના રોજ બનાવ્યું';
  }

  @override
  String updatedOn(String date) {
    return '$date ના રોજ બદલ્યું';
  }

  @override
  String get genericError => 'કંઈક ખોટું થયું. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get savedMessage => 'સાચવ્યું';

  @override
  String get deletedMessage => 'કાઢી નાખ્યું';

  @override
  String get confirmDeleteTitle => 'આ કાઢી નાખવું છે?';

  @override
  String get confirmDeleteMessage => 'આ પાછું લાવી શકાશે નહીં.';

  @override
  String get discardChangesTitle => 'ફેરફારો છોડી દેવા છે?';

  @override
  String get discardChangesMessage => 'ન સાચવેલા ફેરફારો ગુમ થઈ જશે.';

  @override
  String get discard => 'છોડી દો';

  @override
  String get keepEditing => 'ફેરફાર ચાલુ રાખો';

  @override
  String get offlineBanner =>
      'તમે ઑફલાઇન છો. તમારા ફેરફાર આ ફોનમાં સચવાયેલા છે અને ઇન્ટરનેટ આવતાં તમારા એકાઉન્ટમાં પહોંચી જશે.';

  @override
  String get pmCash => 'રોકડ';

  @override
  String get pmUpi => 'UPI';

  @override
  String get pmBankTransfer => 'બેંક ટ્રાન્સફર';

  @override
  String get pmCreditCard => 'ક્રેડિટ કાર્ડ';

  @override
  String get pmDebitCard => 'ડેબિટ કાર્ડ';

  @override
  String get pmOther => 'અન્ય';

  @override
  String get validationRequired => 'આ માહિતી જરૂરી છે';

  @override
  String get validationAmount => 'માન્ય રકમ લખો (વધુમાં વધુ 2 દશાંશ)';

  @override
  String get validationAmountPositive => 'રકમ શૂન્યથી વધુ હોવી જોઈએ';

  @override
  String get validationPhone => 'માન્ય મોબાઇલ નંબર લખો';

  @override
  String get validationEmail => 'સાચું ઇમેઇલ સરનામું લખો';

  @override
  String validationTooLong(int max) {
    return 'ખૂબ લાંબું છે (વધુમાં વધુ $max અક્ષર)';
  }

  @override
  String get openCalculator => 'કેલ્ક્યુલેટર ખોલો';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count નોંધ',
      one: '1 નોંધ',
      zero: 'કોઈ નોંધ નથી',
    );
    return '$_temp0';
  }

  @override
  String get comingFromDate => 'થી';

  @override
  String get toDate => 'સુધી';

  @override
  String get periodThisMonth => 'આ મહિને';

  @override
  String get periodLastMonth => 'ગયા મહિને';

  @override
  String get periodThisYear => 'આ વર્ષે';

  @override
  String get periodCustom => 'પસંદગીની તારીખો';

  @override
  String get notConfigured => 'ગોઠવાયેલ નથી';

  @override
  String get privateOnDevice => 'ખાનગી · તમારા એકાઉન્ટમાં સચવાયેલું';

  @override
  String get exitAppTitle => 'હિસાબમિત્ર બંધ કરવી છે?';

  @override
  String get exitAppConfirm => 'બંધ કરો';

  @override
  String get exitAppStay => 'રહો';

  @override
  String get errorNotFound => 'આ નોંધ હવે અસ્તિત્વમાં નથી.';

  @override
  String errorInUse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'તે $count નોંધોમાં વપરાયેલ છે.',
      one: 'તે 1 નોંધમાં વપરાયેલ છે.',
    );
    return '$_temp0';
  }

  @override
  String get errorStorage =>
      'ફોનના સ્ટોરેજમાં સાચવી શકાયું નહીં. ખાલી જગ્યા તપાસીને ફરી પ્રયાસ કરો.';

  @override
  String get errorNetwork =>
      'ઇન્ટરનેટ કનેક્શન નથી. તમારો ફેરફાર ફોનમાં સાચવ્યો છે અને પછી સિંક થશે.';

  @override
  String get errorCloudNotConfigured =>
      'એપના આ વર્ઝનમાં ક્લાઉડ સુવિધાઓ ગોઠવાયેલી નથી.';

  @override
  String get errorPermission => 'પરવાનગી મળી નથી.';

  @override
  String get authInvalidOtp =>
      'આ કોડ સાચો નથી. કૃપા કરીને તપાસીને ફરી પ્રયાસ કરો.';

  @override
  String get authOtpExpired => 'કોડની મુદત પૂરી થઈ ગઈ છે. નવો કોડ મંગાવો.';

  @override
  String get authRateLimited =>
      'ઘણા બધા પ્રયાસો થયા. એક મિનિટ રાહ જોઈને ફરી પ્રયાસ કરો.';

  @override
  String get authSessionExpired =>
      'તમારું સત્ર પૂરું થયું છે. કૃપા કરીને ફરી સાઇન ઇન કરો.';

  @override
  String get authGenericError =>
      'અત્યારે સાઇન ઇન થઈ શક્યું નહીં. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get errorPaymentCount =>
      'કુલ હપ્તા, ચૂકવેલા હપ્તા કરતાં વધુ હોવા જોઈએ.';

  @override
  String greeting(String name) {
    return 'નમસ્તે, $name';
  }

  @override
  String get greetingNoName => 'નમસ્તે!';

  @override
  String get dashboardBalanceLabel => 'આ સમયગાળાની બચત';

  @override
  String get dashboardToReceive => 'લેવાના બાકી';

  @override
  String get dashboardToPay => 'આપવાના બાકી';

  @override
  String get quickActions => 'ઝડપી કામ';

  @override
  String get actionAddIncome => 'આવક ઉમેરો';

  @override
  String get actionAddExpense => 'ખર્ચ ઉમેરો';

  @override
  String get actionGiveMoney => 'પૈસા આપ્યા';

  @override
  String get actionReceiveMoney => 'પૈસા લીધા';

  @override
  String get actionCreateGroup => 'ગ્રુપ બનાવો';

  @override
  String get actionGroupExpense => 'ગ્રુપ ખર્ચ';

  @override
  String get actionReports => 'રિપોર્ટ';

  @override
  String get incomeVsExpense => 'આવક સામે ખર્ચ';

  @override
  String get lastSixMonths => 'છેલ્લા 6 મહિના';

  @override
  String get recentTransactions => 'તાજેતરની નોંધો';

  @override
  String get pendingRepayments => 'બાકી ચુકવણી';

  @override
  String get upcomingReminders => 'આગામી રિમાઇન્ડર';

  @override
  String get groupSummaryTitle => 'તમારાં ગ્રુપ';

  @override
  String groupSummaryLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count સક્રિય ગ્રુપ',
      one: '1 સક્રિય ગ્રુપ',
      zero: 'કોઈ સક્રિય ગ્રુપ નથી',
    );
    return '$_temp0';
  }

  @override
  String get youOwe => 'તમારે આપવાના';

  @override
  String get youAreOwed => 'તમારે લેવાના';

  @override
  String get welcomeEmptyTitle => 'ચાલો, તમારો હિસાબ શરૂ કરીએ';

  @override
  String get welcomeEmptyBody =>
      'તમારો પહેલો ખર્ચ કે આવક ઉમેરો. ફક્ત થોડી સેકન્ડ લાગશે.';

  @override
  String get noTransactionsTitle => 'હજી કોઈ નોંધ નથી';

  @override
  String get noTransactionsBody =>
      'તમે ઉમેરેલી નોંધો અહીં તારીખ પ્રમાણે દેખાશે.';

  @override
  String get noResultsTitle => 'કંઈ મળ્યું નહીં';

  @override
  String get noResultsBody => 'બીજું કંઈક શોધો અથવા ફિલ્ટર સાફ કરો.';

  @override
  String get selectPickPeriod => 'સમયગાળો પસંદ કરો';

  @override
  String get transactionsTitle => 'હિસાબ';

  @override
  String get searchTransactionsHint => 'વર્ણન, નોંધ, શ્રેણી કે વ્યક્તિ શોધો';

  @override
  String get filterAll => 'બધું';

  @override
  String get filterType => 'પ્રકાર';

  @override
  String get filterClearAll => 'ફિલ્ટર સાફ કરો';

  @override
  String get addIncomeTitle => 'આવક ઉમેરો';

  @override
  String get addExpenseTitle => 'ખર્ચ ઉમેરો';

  @override
  String get editTransactionTitle => 'નોંધમાં ફેરફાર';

  @override
  String get transactionDetailsTitle => 'નોંધની વિગત';

  @override
  String get amountHint => '0.00';

  @override
  String get descriptionHint => 'દા.ત. બજારમાંથી શાકભાજી';

  @override
  String get personOptional => 'વ્યક્તિ (વૈકલ્પિક)';

  @override
  String get addNewPerson => 'નવી વ્યક્તિ ઉમેરો';

  @override
  String get manageCategories => 'સંચાલન';

  @override
  String get chooseCategory => 'શ્રેણી પસંદ કરો';

  @override
  String get transactionSaved => 'નોંધ સાચવી';

  @override
  String get transactionDeleted => 'નોંધ કાઢી નાખી';

  @override
  String get deleteTransactionMessage =>
      'આ નોંધ અને તેનાં જોડાણો તમારા એકાઉન્ટમાંથી અને આ ફોનમાંથી કાઢી નખાશે.';

  @override
  String dayNet(String amount) {
    return 'ચોખ્ખું $amount';
  }

  @override
  String get monthIncomeShort => 'જમા';

  @override
  String get monthExpenseShort => 'ઉધાર';

  @override
  String get categoriesTitle => 'શ્રેણીઓ';

  @override
  String get addCategory => 'શ્રેણી ઉમેરો';

  @override
  String get editCategory => 'શ્રેણીમાં ફેરફાર';

  @override
  String get categoryName => 'શ્રેણીનું નામ';

  @override
  String get categoryNameEnglish => 'નામ (અંગ્રેજી)';

  @override
  String get categoryNameGujarati => 'નામ (ગુજરાતી)';

  @override
  String get categoryIcon => 'ચિહ્ન';

  @override
  String get categoryColor => 'રંગ';

  @override
  String get categoryType => 'પ્રકાર';

  @override
  String categoryUsage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count નોંધોમાં વપરાઈ',
      one: '1 નોંધમાં વપરાઈ',
      zero: 'હજી વપરાઈ નથી',
    );
    return '$_temp0';
  }

  @override
  String get categoryDeleteInUseTitle => 'કાઢતાં પહેલાં નોંધો ખસેડો';

  @override
  String categoryDeleteInUseBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count નોંધો આ શ્રેણી વાપરે છે.',
      one: '1 નોંધ આ શ્રેણી વાપરે છે.',
    );
    return '$_temp0 તેમને ક્યાં ખસેડવી તે પસંદ કરો.';
  }

  @override
  String get categoryMoveAndDelete => 'ખસેડો અને કાઢો';

  @override
  String get calculatorTitle => 'કેલ્ક્યુલેટર';

  @override
  String get calculatorBasic => 'કેલ્ક્યુલેટર';

  @override
  String get calculatorUnit => 'ભાવ × જથ્થો';

  @override
  String get unitPrice => 'એકમ ભાવ';

  @override
  String get quantity => 'જથ્થો';

  @override
  String calculatorUseAmount(String amount) {
    return '$amount વાપરો';
  }

  @override
  String get calculatorInvalid => 'અધૂરી ગણતરી';

  @override
  String get calculatorCopy => 'જવાબ કૉપી કરો';

  @override
  String get copied => 'કૉપી થયું';

  @override
  String get catFood => 'ભોજન અને નાસ્તો';

  @override
  String get catGroceries => 'કરિયાણું';

  @override
  String get catTransport => 'વાહનવ્યવહાર';

  @override
  String get catFuel => 'પેટ્રોલ-ડીઝલ';

  @override
  String get catShopping => 'ખરીદી';

  @override
  String get catBills => 'બિલ અને સેવાઓ';

  @override
  String get catRent => 'ભાડું';

  @override
  String get catHealth => 'આરોગ્ય';

  @override
  String get catEducation => 'શિક્ષણ';

  @override
  String get catEntertainment => 'મનોરંજન';

  @override
  String get catTravel => 'પ્રવાસ';

  @override
  String get catFestivals => 'તહેવાર અને ભેટ';

  @override
  String get catHousehold => 'ઘરવખરી';

  @override
  String get catMobile => 'મોબાઇલ અને ઇન્ટરનેટ';

  @override
  String get catPersonalCare => 'વ્યક્તિગત સંભાળ';

  @override
  String get catDonation => 'દાન';

  @override
  String get catOtherExpense => 'અન્ય ખર્ચ';

  @override
  String get catSalary => 'પગાર';

  @override
  String get catBusiness => 'ધંધો';

  @override
  String get catFreelance => 'ફ્રીલાન્સ';

  @override
  String get catInterest => 'વ્યાજ';

  @override
  String get catRentalIncome => 'ભાડાની આવક';

  @override
  String get catGiftsReceived => 'મળેલી ભેટ';

  @override
  String get catRefund => 'રિફંડ';

  @override
  String get catOtherIncome => 'અન્ય આવક';

  @override
  String get errorRepaymentExceeds => 'રકમ બાકી રકમ કરતાં વધુ છે.';

  @override
  String get errorSplitInvalid => 'વહેંચણીનો સરવાળો કુલ રકમ જેટલો નથી.';

  @override
  String get errorCategoryType => 'સમાન પ્રકારની શ્રેણી પસંદ કરો.';

  @override
  String get errorPersonOutstanding =>
      'કાઢતાં પહેલાં આ વ્યક્તિ સાથેની બધી બાકી રકમ ચૂકતે કરો.';

  @override
  String get errorPrincipalBelowRepaid =>
      'રકમ પહેલેથી પાછી મળેલી રકમથી ઓછી ન હોઈ શકે.';

  @override
  String get errorMemberInUse =>
      'આ સભ્યના ખર્ચ કે ચુકવણી નોંધાયેલ છે, તેથી તેમને દૂર કરી શકાશે નહીં.';

  @override
  String get errorSettlementExceeds =>
      'આ રકમ આપનારના બાકી કે લેનારના લેણાં કરતાં વધુ છે.';

  @override
  String get errorSameMember => 'આપનાર અને લેનાર અલગ હોવા જોઈએ.';

  @override
  String get errorGroupShared =>
      'શેર કરેલું ગ્રુપ કાઢી શકાતું નથી. તેને આર્કાઇવ કરો.';

  @override
  String get transactionsShowList => 'યાદી રૂપે જુઓ';

  @override
  String get transactionsShowSheet => 'પત્રક રૂપે જુઓ';

  @override
  String get runningBalance => 'ચાલુ સિલક';

  @override
  String get sheetTip =>
      'ખાતાની જેમ જૂની એન્ટ્રી પહેલાં. ખોલવા માટે લાઇન પર ટૅપ કરો.';

  @override
  String get groupsTitle => 'ગ્રુપ';

  @override
  String get createGroup => 'ગ્રુપ બનાવો';

  @override
  String get editGroup => 'ગ્રુપમાં ફેરફાર';

  @override
  String get groupName => 'ગ્રુપનું નામ';

  @override
  String get groupNameHint => 'દા.ત. ગોવા પ્રવાસ 2026';

  @override
  String get groupType => 'ગ્રુપનો પ્રકાર';

  @override
  String get groupTypeTrip => 'પ્રવાસ';

  @override
  String get groupTypeFamily => 'પરિવાર';

  @override
  String get groupTypeFriends => 'મિત્રો';

  @override
  String get groupTypeEvent => 'પ્રસંગ';

  @override
  String get groupTypeHousehold => 'ઘરખર્ચ';

  @override
  String get groupTypeOther => 'અન્ય';

  @override
  String get groupMembers => 'સભ્યો';

  @override
  String get addMember => 'સભ્ય ઉમેરો';

  @override
  String get memberName => 'સભ્યનું નામ';

  @override
  String memberYou(String name) {
    return '$name (તમે)';
  }

  @override
  String get fromPeople => 'લોકોમાંથી';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count સભ્યો',
      one: '1 સભ્ય',
    );
    return '$_temp0';
  }

  @override
  String get totalSpent => 'કુલ ખર્ચ';

  @override
  String get yourBalance => 'તમારી સિલક';

  @override
  String get showArchived => 'આર્કાઇવ કરેલાં બતાવો';

  @override
  String get archived => 'આર્કાઇવ કરેલું';

  @override
  String get archiveGroup => 'ગ્રુપ આર્કાઇવ કરો';

  @override
  String get unarchiveGroup => 'ગ્રુપ પાછું લાવો';

  @override
  String get deleteGroup => 'ગ્રુપ કાઢી નાખો';

  @override
  String get deleteGroupMessage =>
      'આ ગ્રુપ અને તેના બધા ખર્ચ આ ફોનમાંથી કાઢી નખાશે.';

  @override
  String get noGroupsTitle => 'હજી કોઈ ગ્રુપ નથી';

  @override
  String get noGroupsBody =>
      'પ્રવાસ, પરિવાર કે પ્રસંગ માટે ગ્રુપ બનાવો અને ખર્ચ યોગ્ય રીતે વહેંચો.';

  @override
  String get groupSaved => 'ગ્રુપ સાચવ્યું';

  @override
  String get groupExpenses => 'ખર્ચ';

  @override
  String get groupBalances => 'સિલક';

  @override
  String get addGroupExpense => 'ખર્ચ ઉમેરો';

  @override
  String get editGroupExpense => 'ખર્ચમાં ફેરફાર';

  @override
  String get groupExpenseDetail => 'ખર્ચની વિગત';

  @override
  String get paidBy => 'કોણે ચૂકવ્યા';

  @override
  String paidByName(String name) {
    return '$name એ ચૂકવ્યા';
  }

  @override
  String get splitMethod => 'વહેંચણીની રીત';

  @override
  String get splitEqual => 'સરખા ભાગે';

  @override
  String get splitExact => 'ચોક્કસ રકમ';

  @override
  String get splitPercentage => 'ટકાવારી';

  @override
  String get splitRatio => 'ગુણોત્તર / ભાગ';

  @override
  String get splitAdjustment => 'અસમાન (+/−)';

  @override
  String get splitEqualHelp => 'પસંદ કરેલા લોકો વચ્ચે સરખા ભાગે વહેંચો.';

  @override
  String get splitExactHelp =>
      'દરેક વ્યક્તિએ કેટલા આપવાના છે તે લખો. સરવાળો કુલ જેટલો હોવો જોઈએ.';

  @override
  String get splitPercentageHelp =>
      'દરેક વ્યક્તિ માટે ટકા લખો. સરવાળો 100% હોવો જોઈએ.';

  @override
  String get splitRatioHelp =>
      'ભાગ લખો, દા.ત. દંપતી માટે 2 અને એકલ વ્યક્તિ માટે 1.';

  @override
  String get splitAdjustmentHelp =>
      'સરખા ભાગ ઉપરાંત અમુક લોકો માટે વધારાની કે ઓછી રકમ.';

  @override
  String get participants => 'કોની વચ્ચે વહેંચવું';

  @override
  String get selectAll => 'બધાને પસંદ કરો';

  @override
  String get splitPreview => 'વહેંચણીની ઝલક';

  @override
  String splitRemaining(String amount) {
    return 'બાકી $amount';
  }

  @override
  String splitOver(String amount) {
    return '$amount વધુ';
  }

  @override
  String percentTotal(String percent) {
    return 'કુલ $percent%';
  }

  @override
  String get splitNeedsParticipants => 'ઓછામાં ઓછી એક વ્યક્તિ પસંદ કરો.';

  @override
  String get splitAdjustmentsTooBig => 'ફેરફારની રકમ કુલ કરતાં વધુ છે.';

  @override
  String get splitNegativeShare => 'ફેરફારથી કોઈનો ભાગ શૂન્યથી ઓછો થાય છે.';

  @override
  String get splitZeroShares => 'ઓછામાં ઓછો એક ભાગ લખો.';

  @override
  String get groupExpenseSaved => 'ખર્ચ સાચવ્યો';

  @override
  String get deleteGroupExpenseMessage => 'આ ખર્ચ ગ્રુપની સિલકમાંથી દૂર થશે.';

  @override
  String get owes => 'આપવાના';

  @override
  String get getsBack => 'લેવાના';

  @override
  String get settledUp => 'ચૂકતે';

  @override
  String get suggestedSettlements => 'સૂચવેલી ચુકવણી';

  @override
  String get settleUp => 'ચૂકતે કરો';

  @override
  String get recordSettlement => 'ચુકવણી નોંધો';

  @override
  String get settlementFrom => 'કોણે ચૂકવ્યા';

  @override
  String get settlementTo => 'કોને મળ્યા';

  @override
  String get settlementSaved => 'ચુકવણી નોંધાઈ';

  @override
  String get settlementHistory => 'ચુકવણીનો ઇતિહાસ';

  @override
  String get noSettlements => 'હજી કોઈ ચુકવણી નથી';

  @override
  String get deleteSettlementConfirm =>
      'આ ચુકવણી કાઢવી છે? સિલક પાછી બદલાઈ જશે.';

  @override
  String get groupAllSettled => 'બધાનો હિસાબ ચૂકતે છે';

  @override
  String paysTo(String from, String to) {
    return '$from → $to';
  }

  @override
  String maxSettlement(String amount) {
    return 'વધુમાં વધુ $amount';
  }

  @override
  String get paid => 'ચૂકવ્યા';

  @override
  String get memberShare => 'ભાગ';

  @override
  String get net => 'ચોખ્ખું';

  @override
  String get settlementStatus => 'સ્થિતિ';

  @override
  String get statusPending => 'બાકી';

  @override
  String get statusPartlySettled => 'અંશતઃ ચૂકતે';

  @override
  String get statusSettledShort => 'ચૂકતે';

  @override
  String get viewSpreadsheet => 'પત્રક';

  @override
  String get viewCards => 'કાર્ડ';

  @override
  String get viewTimeline => 'સમયરેખા';

  @override
  String get filterMember => 'સભ્ય';

  @override
  String get filterDate => 'તારીખ';

  @override
  String get noGroupExpensesTitle => 'હજી કોઈ ખર્ચ નથી';

  @override
  String get noGroupExpensesBody =>
      'પહેલો ખર્ચ ઉમેરો — વહેંચણીની ગણતરી આપમેળે થશે.';

  @override
  String get gcatFood => 'ભોજન';

  @override
  String get gcatTravel => 'મુસાફરી';

  @override
  String get gcatStay => 'રહેવાનું';

  @override
  String get gcatTickets => 'ટિકિટ';

  @override
  String get gcatShopping => 'ખરીદી';

  @override
  String get gcatGroceries => 'કરિયાણું';

  @override
  String get gcatFuel => 'પેટ્રોલ';

  @override
  String get gcatEntertainment => 'મોજમજા';

  @override
  String get gcatGifts => 'ભેટ';

  @override
  String get gcatUtilities => 'બિલ';

  @override
  String get gcatRent => 'ભાડું';

  @override
  String get gcatOther => 'અન્ય';

  @override
  String get removeMember => 'સભ્યને દૂર કરો';

  @override
  String get renameMember => 'નામ બદલો';

  @override
  String get memberRemoved => 'સભ્ય દૂર કર્યા';

  @override
  String get roleOwner => 'માલિક';

  @override
  String get roleAdmin => 'સંચાલક';

  @override
  String get roleMember => 'સભ્ય';

  @override
  String get localParticipant => 'ફક્ત આ ફોનમાં';

  @override
  String get cloudMember => 'એપ દ્વારા જોડાયેલ';

  @override
  String get sharedGroup => 'શેર કરેલું';

  @override
  String get localGroup => 'આ ફોનમાં';

  @override
  String get pickGroup => 'ગ્રુપ પસંદ કરો';

  @override
  String timelineSettlement(String from, String to) {
    return '$from એ $to ને ચૂકવ્યા';
  }

  @override
  String expensesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ખર્ચ',
      one: '1 ખર્ચ',
      zero: 'કોઈ ખર્ચ નથી',
    );
    return '$_temp0';
  }

  @override
  String get inviteMembers => 'સભ્યોને આમંત્રણ';

  @override
  String get joinGroup => 'ગ્રુપમાં જોડાઓ';

  @override
  String get khataTitle => 'ખાતું';

  @override
  String get ledgerGivenLabel => 'મેં આપ્યા';

  @override
  String get ledgerTakenLabel => 'મેં લીધા';

  @override
  String get ledgerGivenLong => 'આપેલા પૈસા — તમારે લેવાના';

  @override
  String get ledgerTakenLong => 'લીધેલા પૈસા — તમારે આપવાના';

  @override
  String get netBalance => 'ચોખ્ખી સિલક';

  @override
  String owesYou(String name) {
    return '$name પાસેથી લેવાના';
  }

  @override
  String youOweName(String name) {
    return '$name ને આપવાના';
  }

  @override
  String get allSettled => 'બધું ચૂકતે';

  @override
  String get statusOpen => 'બાકી';

  @override
  String get statusPartial => 'આંશિક ચૂકવેલ';

  @override
  String get statusSettled => 'ચૂકતે';

  @override
  String dueOn(String date) {
    return '$date સુધીમાં';
  }

  @override
  String get overdue => 'મુદત વીતી ગઈ';

  @override
  String get principal => 'મૂળ રકમ';

  @override
  String get repaid => 'ચૂકવાયેલ';

  @override
  String get outstanding => 'બાકી રકમ';

  @override
  String get recordRepayment => 'ચુકવણી નોંધો';

  @override
  String get repaymentReceivedTitle => 'પાછા મળેલા પૈસા';

  @override
  String get repaymentPaidTitle => 'પાછા આપેલા પૈસા';

  @override
  String get repaymentSaved => 'ચુકવણી નોંધાઈ';

  @override
  String get repaymentExceedsTitle => 'બાકી રકમ કરતાં વધુ';

  @override
  String repaymentExceedsBody(String due, String extra) {
    return 'ફક્ત $due બાકી છે. વધારાના $extra સામેની બાજુ એડવાન્સ / જમા તરીકે નોંધવા છે?';
  }

  @override
  String get recordAsAdvance => 'એડવાન્સ તરીકે નોંધો';

  @override
  String get advanceCredit => 'એડવાન્સ / જમા';

  @override
  String get repaymentHistory => 'ચુકવણીનો ઇતિહાસ';

  @override
  String get noRepayments => 'હજી કોઈ ચુકવણી નથી';

  @override
  String get ledgerEntries => 'નોંધો';

  @override
  String get noLedgerTitle => 'તમારું ખાતું ખાલી છે';

  @override
  String get noLedgerBody =>
      'તમે આપેલા કે લીધેલા પૈસા નોંધો અને ચુકવણી પર નજર રાખો.';

  @override
  String get dueDateOptional => 'પરત કરવાની તારીખ (વૈકલ્પિક)';

  @override
  String get ledgerEntryTitleNew => 'ખાતામાં નવી નોંધ';

  @override
  String get ledgerEntryTitleEdit => 'ખાતાની નોંધમાં ફેરફાર';

  @override
  String get ledgerEntryDetailTitle => 'ખાતાની નોંધ';

  @override
  String get ledgerSaved => 'ખાતામાં નોંધ સાચવી';

  @override
  String get deleteLedgerMessage =>
      'આ નોંધ અને તેની ચુકવણીનો ઇતિહાસ કાઢી નખાશે.';

  @override
  String get deleteRepaymentConfirm =>
      'આ ચુકવણી કાઢવી છે? બાકી રકમ ફરી વધી જશે.';

  @override
  String get filterToReceive => 'લેવાના';

  @override
  String get filterToPay => 'આપવાના';

  @override
  String get filterSettled => 'ચૂકતે';

  @override
  String get peopleTitle => 'લોકો';

  @override
  String get addPerson => 'વ્યક્તિ ઉમેરો';

  @override
  String get editPerson => 'વ્યક્તિની વિગતમાં ફેરફાર';

  @override
  String get personName => 'નામ';

  @override
  String get mobileNumber => 'મોબાઇલ નંબર';

  @override
  String get emailOptional => 'ઇમેઇલ (વૈકલ્પિક)';

  @override
  String get pickFromContacts => 'સંપર્કમાંથી પસંદ કરો';

  @override
  String get contactsHint =>
      'તમે પસંદ કરેલો સંપર્ક જ વંચાય છે. હિસાબમિત્ર તમારા બીજા સંપર્કો જોઈ શકતું નથી.';

  @override
  String get personSaved => 'વ્યક્તિ સાચવી';

  @override
  String get deletePersonMessage =>
      'આ વ્યક્તિ અને તેમના ચૂકતે થયેલા ખાતાનો ઇતિહાસ કાઢી નખાશે.';

  @override
  String get noPeopleTitle => 'હજી કોઈ વ્યક્તિ નથી';

  @override
  String get noPeopleBody =>
      'જેમને તમે પૈસા ઉધાર આપો છો કે જેમની પાસેથી લો છો તેમને ઉમેરો.';

  @override
  String get searchPeople => 'લોકો શોધો';

  @override
  String get totalGiven => 'કુલ આપ્યા';

  @override
  String get totalTaken => 'કુલ લીધા';

  @override
  String get personTransactions => 'આવક અને ખર્ચ';

  @override
  String get callPerson => 'ફોન કરો';

  @override
  String get selectPerson => 'વ્યક્તિ પસંદ કરો';

  @override
  String get addEntry => 'નોંધ ઉમેરો';

  @override
  String get remindLater => 'રિમાઇન્ડર મૂકો';

  @override
  String repaymentFor(String description) {
    return 'માટે: $description';
  }

  @override
  String repaidProgress(String repaid, String total) {
    return '$total માંથી $repaid ચૂકવાયા';
  }

  @override
  String get settlementHistoryTitle => 'ચુકવણીનો ઇતિહાસ';

  @override
  String get ledgerNotIncomeNote =>
      'ખાતાની નોંધો ઉધાર છે, આવક કે ખર્ચ નથી, તેથી તમારી બચત પર અસર કરતી નથી.';

  @override
  String get navHome => 'મુખ્ય';

  @override
  String get navTransactions => 'હિસાબ';

  @override
  String get navPeople => 'ખાતું';

  @override
  String get navGroups => 'ગ્રુપ';

  @override
  String get navMore => 'વધુ';

  @override
  String get languageTitle => 'તમારી ભાષા પસંદ કરો';

  @override
  String get languageSubtitle => 'તમે ગમે ત્યારે સેટિંગ્સમાં બદલી શકો છો.';

  @override
  String get languageEnglish => 'English (અંગ્રેજી)';

  @override
  String get languageGujarati => 'ગુજરાતી';

  @override
  String get onboardTitle1 => 'તમારો રોજનો હિસાબ, એકદમ સરળ';

  @override
  String get onboardBody1 =>
      'આવક અને ખર્ચ સેકન્ડોમાં નોંધો. બધું તમારા એકાઉન્ટમાં સચવાય છે, અને ઇન્ટરનેટ વિના પણ ચાલે છે.';

  @override
  String get onboardTitle2 => 'ઉધાર આપો, ઉધાર લો, ચૂકતે કરો';

  @override
  String get onboardBody2 =>
      'આપેલા અને લીધેલા પૈસાનું સ્પષ્ટ ખાતું રાખો — આંશિક ચુકવણી અને યાદ અપાવતા રિમાઇન્ડર સાથે.';

  @override
  String get onboardTitle3 => 'પરિવાર અને મિત્રો સાથે ખર્ચ વહેંચો';

  @override
  String get onboardBody3 =>
      'પ્રવાસ, તહેવાર અને ઘરખર્ચ યોગ્ય રીતે વહેંચો — છેલ્લા પૈસા સુધી.';

  @override
  String get getStarted => 'શરૂ કરીએ';

  @override
  String get profileSetupTitle => 'તમારું એકાઉન્ટ બનાવો';

  @override
  String get profileSetupSubtitle =>
      'નામ, ઇમેઇલ અને મોબાઇલ નંબર જરૂરી છે. અમે તમારો ઇમેઇલ ચકાસીએ છીએ; તમારો હિસાબ આ એકાઉન્ટમાં સચવાશે.';

  @override
  String get yourName => 'તમારું નામ';

  @override
  String get startUsing => 'હિસાબમિત્ર વાપરવાનું શરૂ કરો';

  @override
  String get privacyPromise =>
      'તમારો હિસાબ તમારા એકાઉન્ટમાં સચવાય છે, અને તે ફક્ત તમે જ જોઈ શકો છો.';

  @override
  String get remindersTitle => 'રિમાઇન્ડર';

  @override
  String get addReminder => 'રિમાઇન્ડર ઉમેરો';

  @override
  String get editReminder => 'રિમાઇન્ડરમાં ફેરફાર';

  @override
  String get reminderTitle => 'શું યાદ રાખવું છે';

  @override
  String get reminderTime => 'સમય';

  @override
  String get reminderRepeat => 'પુનરાવર્તન';

  @override
  String get repeatNone => 'એક વાર';

  @override
  String get repeatDaily => 'દરરોજ';

  @override
  String get repeatWeekly => 'દર અઠવાડિયે';

  @override
  String get repeatMonthly => 'દર મહિને';

  @override
  String get reminderKind => 'પ્રકાર';

  @override
  String get kindRepayment => 'પૈસા પાછા આપવા';

  @override
  String get kindCollection => 'પૈસા લેવા';

  @override
  String get kindGroupSettlement => 'ગ્રુપ ચુકવણી';

  @override
  String get kindCustom => 'અન્ય';

  @override
  String get reminderSaved => 'રિમાઇન્ડર મૂક્યું';

  @override
  String get reminderDone => 'પૂર્ણ થયું';

  @override
  String get reminderCancel => 'રિમાઇન્ડર રદ કરો';

  @override
  String get reminderUpcoming => 'આગામી';

  @override
  String get reminderHistory => 'પૂર્ણ અને રદ';

  @override
  String get noRemindersTitle => 'કોઈ રિમાઇન્ડર નથી';

  @override
  String get noRemindersBody => 'ચુકવણી, ઉઘરાણી કે બિલ માટે રિમાઇન્ડર મૂકો.';

  @override
  String get reminderPast => 'આ સમય વીતી ગયો છે.';

  @override
  String get notificationsDenied =>
      'હિસાબમિત્ર માટે સૂચનાઓ બંધ છે. તમે Android સેટિંગ્સમાં ચાલુ કરી શકો છો.';

  @override
  String get notificationGenericTitle => 'હિસાબમિત્ર રિમાઇન્ડર';

  @override
  String get notificationGenericBody =>
      'તમારું રિમાઇન્ડર જોવા હિસાબમિત્ર ખોલો.';

  @override
  String reminderCollectTitle(String amount, String name) {
    return '$name પાસેથી $amount લેવાના';
  }

  @override
  String reminderRepayTitle(String amount, String name) {
    return '$name ને $amount આપવાના';
  }

  @override
  String reminderSettleTitle(String group) {
    return '$group માં હિસાબ ચૂકતે કરો';
  }

  @override
  String get statusDone => 'પૂર્ણ';

  @override
  String get statusCancelled => 'રદ';

  @override
  String get kindEmi => 'EMI (હપ્તો)';

  @override
  String get kindSip => 'SIP';

  @override
  String get kindInstallment => 'હપ્તો';

  @override
  String get kindMaintenance => 'મેન્ટેનન્સ';

  @override
  String get kindInsurance => 'વીમા પ્રીમિયમ';

  @override
  String get kindRent => 'ભાડું';

  @override
  String get kindSubscription => 'સબ્સ્ક્રિપ્શન';

  @override
  String get kindBill => 'બિલ';

  @override
  String get repeatQuarterly => 'દર 3 મહિને';

  @override
  String get repeatHalfYearly => 'દર 6 મહિને';

  @override
  String get repeatYearly => 'વાર્ષિક';

  @override
  String get reminderTypePayment => 'નિયમિત ચુકવણી';

  @override
  String get reminderTypeReminder => 'રિમાઇન્ડર';

  @override
  String get paymentType => 'ચુકવણીનો પ્રકાર';

  @override
  String get paymentAmount => 'નક્કી રકમ';

  @override
  String get paymentCategory => 'ખર્ચની શ્રેણી';

  @override
  String get paymentCategoryHint => 'ચુકવણી નોંધતી વખતે વપરાશે';

  @override
  String get paymentEnds => 'ક્યારે પૂરું થાય';

  @override
  String get paymentEndsNever => 'કોઈ અંતિમ તારીખ નહીં';

  @override
  String get paymentEndsAfter => 'નક્કી હપ્તા પછી';

  @override
  String get paymentCount => 'કુલ હપ્તા';

  @override
  String paymentProgress(int done, int total) {
    return '$total માંથી $done ચૂકવ્યા';
  }

  @override
  String paymentsPaidSoFar(int count) {
    return 'અત્યાર સુધી $count ચૂકવ્યા';
  }

  @override
  String get markPaid => 'ચૂકવ્યું';

  @override
  String get recordPaymentTitle => 'આ ચુકવણી નોંધવી છે?';

  @override
  String recordPaymentBody(String amount, String title) {
    return '$title માટે $amount. હિસાબમાં ખર્ચ તરીકે ઉમેરવું છે?';
  }

  @override
  String get recordAsExpense => 'ખર્ચ તરીકે ઉમેરો';

  @override
  String get justMarkPaid => 'ફક્ત ચૂકવ્યું નોંધો';

  @override
  String get paymentsDueThisMonth => 'આ મહિને ભરવાની ચુકવણી';

  @override
  String get addRecurringPayment => 'નિયમિત ચુકવણી ઉમેરો';

  @override
  String notificationPaymentBody(String amount) {
    return '$amount ભરવાના છે';
  }

  @override
  String get reminderBatteryTip =>
      'કેટલાક ફોનમાં (Xiaomi, Oppo, Vivo વગેરે) બૅટરી બચત રિમાઇન્ડર રોકી શકે છે. રિમાઇન્ડર સમયસર મળે તે માટે હિસાબમિત્રને બેકગ્રાઉન્ડમાં ચાલવાની મંજૂરી આપો.';

  @override
  String get reminderBatteryTipOpen => 'સેટિંગ્સ ખોલો';

  @override
  String get reminderBatteryTipDismiss => 'સમજાયું';

  @override
  String get reportsTitle => 'રિપોર્ટ';

  @override
  String get reportOverview => 'આવક અને ખર્ચ';

  @override
  String get reportOverviewDesc => 'માસિક આવક, ખર્ચ અને બચત';

  @override
  String get reportCategories => 'શ્રેણી મુજબ ખર્ચ';

  @override
  String get reportCategoriesDesc => 'તમારા પૈસા ક્યાં ગયા';

  @override
  String get reportPaymentMethods => 'ચુકવણીની રીતો';

  @override
  String get reportPaymentMethodsDesc => 'રોકડ, UPI, કાર્ડ અને બેંક';

  @override
  String get reportPeople => 'ઉધાર આપ-લે';

  @override
  String get reportPeopleDesc => 'સમયગાળા માટે વ્યક્તિ મુજબ ખાતું';

  @override
  String get reportGroups => 'ગ્રુપ ખર્ચ';

  @override
  String get reportGroupsDesc => 'ગ્રુપમાં ખર્ચ અને ચુકવણી';

  @override
  String get savings => 'બચત';

  @override
  String get exportCsv => 'CSV (Excel) નિકાસ';

  @override
  String get exportPdf => 'PDF નિકાસ';

  @override
  String get exportFailed => 'નિકાસ ફાઇલ બનાવી શકાઈ નહીં.';

  @override
  String get monthlyBreakdown => 'માસિક વિગત';

  @override
  String get topExpenses => 'સૌથી મોટા ખર્ચ';

  @override
  String get loansGiven => 'આપેલા પૈસા (ઉધાર)';

  @override
  String get loansTaken => 'લીધેલા પૈસા (ઉધાર)';

  @override
  String get repaymentsReceived => 'પાછા મળેલા પૈસા';

  @override
  String get repaymentsPaid => 'પાછા આપેલા પૈસા';

  @override
  String get groupSettlementsLabel => 'ગ્રુપ ચુકવણી';

  @override
  String get reportSeparationNote =>
      'ઉધાર, તેની ચુકવણી અને ગ્રુપ ચુકવણી અલગ બતાવવામાં આવે છે. તેમને આવક કે ખર્ચ ગણવામાં આવતા નથી.';

  @override
  String generatedOn(String date) {
    return '$date ના રોજ હિસાબમિત્ર દ્વારા તૈયાર';
  }

  @override
  String pageOf(int page, int total) {
    return 'પાનું $page / $total';
  }

  @override
  String reportPeriod(String from, String to) {
    return '$from – $to';
  }

  @override
  String get colType => 'પ્રકાર';

  @override
  String get colMonth => 'મહિનો';

  @override
  String get colCount => 'નોંધો';

  @override
  String get colShare => 'કુલનો %';

  @override
  String get myShare => 'મારો ભાગ';

  @override
  String get iPaid => 'મેં ચૂકવ્યા';

  @override
  String get noDataForPeriod => 'આ સમયગાળામાં કોઈ નોંધ નથી';

  @override
  String get transactionsExportTitle => 'વ્યવહારો';

  @override
  String get fullReportTitle => 'નાણાકીય રિપોર્ટ';

  @override
  String get settlementSummary => 'ચુકવણીનો સારાંશ';

  @override
  String shareReportCaption(String title, String period) {
    return '📊 *હિસાબમિત્ર રિપોર્ટ* · $title · $period';
  }

  @override
  String get settingsTitle => 'સેટિંગ્સ';

  @override
  String get settingsAppearance => 'દેખાવ';

  @override
  String get settingsTheme => 'રંગ થીમ';

  @override
  String get paletteRannUtsav => 'રણ ઉત્સવ';

  @override
  String get paletteRannUtsavDesc =>
      'પૂનમની રાતે કચ્છના સફેદ રણનો નેવી, ચાંદી અને લાલ';

  @override
  String get paletteBandhaniLal => 'બાંધણી લાલ';

  @override
  String get paletteBandhaniLalDesc => 'લાલ ચોપડાનો મરૂન અને કેસર';

  @override
  String get paletteKesariyo => 'કેસરિયો';

  @override
  String get paletteKesariyoDesc => 'નવરાત્રીનો કેસરી અને જાંબુડી';

  @override
  String get palettePatolaRani => 'પટોળા રાણી';

  @override
  String get palettePatolaRaniDesc =>
      'પાટણના પટોળાનો રાણી ગુલાબી, હળદર અને રીંગણી';

  @override
  String get paletteNeelGagan => 'નીલ ગગન';

  @override
  String get paletteNeelGaganDesc => 'ઉત્તરાયણના આકાશનો આસમાની અને ગળી';

  @override
  String get settingsLanguage => 'ભાષા';

  @override
  String get settingsFinance => 'નાણાં';

  @override
  String get settingsCurrency => 'મુખ્ય ચલણ';

  @override
  String get currencyInr => 'ભારતીય રૂપિયો (₹)';

  @override
  String get settingsDateFormat => 'તારીખનું સ્વરૂપ';

  @override
  String get settingsNumberFormat => 'આંકડાનું સ્વરૂપ';

  @override
  String get numberFormatIndian => 'ભારતીય (1,23,456.00)';

  @override
  String get numberFormatInternational => 'આંતરરાષ્ટ્રીય (123,456.00)';

  @override
  String get settingsCalculatorAuto => 'કુલ આપમેળે ગણો';

  @override
  String get settingsCalculatorAutoDesc =>
      'એકમ ભાવ કે જથ્થો બદલાય ત્યારે રકમ બદલાય';

  @override
  String get settingsGroupSection => 'ગ્રુપ';

  @override
  String get settingsDefaultGroupView => 'ગ્રુપનો મુખ્ય દેખાવ';

  @override
  String get groupViewSpreadsheet => 'પત્રક';

  @override
  String get groupViewCards => 'કાર્ડ';

  @override
  String get groupViewTimeline => 'સમયરેખા';

  @override
  String get settingsGroupNotifications => 'ગ્રુપ ચૂકવણી રિમાઇન્ડર';

  @override
  String get settingsNotifications => 'સૂચનાઓ';

  @override
  String get settingsReminderNotifications => 'રિમાઇન્ડર સૂચનાઓ';

  @override
  String get settingsHideAmounts => 'સૂચનામાં રકમ છુપાવો';

  @override
  String get settingsHideAmountsDesc => 'સૂચનામાં ફક્ત સામાન્ય સંદેશ દેખાશે';

  @override
  String get settingsSync => 'ક્લાઉડ સિંક';

  @override
  String get settingsSyncStatus => 'સિંકની સ્થિતિ';

  @override
  String get settingsBackup => 'બેકઅપ અને રિસ્ટોર';

  @override
  String get settingsBackupDesc => 'જાતે, આપમેળે અને એન્ક્રિપ્ટેડ બેકઅપ';

  @override
  String get autoBackupOff => 'બંધ';

  @override
  String get settingsAi => 'AI સહાયક';

  @override
  String get settingsAiEnabled => 'AI સહાયક ચાલુ કરો';

  @override
  String get settingsAiEnabledDesc =>
      'આ ફોનમાં થયેલી ગણતરીઓથી પ્રશ્નોના જવાબ આપે છે';

  @override
  String get settingsAiProvider => 'જવાબ આપનાર એન્જિન';

  @override
  String get aiProviderLocal => 'ફોનમાં જ (ખાનગી)';

  @override
  String get aiProviderOnline => 'ઓનલાઇન AI (Claude)';

  @override
  String get settingsAiConsent => 'ઓનલાઇન AI સાથે સારાંશ શેર કરવાની મંજૂરી';

  @override
  String get settingsAiConsentDesc =>
      'તમારા પ્રશ્નના જવાબ માટે જરૂરી કુલ આંકડા જ મોકલાય છે. મૂળ વ્યવહારો, નોંધ અને જોડાણો ક્યારેય મોકલાતાં નથી.';

  @override
  String get settingsAiShareNames => 'લોકો અને ગ્રુપનાં નામ સામેલ કરો';

  @override
  String get settingsAiApiKey => 'ઓનલાઇન AI API કી';

  @override
  String get settingsAiApiKeySet => 'કી સુરક્ષિત રીતે સાચવી છે';

  @override
  String get settingsAiApiKeyMissing => 'કોઈ કી સાચવેલી નથી';

  @override
  String get settingsAiPrivacy => 'AI તમારા ડેટાનો ઉપયોગ કેવી રીતે કરે છે';

  @override
  String get aiPrivacyExplanation =>
      'બધી રકમની ગણતરી હિસાબમિત્ર તમારા ફોનમાં જ કરે છે. ફોનમાંના એન્જિન સાથે કંઈ પણ ફોનની બહાર જતું નથી. જો તમે ઓનલાઇન AI ચાલુ કરો અને મંજૂરી આપો, તો ફક્ત તમારા પ્રશ્ન માટેના સારાંશ આંકડા (જેમ કે \'આ મહિનાનો શ્રેણી મુજબ ખર્ચ\') જવાબ લખવા માટે મોકલાય છે. AI ક્યારેય તમારી નોંધો ઉમેરી, બદલી કે કાઢી શકતું નથી.';

  @override
  String get settingsGujaratiInput => 'ગુજરાતી ટાઇપિંગ';

  @override
  String get inputModeSystem => 'ફોનનું કીબોર્ડ';

  @override
  String get inputModeTransliteration => 'English → ગુજરાતી (\'kem chho\' લખો)';

  @override
  String get inputModeKeypad => 'ગુજરાતી કીપેડ';

  @override
  String get settingsAccount => 'એકાઉન્ટ';

  @override
  String get settingsProfile => 'પ્રોફાઇલ';

  @override
  String get settingsLogout => 'લૉગ આઉટ';

  @override
  String get settingsLogoutConfirm =>
      'લૉગ આઉટ કરવું છે? તમારો હિસાબ તમારા એકાઉન્ટમાં સચવાયેલો રહેશે અને આ ફોનમાંથી દૂર થશે. શ્રેણીઓ અને સેટિંગ્સ ફોનમાં જ રહેશે.';

  @override
  String get settingsDeleteAccount => 'ક્લાઉડ એકાઉન્ટ કાઢી નાખો';

  @override
  String get settingsDeleteAccountDesc =>
      'તમારું એકાઉન્ટ, તેમાં સચવાયેલો હિસાબ અને બિલ, તથા ગ્રુપ સભ્યપદ કાઢી નાખે છે.';

  @override
  String get settingsAbout => 'વિશે';

  @override
  String get settingsCategories => 'શ્રેણીઓ';

  @override
  String get settingsReminders => 'રિમાઇન્ડર';

  @override
  String get settingsCalculator => 'કેલ્ક્યુલેટર';

  @override
  String get settingsReports => 'રિપોર્ટ';

  @override
  String get settingsPrivacyPolicy => 'ગોપનીયતા નીતિ';

  @override
  String get settingsTerms => 'નિયમો અને શરતો';

  @override
  String get signOutUnsentTitle => 'હજી સચવાયું નથી';

  @override
  String signOutUnsentBody(String count) {
    return '$count ફેરફાર હજી તમારા એકાઉન્ટમાં સચવાયા નથી. અત્યારે લૉગ આઉટ કરશો તો તે જતા રહેશે.';
  }

  @override
  String get signOutWaitSync => 'રાહ જુઓ અને સિંક કરો';

  @override
  String get signOutAnyway => 'છતાં લૉગ આઉટ કરો';

  @override
  String get tourPromptTitle => 'એપની ઝડપી સફર કરવી છે?';

  @override
  String get tourPromptBody =>
      'નમૂનાની માહિતી સાથે હિસાબમિત્ર જુઓ: બે મહિનાની આવક-ખર્ચ, આપેલા અને લીધેલા પૈસા, અને મિત્રો સાથે વહેંચેલો ગોવા પ્રવાસ. અંતે નમૂનાની માહિતી કાઢી શકો છો.';

  @override
  String get tourStart => 'સફર શરૂ કરો';

  @override
  String get tourNotNow => 'હમણાં નહીં';

  @override
  String get tourLoading => 'નમૂનાની માહિતી ઉમેરી રહ્યા છીએ…';

  @override
  String tourStepOf(int current, int total) {
    return '$total માંથી $current';
  }

  @override
  String get tourNext => 'આગળ';

  @override
  String get tourBack => 'પાછળ';

  @override
  String get tourSkip => 'સફર છોડો';

  @override
  String get tour1Title => 'તમારો મહિનો એક નજરે';

  @override
  String get tour1Body =>
      'બચત = સમયગાળાની આવક − ખર્ચ. ઉપરનાં બટનથી આ મહિનો, ગયો મહિનો અને આ વર્ષ બદલો.';

  @override
  String get tour2Title => 'લેવાના અને આપવાના પૈસા';

  @override
  String get tour2Body =>
      'તમારા ખાતાનો સરવાળો: તમે આપેલા અને લીધેલા પૈસા. ઉધાર આવક-ખર્ચથી અલગ રહે છે.';

  @override
  String get tour3Title => 'ઝડપી કામ';

  @override
  String get tour3Body =>
      'આવક કે ખર્ચ ઉમેરો, પૈસા આપો કે લો, ગ્રુપ બનાવો, ગ્રુપ ખર્ચ વહેંચો કે રિપોર્ટ જુઓ — એક જ ટૅપમાં.';

  @override
  String get tour4Title => 'તમારો હિસાબ, પત્રક રૂપે પણ';

  @override
  String get tour4Body =>
      'દરેક એન્ટ્રી દિવસ પ્રમાણે. આ ટેબલ આઇકન પર ટૅપ કરો અને આવક, ખર્ચ અને ચાલુ સિલક સાથે Excel જેવું પત્રક જુઓ.';

  @override
  String get tour5Title => 'ખાતું: વ્યક્તિઓ અને ઉધાર';

  @override
  String get tour5Body =>
      'કોણ તમને આપવાના છે અને તમારે કોને આપવાના છે તે જુઓ. વ્યક્તિ ખોલો અને આખું ખાતું, આંશિક ચૂકવણી અને તારીખો જુઓ.';

  @override
  String get tour6Title => 'ગ્રુપ: વહેંચો અને હિસાબ પતાવો';

  @override
  String get tour6Body =>
      'પ્રવાસ અને પરિવારના ખર્ચ સરખા, રકમ, ટકા કે ભાગ પ્રમાણે વહેંચો. બાકી અને હિસાબ પતાવટ જોવા નમૂનાનો ગોવા પ્રવાસ ખોલો.';

  @override
  String get tour7Title => 'વધુ સાધનો';

  @override
  String get tour7Body =>
      'PDF અને CSV સાથે રિપોર્ટ, કેલ્ક્યુલેટર, રિમાઇન્ડર, બેકઅપ, AI સહાયક, અને રંગ થીમ, ભાષા તથા ગુજરાતી કીબોર્ડનાં સેટિંગ્સ.';

  @override
  String get tourFinishTitle => 'તૈયાર!';

  @override
  String get tourFinishBody =>
      'થોડું વધુ જોવા નમૂનાની માહિતી રાખો, અથવા તેને કાઢીને તમારો પોતાનો હિસાબ શરૂ કરો. સફર ક્યારેય પણ ‘વધુ’માંથી ફરી જોઈ શકો છો.';

  @override
  String get tourRemoveSample => 'નમૂનાની માહિતી કાઢો';

  @override
  String get tourKeepSample => 'હમણાં રાખો';

  @override
  String get sampleBanner => 'તમે નમૂનાની માહિતી જોઈ રહ્યા છો.';

  @override
  String get sampleRemove => 'કાઢો';

  @override
  String get sampleRemoveTitle => 'નમૂનાની માહિતી કાઢવી છે?';

  @override
  String get sampleRemoveBody =>
      'નમૂનાની એન્ટ્રી, વ્યક્તિઓ અને નમૂનાનું ગ્રુપ નીકળી જશે. તમે જાતે ઉમેરેલું બધું રહેશે — તમે વાપરેલી નમૂનાની વ્યક્તિ કે ગ્રુપ રાખવામાં આવશે.';

  @override
  String get sampleRemoved => 'નમૂનાની માહિતી કાઢી';

  @override
  String get moreAppTour => 'એપની સફર';

  @override
  String get moreAppTourDesc =>
      'નમૂનાની માહિતી સાથે એક મિનિટની માર્ગદર્શિત સફર';
}

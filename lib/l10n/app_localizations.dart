import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// Placeholder text shown when no group is selected in desktop mode.
  ///
  /// In en, this message translates to:
  /// **'Select a group to view notes'**
  String get selectGroupToViewNotes;

  /// Text used in share dialog when sharing the access key.
  ///
  /// In en, this message translates to:
  /// **'Here is your access key.'**
  String get accessKeyShareText;

  /// Generic error message shown when an operation fails.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get pleaseTryAgain;

  /// Toast message shown when text is copied to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// Title for the access key page.
  ///
  /// In en, this message translates to:
  /// **'Access Key'**
  String get accessKeyTitle;

  /// Instructional text for saving the access key.
  ///
  /// In en, this message translates to:
  /// **'Please save this key in a secure place. You\'ll need it to sync notes on another device.'**
  String get accessKeyDescription;

  /// Label for the copy button.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyLabel;

  /// Label for the button that downloads the access key as a text file.
  ///
  /// In en, this message translates to:
  /// **'Download as Text File'**
  String get downloadAsTextFileLabel;

  /// Label for the continue button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// Reason shown in the biometric/device authentication prompt.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate'**
  String get pleaseAuthenticate;

  /// Error message title when backup creation fails.
  ///
  /// In en, this message translates to:
  /// **'Could not create'**
  String get couldNotCreate;

  /// Error message title when sharing backup fails.
  ///
  /// In en, this message translates to:
  /// **'Could not share file'**
  String get couldNotShareFile;

  /// Text used in share dialog when sharing the backup file.
  ///
  /// In en, this message translates to:
  /// **'Here is the backup file for your app.'**
  String get hereIsTheBackupFile;

  /// Generic error message title.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// Label for the backup option.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupLabel;

  /// Label for the restore option.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreLabel;

  /// Label for the feedback/review option.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get leaveAReviewLabel;

  /// Label for the share app option.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareLabel;

  /// Label for the link to the desktop version.
  ///
  /// In en, this message translates to:
  /// **'Desktop App'**
  String get desktopAppLinkLabel;

  /// Label for the logging toggle setting.
  ///
  /// In en, this message translates to:
  /// **'Logging'**
  String get loggingLabel;

  /// Label showing app version.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String versionLabel(String version);

  /// Label for the loading state of the app version.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingLabel;

  /// Toast message shown after successfully restoring items.
  ///
  /// In en, this message translates to:
  /// **'Restored.'**
  String get restoredLabel;

  /// Toast message shown after successfully deleting items permanently.
  ///
  /// In en, this message translates to:
  /// **'Deleted permanently.'**
  String get deletedPermanentlyLabel;

  /// Title for the media viewer page.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get mediaTitle;

  /// Error message when invalid mnemonic phrase is entered.
  ///
  /// In en, this message translates to:
  /// **'Invalid word list'**
  String get invalidWordList;

  /// Label for the recovery phrase text input.
  ///
  /// In en, this message translates to:
  /// **'Enter your 24-word phrase'**
  String get enterYour24WordPhrase;

  /// Hint text for the recovery phrase text input.
  ///
  /// In en, this message translates to:
  /// **'Enter your recovery phrase here'**
  String get enterYourRecoveryPhraseHere;

  /// Error message when recovery phrase is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your recovery phrase'**
  String get pleaseEnterYourRecoveryPhrase;

  /// Error message when recovery phrase does not have 24 words.
  ///
  /// In en, this message translates to:
  /// **'Recovery phrase must contain exactly 24 words'**
  String get recoveryPhraseMustContain24Words;

  /// Label for the submit button.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitLabel;

  /// Separator text between input and file upload.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get orLabel;

  /// Label for the file selection button.
  ///
  /// In en, this message translates to:
  /// **'Select .txt File'**
  String get selectTxtFileLabel;

  /// Title for error dialog.
  ///
  /// In en, this message translates to:
  /// **'Failure'**
  String get failureTitle;

  /// Error message when password key is invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid password key'**
  String get invalidPasswordKey;

  /// Title for the password key input page.
  ///
  /// In en, this message translates to:
  /// **'Enable Sync'**
  String get enableSyncTitle;

  /// Description of password requirements.
  ///
  /// In en, this message translates to:
  /// **'Please enter the key (password) you had created. Its a min 10 characters long with minimum 1 numeric, 1 lowercase, 1 uppercase and 1 special character.'**
  String get passwordRequirementsDescription;

  /// Label for password input.
  ///
  /// In en, this message translates to:
  /// **'Enter key'**
  String get enterKeyLabel;

  /// Error message when password input is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter key'**
  String get pleaseEnterKey;

  /// Title for the filter notes dialog.
  ///
  /// In en, this message translates to:
  /// **'Filter notes'**
  String get filterNotesTitle;

  /// Tooltip for filter pinned notes button.
  ///
  /// In en, this message translates to:
  /// **'Filter pinned notes'**
  String get filterPinnedNotesTooltip;

  /// Tooltip for filter starred notes button.
  ///
  /// In en, this message translates to:
  /// **'Filter starred notes'**
  String get filterStarredNotesTooltip;

  /// Tooltip for filter text notes button.
  ///
  /// In en, this message translates to:
  /// **'Filter text notes'**
  String get filterTextNotesTooltip;

  /// Tooltip for filter tasks button.
  ///
  /// In en, this message translates to:
  /// **'Filter tasks'**
  String get filterTasksTooltip;

  /// Tooltip for filter links button.
  ///
  /// In en, this message translates to:
  /// **'Filter links'**
  String get filterLinksTooltip;

  /// Tooltip for filter images button.
  ///
  /// In en, this message translates to:
  /// **'Filter images'**
  String get filterImagesTooltip;

  /// Tooltip for filter audio button.
  ///
  /// In en, this message translates to:
  /// **'Filter audio'**
  String get filterAudioTooltip;

  /// Tooltip for filter video button.
  ///
  /// In en, this message translates to:
  /// **'Filter video'**
  String get filterVideoTooltip;

  /// Tooltip for filter files button.
  ///
  /// In en, this message translates to:
  /// **'Filter files'**
  String get filterFilesTooltip;

  /// Tooltip for filter contacts button.
  ///
  /// In en, this message translates to:
  /// **'Filter contacts'**
  String get filterContactsTooltip;

  /// Tooltip for filter location button.
  ///
  /// In en, this message translates to:
  /// **'Filter location'**
  String get filterLocationTooltip;

  /// Toast message when items are moved to trash.
  ///
  /// In en, this message translates to:
  /// **'Moved to trash'**
  String get movedToTrash;

  /// Toast message when selected notes are copied to clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedNotesToClipboard;

  /// Label used when sharing location.
  ///
  /// In en, this message translates to:
  /// **'Location:'**
  String get locationShareLabel;

  /// Label used when sharing contact.
  ///
  /// In en, this message translates to:
  /// **'Contact:'**
  String get contactShareLabel;

  /// Label used when sharing contact emails.
  ///
  /// In en, this message translates to:
  /// **'Emails:'**
  String get emailsShareLabel;

  /// Label used when sharing contact addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses:'**
  String get addressesShareLabel;

  /// Toast message when microphone is not available.
  ///
  /// In en, this message translates to:
  /// **'Microphone may not be available.'**
  String get microphoneNotAvailable;

  /// Toast message when microphone permission is required.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to record audio.'**
  String get microphonePermissionRequired;

  /// Error message when audio duration could not be retrieved.
  ///
  /// In en, this message translates to:
  /// **'Could not get duration'**
  String get couldNotGetDuration;

  /// Error message when file picker fails.
  ///
  /// In en, this message translates to:
  /// **'Error opening files'**
  String get errorOpeningFiles;

  /// Title for please wait dialog.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWaitTitle;

  /// Message shown when file is not available yet.
  ///
  /// In en, this message translates to:
  /// **'File not available yet'**
  String get fileNotAvailableYet;

  /// Tooltip for clear selection button.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get clearSelectionTooltip;

  /// Tooltip for copy notes button.
  ///
  /// In en, this message translates to:
  /// **'Copy notes'**
  String get copyNotesTooltip;

  /// Tooltip for change task type button.
  ///
  /// In en, this message translates to:
  /// **'Change task type'**
  String get changeTaskTypeTooltip;

  /// Tooltip for share notes button.
  ///
  /// In en, this message translates to:
  /// **'Share notes'**
  String get shareNotesTooltip;

  /// Tooltip for edit note button.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNoteTooltip;

  /// Tooltip for star/unstar notes button.
  ///
  /// In en, this message translates to:
  /// **'Star/unstar notes'**
  String get starUnstarNotesTooltip;

  /// Tooltip for move to trash button.
  ///
  /// In en, this message translates to:
  /// **'Move to trash'**
  String get moveToTrashTooltip;

  /// Tooltip for pin/unpin notes button.
  ///
  /// In en, this message translates to:
  /// **'Pin/unpin notes'**
  String get pinUnpinNotesTooltip;

  /// Tooltip for cancel reply button.
  ///
  /// In en, this message translates to:
  /// **'Cancel reply item'**
  String get cancelReplyTooltip;

  /// Hint text for creating a task.
  ///
  /// In en, this message translates to:
  /// **'Create a task'**
  String get createTaskHint;

  /// Hint text for adding a note.
  ///
  /// In en, this message translates to:
  /// **'Add a note...'**
  String get addNoteHint;

  /// Tooltip for attach button.
  ///
  /// In en, this message translates to:
  /// **'Attach'**
  String get attachTooltip;

  /// Tooltip for add note button.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNoteTooltip;

  /// Tooltip for record/stop audio button.
  ///
  /// In en, this message translates to:
  /// **'Record/stop audio'**
  String get recordStopAudioTooltip;

  /// Label for contact attachment option.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactAttachmentLabel;

  /// Label for location attachment option.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationAttachmentLabel;

  /// Label for camera attachment option.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraAttachmentLabel;

  /// Label for files attachment option.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get filesAttachmentLabel;

  /// Label for checklist attachment option.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklistAttachmentLabel;

  /// Title for the access key input page.
  ///
  /// In en, this message translates to:
  /// **'Enable Sync'**
  String get accessKeyInputTitle;

  /// Description text on the access key input page.
  ///
  /// In en, this message translates to:
  /// **'Please enter your 24-word recovery phrase or load a .txt file containing it.'**
  String get accessKeyInputDescription;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

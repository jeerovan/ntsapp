import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

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
    Locale('ar'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('fa'),
    Locale('fr'),
    Locale('he'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh')
  ];

  /// Title for the important notice page.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get importantTitle;

  /// First paragraph of the access key notice.
  ///
  /// In en, this message translates to:
  /// **'On the next page you\'ll see a series of 24 words. This is your unique and private encryption key and it is the ONLY way to recover your notes in case of logout, device loss or malfunction.'**
  String get accessKeyNoticeDescription1;

  /// Second paragraph of the access key notice.
  ///
  /// In en, this message translates to:
  /// **'We do not store the key. It is YOUR responsibility to store it in a safe place outside of {appName} app.'**
  String accessKeyNoticeDescription2(String appName);

  /// Button text to understand and show the key.
  ///
  /// In en, this message translates to:
  /// **'I understand.\nShow me the key.'**
  String get iUnderstandShowMeTheKey;

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

  /// Label for the edit menu item in the app bar popup menu.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editMenuItemLabel;

  /// Label for the filter menu item in the app bar popup menu.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filterMenuItemLabel;

  /// Error message shown when external storage permission is denied.
  ///
  /// In en, this message translates to:
  /// **'Permission to access external storage was denied.'**
  String get externalStoragePermissionDenied;

  /// Hint message shown when the send button is pressed while not typing and not recording.
  ///
  /// In en, this message translates to:
  /// **'Press long to start recording.'**
  String get pressLongToStartRecording;

  /// Title for the tip dialog shown to first-time users.
  ///
  /// In en, this message translates to:
  /// **'Did you know?'**
  String get didYouKnowTitle;

  /// Tooltip for the close button on dialogs.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeTooltip;

  /// Description text about the app in the tip dialog.
  ///
  /// In en, this message translates to:
  /// **'{appName} is a completely private notes app. It doesn\'t collect your personal data or show you ads.\n\nWe hope you enjoy using it. Tell us what you think.'**
  String appDescriptionContent(String appName);

  /// Tooltip for the search notes button.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get searchNotesTooltip;

  /// Label for the sync menu item.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncMenuItemLabel;

  /// Label for the trash menu item.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trashMenuItemLabel;

  /// Label for the starred notes menu item.
  ///
  /// In en, this message translates to:
  /// **'Starred notes'**
  String get starredNotesMenuItemLabel;

  /// Label for the settings menu item.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsMenuItemLabel;

  /// Label for the account menu item.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountMenuItemLabel;

  /// Label for the page menu item (shown in debug mode).
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get pageMenuItemLabel;

  /// Label for the SQLite database viewer menu item.
  ///
  /// In en, this message translates to:
  /// **'Sqlite'**
  String get sqliteMenuItemLabel;

  /// Label for the logs menu item.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logsMenuItemLabel;

  /// Label for the reorder group menu item.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorderMenuItemLabel;

  /// Label for the edit group menu item.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editGroupMenuItemLabel;

  /// Label for the delete group menu item.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteGroupMenuItemLabel;

  /// Tooltip message for drag handle on desktop.
  ///
  /// In en, this message translates to:
  /// **'Drag handle to re-order'**
  String get dragHandleReorderTooltip;

  /// Tooltip message for hold and drag to re-order on mobile.
  ///
  /// In en, this message translates to:
  /// **'Hold and drag to re-order'**
  String get holdAndDragReorderTooltip;

  /// Empty state message shown when there are no groups on the home page.
  ///
  /// In en, this message translates to:
  /// **'Hi there!\n\nIt\'s kind of looking empty in here.\n\nTap the + button and create some notes to self. :)'**
  String get emptyHomePageMessage;

  /// Title shown when reordering groups on the home page.
  ///
  /// In en, this message translates to:
  /// **'Reordering'**
  String get reorderingTitle;

  /// Placeholder label shown when shared contents are being loaded.
  ///
  /// In en, this message translates to:
  /// **'Select...'**
  String get selectEllipsisLabel;

  /// Label for the date/time toggle switch in group settings.
  ///
  /// In en, this message translates to:
  /// **'Date/Time'**
  String get dateTimeToggleLabel;

  /// Label for the note border toggle switch in group settings.
  ///
  /// In en, this message translates to:
  /// **'Note border'**
  String get noteBorderToggleLabel;

  /// Label for the delete group button in group edit page.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteGroupButtonLabel;

  /// Label for the notes tab in the trash page.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTabLabel;

  /// Label for the groups tab in the trash page.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupsTabLabel;

  /// Label for the categories tab in the trash page.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTabLabel;

  /// Label for location items in search results.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationItemLabel;

  /// Page title for creating a new group.
  ///
  /// In en, this message translates to:
  /// **'Add group'**
  String get addGroupTitle;

  /// Page title for editing an existing group.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get editGroupTitle;

  /// Label for the title input field.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleInputLabel;

  /// Title for the location permission dialog.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get locationPermissionRequiredTitle;

  /// Content text for the location permission dialog.
  ///
  /// In en, this message translates to:
  /// **'Please enable location permissions in the app settings.'**
  String get enableLocationPermissionsContent;

  /// Label for the cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonLabel;

  /// Label for the open settings button.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettingsButtonLabel;

  /// Title for the location services alert.
  ///
  /// In en, this message translates to:
  /// **'Location Services'**
  String get locationServicesTitle;

  /// Content text for the location services disabled alert.
  ///
  /// In en, this message translates to:
  /// **'Please enable!'**
  String get pleaseEnableLocationServicesContent;

  /// Title for the location picker page.
  ///
  /// In en, this message translates to:
  /// **'Select location'**
  String get selectLocationTitle;

  /// Tooltip for the use current location button.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocationTooltip;

  /// Label for the select all button in archived items.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAllButtonLabel;

  /// Hint text for the search logs input field.
  ///
  /// In en, this message translates to:
  /// **'Search logs..'**
  String get searchLogsHint;

  /// Message shown when there are no log entries to display.
  ///
  /// In en, this message translates to:
  /// **'No logs available'**
  String get noLogsAvailable;

  /// Title for the SQLite database viewer page.
  ///
  /// In en, this message translates to:
  /// **'DB Viewer'**
  String get dbViewerTitle;

  /// Instruction text shown when no table is selected in the DB viewer.
  ///
  /// In en, this message translates to:
  /// **'Select a table to view its data'**
  String get selectTableToViewData;

  /// Hint text for the table selection dropdown in the DB viewer.
  ///
  /// In en, this message translates to:
  /// **'Select a table'**
  String get selectTableDropdownHint;

  /// Title for the contact picker page.
  ///
  /// In en, this message translates to:
  /// **'Pick a contact'**
  String get pickContactTitle;

  /// Text shown when contact permission is required.
  ///
  /// In en, this message translates to:
  /// **'Permission required'**
  String get permissionRequiredText;

  /// Label for the grant permission button.
  ///
  /// In en, this message translates to:
  /// **'Grant permission'**
  String get grantPermissionButtonLabel;

  /// Title for the dummy/testing page.
  ///
  /// In en, this message translates to:
  /// **'Page Dummy'**
  String get pageDummyTitle;

  /// Label for the simulate button on the dummy page.
  ///
  /// In en, this message translates to:
  /// **'Simulate'**
  String get simulateButtonLabel;

  /// Title for the select category page.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategoryTitle;

  /// Title for the add category page.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategoryTitle;

  /// Title for the edit category page.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategoryTitle;

  /// Hint text for the category title input field.
  ///
  /// In en, this message translates to:
  /// **'Category title'**
  String get categoryTitleHint;

  /// Label for the color selector.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// Label for the change color option.
  ///
  /// In en, this message translates to:
  /// **'Change color'**
  String get changeColorLabel;

  /// Toast message shown when a device is disabled.
  ///
  /// In en, this message translates to:
  /// **'Device disabled!'**
  String get deviceDisabledMessage;

  /// Toast message shown when attempting to remove the current device.
  ///
  /// In en, this message translates to:
  /// **'Can\'t remove this device!'**
  String get cannotRemoveThisDeviceMessage;

  /// Title for the confirm remove device dialog.
  ///
  /// In en, this message translates to:
  /// **'Confirm Remove'**
  String get confirmRemoveTitle;

  /// Content text for the confirm remove device dialog.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? This will delete all the data on the device.'**
  String get confirmRemoveDeviceContent;

  /// Label for the OK button.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButtonLabel;

  /// Title for the registered devices page.
  ///
  /// In en, this message translates to:
  /// **'Registered Devices'**
  String get registeredDevicesTitle;

  /// Message shown when no devices are found.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get noDevicesFoundMessage;

  /// Label for an enabled device status.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabledLabel;

  /// Label for a disabled device status.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabledLabel;

  /// Title for the media migration page.
  ///
  /// In en, this message translates to:
  /// **'Migrating Media'**
  String get migratingMediaTitle;

  /// Message shown while media is being processed.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processingMessage;

  /// Warning message asking the user not to navigate away during media migration.
  ///
  /// In en, this message translates to:
  /// **'Please do not navigate away'**
  String get doNotNavigateAwayMessage;

  /// Error message shown when loading logs fails, including the error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetails(String error);

  /// Validation error when the key contains a sequential pattern.
  ///
  /// In en, this message translates to:
  /// **'Sequence not accepted'**
  String get sequenceNotAcceptedError;

  /// Validation error when the key matches one of the example keys.
  ///
  /// In en, this message translates to:
  /// **'Examples not accepted'**
  String get examplesNotAcceptedError;

  /// Label and hint for the confirm key input field.
  ///
  /// In en, this message translates to:
  /// **'Enter key again'**
  String get enterKeyAgainLabel;

  /// Validation error when the confirm key field is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter key again'**
  String get pleaseEnterKeyAgainError;

  /// Validation error when the two keys do not match.
  ///
  /// In en, this message translates to:
  /// **'Keys do not match'**
  String get keysDoNotMatchError;

  /// Password rule description for one uppercase letter.
  ///
  /// In en, this message translates to:
  /// **'1 uppercase letter'**
  String get ruleUppercaseLetter;

  /// Password rule description for one lowercase letter.
  ///
  /// In en, this message translates to:
  /// **'1 lowercase letter'**
  String get ruleLowercaseLetter;

  /// Password rule description for one numeric character.
  ///
  /// In en, this message translates to:
  /// **'1 numeric letter'**
  String get ruleNumericLetter;

  /// Password rule description for one special character.
  ///
  /// In en, this message translates to:
  /// **'1 special character'**
  String get ruleSpecialCharacter;

  /// Password rule description for the minimum length.
  ///
  /// In en, this message translates to:
  /// **'min 10 characters'**
  String get ruleMinTenCharacters;

  /// Title for the key examples dialog.
  ///
  /// In en, this message translates to:
  /// **'Examples'**
  String get examplesTitle;

  /// Example key shown in the examples dialog. Do not translate.
  ///
  /// In en, this message translates to:
  /// **'I would love 2 have @ll ...'**
  String get passwordExample1;

  /// Example key shown in the examples dialog. Do not translate.
  ///
  /// In en, this message translates to:
  /// **'(A6r4K4D46r4)'**
  String get passwordExample2;

  /// Example key shown in the examples dialog. Do not translate.
  ///
  /// In en, this message translates to:
  /// **'Mykey@2025'**
  String get passwordExample3;

  /// Example key shown in the examples dialog. Do not translate.
  ///
  /// In en, this message translates to:
  /// **'C0ffee !s great f0r pr0ductivity'**
  String get passwordExample4;

  /// Label for the button to dismiss the examples dialog.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotItButtonLabel;

  /// Title for the encryption key creation page.
  ///
  /// In en, this message translates to:
  /// **'Encryption key'**
  String get encryptionKeyTitle;

  /// Instructional text for creating an encryption key.
  ///
  /// In en, this message translates to:
  /// **'Please enter a long and hard to guess key (password). Remember to save it somewhere safe. If it lost/forgotten, it can not be recovered.'**
  String get createKeyDescription;

  /// Tooltip for the button that shows key examples.
  ///
  /// In en, this message translates to:
  /// **'See examples'**
  String get seeExamplesTooltip;

  /// Message shown when plan details could not be fetched.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch details'**
  String get couldNotFetchDetailsMessage;

  /// Label for the retry button.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButtonLabel;

  /// Label shown before the signed-in email.
  ///
  /// In en, this message translates to:
  /// **'Signed in as:'**
  String get signedInAsLabel;

  /// Label for the storage usage section.
  ///
  /// In en, this message translates to:
  /// **'Storage Usage'**
  String get storageUsageLabel;

  /// Label for the subscribe option.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribeLabel;

  /// Label for the plan expired renew option.
  ///
  /// In en, this message translates to:
  /// **'Plan expired! Renew'**
  String get planExpiredRenewLabel;

  /// Label for the manage devices option.
  ///
  /// In en, this message translates to:
  /// **'Manage devices'**
  String get manageDevicesLabel;

  /// Label for the view access key option.
  ///
  /// In en, this message translates to:
  /// **'View access key'**
  String get viewAccessKeyLabel;

  /// Label for the change key password option.
  ///
  /// In en, this message translates to:
  /// **'Change key password'**
  String get changeKeyPasswordLabel;

  /// Label for the manage subscription option.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get manageSubscriptionLabel;

  /// Label for the sign out option.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutButtonLabel;

  /// Title for the plan subscribe page.
  ///
  /// In en, this message translates to:
  /// **'Yearly plans'**
  String get yearlyPlansTitle;

  /// Label for the login button.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLabel;

  /// Headline on the subscribe page.
  ///
  /// In en, this message translates to:
  /// **'Sync all your notes'**
  String get syncAllYourNotesLabel;

  /// Subheadline on the subscribe page.
  ///
  /// In en, this message translates to:
  /// **'across your devices'**
  String get acrossYourDevicesLabel;

  /// Feature list item for end-to-end encryption.
  ///
  /// In en, this message translates to:
  /// **'End-to-end encryption'**
  String get featureEndToEndEncryption;

  /// Feature list item for syncing up to 3 devices.
  ///
  /// In en, this message translates to:
  /// **'Sync up to 3 devices'**
  String get featureSyncUpTo3Devices;

  /// Feature list item for upgrading or cancelling anytime.
  ///
  /// In en, this message translates to:
  /// **'Upgrade/Cancel anytime'**
  String get featureUpgradeCancelAnytime;

  /// Message shown when no plans are available.
  ///
  /// In en, this message translates to:
  /// **'No plans available'**
  String get noPlansAvailableMessage;

  /// Label prompting the user to download the app and subscribe.
  ///
  /// In en, this message translates to:
  /// **'Download the app & subscribe'**
  String get downloadAppSubscribeLabel;

  /// Label for the privacy and terms footer.
  ///
  /// In en, this message translates to:
  /// **'Privacy • Terms'**
  String get privacyTermsLabel;

  /// Badge text showing the savings percentage.
  ///
  /// In en, this message translates to:
  /// **'Save 50%'**
  String get saveFiftyPercentLabel;

  /// Title for the select key type page before welcoming.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get helloTitle;

  /// Description text on the select key type page.
  ///
  /// In en, this message translates to:
  /// **'To encrypt your data, we’ll need a master encryption key.'**
  String get selectKeyMasterKeyDescription;

  /// Description of the two key creation options.
  ///
  /// In en, this message translates to:
  /// **'There are 2 options - either you create a key yourself (similar to password) or we create it for you.'**
  String get selectKeyTwoOptionsDescription;

  /// Acknowledgement text for understanding the risk of losing the encryption key.
  ///
  /// In en, this message translates to:
  /// **'I understand that if I lose/forget encryption key, I may lose the data.'**
  String get understandLoseKeyAcknowledgement;

  /// Label for the button to let the app create the key.
  ///
  /// In en, this message translates to:
  /// **'Create the key for me'**
  String get createKeyForMeButtonLabel;

  /// Label indicating a recommended option.
  ///
  /// In en, this message translates to:
  /// **'(Recommended)'**
  String get recommendedLabel;

  /// Toast message asking the user to acknowledge the terms.
  ///
  /// In en, this message translates to:
  /// **'Please acknowledge!'**
  String get pleaseAcknowledgeMessage;

  /// Label for the button to create the key yourself.
  ///
  /// In en, this message translates to:
  /// **'I’ll create the key myself'**
  String get createKeyMyselfButtonLabel;

  /// Welcome message with the app name.
  ///
  /// In en, this message translates to:
  /// **'Welcome to {appName}'**
  String welcomeToAppName(String appName);

  /// Description of the end-to-end encryption used.
  ///
  /// In en, this message translates to:
  /// **'We use end-to-end encryption to make sure that all of your notes are safe and no one else can see them, not even us.'**
  String get e2eEncryptionDescription;

  /// Message prompting the user to start encryption.
  ///
  /// In en, this message translates to:
  /// **'Time to start the encryption!'**
  String get timeToStartEncryptionLabel;

  /// Label for the next button.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButtonLabel;

  /// Toast message when sending the OTP fails.
  ///
  /// In en, this message translates to:
  /// **'Sending OTP failed. Please try again!'**
  String get sendingOtpFailedMessage;

  /// Toast message when verifying the OTP fails.
  ///
  /// In en, this message translates to:
  /// **'OTP verification failed. Please try again!'**
  String get otpVerificationFailedMessage;

  /// Title for the sign-in page before OTP is sent.
  ///
  /// In en, this message translates to:
  /// **'Email SignIn'**
  String get emailSignInTitle;

  /// Label for verifying the OTP (used as title and button).
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtpLabel;

  /// Label for the email input field.
  ///
  /// In en, this message translates to:
  /// **'Enter Email'**
  String get enterEmailLabel;

  /// Label for the send OTP button.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtpLabel;

  /// Message confirming the OTP was sent to the email.
  ///
  /// In en, this message translates to:
  /// **'We have sent a one-time password (OTP) to your email {email}'**
  String otpSentToEmailMessage(String email);

  /// Label for the OTP input field.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtpLabel;

  /// Label for the change email button.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmailLabel;

  /// Title shown while encrypting local notes.
  ///
  /// In en, this message translates to:
  /// **'Encrypting notes'**
  String get encryptingNotesTitle;

  /// Title shown while fetching details.
  ///
  /// In en, this message translates to:
  /// **'Fetching details'**
  String get fetchingDetailsTitle;

  /// Error message shown when fetching fails.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch'**
  String get couldNotFetchMessage;

  /// Error message when the subscription email does not match.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is associated with another email. Please sign-out and use that to enable cloud storage.'**
  String get subscriptionEmailMismatchMessage;

  /// Error message shown when checking plan details fails.
  ///
  /// In en, this message translates to:
  /// **'Error checking plan details'**
  String get errorCheckingPlanDetailsMessage;

  /// Title shown while registering the device.
  ///
  /// In en, this message translates to:
  /// **'Register device'**
  String get registerDeviceTitle;

  /// Label for the manage button (e.g., manage devices).
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manageButtonLabel;

  /// Title shown while fetching encryption keys.
  ///
  /// In en, this message translates to:
  /// **'Fetching Keys'**
  String get fetchingKeysTitle;

  /// Title shown while signing out.
  ///
  /// In en, this message translates to:
  /// **'Signing out'**
  String get signingOutTitle;

  /// Error message asking the user to check internet connection.
  ///
  /// In en, this message translates to:
  /// **'Please check internet'**
  String get pleaseCheckInternetMessage;

  /// Generic error message when something goes wrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrongMessage;

  /// Tooltip for the play/pause audio button.
  ///
  /// In en, this message translates to:
  /// **'Play/pause'**
  String get playPauseTooltip;

  /// Formatted timer display showing minutes and seconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes}:{seconds}'**
  String timerFormattedTime(String minutes, String seconds);

  /// Tooltip for the download button.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadTooltip;

  /// Error message when the access key is invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid access key'**
  String get invalidAccessKey;

  /// Error message when the selected file does not contain a 24-word recovery phrase.
  ///
  /// In en, this message translates to:
  /// **'The file does not contain exactly 24 words.'**
  String get fileDoesNotContain24Words;

  /// Toast message when an error occurs while reading a file.
  ///
  /// In en, this message translates to:
  /// **'Error reading file'**
  String get errorReadingFile;

  /// Label for the 'All' filter option.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLabel;

  /// Log type label for debug entries.
  ///
  /// In en, this message translates to:
  /// **'DEBUG'**
  String get logTypeDebug;

  /// Log type label for error entries.
  ///
  /// In en, this message translates to:
  /// **'ERROR'**
  String get logTypeError;

  /// Log type label for info entries.
  ///
  /// In en, this message translates to:
  /// **'INFO'**
  String get logTypeInfo;

  /// Log type label for warning entries.
  ///
  /// In en, this message translates to:
  /// **'WARNING'**
  String get logTypeWarning;

  /// Hint text for the group title input field.
  ///
  /// In en, this message translates to:
  /// **'Group title'**
  String get groupTitleHint;

  /// Label for the category selector section.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// Placeholder text prompting the user to select a category.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategoryPlaceholder;

  /// Formatted storage size in bytes.
  ///
  /// In en, this message translates to:
  /// **'{bytes} B'**
  String storageBytesFormat(String bytes);

  /// Formatted storage size in kilobytes.
  ///
  /// In en, this message translates to:
  /// **'{kb} KB'**
  String storageKilobytesFormat(String kb);

  /// Formatted storage size in megabytes.
  ///
  /// In en, this message translates to:
  /// **'{mb} MB'**
  String storageMegabytesFormat(String mb);

  /// Formatted storage size in gigabytes.
  ///
  /// In en, this message translates to:
  /// **'{gb} GB'**
  String storageGigabytesFormat(String gb);

  /// Formatted used vs total storage display.
  ///
  /// In en, this message translates to:
  /// **'{used} / {total}'**
  String storageUsedTotalFormat(String used, String total);

  /// Formatted plan storage size with unit (e.g. '100 GB').
  ///
  /// In en, this message translates to:
  /// **'{size} {unit}'**
  String planStorageSizeFormat(String size, String unit);

  /// Hint text for the search input field.
  ///
  /// In en, this message translates to:
  /// **'query, #document etc..'**
  String get searchHint;

  /// Separator used between category and group in search result headers.
  ///
  /// In en, this message translates to:
  /// **' > '**
  String get categoryGroupSeparator;

  /// Label shown for audio file search results.
  ///
  /// In en, this message translates to:
  /// **'Audio file'**
  String get audioFileLabel;

  /// Native name of the Arabic language.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// Native name of the German language.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// Native name of the Greek language.
  ///
  /// In en, this message translates to:
  /// **'Ελληνικά'**
  String get languageGreek;

  /// Native name of the English language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Native name of the Spanish language.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// Native name of the Persian (Farsi) language.
  ///
  /// In en, this message translates to:
  /// **'فارسی'**
  String get languagePersian;

  /// Native name of the French language.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// Native name of the Hebrew language.
  ///
  /// In en, this message translates to:
  /// **'עברית'**
  String get languageHebrew;

  /// Native name of the Hindi language.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get languageHindi;

  /// Native name of the Indonesian language.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageIndonesian;

  /// Native name of the Italian language.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// Native name of the Japanese language.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// Native name of the Korean language.
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get languageKorean;

  /// Native name of the Dutch language.
  ///
  /// In en, this message translates to:
  /// **'Nederlands'**
  String get languageDutch;

  /// Native name of the Portuguese language.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// Native name of the Russian language.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// Native name of the Thai language.
  ///
  /// In en, this message translates to:
  /// **'ไทย'**
  String get languageThai;

  /// Native name of the Turkish language.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// Native name of the Ukrainian language.
  ///
  /// In en, this message translates to:
  /// **'Українська'**
  String get languageUkrainian;

  /// Native name of the Vietnamese language.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// Native name of the Simplified Chinese language.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageChineseSimplified;

  /// Header label for the language selection menu.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguageTitle;

  /// Title of the settings page displayed in the AppBar.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Label for the theme settings list tile.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// Tooltip for the theme toggle button.
  ///
  /// In en, this message translates to:
  /// **'Day/night theme'**
  String get dayNightThemeTooltip;

  /// Label for the app lock setting.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get lockLabel;

  /// Label for the time format dropdown setting.
  ///
  /// In en, this message translates to:
  /// **'Time Format'**
  String get timeFormatLabel;

  /// Label for the 12-hour time format option.
  ///
  /// In en, this message translates to:
  /// **'H12'**
  String get h12Label;

  /// Label for the 24-hour time format option.
  ///
  /// In en, this message translates to:
  /// **'H24'**
  String get h24Label;

  /// Label for the font size setting.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontSizeLabel;

  /// Tooltip for the decrease font size button.
  ///
  /// In en, this message translates to:
  /// **'Reduce text size'**
  String get reduceTextSizeTooltip;

  /// Tooltip for the increase font size button.
  ///
  /// In en, this message translates to:
  /// **'Increase text size'**
  String get increaseTextSizeTooltip;

  /// Label for the language setting list tile.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// Label for the auto-open group setting list tile.
  ///
  /// In en, this message translates to:
  /// **'Auto-open group'**
  String get autoOpenGroupLabel;

  /// Header label for the group selection menu.
  ///
  /// In en, this message translates to:
  /// **'Select group'**
  String get selectGroupTitle;

  /// Content of the share intent for sharing the app.
  ///
  /// In en, this message translates to:
  /// **'Make a {appName}: {appLink}'**
  String shareAppMessage(String appName, String appLink);

  /// Label for an empty note preview.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get noteTypeEmpty;

  /// Label for an image note preview.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get noteTypeImage;

  /// Label for a video note preview.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get noteTypeVideo;

  /// Label for an audio note preview.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get noteTypeAudio;

  /// Label for a document note preview.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get noteTypeDocument;

  /// Label for a contact note preview.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get noteTypeContact;

  /// Label for a location note preview.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get noteTypeLocation;

  /// Label for a note preview of an unrecognized type.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get noteTypeUnknown;

  /// Validation error message when a field is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter data'**
  String get pleaseEnterData;

  /// Validation error message when the input must be a number.
  ///
  /// In en, this message translates to:
  /// **'A number'**
  String get aNumber;

  /// Validation error message prompting the user to enter data.
  ///
  /// In en, this message translates to:
  /// **'Enter data'**
  String get enterDataLabel;

  /// Validation error message for invalid input data.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid data'**
  String get pleaseEnterValidData;

  /// Validation error message prompting the user to select an option.
  ///
  /// In en, this message translates to:
  /// **'Please select an option'**
  String get pleaseSelectAnOption;

  /// Formatted date range string.
  ///
  /// In en, this message translates to:
  /// **'{start} - {end}'**
  String dateRangeFormat(String start, String end);

  /// Human-readable label for today's date.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// Human-readable label for yesterday's date.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayLabel;

  /// Day-of-week name for Monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get mondayLabel;

  /// Day-of-week name for Tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesdayLabel;

  /// Day-of-week name for Wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesdayLabel;

  /// Day-of-week name for Thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursdayLabel;

  /// Day-of-week name for Friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get fridayLabel;

  /// Day-of-week name for Saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturdayLabel;

  /// Day-of-week name for Sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sundayLabel;

  /// Short month name for January.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get januaryShortLabel;

  /// Short month name for February.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get februaryShortLabel;

  /// Short month name for March.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get marchShortLabel;

  /// Short month name for April.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get aprilShortLabel;

  /// Short month name for May.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get mayShortLabel;

  /// Short month name for June.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get juneShortLabel;

  /// Short month name for July.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get julyShortLabel;

  /// Short month name for August.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get augustShortLabel;

  /// Short month name for September.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get septemberShortLabel;

  /// Short month name for October.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get octoberShortLabel;

  /// Short month name for November.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get novemberShortLabel;

  /// Short month name for December.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get decemberShortLabel;

  /// Formatted note group date title.
  ///
  /// In en, this message translates to:
  /// **'{month} {day}, {dayOfWeek}'**
  String noteGroupDateTitleFormat(String month, String day, String dayOfWeek);

  /// Formatted media duration with hours.
  ///
  /// In en, this message translates to:
  /// **'{hours}:{minutes}:{seconds}'**
  String mediaDurationHoursFormat(String hours, String minutes, String seconds);

  /// Formatted media duration without hours.
  ///
  /// In en, this message translates to:
  /// **'{minutes}:{seconds}'**
  String mediaDurationMinutesFormat(String minutes, String seconds);

  /// Display string when file size is zero.
  ///
  /// In en, this message translates to:
  /// **'0 B'**
  String get fileSizeZero;

  /// File size unit for bytes.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get fileSizeUnitBytes;

  /// File size unit for kilobytes.
  ///
  /// In en, this message translates to:
  /// **'KB'**
  String get fileSizeUnitKilobytes;

  /// File size unit for megabytes.
  ///
  /// In en, this message translates to:
  /// **'MB'**
  String get fileSizeUnitMegabytes;

  /// File size unit for gigabytes.
  ///
  /// In en, this message translates to:
  /// **'GB'**
  String get fileSizeUnitGigabytes;

  /// File size unit for terabytes.
  ///
  /// In en, this message translates to:
  /// **'TB'**
  String get fileSizeUnitTerabytes;

  /// Formatted file size string with suffix unit.
  ///
  /// In en, this message translates to:
  /// **'{size} {suffix}'**
  String fileSizeFormat(String size, String suffix);

  /// Pluralized label for a single note group count.
  ///
  /// In en, this message translates to:
  /// **'{count} note group'**
  String noteGroupCountSingle(int count);

  /// Pluralized label for multiple note groups count.
  ///
  /// In en, this message translates to:
  /// **'{count} note groups'**
  String noteGroupCountPlural(int count);

  /// Default category title for the Tasks category created on fresh install.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get seedCategoryTasks;

  /// Default group title for the Notes group created on fresh install.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get seedGroupNotes;

  /// Default group title for the Fitness group created on fresh install.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get seedGroupFitness;

  /// Welcome note text created on fresh install.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Note Safe!\nIdeas, lists or anything on your mind, put it all in here.\n\nLong press on this note for delete, edit and other options.'**
  String get seedItemWelcome;

  /// First default task created on fresh install.
  ///
  /// In en, this message translates to:
  /// **'Morning workout'**
  String get seedItemMorningWorkout;

  /// Second default task created on fresh install.
  ///
  /// In en, this message translates to:
  /// **'10 minutes meditation'**
  String get seedItemMeditation;

  /// Third default task created on fresh install.
  ///
  /// In en, this message translates to:
  /// **'2L of water a day'**
  String get seedItemWater;

  /// Fourth default task created on fresh install.
  ///
  /// In en, this message translates to:
  /// **'Walk 10,000 steps'**
  String get seedItemSteps;


}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'de', 'el', 'en', 'es', 'fa', 'fr', 'he', 'hi', 'id', 'it', 'ja', 'ko', 'nl', 'pt', 'ru', 'th', 'tr', 'uk', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'de': return AppLocalizationsDe();
    case 'el': return AppLocalizationsEl();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fa': return AppLocalizationsFa();
    case 'fr': return AppLocalizationsFr();
    case 'he': return AppLocalizationsHe();
    case 'hi': return AppLocalizationsHi();
    case 'id': return AppLocalizationsId();
    case 'it': return AppLocalizationsIt();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'nl': return AppLocalizationsNl();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'th': return AppLocalizationsTh();
    case 'tr': return AppLocalizationsTr();
    case 'uk': return AppLocalizationsUk();
    case 'vi': return AppLocalizationsVi();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

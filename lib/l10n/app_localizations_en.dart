// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get importantTitle => 'Important';

  @override
  String get accessKeyNoticeDescription1 => 'On the next page you\'ll see a series of 24 words. This is your unique and private encryption key and it is the ONLY way to recover your notes in case of logout, device loss or malfunction.';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return 'We do not store the key. It is YOUR responsibility to store it in a safe place outside of $appName app.';
  }

  @override
  String get iUnderstandShowMeTheKey => 'I understand.\nShow me the key.';

  @override
  String get selectGroupToViewNotes => 'Select a group to view notes';

  @override
  String get accessKeyShareText => 'Here is your access key.';

  @override
  String get pleaseTryAgain => 'Please try again.';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get accessKeyTitle => 'Access Key';

  @override
  String get accessKeyDescription => 'Please save this key in a secure place. You\'ll need it to sync notes on another device.';

  @override
  String get copyLabel => 'Copy';

  @override
  String get downloadAsTextFileLabel => 'Download as Text File';

  @override
  String get continueLabel => 'Continue';

  @override
  String get pleaseAuthenticate => 'Please authenticate';

  @override
  String get couldNotCreate => 'Could not create';

  @override
  String get couldNotShareFile => 'Could not share file';

  @override
  String get hereIsTheBackupFile => 'Here is the backup file for your app.';

  @override
  String get errorTitle => 'Error';

  @override
  String get backupLabel => 'Backup';

  @override
  String get restoreLabel => 'Restore';

  @override
  String get leaveAReviewLabel => 'Leave a review';

  @override
  String get shareLabel => 'Share';

  @override
  String get desktopAppLinkLabel => 'Desktop App';

  @override
  String get loggingLabel => 'Logging';

  @override
  String versionLabel(String version) {
    return 'Version: $version';
  }

  @override
  String get loadingLabel => 'Loading...';

  @override
  String get restoredLabel => 'Restored.';

  @override
  String get deletedPermanentlyLabel => 'Deleted permanently.';

  @override
  String get mediaTitle => 'Media';

  @override
  String get invalidWordList => 'Invalid word list';

  @override
  String get enterYour24WordPhrase => 'Enter your 24-word phrase';

  @override
  String get enterYourRecoveryPhraseHere => 'Enter your recovery phrase here';

  @override
  String get pleaseEnterYourRecoveryPhrase => 'Please enter your recovery phrase';

  @override
  String get recoveryPhraseMustContain24Words => 'Recovery phrase must contain exactly 24 words';

  @override
  String get submitLabel => 'Submit';

  @override
  String get orLabel => 'Or';

  @override
  String get selectTxtFileLabel => 'Select .txt File';

  @override
  String get failureTitle => 'Failure';

  @override
  String get invalidPasswordKey => 'Invalid password key';

  @override
  String get enableSyncTitle => 'Enable Sync';

  @override
  String get passwordRequirementsDescription => 'Please enter the key (password) you had created. Its a min 10 characters long with minimum 1 numeric, 1 lowercase, 1 uppercase and 1 special character.';

  @override
  String get enterKeyLabel => 'Enter key';

  @override
  String get pleaseEnterKey => 'Please enter key';

  @override
  String get filterNotesTitle => 'Filter notes';

  @override
  String get filterPinnedNotesTooltip => 'Filter pinned notes';

  @override
  String get filterStarredNotesTooltip => 'Filter starred notes';

  @override
  String get filterTextNotesTooltip => 'Filter text notes';

  @override
  String get filterTasksTooltip => 'Filter tasks';

  @override
  String get filterLinksTooltip => 'Filter links';

  @override
  String get filterImagesTooltip => 'Filter images';

  @override
  String get filterAudioTooltip => 'Filter audio';

  @override
  String get filterVideoTooltip => 'Filter video';

  @override
  String get filterFilesTooltip => 'Filter files';

  @override
  String get filterContactsTooltip => 'Filter contacts';

  @override
  String get filterLocationTooltip => 'Filter location';

  @override
  String get movedToTrash => 'Moved to trash';

  @override
  String get copiedNotesToClipboard => 'Copied to clipboard';

  @override
  String get locationShareLabel => 'Location:';

  @override
  String get contactShareLabel => 'Contact:';

  @override
  String get emailsShareLabel => 'Emails:';

  @override
  String get addressesShareLabel => 'Addresses:';

  @override
  String get microphoneNotAvailable => 'Microphone may not be available.';

  @override
  String get microphonePermissionRequired => 'Microphone permission is required to record audio.';

  @override
  String get couldNotGetDuration => 'Could not get duration';

  @override
  String get errorOpeningFiles => 'Error opening files';

  @override
  String get pleaseWaitTitle => 'Please wait';

  @override
  String get fileNotAvailableYet => 'File not available yet';

  @override
  String get clearSelectionTooltip => 'Clear selection';

  @override
  String get copyNotesTooltip => 'Copy notes';

  @override
  String get changeTaskTypeTooltip => 'Change task type';

  @override
  String get shareNotesTooltip => 'Share notes';

  @override
  String get editNoteTooltip => 'Edit note';

  @override
  String get starUnstarNotesTooltip => 'Star/unstar notes';

  @override
  String get moveToTrashTooltip => 'Move to trash';

  @override
  String get pinUnpinNotesTooltip => 'Pin/unpin notes';

  @override
  String get cancelReplyTooltip => 'Cancel reply item';

  @override
  String get createTaskHint => 'Create a task';

  @override
  String get addNoteHint => 'Add a note...';

  @override
  String get attachTooltip => 'Attach';

  @override
  String get addNoteTooltip => 'Add note';

  @override
  String get recordStopAudioTooltip => 'Record/stop audio';

  @override
  String get contactAttachmentLabel => 'Contact';

  @override
  String get locationAttachmentLabel => 'Location';

  @override
  String get cameraAttachmentLabel => 'Camera';

  @override
  String get filesAttachmentLabel => 'Files';

  @override
  String get checklistAttachmentLabel => 'Checklist';

  @override
  String get accessKeyInputTitle => 'Enable Sync';

  @override
  String get accessKeyInputDescription => 'Please enter your 24-word recovery phrase or load a .txt file containing it.';

  @override
  String get editMenuItemLabel => 'Edit';

  @override
  String get filterMenuItemLabel => 'Filters';

  @override
  String get externalStoragePermissionDenied => 'Permission to access external storage was denied.';

  @override
  String get pressLongToStartRecording => 'Press long to start recording.';

  @override
  String get didYouKnowTitle => 'Did you know?';

  @override
  String get closeTooltip => 'Close';

  @override
  String appDescriptionContent(String appName) {
    return '$appName is a completely private notes app. It doesn\'t collect your personal data or show you ads.\n\nWe hope you enjoy using it. Tell us what you think.';
  }

  @override
  String get searchNotesTooltip => 'Search notes';

  @override
  String get syncMenuItemLabel => 'Sync';

  @override
  String get trashMenuItemLabel => 'Trash';

  @override
  String get starredNotesMenuItemLabel => 'Starred notes';

  @override
  String get settingsMenuItemLabel => 'Settings';

  @override
  String get accountMenuItemLabel => 'Account';

  @override
  String get pageMenuItemLabel => 'Page';

  @override
  String get sqliteMenuItemLabel => 'Sqlite';

  @override
  String get logsMenuItemLabel => 'Logs';

  @override
  String get reorderMenuItemLabel => 'Reorder';

  @override
  String get editGroupMenuItemLabel => 'Edit';

  @override
  String get deleteGroupMenuItemLabel => 'Delete';

  @override
  String get dragHandleReorderTooltip => 'Drag handle to re-order';

  @override
  String get holdAndDragReorderTooltip => 'Hold and drag to re-order';

  @override
  String get emptyHomePageMessage => 'Hi there!\n\nIt\'s kind of looking empty in here.\n\nTap the + button and create some notes to self. :)';

  @override
  String get reorderingTitle => 'Reordering';

  @override
  String get selectEllipsisLabel => 'Select...';

  @override
  String get dateTimeToggleLabel => 'Date/Time';

  @override
  String get noteBorderToggleLabel => 'Note border';

  @override
  String get deleteGroupButtonLabel => 'Delete';

  @override
  String get notesTabLabel => 'Notes';

  @override
  String get groupsTabLabel => 'Groups';

  @override
  String get categoriesTabLabel => 'Categories';

  @override
  String get locationItemLabel => 'Location';

  @override
  String get addGroupTitle => 'Add group';

  @override
  String get editGroupTitle => 'Edit group';

  @override
  String get titleInputLabel => 'Title';

  @override
  String get locationPermissionRequiredTitle => 'Location Permission Required';

  @override
  String get enableLocationPermissionsContent => 'Please enable location permissions in the app settings.';

  @override
  String get cancelButtonLabel => 'Cancel';

  @override
  String get openSettingsButtonLabel => 'Open Settings';

  @override
  String get locationServicesTitle => 'Location Services';

  @override
  String get pleaseEnableLocationServicesContent => 'Please enable!';

  @override
  String get selectLocationTitle => 'Select location';

  @override
  String get useCurrentLocationTooltip => 'Use current location';

  @override
  String get selectAllButtonLabel => 'Select all';

  @override
  String get searchLogsHint => 'Search logs..';

  @override
  String get noLogsAvailable => 'No logs available';

  @override
  String get dbViewerTitle => 'DB Viewer';

  @override
  String get selectTableToViewData => 'Select a table to view its data';

  @override
  String get selectTableDropdownHint => 'Select a table';

  @override
  String get pickContactTitle => 'Pick a contact';

  @override
  String get permissionRequiredText => 'Permission required';

  @override
  String get grantPermissionButtonLabel => 'Grant permission';

  @override
  String get pageDummyTitle => 'Page Dummy';

  @override
  String get simulateButtonLabel => 'Simulate';

  @override
  String get selectCategoryTitle => 'Select category';

  @override
  String get addCategoryTitle => 'Add category';

  @override
  String get editCategoryTitle => 'Edit category';

  @override
  String get categoryTitleHint => 'Category title';

  @override
  String get colorLabel => 'Color';

  @override
  String get changeColorLabel => 'Change color';

  @override
  String get deviceDisabledMessage => 'Device disabled!';

  @override
  String get cannotRemoveThisDeviceMessage => 'Can\'t remove this device!';

  @override
  String get confirmRemoveTitle => 'Confirm Remove';

  @override
  String get confirmRemoveDeviceContent => 'Are you sure? This will delete all the data on the device.';

  @override
  String get okButtonLabel => 'OK';

  @override
  String get registeredDevicesTitle => 'Registered Devices';

  @override
  String get noDevicesFoundMessage => 'No devices found';

  @override
  String get enabledLabel => 'Enabled';

  @override
  String get disabledLabel => 'Disabled';

  @override
  String get migratingMediaTitle => 'Migrating Media';

  @override
  String get processingMessage => 'Processing...';

  @override
  String get doNotNavigateAwayMessage => 'Please do not navigate away';

  @override
  String errorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String get sequenceNotAcceptedError => 'Sequence not accepted';

  @override
  String get examplesNotAcceptedError => 'Examples not accepted';

  @override
  String get enterKeyAgainLabel => 'Enter key again';

  @override
  String get pleaseEnterKeyAgainError => 'Please enter key again';

  @override
  String get keysDoNotMatchError => 'Keys do not match';

  @override
  String get ruleUppercaseLetter => '1 uppercase letter';

  @override
  String get ruleLowercaseLetter => '1 lowercase letter';

  @override
  String get ruleNumericLetter => '1 numeric letter';

  @override
  String get ruleSpecialCharacter => '1 special character';

  @override
  String get ruleMinTenCharacters => 'min 10 characters';

  @override
  String get examplesTitle => 'Examples';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => 'Got it';

  @override
  String get encryptionKeyTitle => 'Encryption key';

  @override
  String get createKeyDescription => 'Please enter a long and hard to guess key (password). Remember to save it somewhere safe. If it lost/forgotten, it can not be recovered.';

  @override
  String get seeExamplesTooltip => 'See examples';

  @override
  String get couldNotFetchDetailsMessage => 'Could not fetch details';

  @override
  String get retryButtonLabel => 'Retry';

  @override
  String get signedInAsLabel => 'Signed in as:';

  @override
  String get storageUsageLabel => 'Storage Usage';

  @override
  String get subscribeLabel => 'Subscribe';

  @override
  String get planExpiredRenewLabel => 'Plan expired! Renew';

  @override
  String get manageDevicesLabel => 'Manage devices';

  @override
  String get viewAccessKeyLabel => 'View access key';

  @override
  String get changeKeyPasswordLabel => 'Change key password';

  @override
  String get manageSubscriptionLabel => 'Manage subscription';

  @override
  String get signOutButtonLabel => 'Sign Out';

  @override
  String get yearlyPlansTitle => 'Yearly plans';

  @override
  String get loginLabel => 'Login';

  @override
  String get syncAllYourNotesLabel => 'Sync all your notes';

  @override
  String get acrossYourDevicesLabel => 'across your devices';

  @override
  String get featureEndToEndEncryption => 'End-to-end encryption';

  @override
  String get featureSyncUpTo3Devices => 'Sync up to 3 devices';

  @override
  String get featureUpgradeCancelAnytime => 'Upgrade/Cancel anytime';

  @override
  String get noPlansAvailableMessage => 'No plans available';

  @override
  String get downloadAppSubscribeLabel => 'Download the app & subscribe';

  @override
  String get privacyTermsLabel => 'Privacy • Terms';

  @override
  String get saveFiftyPercentLabel => 'Save 50%';

  @override
  String get helloTitle => 'Hello';

  @override
  String get selectKeyMasterKeyDescription => 'To encrypt your data, we’ll need a master encryption key.';

  @override
  String get selectKeyTwoOptionsDescription => 'There are 2 options - either you create a key yourself (similar to password) or we create it for you.';

  @override
  String get understandLoseKeyAcknowledgement => 'I understand that if I lose/forget encryption key, I may lose the data.';

  @override
  String get createKeyForMeButtonLabel => 'Create the key for me';

  @override
  String get recommendedLabel => '(Recommended)';

  @override
  String get pleaseAcknowledgeMessage => 'Please acknowledge!';

  @override
  String get createKeyMyselfButtonLabel => 'I’ll create the key myself';

  @override
  String welcomeToAppName(String appName) {
    return 'Welcome to $appName';
  }

  @override
  String get e2eEncryptionDescription => 'We use end-to-end encryption to make sure that all of your notes are safe and no one else can see them, not even us.';

  @override
  String get timeToStartEncryptionLabel => 'Time to start the encryption!';

  @override
  String get nextButtonLabel => 'Next';

  @override
  String get sendingOtpFailedMessage => 'Sending OTP failed. Please try again!';

  @override
  String get otpVerificationFailedMessage => 'OTP verification failed. Please try again!';

  @override
  String get emailSignInTitle => 'Email SignIn';

  @override
  String get verifyOtpLabel => 'Verify OTP';

  @override
  String get enterEmailLabel => 'Enter Email';

  @override
  String get sendOtpLabel => 'Send OTP';

  @override
  String otpSentToEmailMessage(String email) {
    return 'We have sent a one-time password (OTP) to your email $email';
  }

  @override
  String get enterOtpLabel => 'Enter OTP';

  @override
  String get changeEmailLabel => 'Change email';

  @override
  String get encryptingNotesTitle => 'Encrypting notes';

  @override
  String get fetchingDetailsTitle => 'Fetching details';

  @override
  String get couldNotFetchMessage => 'Could not fetch';

  @override
  String get subscriptionEmailMismatchMessage => 'Your subscription is associated with another email. Please sign-out and use that to enable cloud storage.';

  @override
  String get errorCheckingPlanDetailsMessage => 'Error checking plan details';

  @override
  String get registerDeviceTitle => 'Register device';

  @override
  String get manageButtonLabel => 'Manage';

  @override
  String get fetchingKeysTitle => 'Fetching Keys';

  @override
  String get signingOutTitle => 'Signing out';

  @override
  String get pleaseCheckInternetMessage => 'Please check internet';

  @override
  String get somethingWentWrongMessage => 'Something went wrong';

  @override
  String get playPauseTooltip => 'Play/pause';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => 'Download';

  @override
  String get invalidAccessKey => 'Invalid access key';

  @override
  String get fileDoesNotContain24Words => 'The file does not contain exactly 24 words.';

  @override
  String get errorReadingFile => 'Error reading file';

  @override
  String get allLabel => 'All';

  @override
  String get logTypeDebug => 'DEBUG';

  @override
  String get logTypeError => 'ERROR';

  @override
  String get logTypeInfo => 'INFO';

  @override
  String get logTypeWarning => 'WARNING';

  @override
  String get groupTitleHint => 'Group title';

  @override
  String get categoryLabel => 'Category';

  @override
  String get selectCategoryPlaceholder => 'Select category';

  @override
  String storageBytesFormat(String bytes) {
    return '$bytes B';
  }

  @override
  String storageKilobytesFormat(String kb) {
    return '$kb KB';
  }

  @override
  String storageMegabytesFormat(String mb) {
    return '$mb MB';
  }

  @override
  String storageGigabytesFormat(String gb) {
    return '$gb GB';
  }

  @override
  String storageUsedTotalFormat(String used, String total) {
    return '$used / $total';
  }

  @override
  String planStorageSizeFormat(String size, String unit) {
    return '$size $unit';
  }

  @override
  String get searchHint => 'query, #document etc..';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => 'Audio file';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageGreek => 'Ελληνικά';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePersian => 'فارسی';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageHebrew => 'עברית';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageDutch => 'Nederlands';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageThai => 'ไทย';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageUkrainian => 'Українська';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get selectLanguageTitle => 'Select language';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeLabel => 'Theme';

  @override
  String get dayNightThemeTooltip => 'Day/night theme';

  @override
  String get lockLabel => 'Lock';

  @override
  String get timeFormatLabel => 'Time Format';

  @override
  String get h12Label => 'H12';

  @override
  String get h24Label => 'H24';

  @override
  String get fontSizeLabel => 'Font size';

  @override
  String get reduceTextSizeTooltip => 'Reduce text size';

  @override
  String get increaseTextSizeTooltip => 'Increase text size';

  @override
  String get languageLabel => 'Language';

  @override
  String shareAppMessage(String appName, String appLink) {
    return 'Make a $appName: $appLink';
  }

  @override
  String get noteTypeEmpty => 'Empty';

  @override
  String get noteTypeImage => 'Image';

  @override
  String get noteTypeVideo => 'Video';

  @override
  String get noteTypeAudio => 'Audio';

  @override
  String get noteTypeDocument => 'Document';

  @override
  String get noteTypeContact => 'Contact';

  @override
  String get noteTypeLocation => 'Location';

  @override
  String get noteTypeUnknown => 'Unknown';

  @override
  String get pleaseEnterData => 'Please enter data';

  @override
  String get aNumber => 'A number';

  @override
  String get enterDataLabel => 'Enter data';

  @override
  String get pleaseEnterValidData => 'Please enter valid data';

  @override
  String get pleaseSelectAnOption => 'Please select an option';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => 'Today';

  @override
  String get yesterdayLabel => 'Yesterday';

  @override
  String get mondayLabel => 'Monday';

  @override
  String get tuesdayLabel => 'Tuesday';

  @override
  String get wednesdayLabel => 'Wednesday';

  @override
  String get thursdayLabel => 'Thursday';

  @override
  String get fridayLabel => 'Friday';

  @override
  String get saturdayLabel => 'Saturday';

  @override
  String get sundayLabel => 'Sunday';

  @override
  String get januaryShortLabel => 'Jan';

  @override
  String get februaryShortLabel => 'Feb';

  @override
  String get marchShortLabel => 'Mar';

  @override
  String get aprilShortLabel => 'Apr';

  @override
  String get mayShortLabel => 'May';

  @override
  String get juneShortLabel => 'Jun';

  @override
  String get julyShortLabel => 'Jul';

  @override
  String get augustShortLabel => 'Aug';

  @override
  String get septemberShortLabel => 'Sep';

  @override
  String get octoberShortLabel => 'Oct';

  @override
  String get novemberShortLabel => 'Nov';

  @override
  String get decemberShortLabel => 'Dec';

  @override
  String noteGroupDateTitleFormat(String month, String day, String dayOfWeek) {
    return '$month $day, $dayOfWeek';
  }

  @override
  String mediaDurationHoursFormat(String hours, String minutes, String seconds) {
    return '$hours:$minutes:$seconds';
  }

  @override
  String mediaDurationMinutesFormat(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get fileSizeZero => '0 B';

  @override
  String get fileSizeUnitBytes => 'B';

  @override
  String get fileSizeUnitKilobytes => 'KB';

  @override
  String get fileSizeUnitMegabytes => 'MB';

  @override
  String get fileSizeUnitGigabytes => 'GB';

  @override
  String get fileSizeUnitTerabytes => 'TB';

  @override
  String fileSizeFormat(String size, String suffix) {
    return '$size $suffix';
  }

  @override
  String noteGroupCountSingle(int count) {
    return '$count note group';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count note groups';
  }
}

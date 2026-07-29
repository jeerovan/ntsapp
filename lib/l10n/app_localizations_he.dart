// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get importantTitle => 'חשוב';

  @override
  String get accessKeyNoticeDescription1 => 'בעמוד הבא תראה סדרה של 24 מילים. זהו מפתח ההצפנה הייחודי והפרטי שלך, והוא הדרך היחידה לשחזר את ההערות שלך במקרה של התנתקות, אובדן מכשיר או תקלה.';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return 'איננו שומרים את המפתח. באחריותך לשמור אותו במקום בטוח מחוץ לאפליקציית $appName.';
  }

  @override
  String get iUnderstandShowMeTheKey => 'אני מבין.\nהצג לי את המפתח.';

  @override
  String get selectGroupToViewNotes => 'בחר קבוצה כדי להציג הערות';

  @override
  String get accessKeyShareText => 'להלן מפתח הגישה שלך.';

  @override
  String get pleaseTryAgain => 'אנא נסה שוב.';

  @override
  String get copiedToClipboard => 'הועתק ללוח';

  @override
  String get accessKeyTitle => 'מפתח גישה';

  @override
  String get accessKeyDescription => 'אנא שמור מפתח זה במקום מאובטח. תזדקק לו כדי לסנכרן הערות במכשיר אחר.';

  @override
  String get copyLabel => 'העתק';

  @override
  String get downloadAsTextFileLabel => 'הורד כקובץ טקסט';

  @override
  String get continueLabel => 'המשך';

  @override
  String get pleaseAuthenticate => 'אנא בצע אימות';

  @override
  String get couldNotCreate => 'לא ניתן ליצור';

  @override
  String get couldNotShareFile => 'לא ניתן לשתף את הקובץ';

  @override
  String get hereIsTheBackupFile => 'להלן קובץ הגיבוי עבור האפליקציה שלך.';

  @override
  String get errorTitle => 'שגיאה';

  @override
  String get backupLabel => 'גיבוי';

  @override
  String get restoreLabel => 'שחזור';

  @override
  String get leaveAReviewLabel => 'כתוב ביקורת';

  @override
  String get shareLabel => 'שתף';

  @override
  String get desktopAppLinkLabel => 'אפליקציית שולחן עבודה';

  @override
  String get loggingLabel => 'רישום (Logging)';

  @override
  String versionLabel(String version) {
    return 'גרסה: $version';
  }

  @override
  String get loadingLabel => 'טוען...';

  @override
  String get restoredLabel => 'שוחזר.';

  @override
  String get deletedPermanentlyLabel => 'נמחק לצמיתות.';

  @override
  String get mediaTitle => 'מדיה';

  @override
  String get invalidWordList => 'רשימת מילים לא חוקית';

  @override
  String get enterYour24WordPhrase => 'הזן את משפט 24 המילים שלך';

  @override
  String get enterYourRecoveryPhraseHere => 'הזן את משפט השחזור שלך כאן';

  @override
  String get pleaseEnterYourRecoveryPhrase => 'אנא הזן את משפט השחזור שלך';

  @override
  String get recoveryPhraseMustContain24Words => 'משפט השחזור חייב להכיל בדיוק 24 מילים';

  @override
  String get submitLabel => 'שלח';

  @override
  String get orLabel => 'או';

  @override
  String get selectTxtFileLabel => 'בחר קובץ .txt';

  @override
  String get failureTitle => 'כשל';

  @override
  String get invalidPasswordKey => 'מפתח סיסמה לא חוקי';

  @override
  String get enableSyncTitle => 'הפעל סנכרון';

  @override
  String get passwordRequirementsDescription => 'אנא הזן את המפתח (הסיסמה) שיצרת. הוא חייב להכיל לפחות 10 תווים, כולל לפחות ספרה אחת, אות קטנה אחת, אות גדולה אחת ותו מיוחד אחד.';

  @override
  String get enterKeyLabel => 'הזן מפתח';

  @override
  String get pleaseEnterKey => 'אנא הזן מפתח';

  @override
  String get filterNotesTitle => 'סנן הערות';

  @override
  String get filterPinnedNotesTooltip => 'סנן הערות מוצמדות';

  @override
  String get filterStarredNotesTooltip => 'סנן הערות מסומנות בכוכב';

  @override
  String get filterTextNotesTooltip => 'סנן הערות טקסט';

  @override
  String get filterTasksTooltip => 'סנן משימות';

  @override
  String get filterLinksTooltip => 'סנן קישורים';

  @override
  String get filterImagesTooltip => 'סנן תמונות';

  @override
  String get filterAudioTooltip => 'סנן אודיו';

  @override
  String get filterVideoTooltip => 'סנן וידאו';

  @override
  String get filterFilesTooltip => 'סנן קבצים';

  @override
  String get filterContactsTooltip => 'סנן אנשי קשר';

  @override
  String get filterLocationTooltip => 'סנן מיקום';

  @override
  String get movedToTrash => 'הועבר לאשפה';

  @override
  String get copiedNotesToClipboard => 'הועתק ללוח';

  @override
  String get locationShareLabel => 'מיקום:';

  @override
  String get contactShareLabel => 'איש קשר:';

  @override
  String get emailsShareLabel => 'אימיילים:';

  @override
  String get addressesShareLabel => 'כתובות:';

  @override
  String get microphoneNotAvailable => 'ייתכן שהמיקרופון אינו זמין.';

  @override
  String get microphonePermissionRequired => 'נדרשת הרשאת מיקרופון כדי להקליט אודיו.';

  @override
  String get couldNotGetDuration => 'לא ניתן לקבל משך זמן';

  @override
  String get errorOpeningFiles => 'שגיאה בפתיחת קבצים';

  @override
  String get pleaseWaitTitle => 'אנא המתן';

  @override
  String get fileNotAvailableYet => 'הקובץ עדיין לא זמין';

  @override
  String get clearSelectionTooltip => 'נקה בחירה';

  @override
  String get copyNotesTooltip => 'העתק הערות';

  @override
  String get changeTaskTypeTooltip => 'שנה סוג משימה';

  @override
  String get shareNotesTooltip => 'שתף הערות';

  @override
  String get noNotesSelectedToShare => 'לא נבחרו הערות לשיתוף';

  @override
  String get nothingToShare => 'אין מה לשתף';

  @override
  String get shareFailed => 'השיתוף נכשל';

  @override
  String get editNoteTooltip => 'ערוך הערה';

  @override
  String get starUnstarNotesTooltip => 'סמן/בטל סימון כוכב';

  @override
  String get moveToTrashTooltip => 'העבר לאשפה';

  @override
  String get pinUnpinNotesTooltip => 'הצמד/בטל הצמדה';

  @override
  String get cancelReplyTooltip => 'בטל פריט לתגובה';

  @override
  String get createTaskHint => 'צור משימה';

  @override
  String get addNoteHint => 'הוסף הערה...';

  @override
  String get attachTooltip => 'צרף';

  @override
  String get addNoteTooltip => 'הוסף הערה';

  @override
  String get recordStopAudioTooltip => 'הקלט/עצור הקלטת אודיו';

  @override
  String get contactAttachmentLabel => 'איש קשר';

  @override
  String get locationAttachmentLabel => 'מיקום';

  @override
  String get cameraAttachmentLabel => 'מצלמה';

  @override
  String get filesAttachmentLabel => 'קבצים';

  @override
  String get checklistAttachmentLabel => 'רשימת מטלות';

  @override
  String get accessKeyInputTitle => 'הפעל סנכרון';

  @override
  String get accessKeyInputDescription => 'אנא הזן את משפט השחזור בן 24 המילים שלך או טען קובץ .txt המכיל אותו.';

  @override
  String get editMenuItemLabel => 'ערוך';

  @override
  String get filterMenuItemLabel => 'מסננים';

  @override
  String get externalStoragePermissionDenied => 'ההרשאה לגישה לאחסון חיצוני נדחתה.';

  @override
  String get pressLongToStartRecording => 'לחץ לחיצה ארוכה כדי להתחיל בהקלטה.';

  @override
  String get didYouKnowTitle => 'הידעת?';

  @override
  String get closeTooltip => 'סגור';

  @override
  String appDescriptionContent(String appName) {
    return '$appName היא אפליקציית הערות פרטית לחלוטין. היא אינה אוספת את הנתונים האישיים שלך ואינה מציגה פרסומות.\n\nאנו מקווים שתיהנה מהשימוש בה. ספר לנו מה דעתך.';
  }

  @override
  String get searchNotesTooltip => 'חפש הערות';

  @override
  String get syncMenuItemLabel => 'סנכרון';

  @override
  String get trashMenuItemLabel => 'אשפה';

  @override
  String get starredNotesMenuItemLabel => 'הערות מסומנות בכוכב';

  @override
  String get settingsMenuItemLabel => 'הגדרות';

  @override
  String get accountMenuItemLabel => 'חשבון';

  @override
  String get pageMenuItemLabel => 'עמוד';

  @override
  String get sqliteMenuItemLabel => 'Sqlite';

  @override
  String get logsMenuItemLabel => 'יומנים';

  @override
  String get reorderMenuItemLabel => 'סדר מחדש';

  @override
  String get editGroupMenuItemLabel => 'ערוך';

  @override
  String get deleteGroupMenuItemLabel => 'מחק';

  @override
  String get dragHandleReorderTooltip => 'גרור את הידית כדי לסדר מחדש';

  @override
  String get holdAndDragReorderTooltip => 'החזק וגרור כדי לסדר מחדש';

  @override
  String get emptyHomePageMessage => 'שלום!\n\nנראה שקצת ריק כאן.\n\nהקש על כפתור ה-+ וצור לעצמך הערות. :)';

  @override
  String get reorderingTitle => 'סידור מחדש';

  @override
  String get selectEllipsisLabel => 'בחר...';

  @override
  String get dateTimeToggleLabel => 'תאריך/שעה';

  @override
  String get noteBorderToggleLabel => 'גבול הערה';

  @override
  String get deleteGroupButtonLabel => 'מחק';

  @override
  String get notesTabLabel => 'הערות';

  @override
  String get groupsTabLabel => 'קבוצות';

  @override
  String get categoriesTabLabel => 'קטגוריות';

  @override
  String get locationItemLabel => 'מיקום';

  @override
  String get addGroupTitle => 'הוסף קבוצה';

  @override
  String get editGroupTitle => 'ערוך קבוצה';

  @override
  String get titleInputLabel => 'כותרת';

  @override
  String get locationPermissionRequiredTitle => 'נדרשת הרשאת מיקום';

  @override
  String get enableLocationPermissionsContent => 'אנא הפעל הרשאות מיקום בהגדרות האפליקציה.';

  @override
  String get cancelButtonLabel => 'ביטול';

  @override
  String get openSettingsButtonLabel => 'פתח הגדרות';

  @override
  String get locationServicesTitle => 'שירותי מיקום';

  @override
  String get pleaseEnableLocationServicesContent => 'אנא הפעל!';

  @override
  String get selectLocationTitle => 'בחר מיקום';

  @override
  String get useCurrentLocationTooltip => 'השתמש במיקום הנוכחי';

  @override
  String get selectAllButtonLabel => 'בחר הכל';

  @override
  String get searchLogsHint => 'חפש ביומנים..';

  @override
  String get noLogsAvailable => 'אין יומנים זמינים';

  @override
  String get dbViewerTitle => 'צפייה במסד נתונים';

  @override
  String get selectTableToViewData => 'בחר טבלה כדי להציג את הנתונים שלה';

  @override
  String get selectTableDropdownHint => 'בחר טבלה';

  @override
  String get pickContactTitle => 'בחר איש קשר';

  @override
  String get permissionRequiredText => 'נדרשת הרשאה';

  @override
  String get grantPermissionButtonLabel => 'תן הרשאה';

  @override
  String get pageDummyTitle => 'דף דמי';

  @override
  String get simulateButtonLabel => 'הדמה';

  @override
  String get selectCategoryTitle => 'בחר קטגוריה';

  @override
  String get addCategoryTitle => 'הוסף קטגוריה';

  @override
  String get editCategoryTitle => 'ערוך קטגוריה';

  @override
  String get categoryTitleHint => 'כותרת קטגוריה';

  @override
  String get colorLabel => 'צבע';

  @override
  String get changeColorLabel => 'שנה צבע';

  @override
  String get deviceDisabledMessage => 'מכשיר מושבת!';

  @override
  String get cannotRemoveThisDeviceMessage => 'לא ניתן להסיר מכשיר זה!';

  @override
  String get confirmRemoveTitle => 'אשר הסרה';

  @override
  String get confirmRemoveDeviceContent => 'האם אתה בטוח? פעולה זו תמחק את כל הנתונים במכשיר.';

  @override
  String get okButtonLabel => 'אישור';

  @override
  String get registeredDevicesTitle => 'מכשירים רשומים';

  @override
  String get noDevicesFoundMessage => 'לא נמצאו מכשירים';

  @override
  String get enabledLabel => 'מופעל';

  @override
  String get disabledLabel => 'מושבת';

  @override
  String get migratingMediaTitle => 'מעביר מדיה';

  @override
  String get processingMessage => 'מעבד...';

  @override
  String get doNotNavigateAwayMessage => 'אנא אל תצא מהדף';

  @override
  String errorWithDetails(String error) {
    return 'שגיאה: $error';
  }

  @override
  String get sequenceNotAcceptedError => 'רצף אינו מקובל';

  @override
  String get examplesNotAcceptedError => 'דוגמאות אינן מקובלות';

  @override
  String get enterKeyAgainLabel => 'הזן את המפתח שוב';

  @override
  String get pleaseEnterKeyAgainError => 'אנא הזן את המפתח שוב';

  @override
  String get keysDoNotMatchError => 'המפתחות אינם תואמים';

  @override
  String get ruleUppercaseLetter => 'אות גדולה אחת';

  @override
  String get ruleLowercaseLetter => 'אות קטנה אחת';

  @override
  String get ruleNumericLetter => 'ספרה אחת';

  @override
  String get ruleSpecialCharacter => 'תו מיוחד אחד';

  @override
  String get ruleMinTenCharacters => 'מינימום 10 תווים';

  @override
  String get examplesTitle => 'דוגמאות';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => 'הבנתי';

  @override
  String get encryptionKeyTitle => 'מפתח הצפנה';

  @override
  String get createKeyDescription => 'אנא הזן מפתח (סיסמה) ארוך וקשה לניחוש. זכור לשמור אותו במקום בטוח. אם הוא יאבד או יישכח, לא ניתן יהיה לשחזרו.';

  @override
  String get seeExamplesTooltip => 'ראה דוגמאות';

  @override
  String get couldNotFetchDetailsMessage => 'לא ניתן היה להביא פרטים';

  @override
  String get retryButtonLabel => 'נסה שוב';

  @override
  String get signedInAsLabel => 'מחובר כ:';

  @override
  String get storageUsageLabel => 'שימוש באחסון';

  @override
  String get subscribeLabel => 'הירשם';

  @override
  String get planExpiredRenewLabel => 'התוכנית פגה! חדוש';

  @override
  String get manageDevicesLabel => 'ניהול מכשירים';

  @override
  String get viewAccessKeyLabel => 'צפה במפתח גישה';

  @override
  String get changeKeyPasswordLabel => 'שנה סיסמת מפתח';

  @override
  String get manageSubscriptionLabel => 'ניהול מנוי';

  @override
  String get signOutButtonLabel => 'התנתק';

  @override
  String get yearlyPlansTitle => 'תוכניות שנתיות';

  @override
  String get loginLabel => 'התחבר';

  @override
  String get syncAllYourNotesLabel => 'סנכרן את כל ההערות שלך';

  @override
  String get acrossYourDevicesLabel => 'בין המכשירים שלך';

  @override
  String get featureEndToEndEncryption => 'הצפנה מקצה לקצה';

  @override
  String get featureSyncUpTo3Devices => 'סנכרון עד 3 מכשירים';

  @override
  String get featureUpgradeCancelAnytime => 'שדרוג/ביטול בכל עת';

  @override
  String get noPlansAvailableMessage => 'אין תוכניות זמינות';

  @override
  String get downloadAppSubscribeLabel => 'הורד את האפליקציה והירשם';

  @override
  String get privacyTermsLabel => 'פרטיות • תנאים';

  @override
  String get saveFiftyPercentLabel => 'חסוך 50%';

  @override
  String get helloTitle => 'שלום';

  @override
  String get selectKeyMasterKeyDescription => 'כדי להצפין את הנתונים שלך, נצטרך מפתח הצפנה ראשי.';

  @override
  String get selectKeyTwoOptionsDescription => 'ישנן 2 אפשרויות - או שתיצור מפתח בעצמך (בדומה לסיסמה) או שאנחנו ניצור אותו עבורך.';

  @override
  String get understandLoseKeyAcknowledgement => 'אני מבין שאם אאבד/אשכח את מפתח ההצפנה, אני עלול לאבד את הנתונים.';

  @override
  String get createKeyForMeButtonLabel => 'צור את המפתח עבורי';

  @override
  String get recommendedLabel => '(מומלץ)';

  @override
  String get pleaseAcknowledgeMessage => 'אנא אשר את התנאים!';

  @override
  String get createKeyMyselfButtonLabel => 'אצור את המפתח בעצמי';

  @override
  String welcomeToAppName(String appName) {
    return 'ברוך הבא ל-$appName';
  }

  @override
  String get e2eEncryptionDescription => 'אנו משתמשים בהצפנה מקצה לקצה כדי לוודא שכל ההערות שלך בטוחות ושאף אחד אחר לא יכול לראות אותן, אפילו לא אנחנו.';

  @override
  String get timeToStartEncryptionLabel => 'הגיע הזמן להתחיל בהצפנה!';

  @override
  String get nextButtonLabel => 'הבא';

  @override
  String get sendingOtpFailedMessage => 'שליחת ה-OTP נכשלה. אנא נסה שוב!';

  @override
  String get otpVerificationFailedMessage => 'אימות ה-OTP נכשל. אנא נסה שוב!';

  @override
  String get emailSignInTitle => 'התחברות באמצעות אימייל';

  @override
  String get verifyOtpLabel => 'אמת OTP';

  @override
  String get enterEmailLabel => 'הזן אימייל';

  @override
  String get sendOtpLabel => 'שלח OTP';

  @override
  String otpSentToEmailMessage(String email) {
    return 'שלחנו סיסמה חד-פעמית (OTP) לאימייל שלך $email';
  }

  @override
  String get enterOtpLabel => 'הזן OTP';

  @override
  String get changeEmailLabel => 'שנה אימייל';

  @override
  String get encryptingNotesTitle => 'מצפין הערות';

  @override
  String get fetchingDetailsTitle => 'מביא פרטים';

  @override
  String get couldNotFetchMessage => 'לא ניתן היה להביא נתונים';

  @override
  String get subscriptionEmailMismatchMessage => 'המנוי שלך משויך לאימייל אחר. אנא התנתק והשתמש בו כדי להפעיל אחסון בענן.';

  @override
  String get errorCheckingPlanDetailsMessage => 'שגיאה בבדיקת פרטי התוכנית';

  @override
  String get registerDeviceTitle => 'רשום מכשיר';

  @override
  String get manageButtonLabel => 'נהל';

  @override
  String get fetchingKeysTitle => 'מביא מפתחות';

  @override
  String get signingOutTitle => 'מתנתק';

  @override
  String get pleaseCheckInternetMessage => 'אנא בדוק את החיבור לאינטרנט';

  @override
  String get somethingWentWrongMessage => 'משהו השתבש';

  @override
  String get playPauseTooltip => 'נגן/השהה';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => 'הורד';

  @override
  String get invalidAccessKey => 'מפתח גישה לא חוקי';

  @override
  String get fileDoesNotContain24Words => 'הקובץ אינו מכיל בדיוק 24 מילים.';

  @override
  String get errorReadingFile => 'שגיאה בקריאת קובץ';

  @override
  String get allLabel => 'הכל';

  @override
  String get logTypeDebug => 'DEBUG';

  @override
  String get logTypeError => 'ERROR';

  @override
  String get logTypeInfo => 'INFO';

  @override
  String get logTypeWarning => 'WARNING';

  @override
  String get groupTitleHint => 'כותרת קבוצה';

  @override
  String get categoryLabel => 'קטגוריה';

  @override
  String get selectCategoryPlaceholder => 'בחר קטגוריה';

  @override
  String storageBytesFormat(String bytes) {
    return '$bytes בייט';
  }

  @override
  String storageKilobytesFormat(String kb) {
    return '$kb ק\"ב';
  }

  @override
  String storageMegabytesFormat(String mb) {
    return '$mb מ\"ב';
  }

  @override
  String storageGigabytesFormat(String gb) {
    return '$gb ג\"ב';
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
  String get searchHint => 'שאילתה, #מסמך וכו\'..';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => 'קובץ אודיו';

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
  String get selectLanguageTitle => 'בחר שפה';

  @override
  String get settingsTitle => 'הגדרות';

  @override
  String get themeLabel => 'ערכת נושא';

  @override
  String get dayNightThemeTooltip => 'ערכת נושא יום/לילה';

  @override
  String get lockLabel => 'נעילה';

  @override
  String get timeFormatLabel => 'פורמט זמן';

  @override
  String get h12Label => '12 שעות';

  @override
  String get h24Label => '24 שעות';

  @override
  String get fontSizeLabel => 'גודל גופן';

  @override
  String get reduceTextSizeTooltip => 'הקטן גודל טקסט';

  @override
  String get increaseTextSizeTooltip => 'הגדל גודל טקסט';

  @override
  String get languageLabel => 'שפה';

  @override
  String get autoOpenGroupLabel => 'פתח קבוצה אוטומטית';

  @override
  String get selectGroupTitle => 'בחר קבוצה';

  @override
  String shareAppMessage(String appName, String appLink) {
    return 'צור $appName: $appLink';
  }

  @override
  String get noteTypeEmpty => 'ריק';

  @override
  String get noteTypeImage => 'תמונה';

  @override
  String get noteTypeVideo => 'וידאו';

  @override
  String get noteTypeAudio => 'אודיו';

  @override
  String get noteTypeDocument => 'מסמך';

  @override
  String get noteTypeContact => 'איש קשר';

  @override
  String get noteTypeLocation => 'מיקום';

  @override
  String get noteTypeUnknown => 'לא ידוע';

  @override
  String get pleaseEnterData => 'אנא הזן נתונים';

  @override
  String get aNumber => 'מספר';

  @override
  String get enterDataLabel => 'הזן נתונים';

  @override
  String get pleaseEnterValidData => 'אנא הזן נתונים חוקיים';

  @override
  String get pleaseSelectAnOption => 'אנא בחר אפשרות';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => 'היום';

  @override
  String get yesterdayLabel => 'אתמול';

  @override
  String get mondayLabel => 'שני';

  @override
  String get tuesdayLabel => 'שלישי';

  @override
  String get wednesdayLabel => 'רביעי';

  @override
  String get thursdayLabel => 'חמישי';

  @override
  String get fridayLabel => 'שישי';

  @override
  String get saturdayLabel => 'שבת';

  @override
  String get sundayLabel => 'ראשון';

  @override
  String get januaryShortLabel => 'ינו';

  @override
  String get februaryShortLabel => 'פבר';

  @override
  String get marchShortLabel => 'מרץ';

  @override
  String get aprilShortLabel => 'אפר';

  @override
  String get mayShortLabel => 'מאי';

  @override
  String get juneShortLabel => 'יונ';

  @override
  String get julyShortLabel => 'יול';

  @override
  String get augustShortLabel => 'אוג';

  @override
  String get septemberShortLabel => 'ספט';

  @override
  String get octoberShortLabel => 'אוק';

  @override
  String get novemberShortLabel => 'נוב';

  @override
  String get decemberShortLabel => 'דצמ';

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
  String get fileSizeZero => '0 בייט';

  @override
  String get fileSizeUnitBytes => 'בייט';

  @override
  String get fileSizeUnitKilobytes => 'ק\"ב';

  @override
  String get fileSizeUnitMegabytes => 'מ\"ב';

  @override
  String get fileSizeUnitGigabytes => 'ג\"ב';

  @override
  String get fileSizeUnitTerabytes => 'ט\"ב';

  @override
  String fileSizeFormat(String size, String suffix) {
    return '$size $suffix';
  }

  @override
  String noteGroupCountSingle(int count) {
    return '$count קבוצת הערות';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count קבוצות הערות';
  }

  @override
  String get seedCategoryTasks => 'משימות';

  @override
  String get seedGroupNotes => 'הערות';

  @override
  String get seedGroupFitness => 'כושר';

  @override
  String get seedItemWelcome => 'ברוכים הבאים ל-Note Safe!\nרעיונות, רשימות או כל דבר שעולה בדעתכם – שמרו הכל כאן.\n\nלחצו לחיצה ארוכה על הערה זו כדי למחוק, לערוך או לראות אפשרויות נוספות.';

  @override
  String get seedItemMorningWorkout => 'אימון בוקר';

  @override
  String get seedItemMeditation => '10 דקות מדיטציה';

  @override
  String get seedItemWater => '2 ליטר מים ביום';

  @override
  String get seedItemSteps => 'ללכת 10,000 צעדים';
}

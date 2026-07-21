// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get importantTitle => 'مهم';

  @override
  String get accessKeyNoticeDescription1 => 'در صفحه بعد، مجموعه‌ای از ۲۴ کلمه را مشاهده خواهید کرد. این کلید رمزنگاری منحصربه‌فرد و خصوصی شماست و تنها راه بازیابی یادداشت‌هایتان در صورت خروج از حساب، گم شدن دستگاه یا خرابی آن است.';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return 'ما این کلید را ذخیره نمی‌کنیم. مسئولیت نگهداری آن در مکانی امن و خارج از برنامه $appName بر عهده شماست.';
  }

  @override
  String get iUnderstandShowMeTheKey => 'متوجه شدم.\nکلید را نشانم بده.';

  @override
  String get selectGroupToViewNotes => 'برای مشاهده یادداشت‌ها، یک گروه انتخاب کنید';

  @override
  String get accessKeyShareText => 'این کلید دسترسی شماست.';

  @override
  String get pleaseTryAgain => 'لطفاً دوباره تلاش کنید.';

  @override
  String get copiedToClipboard => 'در حافظه موقت کپی شد';

  @override
  String get accessKeyTitle => 'کلید دسترسی';

  @override
  String get accessKeyDescription => 'لطفاً این کلید را در مکانی امن ذخیره کنید. برای همگام‌سازی یادداشت‌ها روی دستگاه دیگر به آن نیاز خواهید داشت.';

  @override
  String get copyLabel => 'کپی';

  @override
  String get downloadAsTextFileLabel => 'دانلود به صورت فایل متنی';

  @override
  String get continueLabel => 'ادامه';

  @override
  String get pleaseAuthenticate => 'لطفاً احراز هویت کنید';

  @override
  String get couldNotCreate => 'ایجاد نشد';

  @override
  String get couldNotShareFile => 'اشتراک‌گذاری فایل انجام نشد';

  @override
  String get hereIsTheBackupFile => 'این فایل پشتیبان برنامه شماست.';

  @override
  String get errorTitle => 'خطا';

  @override
  String get backupLabel => 'پشتیبان‌گیری';

  @override
  String get restoreLabel => 'بازیابی';

  @override
  String get leaveAReviewLabel => 'ثبت دیدگاه';

  @override
  String get shareLabel => 'اشتراک‌گذاری';

  @override
  String get desktopAppLinkLabel => 'نسخه دسکتاپ';

  @override
  String get loggingLabel => 'لاگ‌ها';

  @override
  String versionLabel(String version) {
    return 'نسخه: $version';
  }

  @override
  String get loadingLabel => 'در حال بارگذاری...';

  @override
  String get restoredLabel => 'بازیابی شد.';

  @override
  String get deletedPermanentlyLabel => 'به‌طور دائم حذف شد.';

  @override
  String get mediaTitle => 'رسانه';

  @override
  String get invalidWordList => 'لیست کلمات نامعتبر';

  @override
  String get enterYour24WordPhrase => 'عبارت ۲۴ کلمه‌ای خود را وارد کنید';

  @override
  String get enterYourRecoveryPhraseHere => 'عبارت بازیابی خود را اینجا وارد کنید';

  @override
  String get pleaseEnterYourRecoveryPhrase => 'لطفاً عبارت بازیابی خود را وارد کنید';

  @override
  String get recoveryPhraseMustContain24Words => 'عبارت بازیابی باید دقیقاً ۲۴ کلمه باشد';

  @override
  String get submitLabel => 'ثبت';

  @override
  String get orLabel => 'یا';

  @override
  String get selectTxtFileLabel => 'انتخاب فایل .txt';

  @override
  String get failureTitle => 'شکست';

  @override
  String get invalidPasswordKey => 'کلید رمز عبور نامعتبر';

  @override
  String get enableSyncTitle => 'فعال‌سازی همگام‌سازی';

  @override
  String get passwordRequirementsDescription => 'لطفاً کلیدی (رمز عبوری) که قبلاً ساخته‌اید را وارد کنید. این کلید باید حداقل ۱۰ کاراکتر داشته باشد و شامل حداقل ۱ عدد، ۱ حرف کوچک، ۱ حرف بزرگ و ۱ کاراکتر خاص باشد.';

  @override
  String get enterKeyLabel => 'وارد کردن کلید';

  @override
  String get pleaseEnterKey => 'لطفاً کلید را وارد کنید';

  @override
  String get filterNotesTitle => 'فیلتر یادداشت‌ها';

  @override
  String get filterPinnedNotesTooltip => 'فیلتر یادداشت‌های پین‌شده';

  @override
  String get filterStarredNotesTooltip => 'فیلتر یادداشت‌های ستاره‌دار';

  @override
  String get filterTextNotesTooltip => 'فیلتر یادداشت‌های متنی';

  @override
  String get filterTasksTooltip => 'فیلتر وظایف';

  @override
  String get filterLinksTooltip => 'فیلتر لینک‌ها';

  @override
  String get filterImagesTooltip => 'فیلتر تصاویر';

  @override
  String get filterAudioTooltip => 'فیلتر صوت';

  @override
  String get filterVideoTooltip => 'فیلتر ویدیو';

  @override
  String get filterFilesTooltip => 'فیلتر فایل‌ها';

  @override
  String get filterContactsTooltip => 'فیلتر مخاطبین';

  @override
  String get filterLocationTooltip => 'فیلتر مکان';

  @override
  String get movedToTrash => 'به سطل زباله منتقل شد';

  @override
  String get copiedNotesToClipboard => 'در حافظه موقت کپی شد';

  @override
  String get locationShareLabel => 'مکان:';

  @override
  String get contactShareLabel => 'مخاطب:';

  @override
  String get emailsShareLabel => 'ایمیل‌ها:';

  @override
  String get addressesShareLabel => 'آدرس‌ها:';

  @override
  String get microphoneNotAvailable => 'میکروفون ممکن است در دسترس نباشد.';

  @override
  String get microphonePermissionRequired => 'برای ضبط صدا، دسترسی به میکروفون لازم است.';

  @override
  String get couldNotGetDuration => 'امکان دریافت مدت زمان وجود ندارد';

  @override
  String get errorOpeningFiles => 'خطا در باز کردن فایل‌ها';

  @override
  String get pleaseWaitTitle => 'لطفاً منتظر بمانید';

  @override
  String get fileNotAvailableYet => 'فایل هنوز در دسترس نیست';

  @override
  String get clearSelectionTooltip => 'پاک کردن انتخاب';

  @override
  String get copyNotesTooltip => 'کپی یادداشت‌ها';

  @override
  String get changeTaskTypeTooltip => 'تغییر نوع وظیفه';

  @override
  String get shareNotesTooltip => 'اشتراک‌گذاری یادداشت‌ها';

  @override
  String get editNoteTooltip => 'ویرایش یادداشت';

  @override
  String get starUnstarNotesTooltip => 'ستاره‌دار/بدون ستاره کردن یادداشت‌ها';

  @override
  String get moveToTrashTooltip => 'انتقال به سطل زباله';

  @override
  String get pinUnpinNotesTooltip => 'پین/برداشتن پین یادداشت‌ها';

  @override
  String get cancelReplyTooltip => 'لغو پاسخ';

  @override
  String get createTaskHint => 'ایجاد یک وظیفه';

  @override
  String get addNoteHint => 'افزودن یادداشت...';

  @override
  String get attachTooltip => 'پیوست';

  @override
  String get addNoteTooltip => 'افزودن یادداشت';

  @override
  String get recordStopAudioTooltip => 'ضبط/توقف ضبط صدا';

  @override
  String get contactAttachmentLabel => 'مخاطب';

  @override
  String get locationAttachmentLabel => 'مکان';

  @override
  String get cameraAttachmentLabel => 'دوربین';

  @override
  String get filesAttachmentLabel => 'فایل‌ها';

  @override
  String get checklistAttachmentLabel => 'چک‌لیست';

  @override
  String get accessKeyInputTitle => 'فعال‌سازی همگام‌سازی';

  @override
  String get accessKeyInputDescription => 'لطفاً عبارت بازیابی ۲۴ کلمه‌ای خود را وارد کنید یا فایل .txt شامل آن را بارگذاری نمایید.';

  @override
  String get editMenuItemLabel => 'ویرایش';

  @override
  String get filterMenuItemLabel => 'فیلترها';

  @override
  String get externalStoragePermissionDenied => 'دسترسی به حافظه خارجی رد شد.';

  @override
  String get pressLongToStartRecording => 'برای شروع ضبط، طولانی فشار دهید.';

  @override
  String get didYouKnowTitle => 'آیا می‌دانستید؟';

  @override
  String get closeTooltip => 'بستن';

  @override
  String appDescriptionContent(String appName) {
    return '$appName یک برنامه یادداشت‌برداری کاملاً خصوصی است. این برنامه داده‌های شخصی شما را جمع‌آوری نمی‌کند و تبلیغاتی نمایش نمی‌دهد.\n\nامیدواریم از استفاده از آن لذت ببرید. نظر خود را با ما در میان بگذارید.';
  }

  @override
  String get searchNotesTooltip => 'جستجوی یادداشت‌ها';

  @override
  String get syncMenuItemLabel => 'همگام‌سازی';

  @override
  String get trashMenuItemLabel => 'سطل زباله';

  @override
  String get starredNotesMenuItemLabel => 'یادداشت‌های ستاره‌دار';

  @override
  String get settingsMenuItemLabel => 'تنظیمات';

  @override
  String get accountMenuItemLabel => 'حساب کاربری';

  @override
  String get pageMenuItemLabel => 'صفحه';

  @override
  String get sqliteMenuItemLabel => 'Sqlite';

  @override
  String get logsMenuItemLabel => 'لاگ‌ها';

  @override
  String get reorderMenuItemLabel => 'مرتب‌سازی مجدد';

  @override
  String get editGroupMenuItemLabel => 'ویرایش';

  @override
  String get deleteGroupMenuItemLabel => 'حذف';

  @override
  String get dragHandleReorderTooltip => 'برای تغییر ترتیب بکشید';

  @override
  String get holdAndDragReorderTooltip => 'برای تغییر ترتیب نگه دارید و بکشید';

  @override
  String get emptyHomePageMessage => 'سلام!\n\nاینجا کمی خالی به نظر می‌رسد.\n\nدکمه + را بزنید و یادداشت‌های خود را ایجاد کنید. :)';

  @override
  String get reorderingTitle => 'مرتب‌سازی';

  @override
  String get selectEllipsisLabel => 'انتخاب...';

  @override
  String get dateTimeToggleLabel => 'تاریخ/زمان';

  @override
  String get noteBorderToggleLabel => 'کادر یادداشت';

  @override
  String get deleteGroupButtonLabel => 'حذف';

  @override
  String get notesTabLabel => 'یادداشت‌ها';

  @override
  String get groupsTabLabel => 'گروه‌ها';

  @override
  String get categoriesTabLabel => 'دسته‌بندی‌ها';

  @override
  String get locationItemLabel => 'مکان';

  @override
  String get addGroupTitle => 'افزودن گروه';

  @override
  String get editGroupTitle => 'ویرایش گروه';

  @override
  String get titleInputLabel => 'عنوان';

  @override
  String get locationPermissionRequiredTitle => 'مجوز مکان مورد نیاز است';

  @override
  String get enableLocationPermissionsContent => 'لطفاً مجوزهای مکان را در تنظیمات برنامه فعال کنید.';

  @override
  String get cancelButtonLabel => 'لغو';

  @override
  String get openSettingsButtonLabel => 'باز کردن تنظیمات';

  @override
  String get locationServicesTitle => 'خدمات مکان';

  @override
  String get pleaseEnableLocationServicesContent => 'لطفاً فعال کنید!';

  @override
  String get selectLocationTitle => 'انتخاب مکان';

  @override
  String get useCurrentLocationTooltip => 'استفاده از مکان فعلی';

  @override
  String get selectAllButtonLabel => 'انتخاب همه';

  @override
  String get searchLogsHint => 'جستجوی لاگ‌ها..';

  @override
  String get noLogsAvailable => 'لاگی موجود نیست';

  @override
  String get dbViewerTitle => 'مشاهده‌گر دیتابیس';

  @override
  String get selectTableToViewData => 'برای مشاهده داده‌ها، یک جدول انتخاب کنید';

  @override
  String get selectTableDropdownHint => 'انتخاب جدول';

  @override
  String get pickContactTitle => 'انتخاب مخاطب';

  @override
  String get permissionRequiredText => 'مجوز مورد نیاز است';

  @override
  String get grantPermissionButtonLabel => 'اعطای مجوز';

  @override
  String get pageDummyTitle => 'صفحه آزمایشی';

  @override
  String get simulateButtonLabel => 'شبیه‌سازی';

  @override
  String get selectCategoryTitle => 'انتخاب دسته‌بندی';

  @override
  String get addCategoryTitle => 'افزودن دسته‌بندی';

  @override
  String get editCategoryTitle => 'ویرایش دسته‌بندی';

  @override
  String get categoryTitleHint => 'عنوان دسته‌بندی';

  @override
  String get colorLabel => 'رنگ';

  @override
  String get changeColorLabel => 'تغییر رنگ';

  @override
  String get deviceDisabledMessage => 'دستگاه غیرفعال شد!';

  @override
  String get cannotRemoveThisDeviceMessage => 'نمی‌توان این دستگاه را حذف کرد!';

  @override
  String get confirmRemoveTitle => 'تأیید حذف';

  @override
  String get confirmRemoveDeviceContent => 'مطمئن هستید؟ این کار تمام داده‌های روی این دستگاه را حذف می‌کند.';

  @override
  String get okButtonLabel => 'باشه';

  @override
  String get registeredDevicesTitle => 'دستگاه‌های ثبت‌شده';

  @override
  String get noDevicesFoundMessage => 'دستگاهی یافت نشد';

  @override
  String get enabledLabel => 'فعال';

  @override
  String get disabledLabel => 'غیرفعال';

  @override
  String get migratingMediaTitle => 'انتقال رسانه‌ها';

  @override
  String get processingMessage => 'در حال پردازش...';

  @override
  String get doNotNavigateAwayMessage => 'لطفاً از صفحه خارج نشوید';

  @override
  String errorWithDetails(String error) {
    return 'خطا: $error';
  }

  @override
  String get sequenceNotAcceptedError => 'توالی پذیرفته نشد';

  @override
  String get examplesNotAcceptedError => 'نمونه‌ها پذیرفته نشدند';

  @override
  String get enterKeyAgainLabel => 'وارد کردن مجدد کلید';

  @override
  String get pleaseEnterKeyAgainError => 'لطفاً کلید را دوباره وارد کنید';

  @override
  String get keysDoNotMatchError => 'کلیدها مطابقت ندارند';

  @override
  String get ruleUppercaseLetter => '۱ حرف بزرگ';

  @override
  String get ruleLowercaseLetter => '۱ حرف کوچک';

  @override
  String get ruleNumericLetter => '۱ عدد';

  @override
  String get ruleSpecialCharacter => '۱ کاراکتر خاص';

  @override
  String get ruleMinTenCharacters => 'حداقل ۱۰ کاراکتر';

  @override
  String get examplesTitle => 'نمونه‌ها';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => 'متوجه شدم';

  @override
  String get encryptionKeyTitle => 'کلید رمزنگاری';

  @override
  String get createKeyDescription => 'لطفاً یک کلید (رمز عبور) طولانی و غیرقابل حدس وارد کنید. به یاد داشته باشید که آن را در مکانی امن ذخیره کنید. در صورت گم شدن یا فراموشی، بازیابی آن امکان‌پذیر نیست.';

  @override
  String get seeExamplesTooltip => 'مشاهده نمونه‌ها';

  @override
  String get couldNotFetchDetailsMessage => 'امکان دریافت جزئیات وجود ندارد';

  @override
  String get retryButtonLabel => 'تلاش مجدد';

  @override
  String get signedInAsLabel => 'وارد شده با عنوان:';

  @override
  String get storageUsageLabel => 'میزان استفاده از حافظه';

  @override
  String get subscribeLabel => 'اشتراک';

  @override
  String get planExpiredRenewLabel => 'اشتراک منقضی شده است! تمدید کنید';

  @override
  String get manageDevicesLabel => 'مدیریت دستگاه‌ها';

  @override
  String get viewAccessKeyLabel => 'مشاهده کلید دسترسی';

  @override
  String get changeKeyPasswordLabel => 'تغییر رمز عبور کلید';

  @override
  String get manageSubscriptionLabel => 'مدیریت اشتراک';

  @override
  String get signOutButtonLabel => 'خروج از حساب';

  @override
  String get yearlyPlansTitle => 'طرح‌های سالانه';

  @override
  String get loginLabel => 'ورود';

  @override
  String get syncAllYourNotesLabel => 'همگام‌سازی تمامی یادداشت‌ها';

  @override
  String get acrossYourDevicesLabel => 'در تمامی دستگاه‌های شما';

  @override
  String get featureEndToEndEncryption => 'رمزنگاری سراسری';

  @override
  String get featureSyncUpTo3Devices => 'همگام‌سازی تا ۳ دستگاه';

  @override
  String get featureUpgradeCancelAnytime => 'ارتقا/لغو در هر زمان';

  @override
  String get noPlansAvailableMessage => 'هیچ طرحی در دسترس نیست';

  @override
  String get downloadAppSubscribeLabel => 'برنامه را دانلود کرده و مشترک شوید';

  @override
  String get privacyTermsLabel => 'حریم خصوصی • شرایط';

  @override
  String get saveFiftyPercentLabel => '۵۰٪ صرفه‌جویی';

  @override
  String get helloTitle => 'سلام';

  @override
  String get selectKeyMasterKeyDescription => 'برای رمزنگاری داده‌هایتان، به یک کلید رمزنگاری اصلی نیاز داریم.';

  @override
  String get selectKeyTwoOptionsDescription => 'دو گزینه دارید: یا خودتان کلید را بسازید (مشابه رمز عبور) یا ما آن را برای شما بسازیم.';

  @override
  String get understandLoseKeyAcknowledgement => 'متوجه هستم که در صورت گم کردن یا فراموشی کلید رمزنگاری، ممکن است داده‌ها را از دست بدهم.';

  @override
  String get createKeyForMeButtonLabel => 'کلید را برایم بساز';

  @override
  String get recommendedLabel => '(پیشنهادی)';

  @override
  String get pleaseAcknowledgeMessage => 'لطفاً تأیید کنید!';

  @override
  String get createKeyMyselfButtonLabel => 'خودم کلید را می‌سازم';

  @override
  String welcomeToAppName(String appName) {
    return 'به $appName خوش آمدید';
  }

  @override
  String get e2eEncryptionDescription => 'ما از رمزنگاری سراسری استفاده می‌کنیم تا اطمینان حاصل کنیم که تمام یادداشت‌های شما امن هستند و هیچ‌کس، حتی ما، نمی‌تواند آن‌ها را ببیند.';

  @override
  String get timeToStartEncryptionLabel => 'زمان شروع رمزنگاری است!';

  @override
  String get nextButtonLabel => 'بعدی';

  @override
  String get sendingOtpFailedMessage => 'ارسال کد تایید (OTP) انجام نشد. لطفاً دوباره تلاش کنید!';

  @override
  String get otpVerificationFailedMessage => 'تایید کد ناموفق بود. لطفاً دوباره تلاش کنید!';

  @override
  String get emailSignInTitle => 'ورود با ایمیل';

  @override
  String get verifyOtpLabel => 'تایید کد (OTP)';

  @override
  String get enterEmailLabel => 'وارد کردن ایمیل';

  @override
  String get sendOtpLabel => 'ارسال کد تایید';

  @override
  String otpSentToEmailMessage(String email) {
    return 'ما یک کد تایید (OTP) به ایمیل شما $email ارسال کردیم';
  }

  @override
  String get enterOtpLabel => 'وارد کردن کد تایید';

  @override
  String get changeEmailLabel => 'تغییر ایمیل';

  @override
  String get encryptingNotesTitle => 'در حال رمزنگاری یادداشت‌ها';

  @override
  String get fetchingDetailsTitle => 'در حال دریافت جزئیات';

  @override
  String get couldNotFetchMessage => 'امکان دریافت وجود ندارد';

  @override
  String get subscriptionEmailMismatchMessage => 'اشتراک شما با ایمیل دیگری مرتبط است. لطفاً خارج شده و با آن ایمیل وارد شوید تا فضای ابری فعال شود.';

  @override
  String get errorCheckingPlanDetailsMessage => 'خطا در بررسی جزئیات طرح';

  @override
  String get registerDeviceTitle => 'ثبت دستگاه';

  @override
  String get manageButtonLabel => 'مدیریت';

  @override
  String get fetchingKeysTitle => 'در حال دریافت کلیدها';

  @override
  String get signingOutTitle => 'در حال خروج';

  @override
  String get pleaseCheckInternetMessage => 'لطفاً اینترنت خود را بررسی کنید';

  @override
  String get somethingWentWrongMessage => 'مشکلی پیش آمده است';

  @override
  String get playPauseTooltip => 'پخش/مکث';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => 'دانلود';

  @override
  String get invalidAccessKey => 'کلید دسترسی نامعتبر';

  @override
  String get fileDoesNotContain24Words => 'فایل حاوی دقیقاً ۲۴ کلمه نیست.';

  @override
  String get errorReadingFile => 'خطا در خواندن فایل';

  @override
  String get allLabel => 'همه';

  @override
  String get logTypeDebug => 'دی‌باگ';

  @override
  String get logTypeError => 'خطا';

  @override
  String get logTypeInfo => 'اطلاعات';

  @override
  String get logTypeWarning => 'هشدار';

  @override
  String get groupTitleHint => 'عنوان گروه';

  @override
  String get categoryLabel => 'دسته‌بندی';

  @override
  String get selectCategoryPlaceholder => 'انتخاب دسته‌بندی';

  @override
  String storageBytesFormat(String bytes) {
    return '$bytes بایت';
  }

  @override
  String storageKilobytesFormat(String kb) {
    return '$kb کیلوبایت';
  }

  @override
  String storageMegabytesFormat(String mb) {
    return '$mb مگابایت';
  }

  @override
  String storageGigabytesFormat(String gb) {
    return '$gb گیگابایت';
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
  String get searchHint => 'کوئری، #سند و غیره..';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => 'فایل صوتی';

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
  String get selectLanguageTitle => 'انتخاب زبان';

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String get themeLabel => 'تم';

  @override
  String get dayNightThemeTooltip => 'تم روز/شب';

  @override
  String get lockLabel => 'قفل';

  @override
  String get timeFormatLabel => 'فرمت زمان';

  @override
  String get h12Label => '۱۲ ساعته';

  @override
  String get h24Label => '۲۴ ساعته';

  @override
  String get fontSizeLabel => 'اندازه فونت';

  @override
  String get reduceTextSizeTooltip => 'کاهش اندازه متن';

  @override
  String get increaseTextSizeTooltip => 'افزایش اندازه متن';

  @override
  String get languageLabel => 'زبان';

  @override
  String get autoOpenGroupLabel => 'باز کردن خودکار گروه';

  @override
  String get selectGroupTitle => 'انتخاب گروه';

  @override
  String shareAppMessage(String appName, String appLink) {
    return 'یک $appName بسازید: $appLink';
  }

  @override
  String get noteTypeEmpty => 'خالی';

  @override
  String get noteTypeImage => 'تصویر';

  @override
  String get noteTypeVideo => 'ویدیو';

  @override
  String get noteTypeAudio => 'صوت';

  @override
  String get noteTypeDocument => 'سند';

  @override
  String get noteTypeContact => 'مخاطب';

  @override
  String get noteTypeLocation => 'مکان';

  @override
  String get noteTypeUnknown => 'ناشناخته';

  @override
  String get pleaseEnterData => 'لطفاً داده وارد کنید';

  @override
  String get aNumber => 'یک عدد';

  @override
  String get enterDataLabel => 'وارد کردن داده';

  @override
  String get pleaseEnterValidData => 'لطفاً داده معتبر وارد کنید';

  @override
  String get pleaseSelectAnOption => 'لطفاً یک گزینه انتخاب کنید';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => 'امروز';

  @override
  String get yesterdayLabel => 'دیروز';

  @override
  String get mondayLabel => 'دوشنبه';

  @override
  String get tuesdayLabel => 'سه‌شنبه';

  @override
  String get wednesdayLabel => 'چهارشنبه';

  @override
  String get thursdayLabel => 'پنجشنبه';

  @override
  String get fridayLabel => 'جمعه';

  @override
  String get saturdayLabel => 'شنبه';

  @override
  String get sundayLabel => 'یکشنبه';

  @override
  String get januaryShortLabel => 'ژانویه';

  @override
  String get februaryShortLabel => 'فوریه';

  @override
  String get marchShortLabel => 'مارس';

  @override
  String get aprilShortLabel => 'آوریل';

  @override
  String get mayShortLabel => 'مه';

  @override
  String get juneShortLabel => 'ژوئن';

  @override
  String get julyShortLabel => 'ژوئیه';

  @override
  String get augustShortLabel => 'اوت';

  @override
  String get septemberShortLabel => 'سپتامبر';

  @override
  String get octoberShortLabel => 'اکتبر';

  @override
  String get novemberShortLabel => 'نوامبر';

  @override
  String get decemberShortLabel => 'دسامبر';

  @override
  String noteGroupDateTitleFormat(String month, String day, String dayOfWeek) {
    return '$month $day، $dayOfWeek';
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
  String get fileSizeZero => '۰ بایت';

  @override
  String get fileSizeUnitBytes => 'بایت';

  @override
  String get fileSizeUnitKilobytes => 'کیلوبایت';

  @override
  String get fileSizeUnitMegabytes => 'مگابایت';

  @override
  String get fileSizeUnitGigabytes => 'گیگابایت';

  @override
  String get fileSizeUnitTerabytes => 'ترابایت';

  @override
  String fileSizeFormat(String size, String suffix) {
    return '$size $suffix';
  }

  @override
  String noteGroupCountSingle(int count) {
    return '$count گروه یادداشت';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count گروه یادداشت';
  }


  @override
  String get seedCategoryTasks => "وظایف";

  @override
  String get seedGroupNotes => "یادداشت‌ها";

  @override
  String get seedGroupFitness => "تناسب اندام";

  @override
  String get seedItemWelcome =>
      "به Note Safe خوش آمدید!\nایده‌ها، لیست‌ها یا هر چیزی که در ذهن دارید را اینجا بنویسید.\n\nبرای حذف، ویرایش و سایر گزینه‌ها، روی این یادداشت نگه دارید.";

  @override
  String get seedItemMorningWorkout => "ورزش صبحگاهی";

  @override
  String get seedItemMeditation => "۱۰ دقیقه مدیتیشن";

  @override
  String get seedItemWater => "۲ لیتر آب در روز";

  @override
  String get seedItemSteps => "۱۰,۰۰۰ قدم پیاده‌روی";
}
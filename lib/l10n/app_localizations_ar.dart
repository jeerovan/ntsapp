// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get importantTitle => 'هام';

  @override
  String get accessKeyNoticeDescription1 => 'في الصفحة التالية، ستظهر لك سلسلة مكونة من 24 كلمة. هذا هو مفتاح التشفير الخاص والفريد الخاص بك، وهو الطريقة الوحيدة لاستعادة ملاحظاتك في حال تسجيل الخروج أو فقدان الجهاز أو تعطل التطبيق.';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return 'نحن لا نقوم بتخزين المفتاح. تقع على عاتقك مسؤولية حفظه في مكان آمن خارج تطبيق $appName.';
  }

  @override
  String get iUnderstandShowMeTheKey => 'أفهم ذلك.\nأظهر لي المفتاح.';

  @override
  String get selectGroupToViewNotes => 'اختر مجموعة لعرض الملاحظات';

  @override
  String get accessKeyShareText => 'إليك مفتاح الوصول الخاص بك.';

  @override
  String get pleaseTryAgain => 'يرجى المحاولة مجدداً.';

  @override
  String get copiedToClipboard => 'تم النسخ إلى الحافظة';

  @override
  String get accessKeyTitle => 'مفتاح الوصول';

  @override
  String get accessKeyDescription => 'يرجى حفظ هذا المفتاح في مكان آمن. ستحتاجه لمزامنة ملاحظاتك على جهاز آخر.';

  @override
  String get copyLabel => 'نسخ';

  @override
  String get downloadAsTextFileLabel => 'تنزيل كملف نصي';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get pleaseAuthenticate => 'يرجى المصادقة';

  @override
  String get couldNotCreate => 'تعذر الإنشاء';

  @override
  String get couldNotShareFile => 'تعذر مشاركة الملف';

  @override
  String get hereIsTheBackupFile => 'إليك ملف النسخ الاحتياطي للتطبيق.';

  @override
  String get errorTitle => 'خطأ';

  @override
  String get backupLabel => 'نسخ احتياطي';

  @override
  String get restoreLabel => 'استعادة';

  @override
  String get leaveAReviewLabel => 'اترك تقييماً';

  @override
  String get shareLabel => 'مشاركة';

  @override
  String get desktopAppLinkLabel => 'تطبيق سطح المكتب';

  @override
  String get loggingLabel => 'السجلات';

  @override
  String versionLabel(String version) {
    return 'الإصدار: $version';
  }

  @override
  String get loadingLabel => 'جاري التحميل...';

  @override
  String get restoredLabel => 'تم الاستعادة.';

  @override
  String get deletedPermanentlyLabel => 'تم الحذف نهائياً.';

  @override
  String get mediaTitle => 'الوسائط';

  @override
  String get invalidWordList => 'قائمة كلمات غير صالحة';

  @override
  String get enterYour24WordPhrase => 'أدخل عبارة الاسترداد المكونة من 24 كلمة';

  @override
  String get enterYourRecoveryPhraseHere => 'أدخل عبارة الاسترداد هنا';

  @override
  String get pleaseEnterYourRecoveryPhrase => 'يرجى إدخال عبارة الاسترداد الخاصة بك';

  @override
  String get recoveryPhraseMustContain24Words => 'يجب أن تحتوي عبارة الاسترداد على 24 كلمة بالضبط';

  @override
  String get submitLabel => 'إرسال';

  @override
  String get orLabel => 'أو';

  @override
  String get selectTxtFileLabel => 'اختر ملف .txt';

  @override
  String get failureTitle => 'فشل';

  @override
  String get invalidPasswordKey => 'مفتاح كلمة المرور غير صالح';

  @override
  String get enableSyncTitle => 'تفعيل المزامنة';

  @override
  String get passwordRequirementsDescription => 'يرجى إدخال المفتاح (كلمة المرور) الذي أنشأته. يجب أن يتكون من 10 أحرف على الأقل، متضمناً رقماً واحداً، وحرفاً صغيراً، وحرفاً كبيراً، ورمزاً خاصاً.';

  @override
  String get enterKeyLabel => 'أدخل المفتاح';

  @override
  String get pleaseEnterKey => 'يرجى إدخال المفتاح';

  @override
  String get filterNotesTitle => 'تصفية الملاحظات';

  @override
  String get filterPinnedNotesTooltip => 'تصفية الملاحظات المثبتة';

  @override
  String get filterStarredNotesTooltip => 'تصفية الملاحظات المميزة بنجمة';

  @override
  String get filterTextNotesTooltip => 'تصفية الملاحظات النصية';

  @override
  String get filterTasksTooltip => 'تصفية المهام';

  @override
  String get filterLinksTooltip => 'تصفية الروابط';

  @override
  String get filterImagesTooltip => 'تصفية الصور';

  @override
  String get filterAudioTooltip => 'تصفية الملفات الصوتية';

  @override
  String get filterVideoTooltip => 'تصفية الفيديوهات';

  @override
  String get filterFilesTooltip => 'تصفية الملفات';

  @override
  String get filterContactsTooltip => 'تصفية جهات الاتصال';

  @override
  String get filterLocationTooltip => 'تصفية المواقع الجغرافية';

  @override
  String get movedToTrash => 'تم النقل إلى المهملات';

  @override
  String get copiedNotesToClipboard => 'تم النسخ إلى الحافظة';

  @override
  String get locationShareLabel => 'الموقع:';

  @override
  String get contactShareLabel => 'جهة الاتصال:';

  @override
  String get emailsShareLabel => 'البريد الإلكتروني:';

  @override
  String get addressesShareLabel => 'العناوين:';

  @override
  String get microphoneNotAvailable => 'قد لا يكون الميكروفون متاحاً.';

  @override
  String get microphonePermissionRequired => 'إذن الوصول للميكروفون مطلوب لتسجيل الصوت.';

  @override
  String get couldNotGetDuration => 'تعذر الحصول على المدة';

  @override
  String get errorOpeningFiles => 'خطأ أثناء فتح الملفات';

  @override
  String get pleaseWaitTitle => 'يرجى الانتظار';

  @override
  String get fileNotAvailableYet => 'الملف غير متاح حالياً';

  @override
  String get clearSelectionTooltip => 'إلغاء التحديد';

  @override
  String get copyNotesTooltip => 'نسخ الملاحظات';

  @override
  String get changeTaskTypeTooltip => 'تغيير نوع المهمة';

  @override
  String get shareNotesTooltip => 'مشاركة الملاحظات';

  @override
  String get noNotesSelectedToShare => 'لا توجد ملاحظات محددة للمشاركة';

  @override
  String get nothingToShare => 'لا يوجد شيء للمشاركة';

  @override
  String get shareFailed => 'فشل المشاركة';

  @override
  String get editNoteTooltip => 'تعديل الملاحظة';

  @override
  String get starUnstarNotesTooltip => 'تمييز/إلغاء تمييز الملاحظات';

  @override
  String get moveToTrashTooltip => 'نقل إلى المهملات';

  @override
  String get pinUnpinNotesTooltip => 'تثبيت/إلغاء تثبيت الملاحظات';

  @override
  String get cancelReplyTooltip => 'إلغاء الرد';

  @override
  String get createTaskHint => 'إنشاء مهمة';

  @override
  String get addNoteHint => 'إضافة ملاحظة...';

  @override
  String get attachTooltip => 'إرفاق';

  @override
  String get addNoteTooltip => 'إضافة ملاحظة';

  @override
  String get recordStopAudioTooltip => 'تسجيل/إيقاف الصوت';

  @override
  String get contactAttachmentLabel => 'جهة اتصال';

  @override
  String get locationAttachmentLabel => 'الموقع';

  @override
  String get cameraAttachmentLabel => 'الكاميرا';

  @override
  String get filesAttachmentLabel => 'الملفات';

  @override
  String get checklistAttachmentLabel => 'قائمة مهام';

  @override
  String get accessKeyInputTitle => 'تفعيل المزامنة';

  @override
  String get accessKeyInputDescription => 'يرجى إدخال عبارة الاسترداد المكونة من 24 كلمة أو تحميل ملف .txt يحتوي عليها.';

  @override
  String get editMenuItemLabel => 'تعديل';

  @override
  String get filterMenuItemLabel => 'الفلاتر';

  @override
  String get externalStoragePermissionDenied => 'تم رفض إذن الوصول إلى وحدة التخزين الخارجية.';

  @override
  String get pressLongToStartRecording => 'اضغط مطولاً للبدء في التسجيل.';

  @override
  String get didYouKnowTitle => 'هل تعلم؟';

  @override
  String get closeTooltip => 'إغلاق';

  @override
  String appDescriptionContent(String appName) {
    return '$appName هو تطبيق ملاحظات خاص بالكامل. لا نقوم بجمع بياناتك الشخصية ولا نعرض لك أي إعلانات.\n\nنأمل أن تستمتع باستخدامه. شاركنا رأيك.';
  }

  @override
  String get searchNotesTooltip => 'البحث في الملاحظات';

  @override
  String get syncMenuItemLabel => 'مزامنة';

  @override
  String get trashMenuItemLabel => 'سلة المهملات';

  @override
  String get starredNotesMenuItemLabel => 'الملاحظات المميزة';

  @override
  String get settingsMenuItemLabel => 'الإعدادات';

  @override
  String get accountMenuItemLabel => 'الحساب';

  @override
  String get pageMenuItemLabel => 'الصفحة';

  @override
  String get sqliteMenuItemLabel => 'قاعدة بيانات SQLite';

  @override
  String get logsMenuItemLabel => 'السجلات';

  @override
  String get reorderMenuItemLabel => 'إعادة الترتيب';

  @override
  String get editGroupMenuItemLabel => 'تعديل';

  @override
  String get deleteGroupMenuItemLabel => 'حذف';

  @override
  String get dragHandleReorderTooltip => 'اسحب المقبض لإعادة الترتيب';

  @override
  String get holdAndDragReorderTooltip => 'اضغط مع السحب لإعادة الترتيب';

  @override
  String get emptyHomePageMessage => 'أهلاً بك!\n\nتبدو الصفحة فارغة هنا.\n\nاضغط على زر + لإنشاء ملاحظاتك الخاصة. :)';

  @override
  String get reorderingTitle => 'إعادة الترتيب';

  @override
  String get selectEllipsisLabel => 'اختيار...';

  @override
  String get dateTimeToggleLabel => 'التاريخ/الوقت';

  @override
  String get noteBorderToggleLabel => 'حدود الملاحظة';

  @override
  String get deleteGroupButtonLabel => 'حذف';

  @override
  String get notesTabLabel => 'الملاحظات';

  @override
  String get groupsTabLabel => 'المجموعات';

  @override
  String get categoriesTabLabel => 'الفئات';

  @override
  String get locationItemLabel => 'الموقع';

  @override
  String get addGroupTitle => 'إضافة مجموعة';

  @override
  String get editGroupTitle => 'تعديل المجموعة';

  @override
  String get titleInputLabel => 'العنوان';

  @override
  String get locationPermissionRequiredTitle => 'مطلوب إذن الوصول للموقع';

  @override
  String get enableLocationPermissionsContent => 'يرجى تفعيل إذن الوصول للموقع من إعدادات التطبيق.';

  @override
  String get cancelButtonLabel => 'إلغاء';

  @override
  String get openSettingsButtonLabel => 'فتح الإعدادات';

  @override
  String get locationServicesTitle => 'خدمات الموقع';

  @override
  String get pleaseEnableLocationServicesContent => 'يرجى التفعيل!';

  @override
  String get selectLocationTitle => 'اختر الموقع';

  @override
  String get useCurrentLocationTooltip => 'استخدام الموقع الحالي';

  @override
  String get selectAllButtonLabel => 'تحديد الكل';

  @override
  String get searchLogsHint => 'البحث في السجلات..';

  @override
  String get noLogsAvailable => 'لا توجد سجلات متاحة';

  @override
  String get dbViewerTitle => 'عارض قاعدة البيانات';

  @override
  String get selectTableToViewData => 'اختر جدولاً لعرض بياناته';

  @override
  String get selectTableDropdownHint => 'اختر جدولاً';

  @override
  String get pickContactTitle => 'اختر جهة اتصال';

  @override
  String get permissionRequiredText => 'الإذن مطلوب';

  @override
  String get grantPermissionButtonLabel => 'منح الإذن';

  @override
  String get pageDummyTitle => 'صفحة تجريبية';

  @override
  String get simulateButtonLabel => 'محاكاة';

  @override
  String get selectCategoryTitle => 'اختر فئة';

  @override
  String get addCategoryTitle => 'إضافة فئة';

  @override
  String get editCategoryTitle => 'تعديل فئة';

  @override
  String get categoryTitleHint => 'عنوان الفئة';

  @override
  String get colorLabel => 'اللون';

  @override
  String get changeColorLabel => 'تغيير اللون';

  @override
  String get deviceDisabledMessage => 'الجهاز معطل!';

  @override
  String get cannotRemoveThisDeviceMessage => 'لا يمكن إزالة هذا الجهاز!';

  @override
  String get confirmRemoveTitle => 'تأكيد الإزالة';

  @override
  String get confirmRemoveDeviceContent => 'هل أنت متأكد؟ سيؤدي هذا إلى حذف جميع البيانات الموجودة على الجهاز.';

  @override
  String get okButtonLabel => 'موافق';

  @override
  String get registeredDevicesTitle => 'الأجهزة المسجلة';

  @override
  String get noDevicesFoundMessage => 'لم يتم العثور على أجهزة';

  @override
  String get enabledLabel => 'مفعل';

  @override
  String get disabledLabel => 'معطل';

  @override
  String get migratingMediaTitle => 'نقل الوسائط';

  @override
  String get processingMessage => 'جاري المعالجة...';

  @override
  String get doNotNavigateAwayMessage => 'يرجى عدم مغادرة الصفحة';

  @override
  String errorWithDetails(String error) {
    return 'خطأ: $error';
  }

  @override
  String get sequenceNotAcceptedError => 'تسلسل غير مقبول';

  @override
  String get examplesNotAcceptedError => 'أمثلة غير مقبولة';

  @override
  String get enterKeyAgainLabel => 'أعد إدخال المفتاح';

  @override
  String get pleaseEnterKeyAgainError => 'يرجى إعادة إدخال المفتاح';

  @override
  String get keysDoNotMatchError => 'المفتاحان غير متطابقين';

  @override
  String get ruleUppercaseLetter => 'حرف كبير واحد (Uppercase)';

  @override
  String get ruleLowercaseLetter => 'حرف صغير واحد (Lowercase)';

  @override
  String get ruleNumericLetter => 'رقم واحد';

  @override
  String get ruleSpecialCharacter => 'رمز خاص واحد';

  @override
  String get ruleMinTenCharacters => '10 أحرف كحد أدنى';

  @override
  String get examplesTitle => 'أمثلة';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => 'فهمت';

  @override
  String get encryptionKeyTitle => 'مفتاح التشفير';

  @override
  String get createKeyDescription => 'يرجى إدخال مفتاح (كلمة مرور) طويل ويصعب تخمينه. تذكر حفظه في مكان آمن. في حال ضياعه أو نسيانه، لا يمكن استعادته.';

  @override
  String get seeExamplesTooltip => 'عرض الأمثلة';

  @override
  String get couldNotFetchDetailsMessage => 'تعذر جلب التفاصيل';

  @override
  String get retryButtonLabel => 'إعادة المحاولة';

  @override
  String get signedInAsLabel => 'تم تسجيل الدخول باسم:';

  @override
  String get storageUsageLabel => 'استخدام التخزين';

  @override
  String get subscribeLabel => 'اشتراك';

  @override
  String get planExpiredRenewLabel => 'انتهت صلاحية الخطة! تجديد';

  @override
  String get manageDevicesLabel => 'إدارة الأجهزة';

  @override
  String get viewAccessKeyLabel => 'عرض مفتاح الوصول';

  @override
  String get changeKeyPasswordLabel => 'تغيير كلمة مرور المفتاح';

  @override
  String get manageSubscriptionLabel => 'إدارة الاشتراك';

  @override
  String get signOutButtonLabel => 'تسجيل الخروج';

  @override
  String get yearlyPlansTitle => 'الخطط السنوية';

  @override
  String get loginLabel => 'تسجيل الدخول';

  @override
  String get syncAllYourNotesLabel => 'مزامنة جميع ملاحظاتك';

  @override
  String get acrossYourDevicesLabel => 'عبر جميع أجهزتك';

  @override
  String get featureEndToEndEncryption => 'تشفير من الطرف إلى الطرف';

  @override
  String get featureSyncUpTo3Devices => 'مزامنة ما يصل إلى 3 أجهزة';

  @override
  String get featureUpgradeCancelAnytime => 'الترقية/الإلغاء في أي وقت';

  @override
  String get noPlansAvailableMessage => 'لا توجد خطط متاحة';

  @override
  String get downloadAppSubscribeLabel => 'حمّل التطبيق واشترك';

  @override
  String get privacyTermsLabel => 'الخصوصية • الشروط';

  @override
  String get saveFiftyPercentLabel => 'وفر 50%';

  @override
  String get helloTitle => 'مرحباً';

  @override
  String get selectKeyMasterKeyDescription => 'لتشفير بياناتك، نحتاج إلى مفتاح تشفير رئيسي.';

  @override
  String get selectKeyTwoOptionsDescription => 'يوجد خياران: إما أن تنشئ المفتاح بنفسك (مثل كلمة المرور) أو ننشئه نحن نيابة عنك.';

  @override
  String get understandLoseKeyAcknowledgement => 'أدرك أن فقدان أو نسيان مفتاح التشفير قد يؤدي إلى فقدان بياناتي.';

  @override
  String get createKeyForMeButtonLabel => 'أنشئ المفتاح نيابة عني';

  @override
  String get recommendedLabel => '(موصى به)';

  @override
  String get pleaseAcknowledgeMessage => 'يرجى الموافقة على الشروط!';

  @override
  String get createKeyMyselfButtonLabel => 'سأنشئ المفتاح بنفسي';

  @override
  String welcomeToAppName(String appName) {
    return 'مرحباً بك في $appName';
  }

  @override
  String get e2eEncryptionDescription => 'نستخدم التشفير من الطرف إلى الطرف لضمان خصوصية وأمان ملاحظاتك، بحيث لا يمكن لأحد الاطلاع عليها غيرك، ولا حتى نحن.';

  @override
  String get timeToStartEncryptionLabel => 'حان وقت بدء التشفير!';

  @override
  String get nextButtonLabel => 'التالي';

  @override
  String get sendingOtpFailedMessage => 'فشل إرسال رمز التحقق. يرجى المحاولة مرة أخرى!';

  @override
  String get otpVerificationFailedMessage => 'فشل التحقق من الرمز. يرجى المحاولة مرة أخرى!';

  @override
  String get emailSignInTitle => 'تسجيل الدخول بالبريد الإلكتروني';

  @override
  String get verifyOtpLabel => 'تحقق من الرمز';

  @override
  String get enterEmailLabel => 'أدخل البريد الإلكتروني';

  @override
  String get sendOtpLabel => 'إرسال رمز التحقق';

  @override
  String otpSentToEmailMessage(String email) {
    return 'لقد أرسلنا رمز تحقق (OTP) إلى بريدك الإلكتروني $email';
  }

  @override
  String get enterOtpLabel => 'أدخل رمز التحقق';

  @override
  String get changeEmailLabel => 'تغيير البريد الإلكتروني';

  @override
  String get encryptingNotesTitle => 'جاري تشفير الملاحظات';

  @override
  String get fetchingDetailsTitle => 'جاري جلب التفاصيل';

  @override
  String get couldNotFetchMessage => 'تعذر الجلب';

  @override
  String get subscriptionEmailMismatchMessage => 'اشتراكك مرتبط ببريد إلكتروني آخر. يرجى تسجيل الخروج واستخدام ذلك البريد لتفعيل التخزين السحابي.';

  @override
  String get errorCheckingPlanDetailsMessage => 'خطأ أثناء التحقق من تفاصيل الخطة';

  @override
  String get registerDeviceTitle => 'تسجيل الجهاز';

  @override
  String get manageButtonLabel => 'إدارة';

  @override
  String get fetchingKeysTitle => 'جاري جلب المفاتيح';

  @override
  String get signingOutTitle => 'جاري تسجيل الخروج';

  @override
  String get pleaseCheckInternetMessage => 'يرجى التحقق من اتصال الإنترنت';

  @override
  String get somethingWentWrongMessage => 'حدث خطأ ما';

  @override
  String get playPauseTooltip => 'تشغيل/إيقاف مؤقت';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => 'تنزيل';

  @override
  String get invalidAccessKey => 'مفتاح الوصول غير صالح';

  @override
  String get fileDoesNotContain24Words => 'الملف لا يحتوي على 24 كلمة بالضبط.';

  @override
  String get errorReadingFile => 'خطأ في قراءة الملف';

  @override
  String get allLabel => 'الكل';

  @override
  String get logTypeDebug => 'تصحيح';

  @override
  String get logTypeError => 'خطأ';

  @override
  String get logTypeInfo => 'معلومات';

  @override
  String get logTypeWarning => 'تحذير';

  @override
  String get groupTitleHint => 'عنوان المجموعة';

  @override
  String get categoryLabel => 'الفئة';

  @override
  String get selectCategoryPlaceholder => 'اختر فئة';

  @override
  String storageBytesFormat(String bytes) {
    return '$bytes بايت';
  }

  @override
  String storageKilobytesFormat(String kb) {
    return '$kb كيلوبايت';
  }

  @override
  String storageMegabytesFormat(String mb) {
    return '$mb ميجابايت';
  }

  @override
  String storageGigabytesFormat(String gb) {
    return '$gb جيجابايت';
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
  String get searchHint => 'استعلام، #مستند، إلخ...';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => 'ملف صوتي';

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
  String get selectLanguageTitle => 'اختر اللغة';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get themeLabel => 'السمة';

  @override
  String get dayNightThemeTooltip => 'سمة فاتحة/داكنة';

  @override
  String get lockLabel => 'قفل التطبيق';

  @override
  String get timeFormatLabel => 'تنسيق الوقت';

  @override
  String get h12Label => '١٢ ساعة';

  @override
  String get h24Label => '٢٤ ساعة';

  @override
  String get fontSizeLabel => 'حجم الخط';

  @override
  String get reduceTextSizeTooltip => 'تصغير حجم النص';

  @override
  String get increaseTextSizeTooltip => 'تكبير حجم النص';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get autoOpenGroupLabel => 'فتح المجموعة تلقائياً';

  @override
  String get selectGroupTitle => 'اختر مجموعة';

  @override
  String shareAppMessage(String appName, String appLink) {
    return 'جرب تطبيق $appName: $appLink';
  }

  @override
  String get noteTypeEmpty => 'فارغ';

  @override
  String get noteTypeImage => 'صورة';

  @override
  String get noteTypeVideo => 'فيديو';

  @override
  String get noteTypeAudio => 'صوت';

  @override
  String get noteTypeDocument => 'مستند';

  @override
  String get noteTypeContact => 'جهة اتصال';

  @override
  String get noteTypeLocation => 'موقع';

  @override
  String get noteTypeUnknown => 'غير معروف';

  @override
  String get pleaseEnterData => 'يرجى إدخال بيانات';

  @override
  String get aNumber => 'يجب أن يكون رقماً';

  @override
  String get enterDataLabel => 'أدخل البيانات';

  @override
  String get pleaseEnterValidData => 'يرجى إدخال بيانات صحيحة';

  @override
  String get pleaseSelectAnOption => 'يرجى تحديد خيار';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => 'اليوم';

  @override
  String get yesterdayLabel => 'أمس';

  @override
  String get mondayLabel => 'الاثنين';

  @override
  String get tuesdayLabel => 'الثلاثاء';

  @override
  String get wednesdayLabel => 'الأربعاء';

  @override
  String get thursdayLabel => 'الخميس';

  @override
  String get fridayLabel => 'الجمعة';

  @override
  String get saturdayLabel => 'السبت';

  @override
  String get sundayLabel => 'الأحد';

  @override
  String get januaryShortLabel => 'يناير';

  @override
  String get februaryShortLabel => 'فبراير';

  @override
  String get marchShortLabel => 'مارس';

  @override
  String get aprilShortLabel => 'أبريل';

  @override
  String get mayShortLabel => 'مايو';

  @override
  String get juneShortLabel => 'يونيو';

  @override
  String get julyShortLabel => 'يوليو';

  @override
  String get augustShortLabel => 'أغسطس';

  @override
  String get septemberShortLabel => 'سبتمبر';

  @override
  String get octoberShortLabel => 'أكتوبر';

  @override
  String get novemberShortLabel => 'نوفمبر';

  @override
  String get decemberShortLabel => 'ديسمبر';

  @override
  String noteGroupDateTitleFormat(String month, String day, String dayOfWeek) {
    return '$dayOfWeek، $day $month';
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
  String get fileSizeZero => '0 بايت';

  @override
  String get fileSizeUnitBytes => 'بايت';

  @override
  String get fileSizeUnitKilobytes => 'كيلوبايت';

  @override
  String get fileSizeUnitMegabytes => 'ميجابايت';

  @override
  String get fileSizeUnitGigabytes => 'جيجابايت';

  @override
  String get fileSizeUnitTerabytes => 'تيرابايت';

  @override
  String fileSizeFormat(String size, String suffix) {
    return '$size $suffix';
  }

  @override
  String noteGroupCountSingle(int count) {
    return '$count مجموعة ملاحظات';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count مجموعات ملاحظات';
  }

  @override
  String get seedCategoryTasks => 'المهام';

  @override
  String get seedGroupNotes => 'ملاحظات';

  @override
  String get seedGroupFitness => 'اللياقة البدنية';

  @override
  String get seedItemWelcome => 'مرحباً بك في Note Safe!\nدوّن أفكارك، قوائمك، أو أي شيء يدور في ذهنك هنا.\n\nاضغط مطولاً على هذه الملاحظة للحذف، التعديل، أو عرض خيارات أخرى.';

  @override
  String get seedItemMorningWorkout => 'تمارين الصباح';

  @override
  String get seedItemMeditation => '10 دقائق تأمل';

  @override
  String get seedItemWater => 'شرب لترين من الماء يومياً';

  @override
  String get seedItemSteps => 'المشي 10,000 خطوة';
}

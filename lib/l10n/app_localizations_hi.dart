// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get importantTitle => 'महत्वपूर्ण';

  @override
  String get accessKeyNoticeDescription1 => 'अगले पेज पर आपको 24 शब्दों की एक श्रृंखला दिखाई देगी। यह आपकी अद्वितीय और निजी एन्क्रिप्शन कुंजी है और लॉगआउट, डिवाइस खो जाने या खराब होने की स्थिति में आपके नोट्स को रिकवर करने का यह एकमात्र तरीका है।';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return 'हम इस कुंजी को स्टोर नहीं करते हैं। इसे $appName ऐप के बाहर किसी सुरक्षित स्थान पर रखना आपकी जिम्मेदारी है।';
  }

  @override
  String get iUnderstandShowMeTheKey => 'मैं समझ गया।\nचाबी दिखाएं।';

  @override
  String get selectGroupToViewNotes => 'नोट्स देखने के लिए एक समूह चुनें';

  @override
  String get accessKeyShareText => 'यह रही आपकी एक्सेस की।';

  @override
  String get pleaseTryAgain => 'कृपया पुनः प्रयास करें।';

  @override
  String get copiedToClipboard => 'क्लिपबोर्ड पर कॉपी किया गया';

  @override
  String get accessKeyTitle => 'एक्सेस की';

  @override
  String get accessKeyDescription => 'कृपया इस कुंजी को सुरक्षित स्थान पर सहेजें। अन्य डिवाइस पर नोट्स सिंक करने के लिए आपको इसकी आवश्यकता होगी।';

  @override
  String get copyLabel => 'कॉपी करें';

  @override
  String get downloadAsTextFileLabel => 'टेक्स्ट फ़ाइल के रूप में डाउनलोड करें';

  @override
  String get continueLabel => 'जारी रखें';

  @override
  String get pleaseAuthenticate => 'कृपया प्रमाणित करें';

  @override
  String get couldNotCreate => 'बनाया नहीं जा सका';

  @override
  String get couldNotShareFile => 'फ़ाइल शेयर नहीं की जा सकी';

  @override
  String get hereIsTheBackupFile => 'यह रहा आपके ऐप का बैकअप फ़ाइल।';

  @override
  String get errorTitle => 'त्रुटि';

  @override
  String get backupLabel => 'बैकअप';

  @override
  String get restoreLabel => 'रीस्टोर करें';

  @override
  String get leaveAReviewLabel => 'समीक्षा लिखें';

  @override
  String get shareLabel => 'शेयर करें';

  @override
  String get desktopAppLinkLabel => 'डेस्कटॉप ऐप';

  @override
  String get loggingLabel => 'लॉगिंग';

  @override
  String versionLabel(String version) {
    return 'वर्जन: $version';
  }

  @override
  String get loadingLabel => 'लोड हो रहा है...';

  @override
  String get restoredLabel => 'रिस्टोर किया गया।';

  @override
  String get deletedPermanentlyLabel => 'स्थायी रूप से हटा दिया गया।';

  @override
  String get mediaTitle => 'मीडिया';

  @override
  String get invalidWordList => 'अमान्य शब्द सूची';

  @override
  String get enterYour24WordPhrase => 'अपना 24-शब्दों का वाक्यांश दर्ज करें';

  @override
  String get enterYourRecoveryPhraseHere => 'अपना रिकवरी फ्रेज़ यहाँ दर्ज करें';

  @override
  String get pleaseEnterYourRecoveryPhrase => 'कृपया अपना रिकवरी वाक्यांश दर्ज करें';

  @override
  String get recoveryPhraseMustContain24Words => 'रिकवरी वाक्यांश में ठीक 24 शब्द होने चाहिए';

  @override
  String get submitLabel => 'सबमिट करें';

  @override
  String get orLabel => 'या';

  @override
  String get selectTxtFileLabel => '.txt फ़ाइल चुनें';

  @override
  String get failureTitle => 'विफलता';

  @override
  String get invalidPasswordKey => 'अमान्य पासवर्ड की';

  @override
  String get enableSyncTitle => 'सिंक सक्षम करें';

  @override
  String get passwordRequirementsDescription => 'कृपया अपना बनाया हुआ पासवर्ड दर्ज करें। यह कम से कम 10 अक्षरों का होना चाहिए और इसमें न्यूनतम 1 अंक, 1 छोटा अक्षर, 1 बड़ा अक्षर और 1 विशेष वर्ण होना अनिवार्य है।';

  @override
  String get enterKeyLabel => 'कुंजी दर्ज करें';

  @override
  String get pleaseEnterKey => 'कृपया की (key) दर्ज करें';

  @override
  String get filterNotesTitle => 'नोट्स फ़िल्टर करें';

  @override
  String get filterPinnedNotesTooltip => 'पिन किए गए नोट्स फ़िल्टर करें';

  @override
  String get filterStarredNotesTooltip => 'तारांकित नोट्स फ़िल्टर करें';

  @override
  String get filterTextNotesTooltip => 'टेक्स्ट नोट्स फ़िल्टर करें';

  @override
  String get filterTasksTooltip => 'कार्य फ़िल्टर करें';

  @override
  String get filterLinksTooltip => 'लिंक फ़िल्टर करें';

  @override
  String get filterImagesTooltip => 'छवियां फ़िल्टर करें';

  @override
  String get filterAudioTooltip => 'ऑडियो फ़िल्टर करें';

  @override
  String get filterVideoTooltip => 'वीडियो फ़िल्टर करें';

  @override
  String get filterFilesTooltip => 'फ़ाइलें फ़िल्टर करें';

  @override
  String get filterContactsTooltip => 'संपर्क फ़िल्टर करें';

  @override
  String get filterLocationTooltip => 'स्थान फ़िल्टर करें';

  @override
  String get movedToTrash => 'ट्रैश में ले जाया गया';

  @override
  String get copiedNotesToClipboard => 'क्लिपबोर्ड पर कॉपी किया गया';

  @override
  String get locationShareLabel => 'स्थान:';

  @override
  String get contactShareLabel => 'संपर्क:';

  @override
  String get emailsShareLabel => 'ईमेल:';

  @override
  String get addressesShareLabel => 'पते:';

  @override
  String get microphoneNotAvailable => 'माइक्रोफ़ोन शायद उपलब्ध नहीं है।';

  @override
  String get microphonePermissionRequired => 'ऑडियो रिकॉर्ड करने के लिए माइक्रोफ़ोन की अनुमति आवश्यक है।';

  @override
  String get couldNotGetDuration => 'अवधि प्राप्त नहीं हो सकी';

  @override
  String get errorOpeningFiles => 'फ़ाइलें खोलने में त्रुटि';

  @override
  String get pleaseWaitTitle => 'कृपया प्रतीक्षा करें';

  @override
  String get fileNotAvailableYet => 'फ़ाइल अभी उपलब्ध नहीं है';

  @override
  String get clearSelectionTooltip => 'चयन साफ़ करें';

  @override
  String get copyNotesTooltip => 'नोट्स कॉपी करें';

  @override
  String get changeTaskTypeTooltip => 'कार्य का प्रकार बदलें';

  @override
  String get shareNotesTooltip => 'नोट्स साझा करें';

  @override
  String get noNotesSelectedToShare => 'साझा करने के लिए कोई नोट चयनित नहीं है';

  @override
  String get nothingToShare => 'साझा करने के लिए कुछ नहीं';

  @override
  String get shareFailed => 'साझा करना विफल';

  @override
  String get editNoteTooltip => 'नोट संपादित करें';

  @override
  String get starUnstarNotesTooltip => 'नोट्स को स्टार/अनस्टार करें';

  @override
  String get moveToTrashTooltip => 'ट्रैश में ले जाएं';

  @override
  String get pinUnpinNotesTooltip => 'नोट्स को पिन/अनपिन करें';

  @override
  String get cancelReplyTooltip => 'उत्तर रद्द करें';

  @override
  String get createTaskHint => 'एक कार्य बनाएं';

  @override
  String get addNoteHint => 'एक नोट जोड़ें...';

  @override
  String get attachTooltip => 'संलग्न करें';

  @override
  String get addNoteTooltip => 'नोट जोड़ें';

  @override
  String get recordStopAudioTooltip => 'ऑडियो रिकॉर्ड/रोकें';

  @override
  String get contactAttachmentLabel => 'संपर्क';

  @override
  String get locationAttachmentLabel => 'स्थान';

  @override
  String get cameraAttachmentLabel => 'कैमरा';

  @override
  String get filesAttachmentLabel => 'फ़ाइलें';

  @override
  String get checklistAttachmentLabel => 'चेकलिस्ट';

  @override
  String get accessKeyInputTitle => 'सिंक सक्षम करें';

  @override
  String get accessKeyInputDescription => 'कृपया अपना 24-शब्दों का रिकवरी वाक्यांश दर्ज करें या इसे रखने वाली .txt फ़ाइल अपलोड करें।';

  @override
  String get editMenuItemLabel => 'संपादित करें';

  @override
  String get filterMenuItemLabel => 'फ़िल्टर';

  @override
  String get externalStoragePermissionDenied => 'बाह्य संग्रहण (external storage) तक पहुँचने की अनुमति अस्वीकार कर दी गई।';

  @override
  String get pressLongToStartRecording => 'रिकॉर्डिंग शुरू करने के लिए लंबे समय तक दबाएं।';

  @override
  String get didYouKnowTitle => 'क्या आप जानते हैं?';

  @override
  String get closeTooltip => 'बंद करें';

  @override
  String appDescriptionContent(String appName) {
    return '$appName पूरी तरह से निजी नोट्स ऐप है। यह आपका व्यक्तिगत डेटा एकत्र नहीं करता है और न ही आपको विज्ञापन दिखाता है।\n\nहमें उम्मीद है कि आप इसका उपयोग करके आनंद लेंगे। हमें बताएं कि आप क्या सोचते हैं।';
  }

  @override
  String get searchNotesTooltip => 'नोट्स खोजें';

  @override
  String get syncMenuItemLabel => 'सिंक करें';

  @override
  String get trashMenuItemLabel => 'ट्रैश';

  @override
  String get starredNotesMenuItemLabel => 'स्टार किए गए नोट्स';

  @override
  String get settingsMenuItemLabel => 'सेटिंग्स';

  @override
  String get accountMenuItemLabel => 'खाता';

  @override
  String get pageMenuItemLabel => 'पृष्ठ';

  @override
  String get sqliteMenuItemLabel => 'Sqlite';

  @override
  String get logsMenuItemLabel => 'लॉग्स';

  @override
  String get reorderMenuItemLabel => 'पुनः व्यवस्थित करें';

  @override
  String get editGroupMenuItemLabel => 'संपादित करें';

  @override
  String get deleteGroupMenuItemLabel => 'हटाएं';

  @override
  String get dragHandleReorderTooltip => 'पुनः व्यवस्थित करने के लिए ड्रैग हैंडल का उपयोग करें';

  @override
  String get holdAndDragReorderTooltip => 'पुनः व्यवस्थित करने के लिए दबाए रखें और ड्रैग करें';

  @override
  String get emptyHomePageMessage => 'नमस्ते!\n\nयहाँ सब कुछ खाली लग रहा है।\n\n+ बटन पर टैप करें और कुछ नोट्स बनाएं। :)';

  @override
  String get reorderingTitle => 'पुनः व्यवस्थित किया जा रहा है';

  @override
  String get selectEllipsisLabel => 'चुनें...';

  @override
  String get dateTimeToggleLabel => 'दिनांक/समय';

  @override
  String get noteBorderToggleLabel => 'नोट बॉर्डर';

  @override
  String get deleteGroupButtonLabel => 'हटाएं';

  @override
  String get notesTabLabel => 'नोट्स';

  @override
  String get groupsTabLabel => 'ग्रुप्स';

  @override
  String get categoriesTabLabel => 'श्रेणियाँ';

  @override
  String get locationItemLabel => 'स्थान';

  @override
  String get addGroupTitle => 'ग्रुप जोड़ें';

  @override
  String get editGroupTitle => 'ग्रुप संपादित करें';

  @override
  String get titleInputLabel => 'शीर्षक';

  @override
  String get locationPermissionRequiredTitle => 'स्थान की अनुमति आवश्यक है';

  @override
  String get enableLocationPermissionsContent => 'कृपया ऐप सेटिंग्स में स्थान की अनुमतियाँ सक्षम करें।';

  @override
  String get cancelButtonLabel => 'रद्द करें';

  @override
  String get openSettingsButtonLabel => 'सेटिंग्स खोलें';

  @override
  String get locationServicesTitle => 'स्थान सेवाएँ';

  @override
  String get pleaseEnableLocationServicesContent => 'कृपया सक्षम करें!';

  @override
  String get selectLocationTitle => 'स्थान चुनें';

  @override
  String get useCurrentLocationTooltip => 'वर्तमान स्थान का उपयोग करें';

  @override
  String get selectAllButtonLabel => 'सभी चुनें';

  @override
  String get searchLogsHint => 'लॉग्स खोजें..';

  @override
  String get noLogsAvailable => 'कोई लॉग उपलब्ध नहीं है';

  @override
  String get dbViewerTitle => 'DB व्यूअर';

  @override
  String get selectTableToViewData => 'डेटा देखने के लिए एक टेबल चुनें';

  @override
  String get selectTableDropdownHint => 'एक टेबल चुनें';

  @override
  String get pickContactTitle => 'एक संपर्क चुनें';

  @override
  String get permissionRequiredText => 'अनुमति आवश्यक है';

  @override
  String get grantPermissionButtonLabel => 'अनुमति दें';

  @override
  String get pageDummyTitle => 'पेज डमी';

  @override
  String get simulateButtonLabel => 'सिम्युलेट करें';

  @override
  String get selectCategoryTitle => 'श्रेणी चुनें';

  @override
  String get addCategoryTitle => 'श्रेणी जोड़ें';

  @override
  String get editCategoryTitle => 'श्रेणी संपादित करें';

  @override
  String get categoryTitleHint => 'श्रेणी का शीर्षक';

  @override
  String get colorLabel => 'रंग';

  @override
  String get changeColorLabel => 'रंग बदलें';

  @override
  String get deviceDisabledMessage => 'डिवाइस अक्षम है!';

  @override
  String get cannotRemoveThisDeviceMessage => 'इस डिवाइस को नहीं हटा सकते!';

  @override
  String get confirmRemoveTitle => 'हटाने की पुष्टि करें';

  @override
  String get confirmRemoveDeviceContent => 'क्या आप सुनिश्चित हैं? यह डिवाइस पर मौजूद सभी डेटा को हटा देगा।';

  @override
  String get okButtonLabel => 'ठीक है';

  @override
  String get registeredDevicesTitle => 'पंजीकृत डिवाइस';

  @override
  String get noDevicesFoundMessage => 'कोई डिवाइस नहीं मिला';

  @override
  String get enabledLabel => 'सक्षम';

  @override
  String get disabledLabel => 'अक्षम';

  @override
  String get migratingMediaTitle => 'मीडिया माइग्रेट हो रहा है';

  @override
  String get processingMessage => 'प्रक्रिया चल रही है...';

  @override
  String get doNotNavigateAwayMessage => 'कृपया दूर न जाएं';

  @override
  String errorWithDetails(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get sequenceNotAcceptedError => 'अनुक्रम स्वीकृत नहीं है';

  @override
  String get examplesNotAcceptedError => 'उदाहरण स्वीकृत नहीं हैं';

  @override
  String get enterKeyAgainLabel => 'कुंजी फिर से दर्ज करें';

  @override
  String get pleaseEnterKeyAgainError => 'कृपया कुंजी फिर से दर्ज करें';

  @override
  String get keysDoNotMatchError => 'कुंजियाँ मेल नहीं खाती हैं';

  @override
  String get ruleUppercaseLetter => '1 अपरकेस अक्षर';

  @override
  String get ruleLowercaseLetter => '1 लोअरकेस अक्षर';

  @override
  String get ruleNumericLetter => '1 संख्यात्मक अक्षर';

  @override
  String get ruleSpecialCharacter => '1 विशेष वर्ण';

  @override
  String get ruleMinTenCharacters => 'न्यूनतम 10 वर्ण';

  @override
  String get examplesTitle => 'उदाहरण';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => 'समझ गया';

  @override
  String get encryptionKeyTitle => 'एन्क्रिप्शन कुंजी';

  @override
  String get createKeyDescription => 'कृपया एक लंबी और अनुमान लगाने में कठिन कुंजी (पासवर्ड) दर्ज करें। इसे कहीं सुरक्षित रखना याद रखें। यदि यह खो जाती है या भूल जाते हैं, तो इसे पुनर्प्राप्त नहीं किया जा सकता है।';

  @override
  String get seeExamplesTooltip => 'उदाहरण देखें';

  @override
  String get couldNotFetchDetailsMessage => 'विवरण प्राप्त नहीं किया जा सका';

  @override
  String get retryButtonLabel => 'पुनः प्रयास करें';

  @override
  String get signedInAsLabel => 'लॉग इन किया गया:';

  @override
  String get storageUsageLabel => 'स्टोरेज उपयोग';

  @override
  String get subscribeLabel => 'सब्सक्राइब करें';

  @override
  String get planExpiredRenewLabel => 'प्लान समाप्त हो गया! रिन्यू करें';

  @override
  String get manageDevicesLabel => 'डिवाइस प्रबंधित करें';

  @override
  String get viewAccessKeyLabel => 'एक्सेस कुंजी देखें';

  @override
  String get changeKeyPasswordLabel => 'कुंजी पासवर्ड बदलें';

  @override
  String get manageSubscriptionLabel => 'सब्सक्रिप्शन प्रबंधित करें';

  @override
  String get signOutButtonLabel => 'साइन आउट करें';

  @override
  String get yearlyPlansTitle => 'वार्षिक प्लान';

  @override
  String get loginLabel => 'लॉग इन';

  @override
  String get syncAllYourNotesLabel => 'अपने सभी नोट्स सिंक करें';

  @override
  String get acrossYourDevicesLabel => 'अपने सभी डिवाइस पर';

  @override
  String get featureEndToEndEncryption => 'एंड-टू-एंड एन्क्रिप्शन';

  @override
  String get featureSyncUpTo3Devices => '3 डिवाइस तक सिंक करें';

  @override
  String get featureUpgradeCancelAnytime => 'कभी भी अपग्रेड/रद्द करें';

  @override
  String get noPlansAvailableMessage => 'कोई प्लान उपलब्ध नहीं है';

  @override
  String get downloadAppSubscribeLabel => 'ऐप डाउनलोड करें और सब्सक्राइब करें';

  @override
  String get privacyTermsLabel => 'गोपनीयता • शर्तें';

  @override
  String get saveFiftyPercentLabel => '50% बचाएं';

  @override
  String get helloTitle => 'नमस्ते';

  @override
  String get selectKeyMasterKeyDescription => 'अपने डेटा को एन्क्रिप्ट करने के लिए, हमें एक मास्टर एन्क्रिप्शन कुंजी की आवश्यकता होगी।';

  @override
  String get selectKeyTwoOptionsDescription => '2 विकल्प हैं - या तो आप स्वयं एक कुंजी बनाएं (पासवर्ड के समान) या हम आपके लिए इसे बनाएं।';

  @override
  String get understandLoseKeyAcknowledgement => 'मैं समझता हूँ कि यदि मैं एन्क्रिप्शन कुंजी खो देता हूँ/भूल जाता हूँ, तो मैं डेटा खो सकता हूँ।';

  @override
  String get createKeyForMeButtonLabel => 'मेरे लिए कुंजी बनाएं';

  @override
  String get recommendedLabel => '(अनुशंसित)';

  @override
  String get pleaseAcknowledgeMessage => 'कृपया स्वीकार करें!';

  @override
  String get createKeyMyselfButtonLabel => 'मैं स्वयं कुंजी बनाऊंगा';

  @override
  String welcomeToAppName(String appName) {
    return '$appName में आपका स्वागत है';
  }

  @override
  String get e2eEncryptionDescription => 'हम यह सुनिश्चित करने के लिए एंड-टू-एंड एन्क्रिप्शन का उपयोग करते हैं कि आपके सभी नोट्स सुरक्षित हैं और कोई और उन्हें नहीं देख सकता है, यहाँ तक कि हम भी नहीं।';

  @override
  String get timeToStartEncryptionLabel => 'एन्क्रिप्शन शुरू करने का समय!';

  @override
  String get nextButtonLabel => 'अगला';

  @override
  String get sendingOtpFailedMessage => 'OTP भेजने में विफल। कृपया पुनः प्रयास करें!';

  @override
  String get otpVerificationFailedMessage => 'OTP सत्यापन विफल। कृपया पुनः प्रयास करें!';

  @override
  String get emailSignInTitle => 'ईमेल साइन इन';

  @override
  String get verifyOtpLabel => 'OTP सत्यापित करें';

  @override
  String get enterEmailLabel => 'ईमेल दर्ज करें';

  @override
  String get sendOtpLabel => 'OTP भेजें';

  @override
  String otpSentToEmailMessage(String email) {
    return 'हमने आपके ईमेल $email पर एक वन-टाइम पासवर्ड (OTP) भेजा है';
  }

  @override
  String get enterOtpLabel => 'OTP दर्ज करें';

  @override
  String get changeEmailLabel => 'ईमेल बदलें';

  @override
  String get encryptingNotesTitle => 'नोट्स एन्क्रिप्ट किए जा रहे हैं';

  @override
  String get fetchingDetailsTitle => 'विवरण प्राप्त किया जा रहा है';

  @override
  String get couldNotFetchMessage => 'प्राप्त नहीं किया जा सका';

  @override
  String get subscriptionEmailMismatchMessage => 'आपकी सदस्यता किसी अन्य ईमेल से जुड़ी है। कृपया साइन आउट करें और क्लाउड स्टोरेज सक्षम करने के लिए उसका उपयोग करें।';

  @override
  String get errorCheckingPlanDetailsMessage => 'प्लान विवरण की जांच करने में त्रुटि';

  @override
  String get registerDeviceTitle => 'डिवाइस पंजीकृत करें';

  @override
  String get manageButtonLabel => 'प्रबंधित करें';

  @override
  String get fetchingKeysTitle => 'कुंजियाँ प्राप्त की जा रही हैं';

  @override
  String get signingOutTitle => 'साइन आउट किया जा रहा है';

  @override
  String get pleaseCheckInternetMessage => 'कृपया इंटरनेट की जांच करें';

  @override
  String get somethingWentWrongMessage => 'कुछ गलत हो गया';

  @override
  String get playPauseTooltip => 'प्ले/पॉज';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => 'डाउनलोड करें';

  @override
  String get invalidAccessKey => 'अमान्य एक्सेस कुंजी';

  @override
  String get fileDoesNotContain24Words => 'फ़ाइल में सटीक 24 शब्द नहीं हैं।';

  @override
  String get errorReadingFile => 'फ़ाइल पढ़ने में त्रुटि';

  @override
  String get allLabel => 'सभी';

  @override
  String get logTypeDebug => 'डिबग (DEBUG)';

  @override
  String get logTypeError => 'त्रुटि (ERROR)';

  @override
  String get logTypeInfo => 'जानकारी (INFO)';

  @override
  String get logTypeWarning => 'चेतावनी (WARNING)';

  @override
  String get groupTitleHint => 'ग्रुप का शीर्षक';

  @override
  String get categoryLabel => 'श्रेणी';

  @override
  String get selectCategoryPlaceholder => 'श्रेणी चुनें';

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
  String get searchHint => 'क्वेरी, #document आदि..';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => 'ऑडियो फ़ाइल';

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
  String get selectLanguageTitle => 'भाषा चुनें';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get themeLabel => 'थीम';

  @override
  String get dayNightThemeTooltip => 'डे/नाइट थीम';

  @override
  String get lockLabel => 'लॉक';

  @override
  String get timeFormatLabel => 'समय प्रारूप';

  @override
  String get h12Label => '12-घंटे';

  @override
  String get h24Label => '24-घंटे';

  @override
  String get fontSizeLabel => 'फ़ॉन्ट साइज़';

  @override
  String get reduceTextSizeTooltip => 'टेक्स्ट का आकार घटाएं';

  @override
  String get increaseTextSizeTooltip => 'टेक्स्ट का आकार बढ़ाएं';

  @override
  String get languageLabel => 'भाषा';

  @override
  String get autoOpenGroupLabel => 'ऑटो-ओपन ग्रुप';

  @override
  String get selectGroupTitle => 'ग्रुप चुनें';

  @override
  String shareAppMessage(String appName, String appLink) {
    return 'एक $appName बनाएं: $appLink';
  }

  @override
  String get noteTypeEmpty => 'खाली';

  @override
  String get noteTypeImage => 'छवि';

  @override
  String get noteTypeVideo => 'वीडियो';

  @override
  String get noteTypeAudio => 'ऑडियो';

  @override
  String get noteTypeDocument => 'दस्तावेज़';

  @override
  String get noteTypeContact => 'संपर्क';

  @override
  String get noteTypeLocation => 'स्थान';

  @override
  String get noteTypeUnknown => 'अज्ञात';

  @override
  String get pleaseEnterData => 'कृपया डेटा दर्ज करें';

  @override
  String get aNumber => 'एक संख्या';

  @override
  String get enterDataLabel => 'डेटा दर्ज करें';

  @override
  String get pleaseEnterValidData => 'कृपया मान्य डेटा दर्ज करें';

  @override
  String get pleaseSelectAnOption => 'कृपया एक विकल्प चुनें';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => 'आज';

  @override
  String get yesterdayLabel => 'कल';

  @override
  String get mondayLabel => 'सोमवार';

  @override
  String get tuesdayLabel => 'मंगलवार';

  @override
  String get wednesdayLabel => 'बुधवार';

  @override
  String get thursdayLabel => 'गुरुवार';

  @override
  String get fridayLabel => 'शुक्रवार';

  @override
  String get saturdayLabel => 'शनिवार';

  @override
  String get sundayLabel => 'रविवार';

  @override
  String get januaryShortLabel => 'जन';

  @override
  String get februaryShortLabel => 'फ़र';

  @override
  String get marchShortLabel => 'मार्च';

  @override
  String get aprilShortLabel => 'अप्रैल';

  @override
  String get mayShortLabel => 'मई';

  @override
  String get juneShortLabel => 'जून';

  @override
  String get julyShortLabel => 'जुलाई';

  @override
  String get augustShortLabel => 'अगस्त';

  @override
  String get septemberShortLabel => 'सितंबर';

  @override
  String get octoberShortLabel => 'अक्टूबर';

  @override
  String get novemberShortLabel => 'नवंबर';

  @override
  String get decemberShortLabel => 'दिसंबर';

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
    return '$count नोट ग्रुप';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count नोट ग्रुप्स';
  }

  @override
  String get seedCategoryTasks => 'कार्य';

  @override
  String get seedGroupNotes => 'नोट्स';

  @override
  String get seedGroupFitness => 'फिटनेस';

  @override
  String get seedItemWelcome => 'Note Safe में आपका स्वागत है!\nअपने विचार, लिस्ट या जो भी आपके मन में हो, यहाँ लिखें।\n\nइस नोट को डिलीट, एडिट या अन्य विकल्पों के लिए लॉन्ग प्रेस करें।';

  @override
  String get seedItemMorningWorkout => 'सुबह की कसरत';

  @override
  String get seedItemMeditation => '10 मिनट का ध्यान';

  @override
  String get seedItemWater => 'दिन भर में 2 लीटर पानी';

  @override
  String get seedItemSteps => '10,000 कदम चलें';
}

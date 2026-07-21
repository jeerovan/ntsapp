// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get importantTitle => 'สำคัญ';

  @override
  String get accessKeyNoticeDescription1 => 'ในหน้าถัดไป คุณจะเห็นคำ 24 คำ นี่คือคีย์การเข้ารหัสลับเฉพาะตัวและเป็นส่วนตัวของคุณ ซึ่งเป็นวิธีเดียวในการกู้คืนบันทึกของคุณในกรณีที่คุณออกจากระบบ อุปกรณ์หาย หรืออุปกรณ์ทำงานผิดปกติ';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return 'เราไม่ได้จัดเก็บคีย์นี้ไว้ เป็นความรับผิดชอบของคุณที่จะต้องเก็บคีย์นี้ไว้ในที่ปลอดภัยภายนอกแอป $appName';
  }

  @override
  String get iUnderstandShowMeTheKey => 'ฉันเข้าใจแล้ว\nแสดงคีย์ให้ฉันดู';

  @override
  String get selectGroupToViewNotes => 'เลือกกลุ่มเพื่อดูบันทึก';

  @override
  String get accessKeyShareText => 'นี่คือคีย์เข้าถึงของคุณ';

  @override
  String get pleaseTryAgain => 'โปรดลองใหม่อีกครั้ง';

  @override
  String get copiedToClipboard => 'คัดลอกไปยังคลิปบอร์ดแล้ว';

  @override
  String get accessKeyTitle => 'คีย์เข้าถึง';

  @override
  String get accessKeyDescription => 'โปรดบันทึกคีย์นี้ไว้ในที่ปลอดภัย คุณจะต้องใช้เพื่อซิงค์บันทึกบนอุปกรณ์อื่น';

  @override
  String get copyLabel => 'คัดลอก';

  @override
  String get downloadAsTextFileLabel => 'ดาวน์โหลดเป็นไฟล์ข้อความ';

  @override
  String get continueLabel => 'ดำเนินการต่อ';

  @override
  String get pleaseAuthenticate => 'โปรดยืนยันตัวตน';

  @override
  String get couldNotCreate => 'ไม่สามารถสร้างได้';

  @override
  String get couldNotShareFile => 'ไม่สามารถแชร์ไฟล์ได้';

  @override
  String get hereIsTheBackupFile => 'นี่คือไฟล์สำรองข้อมูลสำหรับแอปของคุณ';

  @override
  String get errorTitle => 'ข้อผิดพลาด';

  @override
  String get backupLabel => 'สำรองข้อมูล';

  @override
  String get restoreLabel => 'กู้คืน';

  @override
  String get leaveAReviewLabel => 'รีวิวแอป';

  @override
  String get shareLabel => 'แชร์';

  @override
  String get desktopAppLinkLabel => 'แอปเดสก์ท็อป';

  @override
  String get loggingLabel => 'การบันทึกข้อมูล (Logging)';

  @override
  String versionLabel(String version) {
    return 'เวอร์ชัน: $version';
  }

  @override
  String get loadingLabel => 'กำลังโหลด...';

  @override
  String get restoredLabel => 'กู้คืนแล้ว';

  @override
  String get deletedPermanentlyLabel => 'ลบถาวรแล้ว';

  @override
  String get mediaTitle => 'สื่อ';

  @override
  String get invalidWordList => 'รายการคำไม่ถูกต้อง';

  @override
  String get enterYour24WordPhrase => 'ป้อนวลีกู้คืน 24 คำของคุณ';

  @override
  String get enterYourRecoveryPhraseHere => 'ป้อนวลีกู้คืนของคุณที่นี่';

  @override
  String get pleaseEnterYourRecoveryPhrase => 'โปรดป้อนวลีกู้คืนของคุณ';

  @override
  String get recoveryPhraseMustContain24Words => 'วลีกู้คืนต้องมี 24 คำพอดี';

  @override
  String get submitLabel => 'ส่ง';

  @override
  String get orLabel => 'หรือ';

  @override
  String get selectTxtFileLabel => 'เลือกไฟล์ .txt';

  @override
  String get failureTitle => 'ไม่สำเร็จ';

  @override
  String get invalidPasswordKey => 'คีย์รหัสผ่านไม่ถูกต้อง';

  @override
  String get enableSyncTitle => 'เปิดใช้งานการซิงค์';

  @override
  String get passwordRequirementsDescription => 'โปรดป้อนคีย์ (รหัสผ่าน) ที่คุณสร้างไว้ ต้องมีความยาวอย่างน้อย 10 ตัวอักษร ประกอบด้วยตัวเลข 1 ตัว ตัวพิมพ์เล็ก 1 ตัว ตัวพิมพ์ใหญ่ 1 ตัว และอักขระพิเศษ 1 ตัว';

  @override
  String get enterKeyLabel => 'ป้อนคีย์';

  @override
  String get pleaseEnterKey => 'โปรดป้อนคีย์';

  @override
  String get filterNotesTitle => 'กรองบันทึก';

  @override
  String get filterPinnedNotesTooltip => 'กรองบันทึกที่ปักหมุด';

  @override
  String get filterStarredNotesTooltip => 'กรองบันทึกที่ติดดาว';

  @override
  String get filterTextNotesTooltip => 'กรองบันทึกข้อความ';

  @override
  String get filterTasksTooltip => 'กรองรายการสิ่งที่ต้องทำ';

  @override
  String get filterLinksTooltip => 'กรองลิงก์';

  @override
  String get filterImagesTooltip => 'กรองรูปภาพ';

  @override
  String get filterAudioTooltip => 'กรองเสียง';

  @override
  String get filterVideoTooltip => 'กรองวิดีโอ';

  @override
  String get filterFilesTooltip => 'กรองไฟล์';

  @override
  String get filterContactsTooltip => 'กรองรายชื่อติดต่อ';

  @override
  String get filterLocationTooltip => 'กรองตำแหน่งที่ตั้ง';

  @override
  String get movedToTrash => 'ย้ายไปที่ถังขยะแล้ว';

  @override
  String get copiedNotesToClipboard => 'คัดลอกไปยังคลิปบอร์ดแล้ว';

  @override
  String get locationShareLabel => 'ตำแหน่งที่ตั้ง:';

  @override
  String get contactShareLabel => 'รายชื่อติดต่อ:';

  @override
  String get emailsShareLabel => 'อีเมล:';

  @override
  String get addressesShareLabel => 'ที่อยู่:';

  @override
  String get microphoneNotAvailable => 'ไมโครโฟนอาจไม่พร้อมใช้งาน';

  @override
  String get microphonePermissionRequired => 'จำเป็นต้องได้รับอนุญาตให้ใช้ไมโครโฟนเพื่อบันทึกเสียง';

  @override
  String get couldNotGetDuration => 'ไม่สามารถระบุระยะเวลาได้';

  @override
  String get errorOpeningFiles => 'เกิดข้อผิดพลาดขณะเปิดไฟล์';

  @override
  String get pleaseWaitTitle => 'โปรดรอสักครู่';

  @override
  String get fileNotAvailableYet => 'ไฟล์ยังไม่พร้อมใช้งาน';

  @override
  String get clearSelectionTooltip => 'ล้างการเลือก';

  @override
  String get copyNotesTooltip => 'คัดลอกบันทึก';

  @override
  String get changeTaskTypeTooltip => 'เปลี่ยนประเภทงาน';

  @override
  String get shareNotesTooltip => 'แชร์บันทึก';

  @override
  String get editNoteTooltip => 'แก้ไขบันทึก';

  @override
  String get starUnstarNotesTooltip => 'ติดดาว/เลิกติดดาวบันทึก';

  @override
  String get moveToTrashTooltip => 'ย้ายไปถังขยะ';

  @override
  String get pinUnpinNotesTooltip => 'ปักหมุด/เลิกปักหมุดบันทึก';

  @override
  String get cancelReplyTooltip => 'ยกเลิกรายการตอบกลับ';

  @override
  String get createTaskHint => 'สร้างงาน';

  @override
  String get addNoteHint => 'เพิ่มบันทึก...';

  @override
  String get attachTooltip => 'แนบไฟล์';

  @override
  String get addNoteTooltip => 'เพิ่มบันทึก';

  @override
  String get recordStopAudioTooltip => 'บันทึก/หยุดบันทึกเสียง';

  @override
  String get contactAttachmentLabel => 'รายชื่อติดต่อ';

  @override
  String get locationAttachmentLabel => 'ตำแหน่งที่ตั้ง';

  @override
  String get cameraAttachmentLabel => 'กล้องถ่ายรูป';

  @override
  String get filesAttachmentLabel => 'ไฟล์';

  @override
  String get checklistAttachmentLabel => 'รายการตรวจสอบ';

  @override
  String get accessKeyInputTitle => 'เปิดใช้งานการซิงค์';

  @override
  String get accessKeyInputDescription => 'โปรดป้อนวลีกู้คืน 24 คำของคุณ หรือโหลดไฟล์ .txt ที่มีวลีดังกล่าว';

  @override
  String get editMenuItemLabel => 'แก้ไข';

  @override
  String get filterMenuItemLabel => 'ตัวกรอง';

  @override
  String get externalStoragePermissionDenied => 'ถูกปฏิเสธสิทธิ์ในการเข้าถึงที่จัดเก็บข้อมูลภายนอก';

  @override
  String get pressLongToStartRecording => 'กดค้างเพื่อเริ่มบันทึก';

  @override
  String get didYouKnowTitle => 'คุณรู้หรือไม่?';

  @override
  String get closeTooltip => 'ปิด';

  @override
  String appDescriptionContent(String appName) {
    return '$appName เป็นแอปบันทึกข้อมูลที่เป็นส่วนตัวโดยสมบูรณ์ ไม่มีการรวบรวมข้อมูลส่วนบุคคลของคุณและไม่มีโฆษณาคั่น\n\nเราหวังว่าคุณจะชอบการใช้งาน บอกให้เรารู้ว่าคุณคิดอย่างไร';
  }

  @override
  String get searchNotesTooltip => 'ค้นหาบันทึก';

  @override
  String get syncMenuItemLabel => 'ซิงค์';

  @override
  String get trashMenuItemLabel => 'ถังขยะ';

  @override
  String get starredNotesMenuItemLabel => 'บันทึกที่ติดดาว';

  @override
  String get settingsMenuItemLabel => 'การตั้งค่า';

  @override
  String get accountMenuItemLabel => 'บัญชี';

  @override
  String get pageMenuItemLabel => 'หน้า';

  @override
  String get sqliteMenuItemLabel => 'Sqlite';

  @override
  String get logsMenuItemLabel => 'บันทึกข้อมูล (Logs)';

  @override
  String get reorderMenuItemLabel => 'จัดเรียงใหม่';

  @override
  String get editGroupMenuItemLabel => 'แก้ไข';

  @override
  String get deleteGroupMenuItemLabel => 'ลบ';

  @override
  String get dragHandleReorderTooltip => 'ลากเพื่อจัดเรียงใหม่';

  @override
  String get holdAndDragReorderTooltip => 'กดค้างและลากเพื่อจัดเรียงใหม่';

  @override
  String get emptyHomePageMessage => 'สวัสดี!\n\nที่นี่ดูว่างเปล่าจัง\n\nแตะที่ปุ่ม + เพื่อสร้างบันทึกส่วนตัวได้เลย :)';

  @override
  String get reorderingTitle => 'กำลังจัดเรียงใหม่';

  @override
  String get selectEllipsisLabel => 'เลือก...';

  @override
  String get dateTimeToggleLabel => 'วันที่/เวลา';

  @override
  String get noteBorderToggleLabel => 'ขอบบันทึก';

  @override
  String get deleteGroupButtonLabel => 'ลบ';

  @override
  String get notesTabLabel => 'บันทึก';

  @override
  String get groupsTabLabel => 'กลุ่ม';

  @override
  String get categoriesTabLabel => 'หมวดหมู่';

  @override
  String get locationItemLabel => 'ตำแหน่งที่ตั้ง';

  @override
  String get addGroupTitle => 'เพิ่มกลุ่ม';

  @override
  String get editGroupTitle => 'แก้ไขกลุ่ม';

  @override
  String get titleInputLabel => 'ชื่อเรื่อง';

  @override
  String get locationPermissionRequiredTitle => 'ต้องได้รับอนุญาตตำแหน่งที่ตั้ง';

  @override
  String get enableLocationPermissionsContent => 'โปรดเปิดใช้งานสิทธิ์เข้าถึงตำแหน่งที่ตั้งในการตั้งค่าแอป';

  @override
  String get cancelButtonLabel => 'ยกเลิก';

  @override
  String get openSettingsButtonLabel => 'เปิดการตั้งค่า';

  @override
  String get locationServicesTitle => 'บริการตำแหน่งที่ตั้ง';

  @override
  String get pleaseEnableLocationServicesContent => 'โปรดเปิดใช้งาน!';

  @override
  String get selectLocationTitle => 'เลือกตำแหน่งที่ตั้ง';

  @override
  String get useCurrentLocationTooltip => 'ใช้ตำแหน่งปัจจุบัน';

  @override
  String get selectAllButtonLabel => 'เลือกทั้งหมด';

  @override
  String get searchLogsHint => 'ค้นหาบันทึกข้อมูล...';

  @override
  String get noLogsAvailable => 'ไม่มีบันทึกข้อมูล';

  @override
  String get dbViewerTitle => 'โปรแกรมดูฐานข้อมูล (DB Viewer)';

  @override
  String get selectTableToViewData => 'เลือกตารางเพื่อดูข้อมูล';

  @override
  String get selectTableDropdownHint => 'เลือกตาราง';

  @override
  String get pickContactTitle => 'เลือกรรายชื่อติดต่อ';

  @override
  String get permissionRequiredText => 'จำเป็นต้องได้รับอนุญาต';

  @override
  String get grantPermissionButtonLabel => 'ให้สิทธิ์';

  @override
  String get pageDummyTitle => 'หน้าทดสอบ (Dummy)';

  @override
  String get simulateButtonLabel => 'จำลอง';

  @override
  String get selectCategoryTitle => 'เลือกหมวดหมู่';

  @override
  String get addCategoryTitle => 'เพิ่มหมวดหมู่';

  @override
  String get editCategoryTitle => 'แก้ไขหมวดหมู่';

  @override
  String get categoryTitleHint => 'ชื่อหมวดหมู่';

  @override
  String get colorLabel => 'สี';

  @override
  String get changeColorLabel => 'เปลี่ยนสี';

  @override
  String get deviceDisabledMessage => 'อุปกรณ์ถูกปิดใช้งาน!';

  @override
  String get cannotRemoveThisDeviceMessage => 'ไม่สามารถนำอุปกรณ์นี้ออกได้!';

  @override
  String get confirmRemoveTitle => 'ยืนยันการนำออก';

  @override
  String get confirmRemoveDeviceContent => 'คุณแน่ใจหรือไม่? การดำเนินการนี้จะลบข้อมูลทั้งหมดบนอุปกรณ์ดังกล่าว';

  @override
  String get okButtonLabel => 'ตกลง';

  @override
  String get registeredDevicesTitle => 'อุปกรณ์ที่ลงทะเบียน';

  @override
  String get noDevicesFoundMessage => 'ไม่พบอุปกรณ์';

  @override
  String get enabledLabel => 'เปิดใช้งาน';

  @override
  String get disabledLabel => 'ปิดใช้งาน';

  @override
  String get migratingMediaTitle => 'กำลังย้ายข้อมูลสื่อ';

  @override
  String get processingMessage => 'กำลังประมวลผล...';

  @override
  String get doNotNavigateAwayMessage => 'โปรดอย่าเปลี่ยนหน้าจอ';

  @override
  String errorWithDetails(String error) {
    return 'ข้อผิดพลาด: $error';
  }

  @override
  String get sequenceNotAcceptedError => 'ลำดับรูปแบบนี้ไม่ได้รับอนุญาต';

  @override
  String get examplesNotAcceptedError => 'รูปแบบนี้ไม่ได้รับอนุญาต';

  @override
  String get enterKeyAgainLabel => 'ป้อนคีย์อีกครั้ง';

  @override
  String get pleaseEnterKeyAgainError => 'โปรดป้อนคีย์อีกครั้ง';

  @override
  String get keysDoNotMatchError => 'คีย์ไม่ตรงกัน';

  @override
  String get ruleUppercaseLetter => 'ตัวพิมพ์ใหญ่ 1 ตัว';

  @override
  String get ruleLowercaseLetter => 'ตัวพิมพ์เล็ก 1 ตัว';

  @override
  String get ruleNumericLetter => 'ตัวเลข 1 ตัว';

  @override
  String get ruleSpecialCharacter => 'อักขระพิเศษ 1 ตัว';

  @override
  String get ruleMinTenCharacters => 'อย่างน้อย 10 ตัวอักษร';

  @override
  String get examplesTitle => 'ตัวอย่าง';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => 'เข้าใจแล้ว';

  @override
  String get encryptionKeyTitle => 'คีย์การเข้ารหัส';

  @override
  String get createKeyDescription => 'โปรดป้อนคีย์ (รหัสผ่าน) ที่ยาวและเดาได้ยาก อย่าลืมบันทึกไว้ในที่ปลอดภัย หากทำหายหรือลืม จะไม่สามารถกู้คืนได้';

  @override
  String get seeExamplesTooltip => 'ดูตัวอย่าง';

  @override
  String get couldNotFetchDetailsMessage => 'ไม่สามารถดึงรายละเอียดได้';

  @override
  String get retryButtonLabel => 'ลองใหม่';

  @override
  String get signedInAsLabel => 'ลงชื่อเข้าใช้ด้วย:';

  @override
  String get storageUsageLabel => 'การใช้พื้นที่จัดเก็บ';

  @override
  String get subscribeLabel => 'สมัครสมาชิก';

  @override
  String get planExpiredRenewLabel => 'แผนหมดอายุ! ต่ออายุ';

  @override
  String get manageDevicesLabel => 'จัดการอุปกรณ์';

  @override
  String get viewAccessKeyLabel => 'ดูคีย์เข้าถึง';

  @override
  String get changeKeyPasswordLabel => 'เปลี่ยนรหัสผ่านคีย์';

  @override
  String get manageSubscriptionLabel => 'จัดการการสมัครสมาชิก';

  @override
  String get signOutButtonLabel => 'ลงชื่อออก';

  @override
  String get yearlyPlansTitle => 'แผนรายปี';

  @override
  String get loginLabel => 'เข้าสู่ระบบ';

  @override
  String get syncAllYourNotesLabel => 'ซิงค์บันทึกทั้งหมดของคุณ';

  @override
  String get acrossYourDevicesLabel => 'ข้ามอุปกรณ์ของคุณ';

  @override
  String get featureEndToEndEncryption => 'การเข้ารหัสลับแบบต้นทางถึงปลายทาง (End-to-end Encryption)';

  @override
  String get featureSyncUpTo3Devices => 'ซิงค์สูงสุด 3 อุปกรณ์';

  @override
  String get featureUpgradeCancelAnytime => 'อัปเกรด/ยกเลิกได้ตลอดเวลา';

  @override
  String get noPlansAvailableMessage => 'ไม่มีแผนบริการพร้อมใช้งาน';

  @override
  String get downloadAppSubscribeLabel => 'ดาวน์โหลดแอปและสมัครสมาชิก';

  @override
  String get privacyTermsLabel => 'ความเป็นส่วนตัว • ข้อกำหนด';

  @override
  String get saveFiftyPercentLabel => 'ประหยัด 50%';

  @override
  String get helloTitle => 'สวัสดี';

  @override
  String get selectKeyMasterKeyDescription => 'ในการเข้ารหัสลับข้อมูลของคุณ เราจำเป็นต้องใช้คีย์เข้ารหัสหลัก';

  @override
  String get selectKeyTwoOptionsDescription => 'มี 2 ตัวเลือก คือ คุณสร้างคีย์ด้วยตัวเอง (คล้ายรหัสผ่าน) หรือให้เราสร้างให้คุณ';

  @override
  String get understandLoseKeyAcknowledgement => 'ฉันเข้าใจว่าหากฉันทำคีย์เข้ารหัสหายหรือลืมรหัสไป ฉันอาจสูญเสียข้อมูลทั้งหมด';

  @override
  String get createKeyForMeButtonLabel => 'ให้ฉันสร้างคีย์ให้';

  @override
  String get recommendedLabel => '(แนะนำ)';

  @override
  String get pleaseAcknowledgeMessage => 'โปรดกดยอมรับ!';

  @override
  String get createKeyMyselfButtonLabel => 'ฉันจะสร้างคีย์เอง';

  @override
  String welcomeToAppName(String appName) {
    return 'ยินดีต้อนรับสู่ $appName';
  }

  @override
  String get e2eEncryptionDescription => 'เราใช้การเข้ารหัสลับแบบต้นทางถึงปลายทางเพื่อให้แน่ใจว่าบันทึกทั้งหมดของคุณปลอดภัย และไม่มีใครคนอื่นเห็นได้ แม้แต่เราเอง';

  @override
  String get timeToStartEncryptionLabel => 'ได้เวลาเริ่มการเข้ารหัสแล้ว!';

  @override
  String get nextButtonLabel => 'ถัดไป';

  @override
  String get sendingOtpFailedMessage => 'การส่ง OTP ล้มเหลว โปรดลองใหม่อีกครั้ง!';

  @override
  String get otpVerificationFailedMessage => 'การยืนยัน OTP ล้มเหลว โปรดลองใหม่อีกครั้ง!';

  @override
  String get emailSignInTitle => 'ลงชื่อเข้าใช้ด้วยอีเมล';

  @override
  String get verifyOtpLabel => 'ยืนยัน OTP';

  @override
  String get enterEmailLabel => 'ป้อนอีเมล';

  @override
  String get sendOtpLabel => 'ส่ง OTP';

  @override
  String otpSentToEmailMessage(String email) {
    return 'เราได้ส่งรหัสผ่านใช้ครั้งเดียว (OTP) ไปที่อีเมล $email ของคุณแล้ว';
  }

  @override
  String get enterOtpLabel => 'ป้อน OTP';

  @override
  String get changeEmailLabel => 'เปลี่ยนอีเมล';

  @override
  String get encryptingNotesTitle => 'กำลังเข้ารหัสบันทึก';

  @override
  String get fetchingDetailsTitle => 'กำลังดึงรายละเอียด';

  @override
  String get couldNotFetchMessage => 'ไม่สามารถดึงข้อมูลได้';

  @override
  String get subscriptionEmailMismatchMessage => 'การสมัครสมาชิกของคุณเชื่อมโยงกับอีเมลอื่น โปรดลงชื่อออกและใช้อีเมลนั้นเพื่อเปิดใช้งานระบบคลาวด์';

  @override
  String get errorCheckingPlanDetailsMessage => 'เกิดข้อผิดพลาดขณะตรวจสอบรายละเอียดแผน';

  @override
  String get registerDeviceTitle => 'ลงทะเบียนอุปกรณ์';

  @override
  String get manageButtonLabel => 'จัดการ';

  @override
  String get fetchingKeysTitle => 'กำลังดึงคีย์';

  @override
  String get signingOutTitle => 'กำลังลงชื่อออก';

  @override
  String get pleaseCheckInternetMessage => 'โปรดตรวจสอบการเชื่อมต่ออินเทอร์เน็ต';

  @override
  String get somethingWentWrongMessage => 'มีบางอย่างผิดพลาด';

  @override
  String get playPauseTooltip => 'เล่น/หยุดชั่วคราว';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => 'ดาวน์โหลด';

  @override
  String get invalidAccessKey => 'คีย์เข้าถึงไม่ถูกต้อง';

  @override
  String get fileDoesNotContain24Words => 'ไฟล์ไม่ได้มีคำ 24 คำ';

  @override
  String get errorReadingFile => 'เกิดข้อผิดพลาดในการอ่านไฟล์';

  @override
  String get allLabel => 'ทั้งหมด';

  @override
  String get logTypeDebug => 'DEBUG';

  @override
  String get logTypeError => 'ERROR';

  @override
  String get logTypeInfo => 'INFO';

  @override
  String get logTypeWarning => 'WARNING';

  @override
  String get groupTitleHint => 'ชื่อกลุ่ม';

  @override
  String get categoryLabel => 'หมวดหมู่';

  @override
  String get selectCategoryPlaceholder => 'เลือกหมวดหมู่';

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
  String get searchHint => 'ค้นหา...';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => 'ไฟล์เสียง';

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
  String get selectLanguageTitle => 'เลือกภาษา';

  @override
  String get settingsTitle => 'การตั้งค่า';

  @override
  String get themeLabel => 'ธีม';

  @override
  String get dayNightThemeTooltip => 'ธีมกลางวัน/กลางคืน';

  @override
  String get lockLabel => 'ล็อก';

  @override
  String get timeFormatLabel => 'รูปแบบเวลา';

  @override
  String get h12Label => '12 ชม.';

  @override
  String get h24Label => '24 ชม.';

  @override
  String get fontSizeLabel => 'ขนาดตัวอักษร';

  @override
  String get reduceTextSizeTooltip => 'ลดขนาดตัวอักษร';

  @override
  String get increaseTextSizeTooltip => 'เพิ่มขนาดตัวอักษร';

  @override
  String get languageLabel => 'ภาษา';

  @override
  String get autoOpenGroupLabel => 'เปิดกลุ่มอัตโนมัติ';

  @override
  String get selectGroupTitle => 'เลือกกลุ่ม';

  @override
  String shareAppMessage(String appName, String appLink) {
    return 'สร้าง $appName กัน: $appLink';
  }

  @override
  String get noteTypeEmpty => 'ว่างเปล่า';

  @override
  String get noteTypeImage => 'รูปภาพ';

  @override
  String get noteTypeVideo => 'วิดีโอ';

  @override
  String get noteTypeAudio => 'เสียง';

  @override
  String get noteTypeDocument => 'เอกสาร';

  @override
  String get noteTypeContact => 'รายชื่อติดต่อ';

  @override
  String get noteTypeLocation => 'ตำแหน่งที่ตั้ง';

  @override
  String get noteTypeUnknown => 'ไม่ทราบประเภท';

  @override
  String get pleaseEnterData => 'โปรดป้อนข้อมูล';

  @override
  String get aNumber => 'ตัวเลข';

  @override
  String get enterDataLabel => 'ป้อนข้อมูล';

  @override
  String get pleaseEnterValidData => 'โปรดป้อนข้อมูลที่ถูกต้อง';

  @override
  String get pleaseSelectAnOption => 'โปรดเลือกตัวเลือก';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => 'วันนี้';

  @override
  String get yesterdayLabel => 'เมื่อวาน';

  @override
  String get mondayLabel => 'วันจันทร์';

  @override
  String get tuesdayLabel => 'วันอังคาร';

  @override
  String get wednesdayLabel => 'วันพุธ';

  @override
  String get thursdayLabel => 'วันพฤหัสบดี';

  @override
  String get fridayLabel => 'วันศุกร์';

  @override
  String get saturdayLabel => 'วันเสาร์';

  @override
  String get sundayLabel => 'วันอาทิตย์';

  @override
  String get januaryShortLabel => 'ม.ค.';

  @override
  String get februaryShortLabel => 'ก.พ.';

  @override
  String get marchShortLabel => 'มี.ค.';

  @override
  String get aprilShortLabel => 'เม.ย.';

  @override
  String get mayShortLabel => 'พ.ค.';

  @override
  String get juneShortLabel => 'มิ.ย.';

  @override
  String get julyShortLabel => 'ก.ค.';

  @override
  String get augustShortLabel => 'ส.ค.';

  @override
  String get septemberShortLabel => 'ก.ย.';

  @override
  String get octoberShortLabel => 'ต.ค.';

  @override
  String get novemberShortLabel => 'พ.ย.';

  @override
  String get decemberShortLabel => 'ธ.ค.';

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
    return '$count กลุ่มบันทึก';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count กลุ่มบันทึก';
  }


  @override
  String get seedCategoryTasks => "งานที่ต้องทำ";

  @override
  String get seedGroupNotes => "บันทึก";

  @override
  String get seedGroupFitness => "ออกกำลังกาย";

  @override
  String get seedItemWelcome =>
      "ยินดีต้อนรับสู่ Note Safe!\nไม่ว่าจะเป็นไอเดีย รายการสิ่งที่ต้องทำ หรืออะไรก็ตามที่อยู่ในใจ เก็บไว้ที่นี่ได้เลย\n\nกดค้างที่บันทึกนี้เพื่อลบ แก้ไข หรือดูตัวเลือกอื่นๆ";

  @override
  String get seedItemMorningWorkout => "ออกกำลังกายตอนเช้า";

  @override
  String get seedItemMeditation => "ทำสมาธิ 10 นาที";

  @override
  String get seedItemWater => "ดื่มน้ำวันละ 2 ลิตร";

  @override
  String get seedItemSteps => "เดินให้ครบ 10,000 ก้าว";
}
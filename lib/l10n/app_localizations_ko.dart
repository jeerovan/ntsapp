// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get importantTitle => '중요';

  @override
  String get accessKeyNoticeDescription1 => '다음 페이지에는 24개의 단어가 표시됩니다. 이는 귀하만의 고유하고 비공개인 암호화 키이며, 로그아웃, 기기 분실 또는 오작동 시 노트를 복구할 수 있는 유일한 방법입니다.';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return '저희는 이 키를 저장하지 않습니다. $appName 앱 외부의 안전한 장소에 직접 보관하는 것은 귀하의 책임입니다.';
  }

  @override
  String get iUnderstandShowMeTheKey => '이해했습니다.\n키를 보여주세요.';

  @override
  String get selectGroupToViewNotes => '노트를 보려면 그룹을 선택하세요';

  @override
  String get accessKeyShareText => '귀하의 액세스 키입니다.';

  @override
  String get pleaseTryAgain => '다시 시도해 주세요.';

  @override
  String get copiedToClipboard => '클립보드에 복사되었습니다';

  @override
  String get accessKeyTitle => '액세스 키';

  @override
  String get accessKeyDescription => '이 키를 안전한 곳에 저장하세요. 다른 기기에서 노트를 동기화할 때 필요합니다.';

  @override
  String get copyLabel => '복사';

  @override
  String get downloadAsTextFileLabel => '텍스트 파일로 다운로드';

  @override
  String get continueLabel => '계속';

  @override
  String get pleaseAuthenticate => '인증해 주세요';

  @override
  String get couldNotCreate => '생성할 수 없습니다';

  @override
  String get couldNotShareFile => '파일을 공유할 수 없습니다';

  @override
  String get hereIsTheBackupFile => '앱 백업 파일입니다.';

  @override
  String get errorTitle => '오류';

  @override
  String get backupLabel => '백업';

  @override
  String get restoreLabel => '복원';

  @override
  String get leaveAReviewLabel => '리뷰 남기기';

  @override
  String get shareLabel => '공유';

  @override
  String get desktopAppLinkLabel => '데스크톱 앱';

  @override
  String get loggingLabel => '로깅';

  @override
  String versionLabel(String version) {
    return '버전: $version';
  }

  @override
  String get loadingLabel => '불러오는 중...';

  @override
  String get restoredLabel => '복원됨.';

  @override
  String get deletedPermanentlyLabel => '영구 삭제됨.';

  @override
  String get mediaTitle => '미디어';

  @override
  String get invalidWordList => '잘못된 단어 목록';

  @override
  String get enterYour24WordPhrase => '24개 단어 구문을 입력하세요';

  @override
  String get enterYourRecoveryPhraseHere => '복구 구문을 여기에 입력하세요';

  @override
  String get pleaseEnterYourRecoveryPhrase => '복구 구문을 입력해 주세요';

  @override
  String get recoveryPhraseMustContain24Words => '복구 구문은 정확히 24개의 단어여야 합니다';

  @override
  String get submitLabel => '제출';

  @override
  String get orLabel => '또는';

  @override
  String get selectTxtFileLabel => '.txt 파일 선택';

  @override
  String get failureTitle => '실패';

  @override
  String get invalidPasswordKey => '잘못된 비밀번호 키';

  @override
  String get enableSyncTitle => '동기화 활성화';

  @override
  String get passwordRequirementsDescription => '생성했던 키(비밀번호)를 입력하세요. 최소 10자 이상이며, 숫자, 소문자, 대문자, 특수 문자가 각각 하나 이상 포함되어야 합니다.';

  @override
  String get enterKeyLabel => '키 입력';

  @override
  String get pleaseEnterKey => '키를 입력해 주세요';

  @override
  String get filterNotesTitle => '노트 필터링';

  @override
  String get filterPinnedNotesTooltip => '고정된 노트 필터링';

  @override
  String get filterStarredNotesTooltip => '즐겨찾는 노트 필터링';

  @override
  String get filterTextNotesTooltip => '텍스트 노트 필터링';

  @override
  String get filterTasksTooltip => '할 일 필터링';

  @override
  String get filterLinksTooltip => '링크 필터링';

  @override
  String get filterImagesTooltip => '이미지 필터링';

  @override
  String get filterAudioTooltip => '오디오 필터링';

  @override
  String get filterVideoTooltip => '비디오 필터링';

  @override
  String get filterFilesTooltip => '파일 필터링';

  @override
  String get filterContactsTooltip => '연락처 필터링';

  @override
  String get filterLocationTooltip => '위치 필터링';

  @override
  String get movedToTrash => '휴지통으로 이동됨';

  @override
  String get copiedNotesToClipboard => '클립보드에 복사됨';

  @override
  String get locationShareLabel => '위치:';

  @override
  String get contactShareLabel => '연락처:';

  @override
  String get emailsShareLabel => '이메일:';

  @override
  String get addressesShareLabel => '주소:';

  @override
  String get microphoneNotAvailable => '마이크를 사용할 수 없습니다.';

  @override
  String get microphonePermissionRequired => '오디오 녹음을 위해 마이크 권한이 필요합니다.';

  @override
  String get couldNotGetDuration => '재생 시간을 가져올 수 없습니다';

  @override
  String get errorOpeningFiles => '파일을 여는 중 오류 발생';

  @override
  String get pleaseWaitTitle => '잠시만 기다려 주세요';

  @override
  String get fileNotAvailableYet => '아직 파일을 사용할 수 없습니다';

  @override
  String get clearSelectionTooltip => '선택 해제';

  @override
  String get copyNotesTooltip => '노트 복사';

  @override
  String get changeTaskTypeTooltip => '할 일 유형 변경';

  @override
  String get shareNotesTooltip => '노트 공유';

  @override
  String get editNoteTooltip => '노트 수정';

  @override
  String get starUnstarNotesTooltip => '즐겨찾기/해제';

  @override
  String get moveToTrashTooltip => '휴지통으로 이동';

  @override
  String get pinUnpinNotesTooltip => '고정/해제';

  @override
  String get cancelReplyTooltip => '답글 취소';

  @override
  String get createTaskHint => '할 일 생성';

  @override
  String get addNoteHint => '노트 추가...';

  @override
  String get attachTooltip => '첨부';

  @override
  String get addNoteTooltip => '노트 추가';

  @override
  String get recordStopAudioTooltip => '녹음 시작/중지';

  @override
  String get contactAttachmentLabel => '연락처';

  @override
  String get locationAttachmentLabel => '위치';

  @override
  String get cameraAttachmentLabel => '카메라';

  @override
  String get filesAttachmentLabel => '파일';

  @override
  String get checklistAttachmentLabel => '체크리스트';

  @override
  String get accessKeyInputTitle => '동기화 활성화';

  @override
  String get accessKeyInputDescription => '24개의 단어로 구성된 복구 구문을 입력하거나 파일이 포함된 .txt 파일을 로드하세요.';

  @override
  String get editMenuItemLabel => '수정';

  @override
  String get filterMenuItemLabel => '필터';

  @override
  String get externalStoragePermissionDenied => '외부 저장소에 접근할 권한이 거부되었습니다.';

  @override
  String get pressLongToStartRecording => '길게 눌러 녹음을 시작하세요.';

  @override
  String get didYouKnowTitle => '알고 계셨나요?';

  @override
  String get closeTooltip => '닫기';

  @override
  String appDescriptionContent(String appName) {
    return '$appName은 완전히 개인적인 노트 앱입니다. 개인 데이터를 수집하거나 광고를 표시하지 않습니다.\n\n앱을 즐겁게 사용하시길 바랍니다. 의견을 알려주세요.';
  }

  @override
  String get searchNotesTooltip => '노트 검색';

  @override
  String get syncMenuItemLabel => '동기화';

  @override
  String get trashMenuItemLabel => '휴지통';

  @override
  String get starredNotesMenuItemLabel => '즐겨찾는 노트';

  @override
  String get settingsMenuItemLabel => '설정';

  @override
  String get accountMenuItemLabel => '계정';

  @override
  String get pageMenuItemLabel => '페이지';

  @override
  String get sqliteMenuItemLabel => 'Sqlite';

  @override
  String get logsMenuItemLabel => '로그';

  @override
  String get reorderMenuItemLabel => '순서 변경';

  @override
  String get editGroupMenuItemLabel => '수정';

  @override
  String get deleteGroupMenuItemLabel => '삭제';

  @override
  String get dragHandleReorderTooltip => '드래그하여 순서 변경';

  @override
  String get holdAndDragReorderTooltip => '꾹 누르고 드래그하여 순서 변경';

  @override
  String get emptyHomePageMessage => '안녕하세요!\n\n여기가 텅 비어 있네요.\n\n+ 버튼을 눌러 노트를 작성해 보세요. :)';

  @override
  String get reorderingTitle => '순서 변경 중';

  @override
  String get selectEllipsisLabel => '선택 중...';

  @override
  String get dateTimeToggleLabel => '날짜/시간';

  @override
  String get noteBorderToggleLabel => '노트 테두리';

  @override
  String get deleteGroupButtonLabel => '삭제';

  @override
  String get notesTabLabel => '노트';

  @override
  String get groupsTabLabel => '그룹';

  @override
  String get categoriesTabLabel => '카테고리';

  @override
  String get locationItemLabel => '위치';

  @override
  String get addGroupTitle => '그룹 추가';

  @override
  String get editGroupTitle => '그룹 수정';

  @override
  String get titleInputLabel => '제목';

  @override
  String get locationPermissionRequiredTitle => '위치 권한 필요';

  @override
  String get enableLocationPermissionsContent => '앱 설정에서 위치 권한을 활성화해 주세요.';

  @override
  String get cancelButtonLabel => '취소';

  @override
  String get openSettingsButtonLabel => '설정 열기';

  @override
  String get locationServicesTitle => '위치 서비스';

  @override
  String get pleaseEnableLocationServicesContent => '활성화해 주세요!';

  @override
  String get selectLocationTitle => '위치 선택';

  @override
  String get useCurrentLocationTooltip => '현재 위치 사용';

  @override
  String get selectAllButtonLabel => '모두 선택';

  @override
  String get searchLogsHint => '로그 검색..';

  @override
  String get noLogsAvailable => '사용 가능한 로그 없음';

  @override
  String get dbViewerTitle => 'DB 뷰어';

  @override
  String get selectTableToViewData => '데이터를 보려면 테이블을 선택하세요';

  @override
  String get selectTableDropdownHint => '테이블 선택';

  @override
  String get pickContactTitle => '연락처 선택';

  @override
  String get permissionRequiredText => '권한 필요';

  @override
  String get grantPermissionButtonLabel => '권한 부여';

  @override
  String get pageDummyTitle => '페이지 더미';

  @override
  String get simulateButtonLabel => '시뮬레이션';

  @override
  String get selectCategoryTitle => '카테고리 선택';

  @override
  String get addCategoryTitle => '카테고리 추가';

  @override
  String get editCategoryTitle => '카테고리 수정';

  @override
  String get categoryTitleHint => '카테고리 제목';

  @override
  String get colorLabel => '색상';

  @override
  String get changeColorLabel => '색상 변경';

  @override
  String get deviceDisabledMessage => '기기 비활성화됨!';

  @override
  String get cannotRemoveThisDeviceMessage => '이 기기를 삭제할 수 없습니다!';

  @override
  String get confirmRemoveTitle => '삭제 확인';

  @override
  String get confirmRemoveDeviceContent => '정말 삭제하시겠습니까? 기기의 모든 데이터가 삭제됩니다.';

  @override
  String get okButtonLabel => '확인';

  @override
  String get registeredDevicesTitle => '등록된 기기';

  @override
  String get noDevicesFoundMessage => '발견된 기기 없음';

  @override
  String get enabledLabel => '활성화됨';

  @override
  String get disabledLabel => '비활성화됨';

  @override
  String get migratingMediaTitle => '미디어 마이그레이션 중';

  @override
  String get processingMessage => '처리 중...';

  @override
  String get doNotNavigateAwayMessage => '다른 화면으로 이동하지 마세요';

  @override
  String errorWithDetails(String error) {
    return '오류: $error';
  }

  @override
  String get sequenceNotAcceptedError => '허용되지 않는 순서';

  @override
  String get examplesNotAcceptedError => '허용되지 않는 예시';

  @override
  String get enterKeyAgainLabel => '키 다시 입력';

  @override
  String get pleaseEnterKeyAgainError => '키를 다시 입력해 주세요';

  @override
  String get keysDoNotMatchError => '키가 일치하지 않습니다';

  @override
  String get ruleUppercaseLetter => '대문자 1개';

  @override
  String get ruleLowercaseLetter => '소문자 1개';

  @override
  String get ruleNumericLetter => '숫자 1개';

  @override
  String get ruleSpecialCharacter => '특수 문자 1개';

  @override
  String get ruleMinTenCharacters => '최소 10자';

  @override
  String get examplesTitle => '예시';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => '알겠습니다';

  @override
  String get encryptionKeyTitle => '암호화 키';

  @override
  String get createKeyDescription => '길고 추측하기 어려운 키(비밀번호)를 입력하세요. 안전한 곳에 꼭 저장해 두세요. 분실하거나 잊어버리면 복구할 수 없습니다.';

  @override
  String get seeExamplesTooltip => '예시 보기';

  @override
  String get couldNotFetchDetailsMessage => '세부 정보를 가져올 수 없습니다';

  @override
  String get retryButtonLabel => '재시도';

  @override
  String get signedInAsLabel => '로그인 계정:';

  @override
  String get storageUsageLabel => '저장 공간 사용량';

  @override
  String get subscribeLabel => '구독';

  @override
  String get planExpiredRenewLabel => '플랜 만료! 갱신';

  @override
  String get manageDevicesLabel => '기기 관리';

  @override
  String get viewAccessKeyLabel => '액세스 키 보기';

  @override
  String get changeKeyPasswordLabel => '키 비밀번호 변경';

  @override
  String get manageSubscriptionLabel => '구독 관리';

  @override
  String get signOutButtonLabel => '로그아웃';

  @override
  String get yearlyPlansTitle => '연간 플랜';

  @override
  String get loginLabel => '로그인';

  @override
  String get syncAllYourNotesLabel => '모든 노트 동기화';

  @override
  String get acrossYourDevicesLabel => '여러 기기에서';

  @override
  String get featureEndToEndEncryption => '종단간 암호화';

  @override
  String get featureSyncUpTo3Devices => '최대 3대 기기 동기화';

  @override
  String get featureUpgradeCancelAnytime => '언제든 업그레이드/취소 가능';

  @override
  String get noPlansAvailableMessage => '사용 가능한 플랜 없음';

  @override
  String get downloadAppSubscribeLabel => '앱 다운로드 및 구독';

  @override
  String get privacyTermsLabel => '개인정보처리방침 • 이용약관';

  @override
  String get saveFiftyPercentLabel => '50% 할인';

  @override
  String get helloTitle => '안녕하세요';

  @override
  String get selectKeyMasterKeyDescription => '데이터를 암호화하려면 마스터 암호화 키가 필요합니다.';

  @override
  String get selectKeyTwoOptionsDescription => '두 가지 옵션이 있습니다. 직접 키를 생성하거나(비밀번호와 유사), 저희가 대신 생성해 드릴 수 있습니다.';

  @override
  String get understandLoseKeyAcknowledgement => '암호화 키를 분실하거나 잊어버리면 데이터를 잃을 수 있음을 이해합니다.';

  @override
  String get createKeyForMeButtonLabel => '대신 키 생성';

  @override
  String get recommendedLabel => '(추천)';

  @override
  String get pleaseAcknowledgeMessage => '동의해 주세요!';

  @override
  String get createKeyMyselfButtonLabel => '직접 키 생성';

  @override
  String welcomeToAppName(String appName) {
    return '$appName에 오신 것을 환영합니다';
  }

  @override
  String get e2eEncryptionDescription => '저희는 종단간 암호화를 사용하여 귀하의 모든 노트가 안전하게 보호되도록 합니다. 저희를 포함하여 그 누구도 노트를 볼 수 없습니다.';

  @override
  String get timeToStartEncryptionLabel => '암호화를 시작할 시간입니다!';

  @override
  String get nextButtonLabel => '다음';

  @override
  String get sendingOtpFailedMessage => 'OTP 발송 실패. 다시 시도해 주세요!';

  @override
  String get otpVerificationFailedMessage => 'OTP 인증 실패. 다시 시도해 주세요!';

  @override
  String get emailSignInTitle => '이메일 로그인';

  @override
  String get verifyOtpLabel => 'OTP 인증';

  @override
  String get enterEmailLabel => '이메일 입력';

  @override
  String get sendOtpLabel => 'OTP 발송';

  @override
  String otpSentToEmailMessage(String email) {
    return '귀하의 이메일 $email로 일회용 비밀번호(OTP)를 전송했습니다.';
  }

  @override
  String get enterOtpLabel => 'OTP 입력';

  @override
  String get changeEmailLabel => '이메일 변경';

  @override
  String get encryptingNotesTitle => '노트 암호화 중';

  @override
  String get fetchingDetailsTitle => '세부 정보 가져오는 중';

  @override
  String get couldNotFetchMessage => '가져올 수 없음';

  @override
  String get subscriptionEmailMismatchMessage => '구독 정보가 다른 이메일과 연결되어 있습니다. 로그아웃 후 해당 이메일로 다시 로그인하여 클라우드 저장소를 활성화하세요.';

  @override
  String get errorCheckingPlanDetailsMessage => '플랜 세부 정보 확인 중 오류 발생';

  @override
  String get registerDeviceTitle => '기기 등록';

  @override
  String get manageButtonLabel => '관리';

  @override
  String get fetchingKeysTitle => '키 가져오는 중';

  @override
  String get signingOutTitle => '로그아웃 중';

  @override
  String get pleaseCheckInternetMessage => '인터넷 연결을 확인해 주세요';

  @override
  String get somethingWentWrongMessage => '문제가 발생했습니다';

  @override
  String get playPauseTooltip => '재생/일시정지';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => '다운로드';

  @override
  String get invalidAccessKey => '잘못된 액세스 키';

  @override
  String get fileDoesNotContain24Words => '파일에 정확히 24개의 단어가 포함되어 있지 않습니다.';

  @override
  String get errorReadingFile => '파일 읽기 중 오류 발생';

  @override
  String get allLabel => '모두';

  @override
  String get logTypeDebug => '디버그';

  @override
  String get logTypeError => '오류';

  @override
  String get logTypeInfo => '정보';

  @override
  String get logTypeWarning => '경고';

  @override
  String get groupTitleHint => '그룹 제목';

  @override
  String get categoryLabel => '카테고리';

  @override
  String get selectCategoryPlaceholder => '카테고리 선택';

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
  String get searchHint => '쿼리, #문서 등..';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => '오디오 파일';

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
  String get selectLanguageTitle => '언어 선택';

  @override
  String get settingsTitle => '설정';

  @override
  String get themeLabel => '테마';

  @override
  String get dayNightThemeTooltip => '주간/야간 테마';

  @override
  String get lockLabel => '잠금';

  @override
  String get timeFormatLabel => '시간 형식';

  @override
  String get h12Label => '12시간제';

  @override
  String get h24Label => '24시간제';

  @override
  String get fontSizeLabel => '글꼴 크기';

  @override
  String get reduceTextSizeTooltip => '글꼴 크기 축소';

  @override
  String get increaseTextSizeTooltip => '글꼴 크기 확대';

  @override
  String get languageLabel => '언어';

  @override
  String get autoOpenGroupLabel => '자동 그룹 열기';

  @override
  String get selectGroupTitle => '그룹 선택';

  @override
  String shareAppMessage(String appName, String appLink) {
    return '$appName을 이용해 보세요: $appLink';
  }

  @override
  String get noteTypeEmpty => '비어 있음';

  @override
  String get noteTypeImage => '이미지';

  @override
  String get noteTypeVideo => '비디오';

  @override
  String get noteTypeAudio => '오디오';

  @override
  String get noteTypeDocument => '문서';

  @override
  String get noteTypeContact => '연락처';

  @override
  String get noteTypeLocation => '위치';

  @override
  String get noteTypeUnknown => '알 수 없음';

  @override
  String get pleaseEnterData => '데이터를 입력해 주세요';

  @override
  String get aNumber => '숫자';

  @override
  String get enterDataLabel => '데이터 입력';

  @override
  String get pleaseEnterValidData => '올바른 데이터를 입력해 주세요';

  @override
  String get pleaseSelectAnOption => '옵션을 선택해 주세요';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => '오늘';

  @override
  String get yesterdayLabel => '어제';

  @override
  String get mondayLabel => '월요일';

  @override
  String get tuesdayLabel => '화요일';

  @override
  String get wednesdayLabel => '수요일';

  @override
  String get thursdayLabel => '목요일';

  @override
  String get fridayLabel => '금요일';

  @override
  String get saturdayLabel => '토요일';

  @override
  String get sundayLabel => '일요일';

  @override
  String get januaryShortLabel => '1월';

  @override
  String get februaryShortLabel => '2월';

  @override
  String get marchShortLabel => '3월';

  @override
  String get aprilShortLabel => '4월';

  @override
  String get mayShortLabel => '5월';

  @override
  String get juneShortLabel => '6월';

  @override
  String get julyShortLabel => '7월';

  @override
  String get augustShortLabel => '8월';

  @override
  String get septemberShortLabel => '9월';

  @override
  String get octoberShortLabel => '10월';

  @override
  String get novemberShortLabel => '11월';

  @override
  String get decemberShortLabel => '12월';

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
    return '$count개의 노트 그룹';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count개의 노트 그룹';
  }
}

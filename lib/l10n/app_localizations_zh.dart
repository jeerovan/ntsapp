// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get importantTitle => '重要提示';

  @override
  String get accessKeyNoticeDescription1 => '在下一页，您将看到一组 24 个单词。这是您唯一且私密的加密密钥，也是在退出登录、设备丢失或故障时恢复笔记的唯一途径。';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return '我们不会存储此密钥。您有责任将其妥善存放在 $appName 应用程序之外的安全地方。';
  }

  @override
  String get iUnderstandShowMeTheKey => '我已理解。\n显示密钥。';

  @override
  String get selectGroupToViewNotes => '选择一个群组以查看笔记';

  @override
  String get accessKeyShareText => '这是您的访问密钥。';

  @override
  String get pleaseTryAgain => '请重试。';

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get accessKeyTitle => '访问密钥';

  @override
  String get accessKeyDescription => '请将此密钥保存在安全的地方。在其他设备上同步笔记时需要用到它。';

  @override
  String get copyLabel => '复制';

  @override
  String get downloadAsTextFileLabel => '下载为文本文件';

  @override
  String get continueLabel => '继续';

  @override
  String get pleaseAuthenticate => '请进行身份验证';

  @override
  String get couldNotCreate => '无法创建';

  @override
  String get couldNotShareFile => '无法共享文件';

  @override
  String get hereIsTheBackupFile => '这是您的应用备份文件。';

  @override
  String get errorTitle => '错误';

  @override
  String get backupLabel => '备份';

  @override
  String get restoreLabel => '恢复';

  @override
  String get leaveAReviewLabel => '留下评价';

  @override
  String get shareLabel => '分享';

  @override
  String get desktopAppLinkLabel => '桌面版应用';

  @override
  String get loggingLabel => '日志记录';

  @override
  String versionLabel(String version) {
    return '版本：$version';
  }

  @override
  String get loadingLabel => '加载中...';

  @override
  String get restoredLabel => '已恢复。';

  @override
  String get deletedPermanentlyLabel => '已永久删除。';

  @override
  String get mediaTitle => '媒体';

  @override
  String get invalidWordList => '单词列表无效';

  @override
  String get enterYour24WordPhrase => '输入您的 24 个单词短语';

  @override
  String get enterYourRecoveryPhraseHere => '在此输入您的恢复短语';

  @override
  String get pleaseEnterYourRecoveryPhrase => '请输入您的恢复短语';

  @override
  String get recoveryPhraseMustContain24Words => '恢复短语必须正好包含 24 个单词';

  @override
  String get submitLabel => '提交';

  @override
  String get orLabel => '或';

  @override
  String get selectTxtFileLabel => '选择 .txt 文件';

  @override
  String get failureTitle => '失败';

  @override
  String get invalidPasswordKey => '密码密钥无效';

  @override
  String get enableSyncTitle => '启用同步';

  @override
  String get passwordRequirementsDescription => '请输入您创建的密钥（密码）。它必须至少包含 10 个字符，且包含至少 1 个数字、1 个小写字母、1 个大写字母和 1 个特殊字符。';

  @override
  String get enterKeyLabel => '输入密钥';

  @override
  String get pleaseEnterKey => '请输入密钥';

  @override
  String get filterNotesTitle => '筛选笔记';

  @override
  String get filterPinnedNotesTooltip => '筛选置顶笔记';

  @override
  String get filterStarredNotesTooltip => '筛选标星笔记';

  @override
  String get filterTextNotesTooltip => '筛选文本笔记';

  @override
  String get filterTasksTooltip => '筛选任务';

  @override
  String get filterLinksTooltip => '筛选链接';

  @override
  String get filterImagesTooltip => '筛选图片';

  @override
  String get filterAudioTooltip => '筛选音频';

  @override
  String get filterVideoTooltip => '筛选视频';

  @override
  String get filterFilesTooltip => '筛选文件';

  @override
  String get filterContactsTooltip => '筛选联系人';

  @override
  String get filterLocationTooltip => '筛选位置';

  @override
  String get movedToTrash => '已移至回收站';

  @override
  String get copiedNotesToClipboard => '已复制到剪贴板';

  @override
  String get locationShareLabel => '位置：';

  @override
  String get contactShareLabel => '联系人：';

  @override
  String get emailsShareLabel => '电子邮件：';

  @override
  String get addressesShareLabel => '地址：';

  @override
  String get microphoneNotAvailable => '麦克风可能不可用。';

  @override
  String get microphonePermissionRequired => '录制音频需要麦克风权限。';

  @override
  String get couldNotGetDuration => '无法获取时长';

  @override
  String get errorOpeningFiles => '打开文件时出错';

  @override
  String get pleaseWaitTitle => '请稍候';

  @override
  String get fileNotAvailableYet => '文件暂不可用';

  @override
  String get clearSelectionTooltip => '清除选择';

  @override
  String get copyNotesTooltip => '复制笔记';

  @override
  String get changeTaskTypeTooltip => '更改任务类型';

  @override
  String get shareNotesTooltip => '分享笔记';

  @override
  String get noNotesSelectedToShare => '未选择要分享的笔记';

  @override
  String get nothingToShare => '没有可分享的内容';

  @override
  String get shareFailed => '分享失败';

  @override
  String get editNoteTooltip => '编辑笔记';

  @override
  String get starUnstarNotesTooltip => '标星/取消标星';

  @override
  String get moveToTrashTooltip => '移至回收站';

  @override
  String get pinUnpinNotesTooltip => '置顶/取消置顶';

  @override
  String get cancelReplyTooltip => '取消回复项';

  @override
  String get createTaskHint => '创建任务';

  @override
  String get addNoteHint => '添加笔记...';

  @override
  String get attachTooltip => '添加附件';

  @override
  String get addNoteTooltip => '添加笔记';

  @override
  String get recordStopAudioTooltip => '录制/停止音频';

  @override
  String get contactAttachmentLabel => '联系人';

  @override
  String get locationAttachmentLabel => '位置';

  @override
  String get cameraAttachmentLabel => '相机';

  @override
  String get filesAttachmentLabel => '文件';

  @override
  String get checklistAttachmentLabel => '清单';

  @override
  String get accessKeyInputTitle => '启用同步';

  @override
  String get accessKeyInputDescription => '请输入您的 24 个单词恢复短语，或加载包含该短语的 .txt 文件。';

  @override
  String get editMenuItemLabel => '编辑';

  @override
  String get filterMenuItemLabel => '筛选';

  @override
  String get externalStoragePermissionDenied => '访问外部存储的权限被拒绝。';

  @override
  String get pressLongToStartRecording => '长按以开始录音。';

  @override
  String get didYouKnowTitle => '您知道吗？';

  @override
  String get closeTooltip => '关闭';

  @override
  String appDescriptionContent(String appName) {
    return '$appName 是一款完全私密的笔记应用。它不会收集您的个人数据，也不会向您展示广告。\n\n希望您使用愉快。请告诉我们您的想法。';
  }

  @override
  String get searchNotesTooltip => '搜索笔记';

  @override
  String get syncMenuItemLabel => '同步';

  @override
  String get trashMenuItemLabel => '回收站';

  @override
  String get starredNotesMenuItemLabel => '标星笔记';

  @override
  String get settingsMenuItemLabel => '设置';

  @override
  String get accountMenuItemLabel => '帐户';

  @override
  String get pageMenuItemLabel => '页面';

  @override
  String get sqliteMenuItemLabel => 'Sqlite';

  @override
  String get logsMenuItemLabel => '日志';

  @override
  String get reorderMenuItemLabel => '重新排序';

  @override
  String get editGroupMenuItemLabel => '编辑';

  @override
  String get deleteGroupMenuItemLabel => '删除';

  @override
  String get dragHandleReorderTooltip => '拖动句柄以重新排序';

  @override
  String get holdAndDragReorderTooltip => '按住并拖动以重新排序';

  @override
  String get emptyHomePageMessage => '你好！\n\n这里看起来有点空。\n\n点击 + 按钮创建一些笔记吧。:)';

  @override
  String get reorderingTitle => '重新排序中';

  @override
  String get selectEllipsisLabel => '选择...';

  @override
  String get dateTimeToggleLabel => '日期/时间';

  @override
  String get noteBorderToggleLabel => '笔记边框';

  @override
  String get deleteGroupButtonLabel => '删除';

  @override
  String get notesTabLabel => '笔记';

  @override
  String get groupsTabLabel => '群组';

  @override
  String get categoriesTabLabel => '分类';

  @override
  String get locationItemLabel => '位置';

  @override
  String get addGroupTitle => '添加群组';

  @override
  String get editGroupTitle => '编辑群组';

  @override
  String get titleInputLabel => '标题';

  @override
  String get locationPermissionRequiredTitle => '需要位置权限';

  @override
  String get enableLocationPermissionsContent => '请在应用设置中启用位置权限。';

  @override
  String get cancelButtonLabel => '取消';

  @override
  String get openSettingsButtonLabel => '打开设置';

  @override
  String get locationServicesTitle => '位置服务';

  @override
  String get pleaseEnableLocationServicesContent => '请启用！';

  @override
  String get selectLocationTitle => '选择位置';

  @override
  String get useCurrentLocationTooltip => '使用当前位置';

  @override
  String get selectAllButtonLabel => '全选';

  @override
  String get searchLogsHint => '搜索日志..';

  @override
  String get noLogsAvailable => '暂无日志';

  @override
  String get dbViewerTitle => '数据库查看器';

  @override
  String get selectTableToViewData => '选择一个表以查看其数据';

  @override
  String get selectTableDropdownHint => '选择一个表';

  @override
  String get pickContactTitle => '选择联系人';

  @override
  String get permissionRequiredText => '需要权限';

  @override
  String get grantPermissionButtonLabel => '授予权限';

  @override
  String get pageDummyTitle => '页面虚拟';

  @override
  String get simulateButtonLabel => '模拟';

  @override
  String get selectCategoryTitle => '选择分类';

  @override
  String get addCategoryTitle => '添加分类';

  @override
  String get editCategoryTitle => '编辑分类';

  @override
  String get categoryTitleHint => '分类标题';

  @override
  String get colorLabel => '颜色';

  @override
  String get changeColorLabel => '更改颜色';

  @override
  String get deviceDisabledMessage => '设备已禁用！';

  @override
  String get cannotRemoveThisDeviceMessage => '无法移除此设备！';

  @override
  String get confirmRemoveTitle => '确认移除';

  @override
  String get confirmRemoveDeviceContent => '确定吗？这将删除该设备上的所有数据。';

  @override
  String get okButtonLabel => '确定';

  @override
  String get registeredDevicesTitle => '已注册设备';

  @override
  String get noDevicesFoundMessage => '未找到设备';

  @override
  String get enabledLabel => '已启用';

  @override
  String get disabledLabel => '已禁用';

  @override
  String get migratingMediaTitle => '正在迁移媒体';

  @override
  String get processingMessage => '正在处理...';

  @override
  String get doNotNavigateAwayMessage => '请勿离开当前页面';

  @override
  String errorWithDetails(String error) {
    return '错误：$error';
  }

  @override
  String get sequenceNotAcceptedError => '序列不被接受';

  @override
  String get examplesNotAcceptedError => '示例不被接受';

  @override
  String get enterKeyAgainLabel => '再次输入密钥';

  @override
  String get pleaseEnterKeyAgainError => '请再次输入密钥';

  @override
  String get keysDoNotMatchError => '密钥不匹配';

  @override
  String get ruleUppercaseLetter => '1 个大写字母';

  @override
  String get ruleLowercaseLetter => '1 个小写字母';

  @override
  String get ruleNumericLetter => '1 个数字';

  @override
  String get ruleSpecialCharacter => '1 个特殊字符';

  @override
  String get ruleMinTenCharacters => '至少 10 个字符';

  @override
  String get examplesTitle => '示例';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => '明白了';

  @override
  String get encryptionKeyTitle => '加密密钥';

  @override
  String get createKeyDescription => '请输入一个长且难以猜测的密钥（密码）。请务必将其保存在安全的地方。如果丢失或忘记，将无法找回。';

  @override
  String get seeExamplesTooltip => '查看示例';

  @override
  String get couldNotFetchDetailsMessage => '无法获取详情';

  @override
  String get retryButtonLabel => '重试';

  @override
  String get signedInAsLabel => '登录账号：';

  @override
  String get storageUsageLabel => '存储使用量';

  @override
  String get subscribeLabel => '订阅';

  @override
  String get planExpiredRenewLabel => '计划已过期！续费';

  @override
  String get manageDevicesLabel => '管理设备';

  @override
  String get viewAccessKeyLabel => '查看访问密钥';

  @override
  String get changeKeyPasswordLabel => '更改密钥密码';

  @override
  String get manageSubscriptionLabel => '管理订阅';

  @override
  String get signOutButtonLabel => '退出登录';

  @override
  String get yearlyPlansTitle => '年度计划';

  @override
  String get loginLabel => '登录';

  @override
  String get syncAllYourNotesLabel => '同步您的所有笔记';

  @override
  String get acrossYourDevicesLabel => '跨越您的所有设备';

  @override
  String get featureEndToEndEncryption => '端到端加密';

  @override
  String get featureSyncUpTo3Devices => '最多同步 3 台设备';

  @override
  String get featureUpgradeCancelAnytime => '随时升级/取消';

  @override
  String get noPlansAvailableMessage => '暂无可用计划';

  @override
  String get downloadAppSubscribeLabel => '下载应用并订阅';

  @override
  String get privacyTermsLabel => '隐私 • 条款';

  @override
  String get saveFiftyPercentLabel => '节省 50%';

  @override
  String get helloTitle => '您好';

  @override
  String get selectKeyMasterKeyDescription => '为了加密您的数据，我们需要一个主加密密钥。';

  @override
  String get selectKeyTwoOptionsDescription => '有两种选择 - 您可以自己创建一个密钥（类似于密码），或者由我们为您创建。';

  @override
  String get understandLoseKeyAcknowledgement => '我理解如果我丢失/忘记了加密密钥，我可能会丢失数据。';

  @override
  String get createKeyForMeButtonLabel => '为我创建密钥';

  @override
  String get recommendedLabel => '（推荐）';

  @override
  String get pleaseAcknowledgeMessage => '请确认！';

  @override
  String get createKeyMyselfButtonLabel => '我自己创建密钥';

  @override
  String welcomeToAppName(String appName) {
    return '欢迎使用 $appName';
  }

  @override
  String get e2eEncryptionDescription => '我们使用端到端加密，确保您的所有笔记都是安全的，任何人都无法查看，即使是我们也不行。';

  @override
  String get timeToStartEncryptionLabel => '是时候开始加密了！';

  @override
  String get nextButtonLabel => '下一步';

  @override
  String get sendingOtpFailedMessage => '发送 OTP 失败。请重试！';

  @override
  String get otpVerificationFailedMessage => 'OTP 验证失败。请重试！';

  @override
  String get emailSignInTitle => '电子邮件登录';

  @override
  String get verifyOtpLabel => '验证 OTP';

  @override
  String get enterEmailLabel => '输入电子邮件';

  @override
  String get sendOtpLabel => '发送 OTP';

  @override
  String otpSentToEmailMessage(String email) {
    return '我们已将一次性密码 (OTP) 发送到您的电子邮件 $email';
  }

  @override
  String get enterOtpLabel => '输入 OTP';

  @override
  String get changeEmailLabel => '更改电子邮件';

  @override
  String get encryptingNotesTitle => '正在加密笔记';

  @override
  String get fetchingDetailsTitle => '正在获取详情';

  @override
  String get couldNotFetchMessage => '无法获取';

  @override
  String get subscriptionEmailMismatchMessage => '您的订阅关联了其他电子邮件。请退出登录并使用该邮箱以启用云存储。';

  @override
  String get errorCheckingPlanDetailsMessage => '检查计划详情时出错';

  @override
  String get registerDeviceTitle => '注册设备';

  @override
  String get manageButtonLabel => '管理';

  @override
  String get fetchingKeysTitle => '正在获取密钥';

  @override
  String get signingOutTitle => '正在退出登录';

  @override
  String get pleaseCheckInternetMessage => '请检查网络';

  @override
  String get somethingWentWrongMessage => '出错了';

  @override
  String get playPauseTooltip => '播放/暂停';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => '下载';

  @override
  String get invalidAccessKey => '无效的访问密钥';

  @override
  String get fileDoesNotContain24Words => '该文件包含的单词不足 24 个。';

  @override
  String get errorReadingFile => '读取文件时出错';

  @override
  String get allLabel => '全部';

  @override
  String get logTypeDebug => '调试';

  @override
  String get logTypeError => '错误';

  @override
  String get logTypeInfo => '信息';

  @override
  String get logTypeWarning => '警告';

  @override
  String get groupTitleHint => '群组标题';

  @override
  String get categoryLabel => '分类';

  @override
  String get selectCategoryPlaceholder => '选择分类';

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
  String get searchHint => '查询，#文档等..';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => '音频文件';

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
  String get selectLanguageTitle => '选择语言';

  @override
  String get settingsTitle => '设置';

  @override
  String get themeLabel => '主题';

  @override
  String get dayNightThemeTooltip => '日间/夜间主题';

  @override
  String get lockLabel => '锁定';

  @override
  String get timeFormatLabel => '时间格式';

  @override
  String get h12Label => '12 小时制';

  @override
  String get h24Label => '24 小时制';

  @override
  String get fontSizeLabel => '字体大小';

  @override
  String get reduceTextSizeTooltip => '减小字体大小';

  @override
  String get increaseTextSizeTooltip => '增加字体大小';

  @override
  String get languageLabel => '语言';

  @override
  String get autoOpenGroupLabel => '自动打开群组';

  @override
  String get selectGroupTitle => '选择群组';

  @override
  String shareAppMessage(String appName, String appLink) {
    return '使用 $appName：$appLink';
  }

  @override
  String get noteTypeEmpty => '空';

  @override
  String get noteTypeImage => '图片';

  @override
  String get noteTypeVideo => '视频';

  @override
  String get noteTypeAudio => '音频';

  @override
  String get noteTypeDocument => '文档';

  @override
  String get noteTypeContact => '联系人';

  @override
  String get noteTypeLocation => '位置';

  @override
  String get noteTypeUnknown => '未知';

  @override
  String get pleaseEnterData => '请输入数据';

  @override
  String get aNumber => '一个数字';

  @override
  String get enterDataLabel => '输入数据';

  @override
  String get pleaseEnterValidData => '请输入有效数据';

  @override
  String get pleaseSelectAnOption => '请选择一个选项';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => '今天';

  @override
  String get yesterdayLabel => '昨天';

  @override
  String get mondayLabel => '星期一';

  @override
  String get tuesdayLabel => '星期二';

  @override
  String get wednesdayLabel => '星期三';

  @override
  String get thursdayLabel => '星期四';

  @override
  String get fridayLabel => '星期五';

  @override
  String get saturdayLabel => '星期六';

  @override
  String get sundayLabel => '星期日';

  @override
  String get januaryShortLabel => '1月';

  @override
  String get februaryShortLabel => '2月';

  @override
  String get marchShortLabel => '3月';

  @override
  String get aprilShortLabel => '4月';

  @override
  String get mayShortLabel => '5月';

  @override
  String get juneShortLabel => '6月';

  @override
  String get julyShortLabel => '7月';

  @override
  String get augustShortLabel => '8月';

  @override
  String get septemberShortLabel => '9月';

  @override
  String get octoberShortLabel => '10月';

  @override
  String get novemberShortLabel => '11月';

  @override
  String get decemberShortLabel => '12月';

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
    return '$count 个笔记群组';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count 个笔记群组';
  }

  @override
  String get seedCategoryTasks => '任务';

  @override
  String get seedGroupNotes => '笔记';

  @override
  String get seedGroupFitness => '健身';

  @override
  String get seedItemWelcome => '欢迎使用 Note Safe！\n无论是灵感、清单还是任何想法，都可以记录在这里。\n\n长按此笔记即可进行删除、编辑等操作。';

  @override
  String get seedItemMorningWorkout => '晨间锻炼';

  @override
  String get seedItemMeditation => '10分钟冥想';

  @override
  String get seedItemWater => '每日饮水2升';

  @override
  String get seedItemSteps => '步行10,000步';
}

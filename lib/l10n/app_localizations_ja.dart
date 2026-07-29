// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get importantTitle => '重要事項';

  @override
  String get accessKeyNoticeDescription1 => '次のページで24個の単語が表示されます。これはあなた固有の非公開暗号化キーです。ログアウト、端末の紛失、故障が発生した場合、メモを復元できる唯一の方法です。';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return '当社はキーを保存しません。$appNameアプリの外部で安全な場所に保管するのはあなたの責任です。';
  }

  @override
  String get iUnderstandShowMeTheKey => '理解しました。\nキーを表示する';

  @override
  String get selectGroupToViewNotes => 'メモを表示するグループを選択';

  @override
  String get accessKeyShareText => 'アクセスキーはこちらです。';

  @override
  String get pleaseTryAgain => '再試行してください。';

  @override
  String get copiedToClipboard => 'クリップボードにコピーしました';

  @override
  String get accessKeyTitle => 'アクセスキー';

  @override
  String get accessKeyDescription => 'このキーを安全な場所に保存してください。別の端末でメモを同期する際に必要になります。';

  @override
  String get copyLabel => 'コピー';

  @override
  String get downloadAsTextFileLabel => 'テキストファイルとしてダウンロード';

  @override
  String get continueLabel => '続行';

  @override
  String get pleaseAuthenticate => '認証してください';

  @override
  String get couldNotCreate => '作成できませんでした';

  @override
  String get couldNotShareFile => 'ファイルを共有できませんでした';

  @override
  String get hereIsTheBackupFile => 'アプリのバックアップファイルです。';

  @override
  String get errorTitle => 'エラー';

  @override
  String get backupLabel => 'バックアップ';

  @override
  String get restoreLabel => '復元';

  @override
  String get leaveAReviewLabel => 'レビューを投稿';

  @override
  String get shareLabel => '共有';

  @override
  String get desktopAppLinkLabel => 'デスクトップアプリ';

  @override
  String get loggingLabel => 'ログ記録';

  @override
  String versionLabel(String version) {
    return 'バージョン: $version';
  }

  @override
  String get loadingLabel => '読み込み中...';

  @override
  String get restoredLabel => '復元しました。';

  @override
  String get deletedPermanentlyLabel => '完全に削除しました。';

  @override
  String get mediaTitle => 'メディア';

  @override
  String get invalidWordList => '無効な単語リスト';

  @override
  String get enterYour24WordPhrase => '24単語のフレーズを入力';

  @override
  String get enterYourRecoveryPhraseHere => 'ここにリカバリーフレーズを入力してください';

  @override
  String get pleaseEnterYourRecoveryPhrase => 'リカバリーフレーズを入力してください';

  @override
  String get recoveryPhraseMustContain24Words => 'リカバリーフレーズは24単語である必要があります';

  @override
  String get submitLabel => '送信';

  @override
  String get orLabel => 'または';

  @override
  String get selectTxtFileLabel => '.txtファイルを選択';

  @override
  String get failureTitle => '失敗';

  @override
  String get invalidPasswordKey => '無効なパスワードキー';

  @override
  String get enableSyncTitle => '同期を有効にする';

  @override
  String get passwordRequirementsDescription => '作成したキー（パスワード）を入力してください。10文字以上で、数字、小文字、大文字、特殊文字をそれぞれ1つ以上含む必要があります。';

  @override
  String get enterKeyLabel => 'キーを入力';

  @override
  String get pleaseEnterKey => 'キーを入力してください';

  @override
  String get filterNotesTitle => 'メモを絞り込み';

  @override
  String get filterPinnedNotesTooltip => 'ピン留めしたメモ';

  @override
  String get filterStarredNotesTooltip => 'スター付きのメモ';

  @override
  String get filterTextNotesTooltip => 'テキストメモ';

  @override
  String get filterTasksTooltip => 'タスク';

  @override
  String get filterLinksTooltip => 'リンク';

  @override
  String get filterImagesTooltip => '画像';

  @override
  String get filterAudioTooltip => '音声';

  @override
  String get filterVideoTooltip => '動画';

  @override
  String get filterFilesTooltip => 'ファイル';

  @override
  String get filterContactsTooltip => '連絡先';

  @override
  String get filterLocationTooltip => '場所';

  @override
  String get movedToTrash => 'ゴミ箱に移動しました';

  @override
  String get copiedNotesToClipboard => 'クリップボードにコピーしました';

  @override
  String get locationShareLabel => '場所:';

  @override
  String get contactShareLabel => '連絡先:';

  @override
  String get emailsShareLabel => 'メールアドレス:';

  @override
  String get addressesShareLabel => '住所:';

  @override
  String get microphoneNotAvailable => 'マイクが利用できない可能性があります。';

  @override
  String get microphonePermissionRequired => '音声を録音するにはマイクの権限が必要です。';

  @override
  String get couldNotGetDuration => '長さを取得できませんでした';

  @override
  String get errorOpeningFiles => 'ファイルを開く際にエラーが発生しました';

  @override
  String get pleaseWaitTitle => 'お待ちください';

  @override
  String get fileNotAvailableYet => 'ファイルはまだ利用できません';

  @override
  String get clearSelectionTooltip => '選択を解除';

  @override
  String get copyNotesTooltip => 'メモをコピー';

  @override
  String get changeTaskTypeTooltip => 'タスクタイプを変更';

  @override
  String get shareNotesTooltip => 'メモを共有';

  @override
  String get noNotesSelectedToShare => '共有するメモが選択されていません';

  @override
  String get nothingToShare => '共有するものがありません';

  @override
  String get shareFailed => '共有に失敗しました';

  @override
  String get editNoteTooltip => 'メモを編集';

  @override
  String get starUnstarNotesTooltip => 'スターの付け外し';

  @override
  String get moveToTrashTooltip => 'ゴミ箱に移動';

  @override
  String get pinUnpinNotesTooltip => 'ピン留めの付け外し';

  @override
  String get cancelReplyTooltip => '返信をキャンセル';

  @override
  String get createTaskHint => 'タスクを作成';

  @override
  String get addNoteHint => 'メモを追加...';

  @override
  String get attachTooltip => '添付';

  @override
  String get addNoteTooltip => 'メモを追加';

  @override
  String get recordStopAudioTooltip => '録音開始/停止';

  @override
  String get contactAttachmentLabel => '連絡先';

  @override
  String get locationAttachmentLabel => '場所';

  @override
  String get cameraAttachmentLabel => 'カメラ';

  @override
  String get filesAttachmentLabel => 'ファイル';

  @override
  String get checklistAttachmentLabel => 'チェックリスト';

  @override
  String get accessKeyInputTitle => '同期を有効にする';

  @override
  String get accessKeyInputDescription => '24単語のリカバリーフレーズを入力するか、それを含む.txtファイルを読み込んでください。';

  @override
  String get editMenuItemLabel => '編集';

  @override
  String get filterMenuItemLabel => 'フィルター';

  @override
  String get externalStoragePermissionDenied => '外部ストレージへのアクセス権限が拒否されました。';

  @override
  String get pressLongToStartRecording => '長押しで録音を開始します。';

  @override
  String get didYouKnowTitle => '知っていましたか？';

  @override
  String get closeTooltip => '閉じる';

  @override
  String appDescriptionContent(String appName) {
    return '$appNameは完全にプライベートなメモアプリです。個人データの収集や広告の表示は行いません。\n\nお役に立てれば幸いです。ご意見をお聞かせください。';
  }

  @override
  String get searchNotesTooltip => 'メモを検索';

  @override
  String get syncMenuItemLabel => '同期';

  @override
  String get trashMenuItemLabel => 'ゴミ箱';

  @override
  String get starredNotesMenuItemLabel => 'スター付きのメモ';

  @override
  String get settingsMenuItemLabel => '設定';

  @override
  String get accountMenuItemLabel => 'アカウント';

  @override
  String get pageMenuItemLabel => 'ページ';

  @override
  String get sqliteMenuItemLabel => 'Sqlite';

  @override
  String get logsMenuItemLabel => 'ログ';

  @override
  String get reorderMenuItemLabel => '並び替え';

  @override
  String get editGroupMenuItemLabel => '編集';

  @override
  String get deleteGroupMenuItemLabel => '削除';

  @override
  String get dragHandleReorderTooltip => 'ドラッグして並び替え';

  @override
  String get holdAndDragReorderTooltip => '長押しでドラッグして並び替え';

  @override
  String get emptyHomePageMessage => 'こんにちは！\n\nここにはまだ何もありません。\n\n「+」ボタンをタップして、メモを作成してみましょう。:)';

  @override
  String get reorderingTitle => '並び替え中';

  @override
  String get selectEllipsisLabel => '選択...';

  @override
  String get dateTimeToggleLabel => '日時';

  @override
  String get noteBorderToggleLabel => 'メモの枠線';

  @override
  String get deleteGroupButtonLabel => '削除';

  @override
  String get notesTabLabel => 'メモ';

  @override
  String get groupsTabLabel => 'グループ';

  @override
  String get categoriesTabLabel => 'カテゴリー';

  @override
  String get locationItemLabel => '場所';

  @override
  String get addGroupTitle => 'グループを追加';

  @override
  String get editGroupTitle => 'グループを編集';

  @override
  String get titleInputLabel => 'タイトル';

  @override
  String get locationPermissionRequiredTitle => '位置情報の権限が必要です';

  @override
  String get enableLocationPermissionsContent => 'アプリの設定で位置情報の権限を有効にしてください。';

  @override
  String get cancelButtonLabel => 'キャンセル';

  @override
  String get openSettingsButtonLabel => '設定を開く';

  @override
  String get locationServicesTitle => '位置情報サービス';

  @override
  String get pleaseEnableLocationServicesContent => '有効にしてください！';

  @override
  String get selectLocationTitle => '場所を選択';

  @override
  String get useCurrentLocationTooltip => '現在の場所を使用';

  @override
  String get selectAllButtonLabel => 'すべて選択';

  @override
  String get searchLogsHint => 'ログを検索...';

  @override
  String get noLogsAvailable => 'ログはありません';

  @override
  String get dbViewerTitle => 'DBビューアー';

  @override
  String get selectTableToViewData => 'データを確認するテーブルを選択';

  @override
  String get selectTableDropdownHint => 'テーブルを選択';

  @override
  String get pickContactTitle => '連絡先を選択';

  @override
  String get permissionRequiredText => '権限が必要です';

  @override
  String get grantPermissionButtonLabel => '権限を許可';

  @override
  String get pageDummyTitle => 'ページダミー';

  @override
  String get simulateButtonLabel => 'シミュレート';

  @override
  String get selectCategoryTitle => 'カテゴリーを選択';

  @override
  String get addCategoryTitle => 'カテゴリーを追加';

  @override
  String get editCategoryTitle => 'カテゴリーを編集';

  @override
  String get categoryTitleHint => 'カテゴリーのタイトル';

  @override
  String get colorLabel => '色';

  @override
  String get changeColorLabel => '色を変更';

  @override
  String get deviceDisabledMessage => '端末が無効です！';

  @override
  String get cannotRemoveThisDeviceMessage => 'この端末は削除できません！';

  @override
  String get confirmRemoveTitle => '削除の確認';

  @override
  String get confirmRemoveDeviceContent => 'よろしいですか？この端末上のすべてのデータが削除されます。';

  @override
  String get okButtonLabel => 'OK';

  @override
  String get registeredDevicesTitle => '登録済み端末';

  @override
  String get noDevicesFoundMessage => '端末が見つかりません';

  @override
  String get enabledLabel => '有効';

  @override
  String get disabledLabel => '無効';

  @override
  String get migratingMediaTitle => 'メディア移行中';

  @override
  String get processingMessage => '処理中...';

  @override
  String get doNotNavigateAwayMessage => '画面を閉じないでください';

  @override
  String errorWithDetails(String error) {
    return 'エラー: $error';
  }

  @override
  String get sequenceNotAcceptedError => '連続したパターンは使用できません';

  @override
  String get examplesNotAcceptedError => '使用例に一致するキーは使用できません';

  @override
  String get enterKeyAgainLabel => 'もう一度キーを入力';

  @override
  String get pleaseEnterKeyAgainError => 'キーを再入力してください';

  @override
  String get keysDoNotMatchError => 'キーが一致しません';

  @override
  String get ruleUppercaseLetter => '大文字1文字以上';

  @override
  String get ruleLowercaseLetter => '小文字1文字以上';

  @override
  String get ruleNumericLetter => '数字1文字以上';

  @override
  String get ruleSpecialCharacter => '特殊文字1文字以上';

  @override
  String get ruleMinTenCharacters => '10文字以上';

  @override
  String get examplesTitle => '使用例';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => '了解';

  @override
  String get encryptionKeyTitle => '暗号化キー';

  @override
  String get createKeyDescription => '長く、推測されにくいキー（パスワード）を入力してください。安全な場所に保存することを忘れないでください。紛失・忘れた場合、復元することはできません。';

  @override
  String get seeExamplesTooltip => '使用例を見る';

  @override
  String get couldNotFetchDetailsMessage => '詳細を取得できませんでした';

  @override
  String get retryButtonLabel => '再試行';

  @override
  String get signedInAsLabel => 'サインイン中:';

  @override
  String get storageUsageLabel => 'ストレージ使用量';

  @override
  String get subscribeLabel => '購読';

  @override
  String get planExpiredRenewLabel => 'プランの有効期限が切れました！更新';

  @override
  String get manageDevicesLabel => '端末の管理';

  @override
  String get viewAccessKeyLabel => 'アクセスキーを表示';

  @override
  String get changeKeyPasswordLabel => 'キーのパスワードを変更';

  @override
  String get manageSubscriptionLabel => 'サブスクリプションの管理';

  @override
  String get signOutButtonLabel => 'サインアウト';

  @override
  String get yearlyPlansTitle => '年間プラン';

  @override
  String get loginLabel => 'ログイン';

  @override
  String get syncAllYourNotesLabel => 'すべてのメモを同期';

  @override
  String get acrossYourDevicesLabel => '端末間で';

  @override
  String get featureEndToEndEncryption => 'エンドツーエンド暗号化';

  @override
  String get featureSyncUpTo3Devices => '最大3台の端末で同期';

  @override
  String get featureUpgradeCancelAnytime => 'いつでもアップグレード/キャンセル可能';

  @override
  String get noPlansAvailableMessage => 'プランはありません';

  @override
  String get downloadAppSubscribeLabel => 'アプリをダウンロードして購読';

  @override
  String get privacyTermsLabel => 'プライバシーポリシー • 利用規約';

  @override
  String get saveFiftyPercentLabel => '50%オフ';

  @override
  String get helloTitle => 'ようこそ';

  @override
  String get selectKeyMasterKeyDescription => 'データを暗号化するために、マスター暗号化キーが必要です。';

  @override
  String get selectKeyTwoOptionsDescription => '2つのオプションがあります。自分でキーを作成するか、アプリが自動で作成します。';

  @override
  String get understandLoseKeyAcknowledgement => '暗号化キーを紛失・忘れた場合、データが失われる可能性があることを理解しました。';

  @override
  String get createKeyForMeButtonLabel => 'アプリでキーを作成';

  @override
  String get recommendedLabel => '(推奨)';

  @override
  String get pleaseAcknowledgeMessage => '同意してください！';

  @override
  String get createKeyMyselfButtonLabel => '自分でキーを作成する';

  @override
  String welcomeToAppName(String appName) {
    return '$appNameへようこそ';
  }

  @override
  String get e2eEncryptionDescription => 'エンドツーエンド暗号化により、すべてのメモは安全に保護され、当社を含め第三者からは閲覧できません。';

  @override
  String get timeToStartEncryptionLabel => '暗号化を開始しましょう！';

  @override
  String get nextButtonLabel => '次へ';

  @override
  String get sendingOtpFailedMessage => 'OTPの送信に失敗しました。再試行してください！';

  @override
  String get otpVerificationFailedMessage => 'OTPの確認に失敗しました。再試行してください！';

  @override
  String get emailSignInTitle => 'メールサインイン';

  @override
  String get verifyOtpLabel => 'OTPを検証';

  @override
  String get enterEmailLabel => 'メールアドレスを入力';

  @override
  String get sendOtpLabel => 'OTPを送信';

  @override
  String otpSentToEmailMessage(String email) {
    return 'ワンタイムパスワード(OTP)をメール($email)へ送信しました';
  }

  @override
  String get enterOtpLabel => 'OTPを入力';

  @override
  String get changeEmailLabel => 'メールアドレスを変更';

  @override
  String get encryptingNotesTitle => 'メモを暗号化中';

  @override
  String get fetchingDetailsTitle => '詳細を取得中';

  @override
  String get couldNotFetchMessage => '取得できませんでした';

  @override
  String get subscriptionEmailMismatchMessage => 'サブスクリプションが別のメールアドレスと関連付けられています。サインアウトし、そのアカウントを使用してクラウドストレージを有効にしてください。';

  @override
  String get errorCheckingPlanDetailsMessage => 'プラン詳細の確認中にエラーが発生しました';

  @override
  String get registerDeviceTitle => '端末を登録';

  @override
  String get manageButtonLabel => '管理';

  @override
  String get fetchingKeysTitle => 'キーを取得中';

  @override
  String get signingOutTitle => 'サインアウト中';

  @override
  String get pleaseCheckInternetMessage => 'インターネット接続を確認してください';

  @override
  String get somethingWentWrongMessage => '問題が発生しました';

  @override
  String get playPauseTooltip => '再生/一時停止';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => 'ダウンロード';

  @override
  String get invalidAccessKey => '無効なアクセスキー';

  @override
  String get fileDoesNotContain24Words => 'ファイルに24単語が含まれていません。';

  @override
  String get errorReadingFile => 'ファイルの読み取りエラー';

  @override
  String get allLabel => 'すべて';

  @override
  String get logTypeDebug => 'デバッグ';

  @override
  String get logTypeError => 'エラー';

  @override
  String get logTypeInfo => '情報';

  @override
  String get logTypeWarning => '警告';

  @override
  String get groupTitleHint => 'グループタイトル';

  @override
  String get categoryLabel => 'カテゴリー';

  @override
  String get selectCategoryPlaceholder => 'カテゴリーを選択';

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
  String get searchHint => '検索ワード、#ドキュメント等...';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => '音声ファイル';

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
  String get selectLanguageTitle => '言語を選択';

  @override
  String get settingsTitle => '設定';

  @override
  String get themeLabel => 'テーマ';

  @override
  String get dayNightThemeTooltip => '昼/夜テーマ';

  @override
  String get lockLabel => 'ロック';

  @override
  String get timeFormatLabel => '時刻形式';

  @override
  String get h12Label => '12時間制';

  @override
  String get h24Label => '24時間制';

  @override
  String get fontSizeLabel => 'フォントサイズ';

  @override
  String get reduceTextSizeTooltip => 'フォントサイズを縮小';

  @override
  String get increaseTextSizeTooltip => 'フォントサイズを拡大';

  @override
  String get languageLabel => '言語';

  @override
  String get autoOpenGroupLabel => 'グループを自動的に開く';

  @override
  String get selectGroupTitle => 'グループを選択';

  @override
  String shareAppMessage(String appName, String appLink) {
    return '$appNameを使ってみませんか: $appLink';
  }

  @override
  String get noteTypeEmpty => '空';

  @override
  String get noteTypeImage => '画像';

  @override
  String get noteTypeVideo => '動画';

  @override
  String get noteTypeAudio => '音声';

  @override
  String get noteTypeDocument => 'ドキュメント';

  @override
  String get noteTypeContact => '連絡先';

  @override
  String get noteTypeLocation => '場所';

  @override
  String get noteTypeUnknown => '不明';

  @override
  String get pleaseEnterData => 'データを入力してください';

  @override
  String get aNumber => '数字';

  @override
  String get enterDataLabel => 'データを入力';

  @override
  String get pleaseEnterValidData => '有効なデータを入力してください';

  @override
  String get pleaseSelectAnOption => 'オプションを選択してください';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => '今日';

  @override
  String get yesterdayLabel => '昨日';

  @override
  String get mondayLabel => '月曜日';

  @override
  String get tuesdayLabel => '火曜日';

  @override
  String get wednesdayLabel => '水曜日';

  @override
  String get thursdayLabel => '木曜日';

  @override
  String get fridayLabel => '金曜日';

  @override
  String get saturdayLabel => '土曜日';

  @override
  String get sundayLabel => '日曜日';

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
    return '$month $day ($dayOfWeek)';
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
    return '$count個のメモグループ';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count個のメモグループ';
  }

  @override
  String get seedCategoryTasks => 'タスク';

  @override
  String get seedGroupNotes => 'メモ';

  @override
  String get seedGroupFitness => 'フィットネス';

  @override
  String get seedItemWelcome => 'Note Safeへようこそ！\nアイデアやリストなど、気になることを何でもここに書き留めておきましょう。\n\nこのメモを長押しすると、削除や編集などのオプションが表示されます。';

  @override
  String get seedItemMorningWorkout => '朝のワークアウト';

  @override
  String get seedItemMeditation => '10分間の瞑想';

  @override
  String get seedItemWater => '1日2リットルの水分補給';

  @override
  String get seedItemSteps => '1日1万歩歩く';
}

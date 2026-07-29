// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get importantTitle => 'Важно';

  @override
  String get accessKeyNoticeDescription1 => 'На следующей странице вы увидите список из 24 слов. Это ваш уникальный и личный ключ шифрования. Это ЕДИНСТВЕННЫЙ способ восстановить доступ к заметкам в случае выхода из аккаунта, потери или поломки устройства.';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return 'Мы не храним этот ключ. ВАША обязанность — сохранить его в надежном месте вне приложения $appName.';
  }

  @override
  String get iUnderstandShowMeTheKey => 'Я понимаю.\nПоказать ключ';

  @override
  String get selectGroupToViewNotes => 'Выберите группу, чтобы увидеть заметки';

  @override
  String get accessKeyShareText => 'Вот ваш ключ доступа.';

  @override
  String get pleaseTryAgain => 'Пожалуйста, попробуйте еще раз.';

  @override
  String get copiedToClipboard => 'Скопировано в буфер обмена';

  @override
  String get accessKeyTitle => 'Ключ доступа';

  @override
  String get accessKeyDescription => 'Пожалуйста, сохраните этот ключ в надежном месте. Он понадобится вам для синхронизации заметок на другом устройстве.';

  @override
  String get copyLabel => 'Копировать';

  @override
  String get downloadAsTextFileLabel => 'Скачать как текстовый файл';

  @override
  String get continueLabel => 'Продолжить';

  @override
  String get pleaseAuthenticate => 'Пожалуйста, пройдите аутентификацию';

  @override
  String get couldNotCreate => 'Не удалось создать';

  @override
  String get couldNotShareFile => 'Не удалось отправить файл';

  @override
  String get hereIsTheBackupFile => 'Вот файл резервной копии вашего приложения.';

  @override
  String get errorTitle => 'Ошибка';

  @override
  String get backupLabel => 'Резервная копия';

  @override
  String get restoreLabel => 'Восстановить';

  @override
  String get leaveAReviewLabel => 'Оставить отзыв';

  @override
  String get shareLabel => 'Поделиться';

  @override
  String get desktopAppLinkLabel => 'Десктопное приложение';

  @override
  String get loggingLabel => 'Логирование';

  @override
  String versionLabel(String version) {
    return 'Версия: $version';
  }

  @override
  String get loadingLabel => 'Загрузка...';

  @override
  String get restoredLabel => 'Восстановлено.';

  @override
  String get deletedPermanentlyLabel => 'Удалено навсегда.';

  @override
  String get mediaTitle => 'Медиа';

  @override
  String get invalidWordList => 'Неверный список слов';

  @override
  String get enterYour24WordPhrase => 'Введите вашу фразу из 24 слов';

  @override
  String get enterYourRecoveryPhraseHere => 'Введите фразу для восстановления здесь';

  @override
  String get pleaseEnterYourRecoveryPhrase => 'Пожалуйста, введите вашу фразу для восстановления';

  @override
  String get recoveryPhraseMustContain24Words => 'Фраза для восстановления должна состоять ровно из 24 слов';

  @override
  String get submitLabel => 'Отправить';

  @override
  String get orLabel => 'Или';

  @override
  String get selectTxtFileLabel => 'Выберите .txt файл';

  @override
  String get failureTitle => 'Сбой';

  @override
  String get invalidPasswordKey => 'Неверный пароль';

  @override
  String get enableSyncTitle => 'Включить синхронизацию';

  @override
  String get passwordRequirementsDescription => 'Пожалуйста, введите созданный вами ключ (пароль). Минимум 10 символов, включая 1 цифру, 1 строчную букву, 1 заглавную букву и 1 спецсимвол.';

  @override
  String get enterKeyLabel => 'Введите ключ';

  @override
  String get pleaseEnterKey => 'Пожалуйста, введите ключ';

  @override
  String get filterNotesTitle => 'Фильтр заметок';

  @override
  String get filterPinnedNotesTooltip => 'Фильтр закрепленных заметок';

  @override
  String get filterStarredNotesTooltip => 'Фильтр избранных заметок';

  @override
  String get filterTextNotesTooltip => 'Фильтр текстовых заметок';

  @override
  String get filterTasksTooltip => 'Фильтр задач';

  @override
  String get filterLinksTooltip => 'Фильтр ссылок';

  @override
  String get filterImagesTooltip => 'Фильтр изображений';

  @override
  String get filterAudioTooltip => 'Фильтр аудио';

  @override
  String get filterVideoTooltip => 'Фильтр видео';

  @override
  String get filterFilesTooltip => 'Фильтр файлов';

  @override
  String get filterContactsTooltip => 'Фильтр контактов';

  @override
  String get filterLocationTooltip => 'Фильтр местоположений';

  @override
  String get movedToTrash => 'Перемещено в корзину';

  @override
  String get copiedNotesToClipboard => 'Скопировано в буфер обмена';

  @override
  String get locationShareLabel => 'Местоположение:';

  @override
  String get contactShareLabel => 'Контакт:';

  @override
  String get emailsShareLabel => 'Email-адреса:';

  @override
  String get addressesShareLabel => 'Адреса:';

  @override
  String get microphoneNotAvailable => 'Микрофон может быть недоступен.';

  @override
  String get microphonePermissionRequired => 'Для записи аудио требуется разрешение на использование микрофона.';

  @override
  String get couldNotGetDuration => 'Не удалось получить длительность';

  @override
  String get errorOpeningFiles => 'Ошибка при открытии файлов';

  @override
  String get pleaseWaitTitle => 'Пожалуйста, подождите';

  @override
  String get fileNotAvailableYet => 'Файл пока недоступен';

  @override
  String get clearSelectionTooltip => 'Очистить выбор';

  @override
  String get copyNotesTooltip => 'Копировать заметки';

  @override
  String get changeTaskTypeTooltip => 'Изменить тип задачи';

  @override
  String get shareNotesTooltip => 'Поделиться заметками';

  @override
  String get noNotesSelectedToShare => 'Не выбраны заметки для публикации';

  @override
  String get nothingToShare => 'Нечего публиковать';

  @override
  String get shareFailed => 'Ошибка публикации';

  @override
  String get editNoteTooltip => 'Редактировать заметку';

  @override
  String get starUnstarNotesTooltip => 'Добавить/удалить из избранного';

  @override
  String get moveToTrashTooltip => 'Переместить в корзину';

  @override
  String get pinUnpinNotesTooltip => 'Закрепить/открепить заметки';

  @override
  String get cancelReplyTooltip => 'Отменить ответ';

  @override
  String get createTaskHint => 'Создать задачу';

  @override
  String get addNoteHint => 'Добавить заметку...';

  @override
  String get attachTooltip => 'Прикрепить';

  @override
  String get addNoteTooltip => 'Добавить заметку';

  @override
  String get recordStopAudioTooltip => 'Записать/остановить аудио';

  @override
  String get contactAttachmentLabel => 'Контакт';

  @override
  String get locationAttachmentLabel => 'Местоположение';

  @override
  String get cameraAttachmentLabel => 'Камера';

  @override
  String get filesAttachmentLabel => 'Файлы';

  @override
  String get checklistAttachmentLabel => 'Чек-лист';

  @override
  String get accessKeyInputTitle => 'Включить синхронизацию';

  @override
  String get accessKeyInputDescription => 'Пожалуйста, введите вашу фразу для восстановления из 24 слов или загрузите .txt файл, содержащий ее.';

  @override
  String get editMenuItemLabel => 'Редактировать';

  @override
  String get filterMenuItemLabel => 'Фильтры';

  @override
  String get externalStoragePermissionDenied => 'В доступе к внешнему хранилищу отказано.';

  @override
  String get pressLongToStartRecording => 'Нажмите и удерживайте, чтобы начать запись.';

  @override
  String get didYouKnowTitle => 'А вы знали?';

  @override
  String get closeTooltip => 'Закрыть';

  @override
  String appDescriptionContent(String appName) {
    return '$appName — это полностью приватное приложение для заметок. Оно не собирает ваши личные данные и не показывает рекламу.\n\nНадеемся, вам понравится пользоваться им. Поделитесь своим мнением.';
  }

  @override
  String get searchNotesTooltip => 'Поиск заметок';

  @override
  String get syncMenuItemLabel => 'Синхронизация';

  @override
  String get trashMenuItemLabel => 'Корзина';

  @override
  String get starredNotesMenuItemLabel => 'Избранные заметки';

  @override
  String get settingsMenuItemLabel => 'Настройки';

  @override
  String get accountMenuItemLabel => 'Аккаунт';

  @override
  String get pageMenuItemLabel => 'Страница';

  @override
  String get sqliteMenuItemLabel => 'Sqlite';

  @override
  String get logsMenuItemLabel => 'Логи';

  @override
  String get reorderMenuItemLabel => 'Изменить порядок';

  @override
  String get editGroupMenuItemLabel => 'Редактировать';

  @override
  String get deleteGroupMenuItemLabel => 'Удалить';

  @override
  String get dragHandleReorderTooltip => 'Перетащите маркер, чтобы изменить порядок';

  @override
  String get holdAndDragReorderTooltip => 'Нажмите и перетащите, чтобы изменить порядок';

  @override
  String get emptyHomePageMessage => 'Привет!\n\nЗдесь пока пусто.\n\nНажмите кнопку +, чтобы создать свою первую заметку. :)';

  @override
  String get reorderingTitle => 'Изменение порядка';

  @override
  String get selectEllipsisLabel => 'Выбор...';

  @override
  String get dateTimeToggleLabel => 'Дата/время';

  @override
  String get noteBorderToggleLabel => 'Рамка заметки';

  @override
  String get deleteGroupButtonLabel => 'Удалить';

  @override
  String get notesTabLabel => 'Заметки';

  @override
  String get groupsTabLabel => 'Группы';

  @override
  String get categoriesTabLabel => 'Категории';

  @override
  String get locationItemLabel => 'Местоположение';

  @override
  String get addGroupTitle => 'Добавить группу';

  @override
  String get editGroupTitle => 'Редактировать группу';

  @override
  String get titleInputLabel => 'Заголовок';

  @override
  String get locationPermissionRequiredTitle => 'Требуется разрешение на доступ к местоположению';

  @override
  String get enableLocationPermissionsContent => 'Пожалуйста, включите разрешения на использование местоположения в настройках приложения.';

  @override
  String get cancelButtonLabel => 'Отмена';

  @override
  String get openSettingsButtonLabel => 'Открыть настройки';

  @override
  String get locationServicesTitle => 'Службы геолокации';

  @override
  String get pleaseEnableLocationServicesContent => 'Пожалуйста, включите!';

  @override
  String get selectLocationTitle => 'Выбрать местоположение';

  @override
  String get useCurrentLocationTooltip => 'Использовать текущее местоположение';

  @override
  String get selectAllButtonLabel => 'Выбрать все';

  @override
  String get searchLogsHint => 'Поиск по логам..';

  @override
  String get noLogsAvailable => 'Логи отсутствуют';

  @override
  String get dbViewerTitle => 'Просмотр БД';

  @override
  String get selectTableToViewData => 'Выберите таблицу, чтобы просмотреть данные';

  @override
  String get selectTableDropdownHint => 'Выберите таблицу';

  @override
  String get pickContactTitle => 'Выберите контакт';

  @override
  String get permissionRequiredText => 'Требуется разрешение';

  @override
  String get grantPermissionButtonLabel => 'Предоставить разрешение';

  @override
  String get pageDummyTitle => 'Тестовая страница';

  @override
  String get simulateButtonLabel => 'Симулировать';

  @override
  String get selectCategoryTitle => 'Выбрать категорию';

  @override
  String get addCategoryTitle => 'Добавить категорию';

  @override
  String get editCategoryTitle => 'Редактировать категорию';

  @override
  String get categoryTitleHint => 'Название категории';

  @override
  String get colorLabel => 'Цвет';

  @override
  String get changeColorLabel => 'Изменить цвет';

  @override
  String get deviceDisabledMessage => 'Устройство отключено!';

  @override
  String get cannotRemoveThisDeviceMessage => 'Невозможно удалить это устройство!';

  @override
  String get confirmRemoveTitle => 'Подтвердите удаление';

  @override
  String get confirmRemoveDeviceContent => 'Вы уверены? Это приведет к удалению всех данных на устройстве.';

  @override
  String get okButtonLabel => 'OK';

  @override
  String get registeredDevicesTitle => 'Зарегистрированные устройства';

  @override
  String get noDevicesFoundMessage => 'Устройства не найдены';

  @override
  String get enabledLabel => 'Включено';

  @override
  String get disabledLabel => 'Отключено';

  @override
  String get migratingMediaTitle => 'Миграция медиа';

  @override
  String get processingMessage => 'Обработка...';

  @override
  String get doNotNavigateAwayMessage => 'Пожалуйста, не закрывайте страницу';

  @override
  String errorWithDetails(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get sequenceNotAcceptedError => 'Последовательность не допускается';

  @override
  String get examplesNotAcceptedError => 'Примеры не допускаются';

  @override
  String get enterKeyAgainLabel => 'Введите ключ еще раз';

  @override
  String get pleaseEnterKeyAgainError => 'Пожалуйста, введите ключ еще раз';

  @override
  String get keysDoNotMatchError => 'Ключи не совпадают';

  @override
  String get ruleUppercaseLetter => '1 заглавная буква';

  @override
  String get ruleLowercaseLetter => '1 строчная буква';

  @override
  String get ruleNumericLetter => '1 цифра';

  @override
  String get ruleSpecialCharacter => '1 специальный символ';

  @override
  String get ruleMinTenCharacters => 'минимум 10 символов';

  @override
  String get examplesTitle => 'Примеры';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => 'Понятно';

  @override
  String get encryptionKeyTitle => 'Ключ шифрования';

  @override
  String get createKeyDescription => 'Пожалуйста, введите длинный и сложный для угадывания ключ (пароль). Не забудьте сохранить его в надежном месте. Если ключ будет потерян или забыт, восстановить его будет невозможно.';

  @override
  String get seeExamplesTooltip => 'Посмотреть примеры';

  @override
  String get couldNotFetchDetailsMessage => 'Не удалось получить информацию';

  @override
  String get retryButtonLabel => 'Повторить';

  @override
  String get signedInAsLabel => 'Вы вошли как:';

  @override
  String get storageUsageLabel => 'Использование хранилища';

  @override
  String get subscribeLabel => 'Подписаться';

  @override
  String get planExpiredRenewLabel => 'План истек! Продлить';

  @override
  String get manageDevicesLabel => 'Управление устройствами';

  @override
  String get viewAccessKeyLabel => 'Показать ключ доступа';

  @override
  String get changeKeyPasswordLabel => 'Изменить пароль ключа';

  @override
  String get manageSubscriptionLabel => 'Управление подпиской';

  @override
  String get signOutButtonLabel => 'Выйти';

  @override
  String get yearlyPlansTitle => 'Годовые планы';

  @override
  String get loginLabel => 'Войти';

  @override
  String get syncAllYourNotesLabel => 'Синхронизируйте все свои заметки';

  @override
  String get acrossYourDevicesLabel => 'на всех ваших устройствах';

  @override
  String get featureEndToEndEncryption => 'Сквозное шифрование';

  @override
  String get featureSyncUpTo3Devices => 'Синхронизация до 3 устройств';

  @override
  String get featureUpgradeCancelAnytime => 'Улучшение/Отмена в любое время';

  @override
  String get noPlansAvailableMessage => 'Планы отсутствуют';

  @override
  String get downloadAppSubscribeLabel => 'Скачайте приложение и подпишитесь';

  @override
  String get privacyTermsLabel => 'Конфиденциальность • Условия';

  @override
  String get saveFiftyPercentLabel => 'Скидка 50%';

  @override
  String get helloTitle => 'Привет';

  @override
  String get selectKeyMasterKeyDescription => 'Для шифрования ваших данных нам понадобится мастер-ключ.';

  @override
  String get selectKeyTwoOptionsDescription => 'Есть 2 варианта: вы можете создать ключ самостоятельно (как пароль) или мы создадим его для вас.';

  @override
  String get understandLoseKeyAcknowledgement => 'Я понимаю, что если я потеряю/забуду ключ шифрования, я могу потерять доступ к данным.';

  @override
  String get createKeyForMeButtonLabel => 'Создать ключ для меня';

  @override
  String get recommendedLabel => '(Рекомендуется)';

  @override
  String get pleaseAcknowledgeMessage => 'Пожалуйста, подтвердите!';

  @override
  String get createKeyMyselfButtonLabel => 'Я создам ключ сам';

  @override
  String welcomeToAppName(String appName) {
    return 'Добро пожаловать в $appName';
  }

  @override
  String get e2eEncryptionDescription => 'Мы используем сквозное шифрование, чтобы гарантировать, что все ваши заметки в безопасности и никто, даже мы, не может их прочитать.';

  @override
  String get timeToStartEncryptionLabel => 'Время начать шифрование!';

  @override
  String get nextButtonLabel => 'Далее';

  @override
  String get sendingOtpFailedMessage => 'Не удалось отправить OTP. Попробуйте еще раз!';

  @override
  String get otpVerificationFailedMessage => 'Проверка OTP не удалась. Попробуйте еще раз!';

  @override
  String get emailSignInTitle => 'Вход по Email';

  @override
  String get verifyOtpLabel => 'Проверить OTP';

  @override
  String get enterEmailLabel => 'Введите Email';

  @override
  String get sendOtpLabel => 'Отправить OTP';

  @override
  String otpSentToEmailMessage(String email) {
    return 'Мы отправили одноразовый пароль (OTP) на вашу почту $email';
  }

  @override
  String get enterOtpLabel => 'Введите OTP';

  @override
  String get changeEmailLabel => 'Изменить Email';

  @override
  String get encryptingNotesTitle => 'Шифрование заметок';

  @override
  String get fetchingDetailsTitle => 'Получение информации';

  @override
  String get couldNotFetchMessage => 'Не удалось получить данные';

  @override
  String get subscriptionEmailMismatchMessage => 'Ваша подписка привязана к другому email. Пожалуйста, выйдите из аккаунта и войдите через нужную почту, чтобы включить облачное хранилище.';

  @override
  String get errorCheckingPlanDetailsMessage => 'Ошибка при проверке деталей подписки';

  @override
  String get registerDeviceTitle => 'Регистрация устройства';

  @override
  String get manageButtonLabel => 'Управление';

  @override
  String get fetchingKeysTitle => 'Получение ключей';

  @override
  String get signingOutTitle => 'Выход из аккаунта';

  @override
  String get pleaseCheckInternetMessage => 'Пожалуйста, проверьте интернет';

  @override
  String get somethingWentWrongMessage => 'Что-то пошло не так';

  @override
  String get playPauseTooltip => 'Воспроизведение/пауза';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => 'Скачать';

  @override
  String get invalidAccessKey => 'Неверный ключ доступа';

  @override
  String get fileDoesNotContain24Words => 'Файл не содержит ровно 24 слова.';

  @override
  String get errorReadingFile => 'Ошибка при чтении файла';

  @override
  String get allLabel => 'Все';

  @override
  String get logTypeDebug => 'DEBUG';

  @override
  String get logTypeError => 'ERROR';

  @override
  String get logTypeInfo => 'INFO';

  @override
  String get logTypeWarning => 'WARNING';

  @override
  String get groupTitleHint => 'Название группы';

  @override
  String get categoryLabel => 'Категория';

  @override
  String get selectCategoryPlaceholder => 'Выберите категорию';

  @override
  String storageBytesFormat(String bytes) {
    return '$bytes Б';
  }

  @override
  String storageKilobytesFormat(String kb) {
    return '$kb КБ';
  }

  @override
  String storageMegabytesFormat(String mb) {
    return '$mb МБ';
  }

  @override
  String storageGigabytesFormat(String gb) {
    return '$gb ГБ';
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
  String get searchHint => 'запрос, #документ и т.д..';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => 'Аудиофайл';

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
  String get selectLanguageTitle => 'Выберите язык';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get themeLabel => 'Тема';

  @override
  String get dayNightThemeTooltip => 'Дневная/ночная тема';

  @override
  String get lockLabel => 'Блокировка';

  @override
  String get timeFormatLabel => 'Формат времени';

  @override
  String get h12Label => '12-часовой';

  @override
  String get h24Label => '24-часовой';

  @override
  String get fontSizeLabel => 'Размер шрифта';

  @override
  String get reduceTextSizeTooltip => 'Уменьшить шрифт';

  @override
  String get increaseTextSizeTooltip => 'Увеличить шрифт';

  @override
  String get languageLabel => 'Язык';

  @override
  String get autoOpenGroupLabel => 'Автооткрытие группы';

  @override
  String get selectGroupTitle => 'Выберите группу';

  @override
  String shareAppMessage(String appName, String appLink) {
    return 'Попробуйте $appName: $appLink';
  }

  @override
  String get noteTypeEmpty => 'Пусто';

  @override
  String get noteTypeImage => 'Изображение';

  @override
  String get noteTypeVideo => 'Видео';

  @override
  String get noteTypeAudio => 'Аудио';

  @override
  String get noteTypeDocument => 'Документ';

  @override
  String get noteTypeContact => 'Контакт';

  @override
  String get noteTypeLocation => 'Местоположение';

  @override
  String get noteTypeUnknown => 'Неизвестно';

  @override
  String get pleaseEnterData => 'Пожалуйста, введите данные';

  @override
  String get aNumber => 'Число';

  @override
  String get enterDataLabel => 'Введите данные';

  @override
  String get pleaseEnterValidData => 'Пожалуйста, введите корректные данные';

  @override
  String get pleaseSelectAnOption => 'Пожалуйста, выберите вариант';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => 'Сегодня';

  @override
  String get yesterdayLabel => 'Вчера';

  @override
  String get mondayLabel => 'Понедельник';

  @override
  String get tuesdayLabel => 'Вторник';

  @override
  String get wednesdayLabel => 'Среда';

  @override
  String get thursdayLabel => 'Четверг';

  @override
  String get fridayLabel => 'Пятница';

  @override
  String get saturdayLabel => 'Суббота';

  @override
  String get sundayLabel => 'Воскресенье';

  @override
  String get januaryShortLabel => 'Янв';

  @override
  String get februaryShortLabel => 'Фев';

  @override
  String get marchShortLabel => 'Мар';

  @override
  String get aprilShortLabel => 'Апр';

  @override
  String get mayShortLabel => 'Май';

  @override
  String get juneShortLabel => 'Июн';

  @override
  String get julyShortLabel => 'Июл';

  @override
  String get augustShortLabel => 'Авг';

  @override
  String get septemberShortLabel => 'Сен';

  @override
  String get octoberShortLabel => 'Окт';

  @override
  String get novemberShortLabel => 'Ноя';

  @override
  String get decemberShortLabel => 'Дек';

  @override
  String noteGroupDateTitleFormat(String month, String day, String dayOfWeek) {
    return '$day $month, $dayOfWeek';
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
  String get fileSizeZero => '0 Б';

  @override
  String get fileSizeUnitBytes => 'Б';

  @override
  String get fileSizeUnitKilobytes => 'КБ';

  @override
  String get fileSizeUnitMegabytes => 'МБ';

  @override
  String get fileSizeUnitGigabytes => 'ГБ';

  @override
  String get fileSizeUnitTerabytes => 'ТБ';

  @override
  String fileSizeFormat(String size, String suffix) {
    return '$size $suffix';
  }

  @override
  String noteGroupCountSingle(int count) {
    return '$count группа заметок';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count групп заметок';
  }

  @override
  String get seedCategoryTasks => 'Задачи';

  @override
  String get seedGroupNotes => 'Заметки';

  @override
  String get seedGroupFitness => 'Фитнес';

  @override
  String get seedItemWelcome => 'Добро пожаловать в Note Safe!\nЗаписывайте сюда любые идеи, списки и всё, что у вас на уме.\n\nУдерживайте заметку, чтобы удалить, изменить её или открыть другие параметры.';

  @override
  String get seedItemMorningWorkout => 'Утренняя тренировка';

  @override
  String get seedItemMeditation => '10 минут медитации';

  @override
  String get seedItemWater => '2 л воды в день';

  @override
  String get seedItemSteps => 'Пройти 10 000 шагов';
}

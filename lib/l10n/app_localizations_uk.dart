// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get importantTitle => 'Важливо';

  @override
  String get accessKeyNoticeDescription1 => 'На наступній сторінці ви побачите 24 слова. Це ваш унікальний і приватний ключ шифрування, і це ЄДИНИЙ спосіб відновити ваші нотатки у разі виходу з облікового запису, втрати чи поломки пристрою.';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return 'Ми не зберігаємо цей ключ. Вашим обов\'язком є зберегти його в надійному місці поза межами програми $appName.';
  }

  @override
  String get iUnderstandShowMeTheKey => 'Я розумію.\nПоказати ключ.';

  @override
  String get selectGroupToViewNotes => 'Виберіть групу, щоб переглянути нотатки';

  @override
  String get accessKeyShareText => 'Ось ваш ключ доступу.';

  @override
  String get pleaseTryAgain => 'Будь ласка, спробуйте ще раз.';

  @override
  String get copiedToClipboard => 'Скопійовано в буфер обміну';

  @override
  String get accessKeyTitle => 'Ключ доступу';

  @override
  String get accessKeyDescription => 'Будь ласка, збережіть цей ключ у надійному місці. Він знадобиться вам для синхронізації нотаток на іншому пристрої.';

  @override
  String get copyLabel => 'Копіювати';

  @override
  String get downloadAsTextFileLabel => 'Завантажити як текстовий файл';

  @override
  String get continueLabel => 'Продовжити';

  @override
  String get pleaseAuthenticate => 'Будь ласка, пройдіть автентифікацію';

  @override
  String get couldNotCreate => 'Не вдалося створити';

  @override
  String get couldNotShareFile => 'Не вдалося поділитися файлом';

  @override
  String get hereIsTheBackupFile => 'Ось файл резервної копії для вашої програми.';

  @override
  String get errorTitle => 'Помилка';

  @override
  String get backupLabel => 'Резервна копія';

  @override
  String get restoreLabel => 'Відновити';

  @override
  String get leaveAReviewLabel => 'Залишити відгук';

  @override
  String get shareLabel => 'Поділитися';

  @override
  String get desktopAppLinkLabel => 'Десктопна версія';

  @override
  String get loggingLabel => 'Ведення журналів';

  @override
  String versionLabel(String version) {
    return 'Версія: $version';
  }

  @override
  String get loadingLabel => 'Завантаження...';

  @override
  String get restoredLabel => 'Відновлено.';

  @override
  String get deletedPermanentlyLabel => 'Видалено назавжди.';

  @override
  String get mediaTitle => 'Медіа';

  @override
  String get invalidWordList => 'Недійсний список слів';

  @override
  String get enterYour24WordPhrase => 'Введіть вашу фразу з 24 слів';

  @override
  String get enterYourRecoveryPhraseHere => 'Введіть вашу фразу відновлення тут';

  @override
  String get pleaseEnterYourRecoveryPhrase => 'Будь ласка, введіть фразу відновлення';

  @override
  String get recoveryPhraseMustContain24Words => 'Фраза відновлення повинна містити рівно 24 слова';

  @override
  String get submitLabel => 'Надіслати';

  @override
  String get orLabel => 'Або';

  @override
  String get selectTxtFileLabel => 'Вибрати .txt файл';

  @override
  String get failureTitle => 'Помилка';

  @override
  String get invalidPasswordKey => 'Недійсний пароль-ключ';

  @override
  String get enableSyncTitle => 'Увімкнути синхронізацію';

  @override
  String get passwordRequirementsDescription => 'Будь ласка, введіть створений вами ключ (пароль). Він повинен містити мінімум 10 символів, включаючи принаймні 1 цифру, 1 малу літеру, 1 велику літеру та 1 спеціальний символ.';

  @override
  String get enterKeyLabel => 'Введіть ключ';

  @override
  String get pleaseEnterKey => 'Будь ласка, введіть ключ';

  @override
  String get filterNotesTitle => 'Фільтрувати нотатки';

  @override
  String get filterPinnedNotesTooltip => 'Фільтрувати закріплені нотатки';

  @override
  String get filterStarredNotesTooltip => 'Фільтрувати обрані нотатки';

  @override
  String get filterTextNotesTooltip => 'Фільтрувати текстові нотатки';

  @override
  String get filterTasksTooltip => 'Фільтрувати завдання';

  @override
  String get filterLinksTooltip => 'Фільтрувати посилання';

  @override
  String get filterImagesTooltip => 'Фільтрувати зображення';

  @override
  String get filterAudioTooltip => 'Фільтрувати аудіо';

  @override
  String get filterVideoTooltip => 'Фільтрувати відео';

  @override
  String get filterFilesTooltip => 'Фільтрувати файли';

  @override
  String get filterContactsTooltip => 'Фільтрувати контакти';

  @override
  String get filterLocationTooltip => 'Фільтрувати місцезнаходження';

  @override
  String get movedToTrash => 'Переміщено в кошик';

  @override
  String get copiedNotesToClipboard => 'Скопійовано в буфер обміну';

  @override
  String get locationShareLabel => 'Місцезнаходження:';

  @override
  String get contactShareLabel => 'Контакт:';

  @override
  String get emailsShareLabel => 'Ел. пошта:';

  @override
  String get addressesShareLabel => 'Адреси:';

  @override
  String get microphoneNotAvailable => 'Мікрофон може бути недоступний.';

  @override
  String get microphonePermissionRequired => 'Для запису аудіо потрібен дозвіл на використання мікрофона.';

  @override
  String get couldNotGetDuration => 'Не вдалося отримати тривалість';

  @override
  String get errorOpeningFiles => 'Помилка при відкритті файлів';

  @override
  String get pleaseWaitTitle => 'Будь ласка, зачекайте';

  @override
  String get fileNotAvailableYet => 'Файл ще не доступний';

  @override
  String get clearSelectionTooltip => 'Очистити вибір';

  @override
  String get copyNotesTooltip => 'Копіювати нотатки';

  @override
  String get changeTaskTypeTooltip => 'Змінити тип завдання';

  @override
  String get shareNotesTooltip => 'Поділитися нотатками';

  @override
  String get editNoteTooltip => 'Редагувати нотатку';

  @override
  String get starUnstarNotesTooltip => 'Додати/прибрати з обраного';

  @override
  String get moveToTrashTooltip => 'Перемістити в кошик';

  @override
  String get pinUnpinNotesTooltip => 'Закріпити/відкріпити нотатки';

  @override
  String get cancelReplyTooltip => 'Скасувати відповідь';

  @override
  String get createTaskHint => 'Створити завдання';

  @override
  String get addNoteHint => 'Додати нотатку...';

  @override
  String get attachTooltip => 'Прикріпити';

  @override
  String get addNoteTooltip => 'Додати нотатку';

  @override
  String get recordStopAudioTooltip => 'Запис/зупинка аудіо';

  @override
  String get contactAttachmentLabel => 'Контакт';

  @override
  String get locationAttachmentLabel => 'Місцезнаходження';

  @override
  String get cameraAttachmentLabel => 'Камера';

  @override
  String get filesAttachmentLabel => 'Файли';

  @override
  String get checklistAttachmentLabel => 'Чек-лист';

  @override
  String get accessKeyInputTitle => 'Увімкнути синхронізацію';

  @override
  String get accessKeyInputDescription => 'Будь ласка, введіть вашу фразу відновлення з 24 слів або завантажте .txt файл, що її містить.';

  @override
  String get editMenuItemLabel => 'Редагувати';

  @override
  String get filterMenuItemLabel => 'Фільтри';

  @override
  String get externalStoragePermissionDenied => 'У доступі до зовнішнього сховища було відмовлено.';

  @override
  String get pressLongToStartRecording => 'Натисніть і утримуйте, щоб почати запис.';

  @override
  String get didYouKnowTitle => 'Чи знаєте ви?';

  @override
  String get closeTooltip => 'Закрити';

  @override
  String appDescriptionContent(String appName) {
    return '$appName — це повністю приватна програма для нотаток. Вона не збирає ваші особисті дані та не показує рекламу.\n\nСподіваємося, вам сподобається її використовувати. Розкажіть, що ви думаєте.';
  }

  @override
  String get searchNotesTooltip => 'Пошук нотаток';

  @override
  String get syncMenuItemLabel => 'Синхронізація';

  @override
  String get trashMenuItemLabel => 'Кошик';

  @override
  String get starredNotesMenuItemLabel => 'Обрані нотатки';

  @override
  String get settingsMenuItemLabel => 'Налаштування';

  @override
  String get accountMenuItemLabel => 'Обліковий запис';

  @override
  String get pageMenuItemLabel => 'Сторінка';

  @override
  String get sqliteMenuItemLabel => 'Sqlite';

  @override
  String get logsMenuItemLabel => 'Журнали';

  @override
  String get reorderMenuItemLabel => 'Змінити порядок';

  @override
  String get editGroupMenuItemLabel => 'Редагувати';

  @override
  String get deleteGroupMenuItemLabel => 'Видалити';

  @override
  String get dragHandleReorderTooltip => 'Перетягніть, щоб змінити порядок';

  @override
  String get holdAndDragReorderTooltip => 'Натисніть і перетягніть, щоб змінити порядок';

  @override
  String get emptyHomePageMessage => 'Привіт!\n\nТут поки що порожньо.\n\nНатисніть кнопку +, щоб створити перші нотатки. :)';

  @override
  String get reorderingTitle => 'Зміна порядку';

  @override
  String get selectEllipsisLabel => 'Вибрати...';

  @override
  String get dateTimeToggleLabel => 'Дата/час';

  @override
  String get noteBorderToggleLabel => 'Межі нотатки';

  @override
  String get deleteGroupButtonLabel => 'Видалити';

  @override
  String get notesTabLabel => 'Нотатки';

  @override
  String get groupsTabLabel => 'Групи';

  @override
  String get categoriesTabLabel => 'Категорії';

  @override
  String get locationItemLabel => 'Місцезнаходження';

  @override
  String get addGroupTitle => 'Додати групу';

  @override
  String get editGroupTitle => 'Редагувати групу';

  @override
  String get titleInputLabel => 'Назва';

  @override
  String get locationPermissionRequiredTitle => 'Потрібен дозвіл на місцезнаходження';

  @override
  String get enableLocationPermissionsContent => 'Будь ласка, увімкніть дозвіл на визначення місцезнаходження в налаштуваннях програми.';

  @override
  String get cancelButtonLabel => 'Скасувати';

  @override
  String get openSettingsButtonLabel => 'Відкрити налаштування';

  @override
  String get locationServicesTitle => 'Служби визначення місцезнаходження';

  @override
  String get pleaseEnableLocationServicesContent => 'Будь ласка, увімкніть їх!';

  @override
  String get selectLocationTitle => 'Вибрати місцезнаходження';

  @override
  String get useCurrentLocationTooltip => 'Використати поточне місцезнаходження';

  @override
  String get selectAllButtonLabel => 'Вибрати все';

  @override
  String get searchLogsHint => 'Пошук у журналах..';

  @override
  String get noLogsAvailable => 'Немає доступних журналів';

  @override
  String get dbViewerTitle => 'Перегляд БД';

  @override
  String get selectTableToViewData => 'Виберіть таблицю для перегляду даних';

  @override
  String get selectTableDropdownHint => 'Вибрати таблицю';

  @override
  String get pickContactTitle => 'Вибрати контакт';

  @override
  String get permissionRequiredText => 'Потрібен дозвіл';

  @override
  String get grantPermissionButtonLabel => 'Надати дозвіл';

  @override
  String get pageDummyTitle => 'Заглушка сторінки';

  @override
  String get simulateButtonLabel => 'Симулювати';

  @override
  String get selectCategoryTitle => 'Вибрати категорію';

  @override
  String get addCategoryTitle => 'Додати категорію';

  @override
  String get editCategoryTitle => 'Редагувати категорію';

  @override
  String get categoryTitleHint => 'Назва категорії';

  @override
  String get colorLabel => 'Колір';

  @override
  String get changeColorLabel => 'Змінити колір';

  @override
  String get deviceDisabledMessage => 'Пристрій вимкнено!';

  @override
  String get cannotRemoveThisDeviceMessage => 'Не можна видалити цей пристрій!';

  @override
  String get confirmRemoveTitle => 'Підтвердити видалення';

  @override
  String get confirmRemoveDeviceContent => 'Ви впевнені? Це призведе до видалення всіх даних на пристрої.';

  @override
  String get okButtonLabel => 'ОК';

  @override
  String get registeredDevicesTitle => 'Зареєстровані пристрої';

  @override
  String get noDevicesFoundMessage => 'Пристроїв не знайдено';

  @override
  String get enabledLabel => 'Увімкнено';

  @override
  String get disabledLabel => 'Вимкнено';

  @override
  String get migratingMediaTitle => 'Міграція медіа';

  @override
  String get processingMessage => 'Обробка...';

  @override
  String get doNotNavigateAwayMessage => 'Будь ласка, не покидайте сторінку';

  @override
  String errorWithDetails(String error) {
    return 'Помилка: $error';
  }

  @override
  String get sequenceNotAcceptedError => 'Послідовність не прийнята';

  @override
  String get examplesNotAcceptedError => 'Приклади не прийняті';

  @override
  String get enterKeyAgainLabel => 'Введіть ключ ще раз';

  @override
  String get pleaseEnterKeyAgainError => 'Будь ласка, введіть ключ ще раз';

  @override
  String get keysDoNotMatchError => 'Ключі не збігаються';

  @override
  String get ruleUppercaseLetter => '1 велика літера';

  @override
  String get ruleLowercaseLetter => '1 мала літера';

  @override
  String get ruleNumericLetter => '1 цифра';

  @override
  String get ruleSpecialCharacter => '1 спеціальний символ';

  @override
  String get ruleMinTenCharacters => 'мін 10 символів';

  @override
  String get examplesTitle => 'Приклади';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => 'Зрозуміло';

  @override
  String get encryptionKeyTitle => 'Ключ шифрування';

  @override
  String get createKeyDescription => 'Будь ласка, введіть довгий і складний ключ (пароль). Не забудьте зберегти його в надійному місці. Якщо він буде втрачений або забутий, його неможливо відновити.';

  @override
  String get seeExamplesTooltip => 'Дивитися приклади';

  @override
  String get couldNotFetchDetailsMessage => 'Не вдалося отримати дані';

  @override
  String get retryButtonLabel => 'Повторити';

  @override
  String get signedInAsLabel => 'Ви увійшли як:';

  @override
  String get storageUsageLabel => 'Використання сховища';

  @override
  String get subscribeLabel => 'Підписатися';

  @override
  String get planExpiredRenewLabel => 'Термін дії плану закінчився! Оновити';

  @override
  String get manageDevicesLabel => 'Керування пристроями';

  @override
  String get viewAccessKeyLabel => 'Переглянути ключ доступу';

  @override
  String get changeKeyPasswordLabel => 'Змінити ключ-пароль';

  @override
  String get manageSubscriptionLabel => 'Керування підпискою';

  @override
  String get signOutButtonLabel => 'Вийти';

  @override
  String get yearlyPlansTitle => 'Річні плани';

  @override
  String get loginLabel => 'Вхід';

  @override
  String get syncAllYourNotesLabel => 'Синхронізуйте всі свої нотатки';

  @override
  String get acrossYourDevicesLabel => 'на всіх ваших пристроях';

  @override
  String get featureEndToEndEncryption => 'Наскрізне шифрування';

  @override
  String get featureSyncUpTo3Devices => 'Синхронізація до 3 пристроїв';

  @override
  String get featureUpgradeCancelAnytime => 'Оновлення/скасування в будь-який час';

  @override
  String get noPlansAvailableMessage => 'Немає доступних планів';

  @override
  String get downloadAppSubscribeLabel => 'Завантажте програму та підпишіться';

  @override
  String get privacyTermsLabel => 'Конфіденційність • Умови';

  @override
  String get saveFiftyPercentLabel => 'Економія 50%';

  @override
  String get helloTitle => 'Вітаємо';

  @override
  String get selectKeyMasterKeyDescription => 'Щоб зашифрувати ваші дані, нам знадобиться майстер-ключ шифрування.';

  @override
  String get selectKeyTwoOptionsDescription => 'Є 2 варіанти: або ви створюєте ключ самостійно (як пароль), або ми створюємо його за вас.';

  @override
  String get understandLoseKeyAcknowledgement => 'Я розумію, що якщо втрачу/забуду ключ шифрування, я можу втратити дані.';

  @override
  String get createKeyForMeButtonLabel => 'Створити ключ за мене';

  @override
  String get recommendedLabel => '(Рекомендовано)';

  @override
  String get pleaseAcknowledgeMessage => 'Будь ласка, підтвердіть!';

  @override
  String get createKeyMyselfButtonLabel => 'Я створю ключ самостійно';

  @override
  String welcomeToAppName(String appName) {
    return 'Ласкаво просимо до $appName';
  }

  @override
  String get e2eEncryptionDescription => 'Ми використовуємо наскрізне шифрування, щоб гарантувати безпеку ваших нотаток. Ніхто інший, навіть ми, не може їх побачити.';

  @override
  String get timeToStartEncryptionLabel => 'Час почати шифрування!';

  @override
  String get nextButtonLabel => 'Далі';

  @override
  String get sendingOtpFailedMessage => 'Не вдалося надіслати OTP. Будь ласка, спробуйте ще раз!';

  @override
  String get otpVerificationFailedMessage => 'Перевірка OTP не вдалася. Будь ласка, спробуйте ще раз!';

  @override
  String get emailSignInTitle => 'Вхід через Email';

  @override
  String get verifyOtpLabel => 'Перевірити OTP';

  @override
  String get enterEmailLabel => 'Введіть Email';

  @override
  String get sendOtpLabel => 'Надіслати OTP';

  @override
  String otpSentToEmailMessage(String email) {
    return 'Ми надіслали одноразовий пароль (OTP) на вашу електронну пошту $email';
  }

  @override
  String get enterOtpLabel => 'Введіть OTP';

  @override
  String get changeEmailLabel => 'Змінити email';

  @override
  String get encryptingNotesTitle => 'Шифрування нотаток';

  @override
  String get fetchingDetailsTitle => 'Отримання даних';

  @override
  String get couldNotFetchMessage => 'Не вдалося отримати';

  @override
  String get subscriptionEmailMismatchMessage => 'Ваша підписка прив\'язана до іншої електронної адреси. Будь ласка, вийдіть і використайте її для увімкнення хмарного сховища.';

  @override
  String get errorCheckingPlanDetailsMessage => 'Помилка при перевірці даних плану';

  @override
  String get registerDeviceTitle => 'Реєстрація пристрою';

  @override
  String get manageButtonLabel => 'Керувати';

  @override
  String get fetchingKeysTitle => 'Отримання ключів';

  @override
  String get signingOutTitle => 'Вихід';

  @override
  String get pleaseCheckInternetMessage => 'Будь ласка, перевірте інтернет-з\'єднання';

  @override
  String get somethingWentWrongMessage => 'Щось пішло не так';

  @override
  String get playPauseTooltip => 'Відтворити/пауза';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => 'Завантажити';

  @override
  String get invalidAccessKey => 'Недійсний ключ доступу';

  @override
  String get fileDoesNotContain24Words => 'Файл не містить рівно 24 слів.';

  @override
  String get errorReadingFile => 'Помилка при читанні файлу';

  @override
  String get allLabel => 'Усі';

  @override
  String get logTypeDebug => 'DEBUG';

  @override
  String get logTypeError => 'ERROR';

  @override
  String get logTypeInfo => 'INFO';

  @override
  String get logTypeWarning => 'WARNING';

  @override
  String get groupTitleHint => 'Назва групи';

  @override
  String get categoryLabel => 'Категорія';

  @override
  String get selectCategoryPlaceholder => 'Вибрати категорію';

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
  String get searchHint => 'запит, #документ тощо..';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => 'Аудіофайл';

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
  String get selectLanguageTitle => 'Вибрати мову';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get themeLabel => 'Тема';

  @override
  String get dayNightThemeTooltip => 'Денна/нічна тема';

  @override
  String get lockLabel => 'Блокування';

  @override
  String get timeFormatLabel => 'Формат часу';

  @override
  String get h12Label => '12-годинний';

  @override
  String get h24Label => '24-годинний';

  @override
  String get fontSizeLabel => 'Розмір шрифту';

  @override
  String get reduceTextSizeTooltip => 'Зменшити розмір тексту';

  @override
  String get increaseTextSizeTooltip => 'Збільшити розмір тексту';

  @override
  String get languageLabel => 'Мова';

  @override
  String get autoOpenGroupLabel => 'Автоматично відкривати групу';

  @override
  String get selectGroupTitle => 'Вибрати групу';

  @override
  String shareAppMessage(String appName, String appLink) {
    return 'Спробуйте $appName: $appLink';
  }

  @override
  String get noteTypeEmpty => 'Порожньо';

  @override
  String get noteTypeImage => 'Зображення';

  @override
  String get noteTypeVideo => 'Відео';

  @override
  String get noteTypeAudio => 'Аудіо';

  @override
  String get noteTypeDocument => 'Документ';

  @override
  String get noteTypeContact => 'Контакт';

  @override
  String get noteTypeLocation => 'Місцезнаходження';

  @override
  String get noteTypeUnknown => 'Невідомо';

  @override
  String get pleaseEnterData => 'Будь ласка, введіть дані';

  @override
  String get aNumber => 'Число';

  @override
  String get enterDataLabel => 'Введіть дані';

  @override
  String get pleaseEnterValidData => 'Будь ласка, введіть дійсні дані';

  @override
  String get pleaseSelectAnOption => 'Будь ласка, виберіть варіант';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => 'Сьогодні';

  @override
  String get yesterdayLabel => 'Вчора';

  @override
  String get mondayLabel => 'Понеділок';

  @override
  String get tuesdayLabel => 'Вівторок';

  @override
  String get wednesdayLabel => 'Середа';

  @override
  String get thursdayLabel => 'Четвер';

  @override
  String get fridayLabel => 'П\'ятниця';

  @override
  String get saturdayLabel => 'Субота';

  @override
  String get sundayLabel => 'Неділя';

  @override
  String get januaryShortLabel => 'Січ';

  @override
  String get februaryShortLabel => 'Лют';

  @override
  String get marchShortLabel => 'Бер';

  @override
  String get aprilShortLabel => 'Кві';

  @override
  String get mayShortLabel => 'Тра';

  @override
  String get juneShortLabel => 'Чер';

  @override
  String get julyShortLabel => 'Лип';

  @override
  String get augustShortLabel => 'Сер';

  @override
  String get septemberShortLabel => 'Вер';

  @override
  String get octoberShortLabel => 'Жов';

  @override
  String get novemberShortLabel => 'Лис';

  @override
  String get decemberShortLabel => 'Гру';

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
    return '$count група нотаток';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count груп нотаток';
  }
}

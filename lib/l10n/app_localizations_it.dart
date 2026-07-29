// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get importantTitle => 'Importante';

  @override
  String get accessKeyNoticeDescription1 => 'Nella prossima pagina vedrai una serie di 24 parole. Questa è la tua chiave di cifratura univoca e privata ed è l\'UNICO modo per recuperare le tue note in caso di disconnessione, smarrimento o malfunzionamento del dispositivo.';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return 'Non memorizziamo la chiave. È TUA responsabilità conservarla in un luogo sicuro al di fuori dell\'app $appName.';
  }

  @override
  String get iUnderstandShowMeTheKey => 'Ho capito.\nMostrami la chiave.';

  @override
  String get selectGroupToViewNotes => 'Seleziona un gruppo per vedere le note';

  @override
  String get accessKeyShareText => 'Ecco la tua chiave di accesso.';

  @override
  String get pleaseTryAgain => 'Per favore, riprova.';

  @override
  String get copiedToClipboard => 'Copiato negli appunti';

  @override
  String get accessKeyTitle => 'Chiave di accesso';

  @override
  String get accessKeyDescription => 'Per favore, salva questa chiave in un posto sicuro. Ti servirà per sincronizzare le note su un altro dispositivo.';

  @override
  String get copyLabel => 'Copia';

  @override
  String get downloadAsTextFileLabel => 'Scarica come file di testo';

  @override
  String get continueLabel => 'Continua';

  @override
  String get pleaseAuthenticate => 'Per favore, autenticati';

  @override
  String get couldNotCreate => 'Impossibile creare';

  @override
  String get couldNotShareFile => 'Impossibile condividere il file';

  @override
  String get hereIsTheBackupFile => 'Ecco il file di backup per la tua app.';

  @override
  String get errorTitle => 'Errore';

  @override
  String get backupLabel => 'Backup';

  @override
  String get restoreLabel => 'Ripristina';

  @override
  String get leaveAReviewLabel => 'Lascia una recensione';

  @override
  String get shareLabel => 'Condividi';

  @override
  String get desktopAppLinkLabel => 'App Desktop';

  @override
  String get loggingLabel => 'Logging';

  @override
  String versionLabel(String version) {
    return 'Versione: $version';
  }

  @override
  String get loadingLabel => 'Caricamento...';

  @override
  String get restoredLabel => 'Ripristinato.';

  @override
  String get deletedPermanentlyLabel => 'Eliminato definitivamente.';

  @override
  String get mediaTitle => 'Media';

  @override
  String get invalidWordList => 'Lista di parole non valida';

  @override
  String get enterYour24WordPhrase => 'Inserisci la tua frase di 24 parole';

  @override
  String get enterYourRecoveryPhraseHere => 'Inserisci qui la tua frase di recupero';

  @override
  String get pleaseEnterYourRecoveryPhrase => 'Per favore, inserisci la tua frase di recupero';

  @override
  String get recoveryPhraseMustContain24Words => 'La frase di recupero deve contenere esattamente 24 parole';

  @override
  String get submitLabel => 'Invia';

  @override
  String get orLabel => 'O';

  @override
  String get selectTxtFileLabel => 'Seleziona file .txt';

  @override
  String get failureTitle => 'Fallito';

  @override
  String get invalidPasswordKey => 'Chiave password non valida';

  @override
  String get enableSyncTitle => 'Abilita sincronizzazione';

  @override
  String get passwordRequirementsDescription => 'Per favore, inserisci la chiave (password) che hai creato. Deve essere lunga almeno 10 caratteri con almeno 1 numero, 1 lettera minuscola, 1 maiuscola e 1 carattere speciale.';

  @override
  String get enterKeyLabel => 'Inserisci chiave';

  @override
  String get pleaseEnterKey => 'Per favore, inserisci la chiave';

  @override
  String get filterNotesTitle => 'Filtra note';

  @override
  String get filterPinnedNotesTooltip => 'Filtra note fissate';

  @override
  String get filterStarredNotesTooltip => 'Filtra note preferite';

  @override
  String get filterTextNotesTooltip => 'Filtra note testuali';

  @override
  String get filterTasksTooltip => 'Filtra attività';

  @override
  String get filterLinksTooltip => 'Filtra link';

  @override
  String get filterImagesTooltip => 'Filtra immagini';

  @override
  String get filterAudioTooltip => 'Filtra audio';

  @override
  String get filterVideoTooltip => 'Filtra video';

  @override
  String get filterFilesTooltip => 'Filtra file';

  @override
  String get filterContactsTooltip => 'Filtra contatti';

  @override
  String get filterLocationTooltip => 'Filtra posizione';

  @override
  String get movedToTrash => 'Spostato nel cestino';

  @override
  String get copiedNotesToClipboard => 'Copiato negli appunti';

  @override
  String get locationShareLabel => 'Posizione:';

  @override
  String get contactShareLabel => 'Contatto:';

  @override
  String get emailsShareLabel => 'Email:';

  @override
  String get addressesShareLabel => 'Indirizzi:';

  @override
  String get microphoneNotAvailable => 'Il microfono potrebbe non essere disponibile.';

  @override
  String get microphonePermissionRequired => 'È richiesta l\'autorizzazione del microfono per registrare audio.';

  @override
  String get couldNotGetDuration => 'Impossibile ottenere la durata';

  @override
  String get errorOpeningFiles => 'Errore durante l\'apertura dei file';

  @override
  String get pleaseWaitTitle => 'Per favore, attendi';

  @override
  String get fileNotAvailableYet => 'File non ancora disponibile';

  @override
  String get clearSelectionTooltip => 'Cancella selezione';

  @override
  String get copyNotesTooltip => 'Copia note';

  @override
  String get changeTaskTypeTooltip => 'Cambia tipo di attività';

  @override
  String get shareNotesTooltip => 'Condividi note';

  @override
  String get noNotesSelectedToShare => 'Nessuna nota selezionata da condividere';

  @override
  String get nothingToShare => 'Niente da condividere';

  @override
  String get shareFailed => 'Condivisione fallita';

  @override
  String get editNoteTooltip => 'Modifica nota';

  @override
  String get starUnstarNotesTooltip => 'Aggiungi/rimuovi dalle preferite';

  @override
  String get moveToTrashTooltip => 'Sposta nel cestino';

  @override
  String get pinUnpinNotesTooltip => 'Fissa/sblocca nota';

  @override
  String get cancelReplyTooltip => 'Annulla risposta';

  @override
  String get createTaskHint => 'Crea un\'attività';

  @override
  String get addNoteHint => 'Aggiungi una nota...';

  @override
  String get attachTooltip => 'Allega';

  @override
  String get addNoteTooltip => 'Aggiungi nota';

  @override
  String get recordStopAudioTooltip => 'Registra/ferma audio';

  @override
  String get contactAttachmentLabel => 'Contatto';

  @override
  String get locationAttachmentLabel => 'Posizione';

  @override
  String get cameraAttachmentLabel => 'Fotocamera';

  @override
  String get filesAttachmentLabel => 'File';

  @override
  String get checklistAttachmentLabel => 'Lista di controllo';

  @override
  String get accessKeyInputTitle => 'Abilita sincronizzazione';

  @override
  String get accessKeyInputDescription => 'Per favore, inserisci la tua frase di recupero di 24 parole o carica un file .txt che la contiene.';

  @override
  String get editMenuItemLabel => 'Modifica';

  @override
  String get filterMenuItemLabel => 'Filtri';

  @override
  String get externalStoragePermissionDenied => 'Autorizzazione per accedere alla memoria esterna negata.';

  @override
  String get pressLongToStartRecording => 'Tieni premuto per iniziare a registrare.';

  @override
  String get didYouKnowTitle => 'Lo sapevi?';

  @override
  String get closeTooltip => 'Chiudi';

  @override
  String appDescriptionContent(String appName) {
    return '$appName è un\'app per note completamente privata. Non raccoglie i tuoi dati personali né mostra pubblicità.\n\nSperiamo che ti piaccia usarla. Facci sapere cosa ne pensi.';
  }

  @override
  String get searchNotesTooltip => 'Cerca note';

  @override
  String get syncMenuItemLabel => 'Sincronizza';

  @override
  String get trashMenuItemLabel => 'Cestino';

  @override
  String get starredNotesMenuItemLabel => 'Note preferite';

  @override
  String get settingsMenuItemLabel => 'Impostazioni';

  @override
  String get accountMenuItemLabel => 'Account';

  @override
  String get pageMenuItemLabel => 'Pagina';

  @override
  String get sqliteMenuItemLabel => 'Sqlite';

  @override
  String get logsMenuItemLabel => 'Log';

  @override
  String get reorderMenuItemLabel => 'Riordina';

  @override
  String get editGroupMenuItemLabel => 'Modifica';

  @override
  String get deleteGroupMenuItemLabel => 'Elimina';

  @override
  String get dragHandleReorderTooltip => 'Trascina per riordinare';

  @override
  String get holdAndDragReorderTooltip => 'Tieni premuto e trascina per riordinare';

  @override
  String get emptyHomePageMessage => 'Ciao!\n\nQui sembra un po\' vuoto.\n\nTocca il pulsante + e crea delle note per te stesso. :)';

  @override
  String get reorderingTitle => 'Riordino';

  @override
  String get selectEllipsisLabel => 'Seleziona...';

  @override
  String get dateTimeToggleLabel => 'Data/Ora';

  @override
  String get noteBorderToggleLabel => 'Bordo nota';

  @override
  String get deleteGroupButtonLabel => 'Elimina';

  @override
  String get notesTabLabel => 'Note';

  @override
  String get groupsTabLabel => 'Gruppi';

  @override
  String get categoriesTabLabel => 'Categorie';

  @override
  String get locationItemLabel => 'Posizione';

  @override
  String get addGroupTitle => 'Aggiungi gruppo';

  @override
  String get editGroupTitle => 'Modifica gruppo';

  @override
  String get titleInputLabel => 'Titolo';

  @override
  String get locationPermissionRequiredTitle => 'Autorizzazione posizione richiesta';

  @override
  String get enableLocationPermissionsContent => 'Per favore, abilita le autorizzazioni di posizione nelle impostazioni dell\'app.';

  @override
  String get cancelButtonLabel => 'Annulla';

  @override
  String get openSettingsButtonLabel => 'Apri impostazioni';

  @override
  String get locationServicesTitle => 'Servizi di localizzazione';

  @override
  String get pleaseEnableLocationServicesContent => 'Per favore, abilitali!';

  @override
  String get selectLocationTitle => 'Seleziona posizione';

  @override
  String get useCurrentLocationTooltip => 'Usa posizione attuale';

  @override
  String get selectAllButtonLabel => 'Seleziona tutto';

  @override
  String get searchLogsHint => 'Cerca nei log..';

  @override
  String get noLogsAvailable => 'Nessun log disponibile';

  @override
  String get dbViewerTitle => 'Visualizzatore DB';

  @override
  String get selectTableToViewData => 'Seleziona una tabella per vederne i dati';

  @override
  String get selectTableDropdownHint => 'Seleziona una tabella';

  @override
  String get pickContactTitle => 'Scegli un contatto';

  @override
  String get permissionRequiredText => 'Autorizzazione richiesta';

  @override
  String get grantPermissionButtonLabel => 'Concedi autorizzazione';

  @override
  String get pageDummyTitle => 'Pagina prova';

  @override
  String get simulateButtonLabel => 'Simula';

  @override
  String get selectCategoryTitle => 'Seleziona categoria';

  @override
  String get addCategoryTitle => 'Aggiungi categoria';

  @override
  String get editCategoryTitle => 'Modifica categoria';

  @override
  String get categoryTitleHint => 'Titolo categoria';

  @override
  String get colorLabel => 'Colore';

  @override
  String get changeColorLabel => 'Cambia colore';

  @override
  String get deviceDisabledMessage => 'Dispositivo disabilitato!';

  @override
  String get cannotRemoveThisDeviceMessage => 'Impossibile rimuovere questo dispositivo!';

  @override
  String get confirmRemoveTitle => 'Conferma rimozione';

  @override
  String get confirmRemoveDeviceContent => 'Sei sicuro? Questo eliminerà tutti i dati sul dispositivo.';

  @override
  String get okButtonLabel => 'OK';

  @override
  String get registeredDevicesTitle => 'Dispositivi registrati';

  @override
  String get noDevicesFoundMessage => 'Nessun dispositivo trovato';

  @override
  String get enabledLabel => 'Abilitato';

  @override
  String get disabledLabel => 'Disabilitato';

  @override
  String get migratingMediaTitle => 'Migrazione media';

  @override
  String get processingMessage => 'Elaborazione...';

  @override
  String get doNotNavigateAwayMessage => 'Per favore, non allontanarti';

  @override
  String errorWithDetails(String error) {
    return 'Errore: $error';
  }

  @override
  String get sequenceNotAcceptedError => 'Sequenza non accettata';

  @override
  String get examplesNotAcceptedError => 'Esempi non accettati';

  @override
  String get enterKeyAgainLabel => 'Inserisci di nuovo la chiave';

  @override
  String get pleaseEnterKeyAgainError => 'Per favore, inserisci di nuovo la chiave';

  @override
  String get keysDoNotMatchError => 'Le chiavi non corrispondono';

  @override
  String get ruleUppercaseLetter => '1 lettera maiuscola';

  @override
  String get ruleLowercaseLetter => '1 lettera minuscola';

  @override
  String get ruleNumericLetter => '1 numero';

  @override
  String get ruleSpecialCharacter => '1 carattere speciale';

  @override
  String get ruleMinTenCharacters => 'min 10 caratteri';

  @override
  String get examplesTitle => 'Esempi';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => 'Ho capito';

  @override
  String get encryptionKeyTitle => 'Chiave di cifratura';

  @override
  String get createKeyDescription => 'Per favore, inserisci una chiave (password) lunga e difficile da indovinare. Ricordati di salvarla in un posto sicuro. Se viene persa o dimenticata, non può essere recuperata.';

  @override
  String get seeExamplesTooltip => 'Vedi esempi';

  @override
  String get couldNotFetchDetailsMessage => 'Impossibile recuperare i dettagli';

  @override
  String get retryButtonLabel => 'Riprova';

  @override
  String get signedInAsLabel => 'Accesso effettuato come:';

  @override
  String get storageUsageLabel => 'Utilizzo archiviazione';

  @override
  String get subscribeLabel => 'Abbonati';

  @override
  String get planExpiredRenewLabel => 'Piano scaduto! Rinnova';

  @override
  String get manageDevicesLabel => 'Gestisci dispositivi';

  @override
  String get viewAccessKeyLabel => 'Visualizza chiave di accesso';

  @override
  String get changeKeyPasswordLabel => 'Cambia password chiave';

  @override
  String get manageSubscriptionLabel => 'Gestisci abbonamento';

  @override
  String get signOutButtonLabel => 'Disconnetti';

  @override
  String get yearlyPlansTitle => 'Piani annuali';

  @override
  String get loginLabel => 'Accedi';

  @override
  String get syncAllYourNotesLabel => 'Sincronizza tutte le tue note';

  @override
  String get acrossYourDevicesLabel => 'su tutti i tuoi dispositivi';

  @override
  String get featureEndToEndEncryption => 'Cifratura end-to-end';

  @override
  String get featureSyncUpTo3Devices => 'Sincronizza fino a 3 dispositivi';

  @override
  String get featureUpgradeCancelAnytime => 'Upgrade/Cancella in qualsiasi momento';

  @override
  String get noPlansAvailableMessage => 'Nessun piano disponibile';

  @override
  String get downloadAppSubscribeLabel => 'Scarica l\'app e abbonati';

  @override
  String get privacyTermsLabel => 'Privacy • Termini';

  @override
  String get saveFiftyPercentLabel => 'Risparmia il 50%';

  @override
  String get helloTitle => 'Ciao';

  @override
  String get selectKeyMasterKeyDescription => 'Per cifrare i tuoi dati, avremo bisogno di una chiave di cifratura principale.';

  @override
  String get selectKeyTwoOptionsDescription => 'Ci sono 2 opzioni: puoi creare tu stesso una chiave (simile a una password) oppure possiamo crearla noi per te.';

  @override
  String get understandLoseKeyAcknowledgement => 'Capisco che se perdo/dimentico la chiave di cifratura, potrei perdere i dati.';

  @override
  String get createKeyForMeButtonLabel => 'Crea la chiave per me';

  @override
  String get recommendedLabel => '(Consigliato)';

  @override
  String get pleaseAcknowledgeMessage => 'Per favore, conferma!';

  @override
  String get createKeyMyselfButtonLabel => 'Creerò io la chiave';

  @override
  String welcomeToAppName(String appName) {
    return 'Benvenuto su $appName';
  }

  @override
  String get e2eEncryptionDescription => 'Usiamo la cifratura end-to-end per assicurarci che tutte le tue note siano al sicuro e che nessun altro possa vederle, nemmeno noi.';

  @override
  String get timeToStartEncryptionLabel => 'È ora di avviare la cifratura!';

  @override
  String get nextButtonLabel => 'Avanti';

  @override
  String get sendingOtpFailedMessage => 'Invio OTP fallito. Per favore, riprova!';

  @override
  String get otpVerificationFailedMessage => 'Verifica OTP fallita. Per favore, riprova!';

  @override
  String get emailSignInTitle => 'Accesso email';

  @override
  String get verifyOtpLabel => 'Verifica OTP';

  @override
  String get enterEmailLabel => 'Inserisci email';

  @override
  String get sendOtpLabel => 'Invia OTP';

  @override
  String otpSentToEmailMessage(String email) {
    return 'Abbiamo inviato una password usa e getta (OTP) alla tua email $email';
  }

  @override
  String get enterOtpLabel => 'Inserisci OTP';

  @override
  String get changeEmailLabel => 'Cambia email';

  @override
  String get encryptingNotesTitle => 'Cifratura note';

  @override
  String get fetchingDetailsTitle => 'Recupero dettagli';

  @override
  String get couldNotFetchMessage => 'Impossibile recuperare';

  @override
  String get subscriptionEmailMismatchMessage => 'Il tuo abbonamento è associato a un\'altra email. Per favore, disconnettiti e usa quella per abilitare l\'archiviazione cloud.';

  @override
  String get errorCheckingPlanDetailsMessage => 'Errore durante il controllo dei dettagli del piano';

  @override
  String get registerDeviceTitle => 'Registra dispositivo';

  @override
  String get manageButtonLabel => 'Gestisci';

  @override
  String get fetchingKeysTitle => 'Recupero chiavi';

  @override
  String get signingOutTitle => 'Disconnessione';

  @override
  String get pleaseCheckInternetMessage => 'Per favore, controlla la connessione internet';

  @override
  String get somethingWentWrongMessage => 'Qualcosa è andato storto';

  @override
  String get playPauseTooltip => 'Riproduci/pausa';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => 'Scarica';

  @override
  String get invalidAccessKey => 'Chiave di accesso non valida';

  @override
  String get fileDoesNotContain24Words => 'Il file non contiene esattamente 24 parole.';

  @override
  String get errorReadingFile => 'Errore durante la lettura del file';

  @override
  String get allLabel => 'Tutto';

  @override
  String get logTypeDebug => 'DEBUG';

  @override
  String get logTypeError => 'ERRORE';

  @override
  String get logTypeInfo => 'INFO';

  @override
  String get logTypeWarning => 'AVVISO';

  @override
  String get groupTitleHint => 'Titolo gruppo';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get selectCategoryPlaceholder => 'Seleziona categoria';

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
  String get searchHint => 'query, #document ecc..';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => 'File audio';

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
  String get selectLanguageTitle => 'Seleziona lingua';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get themeLabel => 'Tema';

  @override
  String get dayNightThemeTooltip => 'Tema giorno/notte';

  @override
  String get lockLabel => 'Blocco';

  @override
  String get timeFormatLabel => 'Formato ora';

  @override
  String get h12Label => '12 ore';

  @override
  String get h24Label => '24 ore';

  @override
  String get fontSizeLabel => 'Dimensione carattere';

  @override
  String get reduceTextSizeTooltip => 'Riduci dimensione testo';

  @override
  String get increaseTextSizeTooltip => 'Aumenta dimensione testo';

  @override
  String get languageLabel => 'Lingua';

  @override
  String get autoOpenGroupLabel => 'Apri gruppo automaticamente';

  @override
  String get selectGroupTitle => 'Seleziona gruppo';

  @override
  String shareAppMessage(String appName, String appLink) {
    return 'Usa $appName: $appLink';
  }

  @override
  String get noteTypeEmpty => 'Vuoto';

  @override
  String get noteTypeImage => 'Immagine';

  @override
  String get noteTypeVideo => 'Video';

  @override
  String get noteTypeAudio => 'Audio';

  @override
  String get noteTypeDocument => 'Documento';

  @override
  String get noteTypeContact => 'Contatto';

  @override
  String get noteTypeLocation => 'Posizione';

  @override
  String get noteTypeUnknown => 'Sconosciuto';

  @override
  String get pleaseEnterData => 'Per favore, inserisci i dati';

  @override
  String get aNumber => 'Un numero';

  @override
  String get enterDataLabel => 'Inserisci dati';

  @override
  String get pleaseEnterValidData => 'Per favore, inserisci dati validi';

  @override
  String get pleaseSelectAnOption => 'Per favore, seleziona un\'opzione';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => 'Oggi';

  @override
  String get yesterdayLabel => 'Ieri';

  @override
  String get mondayLabel => 'Lunedì';

  @override
  String get tuesdayLabel => 'Martedì';

  @override
  String get wednesdayLabel => 'Mercoledì';

  @override
  String get thursdayLabel => 'Giovedì';

  @override
  String get fridayLabel => 'Venerdì';

  @override
  String get saturdayLabel => 'Sabato';

  @override
  String get sundayLabel => 'Domenica';

  @override
  String get januaryShortLabel => 'Gen';

  @override
  String get februaryShortLabel => 'Feb';

  @override
  String get marchShortLabel => 'Mar';

  @override
  String get aprilShortLabel => 'Apr';

  @override
  String get mayShortLabel => 'Mag';

  @override
  String get juneShortLabel => 'Giu';

  @override
  String get julyShortLabel => 'Lug';

  @override
  String get augustShortLabel => 'Ago';

  @override
  String get septemberShortLabel => 'Set';

  @override
  String get octoberShortLabel => 'Ott';

  @override
  String get novemberShortLabel => 'Nov';

  @override
  String get decemberShortLabel => 'Dic';

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
    return '$count gruppo di note';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count gruppi di note';
  }

  @override
  String get seedCategoryTasks => 'Attività';

  @override
  String get seedGroupNotes => 'Note';

  @override
  String get seedGroupFitness => 'Fitness';

  @override
  String get seedItemWelcome => 'Benvenuto in Note Safe!\nIdee, liste o qualsiasi cosa ti passi per la testa, annotala qui.\n\nTieni premuto su questa nota per eliminarla, modificarla o visualizzare altre opzioni.';

  @override
  String get seedItemMorningWorkout => 'Allenamento mattutino';

  @override
  String get seedItemMeditation => '10 minuti di meditazione';

  @override
  String get seedItemWater => '2L di acqua al giorno';

  @override
  String get seedItemSteps => 'Fai 10.000 passi';
}

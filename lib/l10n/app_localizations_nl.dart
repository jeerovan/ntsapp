// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get importantTitle => 'Belangrijk';

  @override
  String get accessKeyNoticeDescription1 => 'Op de volgende pagina krijg je een reeks van 24 woorden te zien. Dit is je unieke en privé-versleutelingssleutel en het is de ENIGE manier om je notities te herstellen in het geval van uitloggen, verlies van het apparaat of een storing.';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return 'Wij slaan de sleutel niet op. Het is JOUW verantwoordelijkheid om deze op een veilige plek buiten de $appName-app te bewaren.';
  }

  @override
  String get iUnderstandShowMeTheKey => 'Ik begrijp het.\nToon de sleutel.';

  @override
  String get selectGroupToViewNotes => 'Selecteer een groep om notities te bekijken';

  @override
  String get accessKeyShareText => 'Hier is je toegangssleutel.';

  @override
  String get pleaseTryAgain => 'Probeer het opnieuw.';

  @override
  String get copiedToClipboard => 'Gekopieerd naar klembord';

  @override
  String get accessKeyTitle => 'Toegangssleutel';

  @override
  String get accessKeyDescription => 'Sla deze sleutel op een veilige plek op. Je hebt hem nodig om notities te synchroniseren op een ander apparaat.';

  @override
  String get copyLabel => 'Kopiëren';

  @override
  String get downloadAsTextFileLabel => 'Downloaden als tekstbestand';

  @override
  String get continueLabel => 'Doorgaan';

  @override
  String get pleaseAuthenticate => 'Graag verifiëren';

  @override
  String get couldNotCreate => 'Kon niet aanmaken';

  @override
  String get couldNotShareFile => 'Kon bestand niet delen';

  @override
  String get hereIsTheBackupFile => 'Hier is het back-upbestand voor je app.';

  @override
  String get errorTitle => 'Fout';

  @override
  String get backupLabel => 'Back-up';

  @override
  String get restoreLabel => 'Herstellen';

  @override
  String get leaveAReviewLabel => 'Schrijf een beoordeling';

  @override
  String get shareLabel => 'Delen';

  @override
  String get desktopAppLinkLabel => 'Desktop-app';

  @override
  String get loggingLabel => 'Logging';

  @override
  String versionLabel(String version) {
    return 'Versie: $version';
  }

  @override
  String get loadingLabel => 'Laden...';

  @override
  String get restoredLabel => 'Hersteld.';

  @override
  String get deletedPermanentlyLabel => 'Permanent verwijderd.';

  @override
  String get mediaTitle => 'Media';

  @override
  String get invalidWordList => 'Ongeldige woordenlijst';

  @override
  String get enterYour24WordPhrase => 'Voer je 24-woordige zin in';

  @override
  String get enterYourRecoveryPhraseHere => 'Voer hier je herstelzin in';

  @override
  String get pleaseEnterYourRecoveryPhrase => 'Voer je herstelzin in';

  @override
  String get recoveryPhraseMustContain24Words => 'De herstelzin moet exact 24 woorden bevatten';

  @override
  String get submitLabel => 'Verzenden';

  @override
  String get orLabel => 'Of';

  @override
  String get selectTxtFileLabel => 'Selecteer .txt-bestand';

  @override
  String get failureTitle => 'Mislukt';

  @override
  String get invalidPasswordKey => 'Ongeldige wachtwoordsleutel';

  @override
  String get enableSyncTitle => 'Synchronisatie inschakelen';

  @override
  String get passwordRequirementsDescription => 'Voer de sleutel (wachtwoord) in die je hebt aangemaakt. Deze moet minimaal 10 tekens lang zijn en minstens 1 cijfer, 1 kleine letter, 1 hoofdletter en 1 speciaal teken bevatten.';

  @override
  String get enterKeyLabel => 'Voer sleutel in';

  @override
  String get pleaseEnterKey => 'Voer de sleutel in';

  @override
  String get filterNotesTitle => 'Notities filteren';

  @override
  String get filterPinnedNotesTooltip => 'Vastgezette notities filteren';

  @override
  String get filterStarredNotesTooltip => 'Notities met ster filteren';

  @override
  String get filterTextNotesTooltip => 'Tekstnotities filteren';

  @override
  String get filterTasksTooltip => 'Taken filteren';

  @override
  String get filterLinksTooltip => 'Links filteren';

  @override
  String get filterImagesTooltip => 'Afbeeldingen filteren';

  @override
  String get filterAudioTooltip => 'Audio filteren';

  @override
  String get filterVideoTooltip => 'Video\'s filteren';

  @override
  String get filterFilesTooltip => 'Bestanden filteren';

  @override
  String get filterContactsTooltip => 'Contacten filteren';

  @override
  String get filterLocationTooltip => 'Locaties filteren';

  @override
  String get movedToTrash => 'Verplaatst naar prullenbak';

  @override
  String get copiedNotesToClipboard => 'Gekopieerd naar klembord';

  @override
  String get locationShareLabel => 'Locatie:';

  @override
  String get contactShareLabel => 'Contact:';

  @override
  String get emailsShareLabel => 'E-mails:';

  @override
  String get addressesShareLabel => 'Adressen:';

  @override
  String get microphoneNotAvailable => 'Microfoon is mogelijk niet beschikbaar.';

  @override
  String get microphonePermissionRequired => 'Microfoontoestemming is vereist om audio op te nemen.';

  @override
  String get couldNotGetDuration => 'Kon duur niet ophalen';

  @override
  String get errorOpeningFiles => 'Fout bij openen bestanden';

  @override
  String get pleaseWaitTitle => 'Even geduld';

  @override
  String get fileNotAvailableYet => 'Bestand nog niet beschikbaar';

  @override
  String get clearSelectionTooltip => 'Selectie wissen';

  @override
  String get copyNotesTooltip => 'Notities kopiëren';

  @override
  String get changeTaskTypeTooltip => 'Taaktype wijzigen';

  @override
  String get shareNotesTooltip => 'Notities delen';

  @override
  String get noNotesSelectedToShare => 'Geen notities geselecteerd om te delen';

  @override
  String get nothingToShare => 'Niets om te delen';

  @override
  String get shareFailed => 'Delen mislukt';

  @override
  String get editNoteTooltip => 'Notitie bewerken';

  @override
  String get starUnstarNotesTooltip => 'Ster toevoegen/verwijderen';

  @override
  String get moveToTrashTooltip => 'Verplaatsen naar prullenbak';

  @override
  String get pinUnpinNotesTooltip => 'Vastzetten/losmaken';

  @override
  String get cancelReplyTooltip => 'Antwoord annuleren';

  @override
  String get createTaskHint => 'Een taak aanmaken';

  @override
  String get addNoteHint => 'Notitie toevoegen...';

  @override
  String get attachTooltip => 'Bijvoegen';

  @override
  String get addNoteTooltip => 'Notitie toevoegen';

  @override
  String get recordStopAudioTooltip => 'Audio opnemen/stoppen';

  @override
  String get contactAttachmentLabel => 'Contact';

  @override
  String get locationAttachmentLabel => 'Locatie';

  @override
  String get cameraAttachmentLabel => 'Camera';

  @override
  String get filesAttachmentLabel => 'Bestanden';

  @override
  String get checklistAttachmentLabel => 'Checklist';

  @override
  String get accessKeyInputTitle => 'Synchronisatie inschakelen';

  @override
  String get accessKeyInputDescription => 'Voer je 24-woordige herstelzin in of laad een .txt-bestand dat deze bevat.';

  @override
  String get editMenuItemLabel => 'Bewerken';

  @override
  String get filterMenuItemLabel => 'Filters';

  @override
  String get externalStoragePermissionDenied => 'Toestemming voor toegang tot externe opslag geweigerd.';

  @override
  String get pressLongToStartRecording => 'Houd ingedrukt om opname te starten.';

  @override
  String get didYouKnowTitle => 'Wist je dat?';

  @override
  String get closeTooltip => 'Sluiten';

  @override
  String appDescriptionContent(String appName) {
    return '$appName is een volledig privé-notitie-app. Het verzamelt geen persoonlijke gegevens en toont geen advertenties.\n\nWe hopen dat je er met plezier gebruik van maakt. Laat ons weten wat je ervan vindt.';
  }

  @override
  String get searchNotesTooltip => 'Notities doorzoeken';

  @override
  String get syncMenuItemLabel => 'Synchroniseren';

  @override
  String get trashMenuItemLabel => 'Prullenbak';

  @override
  String get starredNotesMenuItemLabel => 'Notities met ster';

  @override
  String get settingsMenuItemLabel => 'Instellingen';

  @override
  String get accountMenuItemLabel => 'Account';

  @override
  String get pageMenuItemLabel => 'Pagina';

  @override
  String get sqliteMenuItemLabel => 'Sqlite';

  @override
  String get logsMenuItemLabel => 'Logs';

  @override
  String get reorderMenuItemLabel => 'Sorteren';

  @override
  String get editGroupMenuItemLabel => 'Bewerken';

  @override
  String get deleteGroupMenuItemLabel => 'Verwijderen';

  @override
  String get dragHandleReorderTooltip => 'Sleepgreep om te sorteren';

  @override
  String get holdAndDragReorderTooltip => 'Houd vast en sleep om te sorteren';

  @override
  String get emptyHomePageMessage => 'Hallo!\n\nHet ziet er hier nogal leeg uit.\n\nTik op de +-knop en maak wat notities voor jezelf. :)';

  @override
  String get reorderingTitle => 'Sorteren';

  @override
  String get selectEllipsisLabel => 'Selecteren...';

  @override
  String get dateTimeToggleLabel => 'Datum/Tijd';

  @override
  String get noteBorderToggleLabel => 'Notitierand';

  @override
  String get deleteGroupButtonLabel => 'Verwijderen';

  @override
  String get notesTabLabel => 'Notities';

  @override
  String get groupsTabLabel => 'Groepen';

  @override
  String get categoriesTabLabel => 'Categorieën';

  @override
  String get locationItemLabel => 'Locatie';

  @override
  String get addGroupTitle => 'Groep toevoegen';

  @override
  String get editGroupTitle => 'Groep bewerken';

  @override
  String get titleInputLabel => 'Titel';

  @override
  String get locationPermissionRequiredTitle => 'Locatietoestemming vereist';

  @override
  String get enableLocationPermissionsContent => 'Schakel locatietoestemmingen in bij de app-instellingen.';

  @override
  String get cancelButtonLabel => 'Annuleren';

  @override
  String get openSettingsButtonLabel => 'Instellingen openen';

  @override
  String get locationServicesTitle => 'Locatievoorzieningen';

  @override
  String get pleaseEnableLocationServicesContent => 'Schakel deze in!';

  @override
  String get selectLocationTitle => 'Locatie selecteren';

  @override
  String get useCurrentLocationTooltip => 'Huidige locatie gebruiken';

  @override
  String get selectAllButtonLabel => 'Alles selecteren';

  @override
  String get searchLogsHint => 'Logs doorzoeken..';

  @override
  String get noLogsAvailable => 'Geen logs beschikbaar';

  @override
  String get dbViewerTitle => 'DB-viewer';

  @override
  String get selectTableToViewData => 'Selecteer een tabel om de data te bekijken';

  @override
  String get selectTableDropdownHint => 'Selecteer een tabel';

  @override
  String get pickContactTitle => 'Kies een contact';

  @override
  String get permissionRequiredText => 'Toestemming vereist';

  @override
  String get grantPermissionButtonLabel => 'Toestemming verlenen';

  @override
  String get pageDummyTitle => 'Dummy-pagina';

  @override
  String get simulateButtonLabel => 'Simuleren';

  @override
  String get selectCategoryTitle => 'Categorie selecteren';

  @override
  String get addCategoryTitle => 'Categorie toevoegen';

  @override
  String get editCategoryTitle => 'Categorie bewerken';

  @override
  String get categoryTitleHint => 'Categorietitel';

  @override
  String get colorLabel => 'Kleur';

  @override
  String get changeColorLabel => 'Kleur wijzigen';

  @override
  String get deviceDisabledMessage => 'Apparaat uitgeschakeld!';

  @override
  String get cannotRemoveThisDeviceMessage => 'Kan dit apparaat niet verwijderen!';

  @override
  String get confirmRemoveTitle => 'Verwijderen bevestigen';

  @override
  String get confirmRemoveDeviceContent => 'Weet je het zeker? Dit verwijdert alle gegevens op dit apparaat.';

  @override
  String get okButtonLabel => 'OK';

  @override
  String get registeredDevicesTitle => 'Geregistreerde apparaten';

  @override
  String get noDevicesFoundMessage => 'Geen apparaten gevonden';

  @override
  String get enabledLabel => 'Ingeschakeld';

  @override
  String get disabledLabel => 'Uitgeschakeld';

  @override
  String get migratingMediaTitle => 'Media migreren';

  @override
  String get processingMessage => 'Verwerken...';

  @override
  String get doNotNavigateAwayMessage => 'Navigeer alstublieft niet weg';

  @override
  String errorWithDetails(String error) {
    return 'Fout: $error';
  }

  @override
  String get sequenceNotAcceptedError => 'Reeks niet geaccepteerd';

  @override
  String get examplesNotAcceptedError => 'Voorbeelden niet geaccepteerd';

  @override
  String get enterKeyAgainLabel => 'Voer sleutel opnieuw in';

  @override
  String get pleaseEnterKeyAgainError => 'Voer de sleutel opnieuw in';

  @override
  String get keysDoNotMatchError => 'Sleutels komen niet overeen';

  @override
  String get ruleUppercaseLetter => '1 hoofdletter';

  @override
  String get ruleLowercaseLetter => '1 kleine letter';

  @override
  String get ruleNumericLetter => '1 cijfer';

  @override
  String get ruleSpecialCharacter => '1 speciaal teken';

  @override
  String get ruleMinTenCharacters => 'minstens 10 tekens';

  @override
  String get examplesTitle => 'Voorbeelden';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => 'Begrepen';

  @override
  String get encryptionKeyTitle => 'Versleutelingssleutel';

  @override
  String get createKeyDescription => 'Voer een lange en moeilijk te raden sleutel (wachtwoord) in. Vergeet niet deze ergens veilig op te slaan. Als deze verloren gaat of vergeten wordt, kan deze niet worden hersteld.';

  @override
  String get seeExamplesTooltip => 'Bekijk voorbeelden';

  @override
  String get couldNotFetchDetailsMessage => 'Kon details niet ophalen';

  @override
  String get retryButtonLabel => 'Opnieuw proberen';

  @override
  String get signedInAsLabel => 'Ingelogd als:';

  @override
  String get storageUsageLabel => 'Opslaggebruik';

  @override
  String get subscribeLabel => 'Abonneren';

  @override
  String get planExpiredRenewLabel => 'Abonnement verlopen! Vernieuwen';

  @override
  String get manageDevicesLabel => 'Apparaten beheren';

  @override
  String get viewAccessKeyLabel => 'Toegangssleutel bekijken';

  @override
  String get changeKeyPasswordLabel => 'Sleutelwachtwoord wijzigen';

  @override
  String get manageSubscriptionLabel => 'Abonnement beheren';

  @override
  String get signOutButtonLabel => 'Uitloggen';

  @override
  String get yearlyPlansTitle => 'Jaarplannen';

  @override
  String get loginLabel => 'Inloggen';

  @override
  String get syncAllYourNotesLabel => 'Synchroniseer al je notities';

  @override
  String get acrossYourDevicesLabel => 'tussen al je apparaten';

  @override
  String get featureEndToEndEncryption => 'End-to-end versleuteling';

  @override
  String get featureSyncUpTo3Devices => 'Synchroniseer tot 3 apparaten';

  @override
  String get featureUpgradeCancelAnytime => 'Altijd upgraden/opzeggen';

  @override
  String get noPlansAvailableMessage => 'Geen abonnementen beschikbaar';

  @override
  String get downloadAppSubscribeLabel => 'Download de app & abonneer';

  @override
  String get privacyTermsLabel => 'Privacy • Voorwaarden';

  @override
  String get saveFiftyPercentLabel => 'Bespaar 50%';

  @override
  String get helloTitle => 'Hallo';

  @override
  String get selectKeyMasterKeyDescription => 'Om je gegevens te versleutelen, hebben we een hoofd-versleutelingssleutel nodig.';

  @override
  String get selectKeyTwoOptionsDescription => 'Er zijn 2 opties: of je maakt zelf een sleutel aan (vergelijkbaar met een wachtwoord), of wij maken deze voor je aan.';

  @override
  String get understandLoseKeyAcknowledgement => 'Ik begrijp dat als ik de versleutelingssleutel kwijtraak/vergeet, ik de gegevens kan verliezen.';

  @override
  String get createKeyForMeButtonLabel => 'Maak de sleutel voor mij aan';

  @override
  String get recommendedLabel => '(Aanbevolen)';

  @override
  String get pleaseAcknowledgeMessage => 'Bevestig dit alstublieft!';

  @override
  String get createKeyMyselfButtonLabel => 'Ik maak zelf de sleutel aan';

  @override
  String welcomeToAppName(String appName) {
    return 'Welkom bij $appName';
  }

  @override
  String get e2eEncryptionDescription => 'Wij gebruiken end-to-end versleuteling om ervoor te zorgen dat al je notities veilig zijn en niemand anders ze kan zien, zelfs wij niet.';

  @override
  String get timeToStartEncryptionLabel => 'Tijd om de versleuteling te starten!';

  @override
  String get nextButtonLabel => 'Volgende';

  @override
  String get sendingOtpFailedMessage => 'Verzenden van OTP mislukt. Probeer het opnieuw!';

  @override
  String get otpVerificationFailedMessage => 'OTP-verificatie mislukt. Probeer het opnieuw!';

  @override
  String get emailSignInTitle => 'E-mail inloggen';

  @override
  String get verifyOtpLabel => 'OTP verifiëren';

  @override
  String get enterEmailLabel => 'E-mail invoeren';

  @override
  String get sendOtpLabel => 'OTP verzenden';

  @override
  String otpSentToEmailMessage(String email) {
    return 'We hebben een eenmalig wachtwoord (OTP) naar je e-mail $email gestuurd';
  }

  @override
  String get enterOtpLabel => 'OTP invoeren';

  @override
  String get changeEmailLabel => 'E-mail wijzigen';

  @override
  String get encryptingNotesTitle => 'Notities versleutelen';

  @override
  String get fetchingDetailsTitle => 'Details ophalen';

  @override
  String get couldNotFetchMessage => 'Kon niet ophalen';

  @override
  String get subscriptionEmailMismatchMessage => 'Je abonnement is gekoppeld aan een ander e-mailadres. Log uit en gebruik dat e-mailadres om cloudopslag in te schakelen.';

  @override
  String get errorCheckingPlanDetailsMessage => 'Fout bij controleren abonnementsdetails';

  @override
  String get registerDeviceTitle => 'Apparaat registreren';

  @override
  String get manageButtonLabel => 'Beheren';

  @override
  String get fetchingKeysTitle => 'Sleutels ophalen';

  @override
  String get signingOutTitle => 'Uitloggen';

  @override
  String get pleaseCheckInternetMessage => 'Controleer je internetverbinding';

  @override
  String get somethingWentWrongMessage => 'Er is iets misgegaan';

  @override
  String get playPauseTooltip => 'Afspelen/pauzeren';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => 'Downloaden';

  @override
  String get invalidAccessKey => 'Ongeldige toegangssleutel';

  @override
  String get fileDoesNotContain24Words => 'Het bestand bevat niet precies 24 woorden.';

  @override
  String get errorReadingFile => 'Fout bij lezen bestand';

  @override
  String get allLabel => 'Alles';

  @override
  String get logTypeDebug => 'DEBUG';

  @override
  String get logTypeError => 'FOUT';

  @override
  String get logTypeInfo => 'INFO';

  @override
  String get logTypeWarning => 'WAARSCHUWING';

  @override
  String get groupTitleHint => 'Groeptitel';

  @override
  String get categoryLabel => 'Categorie';

  @override
  String get selectCategoryPlaceholder => 'Categorie selecteren';

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
  String get searchHint => 'zoekopdracht, #document enz..';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => 'Audiobestand';

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
  String get selectLanguageTitle => 'Taal selecteren';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get themeLabel => 'Thema';

  @override
  String get dayNightThemeTooltip => 'Dag/nacht thema';

  @override
  String get lockLabel => 'Vergrendelen';

  @override
  String get timeFormatLabel => 'Tijdnotatie';

  @override
  String get h12Label => '12-uurs';

  @override
  String get h24Label => '24-uurs';

  @override
  String get fontSizeLabel => 'Tekstgrootte';

  @override
  String get reduceTextSizeTooltip => 'Tekstgrootte verkleinen';

  @override
  String get increaseTextSizeTooltip => 'Tekstgrootte vergroten';

  @override
  String get languageLabel => 'Taal';

  @override
  String get autoOpenGroupLabel => 'Groep automatisch openen';

  @override
  String get selectGroupTitle => 'Groep selecteren';

  @override
  String shareAppMessage(String appName, String appLink) {
    return 'Gebruik een $appName: $appLink';
  }

  @override
  String get noteTypeEmpty => 'Leeg';

  @override
  String get noteTypeImage => 'Afbeelding';

  @override
  String get noteTypeVideo => 'Video';

  @override
  String get noteTypeAudio => 'Audio';

  @override
  String get noteTypeDocument => 'Document';

  @override
  String get noteTypeContact => 'Contact';

  @override
  String get noteTypeLocation => 'Locatie';

  @override
  String get noteTypeUnknown => 'Onbekend';

  @override
  String get pleaseEnterData => 'Voer gegevens in';

  @override
  String get aNumber => 'Een nummer';

  @override
  String get enterDataLabel => 'Gegevens invoeren';

  @override
  String get pleaseEnterValidData => 'Voer geldige gegevens in';

  @override
  String get pleaseSelectAnOption => 'Selecteer een optie';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => 'Vandaag';

  @override
  String get yesterdayLabel => 'Gisteren';

  @override
  String get mondayLabel => 'Maandag';

  @override
  String get tuesdayLabel => 'Dinsdag';

  @override
  String get wednesdayLabel => 'Woensdag';

  @override
  String get thursdayLabel => 'Donderdag';

  @override
  String get fridayLabel => 'Vrijdag';

  @override
  String get saturdayLabel => 'Zaterdag';

  @override
  String get sundayLabel => 'Zondag';

  @override
  String get januaryShortLabel => 'Jan';

  @override
  String get februaryShortLabel => 'Feb';

  @override
  String get marchShortLabel => 'Mrt';

  @override
  String get aprilShortLabel => 'Apr';

  @override
  String get mayShortLabel => 'Mei';

  @override
  String get juneShortLabel => 'Jun';

  @override
  String get julyShortLabel => 'Jul';

  @override
  String get augustShortLabel => 'Aug';

  @override
  String get septemberShortLabel => 'Sep';

  @override
  String get octoberShortLabel => 'Okt';

  @override
  String get novemberShortLabel => 'Nov';

  @override
  String get decemberShortLabel => 'Dec';

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
    return '$count notitiegroep';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count notitiegroepen';
  }

  @override
  String get seedCategoryTasks => 'Taken';

  @override
  String get seedGroupNotes => 'Notities';

  @override
  String get seedGroupFitness => 'Fitness';

  @override
  String get seedItemWelcome => 'Welkom bij Note Safe!\nIdeeën, lijstjes of wat je ook maar bezighoudt, bewaar het hier.\n\nHoud deze notitie ingedrukt voor verwijderen, bewerken en andere opties.';

  @override
  String get seedItemMorningWorkout => 'Ochtendtraining';

  @override
  String get seedItemMeditation => '10 minuten meditatie';

  @override
  String get seedItemWater => '2 liter water per dag';

  @override
  String get seedItemSteps => '10.000 stappen wandelen';
}

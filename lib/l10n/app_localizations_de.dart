// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get importantTitle => 'Wichtig';

  @override
  String get accessKeyNoticeDescription1 => 'Auf der nächsten Seite werden 24 Wörter angezeigt. Dies ist dein einzigartiger und privater Verschlüsselungsschlüssel. Er ist die EINZIGE Möglichkeit, deine Notizen bei Abmeldung, Geräteverlust oder Defekt wiederherzustellen.';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return 'Wir speichern diesen Schlüssel nicht. Es liegt in DEINER Verantwortung, ihn an einem sicheren Ort außerhalb der $appName-App aufzubewahren.';
  }

  @override
  String get iUnderstandShowMeTheKey => 'Ich habe verstanden.\nSchlüssel anzeigen.';

  @override
  String get selectGroupToViewNotes => 'Wähle eine Gruppe, um Notizen anzuzeigen';

  @override
  String get accessKeyShareText => 'Hier ist dein Zugangsschlüssel.';

  @override
  String get pleaseTryAgain => 'Bitte versuche es erneut.';

  @override
  String get copiedToClipboard => 'In die Zwischenablage kopiert';

  @override
  String get accessKeyTitle => 'Zugangsschlüssel';

  @override
  String get accessKeyDescription => 'Bitte bewahre diesen Schlüssel an einem sicheren Ort auf. Du benötigst ihn, um Notizen auf einem anderen Gerät zu synchronisieren.';

  @override
  String get copyLabel => 'Kopieren';

  @override
  String get downloadAsTextFileLabel => 'Als Textdatei herunterladen';

  @override
  String get continueLabel => 'Weiter';

  @override
  String get pleaseAuthenticate => 'Bitte authentifizieren';

  @override
  String get couldNotCreate => 'Erstellung fehlgeschlagen';

  @override
  String get couldNotShareFile => 'Datei konnte nicht geteilt werden';

  @override
  String get hereIsTheBackupFile => 'Hier ist die Sicherungsdatei deiner App.';

  @override
  String get errorTitle => 'Fehler';

  @override
  String get backupLabel => 'Sicherung';

  @override
  String get restoreLabel => 'Wiederherstellen';

  @override
  String get leaveAReviewLabel => 'Bewertung abgeben';

  @override
  String get shareLabel => 'Teilen';

  @override
  String get desktopAppLinkLabel => 'Desktop-App';

  @override
  String get loggingLabel => 'Protokollierung';

  @override
  String versionLabel(String version) {
    return 'Version: $version';
  }

  @override
  String get loadingLabel => 'Wird geladen...';

  @override
  String get restoredLabel => 'Wiederhergestellt.';

  @override
  String get deletedPermanentlyLabel => 'Dauerhaft gelöscht.';

  @override
  String get mediaTitle => 'Medien';

  @override
  String get invalidWordList => 'Ungültige Wortliste';

  @override
  String get enterYour24WordPhrase => 'Gib deine 24-Wörter-Phrase ein';

  @override
  String get enterYourRecoveryPhraseHere => 'Gib hier deine Wiederherstellungsphrase ein';

  @override
  String get pleaseEnterYourRecoveryPhrase => 'Bitte gib deine Wiederherstellungsphrase ein';

  @override
  String get recoveryPhraseMustContain24Words => 'Die Wiederherstellungsphrase muss genau 24 Wörter enthalten';

  @override
  String get submitLabel => 'Absenden';

  @override
  String get orLabel => 'Oder';

  @override
  String get selectTxtFileLabel => '.txt-Datei auswählen';

  @override
  String get failureTitle => 'Fehler';

  @override
  String get invalidPasswordKey => 'Ungültiger Passwortschlüssel';

  @override
  String get enableSyncTitle => 'Synchronisierung aktivieren';

  @override
  String get passwordRequirementsDescription => 'Bitte gib den von dir erstellten Schlüssel (Passwort) ein. Er muss mindestens 10 Zeichen lang sein und jeweils mindestens eine Ziffer, einen Kleinbuchstaben, einen Großbuchstaben sowie ein Sonderzeichen enthalten.';

  @override
  String get enterKeyLabel => 'Schlüssel eingeben';

  @override
  String get pleaseEnterKey => 'Bitte Schlüssel eingeben';

  @override
  String get filterNotesTitle => 'Notizen filtern';

  @override
  String get filterPinnedNotesTooltip => 'Angepinnte Notizen filtern';

  @override
  String get filterStarredNotesTooltip => 'Markierte Notizen filtern';

  @override
  String get filterTextNotesTooltip => 'Textnotizen filtern';

  @override
  String get filterTasksTooltip => 'Aufgaben filtern';

  @override
  String get filterLinksTooltip => 'Links filtern';

  @override
  String get filterImagesTooltip => 'Bilder filtern';

  @override
  String get filterAudioTooltip => 'Audio filtern';

  @override
  String get filterVideoTooltip => 'Videos filtern';

  @override
  String get filterFilesTooltip => 'Dateien filtern';

  @override
  String get filterContactsTooltip => 'Kontakte filtern';

  @override
  String get filterLocationTooltip => 'Standort filtern';

  @override
  String get movedToTrash => 'In den Papierkorb verschoben';

  @override
  String get copiedNotesToClipboard => 'In die Zwischenablage kopiert';

  @override
  String get locationShareLabel => 'Standort:';

  @override
  String get contactShareLabel => 'Kontakt:';

  @override
  String get emailsShareLabel => 'E-Mails:';

  @override
  String get addressesShareLabel => 'Adressen:';

  @override
  String get microphoneNotAvailable => 'Mikrofon ist eventuell nicht verfügbar.';

  @override
  String get microphonePermissionRequired => 'Mikrofonberechtigung für Audioaufnahmen erforderlich.';

  @override
  String get couldNotGetDuration => 'Dauer konnte nicht abgerufen werden';

  @override
  String get errorOpeningFiles => 'Fehler beim Öffnen der Dateien';

  @override
  String get pleaseWaitTitle => 'Bitte warten';

  @override
  String get fileNotAvailableYet => 'Datei noch nicht verfügbar';

  @override
  String get clearSelectionTooltip => 'Auswahl aufheben';

  @override
  String get copyNotesTooltip => 'Notizen kopieren';

  @override
  String get changeTaskTypeTooltip => 'Aufgabentyp ändern';

  @override
  String get shareNotesTooltip => 'Notizen teilen';

  @override
  String get noNotesSelectedToShare => 'Keine Notizen zum Teilen ausgewählt';

  @override
  String get nothingToShare => 'Nichts zu teilen';

  @override
  String get shareFailed => 'Teilen fehlgeschlagen';

  @override
  String get editNoteTooltip => 'Notiz bearbeiten';

  @override
  String get starUnstarNotesTooltip => 'Notiz markieren/entmarkieren';

  @override
  String get moveToTrashTooltip => 'In den Papierkorb verschieben';

  @override
  String get pinUnpinNotesTooltip => 'Notiz anheften/lösen';

  @override
  String get cancelReplyTooltip => 'Antwort abbrechen';

  @override
  String get createTaskHint => 'Aufgabe erstellen';

  @override
  String get addNoteHint => 'Notiz hinzufügen...';

  @override
  String get attachTooltip => 'Anhang';

  @override
  String get addNoteTooltip => 'Notiz hinzufügen';

  @override
  String get recordStopAudioTooltip => 'Audio aufnehmen/stoppen';

  @override
  String get contactAttachmentLabel => 'Kontakt';

  @override
  String get locationAttachmentLabel => 'Standort';

  @override
  String get cameraAttachmentLabel => 'Kamera';

  @override
  String get filesAttachmentLabel => 'Dateien';

  @override
  String get checklistAttachmentLabel => 'Checkliste';

  @override
  String get accessKeyInputTitle => 'Synchronisierung aktivieren';

  @override
  String get accessKeyInputDescription => 'Bitte gib deine 24-Wörter-Wiederherstellungsphrase ein oder lade eine .txt-Datei, die diese enthält.';

  @override
  String get editMenuItemLabel => 'Bearbeiten';

  @override
  String get filterMenuItemLabel => 'Filter';

  @override
  String get externalStoragePermissionDenied => 'Berechtigung für den Zugriff auf den externen Speicher wurde verweigert.';

  @override
  String get pressLongToStartRecording => 'Lange drücken, um die Aufnahme zu starten.';

  @override
  String get didYouKnowTitle => 'Schon gewusst?';

  @override
  String get closeTooltip => 'Schließen';

  @override
  String appDescriptionContent(String appName) {
    return '$appName ist eine vollständig private Notizen-App. Deine persönlichen Daten werden weder erfasst, noch gibt es Werbung.\n\nWir hoffen, die App gefällt dir. Lass uns wissen, was du denkst.';
  }

  @override
  String get searchNotesTooltip => 'Notizen durchsuchen';

  @override
  String get syncMenuItemLabel => 'Synchronisieren';

  @override
  String get trashMenuItemLabel => 'Papierkorb';

  @override
  String get starredNotesMenuItemLabel => 'Favoriten';

  @override
  String get settingsMenuItemLabel => 'Einstellungen';

  @override
  String get accountMenuItemLabel => 'Konto';

  @override
  String get pageMenuItemLabel => 'Seite';

  @override
  String get sqliteMenuItemLabel => 'Sqlite';

  @override
  String get logsMenuItemLabel => 'Protokolle';

  @override
  String get reorderMenuItemLabel => 'Sortieren';

  @override
  String get editGroupMenuItemLabel => 'Bearbeiten';

  @override
  String get deleteGroupMenuItemLabel => 'Löschen';

  @override
  String get dragHandleReorderTooltip => 'Zum Sortieren ziehen';

  @override
  String get holdAndDragReorderTooltip => 'Gedrückt halten und zum Sortieren ziehen';

  @override
  String get emptyHomePageMessage => 'Hallo!\n\nHier ist es noch etwas leer.\n\nTippe auf die Plus-Schaltfläche (+), um dir eine Notiz zu erstellen. :)';

  @override
  String get reorderingTitle => 'Sortieren';

  @override
  String get selectEllipsisLabel => 'Auswählen...';

  @override
  String get dateTimeToggleLabel => 'Datum/Uhrzeit';

  @override
  String get noteBorderToggleLabel => 'Notizrahmen';

  @override
  String get deleteGroupButtonLabel => 'Löschen';

  @override
  String get notesTabLabel => 'Notizen';

  @override
  String get groupsTabLabel => 'Gruppen';

  @override
  String get categoriesTabLabel => 'Kategorien';

  @override
  String get locationItemLabel => 'Standort';

  @override
  String get addGroupTitle => 'Gruppe hinzufügen';

  @override
  String get editGroupTitle => 'Gruppe bearbeiten';

  @override
  String get titleInputLabel => 'Titel';

  @override
  String get locationPermissionRequiredTitle => 'Standortberechtigung erforderlich';

  @override
  String get enableLocationPermissionsContent => 'Bitte aktiviere die Standortberechtigungen in den App-Einstellungen.';

  @override
  String get cancelButtonLabel => 'Abbrechen';

  @override
  String get openSettingsButtonLabel => 'Einstellungen öffnen';

  @override
  String get locationServicesTitle => 'Standortdienste';

  @override
  String get pleaseEnableLocationServicesContent => 'Bitte aktivieren!';

  @override
  String get selectLocationTitle => 'Standort auswählen';

  @override
  String get useCurrentLocationTooltip => 'Aktuellen Standort verwenden';

  @override
  String get selectAllButtonLabel => 'Alle auswählen';

  @override
  String get searchLogsHint => 'Logs durchsuchen...';

  @override
  String get noLogsAvailable => 'Keine Logs verfügbar';

  @override
  String get dbViewerTitle => 'DB-Betrachter';

  @override
  String get selectTableToViewData => 'Wähle eine Tabelle aus, um deren Daten anzuzeigen';

  @override
  String get selectTableDropdownHint => 'Tabelle auswählen';

  @override
  String get pickContactTitle => 'Kontakt auswählen';

  @override
  String get permissionRequiredText => 'Berechtigung erforderlich';

  @override
  String get grantPermissionButtonLabel => 'Berechtigung erteilen';

  @override
  String get pageDummyTitle => 'Dummy-Seite';

  @override
  String get simulateButtonLabel => 'Simulieren';

  @override
  String get selectCategoryTitle => 'Kategorie auswählen';

  @override
  String get addCategoryTitle => 'Kategorie hinzufügen';

  @override
  String get editCategoryTitle => 'Kategorie bearbeiten';

  @override
  String get categoryTitleHint => 'Kategorietitel';

  @override
  String get colorLabel => 'Farbe';

  @override
  String get changeColorLabel => 'Farbe ändern';

  @override
  String get deviceDisabledMessage => 'Gerät deaktiviert!';

  @override
  String get cannotRemoveThisDeviceMessage => 'Dieses Gerät kann nicht entfernt werden!';

  @override
  String get confirmRemoveTitle => 'Entfernen bestätigen';

  @override
  String get confirmRemoveDeviceContent => 'Sind Sie sicher? Dies löscht alle Daten auf dem Gerät.';

  @override
  String get okButtonLabel => 'OK';

  @override
  String get registeredDevicesTitle => 'Registrierte Geräte';

  @override
  String get noDevicesFoundMessage => 'Keine Geräte gefunden';

  @override
  String get enabledLabel => 'Aktiviert';

  @override
  String get disabledLabel => 'Deaktiviert';

  @override
  String get migratingMediaTitle => 'Medien migrieren';

  @override
  String get processingMessage => 'Verarbeitung läuft…';

  @override
  String get doNotNavigateAwayMessage => 'Bitte verlassen Sie diesen Bereich nicht';

  @override
  String errorWithDetails(String error) {
    return 'Fehler: $error';
  }

  @override
  String get sequenceNotAcceptedError => 'Sequenz nicht akzeptiert';

  @override
  String get examplesNotAcceptedError => 'Beispiele nicht akzeptiert';

  @override
  String get enterKeyAgainLabel => 'Schlüssel erneut eingeben';

  @override
  String get pleaseEnterKeyAgainError => 'Bitte geben Sie den Schlüssel erneut ein';

  @override
  String get keysDoNotMatchError => 'Schlüssel stimmen nicht überein';

  @override
  String get ruleUppercaseLetter => '1 Großbuchstabe';

  @override
  String get ruleLowercaseLetter => '1 Kleinbuchstabe';

  @override
  String get ruleNumericLetter => '1 Ziffer';

  @override
  String get ruleSpecialCharacter => '1 Sonderzeichen';

  @override
  String get ruleMinTenCharacters => 'mind. 10 Zeichen';

  @override
  String get examplesTitle => 'Beispiele';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => 'Verstanden';

  @override
  String get encryptionKeyTitle => 'Verschlüsselungsschlüssel';

  @override
  String get createKeyDescription => 'Bitte geben Sie einen langen und schwer zu erratenden Schlüssel (Passwort) ein. Bewahren Sie ihn an einem sicheren Ort auf. Falls er verloren geht oder vergessen wird, kann er nicht wiederhergestellt werden.';

  @override
  String get seeExamplesTooltip => 'Beispiele ansehen';

  @override
  String get couldNotFetchDetailsMessage => 'Details konnten nicht geladen werden';

  @override
  String get retryButtonLabel => 'Wiederholen';

  @override
  String get signedInAsLabel => 'Angemeldet als:';

  @override
  String get storageUsageLabel => 'Speichernutzung';

  @override
  String get subscribeLabel => 'Abonnieren';

  @override
  String get planExpiredRenewLabel => 'Plan abgelaufen! Erneuern';

  @override
  String get manageDevicesLabel => 'Geräte verwalten';

  @override
  String get viewAccessKeyLabel => 'Zugriffsschlüssel anzeigen';

  @override
  String get changeKeyPasswordLabel => 'Schlüsselpasswort ändern';

  @override
  String get manageSubscriptionLabel => 'Abonnement verwalten';

  @override
  String get signOutButtonLabel => 'Abmelden';

  @override
  String get yearlyPlansTitle => 'Jahresabos';

  @override
  String get loginLabel => 'Anmelden';

  @override
  String get syncAllYourNotesLabel => 'Synchronisiere alle deine Notizen';

  @override
  String get acrossYourDevicesLabel => 'über alle deine Geräte hinweg';

  @override
  String get featureEndToEndEncryption => 'Ende-zu-Ende-Verschlüsselung';

  @override
  String get featureSyncUpTo3Devices => 'Synchronisierung bis zu 3 Geräte';

  @override
  String get featureUpgradeCancelAnytime => 'Jederzeit upgraden/kündigen';

  @override
  String get noPlansAvailableMessage => 'Keine Abos verfügbar';

  @override
  String get downloadAppSubscribeLabel => 'App laden & abonnieren';

  @override
  String get privacyTermsLabel => 'Datenschutz • AGB';

  @override
  String get saveFiftyPercentLabel => '50% sparen';

  @override
  String get helloTitle => 'Hallo';

  @override
  String get selectKeyMasterKeyDescription => 'Um deine Daten zu verschlüsseln, benötigen wir einen Hauptschlüssel.';

  @override
  String get selectKeyTwoOptionsDescription => 'Es gibt zwei Optionen: Entweder du erstellst den Schlüssel selbst (ähnlich einem Passwort) oder wir erstellen ihn für dich.';

  @override
  String get understandLoseKeyAcknowledgement => 'Ich verstehe, dass der Verlust meines Verschlüsselungsschlüssels zum Datenverlust führen kann.';

  @override
  String get createKeyForMeButtonLabel => 'Schlüssel für mich erstellen';

  @override
  String get recommendedLabel => '(Empfohlen)';

  @override
  String get pleaseAcknowledgeMessage => 'Bitte bestätigen!';

  @override
  String get createKeyMyselfButtonLabel => 'Ich erstelle den Schlüssel selbst';

  @override
  String welcomeToAppName(String appName) {
    return 'Willkommen bei $appName';
  }

  @override
  String get e2eEncryptionDescription => 'Wir verwenden Ende-zu-Ende-Verschlüsselung, um sicherzustellen, dass all deine Notizen sicher sind und niemand sonst sie sehen kann, nicht einmal wir.';

  @override
  String get timeToStartEncryptionLabel => 'Zeit, die Verschlüsselung zu starten!';

  @override
  String get nextButtonLabel => 'Weiter';

  @override
  String get sendingOtpFailedMessage => 'Senden des OTP fehlgeschlagen. Bitte versuche es erneut!';

  @override
  String get otpVerificationFailedMessage => 'OTP-Verifizierung fehlgeschlagen. Bitte versuche es erneut!';

  @override
  String get emailSignInTitle => 'E-Mail-Anmeldung';

  @override
  String get verifyOtpLabel => 'OTP verifizieren';

  @override
  String get enterEmailLabel => 'E-Mail eingeben';

  @override
  String get sendOtpLabel => 'OTP senden';

  @override
  String otpSentToEmailMessage(String email) {
    return 'Wir haben ein Einmalpasswort (OTP) an deine E-Mail-Adresse $email gesendet';
  }

  @override
  String get enterOtpLabel => 'OTP eingeben';

  @override
  String get changeEmailLabel => 'E-Mail ändern';

  @override
  String get encryptingNotesTitle => 'Notizen werden verschlüsselt';

  @override
  String get fetchingDetailsTitle => 'Details werden abgerufen';

  @override
  String get couldNotFetchMessage => 'Abruf fehlgeschlagen';

  @override
  String get subscriptionEmailMismatchMessage => 'Dein Abonnement ist mit einer anderen E-Mail-Adresse verknüpft. Bitte melde dich ab und verwende diese, um den Cloud-Speicher zu aktivieren.';

  @override
  String get errorCheckingPlanDetailsMessage => 'Fehler beim Überprüfen der Tarifdetails';

  @override
  String get registerDeviceTitle => 'Gerät registrieren';

  @override
  String get manageButtonLabel => 'Verwalten';

  @override
  String get fetchingKeysTitle => 'Schlüssel werden abgerufen';

  @override
  String get signingOutTitle => 'Abmelden';

  @override
  String get pleaseCheckInternetMessage => 'Bitte Internetverbindung prüfen';

  @override
  String get somethingWentWrongMessage => 'Etwas ist schiefgelaufen';

  @override
  String get playPauseTooltip => 'Wiedergabe/Pause';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => 'Herunterladen';

  @override
  String get invalidAccessKey => 'Ungültiger Zugriffsschlüssel';

  @override
  String get fileDoesNotContain24Words => 'Die Datei enthält nicht exakt 24 Wörter.';

  @override
  String get errorReadingFile => 'Fehler beim Lesen der Datei';

  @override
  String get allLabel => 'Alle';

  @override
  String get logTypeDebug => 'DEBUG';

  @override
  String get logTypeError => 'FEHLER';

  @override
  String get logTypeInfo => 'INFO';

  @override
  String get logTypeWarning => 'WARNUNG';

  @override
  String get groupTitleHint => 'Gruppentitel';

  @override
  String get categoryLabel => 'Kategorie';

  @override
  String get selectCategoryPlaceholder => 'Kategorie auswählen';

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
  String get searchHint => 'Suche, #Dokument usw.';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => 'Audiodatei';

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
  String get selectLanguageTitle => 'Sprache auswählen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get themeLabel => 'Design';

  @override
  String get dayNightThemeTooltip => 'Tag-/Nacht-Design';

  @override
  String get lockLabel => 'Sperre';

  @override
  String get timeFormatLabel => 'Zeitformat';

  @override
  String get h12Label => '12 Std.';

  @override
  String get h24Label => '24 Std.';

  @override
  String get fontSizeLabel => 'Schriftgröße';

  @override
  String get reduceTextSizeTooltip => 'Schriftgröße verringern';

  @override
  String get increaseTextSizeTooltip => 'Schriftgröße erhöhen';

  @override
  String get languageLabel => 'Sprache';

  @override
  String get autoOpenGroupLabel => 'Gruppe automatisch öffnen';

  @override
  String get selectGroupTitle => 'Gruppe auswählen';

  @override
  String shareAppMessage(String appName, String appLink) {
    return 'Erstelle ein $appName: $appLink';
  }

  @override
  String get noteTypeEmpty => 'Leer';

  @override
  String get noteTypeImage => 'Bild';

  @override
  String get noteTypeVideo => 'Video';

  @override
  String get noteTypeAudio => 'Audio';

  @override
  String get noteTypeDocument => 'Dokument';

  @override
  String get noteTypeContact => 'Kontakt';

  @override
  String get noteTypeLocation => 'Standort';

  @override
  String get noteTypeUnknown => 'Unbekannt';

  @override
  String get pleaseEnterData => 'Bitte gib Daten ein';

  @override
  String get aNumber => 'Eine Zahl';

  @override
  String get enterDataLabel => 'Daten eingeben';

  @override
  String get pleaseEnterValidData => 'Bitte gib gültige Daten ein';

  @override
  String get pleaseSelectAnOption => 'Bitte wähle eine Option aus';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => 'Heute';

  @override
  String get yesterdayLabel => 'Gestern';

  @override
  String get mondayLabel => 'Montag';

  @override
  String get tuesdayLabel => 'Dienstag';

  @override
  String get wednesdayLabel => 'Mittwoch';

  @override
  String get thursdayLabel => 'Donnerstag';

  @override
  String get fridayLabel => 'Freitag';

  @override
  String get saturdayLabel => 'Samstag';

  @override
  String get sundayLabel => 'Sonntag';

  @override
  String get januaryShortLabel => 'Jan';

  @override
  String get februaryShortLabel => 'Feb';

  @override
  String get marchShortLabel => 'Mär';

  @override
  String get aprilShortLabel => 'Apr';

  @override
  String get mayShortLabel => 'Mai';

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
  String get decemberShortLabel => 'Dez';

  @override
  String noteGroupDateTitleFormat(String month, String day, String dayOfWeek) {
    return '$dayOfWeek, $day. $month';
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
    return '$count Notizgruppe';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count Notizgruppen';
  }

  @override
  String get seedCategoryTasks => 'Aufgaben';

  @override
  String get seedGroupNotes => 'Notizen';

  @override
  String get seedGroupFitness => 'Fitness';

  @override
  String get seedItemWelcome => 'Willkommen bei Note Safe!\nIdeen, Listen oder was dir auch immer durch den Kopf geht – speichere es einfach hier.\n\nHalte diese Notiz gedrückt, um sie zu bearbeiten, zu löschen oder weitere Optionen zu sehen.';

  @override
  String get seedItemMorningWorkout => 'Morgentraining';

  @override
  String get seedItemMeditation => '10 Minuten Meditation';

  @override
  String get seedItemWater => '2 l Wasser am Tag';

  @override
  String get seedItemSteps => '10.000 Schritte gehen';
}

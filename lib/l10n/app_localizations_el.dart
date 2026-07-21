// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get importantTitle => 'Σημαντικό';

  @override
  String get accessKeyNoticeDescription1 => 'Στην επόμενη σελίδα θα δείτε μια σειρά από 24 λέξεις. Αυτό είναι το μοναδικό και απόρρητο κλειδί κρυπτογράφησής σας και είναι ο ΜΟΝΑΔΙΚΟΣ τρόπος για να ανακτήσετε τις σημειώσεις σας σε περίπτωση αποσύνδεσης, απώλειας συσκευής ή δυσλειτουργίας.';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return 'Δεν αποθηκεύουμε το κλειδί. Είναι ΔΙΚΗ ΣΑΣ ευθύνη να το αποθηκεύσετε σε ασφαλές μέρος εκτός της εφαρμογής $appName.';
  }

  @override
  String get iUnderstandShowMeTheKey => 'Καταλαβαίνω.\nΔείξε μου το κλειδί.';

  @override
  String get selectGroupToViewNotes => 'Επιλέξτε μια ομάδα για να δείτε τις σημειώσεις';

  @override
  String get accessKeyShareText => 'Ορίστε το κλειδί πρόσβασής σας.';

  @override
  String get pleaseTryAgain => 'Παρακαλώ προσπαθήστε ξανά.';

  @override
  String get copiedToClipboard => 'Αντιγράφηκε στο πρόχειρο';

  @override
  String get accessKeyTitle => 'Κλειδί πρόσβασης';

  @override
  String get accessKeyDescription => 'Παρακαλώ αποθηκεύστε αυτό το κλειδί σε ασφαλές μέρος. Θα το χρειαστείτε για να συγχρονίσετε τις σημειώσεις σας σε άλλη συσκευή.';

  @override
  String get copyLabel => 'Αντιγραφή';

  @override
  String get downloadAsTextFileLabel => 'Λήψη ως αρχείο κειμένου';

  @override
  String get continueLabel => 'Συνέχεια';

  @override
  String get pleaseAuthenticate => 'Παρακαλώ κάντε ταυτοποίηση';

  @override
  String get couldNotCreate => 'Δεν ήταν δυνατή η δημιουργία';

  @override
  String get couldNotShareFile => 'Δεν ήταν δυνατή η κοινή χρήση του αρχείου';

  @override
  String get hereIsTheBackupFile => 'Ορίστε το αρχείο αντιγράφου ασφαλείας για την εφαρμογή σας.';

  @override
  String get errorTitle => 'Σφάλμα';

  @override
  String get backupLabel => 'Αντίγραφο ασφαλείας';

  @override
  String get restoreLabel => 'Επαναφορά';

  @override
  String get leaveAReviewLabel => 'Αφήστε μια κριτική';

  @override
  String get shareLabel => 'Κοινοποίηση';

  @override
  String get desktopAppLinkLabel => 'Εφαρμογή για υπολογιστή';

  @override
  String get loggingLabel => 'Καταγραφή';

  @override
  String versionLabel(String version) {
    return 'Έκδοση: $version';
  }

  @override
  String get loadingLabel => 'Φόρτωση...';

  @override
  String get restoredLabel => 'Αποκαταστάθηκε.';

  @override
  String get deletedPermanentlyLabel => 'Διαγράφηκε μόνιμα.';

  @override
  String get mediaTitle => 'Πολυμέσα';

  @override
  String get invalidWordList => 'Μη έγκυρη λίστα λέξεων';

  @override
  String get enterYour24WordPhrase => 'Εισαγάγετε τη φράση 24 λέξεων';

  @override
  String get enterYourRecoveryPhraseHere => 'Εισαγάγετε εδώ τη φράση ανάκτησης';

  @override
  String get pleaseEnterYourRecoveryPhrase => 'Παρακαλώ εισαγάγετε τη φράση ανάκτησης';

  @override
  String get recoveryPhraseMustContain24Words => 'Η φράση ανάκτησης πρέπει να περιέχει ακριβώς 24 λέξεις';

  @override
  String get submitLabel => 'Υποβολή';

  @override
  String get orLabel => 'Ή';

  @override
  String get selectTxtFileLabel => 'Επιλογή αρχείου .txt';

  @override
  String get failureTitle => 'Αποτυχία';

  @override
  String get invalidPasswordKey => 'Μη έγκυρο κλειδί κωδικού πρόσβασης';

  @override
  String get enableSyncTitle => 'Ενεργοποίηση συγχρονισμού';

  @override
  String get passwordRequirementsDescription => 'Παρακαλώ εισαγάγετε το κλειδί (κωδικό πρόσβασης) που έχετε δημιουργήσει. Πρέπει να έχει μήκος τουλάχιστον 10 χαρακτήρες, με τουλάχιστον 1 αριθμό, 1 πεζό, 1 κεφαλαίο γράμμα και 1 ειδικό χαρακτήρα.';

  @override
  String get enterKeyLabel => 'Εισαγωγή κλειδιού';

  @override
  String get pleaseEnterKey => 'Παρακαλώ εισαγάγετε το κλειδί';

  @override
  String get filterNotesTitle => 'Φιλτράρισμα σημειώσεων';

  @override
  String get filterPinnedNotesTooltip => 'Φιλτράρισμα καρφιτσωμένων σημειώσεων';

  @override
  String get filterStarredNotesTooltip => 'Φιλτράρισμα σημειώσεων με αστέρι';

  @override
  String get filterTextNotesTooltip => 'Φιλτράρισμα σημειώσεων κειμένου';

  @override
  String get filterTasksTooltip => 'Φιλτράρισμα εργασιών';

  @override
  String get filterLinksTooltip => 'Φιλτράρισμα συνδέσμων';

  @override
  String get filterImagesTooltip => 'Φιλτράρισμα εικόνων';

  @override
  String get filterAudioTooltip => 'Φιλτράρισμα ήχου';

  @override
  String get filterVideoTooltip => 'Φιλτράρισμα βίντεο';

  @override
  String get filterFilesTooltip => 'Φιλτράρισμα αρχείων';

  @override
  String get filterContactsTooltip => 'Φιλτράρισμα επαφών';

  @override
  String get filterLocationTooltip => 'Φιλτράρισμα τοποθεσίας';

  @override
  String get movedToTrash => 'Μετακινήθηκε στον κάδο απορριμμάτων';

  @override
  String get copiedNotesToClipboard => 'Αντιγράφηκε στο πρόχειρο';

  @override
  String get locationShareLabel => 'Τοποθεσία:';

  @override
  String get contactShareLabel => 'Επαφή:';

  @override
  String get emailsShareLabel => 'Email:';

  @override
  String get addressesShareLabel => 'Διευθύνσεις:';

  @override
  String get microphoneNotAvailable => 'Το μικρόφωνο ενδέχεται να μην είναι διαθέσιμο.';

  @override
  String get microphonePermissionRequired => 'Απαιτείται άδεια μικροφώνου για την εγγραφή ήχου.';

  @override
  String get couldNotGetDuration => 'Δεν ήταν δυνατή η λήψη της διάρκειας';

  @override
  String get errorOpeningFiles => 'Σφάλμα κατά το άνοιγμα αρχείων';

  @override
  String get pleaseWaitTitle => 'Παρακαλώ περιμένετε';

  @override
  String get fileNotAvailableYet => 'Το αρχείο δεν είναι ακόμα διαθέσιμο';

  @override
  String get clearSelectionTooltip => 'Καθαρισμός επιλογής';

  @override
  String get copyNotesTooltip => 'Αντιγραφή σημειώσεων';

  @override
  String get changeTaskTypeTooltip => 'Αλλαγή τύπου εργασίας';

  @override
  String get shareNotesTooltip => 'Κοινοποίηση σημειώσεων';

  @override
  String get editNoteTooltip => 'Επεξεργασία σημείωσης';

  @override
  String get starUnstarNotesTooltip => 'Προσθήκη/αφαίρεση αστεριού';

  @override
  String get moveToTrashTooltip => 'Μετακίνηση στον κάδο';

  @override
  String get pinUnpinNotesTooltip => 'Καρφίτσωμα/ξεκαρφίτσωμα σημειώσεων';

  @override
  String get cancelReplyTooltip => 'Ακύρωση απάντησης';

  @override
  String get createTaskHint => 'Δημιουργία εργασίας';

  @override
  String get addNoteHint => 'Προσθήκη σημείωσης...';

  @override
  String get attachTooltip => 'Επισύναψη';

  @override
  String get addNoteTooltip => 'Προσθήκη σημείωσης';

  @override
  String get recordStopAudioTooltip => 'Εγγραφή/διακοπή ήχου';

  @override
  String get contactAttachmentLabel => 'Επαφή';

  @override
  String get locationAttachmentLabel => 'Τοποθεσία';

  @override
  String get cameraAttachmentLabel => 'Κάμερα';

  @override
  String get filesAttachmentLabel => 'Αρχεία';

  @override
  String get checklistAttachmentLabel => 'Λίστα ελέγχου';

  @override
  String get accessKeyInputTitle => 'Ενεργοποίηση συγχρονισμού';

  @override
  String get accessKeyInputDescription => 'Παρακαλώ εισαγάγετε τη φράση ανάκτησης 24 λέξεων ή φορτώστε ένα αρχείο .txt που την περιέχει.';

  @override
  String get editMenuItemLabel => 'Επεξεργασία';

  @override
  String get filterMenuItemLabel => 'Φίλτρα';

  @override
  String get externalStoragePermissionDenied => 'Η άδεια πρόσβασης στον εξωτερικό αποθηκευτικό χώρο απορρίφθηκε.';

  @override
  String get pressLongToStartRecording => 'Πατήστε παρατεταμένα για έναρξη εγγραφής.';

  @override
  String get didYouKnowTitle => 'Το γνωρίζατε;';

  @override
  String get closeTooltip => 'Κλείσιμο';

  @override
  String appDescriptionContent(String appName) {
    return 'Το $appName είναι μια πλήρως ιδιωτική εφαρμογή σημειώσεων. Δεν συλλέγει τα προσωπικά σας δεδομένα και δεν εμφανίζει διαφημίσεις.\n\nΕλπίζουμε να απολαύσετε τη χρήση του. Πείτε μας τη γνώμη σας.';
  }

  @override
  String get searchNotesTooltip => 'Αναζήτηση σημειώσεων';

  @override
  String get syncMenuItemLabel => 'Συγχρονισμός';

  @override
  String get trashMenuItemLabel => 'Κάδος';

  @override
  String get starredNotesMenuItemLabel => 'Σημειώσεις με αστέρι';

  @override
  String get settingsMenuItemLabel => 'Ρυθμίσεις';

  @override
  String get accountMenuItemLabel => 'Λογαριασμός';

  @override
  String get pageMenuItemLabel => 'Σελίδα';

  @override
  String get sqliteMenuItemLabel => 'Sqlite';

  @override
  String get logsMenuItemLabel => 'Αρχεία καταγραφής';

  @override
  String get reorderMenuItemLabel => 'Αναδιάταξη';

  @override
  String get editGroupMenuItemLabel => 'Επεξεργασία';

  @override
  String get deleteGroupMenuItemLabel => 'Διαγραφή';

  @override
  String get dragHandleReorderTooltip => 'Σύρετε τη λαβή για αναδιάταξη';

  @override
  String get holdAndDragReorderTooltip => 'Κρατήστε και σύρετε για αναδιάταξη';

  @override
  String get emptyHomePageMessage => 'Γεια σας!\n\nΕδώ είναι λίγο άδειο.\n\nΠατήστε το κουμπί + και δημιουργήστε μερικές σημειώσεις. :)';

  @override
  String get reorderingTitle => 'Αναδιάταξη';

  @override
  String get selectEllipsisLabel => 'Επιλογή...';

  @override
  String get dateTimeToggleLabel => 'Ημερομηνία/Ώρα';

  @override
  String get noteBorderToggleLabel => 'Περίγραμμα σημείωσης';

  @override
  String get deleteGroupButtonLabel => 'Διαγραφή';

  @override
  String get notesTabLabel => 'Σημειώσεις';

  @override
  String get groupsTabLabel => 'Ομάδες';

  @override
  String get categoriesTabLabel => 'Κατηγορίες';

  @override
  String get locationItemLabel => 'Τοποθεσία';

  @override
  String get addGroupTitle => 'Προσθήκη ομάδας';

  @override
  String get editGroupTitle => 'Επεξεργασία ομάδας';

  @override
  String get titleInputLabel => 'Τίτλος';

  @override
  String get locationPermissionRequiredTitle => 'Απαιτείται άδεια τοποθεσίας';

  @override
  String get enableLocationPermissionsContent => 'Παρακαλώ ενεργοποιήστε τις άδειες τοποθεσίας στις ρυθμίσεις της εφαρμογής.';

  @override
  String get cancelButtonLabel => 'Ακύρωση';

  @override
  String get openSettingsButtonLabel => 'Άνοιγμα ρυθμίσεων';

  @override
  String get locationServicesTitle => 'Υπηρεσίες τοποθεσίας';

  @override
  String get pleaseEnableLocationServicesContent => 'Παρακαλώ ενεργοποιήστε τις!';

  @override
  String get selectLocationTitle => 'Επιλογή τοποθεσίας';

  @override
  String get useCurrentLocationTooltip => 'Χρήση τρέχουσας τοποθεσίας';

  @override
  String get selectAllButtonLabel => 'Επιλογή όλων';

  @override
  String get searchLogsHint => 'Αναζήτηση αρχείων καταγραφής...';

  @override
  String get noLogsAvailable => 'Δεν υπάρχουν διαθέσιμα αρχεία καταγραφής';

  @override
  String get dbViewerTitle => 'Προβολή βάσης δεδομένων';

  @override
  String get selectTableToViewData => 'Επιλέξτε έναν πίνακα για να δείτε τα δεδομένα του';

  @override
  String get selectTableDropdownHint => 'Επιλέξτε έναν πίνακα';

  @override
  String get pickContactTitle => 'Επιλογή επαφής';

  @override
  String get permissionRequiredText => 'Απαιτείται άδεια';

  @override
  String get grantPermissionButtonLabel => 'Παροχή άδειας';

  @override
  String get pageDummyTitle => 'Σελίδα δοκιμής';

  @override
  String get simulateButtonLabel => 'Προσομοίωση';

  @override
  String get selectCategoryTitle => 'Επιλογή κατηγορίας';

  @override
  String get addCategoryTitle => 'Προσθήκη κατηγορίας';

  @override
  String get editCategoryTitle => 'Επεξεργασία κατηγορίας';

  @override
  String get categoryTitleHint => 'Τίτλος κατηγορίας';

  @override
  String get colorLabel => 'Χρώμα';

  @override
  String get changeColorLabel => 'Αλλαγή χρώματος';

  @override
  String get deviceDisabledMessage => 'Η συσκευή απενεργοποιήθηκε!';

  @override
  String get cannotRemoveThisDeviceMessage => 'Δεν είναι δυνατή η αφαίρεση αυτής της συσκευής!';

  @override
  String get confirmRemoveTitle => 'Επιβεβαίωση αφαίρεσης';

  @override
  String get confirmRemoveDeviceContent => 'Είστε σίγουροι; Αυτό θα διαγράψει όλα τα δεδομένα στη συσκευή.';

  @override
  String get okButtonLabel => 'OK';

  @override
  String get registeredDevicesTitle => 'Εγγεγραμμένες συσκευές';

  @override
  String get noDevicesFoundMessage => 'Δεν βρέθηκαν συσκευές';

  @override
  String get enabledLabel => 'Ενεργοποιημένη';

  @override
  String get disabledLabel => 'Απενεργοποιημένη';

  @override
  String get migratingMediaTitle => 'Μεταφορά πολυμέσων';

  @override
  String get processingMessage => 'Επεξεργασία...';

  @override
  String get doNotNavigateAwayMessage => 'Παρακαλώ μην απομακρυνθείτε';

  @override
  String errorWithDetails(String error) {
    return 'Σφάλμα: $error';
  }

  @override
  String get sequenceNotAcceptedError => 'Η ακολουθία δεν έγινε δεκτή';

  @override
  String get examplesNotAcceptedError => 'Τα παραδείγματα δεν έγιναν δεκτά';

  @override
  String get enterKeyAgainLabel => 'Εισαγάγετε ξανά το κλειδί';

  @override
  String get pleaseEnterKeyAgainError => 'Παρακαλώ εισαγάγετε ξανά το κλειδί';

  @override
  String get keysDoNotMatchError => 'Τα κλειδιά δεν ταιριάζουν';

  @override
  String get ruleUppercaseLetter => '1 κεφαλαίο γράμμα';

  @override
  String get ruleLowercaseLetter => '1 πεζό γράμμα';

  @override
  String get ruleNumericLetter => '1 αριθμός';

  @override
  String get ruleSpecialCharacter => '1 ειδικός χαρακτήρας';

  @override
  String get ruleMinTenCharacters => 'τουλάχιστον 10 χαρακτήρες';

  @override
  String get examplesTitle => 'Παραδείγματα';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => 'Το κατάλαβα';

  @override
  String get encryptionKeyTitle => 'Κλειδί κρυπτογράφησης';

  @override
  String get createKeyDescription => 'Παρακαλώ εισαγάγετε ένα μεγάλο και δύσκολο στην πρόβλεψη κλειδί (κωδικό πρόσβασης). Θυμηθείτε να το αποθηκεύσετε σε ασφαλές μέρος. Αν χαθεί ή ξεχαστεί, δεν μπορεί να ανακτηθεί.';

  @override
  String get seeExamplesTooltip => 'Δείτε παραδείγματα';

  @override
  String get couldNotFetchDetailsMessage => 'Δεν ήταν δυνατή η ανάκτηση των λεπτομερειών';

  @override
  String get retryButtonLabel => 'Επανάληψη';

  @override
  String get signedInAsLabel => 'Συνδεδεμένος ως:';

  @override
  String get storageUsageLabel => 'Χρήση αποθηκευτικού χώρου';

  @override
  String get subscribeLabel => 'Εγγραφή';

  @override
  String get planExpiredRenewLabel => 'Το πρόγραμμα έληξε! Ανανέωση';

  @override
  String get manageDevicesLabel => 'Διαχείριση συσκευών';

  @override
  String get viewAccessKeyLabel => 'Προβολή κλειδιού πρόσβασης';

  @override
  String get changeKeyPasswordLabel => 'Αλλαγή κλειδιού κωδικού πρόσβασης';

  @override
  String get manageSubscriptionLabel => 'Διαχείριση συνδρομής';

  @override
  String get signOutButtonLabel => 'Αποσύνδεση';

  @override
  String get yearlyPlansTitle => 'Ετήσια προγράμματα';

  @override
  String get loginLabel => 'Σύνδεση';

  @override
  String get syncAllYourNotesLabel => 'Συγχρονίστε όλες τις σημειώσεις σας';

  @override
  String get acrossYourDevicesLabel => 'σε όλες τις συσκευές σας';

  @override
  String get featureEndToEndEncryption => 'Κρυπτογράφηση από άκρο σε άκρο';

  @override
  String get featureSyncUpTo3Devices => 'Συγχρονισμός έως 3 συσκευών';

  @override
  String get featureUpgradeCancelAnytime => 'Αναβάθμιση/Ακύρωση ανά πάσα στιγμή';

  @override
  String get noPlansAvailableMessage => 'Δεν υπάρχουν διαθέσιμα προγράμματα';

  @override
  String get downloadAppSubscribeLabel => 'Κατεβάστε την εφαρμογή & εγγραφείτε';

  @override
  String get privacyTermsLabel => 'Ιδιωτικότητα • Όροι';

  @override
  String get saveFiftyPercentLabel => 'Εξοικονομήστε 50%';

  @override
  String get helloTitle => 'Γεια σας';

  @override
  String get selectKeyMasterKeyDescription => 'Για να κρυπτογραφήσουμε τα δεδομένα σας, θα χρειαστούμε ένα κύριο κλειδί κρυπτογράφησης.';

  @override
  String get selectKeyTwoOptionsDescription => 'Υπάρχουν 2 επιλογές - είτε δημιουργείτε εσείς το κλειδί (παρόμοια με κωδικό πρόσβασης) είτε το δημιουργούμε εμείς για εσάς.';

  @override
  String get understandLoseKeyAcknowledgement => 'Καταλαβαίνω ότι αν χάσω/ξεχάσω το κλειδί κρυπτογράφησης, μπορεί να χάσω τα δεδομένα.';

  @override
  String get createKeyForMeButtonLabel => 'Δημιούργησε το κλειδί για μένα';

  @override
  String get recommendedLabel => '(Προτείνεται)';

  @override
  String get pleaseAcknowledgeMessage => 'Παρακαλώ επιβεβαιώστε!';

  @override
  String get createKeyMyselfButtonLabel => 'Θα δημιουργήσω το κλειδί μόνος μου';

  @override
  String welcomeToAppName(String appName) {
    return 'Καλώς ήρθατε στο $appName';
  }

  @override
  String get e2eEncryptionDescription => 'Χρησιμοποιούμε κρυπτογράφηση από άκρο σε άκρο για να βεβαιωθούμε ότι όλες οι σημειώσεις σας είναι ασφαλείς και κανείς άλλος δεν μπορεί να τις δει, ούτε καν εμείς.';

  @override
  String get timeToStartEncryptionLabel => 'Ώρα να ξεκινήσει η κρυπτογράφηση!';

  @override
  String get nextButtonLabel => 'Επόμενο';

  @override
  String get sendingOtpFailedMessage => 'Η αποστολή του OTP απέτυχε. Παρακαλώ προσπαθήστε ξανά!';

  @override
  String get otpVerificationFailedMessage => 'Η επαλήθευση του OTP απέτυχε. Παρακαλώ προσπαθήστε ξανά!';

  @override
  String get emailSignInTitle => 'Σύνδεση με Email';

  @override
  String get verifyOtpLabel => 'Επαλήθευση OTP';

  @override
  String get enterEmailLabel => 'Εισαγωγή Email';

  @override
  String get sendOtpLabel => 'Αποστολή OTP';

  @override
  String otpSentToEmailMessage(String email) {
    return 'Έχουμε στείλει έναν κωδικό μιας χρήσης (OTP) στο email σας $email';
  }

  @override
  String get enterOtpLabel => 'Εισαγωγή OTP';

  @override
  String get changeEmailLabel => 'Αλλαγή email';

  @override
  String get encryptingNotesTitle => 'Κρυπτογράφηση σημειώσεων';

  @override
  String get fetchingDetailsTitle => 'Ανάκτηση λεπτομερειών';

  @override
  String get couldNotFetchMessage => 'Δεν ήταν δυνατή η ανάκτηση';

  @override
  String get subscriptionEmailMismatchMessage => 'Η συνδρομή σας σχετίζεται με άλλο email. Παρακαλώ αποσυνδεθείτε και χρησιμοποιήστε εκείνο για να ενεργοποιήσετε τον αποθηκευτικό χώρο στο cloud.';

  @override
  String get errorCheckingPlanDetailsMessage => 'Σφάλμα κατά τον έλεγχο των λεπτομερειών του προγράμματος';

  @override
  String get registerDeviceTitle => 'Εγγραφή συσκευής';

  @override
  String get manageButtonLabel => 'Διαχείριση';

  @override
  String get fetchingKeysTitle => 'Ανάκτηση κλειδιών';

  @override
  String get signingOutTitle => 'Αποσύνδεση';

  @override
  String get pleaseCheckInternetMessage => 'Παρακαλώ ελέγξτε το διαδίκτυο';

  @override
  String get somethingWentWrongMessage => 'Κάτι πήγε στραβά';

  @override
  String get playPauseTooltip => 'Αναπαραγωγή/παύση';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => 'Λήψη';

  @override
  String get invalidAccessKey => 'Μη έγκυρο κλειδί πρόσβασης';

  @override
  String get fileDoesNotContain24Words => 'Το αρχείο δεν περιέχει ακριβώς 24 λέξεις.';

  @override
  String get errorReadingFile => 'Σφάλμα κατά την ανάγνωση του αρχείου';

  @override
  String get allLabel => 'Όλα';

  @override
  String get logTypeDebug => 'DEBUG';

  @override
  String get logTypeError => 'ΣΦΑΛΜΑ';

  @override
  String get logTypeInfo => 'ΠΛΗΡΟΦΟΡΙΕΣ';

  @override
  String get logTypeWarning => 'ΠΡΟΕΙΔΟΠΟΙΗΣΗ';

  @override
  String get groupTitleHint => 'Τίτλος ομάδας';

  @override
  String get categoryLabel => 'Κατηγορία';

  @override
  String get selectCategoryPlaceholder => 'Επιλογή κατηγορίας';

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
  String get searchHint => 'ερώτημα, #έγγραφο κλπ..';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => 'Αρχείο ήχου';

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
  String get selectLanguageTitle => 'Επιλογή γλώσσας';

  @override
  String get settingsTitle => 'Ρυθμίσεις';

  @override
  String get themeLabel => 'Θέμα';

  @override
  String get dayNightThemeTooltip => 'Θέμα ημέρας/νύχτας';

  @override
  String get lockLabel => 'Κλείδωμα';

  @override
  String get timeFormatLabel => 'Μορφή ώρας';

  @override
  String get h12Label => '12ωρη';

  @override
  String get h24Label => '24ωρη';

  @override
  String get fontSizeLabel => 'Μέγεθος γραμματοσειράς';

  @override
  String get reduceTextSizeTooltip => 'Μείωση μεγέθους κειμένου';

  @override
  String get increaseTextSizeTooltip => 'Αύξηση μεγέθους κειμένου';

  @override
  String get languageLabel => 'Γλώσσα';

  @override
  String get autoOpenGroupLabel => 'Αυτόματο άνοιγμα ομάδας';

  @override
  String get selectGroupTitle => 'Επιλογή ομάδας';

  @override
  String shareAppMessage(String appName, String appLink) {
    return 'Δημιουργήστε ένα $appName: $appLink';
  }

  @override
  String get noteTypeEmpty => 'Άδεια';

  @override
  String get noteTypeImage => 'Εικόνα';

  @override
  String get noteTypeVideo => 'Βίντεο';

  @override
  String get noteTypeAudio => 'Ήχος';

  @override
  String get noteTypeDocument => 'Έγγραφο';

  @override
  String get noteTypeContact => 'Επαφή';

  @override
  String get noteTypeLocation => 'Τοποθεσία';

  @override
  String get noteTypeUnknown => 'Άγνωστο';

  @override
  String get pleaseEnterData => 'Παρακαλώ εισαγάγετε δεδομένα';

  @override
  String get aNumber => 'Ένας αριθμός';

  @override
  String get enterDataLabel => 'Εισαγωγή δεδομένων';

  @override
  String get pleaseEnterValidData => 'Παρακαλώ εισαγάγετε έγκυρα δεδομένα';

  @override
  String get pleaseSelectAnOption => 'Παρακαλώ επιλέξτε μια επιλογή';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => 'Σήμερα';

  @override
  String get yesterdayLabel => 'Χθες';

  @override
  String get mondayLabel => 'Δευτέρα';

  @override
  String get tuesdayLabel => 'Τρίτη';

  @override
  String get wednesdayLabel => 'Τετάρτη';

  @override
  String get thursdayLabel => 'Πέμπτη';

  @override
  String get fridayLabel => 'Παρασκευή';

  @override
  String get saturdayLabel => 'Σάββατο';

  @override
  String get sundayLabel => 'Κυριακή';

  @override
  String get januaryShortLabel => 'Ιαν';

  @override
  String get februaryShortLabel => 'Φεβ';

  @override
  String get marchShortLabel => 'Μαρ';

  @override
  String get aprilShortLabel => 'Απρ';

  @override
  String get mayShortLabel => 'Μαΐ';

  @override
  String get juneShortLabel => 'Ιουν';

  @override
  String get julyShortLabel => 'Ιουλ';

  @override
  String get augustShortLabel => 'Αυγ';

  @override
  String get septemberShortLabel => 'Σεπ';

  @override
  String get octoberShortLabel => 'Οκτ';

  @override
  String get novemberShortLabel => 'Νοε';

  @override
  String get decemberShortLabel => 'Δεκ';

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
    return '$count ομάδα σημειώσεων';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count ομάδες σημειώσεων';
  }


  @override
  String get seedCategoryTasks => "Εργασίες";

  @override
  String get seedGroupNotes => "Σημειώσεις";

  @override
  String get seedGroupFitness => "Γυμναστική";

  @override
  String get seedItemWelcome =>
      "Καλώς ήρθατε στο Note Safe!\nΙδέες, λίστες ή οτιδήποτε άλλο έχετε στο μυαλό σας, καταγράψτε τα εδώ.\n\nΠατήστε παρατεταμένα σε αυτή τη σημείωση για διαγραφή, επεξεργασία και άλλες επιλογές.";

  @override
  String get seedItemMorningWorkout => "Πρωινή γυμναστική";

  @override
  String get seedItemMeditation => "10 λεπτά διαλογισμού";

  @override
  String get seedItemWater => "2 λίτρα νερό την ημέρα";

  @override
  String get seedItemSteps => "Περπάτημα 10.000 βήματα";
}
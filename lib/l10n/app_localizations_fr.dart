// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get importantTitle => 'Important';

  @override
  String get accessKeyNoticeDescription1 => 'Sur la page suivante, vous verrez une série de 24 mots. Il s\'agit de votre clé de chiffrement unique et privée, et c\'est le SEUL moyen de récupérer vos notes en cas de déconnexion, de perte ou de dysfonctionnement de votre appareil.';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return 'Nous ne stockons pas la clé. Il est de VOTRE responsabilité de la conserver en lieu sûr, en dehors de l\'application $appName.';
  }

  @override
  String get iUnderstandShowMeTheKey => 'Je comprends.\nAfficher la clé.';

  @override
  String get selectGroupToViewNotes => 'Sélectionnez un groupe pour voir les notes';

  @override
  String get accessKeyShareText => 'Voici votre clé d\'accès.';

  @override
  String get pleaseTryAgain => 'Veuillez réessayer.';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papier';

  @override
  String get accessKeyTitle => 'Clé d\'accès';

  @override
  String get accessKeyDescription => 'Veuillez enregistrer cette clé dans un endroit sûr. Vous en aurez besoin pour synchroniser vos notes sur un autre appareil.';

  @override
  String get copyLabel => 'Copier';

  @override
  String get downloadAsTextFileLabel => 'Télécharger en tant que fichier texte';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get pleaseAuthenticate => 'Veuillez vous authentifier';

  @override
  String get couldNotCreate => 'Création impossible';

  @override
  String get couldNotShareFile => 'Partage de fichier impossible';

  @override
  String get hereIsTheBackupFile => 'Voici le fichier de sauvegarde de votre application.';

  @override
  String get errorTitle => 'Erreur';

  @override
  String get backupLabel => 'Sauvegarde';

  @override
  String get restoreLabel => 'Restaurer';

  @override
  String get leaveAReviewLabel => 'Laisser un avis';

  @override
  String get shareLabel => 'Partager';

  @override
  String get desktopAppLinkLabel => 'Application de bureau';

  @override
  String get loggingLabel => 'Journalisation';

  @override
  String versionLabel(String version) {
    return 'Version : $version';
  }

  @override
  String get loadingLabel => 'Chargement...';

  @override
  String get restoredLabel => 'Restauré.';

  @override
  String get deletedPermanentlyLabel => 'Supprimé définitivement.';

  @override
  String get mediaTitle => 'Média';

  @override
  String get invalidWordList => 'Liste de mots invalide';

  @override
  String get enterYour24WordPhrase => 'Saisissez votre phrase de 24 mots';

  @override
  String get enterYourRecoveryPhraseHere => 'Saisissez votre phrase de récupération ici';

  @override
  String get pleaseEnterYourRecoveryPhrase => 'Veuillez saisir votre phrase de récupération';

  @override
  String get recoveryPhraseMustContain24Words => 'La phrase de récupération doit contenir exactement 24 mots';

  @override
  String get submitLabel => 'Soumettre';

  @override
  String get orLabel => 'Ou';

  @override
  String get selectTxtFileLabel => 'Sélectionner un fichier .txt';

  @override
  String get failureTitle => 'Échec';

  @override
  String get invalidPasswordKey => 'Clé de mot de passe invalide';

  @override
  String get enableSyncTitle => 'Activer la synchronisation';

  @override
  String get passwordRequirementsDescription => 'Veuillez saisir la clé (mot de passe) que vous avez créée. Elle doit comporter au moins 10 caractères, dont 1 chiffre, 1 minuscule, 1 majuscule et 1 caractère spécial.';

  @override
  String get enterKeyLabel => 'Saisir la clé';

  @override
  String get pleaseEnterKey => 'Veuillez saisir la clé';

  @override
  String get filterNotesTitle => 'Filtrer les notes';

  @override
  String get filterPinnedNotesTooltip => 'Filtrer les notes épinglées';

  @override
  String get filterStarredNotesTooltip => 'Filtrer les notes favorites';

  @override
  String get filterTextNotesTooltip => 'Filtrer les notes textuelles';

  @override
  String get filterTasksTooltip => 'Filtrer les tâches';

  @override
  String get filterLinksTooltip => 'Filtrer les liens';

  @override
  String get filterImagesTooltip => 'Filtrer les images';

  @override
  String get filterAudioTooltip => 'Filtrer l\'audio';

  @override
  String get filterVideoTooltip => 'Filtrer les vidéos';

  @override
  String get filterFilesTooltip => 'Filtrer les fichiers';

  @override
  String get filterContactsTooltip => 'Filtrer les contacts';

  @override
  String get filterLocationTooltip => 'Filtrer l\'emplacement';

  @override
  String get movedToTrash => 'Déplacé vers la corbeille';

  @override
  String get copiedNotesToClipboard => 'Copié dans le presse-papier';

  @override
  String get locationShareLabel => 'Emplacement :';

  @override
  String get contactShareLabel => 'Contact :';

  @override
  String get emailsShareLabel => 'E-mails :';

  @override
  String get addressesShareLabel => 'Adresses :';

  @override
  String get microphoneNotAvailable => 'Le microphone n\'est peut-être pas disponible.';

  @override
  String get microphonePermissionRequired => 'L\'autorisation du microphone est requise pour enregistrer de l\'audio.';

  @override
  String get couldNotGetDuration => 'Impossible d\'obtenir la durée';

  @override
  String get errorOpeningFiles => 'Erreur lors de l\'ouverture des fichiers';

  @override
  String get pleaseWaitTitle => 'Veuillez patienter';

  @override
  String get fileNotAvailableYet => 'Fichier pas encore disponible';

  @override
  String get clearSelectionTooltip => 'Effacer la sélection';

  @override
  String get copyNotesTooltip => 'Copier les notes';

  @override
  String get changeTaskTypeTooltip => 'Changer le type de tâche';

  @override
  String get shareNotesTooltip => 'Partager les notes';

  @override
  String get noNotesSelectedToShare => 'Aucune note sélectionnée à partager';

  @override
  String get nothingToShare => 'Rien à partager';

  @override
  String get shareFailed => 'Échec du partage';

  @override
  String get editNoteTooltip => 'Modifier la note';

  @override
  String get starUnstarNotesTooltip => 'Mettre/retirer des favoris';

  @override
  String get moveToTrashTooltip => 'Déplacer vers la corbeille';

  @override
  String get pinUnpinNotesTooltip => 'Épingler/désépingler des notes';

  @override
  String get cancelReplyTooltip => 'Annuler la réponse';

  @override
  String get createTaskHint => 'Créer une tâche';

  @override
  String get addNoteHint => 'Ajouter une note...';

  @override
  String get attachTooltip => 'Joindre';

  @override
  String get addNoteTooltip => 'Ajouter une note';

  @override
  String get recordStopAudioTooltip => 'Enregistrer/arrêter l\'audio';

  @override
  String get contactAttachmentLabel => 'Contact';

  @override
  String get locationAttachmentLabel => 'Emplacement';

  @override
  String get cameraAttachmentLabel => 'Appareil photo';

  @override
  String get filesAttachmentLabel => 'Fichiers';

  @override
  String get checklistAttachmentLabel => 'Liste de contrôle';

  @override
  String get accessKeyInputTitle => 'Activer la synchronisation';

  @override
  String get accessKeyInputDescription => 'Veuillez saisir votre phrase de récupération de 24 mots ou charger un fichier .txt qui la contient.';

  @override
  String get editMenuItemLabel => 'Modifier';

  @override
  String get filterMenuItemLabel => 'Filtres';

  @override
  String get externalStoragePermissionDenied => 'L\'autorisation d\'accéder au stockage externe a été refusée.';

  @override
  String get pressLongToStartRecording => 'Appuyez longuement pour commencer l\'enregistrement.';

  @override
  String get didYouKnowTitle => 'Le saviez-vous ?';

  @override
  String get closeTooltip => 'Fermer';

  @override
  String appDescriptionContent(String appName) {
    return '$appName est une application de notes totalement privée. Elle ne collecte pas vos données personnelles et ne vous montre aucune publicité.\n\nNous espérons que vous apprécierez son utilisation. Dites-nous ce que vous en pensez.';
  }

  @override
  String get searchNotesTooltip => 'Rechercher des notes';

  @override
  String get syncMenuItemLabel => 'Synchroniser';

  @override
  String get trashMenuItemLabel => 'Corbeille';

  @override
  String get starredNotesMenuItemLabel => 'Notes favorites';

  @override
  String get settingsMenuItemLabel => 'Paramètres';

  @override
  String get accountMenuItemLabel => 'Compte';

  @override
  String get pageMenuItemLabel => 'Page';

  @override
  String get sqliteMenuItemLabel => 'Sqlite';

  @override
  String get logsMenuItemLabel => 'Journaux';

  @override
  String get reorderMenuItemLabel => 'Réorganiser';

  @override
  String get editGroupMenuItemLabel => 'Modifier';

  @override
  String get deleteGroupMenuItemLabel => 'Supprimer';

  @override
  String get dragHandleReorderTooltip => 'Faites glisser la poignée pour réorganiser';

  @override
  String get holdAndDragReorderTooltip => 'Maintenez et faites glisser pour réorganiser';

  @override
  String get emptyHomePageMessage => 'Bonjour !\n\nC\'est un peu vide ici.\n\nAppuyez sur le bouton + pour créer des notes personnelles. :)';

  @override
  String get reorderingTitle => 'Réorganisation';

  @override
  String get selectEllipsisLabel => 'Sélectionner...';

  @override
  String get dateTimeToggleLabel => 'Date/Heure';

  @override
  String get noteBorderToggleLabel => 'Bordure de note';

  @override
  String get deleteGroupButtonLabel => 'Supprimer';

  @override
  String get notesTabLabel => 'Notes';

  @override
  String get groupsTabLabel => 'Groupes';

  @override
  String get categoriesTabLabel => 'Catégories';

  @override
  String get locationItemLabel => 'Emplacement';

  @override
  String get addGroupTitle => 'Ajouter un groupe';

  @override
  String get editGroupTitle => 'Modifier le groupe';

  @override
  String get titleInputLabel => 'Titre';

  @override
  String get locationPermissionRequiredTitle => 'Autorisation de localisation requise';

  @override
  String get enableLocationPermissionsContent => 'Veuillez activer les autorisations de localisation dans les paramètres de l\'application.';

  @override
  String get cancelButtonLabel => 'Annuler';

  @override
  String get openSettingsButtonLabel => 'Ouvrir les paramètres';

  @override
  String get locationServicesTitle => 'Services de localisation';

  @override
  String get pleaseEnableLocationServicesContent => 'Veuillez les activer !';

  @override
  String get selectLocationTitle => 'Sélectionner un emplacement';

  @override
  String get useCurrentLocationTooltip => 'Utiliser l\'emplacement actuel';

  @override
  String get selectAllButtonLabel => 'Tout sélectionner';

  @override
  String get searchLogsHint => 'Rechercher dans les journaux...';

  @override
  String get noLogsAvailable => 'Aucun journal disponible';

  @override
  String get dbViewerTitle => 'Visionneuse de base de données';

  @override
  String get selectTableToViewData => 'Sélectionnez une table pour voir ses données';

  @override
  String get selectTableDropdownHint => 'Sélectionner une table';

  @override
  String get pickContactTitle => 'Choisir un contact';

  @override
  String get permissionRequiredText => 'Autorisation requise';

  @override
  String get grantPermissionButtonLabel => 'Accorder l\'autorisation';

  @override
  String get pageDummyTitle => 'Page factice';

  @override
  String get simulateButtonLabel => 'Simuler';

  @override
  String get selectCategoryTitle => 'Sélectionner une catégorie';

  @override
  String get addCategoryTitle => 'Ajouter une catégorie';

  @override
  String get editCategoryTitle => 'Modifier la catégorie';

  @override
  String get categoryTitleHint => 'Titre de la catégorie';

  @override
  String get colorLabel => 'Couleur';

  @override
  String get changeColorLabel => 'Changer la couleur';

  @override
  String get deviceDisabledMessage => 'Appareil désactivé !';

  @override
  String get cannotRemoveThisDeviceMessage => 'Impossible de supprimer cet appareil !';

  @override
  String get confirmRemoveTitle => 'Confirmer la suppression';

  @override
  String get confirmRemoveDeviceContent => 'Êtes-vous sûr ? Cela supprimera toutes les données sur cet appareil.';

  @override
  String get okButtonLabel => 'OK';

  @override
  String get registeredDevicesTitle => 'Appareils enregistrés';

  @override
  String get noDevicesFoundMessage => 'Aucun appareil trouvé';

  @override
  String get enabledLabel => 'Activé';

  @override
  String get disabledLabel => 'Désactivé';

  @override
  String get migratingMediaTitle => 'Migration des médias';

  @override
  String get processingMessage => 'Traitement en cours...';

  @override
  String get doNotNavigateAwayMessage => 'Veuillez ne pas quitter la page';

  @override
  String errorWithDetails(String error) {
    return 'Erreur : $error';
  }

  @override
  String get sequenceNotAcceptedError => 'Séquence non acceptée';

  @override
  String get examplesNotAcceptedError => 'Exemples non acceptés';

  @override
  String get enterKeyAgainLabel => 'Saisir à nouveau la clé';

  @override
  String get pleaseEnterKeyAgainError => 'Veuillez saisir à nouveau la clé';

  @override
  String get keysDoNotMatchError => 'Les clés ne correspondent pas';

  @override
  String get ruleUppercaseLetter => '1 lettre majuscule';

  @override
  String get ruleLowercaseLetter => '1 lettre minuscule';

  @override
  String get ruleNumericLetter => '1 chiffre';

  @override
  String get ruleSpecialCharacter => '1 caractère spécial';

  @override
  String get ruleMinTenCharacters => 'min 10 caractères';

  @override
  String get examplesTitle => 'Exemples';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => 'Compris';

  @override
  String get encryptionKeyTitle => 'Clé de chiffrement';

  @override
  String get createKeyDescription => 'Veuillez saisir une clé (mot de passe) longue et difficile à deviner. N\'oubliez pas de la conserver dans un endroit sûr. Si elle est perdue ou oubliée, elle ne peut pas être récupérée.';

  @override
  String get seeExamplesTooltip => 'Voir des exemples';

  @override
  String get couldNotFetchDetailsMessage => 'Impossible de récupérer les détails';

  @override
  String get retryButtonLabel => 'Réessayer';

  @override
  String get signedInAsLabel => 'Connecté en tant que :';

  @override
  String get storageUsageLabel => 'Utilisation du stockage';

  @override
  String get subscribeLabel => 'S\'abonner';

  @override
  String get planExpiredRenewLabel => 'Plan expiré ! Renouveler';

  @override
  String get manageDevicesLabel => 'Gérer les appareils';

  @override
  String get viewAccessKeyLabel => 'Voir la clé d\'accès';

  @override
  String get changeKeyPasswordLabel => 'Changer le mot de passe de la clé';

  @override
  String get manageSubscriptionLabel => 'Gérer l\'abonnement';

  @override
  String get signOutButtonLabel => 'Déconnexion';

  @override
  String get yearlyPlansTitle => 'Plans annuels';

  @override
  String get loginLabel => 'Connexion';

  @override
  String get syncAllYourNotesLabel => 'Synchronisez toutes vos notes';

  @override
  String get acrossYourDevicesLabel => 'sur tous vos appareils';

  @override
  String get featureEndToEndEncryption => 'Chiffrement de bout en bout';

  @override
  String get featureSyncUpTo3Devices => 'Synchronisation jusqu\'à 3 appareils';

  @override
  String get featureUpgradeCancelAnytime => 'Mise à niveau/Annulation à tout moment';

  @override
  String get noPlansAvailableMessage => 'Aucun plan disponible';

  @override
  String get downloadAppSubscribeLabel => 'Téléchargez l\'application et abonnez-vous';

  @override
  String get privacyTermsLabel => 'Confidentialité • Conditions';

  @override
  String get saveFiftyPercentLabel => 'Économisez 50 %';

  @override
  String get helloTitle => 'Bonjour';

  @override
  String get selectKeyMasterKeyDescription => 'Pour chiffrer vos données, nous aurons besoin d\'une clé de chiffrement principale.';

  @override
  String get selectKeyTwoOptionsDescription => 'Il y a 2 options : soit vous créez vous-même une clé (similaire à un mot de passe), soit nous la créons pour vous.';

  @override
  String get understandLoseKeyAcknowledgement => 'Je comprends que si je perds/oublie ma clé de chiffrement, je risque de perdre mes données.';

  @override
  String get createKeyForMeButtonLabel => 'Créer la clé pour moi';

  @override
  String get recommendedLabel => '(Recommandé)';

  @override
  String get pleaseAcknowledgeMessage => 'Veuillez accepter les conditions !';

  @override
  String get createKeyMyselfButtonLabel => 'Je vais créer la clé moi-même';

  @override
  String welcomeToAppName(String appName) {
    return 'Bienvenue sur $appName';
  }

  @override
  String get e2eEncryptionDescription => 'Nous utilisons un chiffrement de bout en bout pour garantir que toutes vos notes sont en sécurité et que personne d\'autre ne peut les voir, pas même nous.';

  @override
  String get timeToStartEncryptionLabel => 'Il est temps de commencer le chiffrement !';

  @override
  String get nextButtonLabel => 'Suivant';

  @override
  String get sendingOtpFailedMessage => 'Échec de l\'envoi du code OTP. Veuillez réessayer !';

  @override
  String get otpVerificationFailedMessage => 'Échec de la vérification du code OTP. Veuillez réessayer !';

  @override
  String get emailSignInTitle => 'Connexion par e-mail';

  @override
  String get verifyOtpLabel => 'Vérifier l\'OTP';

  @override
  String get enterEmailLabel => 'Saisir l\'e-mail';

  @override
  String get sendOtpLabel => 'Envoyer l\'OTP';

  @override
  String otpSentToEmailMessage(String email) {
    return 'Nous avons envoyé un mot de passe à usage unique (OTP) à votre adresse e-mail $email';
  }

  @override
  String get enterOtpLabel => 'Saisir l\'OTP';

  @override
  String get changeEmailLabel => 'Changer l\'e-mail';

  @override
  String get encryptingNotesTitle => 'Chiffrement des notes';

  @override
  String get fetchingDetailsTitle => 'Récupération des détails';

  @override
  String get couldNotFetchMessage => 'Récupération impossible';

  @override
  String get subscriptionEmailMismatchMessage => 'Votre abonnement est associé à une autre adresse e-mail. Veuillez vous déconnecter et utiliser celle-ci pour activer le stockage cloud.';

  @override
  String get errorCheckingPlanDetailsMessage => 'Erreur lors de la vérification des détails du plan';

  @override
  String get registerDeviceTitle => 'Enregistrer l\'appareil';

  @override
  String get manageButtonLabel => 'Gérer';

  @override
  String get fetchingKeysTitle => 'Récupération des clés';

  @override
  String get signingOutTitle => 'Déconnexion en cours';

  @override
  String get pleaseCheckInternetMessage => 'Veuillez vérifier votre connexion Internet';

  @override
  String get somethingWentWrongMessage => 'Une erreur est survenue';

  @override
  String get playPauseTooltip => 'Lecture/Pause';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => 'Télécharger';

  @override
  String get invalidAccessKey => 'Clé d\'accès invalide';

  @override
  String get fileDoesNotContain24Words => 'Le fichier ne contient pas exactement 24 mots.';

  @override
  String get errorReadingFile => 'Erreur lors de la lecture du fichier';

  @override
  String get allLabel => 'Tout';

  @override
  String get logTypeDebug => 'DÉBOGAGE';

  @override
  String get logTypeError => 'ERREUR';

  @override
  String get logTypeInfo => 'INFO';

  @override
  String get logTypeWarning => 'AVERTISSEMENT';

  @override
  String get groupTitleHint => 'Titre du groupe';

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get selectCategoryPlaceholder => 'Sélectionner une catégorie';

  @override
  String storageBytesFormat(String bytes) {
    return '$bytes o';
  }

  @override
  String storageKilobytesFormat(String kb) {
    return '$kb Ko';
  }

  @override
  String storageMegabytesFormat(String mb) {
    return '$mb Mo';
  }

  @override
  String storageGigabytesFormat(String gb) {
    return '$gb Go';
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
  String get searchHint => 'requête, #document etc..';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => 'Fichier audio';

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
  String get selectLanguageTitle => 'Sélectionner la langue';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get themeLabel => 'Thème';

  @override
  String get dayNightThemeTooltip => 'Thème jour/nuit';

  @override
  String get lockLabel => 'Verrouiller';

  @override
  String get timeFormatLabel => 'Format de l\'heure';

  @override
  String get h12Label => 'H12';

  @override
  String get h24Label => 'H24';

  @override
  String get fontSizeLabel => 'Taille de la police';

  @override
  String get reduceTextSizeTooltip => 'Réduire la taille du texte';

  @override
  String get increaseTextSizeTooltip => 'Augmenter la taille du texte';

  @override
  String get languageLabel => 'Langue';

  @override
  String get autoOpenGroupLabel => 'Ouvrir automatiquement le groupe';

  @override
  String get selectGroupTitle => 'Sélectionner un groupe';

  @override
  String shareAppMessage(String appName, String appLink) {
    return 'Essayez $appName : $appLink';
  }

  @override
  String get noteTypeEmpty => 'Vide';

  @override
  String get noteTypeImage => 'Image';

  @override
  String get noteTypeVideo => 'Vidéo';

  @override
  String get noteTypeAudio => 'Audio';

  @override
  String get noteTypeDocument => 'Document';

  @override
  String get noteTypeContact => 'Contact';

  @override
  String get noteTypeLocation => 'Emplacement';

  @override
  String get noteTypeUnknown => 'Inconnu';

  @override
  String get pleaseEnterData => 'Veuillez saisir des données';

  @override
  String get aNumber => 'Un nombre';

  @override
  String get enterDataLabel => 'Saisir des données';

  @override
  String get pleaseEnterValidData => 'Veuillez saisir des données valides';

  @override
  String get pleaseSelectAnOption => 'Veuillez sélectionner une option';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => 'Aujourd\'hui';

  @override
  String get yesterdayLabel => 'Hier';

  @override
  String get mondayLabel => 'Lundi';

  @override
  String get tuesdayLabel => 'Mardi';

  @override
  String get wednesdayLabel => 'Mercredi';

  @override
  String get thursdayLabel => 'Jeudi';

  @override
  String get fridayLabel => 'Vendredi';

  @override
  String get saturdayLabel => 'Samedi';

  @override
  String get sundayLabel => 'Dimanche';

  @override
  String get januaryShortLabel => 'Jan';

  @override
  String get februaryShortLabel => 'Fév';

  @override
  String get marchShortLabel => 'Mar';

  @override
  String get aprilShortLabel => 'Avr';

  @override
  String get mayShortLabel => 'Mai';

  @override
  String get juneShortLabel => 'Juin';

  @override
  String get julyShortLabel => 'Juil';

  @override
  String get augustShortLabel => 'Août';

  @override
  String get septemberShortLabel => 'Sep';

  @override
  String get octoberShortLabel => 'Oct';

  @override
  String get novemberShortLabel => 'Nov';

  @override
  String get decemberShortLabel => 'Déc';

  @override
  String noteGroupDateTitleFormat(String month, String day, String dayOfWeek) {
    return '$dayOfWeek $day $month';
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
  String get fileSizeZero => '0 o';

  @override
  String get fileSizeUnitBytes => 'o';

  @override
  String get fileSizeUnitKilobytes => 'Ko';

  @override
  String get fileSizeUnitMegabytes => 'Mo';

  @override
  String get fileSizeUnitGigabytes => 'Go';

  @override
  String get fileSizeUnitTerabytes => 'To';

  @override
  String fileSizeFormat(String size, String suffix) {
    return '$size $suffix';
  }

  @override
  String noteGroupCountSingle(int count) {
    return '$count groupe de notes';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count groupes de notes';
  }

  @override
  String get seedCategoryTasks => 'Tâches';

  @override
  String get seedGroupNotes => 'Notes';

  @override
  String get seedGroupFitness => 'Forme physique';

  @override
  String get seedItemWelcome => 'Bienvenue dans Note Safe !\nIdées, listes ou tout ce qui vous passe par la tête, notez tout ici.\n\nAppuyez longuement sur cette note pour accéder aux options de suppression, de modification et autres.';

  @override
  String get seedItemMorningWorkout => 'Entraînement du matin';

  @override
  String get seedItemMeditation => '10 minutes de méditation';

  @override
  String get seedItemWater => '2L d\'eau par jour';

  @override
  String get seedItemSteps => 'Marcher 10 000 pas';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get importantTitle => 'Önemli';

  @override
  String get accessKeyNoticeDescription1 => 'Bir sonraki sayfada 24 kelimeden oluşan bir dizi göreceksiniz. Bu sizin benzersiz ve özel şifreleme anahtarınızdır ve oturum kapatma, cihaz kaybı veya arıza durumunda notlarınızı kurtarmanın TEK yoludur.';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return 'Anahtarı biz saklamıyoruz. Onu $appName uygulaması dışında güvenli bir yerde saklamak SİZİN sorumluluğunuzdadır.';
  }

  @override
  String get iUnderstandShowMeTheKey => 'Anlıyorum.\nAnahtarı göster.';

  @override
  String get selectGroupToViewNotes => 'Notları görüntülemek için bir grup seçin';

  @override
  String get accessKeyShareText => 'Erişim anahtarınız burada.';

  @override
  String get pleaseTryAgain => 'Lütfen tekrar deneyin.';

  @override
  String get copiedToClipboard => 'Panoya kopyalandı';

  @override
  String get accessKeyTitle => 'Erişim Anahtarı';

  @override
  String get accessKeyDescription => 'Lütfen bu anahtarı güvenli bir yerde saklayın. Notları başka bir cihazda senkronize etmek için buna ihtiyacınız olacak.';

  @override
  String get copyLabel => 'Kopyala';

  @override
  String get downloadAsTextFileLabel => 'Metin Dosyası Olarak İndir';

  @override
  String get continueLabel => 'Devam et';

  @override
  String get pleaseAuthenticate => 'Lütfen kimlik doğrulaması yapın';

  @override
  String get couldNotCreate => 'Oluşturulamadı';

  @override
  String get couldNotShareFile => 'Dosya paylaşılamadı';

  @override
  String get hereIsTheBackupFile => 'Uygulamanızın yedek dosyası burada.';

  @override
  String get errorTitle => 'Hata';

  @override
  String get backupLabel => 'Yedekle';

  @override
  String get restoreLabel => 'Geri yükle';

  @override
  String get leaveAReviewLabel => 'Değerlendirme bırak';

  @override
  String get shareLabel => 'Paylaş';

  @override
  String get desktopAppLinkLabel => 'Masaüstü Uygulaması';

  @override
  String get loggingLabel => 'Günlük Kaydı';

  @override
  String versionLabel(String version) {
    return 'Sürüm: $version';
  }

  @override
  String get loadingLabel => 'Yükleniyor...';

  @override
  String get restoredLabel => 'Geri yüklendi.';

  @override
  String get deletedPermanentlyLabel => 'Kalıcı olarak silindi.';

  @override
  String get mediaTitle => 'Medya';

  @override
  String get invalidWordList => 'Geçersiz kelime listesi';

  @override
  String get enterYour24WordPhrase => '24 kelimelik ifadenizi girin';

  @override
  String get enterYourRecoveryPhraseHere => 'Kurtarma ifadenizi buraya girin';

  @override
  String get pleaseEnterYourRecoveryPhrase => 'Lütfen kurtarma ifadenizi girin';

  @override
  String get recoveryPhraseMustContain24Words => 'Kurtarma ifadesi tam olarak 24 kelime içermelidir';

  @override
  String get submitLabel => 'Gönder';

  @override
  String get orLabel => 'Veya';

  @override
  String get selectTxtFileLabel => '.txt Dosyası Seç';

  @override
  String get failureTitle => 'Hata';

  @override
  String get invalidPasswordKey => 'Geçersiz parola anahtarı';

  @override
  String get enableSyncTitle => 'Senkronizasyonu Etkinleştir';

  @override
  String get passwordRequirementsDescription => 'Lütfen oluşturduğunuz anahtarı (parolayı) girin. En az 10 karakter uzunluğunda; en az 1 rakam, 1 küçük harf, 1 büyük harf ve 1 özel karakter içermelidir.';

  @override
  String get enterKeyLabel => 'Anahtarı girin';

  @override
  String get pleaseEnterKey => 'Lütfen anahtarı girin';

  @override
  String get filterNotesTitle => 'Notları filtrele';

  @override
  String get filterPinnedNotesTooltip => 'Sabitlenmiş notları filtrele';

  @override
  String get filterStarredNotesTooltip => 'Yıldızlı notları filtrele';

  @override
  String get filterTextNotesTooltip => 'Metin notlarını filtrele';

  @override
  String get filterTasksTooltip => 'Görevleri filtrele';

  @override
  String get filterLinksTooltip => 'Bağlantıları filtrele';

  @override
  String get filterImagesTooltip => 'Resimleri filtrele';

  @override
  String get filterAudioTooltip => 'Ses dosyalarını filtrele';

  @override
  String get filterVideoTooltip => 'Videoları filtrele';

  @override
  String get filterFilesTooltip => 'Dosyaları filtrele';

  @override
  String get filterContactsTooltip => 'Kişileri filtrele';

  @override
  String get filterLocationTooltip => 'Konumları filtrele';

  @override
  String get movedToTrash => 'Çöp kutusuna taşındı';

  @override
  String get copiedNotesToClipboard => 'Panoya kopyalandı';

  @override
  String get locationShareLabel => 'Konum:';

  @override
  String get contactShareLabel => 'Kişi:';

  @override
  String get emailsShareLabel => 'E-postalar:';

  @override
  String get addressesShareLabel => 'Adresler:';

  @override
  String get microphoneNotAvailable => 'Mikrofon kullanılamıyor olabilir.';

  @override
  String get microphonePermissionRequired => 'Ses kaydı yapmak için mikrofon izni gereklidir.';

  @override
  String get couldNotGetDuration => 'Süre alınamadı';

  @override
  String get errorOpeningFiles => 'Dosya açma hatası';

  @override
  String get pleaseWaitTitle => 'Lütfen bekleyin';

  @override
  String get fileNotAvailableYet => 'Dosya henüz mevcut değil';

  @override
  String get clearSelectionTooltip => 'Seçimi temizle';

  @override
  String get copyNotesTooltip => 'Notları kopyala';

  @override
  String get changeTaskTypeTooltip => 'Görev türünü değiştir';

  @override
  String get shareNotesTooltip => 'Notları paylaş';

  @override
  String get noNotesSelectedToShare => 'Paylaşılacak not seçilmedi';

  @override
  String get nothingToShare => 'Paylaşılacak bir şey yok';

  @override
  String get shareFailed => 'Paylaşım başarısız';

  @override
  String get editNoteTooltip => 'Notu düzenle';

  @override
  String get starUnstarNotesTooltip => 'Notları yıldızla/yıldızı kaldır';

  @override
  String get moveToTrashTooltip => 'Çöp kutusuna taşı';

  @override
  String get pinUnpinNotesTooltip => 'Notları sabitle/sabitlemeyi kaldır';

  @override
  String get cancelReplyTooltip => 'Yanıtı iptal et';

  @override
  String get createTaskHint => 'Bir görev oluştur';

  @override
  String get addNoteHint => 'Not ekle...';

  @override
  String get attachTooltip => 'Ekle';

  @override
  String get addNoteTooltip => 'Not ekle';

  @override
  String get recordStopAudioTooltip => 'Ses kaydını başlat/durdur';

  @override
  String get contactAttachmentLabel => 'Kişi';

  @override
  String get locationAttachmentLabel => 'Konum';

  @override
  String get cameraAttachmentLabel => 'Kamera';

  @override
  String get filesAttachmentLabel => 'Dosyalar';

  @override
  String get checklistAttachmentLabel => 'Kontrol Listesi';

  @override
  String get accessKeyInputTitle => 'Senkronizasyonu Etkinleştir';

  @override
  String get accessKeyInputDescription => 'Lütfen 24 kelimelik kurtarma ifadenizi girin veya onu içeren bir .txt dosyası yükleyin.';

  @override
  String get editMenuItemLabel => 'Düzenle';

  @override
  String get filterMenuItemLabel => 'Filtreler';

  @override
  String get externalStoragePermissionDenied => 'Harici depolama erişim izni reddedildi.';

  @override
  String get pressLongToStartRecording => 'Kaydı başlatmak için uzun basın.';

  @override
  String get didYouKnowTitle => 'Biliyor muydunuz?';

  @override
  String get closeTooltip => 'Kapat';

  @override
  String appDescriptionContent(String appName) {
    return '$appName, tamamen özel bir not uygulamasıdır. Kişisel verilerinizi toplamaz veya size reklam göstermez.\n\nKullanmaktan keyif alacağınızı umuyoruz. Ne düşündüğünüzü bize bildirin.';
  }

  @override
  String get searchNotesTooltip => 'Notlarda ara';

  @override
  String get syncMenuItemLabel => 'Senkronizasyon';

  @override
  String get trashMenuItemLabel => 'Çöp Kutusu';

  @override
  String get starredNotesMenuItemLabel => 'Yıldızlı notlar';

  @override
  String get settingsMenuItemLabel => 'Ayarlar';

  @override
  String get accountMenuItemLabel => 'Hesap';

  @override
  String get pageMenuItemLabel => 'Sayfa';

  @override
  String get sqliteMenuItemLabel => 'Sqlite';

  @override
  String get logsMenuItemLabel => 'Günlükler';

  @override
  String get reorderMenuItemLabel => 'Yeniden sırala';

  @override
  String get editGroupMenuItemLabel => 'Düzenle';

  @override
  String get deleteGroupMenuItemLabel => 'Sil';

  @override
  String get dragHandleReorderTooltip => 'Yeniden sıralamak için sürükleyin';

  @override
  String get holdAndDragReorderTooltip => 'Yeniden sıralamak için basılı tutun ve sürükleyin';

  @override
  String get emptyHomePageMessage => 'Merhaba!\n\nBurası biraz boş görünüyor.\n\n+ düğmesine dokunun ve kendiniz için notlar oluşturun. :)';

  @override
  String get reorderingTitle => 'Yeniden Sıralanıyor';

  @override
  String get selectEllipsisLabel => 'Seç...';

  @override
  String get dateTimeToggleLabel => 'Tarih/Saat';

  @override
  String get noteBorderToggleLabel => 'Not kenarlığı';

  @override
  String get deleteGroupButtonLabel => 'Sil';

  @override
  String get notesTabLabel => 'Notlar';

  @override
  String get groupsTabLabel => 'Gruplar';

  @override
  String get categoriesTabLabel => 'Kategoriler';

  @override
  String get locationItemLabel => 'Konum';

  @override
  String get addGroupTitle => 'Grup ekle';

  @override
  String get editGroupTitle => 'Grubu düzenle';

  @override
  String get titleInputLabel => 'Başlık';

  @override
  String get locationPermissionRequiredTitle => 'Konum İzni Gerekiyor';

  @override
  String get enableLocationPermissionsContent => 'Lütfen uygulama ayarlarından konum izinlerini etkinleştirin.';

  @override
  String get cancelButtonLabel => 'İptal';

  @override
  String get openSettingsButtonLabel => 'Ayarları Aç';

  @override
  String get locationServicesTitle => 'Konum Hizmetleri';

  @override
  String get pleaseEnableLocationServicesContent => 'Lütfen etkinleştirin!';

  @override
  String get selectLocationTitle => 'Konum seç';

  @override
  String get useCurrentLocationTooltip => 'Mevcut konumu kullan';

  @override
  String get selectAllButtonLabel => 'Tümünü seç';

  @override
  String get searchLogsHint => 'Günlüklerde ara..';

  @override
  String get noLogsAvailable => 'Günlük kaydı yok';

  @override
  String get dbViewerTitle => 'Veritabanı Görüntüleyici';

  @override
  String get selectTableToViewData => 'Verilerini görüntülemek için bir tablo seçin';

  @override
  String get selectTableDropdownHint => 'Bir tablo seçin';

  @override
  String get pickContactTitle => 'Bir kişi seçin';

  @override
  String get permissionRequiredText => 'İzin gerekli';

  @override
  String get grantPermissionButtonLabel => 'İzin ver';

  @override
  String get pageDummyTitle => 'Sayfa Örneği';

  @override
  String get simulateButtonLabel => 'Simüle et';

  @override
  String get selectCategoryTitle => 'Kategori seç';

  @override
  String get addCategoryTitle => 'Kategori ekle';

  @override
  String get editCategoryTitle => 'Kategoriyi düzenle';

  @override
  String get categoryTitleHint => 'Kategori başlığı';

  @override
  String get colorLabel => 'Renk';

  @override
  String get changeColorLabel => 'Rengi değiştir';

  @override
  String get deviceDisabledMessage => 'Cihaz devre dışı bırakıldı!';

  @override
  String get cannotRemoveThisDeviceMessage => 'Bu cihaz kaldırılamaz!';

  @override
  String get confirmRemoveTitle => 'Kaldırmayı Onayla';

  @override
  String get confirmRemoveDeviceContent => 'Emin misiniz? Bu, cihazdaki tüm verileri silecektir.';

  @override
  String get okButtonLabel => 'TAMAM';

  @override
  String get registeredDevicesTitle => 'Kayıtlı Cihazlar';

  @override
  String get noDevicesFoundMessage => 'Cihaz bulunamadı';

  @override
  String get enabledLabel => 'Etkin';

  @override
  String get disabledLabel => 'Devre dışı';

  @override
  String get migratingMediaTitle => 'Medya Taşınıyor';

  @override
  String get processingMessage => 'İşleniyor...';

  @override
  String get doNotNavigateAwayMessage => 'Lütfen başka bir sayfaya geçmeyin';

  @override
  String errorWithDetails(String error) {
    return 'Hata: $error';
  }

  @override
  String get sequenceNotAcceptedError => 'Sıralı dizi kabul edilmedi';

  @override
  String get examplesNotAcceptedError => 'Örnekler kabul edilmedi';

  @override
  String get enterKeyAgainLabel => 'Anahtarı tekrar girin';

  @override
  String get pleaseEnterKeyAgainError => 'Lütfen anahtarı tekrar girin';

  @override
  String get keysDoNotMatchError => 'Anahtarlar eşleşmiyor';

  @override
  String get ruleUppercaseLetter => '1 büyük harf';

  @override
  String get ruleLowercaseLetter => '1 küçük harf';

  @override
  String get ruleNumericLetter => '1 rakam';

  @override
  String get ruleSpecialCharacter => '1 özel karakter';

  @override
  String get ruleMinTenCharacters => 'en az 10 karakter';

  @override
  String get examplesTitle => 'Örnekler';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => 'Anlaşıldı';

  @override
  String get encryptionKeyTitle => 'Şifreleme anahtarı';

  @override
  String get createKeyDescription => 'Lütfen uzun ve tahmin edilmesi zor bir anahtar (parola) girin. Güvenli bir yerde saklamayı unutmayın. Kaybedilirse veya unutulursa kurtarılamaz.';

  @override
  String get seeExamplesTooltip => 'Örnekleri gör';

  @override
  String get couldNotFetchDetailsMessage => 'Ayrıntılar alınamadı';

  @override
  String get retryButtonLabel => 'Tekrar dene';

  @override
  String get signedInAsLabel => 'Oturum açıldı:';

  @override
  String get storageUsageLabel => 'Depolama Kullanımı';

  @override
  String get subscribeLabel => 'Abone ol';

  @override
  String get planExpiredRenewLabel => 'Planın süresi doldu! Yenile';

  @override
  String get manageDevicesLabel => 'Cihazları yönet';

  @override
  String get viewAccessKeyLabel => 'Erişim anahtarını görüntüle';

  @override
  String get changeKeyPasswordLabel => 'Anahtar parolasını değiştir';

  @override
  String get manageSubscriptionLabel => 'Aboneliği yönet';

  @override
  String get signOutButtonLabel => 'Oturumu Kapat';

  @override
  String get yearlyPlansTitle => 'Yıllık planlar';

  @override
  String get loginLabel => 'Giriş yap';

  @override
  String get syncAllYourNotesLabel => 'Tüm notlarınızı senkronize edin';

  @override
  String get acrossYourDevicesLabel => 'cihazlarınız arasında';

  @override
  String get featureEndToEndEncryption => 'Uçtan uca şifreleme';

  @override
  String get featureSyncUpTo3Devices => '3 cihaza kadar senkronizasyon';

  @override
  String get featureUpgradeCancelAnytime => 'İstediğiniz zaman yükseltin/iptal edin';

  @override
  String get noPlansAvailableMessage => 'Plan mevcut değil';

  @override
  String get downloadAppSubscribeLabel => 'Uygulamayı indirin ve abone olun';

  @override
  String get privacyTermsLabel => 'Gizlilik • Şartlar';

  @override
  String get saveFiftyPercentLabel => '%50 Tasarruf Edin';

  @override
  String get helloTitle => 'Merhaba';

  @override
  String get selectKeyMasterKeyDescription => 'Verilerinizi şifrelemek için bir ana şifreleme anahtarına ihtiyacımız olacak.';

  @override
  String get selectKeyTwoOptionsDescription => '2 seçenek var; ya anahtarı kendiniz oluşturursunuz (parola gibi) ya da biz sizin için oluştururuz.';

  @override
  String get understandLoseKeyAcknowledgement => 'Şifreleme anahtarını kaybedersem/unutursam verilerimi kaybedebileceğimi anlıyorum.';

  @override
  String get createKeyForMeButtonLabel => 'Anahtarı benim için oluştur';

  @override
  String get recommendedLabel => '(Önerilen)';

  @override
  String get pleaseAcknowledgeMessage => 'Lütfen kabul edin!';

  @override
  String get createKeyMyselfButtonLabel => 'Anahtarı kendim oluşturacağım';

  @override
  String welcomeToAppName(String appName) {
    return '$appName uygulamasına hoş geldiniz';
  }

  @override
  String get e2eEncryptionDescription => 'Tüm notlarınızın güvende olduğundan ve biz dahil hiç kimsenin onları göremediğinden emin olmak için uçtan uca şifreleme kullanıyoruz.';

  @override
  String get timeToStartEncryptionLabel => 'Şifrelemeyi başlatma zamanı!';

  @override
  String get nextButtonLabel => 'İleri';

  @override
  String get sendingOtpFailedMessage => 'OTP gönderilemedi. Lütfen tekrar deneyin!';

  @override
  String get otpVerificationFailedMessage => 'OTP doğrulanamadı. Lütfen tekrar deneyin!';

  @override
  String get emailSignInTitle => 'E-posta ile Giriş';

  @override
  String get verifyOtpLabel => 'OTP Doğrula';

  @override
  String get enterEmailLabel => 'E-posta girin';

  @override
  String get sendOtpLabel => 'OTP Gönder';

  @override
  String otpSentToEmailMessage(String email) {
    return 'E-posta adresinize tek kullanımlık bir şifre (OTP) gönderdik: $email';
  }

  @override
  String get enterOtpLabel => 'OTP girin';

  @override
  String get changeEmailLabel => 'E-postayı değiştir';

  @override
  String get encryptingNotesTitle => 'Notlar şifreleniyor';

  @override
  String get fetchingDetailsTitle => 'Ayrıntılar alınıyor';

  @override
  String get couldNotFetchMessage => 'Alınamadı';

  @override
  String get subscriptionEmailMismatchMessage => 'Aboneliğiniz başka bir e-posta ile ilişkilendirilmiş. Lütfen oturumu kapatın ve bulut depolamayı etkinleştirmek için o e-postayı kullanın.';

  @override
  String get errorCheckingPlanDetailsMessage => 'Plan ayrıntıları kontrol edilirken hata oluştu';

  @override
  String get registerDeviceTitle => 'Cihazı kaydet';

  @override
  String get manageButtonLabel => 'Yönet';

  @override
  String get fetchingKeysTitle => 'Anahtarlar Alınıyor';

  @override
  String get signingOutTitle => 'Oturum kapatılıyor';

  @override
  String get pleaseCheckInternetMessage => 'Lütfen internet bağlantınızı kontrol edin';

  @override
  String get somethingWentWrongMessage => 'Bir şeyler ters gitti';

  @override
  String get playPauseTooltip => 'Oynat/duraklat';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => 'İndir';

  @override
  String get invalidAccessKey => 'Geçersiz erişim anahtarı';

  @override
  String get fileDoesNotContain24Words => 'Dosya tam olarak 24 kelime içermiyor.';

  @override
  String get errorReadingFile => 'Dosya okuma hatası';

  @override
  String get allLabel => 'Tümü';

  @override
  String get logTypeDebug => 'HATA AYIKLAMA';

  @override
  String get logTypeError => 'HATA';

  @override
  String get logTypeInfo => 'BİLGİ';

  @override
  String get logTypeWarning => 'UYARI';

  @override
  String get groupTitleHint => 'Grup başlığı';

  @override
  String get categoryLabel => 'Kategori';

  @override
  String get selectCategoryPlaceholder => 'Kategori seç';

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
  String get searchHint => 'sorgu, #belge vb..';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => 'Ses dosyası';

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
  String get selectLanguageTitle => 'Dil seç';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get themeLabel => 'Tema';

  @override
  String get dayNightThemeTooltip => 'Gündüz/gece teması';

  @override
  String get lockLabel => 'Kilitle';

  @override
  String get timeFormatLabel => 'Saat Formatı';

  @override
  String get h12Label => '12S';

  @override
  String get h24Label => '24S';

  @override
  String get fontSizeLabel => 'Yazı boyutu';

  @override
  String get reduceTextSizeTooltip => 'Yazıyı küçült';

  @override
  String get increaseTextSizeTooltip => 'Yazıyı büyüt';

  @override
  String get languageLabel => 'Dil';

  @override
  String get autoOpenGroupLabel => 'Grubu otomatik aç';

  @override
  String get selectGroupTitle => 'Grup seç';

  @override
  String shareAppMessage(String appName, String appLink) {
    return 'Bir $appName oluşturun: $appLink';
  }

  @override
  String get noteTypeEmpty => 'Boş';

  @override
  String get noteTypeImage => 'Resim';

  @override
  String get noteTypeVideo => 'Video';

  @override
  String get noteTypeAudio => 'Ses';

  @override
  String get noteTypeDocument => 'Belge';

  @override
  String get noteTypeContact => 'Kişi';

  @override
  String get noteTypeLocation => 'Konum';

  @override
  String get noteTypeUnknown => 'Bilinmiyor';

  @override
  String get pleaseEnterData => 'Lütfen veri girin';

  @override
  String get aNumber => 'Bir sayı';

  @override
  String get enterDataLabel => 'Veri girin';

  @override
  String get pleaseEnterValidData => 'Lütfen geçerli bir veri girin';

  @override
  String get pleaseSelectAnOption => 'Lütfen bir seçenek belirleyin';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => 'Bugün';

  @override
  String get yesterdayLabel => 'Dün';

  @override
  String get mondayLabel => 'Pazartesi';

  @override
  String get tuesdayLabel => 'Salı';

  @override
  String get wednesdayLabel => 'Çarşamba';

  @override
  String get thursdayLabel => 'Perşembe';

  @override
  String get fridayLabel => 'Cuma';

  @override
  String get saturdayLabel => 'Cumartesi';

  @override
  String get sundayLabel => 'Pazar';

  @override
  String get januaryShortLabel => 'Oca';

  @override
  String get februaryShortLabel => 'Şub';

  @override
  String get marchShortLabel => 'Mar';

  @override
  String get aprilShortLabel => 'Nis';

  @override
  String get mayShortLabel => 'May';

  @override
  String get juneShortLabel => 'Haz';

  @override
  String get julyShortLabel => 'Tem';

  @override
  String get augustShortLabel => 'Ağu';

  @override
  String get septemberShortLabel => 'Eyl';

  @override
  String get octoberShortLabel => 'Eki';

  @override
  String get novemberShortLabel => 'Kas';

  @override
  String get decemberShortLabel => 'Ara';

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
    return '$count not grubu';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count not grubu';
  }

  @override
  String get seedCategoryTasks => 'Görevler';

  @override
  String get seedGroupNotes => 'Notlar';

  @override
  String get seedGroupFitness => 'Fitness';

  @override
  String get seedItemWelcome => 'Note Safe\'e hoş geldiniz!\nFikirlerinizi, listelerinizi veya aklınızdaki her şeyi buraya kaydedebilirsiniz.\n\nSilme, düzenleme ve diğer seçenekler için bu notun üzerine basılı tutun.';

  @override
  String get seedItemMorningWorkout => 'Sabah antrenmanı';

  @override
  String get seedItemMeditation => '10 dakika meditasyon';

  @override
  String get seedItemWater => 'Günde 2 litre su';

  @override
  String get seedItemSteps => '10.000 adım at';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get importantTitle => 'Importante';

  @override
  String get accessKeyNoticeDescription1 => 'En la siguiente página verás una serie de 24 palabras. Esta es tu clave de cifrado única y privada, y es la ÚNICA forma de recuperar tus notas en caso de cerrar sesión, pérdida del dispositivo o fallo técnico.';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return 'No guardamos esta clave. Es TU responsabilidad almacenarla en un lugar seguro fuera de la aplicación $appName.';
  }

  @override
  String get iUnderstandShowMeTheKey => 'Entendido.\nMuéstrame la clave.';

  @override
  String get selectGroupToViewNotes => 'Selecciona un grupo para ver las notas';

  @override
  String get accessKeyShareText => 'Aquí tienes tu clave de acceso.';

  @override
  String get pleaseTryAgain => 'Por favor, inténtalo de nuevo.';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get accessKeyTitle => 'Clave de acceso';

  @override
  String get accessKeyDescription => 'Por favor, guarda esta clave en un lugar seguro. La necesitarás para sincronizar notas en otro dispositivo.';

  @override
  String get copyLabel => 'Copiar';

  @override
  String get downloadAsTextFileLabel => 'Descargar como archivo de texto';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get pleaseAuthenticate => 'Autentícate, por favor';

  @override
  String get couldNotCreate => 'No se pudo crear';

  @override
  String get couldNotShareFile => 'No se pudo compartir el archivo';

  @override
  String get hereIsTheBackupFile => 'Aquí tienes el archivo de copia de seguridad de tu aplicación.';

  @override
  String get errorTitle => 'Error';

  @override
  String get backupLabel => 'Copia de seguridad';

  @override
  String get restoreLabel => 'Restaurar';

  @override
  String get leaveAReviewLabel => 'Dejar una reseña';

  @override
  String get shareLabel => 'Compartir';

  @override
  String get desktopAppLinkLabel => 'Aplicación de escritorio';

  @override
  String get loggingLabel => 'Registro (Logging)';

  @override
  String versionLabel(String version) {
    return 'Versión: $version';
  }

  @override
  String get loadingLabel => 'Cargando...';

  @override
  String get restoredLabel => 'Restaurado.';

  @override
  String get deletedPermanentlyLabel => 'Eliminado permanentemente.';

  @override
  String get mediaTitle => 'Multimedia';

  @override
  String get invalidWordList => 'Lista de palabras no válida';

  @override
  String get enterYour24WordPhrase => 'Ingresa tu frase de 24 palabras';

  @override
  String get enterYourRecoveryPhraseHere => 'Ingresa aquí tu frase de recuperación';

  @override
  String get pleaseEnterYourRecoveryPhrase => 'Por favor, ingresa tu frase de recuperación';

  @override
  String get recoveryPhraseMustContain24Words => 'La frase de recuperación debe contener exactamente 24 palabras';

  @override
  String get submitLabel => 'Enviar';

  @override
  String get orLabel => 'O';

  @override
  String get selectTxtFileLabel => 'Seleccionar archivo .txt';

  @override
  String get failureTitle => 'Fallo';

  @override
  String get invalidPasswordKey => 'Clave de contraseña no válida';

  @override
  String get enableSyncTitle => 'Habilitar sincronización';

  @override
  String get passwordRequirementsDescription => 'Por favor, introduce la clave (contraseña) que creaste. Debe tener un mínimo de 10 caracteres, incluyendo al menos 1 número, 1 minúscula, 1 mayúscula y 1 carácter especial.';

  @override
  String get enterKeyLabel => 'Ingresa la clave';

  @override
  String get pleaseEnterKey => 'Por favor, ingresa la clave';

  @override
  String get filterNotesTitle => 'Filtrar notas';

  @override
  String get filterPinnedNotesTooltip => 'Filtrar notas fijadas';

  @override
  String get filterStarredNotesTooltip => 'Filtrar notas destacadas';

  @override
  String get filterTextNotesTooltip => 'Filtrar notas de texto';

  @override
  String get filterTasksTooltip => 'Filtrar tareas';

  @override
  String get filterLinksTooltip => 'Filtrar enlaces';

  @override
  String get filterImagesTooltip => 'Filtrar imágenes';

  @override
  String get filterAudioTooltip => 'Filtrar audio';

  @override
  String get filterVideoTooltip => 'Filtrar video';

  @override
  String get filterFilesTooltip => 'Filtrar archivos';

  @override
  String get filterContactsTooltip => 'Filtrar contactos';

  @override
  String get filterLocationTooltip => 'Filtrar ubicación';

  @override
  String get movedToTrash => 'Movido a la papelera';

  @override
  String get copiedNotesToClipboard => 'Copiado al portapapeles';

  @override
  String get locationShareLabel => 'Ubicación:';

  @override
  String get contactShareLabel => 'Contacto:';

  @override
  String get emailsShareLabel => 'Correos electrónicos:';

  @override
  String get addressesShareLabel => 'Direcciones:';

  @override
  String get microphoneNotAvailable => 'Es posible que el micrófono no esté disponible.';

  @override
  String get microphonePermissionRequired => 'Se requiere permiso de micrófono para grabar audio.';

  @override
  String get couldNotGetDuration => 'No se pudo obtener la duración';

  @override
  String get errorOpeningFiles => 'Error al abrir archivos';

  @override
  String get pleaseWaitTitle => 'Espera, por favor';

  @override
  String get fileNotAvailableYet => 'Archivo aún no disponible';

  @override
  String get clearSelectionTooltip => 'Limpiar selección';

  @override
  String get copyNotesTooltip => 'Copiar notas';

  @override
  String get changeTaskTypeTooltip => 'Cambiar tipo de tarea';

  @override
  String get shareNotesTooltip => 'Compartir notas';

  @override
  String get editNoteTooltip => 'Editar nota';

  @override
  String get starUnstarNotesTooltip => 'Destacar/quitar destacado';

  @override
  String get moveToTrashTooltip => 'Mover a la papelera';

  @override
  String get pinUnpinNotesTooltip => 'Fijar/desfijar notas';

  @override
  String get cancelReplyTooltip => 'Cancelar respuesta';

  @override
  String get createTaskHint => 'Crear una tarea';

  @override
  String get addNoteHint => 'Añadir una nota...';

  @override
  String get attachTooltip => 'Adjuntar';

  @override
  String get addNoteTooltip => 'Añadir nota';

  @override
  String get recordStopAudioTooltip => 'Grabar/detener audio';

  @override
  String get contactAttachmentLabel => 'Contacto';

  @override
  String get locationAttachmentLabel => 'Ubicación';

  @override
  String get cameraAttachmentLabel => 'Cámara';

  @override
  String get filesAttachmentLabel => 'Archivos';

  @override
  String get checklistAttachmentLabel => 'Lista de control';

  @override
  String get accessKeyInputTitle => 'Habilitar sincronización';

  @override
  String get accessKeyInputDescription => 'Por favor, ingresa tu frase de recuperación de 24 palabras o carga un archivo .txt que la contenga.';

  @override
  String get editMenuItemLabel => 'Editar';

  @override
  String get filterMenuItemLabel => 'Filtros';

  @override
  String get externalStoragePermissionDenied => 'Se denegó el permiso para acceder al almacenamiento externo.';

  @override
  String get pressLongToStartRecording => 'Mantén presionado para empezar a grabar.';

  @override
  String get didYouKnowTitle => '¿Sabías que...?';

  @override
  String get closeTooltip => 'Cerrar';

  @override
  String appDescriptionContent(String appName) {
    return '$appName es una aplicación de notas completamente privada. No recopila tus datos personales ni muestra anuncios.\n\nEsperamos que disfrutes usándola. Cuéntanos qué te parece.';
  }

  @override
  String get searchNotesTooltip => 'Buscar notas';

  @override
  String get syncMenuItemLabel => 'Sincronizar';

  @override
  String get trashMenuItemLabel => 'Papelera';

  @override
  String get starredNotesMenuItemLabel => 'Notas destacadas';

  @override
  String get settingsMenuItemLabel => 'Ajustes';

  @override
  String get accountMenuItemLabel => 'Cuenta';

  @override
  String get pageMenuItemLabel => 'Página';

  @override
  String get sqliteMenuItemLabel => 'SQLite';

  @override
  String get logsMenuItemLabel => 'Registros';

  @override
  String get reorderMenuItemLabel => 'Reordenar';

  @override
  String get editGroupMenuItemLabel => 'Editar';

  @override
  String get deleteGroupMenuItemLabel => 'Eliminar';

  @override
  String get dragHandleReorderTooltip => 'Arrastra el controlador para reordenar';

  @override
  String get holdAndDragReorderTooltip => 'Mantén presionado y arrastra para reordenar';

  @override
  String get emptyHomePageMessage => '¡Hola!\n\nEsto está un poco vacío por aquí.\n\nToca el botón + y crea algunas notas para ti mismo. :)';

  @override
  String get reorderingTitle => 'Reordenando';

  @override
  String get selectEllipsisLabel => 'Seleccionar...';

  @override
  String get dateTimeToggleLabel => 'Fecha/Hora';

  @override
  String get noteBorderToggleLabel => 'Borde de nota';

  @override
  String get deleteGroupButtonLabel => 'Eliminar';

  @override
  String get notesTabLabel => 'Notas';

  @override
  String get groupsTabLabel => 'Grupos';

  @override
  String get categoriesTabLabel => 'Categorías';

  @override
  String get locationItemLabel => 'Ubicación';

  @override
  String get addGroupTitle => 'Añadir grupo';

  @override
  String get editGroupTitle => 'Editar grupo';

  @override
  String get titleInputLabel => 'Título';

  @override
  String get locationPermissionRequiredTitle => 'Se requiere permiso de ubicación';

  @override
  String get enableLocationPermissionsContent => 'Por favor, habilita los permisos de ubicación en los ajustes de la aplicación.';

  @override
  String get cancelButtonLabel => 'Cancelar';

  @override
  String get openSettingsButtonLabel => 'Abrir ajustes';

  @override
  String get locationServicesTitle => 'Servicios de ubicación';

  @override
  String get pleaseEnableLocationServicesContent => '¡Por favor, habilítalos!';

  @override
  String get selectLocationTitle => 'Seleccionar ubicación';

  @override
  String get useCurrentLocationTooltip => 'Usar ubicación actual';

  @override
  String get selectAllButtonLabel => 'Seleccionar todo';

  @override
  String get searchLogsHint => 'Buscar en registros...';

  @override
  String get noLogsAvailable => 'No hay registros disponibles';

  @override
  String get dbViewerTitle => 'Visualizador de BD';

  @override
  String get selectTableToViewData => 'Selecciona una tabla para ver sus datos';

  @override
  String get selectTableDropdownHint => 'Seleccionar una tabla';

  @override
  String get pickContactTitle => 'Elegir un contacto';

  @override
  String get permissionRequiredText => 'Permiso requerido';

  @override
  String get grantPermissionButtonLabel => 'Conceder permiso';

  @override
  String get pageDummyTitle => 'Página de prueba';

  @override
  String get simulateButtonLabel => 'Simular';

  @override
  String get selectCategoryTitle => 'Seleccionar categoría';

  @override
  String get addCategoryTitle => 'Añadir categoría';

  @override
  String get editCategoryTitle => 'Editar categoría';

  @override
  String get categoryTitleHint => 'Título de la categoría';

  @override
  String get colorLabel => 'Color';

  @override
  String get changeColorLabel => 'Cambiar color';

  @override
  String get deviceDisabledMessage => '¡Dispositivo desactivado!';

  @override
  String get cannotRemoveThisDeviceMessage => '¡No se puede eliminar este dispositivo!';

  @override
  String get confirmRemoveTitle => 'Confirmar eliminación';

  @override
  String get confirmRemoveDeviceContent => '¿Estás seguro? Esto eliminará todos los datos en el dispositivo.';

  @override
  String get okButtonLabel => 'Aceptar';

  @override
  String get registeredDevicesTitle => 'Dispositivos registrados';

  @override
  String get noDevicesFoundMessage => 'No se encontraron dispositivos';

  @override
  String get enabledLabel => 'Activado';

  @override
  String get disabledLabel => 'Desactivado';

  @override
  String get migratingMediaTitle => 'Migrando archivos multimedia';

  @override
  String get processingMessage => 'Procesando...';

  @override
  String get doNotNavigateAwayMessage => 'Por favor, no salgas de esta pantalla';

  @override
  String errorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String get sequenceNotAcceptedError => 'Secuencia no aceptada';

  @override
  String get examplesNotAcceptedError => 'Ejemplos no aceptados';

  @override
  String get enterKeyAgainLabel => 'Ingresa la clave de nuevo';

  @override
  String get pleaseEnterKeyAgainError => 'Por favor, ingresa la clave de nuevo';

  @override
  String get keysDoNotMatchError => 'Las claves no coinciden';

  @override
  String get ruleUppercaseLetter => '1 letra mayúscula';

  @override
  String get ruleLowercaseLetter => '1 letra minúscula';

  @override
  String get ruleNumericLetter => '1 número';

  @override
  String get ruleSpecialCharacter => '1 carácter especial';

  @override
  String get ruleMinTenCharacters => 'mínimo 10 caracteres';

  @override
  String get examplesTitle => 'Ejemplos';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => 'Entendido';

  @override
  String get encryptionKeyTitle => 'Clave de cifrado';

  @override
  String get createKeyDescription => 'Por favor, introduce una clave (contraseña) larga y difícil de adivinar. Recuerda guardarla en un lugar seguro. Si se pierde o se olvida, no se podrá recuperar.';

  @override
  String get seeExamplesTooltip => 'Ver ejemplos';

  @override
  String get couldNotFetchDetailsMessage => 'No se pudieron obtener los detalles';

  @override
  String get retryButtonLabel => 'Reintentar';

  @override
  String get signedInAsLabel => 'Sesión iniciada como:';

  @override
  String get storageUsageLabel => 'Uso de almacenamiento';

  @override
  String get subscribeLabel => 'Suscribirse';

  @override
  String get planExpiredRenewLabel => '¡Plan caducado! Renovar';

  @override
  String get manageDevicesLabel => 'Gestionar dispositivos';

  @override
  String get viewAccessKeyLabel => 'Ver clave de acceso';

  @override
  String get changeKeyPasswordLabel => 'Cambiar clave de contraseña';

  @override
  String get manageSubscriptionLabel => 'Gestionar suscripción';

  @override
  String get signOutButtonLabel => 'Cerrar sesión';

  @override
  String get yearlyPlansTitle => 'Planes anuales';

  @override
  String get loginLabel => 'Iniciar sesión';

  @override
  String get syncAllYourNotesLabel => 'Sincroniza todas tus notas';

  @override
  String get acrossYourDevicesLabel => 'en todos tus dispositivos';

  @override
  String get featureEndToEndEncryption => 'Cifrado de extremo a extremo';

  @override
  String get featureSyncUpTo3Devices => 'Sincroniza hasta 3 dispositivos';

  @override
  String get featureUpgradeCancelAnytime => 'Mejora o cancela en cualquier momento';

  @override
  String get noPlansAvailableMessage => 'No hay planes disponibles';

  @override
  String get downloadAppSubscribeLabel => 'Descarga la aplicación y suscríbete';

  @override
  String get privacyTermsLabel => 'Privacidad • Términos';

  @override
  String get saveFiftyPercentLabel => 'Ahorra 50%';

  @override
  String get helloTitle => 'Hola';

  @override
  String get selectKeyMasterKeyDescription => 'Para cifrar tus datos, necesitaremos una clave de cifrado maestra.';

  @override
  String get selectKeyTwoOptionsDescription => 'Hay 2 opciones: puedes crear una clave tú mismo (similar a una contraseña) o nosotros podemos crearla por ti.';

  @override
  String get understandLoseKeyAcknowledgement => 'Entiendo que si pierdo u olvido la clave de cifrado, podría perder los datos.';

  @override
  String get createKeyForMeButtonLabel => 'Crear la clave por mí';

  @override
  String get recommendedLabel => '(Recomendado)';

  @override
  String get pleaseAcknowledgeMessage => '¡Por favor, confirma que estás de acuerdo!';

  @override
  String get createKeyMyselfButtonLabel => 'Crearé la clave yo mismo';

  @override
  String welcomeToAppName(String appName) {
    return 'Bienvenido a $appName';
  }

  @override
  String get e2eEncryptionDescription => 'Usamos cifrado de extremo a extremo para asegurarnos de que todas tus notas estén protegidas y nadie más pueda verlas, ni siquiera nosotros.';

  @override
  String get timeToStartEncryptionLabel => '¡Es hora de comenzar el cifrado!';

  @override
  String get nextButtonLabel => 'Siguiente';

  @override
  String get sendingOtpFailedMessage => 'Error al enviar la OTP. ¡Por favor, inténtalo de nuevo!';

  @override
  String get otpVerificationFailedMessage => 'Error en la verificación de la OTP. ¡Por favor, inténtalo de nuevo!';

  @override
  String get emailSignInTitle => 'Iniciar sesión con email';

  @override
  String get verifyOtpLabel => 'Verificar OTP';

  @override
  String get enterEmailLabel => 'Ingresa tu email';

  @override
  String get sendOtpLabel => 'Enviar OTP';

  @override
  String otpSentToEmailMessage(String email) {
    return 'Hemos enviado una contraseña de un solo uso (OTP) a tu email $email';
  }

  @override
  String get enterOtpLabel => 'Ingresa la OTP';

  @override
  String get changeEmailLabel => 'Cambiar email';

  @override
  String get encryptingNotesTitle => 'Cifrando notas';

  @override
  String get fetchingDetailsTitle => 'Obteniendo detalles';

  @override
  String get couldNotFetchMessage => 'No se pudo obtener';

  @override
  String get subscriptionEmailMismatchMessage => 'Tu suscripción está asociada con otro email. Por favor, cierra sesión y usa ese email para habilitar el almacenamiento en la nube.';

  @override
  String get errorCheckingPlanDetailsMessage => 'Error al verificar los detalles del plan';

  @override
  String get registerDeviceTitle => 'Registrar dispositivo';

  @override
  String get manageButtonLabel => 'Gestionar';

  @override
  String get fetchingKeysTitle => 'Obteniendo claves';

  @override
  String get signingOutTitle => 'Cerrando sesión';

  @override
  String get pleaseCheckInternetMessage => 'Por favor, comprueba tu conexión a internet';

  @override
  String get somethingWentWrongMessage => 'Algo salió mal';

  @override
  String get playPauseTooltip => 'Reproducir/pausar';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => 'Descargar';

  @override
  String get invalidAccessKey => 'Clave de acceso no válida';

  @override
  String get fileDoesNotContain24Words => 'El archivo no contiene exactamente 24 palabras.';

  @override
  String get errorReadingFile => 'Error al leer el archivo';

  @override
  String get allLabel => 'Todo';

  @override
  String get logTypeDebug => 'DEBUG';

  @override
  String get logTypeError => 'ERROR';

  @override
  String get logTypeInfo => 'INFO';

  @override
  String get logTypeWarning => 'ADVERTENCIA';

  @override
  String get groupTitleHint => 'Título del grupo';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get selectCategoryPlaceholder => 'Seleccionar categoría';

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
  String get searchHint => 'consulta, #documento, etc..';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => 'Archivo de audio';

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
  String get selectLanguageTitle => 'Seleccionar idioma';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get themeLabel => 'Tema';

  @override
  String get dayNightThemeTooltip => 'Tema día/noche';

  @override
  String get lockLabel => 'Bloqueo';

  @override
  String get timeFormatLabel => 'Formato de hora';

  @override
  String get h12Label => '12 h';

  @override
  String get h24Label => '24 h';

  @override
  String get fontSizeLabel => 'Tamaño de fuente';

  @override
  String get reduceTextSizeTooltip => 'Reducir tamaño de texto';

  @override
  String get increaseTextSizeTooltip => 'Aumentar tamaño de texto';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get autoOpenGroupLabel => 'Abrir grupo automáticamente';

  @override
  String get selectGroupTitle => 'Seleccionar grupo';

  @override
  String shareAppMessage(String appName, String appLink) {
    return 'Prueba $appName: $appLink';
  }

  @override
  String get noteTypeEmpty => 'Vacío';

  @override
  String get noteTypeImage => 'Imagen';

  @override
  String get noteTypeVideo => 'Video';

  @override
  String get noteTypeAudio => 'Audio';

  @override
  String get noteTypeDocument => 'Documento';

  @override
  String get noteTypeContact => 'Contacto';

  @override
  String get noteTypeLocation => 'Ubicación';

  @override
  String get noteTypeUnknown => 'Desconocido';

  @override
  String get pleaseEnterData => 'Por favor, ingresa datos';

  @override
  String get aNumber => 'Un número';

  @override
  String get enterDataLabel => 'Ingresar datos';

  @override
  String get pleaseEnterValidData => 'Por favor, ingresa datos válidos';

  @override
  String get pleaseSelectAnOption => 'Por favor, selecciona una opción';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => 'Hoy';

  @override
  String get yesterdayLabel => 'Ayer';

  @override
  String get mondayLabel => 'Lunes';

  @override
  String get tuesdayLabel => 'Martes';

  @override
  String get wednesdayLabel => 'Miércoles';

  @override
  String get thursdayLabel => 'Jueves';

  @override
  String get fridayLabel => 'Viernes';

  @override
  String get saturdayLabel => 'Sábado';

  @override
  String get sundayLabel => 'Domingo';

  @override
  String get januaryShortLabel => 'Ene';

  @override
  String get februaryShortLabel => 'Feb';

  @override
  String get marchShortLabel => 'Mar';

  @override
  String get aprilShortLabel => 'Abr';

  @override
  String get mayShortLabel => 'May';

  @override
  String get juneShortLabel => 'Jun';

  @override
  String get julyShortLabel => 'Jul';

  @override
  String get augustShortLabel => 'Ago';

  @override
  String get septemberShortLabel => 'Sep';

  @override
  String get octoberShortLabel => 'Oct';

  @override
  String get novemberShortLabel => 'Nov';

  @override
  String get decemberShortLabel => 'Dic';

  @override
  String noteGroupDateTitleFormat(String month, String day, String dayOfWeek) {
    return '$dayOfWeek, $day de $month';
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
    return '$count grupo de notas';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count grupos de notas';
  }
}

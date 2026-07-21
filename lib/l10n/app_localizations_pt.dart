// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get importantTitle => 'Importante';

  @override
  String get accessKeyNoticeDescription1 => 'Na próxima página, você verá uma série de 24 palavras. Esta é a sua chave de criptografia exclusiva e privada, e é a ÚNICA maneira de recuperar suas notas em caso de logout, perda ou mau funcionamento do dispositivo.';

  @override
  String accessKeyNoticeDescription2(String appName) {
    return 'Nós não armazenamos a chave. É SUA responsabilidade armazená-la em um local seguro fora do aplicativo $appName.';
  }

  @override
  String get iUnderstandShowMeTheKey => 'Eu entendo.\nMostrar a chave.';

  @override
  String get selectGroupToViewNotes => 'Selecione um grupo para visualizar notas';

  @override
  String get accessKeyShareText => 'Aqui está sua chave de acesso.';

  @override
  String get pleaseTryAgain => 'Por favor, tente novamente.';

  @override
  String get copiedToClipboard => 'Copiado para a área de transferência';

  @override
  String get accessKeyTitle => 'Chave de Acesso';

  @override
  String get accessKeyDescription => 'Por favor, salve esta chave em um local seguro. Você precisará dela para sincronizar notas em outro dispositivo.';

  @override
  String get copyLabel => 'Copiar';

  @override
  String get downloadAsTextFileLabel => 'Baixar como arquivo de texto';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get pleaseAuthenticate => 'Por favor, autentique-se';

  @override
  String get couldNotCreate => 'Não foi possível criar';

  @override
  String get couldNotShareFile => 'Não foi possível compartilhar o arquivo';

  @override
  String get hereIsTheBackupFile => 'Aqui está o arquivo de backup do seu aplicativo.';

  @override
  String get errorTitle => 'Erro';

  @override
  String get backupLabel => 'Backup';

  @override
  String get restoreLabel => 'Restaurar';

  @override
  String get leaveAReviewLabel => 'Deixar uma avaliação';

  @override
  String get shareLabel => 'Compartilhar';

  @override
  String get desktopAppLinkLabel => 'Aplicativo Desktop';

  @override
  String get loggingLabel => 'Logs';

  @override
  String versionLabel(String version) {
    return 'Versão: $version';
  }

  @override
  String get loadingLabel => 'Carregando...';

  @override
  String get restoredLabel => 'Restaurado.';

  @override
  String get deletedPermanentlyLabel => 'Excluído permanentemente.';

  @override
  String get mediaTitle => 'Mídia';

  @override
  String get invalidWordList => 'Lista de palavras inválida';

  @override
  String get enterYour24WordPhrase => 'Insira sua frase de 24 palavras';

  @override
  String get enterYourRecoveryPhraseHere => 'Insira sua frase de recuperação aqui';

  @override
  String get pleaseEnterYourRecoveryPhrase => 'Por favor, insira sua frase de recuperação';

  @override
  String get recoveryPhraseMustContain24Words => 'A frase de recuperação deve conter exatamente 24 palavras';

  @override
  String get submitLabel => 'Enviar';

  @override
  String get orLabel => 'Ou';

  @override
  String get selectTxtFileLabel => 'Selecionar arquivo .txt';

  @override
  String get failureTitle => 'Falha';

  @override
  String get invalidPasswordKey => 'Chave de senha inválida';

  @override
  String get enableSyncTitle => 'Ativar Sincronização';

  @override
  String get passwordRequirementsDescription => 'Por favor, insira a chave (senha) que você criou. Ela deve ter no mínimo 10 caracteres, incluindo 1 número, 1 letra minúscula, 1 letra maiúscula e 1 caractere especial.';

  @override
  String get enterKeyLabel => 'Inserir chave';

  @override
  String get pleaseEnterKey => 'Por favor, insira a chave';

  @override
  String get filterNotesTitle => 'Filtrar notas';

  @override
  String get filterPinnedNotesTooltip => 'Filtrar notas fixadas';

  @override
  String get filterStarredNotesTooltip => 'Filtrar notas marcadas com estrela';

  @override
  String get filterTextNotesTooltip => 'Filtrar notas de texto';

  @override
  String get filterTasksTooltip => 'Filtrar tarefas';

  @override
  String get filterLinksTooltip => 'Filtrar links';

  @override
  String get filterImagesTooltip => 'Filtrar imagens';

  @override
  String get filterAudioTooltip => 'Filtrar áudio';

  @override
  String get filterVideoTooltip => 'Filtrar vídeos';

  @override
  String get filterFilesTooltip => 'Filtrar arquivos';

  @override
  String get filterContactsTooltip => 'Filtrar contatos';

  @override
  String get filterLocationTooltip => 'Filtrar localizações';

  @override
  String get movedToTrash => 'Movido para a lixeira';

  @override
  String get copiedNotesToClipboard => 'Copiado para a área de transferência';

  @override
  String get locationShareLabel => 'Localização:';

  @override
  String get contactShareLabel => 'Contato:';

  @override
  String get emailsShareLabel => 'E-mails:';

  @override
  String get addressesShareLabel => 'Endereços:';

  @override
  String get microphoneNotAvailable => 'O microfone pode não estar disponível.';

  @override
  String get microphonePermissionRequired => 'A permissão de microfone é necessária para gravar áudio.';

  @override
  String get couldNotGetDuration => 'Não foi possível obter a duração';

  @override
  String get errorOpeningFiles => 'Erro ao abrir arquivos';

  @override
  String get pleaseWaitTitle => 'Por favor, aguarde';

  @override
  String get fileNotAvailableYet => 'Arquivo ainda não disponível';

  @override
  String get clearSelectionTooltip => 'Limpar seleção';

  @override
  String get copyNotesTooltip => 'Copiar notas';

  @override
  String get changeTaskTypeTooltip => 'Alterar tipo de tarefa';

  @override
  String get shareNotesTooltip => 'Compartilhar notas';

  @override
  String get editNoteTooltip => 'Editar nota';

  @override
  String get starUnstarNotesTooltip => 'Marcar/desmarcar com estrela';

  @override
  String get moveToTrashTooltip => 'Mover para a lixeira';

  @override
  String get pinUnpinNotesTooltip => 'Fixar/desfixar notas';

  @override
  String get cancelReplyTooltip => 'Cancelar resposta';

  @override
  String get createTaskHint => 'Criar uma tarefa';

  @override
  String get addNoteHint => 'Adicionar uma nota...';

  @override
  String get attachTooltip => 'Anexar';

  @override
  String get addNoteTooltip => 'Adicionar nota';

  @override
  String get recordStopAudioTooltip => 'Gravar/parar áudio';

  @override
  String get contactAttachmentLabel => 'Contato';

  @override
  String get locationAttachmentLabel => 'Localização';

  @override
  String get cameraAttachmentLabel => 'Câmera';

  @override
  String get filesAttachmentLabel => 'Arquivos';

  @override
  String get checklistAttachmentLabel => 'Lista de verificação';

  @override
  String get accessKeyInputTitle => 'Ativar Sincronização';

  @override
  String get accessKeyInputDescription => 'Por favor, insira sua frase de recuperação de 24 palavras ou carregue um arquivo .txt que a contenha.';

  @override
  String get editMenuItemLabel => 'Editar';

  @override
  String get filterMenuItemLabel => 'Filtros';

  @override
  String get externalStoragePermissionDenied => 'A permissão para acessar o armazenamento externo foi negada.';

  @override
  String get pressLongToStartRecording => 'Pressione e segure para começar a gravar.';

  @override
  String get didYouKnowTitle => 'Você sabia?';

  @override
  String get closeTooltip => 'Fechar';

  @override
  String appDescriptionContent(String appName) {
    return 'O $appName é um aplicativo de notas totalmente privado. Ele não coleta seus dados pessoais nem exibe anúncios.\n\nEsperamos que você goste de usá-lo. Diga-nos o que você acha.';
  }

  @override
  String get searchNotesTooltip => 'Pesquisar notas';

  @override
  String get syncMenuItemLabel => 'Sincronizar';

  @override
  String get trashMenuItemLabel => 'Lixeira';

  @override
  String get starredNotesMenuItemLabel => 'Notas marcadas';

  @override
  String get settingsMenuItemLabel => 'Configurações';

  @override
  String get accountMenuItemLabel => 'Conta';

  @override
  String get pageMenuItemLabel => 'Página';

  @override
  String get sqliteMenuItemLabel => 'Sqlite';

  @override
  String get logsMenuItemLabel => 'Logs';

  @override
  String get reorderMenuItemLabel => 'Reordenar';

  @override
  String get editGroupMenuItemLabel => 'Editar';

  @override
  String get deleteGroupMenuItemLabel => 'Excluir';

  @override
  String get dragHandleReorderTooltip => 'Arraste para reordenar';

  @override
  String get holdAndDragReorderTooltip => 'Segure e arraste para reordenar';

  @override
  String get emptyHomePageMessage => 'Olá!\n\nParece um pouco vazio por aqui.\n\nToque no botão + e crie algumas notas para si mesmo. :)';

  @override
  String get reorderingTitle => 'Reordenando';

  @override
  String get selectEllipsisLabel => 'Selecionar...';

  @override
  String get dateTimeToggleLabel => 'Data/Hora';

  @override
  String get noteBorderToggleLabel => 'Borda da nota';

  @override
  String get deleteGroupButtonLabel => 'Excluir';

  @override
  String get notesTabLabel => 'Notas';

  @override
  String get groupsTabLabel => 'Grupos';

  @override
  String get categoriesTabLabel => 'Categorias';

  @override
  String get locationItemLabel => 'Localização';

  @override
  String get addGroupTitle => 'Adicionar grupo';

  @override
  String get editGroupTitle => 'Editar grupo';

  @override
  String get titleInputLabel => 'Título';

  @override
  String get locationPermissionRequiredTitle => 'Permissão de Localização Necessária';

  @override
  String get enableLocationPermissionsContent => 'Por favor, ative as permissões de localização nas configurações do aplicativo.';

  @override
  String get cancelButtonLabel => 'Cancelar';

  @override
  String get openSettingsButtonLabel => 'Abrir Configurações';

  @override
  String get locationServicesTitle => 'Serviços de Localização';

  @override
  String get pleaseEnableLocationServicesContent => 'Por favor, ative!';

  @override
  String get selectLocationTitle => 'Selecionar localização';

  @override
  String get useCurrentLocationTooltip => 'Usar localização atual';

  @override
  String get selectAllButtonLabel => 'Selecionar tudo';

  @override
  String get searchLogsHint => 'Pesquisar logs..';

  @override
  String get noLogsAvailable => 'Nenhum log disponível';

  @override
  String get dbViewerTitle => 'Visualizador de DB';

  @override
  String get selectTableToViewData => 'Selecione uma tabela para ver seus dados';

  @override
  String get selectTableDropdownHint => 'Selecione uma tabela';

  @override
  String get pickContactTitle => 'Escolher um contato';

  @override
  String get permissionRequiredText => 'Permissão necessária';

  @override
  String get grantPermissionButtonLabel => 'Conceder permissão';

  @override
  String get pageDummyTitle => 'Página Dummy';

  @override
  String get simulateButtonLabel => 'Simular';

  @override
  String get selectCategoryTitle => 'Selecionar categoria';

  @override
  String get addCategoryTitle => 'Adicionar categoria';

  @override
  String get editCategoryTitle => 'Editar categoria';

  @override
  String get categoryTitleHint => 'Título da categoria';

  @override
  String get colorLabel => 'Cor';

  @override
  String get changeColorLabel => 'Alterar cor';

  @override
  String get deviceDisabledMessage => 'Dispositivo desativado!';

  @override
  String get cannotRemoveThisDeviceMessage => 'Não é possível remover este dispositivo!';

  @override
  String get confirmRemoveTitle => 'Confirmar Remoção';

  @override
  String get confirmRemoveDeviceContent => 'Tem certeza? Isso excluirá todos os dados do dispositivo.';

  @override
  String get okButtonLabel => 'OK';

  @override
  String get registeredDevicesTitle => 'Dispositivos Registrados';

  @override
  String get noDevicesFoundMessage => 'Nenhum dispositivo encontrado';

  @override
  String get enabledLabel => 'Ativado';

  @override
  String get disabledLabel => 'Desativado';

  @override
  String get migratingMediaTitle => 'Migrando Mídia';

  @override
  String get processingMessage => 'Processando...';

  @override
  String get doNotNavigateAwayMessage => 'Por favor, não saia desta página';

  @override
  String errorWithDetails(String error) {
    return 'Erro: $error';
  }

  @override
  String get sequenceNotAcceptedError => 'Sequência não aceita';

  @override
  String get examplesNotAcceptedError => 'Exemplos não aceitos';

  @override
  String get enterKeyAgainLabel => 'Insira a chave novamente';

  @override
  String get pleaseEnterKeyAgainError => 'Por favor, insira a chave novamente';

  @override
  String get keysDoNotMatchError => 'As chaves não coincidem';

  @override
  String get ruleUppercaseLetter => '1 letra maiúscula';

  @override
  String get ruleLowercaseLetter => '1 letra minúscula';

  @override
  String get ruleNumericLetter => '1 número';

  @override
  String get ruleSpecialCharacter => '1 caractere especial';

  @override
  String get ruleMinTenCharacters => 'mínimo 10 caracteres';

  @override
  String get examplesTitle => 'Exemplos';

  @override
  String get passwordExample1 => 'I would love 2 have @ll ...';

  @override
  String get passwordExample2 => '(A6r4K4D46r4)';

  @override
  String get passwordExample3 => 'Mykey@2025';

  @override
  String get passwordExample4 => 'C0ffee !s great f0r pr0ductivity';

  @override
  String get gotItButtonLabel => 'Entendi';

  @override
  String get encryptionKeyTitle => 'Chave de criptografia';

  @override
  String get createKeyDescription => 'Por favor, insira uma chave (senha) longa e difícil de adivinhar. Lembre-se de salvá-la em um lugar seguro. Se ela for perdida ou esquecida, não poderá ser recuperada.';

  @override
  String get seeExamplesTooltip => 'Ver exemplos';

  @override
  String get couldNotFetchDetailsMessage => 'Não foi possível obter detalhes';

  @override
  String get retryButtonLabel => 'Tentar novamente';

  @override
  String get signedInAsLabel => 'Conectado como:';

  @override
  String get storageUsageLabel => 'Uso de armazenamento';

  @override
  String get subscribeLabel => 'Assinar';

  @override
  String get planExpiredRenewLabel => 'Plano expirou! Renovar';

  @override
  String get manageDevicesLabel => 'Gerenciar dispositivos';

  @override
  String get viewAccessKeyLabel => 'Ver chave de acesso';

  @override
  String get changeKeyPasswordLabel => 'Alterar senha da chave';

  @override
  String get manageSubscriptionLabel => 'Gerenciar assinatura';

  @override
  String get signOutButtonLabel => 'Sair';

  @override
  String get yearlyPlansTitle => 'Planos anuais';

  @override
  String get loginLabel => 'Entrar';

  @override
  String get syncAllYourNotesLabel => 'Sincronize todas as suas notas';

  @override
  String get acrossYourDevicesLabel => 'em todos os seus dispositivos';

  @override
  String get featureEndToEndEncryption => 'Criptografia de ponta a ponta';

  @override
  String get featureSyncUpTo3Devices => 'Sincronize até 3 dispositivos';

  @override
  String get featureUpgradeCancelAnytime => 'Faça upgrade/Cancele a qualquer momento';

  @override
  String get noPlansAvailableMessage => 'Nenhum plano disponível';

  @override
  String get downloadAppSubscribeLabel => 'Baixe o aplicativo e assine';

  @override
  String get privacyTermsLabel => 'Privacidade • Termos';

  @override
  String get saveFiftyPercentLabel => 'Economize 50%';

  @override
  String get helloTitle => 'Olá';

  @override
  String get selectKeyMasterKeyDescription => 'Para criptografar seus dados, precisaremos de uma chave mestra de criptografia.';

  @override
  String get selectKeyTwoOptionsDescription => 'Existem 2 opções - ou você cria uma chave (como uma senha) ou nós criamos uma para você.';

  @override
  String get understandLoseKeyAcknowledgement => 'Entendo que se eu perder/esquecer a chave de criptografia, posso perder meus dados.';

  @override
  String get createKeyForMeButtonLabel => 'Criar a chave para mim';

  @override
  String get recommendedLabel => '(Recomendado)';

  @override
  String get pleaseAcknowledgeMessage => 'Por favor, aceite os termos!';

  @override
  String get createKeyMyselfButtonLabel => 'Eu mesmo criarei a chave';

  @override
  String welcomeToAppName(String appName) {
    return 'Bem-vindo ao $appName';
  }

  @override
  String get e2eEncryptionDescription => 'Usamos criptografia de ponta a ponta para garantir que todas as suas notas estejam seguras e que ninguém mais possa vê-las, nem mesmo nós.';

  @override
  String get timeToStartEncryptionLabel => 'Hora de iniciar a criptografia!';

  @override
  String get nextButtonLabel => 'Próximo';

  @override
  String get sendingOtpFailedMessage => 'Falha ao enviar OTP. Por favor, tente novamente!';

  @override
  String get otpVerificationFailedMessage => 'Falha na verificação do OTP. Por favor, tente novamente!';

  @override
  String get emailSignInTitle => 'Entrar com E-mail';

  @override
  String get verifyOtpLabel => 'Verificar OTP';

  @override
  String get enterEmailLabel => 'Insira o E-mail';

  @override
  String get sendOtpLabel => 'Enviar OTP';

  @override
  String otpSentToEmailMessage(String email) {
    return 'Enviamos uma senha única (OTP) para seu e-mail $email';
  }

  @override
  String get enterOtpLabel => 'Insira o OTP';

  @override
  String get changeEmailLabel => 'Alterar e-mail';

  @override
  String get encryptingNotesTitle => 'Criptografando notas';

  @override
  String get fetchingDetailsTitle => 'Buscando detalhes';

  @override
  String get couldNotFetchMessage => 'Não foi possível buscar';

  @override
  String get subscriptionEmailMismatchMessage => 'Sua assinatura está associada a outro e-mail. Por favor, saia e use esse e-mail para ativar o armazenamento na nuvem.';

  @override
  String get errorCheckingPlanDetailsMessage => 'Erro ao verificar detalhes do plano';

  @override
  String get registerDeviceTitle => 'Registrar dispositivo';

  @override
  String get manageButtonLabel => 'Gerenciar';

  @override
  String get fetchingKeysTitle => 'Buscando Chaves';

  @override
  String get signingOutTitle => 'Saindo';

  @override
  String get pleaseCheckInternetMessage => 'Por favor, verifique a internet';

  @override
  String get somethingWentWrongMessage => 'Algo deu errado';

  @override
  String get playPauseTooltip => 'Reproduzir/pausar';

  @override
  String timerFormattedTime(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get downloadTooltip => 'Baixar';

  @override
  String get invalidAccessKey => 'Chave de acesso inválida';

  @override
  String get fileDoesNotContain24Words => 'O arquivo não contém exatamente 24 palavras.';

  @override
  String get errorReadingFile => 'Erro ao ler arquivo';

  @override
  String get allLabel => 'Tudo';

  @override
  String get logTypeDebug => 'DEBUG';

  @override
  String get logTypeError => 'ERRO';

  @override
  String get logTypeInfo => 'INFO';

  @override
  String get logTypeWarning => 'AVISO';

  @override
  String get groupTitleHint => 'Título do grupo';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get selectCategoryPlaceholder => 'Selecionar categoria';

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
  String get searchHint => 'consulta, #documento etc..';

  @override
  String get categoryGroupSeparator => ' > ';

  @override
  String get audioFileLabel => 'Arquivo de áudio';

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
  String get selectLanguageTitle => 'Selecionar idioma';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get themeLabel => 'Tema';

  @override
  String get dayNightThemeTooltip => 'Tema diurno/noturno';

  @override
  String get lockLabel => 'Bloqueio';

  @override
  String get timeFormatLabel => 'Formato de Hora';

  @override
  String get h12Label => 'H12';

  @override
  String get h24Label => 'H24';

  @override
  String get fontSizeLabel => 'Tamanho da fonte';

  @override
  String get reduceTextSizeTooltip => 'Reduzir tamanho da fonte';

  @override
  String get increaseTextSizeTooltip => 'Aumentar tamanho da fonte';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get autoOpenGroupLabel => 'Abrir grupo automaticamente';

  @override
  String get selectGroupTitle => 'Selecionar grupo';

  @override
  String shareAppMessage(String appName, String appLink) {
    return 'Crie um $appName: $appLink';
  }

  @override
  String get noteTypeEmpty => 'Vazio';

  @override
  String get noteTypeImage => 'Imagem';

  @override
  String get noteTypeVideo => 'Vídeo';

  @override
  String get noteTypeAudio => 'Áudio';

  @override
  String get noteTypeDocument => 'Documento';

  @override
  String get noteTypeContact => 'Contato';

  @override
  String get noteTypeLocation => 'Localização';

  @override
  String get noteTypeUnknown => 'Desconhecido';

  @override
  String get pleaseEnterData => 'Por favor, insira dados';

  @override
  String get aNumber => 'Um número';

  @override
  String get enterDataLabel => 'Insira dados';

  @override
  String get pleaseEnterValidData => 'Por favor, insira dados válidos';

  @override
  String get pleaseSelectAnOption => 'Por favor, selecione uma opção';

  @override
  String dateRangeFormat(String start, String end) {
    return '$start - $end';
  }

  @override
  String get todayLabel => 'Hoje';

  @override
  String get yesterdayLabel => 'Ontem';

  @override
  String get mondayLabel => 'Segunda-feira';

  @override
  String get tuesdayLabel => 'Terça-feira';

  @override
  String get wednesdayLabel => 'Quarta-feira';

  @override
  String get thursdayLabel => 'Quinta-feira';

  @override
  String get fridayLabel => 'Sexta-feira';

  @override
  String get saturdayLabel => 'Sábado';

  @override
  String get sundayLabel => 'Domingo';

  @override
  String get januaryShortLabel => 'Jan';

  @override
  String get februaryShortLabel => 'Fev';

  @override
  String get marchShortLabel => 'Mar';

  @override
  String get aprilShortLabel => 'Abr';

  @override
  String get mayShortLabel => 'Mai';

  @override
  String get juneShortLabel => 'Jun';

  @override
  String get julyShortLabel => 'Jul';

  @override
  String get augustShortLabel => 'Ago';

  @override
  String get septemberShortLabel => 'Set';

  @override
  String get octoberShortLabel => 'Out';

  @override
  String get novemberShortLabel => 'Nov';

  @override
  String get decemberShortLabel => 'Dez';

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
    return '$count grupo de notas';
  }

  @override
  String noteGroupCountPlural(int count) {
    return '$count grupos de notas';
  }


  @override
  String get seedCategoryTasks => "Tarefas";

  @override
  String get seedGroupNotes => "Notas";

  @override
  String get seedGroupFitness => "Fitness";

  @override
  String get seedItemWelcome =>
      "Bem-vindo ao Note Safe!\nIdeias, listas ou qualquer coisa em sua mente, coloque tudo aqui.\n\nPressione e segure nesta nota para excluir, editar e ver outras opções.";

  @override
  String get seedItemMorningWorkout => "Treino matinal";

  @override
  String get seedItemMeditation => "10 minutos de meditação";

  @override
  String get seedItemWater => "2L de água por dia";

  @override
  String get seedItemSteps => "Caminhar 10.000 passos";
}
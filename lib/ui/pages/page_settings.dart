import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ntsapp/l10n/app_localizations.dart';
import 'package:ntsapp/utils/backup_restore.dart';
import 'package:ntsapp/utils/enums.dart';
import 'package:ntsapp/models/model_item_group.dart';
import 'package:ntsapp/models/model_setting.dart';
import 'package:ntsapp/services/service_events.dart';
import 'package:ntsapp/services/service_logger.dart';
import 'package:ntsapp/storage/storage_secure.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/service_locale.dart';
import '../../utils/common.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  final VoidCallback onThemeToggle;
  final bool canShowBackupRestore;

  const SettingsPage(
      {super.key,
      required this.isDarkMode,
      required this.onThemeToggle,
      required this.canShowBackupRestore,
      required this.runningOnDesktop,
      required this.setShowHidePage});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final logger = AppLogger(prefixes: ["page_settings"]);
  final LocalAuthentication _auth = LocalAuthentication();
  SecureStorage secureStorage = SecureStorage();
  bool isAuthSupported = false;
  bool isAuthEnabled = false;
  bool loggingEnabled =
      ModelSetting.get(AppString.loggingEnabled.string, "no") == "yes";
  String timeFormat = "H12";
  String autoOpenGroupId = "";
  String autoOpenGroupTitle = "";

  @override
  void initState() {
    super.initState();
    timeFormat = ModelSetting.get(AppString.timeFormat.string, "H12");
    isAuthEnabled = ModelSetting.get("local_auth", "no") == "yes";
    _loadAutoOpenGroup();
  }

  Future<void> _loadAutoOpenGroup() async {
    String groupId =
        ModelSetting.get(AppString.autoopengroup.string, "") as String;
    if (groupId.isNotEmpty) {
      ModelGroup? group = await ModelGroup.get(groupId);
      if (mounted) {
        setState(() {
          autoOpenGroupId = groupId;
          autoOpenGroupTitle = group?.title ?? "";
        });
      }
    }
  }

  Future<void> _setAutoOpenGroup(ModelGroup group) async {
    await ModelSetting.set(AppString.autoopengroup.string, group.id!);
    if (mounted) {
      setState(() {
        autoOpenGroupId = group.id!;
        autoOpenGroupTitle = group.title;
      });
    }
  }

  Future<void> _clearAutoOpenGroup() async {
    await ModelSetting.delete(AppString.autoopengroup.string);
    if (mounted) {
      setState(() {
        autoOpenGroupId = "";
        autoOpenGroupTitle = "";
      });
    }
  }

  Future<void> _showAutoOpenGroupPicker() async {
    List<ModelGroup> groups = await ModelGroup.allActive();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select group',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: groups.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      final isSelected = group.id == autoOpenGroupId;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        title: Text(group.title),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : null,
                        onTap: () {
                          _setAutoOpenGroup(group);
                          Navigator.of(sheetContext).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> checkDeviceAuth() async {
    isAuthSupported = await _auth.isDeviceSupported();
  }

  Future<void> setAuthSetting() async {
    isAuthEnabled = !isAuthEnabled;
    if (isAuthEnabled) {
      await ModelSetting.set("local_auth", "yes");
    } else {
      await ModelSetting.set("local_auth", "no");
    }
    if (mounted) setState(() {});
  }

  Future<void> _authenticate() async {
    final loc = AppLocalizations.of(context)!;
    try {
      bool isAuthenticated = await _auth.authenticate(
          localizedReason: loc.pleaseAuthenticate,
          biometricOnly: false,
          persistAcrossBackgrounding: true);

      if (isAuthenticated) {
        setAuthSetting();
      }
    } catch (e, s) {
      logger.error("_authenticate", error: e, stackTrace: s);
    }
  }

  Future<void> _setLogging(bool enable) async {
    if (enable) {
      await ModelSetting.set(AppString.loggingEnabled.string, "yes");
    } else {
      await ModelSetting.set(AppString.loggingEnabled.string, "no");
    }
    if (mounted) {
      setState(() {
        loggingEnabled = enable;
      });
    }
  }

  Future<void> updateTimeFormat(String? newFormat) async {
    if (newFormat == null) return;
    await ModelSetting.set(AppString.timeFormat.string, newFormat);
    if (mounted) {
      setState(() {
        timeFormat = newFormat;
      });
    }
  }

  void showProcessing() {
    showProcessingDialog(context);
  }

  void hideProcessing() {
    Navigator.pop(context);
  }

  Future<void> createDownloadBackup() async {
    final loc = AppLocalizations.of(context)!;
    showProcessing();
    String status = "";
    Directory directory = await getApplicationDocumentsDirectory();
    String dirPath = directory.path;
    String today = getTodayDate();
    String? backupDir = await secureStorage.read(key: "backup_dir");
    String backupFilePath = path.join(dirPath, "${backupDir}_$today.zip");
    File backupFile = File(backupFilePath);
    if (!backupFile.existsSync()) {
      try {
        status = await createBackup(dirPath);
      } catch (e) {
        status = e.toString();
      }
    }
    hideProcessing();
    if (status.isNotEmpty) {
      if (mounted) showAlertMessage(context, loc.couldNotCreate, status);
    } else {
      try {
        if (widget.runningOnDesktop) {
          final Uint8List bytes = await backupFile.readAsBytes();
          await FilePicker.saveFile(
            dialogTitle: loc.backupLabel,
            fileName: path.basename(backupFilePath),
            type: FileType.custom,
            allowedExtensions: ["zip"],
            bytes: bytes,
          );
        } else {
          // Use Share package to trigger download or share intent
          final params = ShareParams(
            text: loc.hereIsTheBackupFile,
            files: [XFile(backupFilePath)],
          );
          await SharePlus.instance.share(params);
        }
      } catch (e) {
        status = e.toString();
      }
      if (status.isNotEmpty) {
        if (mounted) showAlertMessage(context, loc.couldNotShareFile, status);
      }
    }
  }

  Future<void> restoreZipBackup() async {
    final loc = AppLocalizations.of(context)!;
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["zip"],
    );
    if (result != null) {
      if (result.files.isNotEmpty) {
        Directory directory = await getApplicationDocumentsDirectory();
        String dirPath = directory.path;
        PlatformFile selectedFile = result.files[0];
        String? backupDir = await secureStorage.read(key: "backup_dir");
        String zipFilePath = selectedFile.path!;
        String error = "";
        if (selectedFile.name.startsWith("${backupDir}_")) {
          showProcessing();
          try {
            error = await restoreBackup({"dir": dirPath, "zip": zipFilePath});
          } catch (e) {
            error = e.toString();
          }
          hideProcessing();
          if (error.isNotEmpty) {
            if (mounted) showAlertMessage(context, loc.errorTitle, error);
          }
        } else if (selectedFile.name.startsWith("NTS")) {
          showProcessing();
          try {
            error =
                await restoreOldBackup({"dir": dirPath, "zip": zipFilePath});
          } catch (e) {
            error = e.toString();
          }
          hideProcessing();
          if (error.isNotEmpty) {
            if (mounted) showAlertMessage(context, loc.errorTitle, error);
          }
        }
      }
    }
  }

  Future<void> setLocale(String localeCode) async {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    provider.setLocale(Locale(localeCode));
    await ModelSetting.set(AppString.locale.string, localeCode);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> clearLocale() async {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    // Clear locale to fallback to device default system language
    provider.clearLocale();
    await ModelSetting.delete(AppString.locale.string);
    if (mounted) {
      setState(() {});
    }
  }

  final List<_AppLanguageOption> _supportedLanguages = [
    _AppLanguageOption(
      code: 'ar',
      nativeName: (loc) => loc.languageArabic,
      locale: Locale('ar'),
    ),
    _AppLanguageOption(
      code: 'de',
      nativeName: (loc) => loc.languageGerman,
      locale: Locale('de'),
    ),
    _AppLanguageOption(
      code: 'el',
      nativeName: (loc) => loc.languageGreek,
      locale: Locale('el'),
    ),
    _AppLanguageOption(
      code: 'en',
      nativeName: (loc) => loc.languageEnglish,
      locale: Locale('en'),
    ),
    _AppLanguageOption(
      code: 'es',
      nativeName: (loc) => loc.languageSpanish,
      locale: Locale('es'),
    ),
    _AppLanguageOption(
      code: 'fa',
      nativeName: (loc) => loc.languagePersian,
      locale: Locale('fa'),
    ),
    _AppLanguageOption(
      code: 'fr',
      nativeName: (loc) => loc.languageFrench,
      locale: Locale('fr'),
    ),
    _AppLanguageOption(
      code: 'he',
      nativeName: (loc) => loc.languageHebrew,
      locale: Locale('he'),
    ),
    _AppLanguageOption(
      code: 'hi',
      nativeName: (loc) => loc.languageHindi,
      locale: Locale('hi'),
    ),
    _AppLanguageOption(
      code: 'id',
      nativeName: (loc) => loc.languageIndonesian,
      locale: Locale('id'),
    ),
    _AppLanguageOption(
      code: 'it',
      nativeName: (loc) => loc.languageItalian,
      locale: Locale('it'),
    ),
    _AppLanguageOption(
      code: 'ja',
      nativeName: (loc) => loc.languageJapanese,
      locale: Locale('ja'),
    ),
    _AppLanguageOption(
      code: 'ko',
      nativeName: (loc) => loc.languageKorean,
      locale: Locale('ko'),
    ),
    _AppLanguageOption(
      code: 'nl',
      nativeName: (loc) => loc.languageDutch,
      locale: Locale('nl'),
    ),
    _AppLanguageOption(
      code: 'pt',
      nativeName: (loc) => loc.languagePortuguese,
      locale: Locale('pt'),
    ),
    _AppLanguageOption(
      code: 'ru',
      nativeName: (loc) => loc.languageRussian,
      locale: Locale('ru'),
    ),
    _AppLanguageOption(
      code: 'th',
      nativeName: (loc) => loc.languageThai,
      locale: Locale('th'),
    ),
    _AppLanguageOption(
      code: 'tr',
      nativeName: (loc) => loc.languageTurkish,
      locale: Locale('tr'),
    ),
    _AppLanguageOption(
      code: 'uk',
      nativeName: (loc) => loc.languageUkrainian,
      locale: Locale('uk'),
    ),
    _AppLanguageOption(
      code: 'vi',
      nativeName: (loc) => loc.languageVietnamese,
      locale: Locale('vi'),
    ),
    _AppLanguageOption(
      code: 'zh',
      nativeName: (loc) => loc.languageChineseSimplified,
      locale: Locale('zh'),
    ),
  ];

  String _normalizeLocaleCode(Locale locale) {
    final countryCode = locale.countryCode;
    if (countryCode != null && countryCode.isNotEmpty) {
      return '${locale.languageCode}-r$countryCode';
    }
    return locale.languageCode;
  }

  _AppLanguageOption? _selectedLanguageOption() {
    final savedCode = ModelSetting.get(AppString.locale.string, "");
    if (savedCode.isEmpty) return null;

    try {
      return _supportedLanguages.firstWhere(
        (item) => item.code == savedCode,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final selected = _selectedLanguageOption();

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final loc = AppLocalizations.of(sheetContext)!;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      loc.selectLanguageTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: _supportedLanguages.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _supportedLanguages[index];
                      final isSelected = selected?.code == item.code;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        title: Text(item.nativeName(loc)),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : null,
                        onTap: () {
                          setLocale(_normalizeLocaleCode(item.locale));
                          Navigator.of(sheetContext).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(
          title: Text(loc.settingsTitle),
          leading: widget.runningOnDesktop
              ? BackButton(
                  onPressed: () async {
                    EventStream()
                        .publish(AppEvent(type: EventType.exitSettings));
                    widget.setShowHidePage!(
                        PageType.settings, false, PageParams());
                  },
                )
              : null,
        ),
        body: ListView(
          padding: const EdgeInsets.all(8.0),
          children: <Widget>[
            ListTile(
              leading: const Icon(LucideIcons.sunMoon, color: Colors.grey),
              title: Text(loc.themeLabel),
              horizontalTitleGap: 24.0,
              onTap: widget.onThemeToggle,
              trailing: IconButton(
                tooltip: loc.dayNightThemeTooltip,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    // Use both fade and rotation transitions
                    return FadeTransition(
                      opacity: animation,
                      child: RotationTransition(
                        turns: Tween<double>(begin: 0.75, end: 1.0)
                            .animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    key: ValueKey(widget.isDarkMode ? 'dark' : 'light'),
                    // Unique key for AnimatedSwitcher
                    color: widget.isDarkMode ? Colors.orange : Colors.black,
                  ),
                ),
                onPressed: () => widget.onThemeToggle(),
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.lock, color: Colors.grey),
              title: Text(loc.lockLabel),
              horizontalTitleGap: 24.0,
              trailing: Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: isAuthEnabled,
                  onChanged: (bool value) {
                    _authenticate();
                  },
                ),
              ),
            ),
            ListTile(
              // The icon at the beginning of the ListTile.
              leading: const Icon(LucideIcons.timer, color: Colors.grey),
              // The main text of the ListTile.
              title: Text(loc.timeFormatLabel),
              // The widget at the end of the ListTile, in this case, a dropdown.
              trailing: DropdownButton<String>(
                value: timeFormat,
                // The items that will be displayed in the dropdown.
                items: [
                  DropdownMenuItem(
                    value: "H12",
                    child: Text(loc.h12Label),
                  ),
                  DropdownMenuItem(
                    value: "H24",
                    child: Text(loc.h24Label),
                  ),
                ],
                // The function that is called when a new item is selected.
                onChanged: (format) => updateTimeFormat(format),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.text_fields, color: Colors.grey),
              title: Text(loc.fontSizeLabel),
              horizontalTitleGap: 24.0,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: loc.reduceTextSizeTooltip,
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      Provider.of<FontSizeController>(context, listen: false)
                          .decreaseFontSize();
                    },
                  ),
/*
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      Provider.of<FontSizeController>(context, listen: false)
                          .resetFontSize();
                    },
                  ),
*/
                  IconButton(
                    tooltip: loc.increaseTextSizeTooltip,
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Provider.of<FontSizeController>(context, listen: false)
                          .increaseFontSize();
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.languages, color: Colors.grey),
              title: Text(loc.languageLabel),
              horizontalTitleGap: 24.0,
              onTap: () => _showLanguagePicker(context),
              trailing: _selectedLanguageOption() != null
                  ? IconButton(
                      onPressed: () {
                        clearLocale();
                      },
                      icon: const Icon(LucideIcons.rotateCcw))
                  : null,
            ),
            ListTile(
              leading: const Icon(LucideIcons.folderOpen, color: Colors.grey),
              title: const Text('Auto-open group'),
              subtitle: autoOpenGroupTitle.isNotEmpty
                  ? Text(autoOpenGroupTitle)
                  : null,
              horizontalTitleGap: 24.0,
              onTap: _showAutoOpenGroupPicker,
              trailing: autoOpenGroupId.isNotEmpty
                  ? IconButton(
                      onPressed: _clearAutoOpenGroup,
                      icon: const Icon(LucideIcons.x),
                    )
                  : null,
            ),
            if (widget.canShowBackupRestore)
              ListTile(
                leading:
                    const Icon(LucideIcons.databaseBackup, color: Colors.grey),
                title: Text(loc.backupLabel),
                horizontalTitleGap: 24.0,
                onTap: () async {
                  createDownloadBackup();
                },
              ),
            if (widget.canShowBackupRestore)
              ListTile(
                leading: const Icon(LucideIcons.rotateCcw, color: Colors.grey),
                title: Text(loc.restoreLabel),
                horizontalTitleGap: 24.0,
                onTap: () async {
                  restoreZipBackup();
                },
              ),
            ListTile(
              leading: const Icon(LucideIcons.star, color: Colors.grey),
              title: Text(loc.leaveAReviewLabel),
              horizontalTitleGap: 24.0,
              onTap: () => _redirectToFeedback(),
            ),
            ListTile(
              leading: const Icon(LucideIcons.share2, color: Colors.grey),
              title: Text(loc.shareLabel),
              horizontalTitleGap: 24.0,
              onTap: () {
                _share();
              },
            ),
            if (Platform.isAndroid || Platform.isIOS)
              ListTile(
                leading: const Icon(LucideIcons.monitor, color: Colors.grey),
                title: Text(loc.desktopAppLinkLabel),
                horizontalTitleGap: 24.0,
                onTap: () => _redirectToDesktopApp(),
              ),
            ListTile(
              leading: const Icon(LucideIcons.list, color: Colors.grey),
              title: Text(loc.loggingLabel),
              horizontalTitleGap: 24.0,
              trailing: Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: loggingEnabled,
                  onChanged: _setLogging,
                ),
              ),
            ),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final version = snapshot.data?.version ?? '';
                  return ListTile(
                    leading: const Icon(LucideIcons.info, color: Colors.grey),
                    horizontalTitleGap: 24.0,
                    title: Text(loc.versionLabel(version)),
                    onTap: null,
                  );
                } else {
                  return ListTile(
                    leading: const Icon(LucideIcons.info, color: Colors.grey),
                    title: Text(loc.loadingLabel),
                    horizontalTitleGap: 24.0,
                  );
                }
              },
            ),
          ],
        ));
  }

  void _redirectToDesktopApp() {
    const url = "https://github.com/jeerovan/ntsapp/releases";
    openURL(url);
  }

  void _redirectToFeedback() {
    const url =
        'https://play.google.com/store/apps/details?id=com.makenotetoself';
    // Use your package name
    openURL(url);
  }

  Future<void> _share() async {
    final loc = AppLocalizations.of(context)!;
    String? appName = await secureStorage.read(key: AppString.appName.string);
    appName = appName ?? "";
    const String appLink =
        'https://play.google.com/store/apps/details?id=com.makenotetoself';
    final params = ShareParams(text: loc.shareAppMessage(appName, appLink));
    await SharePlus.instance.share(params);
  }
}

class _AppLanguageOption {
  final String code;
  final String Function(AppLocalizations loc) nativeName;
  final Locale locale;

  const _AppLanguageOption({
    required this.code,
    required this.nativeName,
    required this.locale,
  });
}

import 'package:flutter/material.dart';

import '../models/model_setting.dart';
import '../utils/enums.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  void _loadSavedLocale() async {
    String savedLanguageCode = ModelSetting.get(AppString.locale.string, "");
    if (savedLanguageCode.isNotEmpty) {
      _locale = Locale(savedLanguageCode);
      notifyListeners();
    }
  }

  void setLocale(Locale locale) async {
    if (!L10n.all.contains(locale)) {
      return; // Prevent setting unsupported locales
    }

    _locale = locale;
    notifyListeners();

    await ModelSetting.set(AppString.locale.string, locale.languageCode);
  }

  void clearLocale() async {
    _locale = null;
    notifyListeners();

    await ModelSetting.delete(AppString.locale.string);
  }
}

// Define your supported locales in a helper class
class L10n {
  static final all = [
    const Locale('ar'),
    const Locale('de'),
    const Locale('el'),
    const Locale('en'),
    const Locale('es'),
    const Locale('fa'),
    const Locale('fr'),
    const Locale('he'),
    const Locale('hi'),
    const Locale('id'),
    const Locale('it'),
    const Locale('ja'),
    const Locale('ko'),
    const Locale('nl'),
    const Locale('pt'),
    const Locale('ru'),
    const Locale('th'),
    const Locale('tr'),
    const Locale('uk'),
    const Locale('vi'),
    const Locale('zh'),
  ];
}

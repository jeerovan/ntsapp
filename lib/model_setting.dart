
import 'dart:convert';
import 'database_helper.dart';

class ModelSetting {
  static Map<String, dynamic> appJson = {};

  static Future<void> update(String key, dynamic value) async {
    appJson[key] = value;

    // Optional: Update the value in the database if needed
    final dbHelper = DatabaseHelper.instance;
    String encodedValue = jsonEncode(value);
    await dbHelper.insert('setting', {'id': key, 'value': encodedValue});
  }

  static dynamic getForKey(String key, dynamic defaultValue) {
    return appJson.containsKey(key) ? appJson[key] : defaultValue;
  }

}

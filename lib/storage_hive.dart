import 'package:hive_flutter/hive_flutter.dart';
import 'package:ntsapp/enums.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class StorageHive {
  static final StorageHive _instance = StorageHive._internal();
  static final boxName = "ntsHive";
  factory StorageHive() {
    return _instance;
  }

  StorageHive._internal();

  Future<void> init() async {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
    Box box = await Hive.openBox(boxName);
    String? existingDeviceId = box.get(AppString.deviceId.value);
    if (existingDeviceId == null) {
      String newDeviceId = Uuid().v4();
      await box.put(AppString.deviceId.value, newDeviceId);
    }
  }

  Future<void> put(String key, dynamic value) async {
    var box = Hive.box(boxName);
    await box.put(key, value);
  }

  dynamic get(String key, {dynamic defaultValue}) {
    var box = Hive.box(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  Future<void> delete(String key) async {
    var box = Hive.box(boxName);
    await box.delete(key);
  }

  Future<void> clear() async {
    var box = Hive.box(boxName);
    await box.clear();
  }

  Future<void> close() async {
    await Hive.close();
  }
}

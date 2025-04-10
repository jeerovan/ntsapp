import 'package:hive_flutter/hive_flutter.dart';
import 'package:ntsapp/enums.dart';
import 'package:path_provider/path_provider.dart';

class StorageHive {
  static final StorageHive _instance = StorageHive._internal();
  static final boxName = "ntsHive";

  factory StorageHive() {
    return _instance;
  }

  StorageHive._internal();

  static bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
    Box box = await Hive.openBox(boxName);
    _initialized = true;
    int? installedAt = box.get(AppString.installedAt.string);
    if (installedAt == null) {
      // app installed at
      await box.put(AppString.installedAt.string,
          DateTime.now().toUtc().millisecondsSinceEpoch);
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

  Stream<BoxEvent> watch(String key) {
    var box = Hive.box(boxName);
    return box.watch(key: key);
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

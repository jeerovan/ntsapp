import 'package:hive_flutter/hive_flutter.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/enums.dart';

class StorageHive {
  static final StorageHive _instance = StorageHive._internal();
  static final _boxName = "ntsHive";

  factory StorageHive() {
    return _instance;
  }

  StorageHive._internal();

  Box? _box;

  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      String storagepath = await getDbStoragePath();
      Hive.init(storagepath);
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
    int? installedAt = _box!.get(AppString.installedAt.string);
    if (installedAt == null) {
      // app installed at
      await _box!.put(AppString.installedAt.string,
          DateTime.now().toUtc().millisecondsSinceEpoch);
    }
  }

  Future<void> put(String key, dynamic value) async {
    var box = Hive.box(_boxName);
    await box.put(key, value);
  }

  dynamic get(String key, {dynamic defaultValue}) {
    var box = Hive.box(_boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  Map<dynamic, dynamic> getAll() {
    return Hive.box(_boxName).toMap();
  }

  Stream<BoxEvent> watch(String key) {
    var box = Hive.box(_boxName);
    return box.watch(key: key);
  }

  Future<void> delete(String key) async {
    var box = Hive.box(_boxName);
    await box.delete(key);
  }

  Future<void> clear() async {
    var box = Hive.box(_boxName);
    await box.clear();
  }

  Future<void> close() async {
    await Hive.close();
  }
}

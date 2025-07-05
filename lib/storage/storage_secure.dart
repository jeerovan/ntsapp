import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Singleton instance
  static final SecureStorage _instance = SecureStorage._internal();

  // Factory constructor to return the singleton instance
  factory SecureStorage() {
    return _instance;
  }

  // Private constructor
  SecureStorage._internal();

  // FlutterSecureStorage instance
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ));

  // CRUD Methods

  /// Write a key-value pair securely
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  /// Read a value by key
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  Future<bool> containsKey({required String key}) async {
    return await _storage.containsKey(key: key);
  }

  /// Delete a value by key
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }
}

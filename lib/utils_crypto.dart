import 'package:flutter/foundation.dart';
import 'package:ntsapp/common.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';

// Data class to pass parameters to compute function
class DeriveKeyFromPasswordParams {
  final String password;
  final Uint8List salt;
  final int opsLimit;
  final int memLimit;

  DeriveKeyFromPasswordParams({
    required this.password,
    required this.salt,
    required this.opsLimit,
    required this.memLimit,
  });
}

class CryptoUtils {
  final SodiumSumo _sodium;

  CryptoUtils(this._sodium);

  static init() {
    SodiumSumoInit.init();
  }

  SecureKey generateKey() {
    return _sodium.crypto.secretBox.keygen(); // Generate 256-bit (32-byte) key
  }

  // Derive key from password and salt
  //TODO fix limits
  Future<SecureKey> deriveKeyFromPassword({
    required String password,
    required Uint8List salt,
  }) async {
    return await _sodium.runIsolated((sodium, secureKeys, keyPairs) {
      return sodium.crypto.pwhash.call(
        password: password.toCharArray(),
        salt: salt,
        outLen: sodium.crypto.secretBox.keyBytes,
        opsLimit: sodium.crypto.pwhash.opsLimitSensitive,
        memLimit: sodium.crypto.pwhash.memLimitModerate,
        alg: CryptoPwhashAlgorithm.argon2id13,
      );
    });
  }

  Uint8List generateSalt() {
    return _sodium.randombytes.buf(_sodium.crypto.pwhash.saltBytes);
  }

  Uint8List generateNonce() {
    return _sodium.randombytes.buf(_sodium.crypto.secretBox.nonceBytes);
  }

  ExecutionResult encryptBytes(Uint8List message, Uint8List keyBytes) {
    SecureKey key = SecureKey.fromList(_sodium, keyBytes);
    Uint8List nonce = generateNonce();
    Uint8List encryptedData =
        _sodium.crypto.secretBox.easy(message: message, nonce: nonce, key: key);
    key.dispose();
    return ExecutionResult.success(
        {"encrypted": encryptedData, "nonce": nonce});
  }

  ExecutionResult decryptBytes(
      Uint8List message, Uint8List nonce, Uint8List keyBytes) {
    SecureKey key = SecureKey.fromList(_sodium, keyBytes);
    Uint8List decryptedData = _sodium.crypto.secretBox
        .openEasy(cipherText: message, nonce: nonce, key: key);
    key.dispose();
    return ExecutionResult.success({"decrypted": decryptedData});
  }
}

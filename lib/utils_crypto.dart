import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ntsapp/common.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';

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
  //TODO check limits
  Future<SecureKey> deriveKeyFromPassword({
    required String password,
    required Uint8List salt,
  }) async {
    return await _sodium.runIsolated((sodium, secureKeys, keyPairs) {
      return sodium.crypto.pwhash.call(
        password: password.toCharArray(),
        salt: salt,
        outLen: sodium.crypto.secretBox.keyBytes,
        opsLimit: sodium.crypto.pwhash.opsLimitSensitive *
            4, // compensation for memlimit
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

  ExecutionResult encryptBytes(
      {required Uint8List plainBytes, required Uint8List key}) {
    SecureKey secureKey = SecureKey.fromList(_sodium, key);
    Uint8List nonce = generateNonce();
    Uint8List cipherBytes = _sodium.crypto.secretBox
        .easy(message: plainBytes, nonce: nonce, key: secureKey);
    secureKey.dispose();
    return ExecutionResult.success({"encrypted": cipherBytes, "nonce": nonce});
  }

  ExecutionResult decryptBytes(
      {required Uint8List cipherBytes,
      required Uint8List nonce,
      required Uint8List key}) {
    SecureKey secureKey = SecureKey.fromList(_sodium, key);
    ExecutionResult executionResult;
    try {
      Uint8List plainBytes = _sodium.crypto.secretBox
          .openEasy(cipherText: cipherBytes, nonce: nonce, key: secureKey);
      executionResult = ExecutionResult.success({"decrypted": plainBytes});
    } catch (e) {
      executionResult = ExecutionResult.failure(reason: e.toString());
    } finally {
      secureKey.dispose();
    }
    return executionResult;
  }

  Future<ExecutionResult> encryptFile(String fileIn, String fileOut) async {
    SecureKey secretKey = _sodium.crypto.secretStream.keygen();
    String secretKeyBase64 = base64Encode(secretKey.extractBytes());

    await _sodium.crypto.secretStream
        .pushChunked(
          messageStream: File(fileIn).openRead(),
          key: secretKey,
          chunkSize: 4096,
        )
        .pipe(
          File(fileOut).openWrite(),
        );
    secretKey.dispose();
    return ExecutionResult.success({"key": secretKeyBase64});
  }

  Future<void> decryptFile(
      String fileIn, String fileOut, Uint8List keyBytes) async {
    SecureKey secretKey = SecureKey.fromList(_sodium, keyBytes);

    await _sodium.crypto.secretStream
        .pullChunked(
          cipherStream: File(fileIn).openRead(),
          key: secretKey,
          chunkSize: 4096,
        )
        .pipe(
          File(fileOut).openWrite(),
        );
    secretKey.dispose();
  }

  Future<ExecutionResult> updateGenerateKeys(
      String password, Map<String, dynamic> profileData) async {
    ExecutionResult result = ExecutionResult.failure(reason: "");
    AndroidOptions getAndroidOptions() => const AndroidOptions(
          encryptedSharedPreferences: true,
        );
    final storage = FlutterSecureStorage(aOptions: getAndroidOptions());
    String userId = profileData["id"];
    String keyForMasterKey = '${userId}_mk';
    String keyForRecoveryKey = '${userId}_rk';

    // check if we already have salt to generate password
    String? passwordSaltBase64 = profileData["pk_salt"];
    Uint8List passwordSalt = generateSalt();
    if (passwordSaltBase64 != null) {
      passwordSalt = base64Decode(passwordSaltBase64);
    } else {
      passwordSaltBase64 = base64Encode(passwordSalt);
    }
    SecureKey passwordKey =
        await deriveKeyFromPassword(password: password, salt: passwordSalt);
    Uint8List passwordKeyBytes = passwordKey.extractBytes();
    passwordKey.dispose();

    String? masterKeyEncryptedWithPasswordKeyBase64 = profileData["mk_ew_pk"];
    String? masterKeyPasswordKeyNonceBase64 = profileData["mk_pk_nonce"];

    if (masterKeyEncryptedWithPasswordKeyBase64 != null &&
        masterKeyPasswordKeyNonceBase64 != null) {
      Uint8List masterKeyEncryptedWithPasswordKeyBytes =
          base64Decode(masterKeyEncryptedWithPasswordKeyBase64);
      Uint8List masterKeyPasswordKeyNonce =
          base64Decode(masterKeyPasswordKeyNonceBase64);
      ExecutionResult masterKeyDecryptionResult = decryptBytes(
          cipherBytes: masterKeyEncryptedWithPasswordKeyBytes,
          nonce: masterKeyPasswordKeyNonce,
          key: passwordKeyBytes);
      if (masterKeyDecryptionResult.isFailure) {
        result = ExecutionResult.failure(reason: "Invalid Password");
      } else {
        Uint8List decryptedMasterKeyBytes =
            masterKeyDecryptionResult.getResult()!["decrypted"];
        String decryptedMasterKeyBase64 = base64Encode(decryptedMasterKeyBytes);

        // get recovery key
        String recoveryKeyEncryptedWithMasterKeyBase64 =
            profileData["rk_ew_mk"];
        Uint8List recoveryKeyEncryptedWithMasterKeyBytes =
            base64Decode(recoveryKeyEncryptedWithMasterKeyBase64);
        String recoveryKeyMasterKeyNonceBase64 = profileData["rk_mk_nonce"];
        Uint8List recoveryKeyMasterKeyNonceBytes =
            base64Decode(recoveryKeyMasterKeyNonceBase64);
        Uint8List recoveryKeyBytes = decryptBytes(
                cipherBytes: recoveryKeyEncryptedWithMasterKeyBytes,
                nonce: recoveryKeyMasterKeyNonceBytes,
                key: decryptedMasterKeyBytes)
            .getResult()!["decrypted"];
        String recoveryKeyBase64 = base64Encode(recoveryKeyBytes);
        // save keys to secure storage
        await storage.write(
            key: keyForMasterKey, value: decryptedMasterKeyBase64);
        await storage.write(key: keyForRecoveryKey, value: recoveryKeyBase64);

        result = ExecutionResult.success({"generated": false});
      }
    } else {
      // generate and save
      SecureKey masterKey = generateKey();
      Uint8List masterKeyBytes = masterKey.extractBytes();
      masterKey.dispose();
      String masterKeyBase64 = base64Encode(masterKeyBytes);

      SecureKey recoveryKey = generateKey();
      Uint8List recoveryKeyBytes = recoveryKey.extractBytes();
      recoveryKey.dispose();
      String recoveryKeyBase64 = base64Encode(recoveryKeyBytes);

      await storage.write(key: keyForMasterKey, value: masterKeyBase64);
      await storage.write(key: keyForRecoveryKey, value: recoveryKeyBase64);

      ExecutionResult masterKeyEncryptedWithRecoveryKeyResult =
          encryptBytes(plainBytes: masterKeyBytes, key: recoveryKeyBytes);
      Uint8List masterKeyEncryptedWithRecoveryKeyBytes =
          masterKeyEncryptedWithRecoveryKeyResult.getResult()!["encrypted"];
      Uint8List masterKeyRecoveryKeyNonceBytes =
          masterKeyEncryptedWithRecoveryKeyResult.getResult()!["nonce"];
      String masterKeyEncryptedWithRecoveryKeyBase64 =
          base64Encode(masterKeyEncryptedWithRecoveryKeyBytes);
      String masterKeyRecoveryKeyNonceBase64 =
          base64Encode(masterKeyRecoveryKeyNonceBytes);

      ExecutionResult recoveryKeyEncryptedWithMasterKeyResult =
          encryptBytes(plainBytes: recoveryKeyBytes, key: masterKeyBytes);
      Uint8List recoveryKeyEncryptedWithMasterKeyBytes =
          recoveryKeyEncryptedWithMasterKeyResult.getResult()!["encrypted"];
      Uint8List recoveryKeyMasterKeyNonceBytes =
          recoveryKeyEncryptedWithMasterKeyResult.getResult()!["nonce"];
      String recoveryKeyEncryptedWithMasterKeyBase64 =
          base64Encode(recoveryKeyEncryptedWithMasterKeyBytes);
      String recoveryKeyMasterKeyNonceBase64 =
          base64Encode(recoveryKeyMasterKeyNonceBytes);

      ExecutionResult masterKeyEncryptedWithPasswordKeyResult =
          encryptBytes(plainBytes: masterKeyBytes, key: passwordKeyBytes);
      Uint8List masterKeyEncryptedWithPasswordKeyBytes =
          masterKeyEncryptedWithPasswordKeyResult.getResult()!["encrypted"];
      Uint8List masterKeyPasswordKeyNonceBytes =
          masterKeyEncryptedWithPasswordKeyResult.getResult()!["nonce"];
      String masterKeyEncryptedWithPasswordKeyBase64 =
          base64Encode(masterKeyEncryptedWithPasswordKeyBytes);
      String masterKeyPasswordKeyNonceBase64 =
          base64Encode(masterKeyPasswordKeyNonceBytes);

      Map<String, dynamic> keysBase64 = {
        "mk_ew_rk": masterKeyEncryptedWithRecoveryKeyBase64,
        "mk_rk_nonce": masterKeyRecoveryKeyNonceBase64,
        "rk_ew_mk": recoveryKeyEncryptedWithMasterKeyBase64,
        "rk_mk_nonce": recoveryKeyMasterKeyNonceBase64,
        "mk_ew_pk": masterKeyEncryptedWithPasswordKeyBase64,
        "mk_pk_nonce": masterKeyPasswordKeyNonceBase64,
        "pk_salt": passwordSaltBase64,
        "updated_at": DateTime.now().toUtc().millisecondsSinceEpoch
      };
      result = ExecutionResult.success({"generated": true, "keys": keysBase64});
    }
    return result;
  }

  Future<ExecutionResult> generateKeysForNewPassword(
      String password, String userId) async {
    AndroidOptions getAndroidOptions() => const AndroidOptions(
          encryptedSharedPreferences: true,
        );
    final storage = FlutterSecureStorage(aOptions: getAndroidOptions());
    String keyForMasterKey = '${userId}_mk';

    String? masterKeyBase64 = await storage.read(key: keyForMasterKey);
    Uint8List masterKeyBytes = base64Decode(masterKeyBase64!);

    Uint8List passwordSalt = generateSalt();
    String passwordSaltBase64 = base64Encode(passwordSalt);

    SecureKey passwordKey =
        await deriveKeyFromPassword(password: password, salt: passwordSalt);
    Uint8List passwordKeyBytes = passwordKey.extractBytes();
    passwordKey.dispose();

    ExecutionResult masterKeyEncryptedWithPasswordKeyResult =
        encryptBytes(plainBytes: masterKeyBytes, key: passwordKeyBytes);
    Uint8List masterKeyEncryptedWithPasswordKeyBytes =
        masterKeyEncryptedWithPasswordKeyResult.getResult()!["encrypted"];
    Uint8List masterKeyPasswordKeyNonceBytes =
        masterKeyEncryptedWithPasswordKeyResult.getResult()!["nonce"];
    String masterKeyEncryptedWithPasswordKeyBase64 =
        base64Encode(masterKeyEncryptedWithPasswordKeyBytes);
    String masterKeyPasswordKeyNonceBase64 =
        base64Encode(masterKeyPasswordKeyNonceBytes);

    Map<String, dynamic> keysBase64 = {
      "mk_ew_pk": masterKeyEncryptedWithPasswordKeyBase64,
      "mk_pk_nonce": masterKeyPasswordKeyNonceBase64,
      "pk_salt": passwordSaltBase64,
      "updated_at": DateTime.now().toUtc().millisecondsSinceEpoch
    };
    return ExecutionResult.success({"keys": keysBase64});
  }
}

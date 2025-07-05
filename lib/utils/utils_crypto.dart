import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ntsapp/utils/common.dart';
import 'package:ntsapp/services/service_logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';
import 'package:crypto/crypto.dart';
import 'enums.dart';

import 'package:http/http.dart' as http;

import 'utils_sync.dart';

class CryptoUtils {
  final logger = AppLogger(prefixes: ["utils_crypto"]);
  final SodiumSumo _sodium;
  CryptoUtils(this._sodium);

  static init() {
    SodiumSumoInit.init();
  }

  SecureKey generateKey() {
    return _sodium.crypto.secretBox.keygen(); // Generate 256-bit (32-byte) key
  }

  // Derive key from password and salt
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
      {required Uint8List plainBytes, Uint8List? key}) {
    SecureKey secureKey =
        key == null ? generateKey() : SecureKey.fromList(_sodium, key);
    Uint8List keyBytes = secureKey.extractBytes();
    Uint8List nonce = generateNonce();
    Uint8List cipherBytes = _sodium.crypto.secretBox
        .easy(message: plainBytes, nonce: nonce, key: secureKey);
    secureKey.dispose();
    return ExecutionResult.success({
      AppString.encrypted.string: cipherBytes,
      AppString.key.string: keyBytes,
      AppString.nonce.string: nonce
    });
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
      executionResult =
          ExecutionResult.success({AppString.decrypted.string: plainBytes});
    } catch (e, s) {
      logger.error("decryptBytes", error: e, stackTrace: s);
      executionResult = ExecutionResult.failure(reason: e.toString());
    } finally {
      secureKey.dispose();
    }
    return executionResult;
  }

  Future<ExecutionResult> encryptFile(String fileIn, String fileOut,
      {Uint8List? key}) async {
    ExecutionResult executionResult;
    SecureKey secretKey = key == null
        ? _sodium.crypto.secretStream.keygen()
        : SecureKey.fromList(_sodium, key);
    String secretKeyBase64 = base64Encode(secretKey.extractBytes());
    try {
      await _sodium.crypto.secretStream
          .pushChunked(
            messageStream: File(fileIn).openRead(),
            key: secretKey,
            chunkSize: 4096,
          )
          .pipe(
            File(fileOut).openWrite(),
          );
      executionResult = ExecutionResult.success({"key": secretKeyBase64});
    } catch (e, s) {
      logger.error("encryptFile", error: e, stackTrace: s);
      executionResult = ExecutionResult.failure(reason: e.toString());
    } finally {
      secretKey.dispose();
    }

    return executionResult;
  }

  Future<ExecutionResult> decryptFile(
      String fileIn, String fileOut, Uint8List keyBytes) async {
    ExecutionResult executionResult;
    SecureKey secretKey = SecureKey.fromList(_sodium, keyBytes);
    try {
      await _sodium.crypto.secretStream
          .pullChunked(
            cipherStream: File(fileIn).openRead(),
            key: secretKey,
            chunkSize: 4096,
          )
          .pipe(
            File(fileOut).openWrite(),
          );
      executionResult = ExecutionResult.success({});
    } catch (e, s) {
      logger.error("decryptFile", error: e, stackTrace: s);
      executionResult = ExecutionResult.failure(reason: e.toString());
    } finally {
      secretKey.dispose();
    }
    return executionResult;
  }

  Future<bool> downloadDecryptFile(Map<String, dynamic> data) async {
    bool downloadDecrypted = false;
    String fileName = data["name"];
    Map<String, dynamic> serverData = await getDataToDownloadFile(fileName);
    String? masterKeyBase64 = await SyncUtils.getMasterKey();
    if (serverData.containsKey("url") && serverData["url"].isNotEmpty) {
      String downloadUrl = serverData["url"];
      Directory tempDir = await getTemporaryDirectory();
      String fileInPath = "${tempDir.path}/$fileName";
      File fileIn = File(fileInPath);
      IOSink fileInSink = fileIn.openWrite();
      try {
        var request = http.Request("GET", Uri.parse(downloadUrl));
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          // Stream file data to avoid memory overuse
          await response.stream.forEach((chunk) => fileInSink.add(chunk));
          await fileInSink.close();
          // decrypt file
          String mimeDirectory = data["mime"].split("/").first;
          String fileOutPath = await getFilePath(mimeDirectory, fileName);
          await checkAndCreateDirectory(fileOutPath);
          String keyCipherBase64 = serverData[AppString.key.string];
          String keyNonceBase64 = serverData[AppString.nonce.string];
          Uint8List? fileEncryptionKeyBytes = getFileEncryptionKeyBytes(
              keyCipherBase64, keyNonceBase64, masterKeyBase64!);
          if (fileEncryptionKeyBytes != null) {
            ExecutionResult decryptionResult = await decryptFile(
                fileInPath, fileOutPath, fileEncryptionKeyBytes);
            if (decryptionResult.isSuccess) {
              downloadDecrypted = true;
              logger.info("Fetched & decrypted");
            } else {
              String error = decryptionResult.failureReason ?? "";
              logger.error("Fetched but decryption failed", error: error);
            }
          } else {
            logger.error("failed to getFileEncryptionKeyBytes:$fileName");
          }
        } else {
          logger.error(
              "Request to fetch:$downloadUrl; NOT OK:${response.statusCode} -> ${response.reasonPhrase ?? ''}");
        }
      } catch (e, s) {
        logger.error("Error Fetching File", error: e, stackTrace: s);
      } finally {
        await fileInSink.close();
      }
    }
    return downloadDecrypted;
  }

  Map<String, dynamic> getEncryptedBytesMap(
      Uint8List plainBytes, Uint8List masterKeyBytes) {
    Map<String, dynamic> changeMap = {};
    ExecutionResult encryptionResult = encryptBytes(
      plainBytes: plainBytes,
    );
    Uint8List cipherBytes =
        encryptionResult.getResult()![AppString.encrypted.string];
    Uint8List keyBytes = encryptionResult.getResult()![AppString.key.string];
    Uint8List nonceBytes =
        encryptionResult.getResult()![AppString.nonce.string];

    //encrypt key with master key
    ExecutionResult keyEncryptionResult =
        encryptBytes(plainBytes: keyBytes, key: masterKeyBytes);
    Uint8List keyCipherBytes =
        keyEncryptionResult.getResult()![AppString.encrypted.string];
    Uint8List keyNonceBytes =
        keyEncryptionResult.getResult()![AppString.nonce.string];

    String cipherBase64 = base64Encode(cipherBytes);
    String nonceBase64 = base64Encode(nonceBytes);

    String keyCipherBase64 = base64Encode(keyCipherBytes);
    String keyNonceBase64 = base64Encode(keyNonceBytes);

    changeMap[AppString.cipherText.string] = cipherBase64;
    changeMap[AppString.cipherNonce.string] = nonceBase64;
    changeMap[AppString.keyCipher.string] = keyCipherBase64;
    changeMap[AppString.keyNonce.string] = keyNonceBase64;
    return changeMap;
  }

  Uint8List? getDecryptedBytesFromMap(
      Map<String, dynamic> map, Uint8List masterKeyBytes) {
    String keyCipherBase64 = map[AppString.keyCipher.string];
    String keyNonceBase64 = map[AppString.keyNonce.string];
    Uint8List keyCipherBytes = base64Decode(keyCipherBase64);
    Uint8List keyNonceBytes = base64Decode(keyNonceBase64);

    ExecutionResult keyDecryptionResult = decryptBytes(
        cipherBytes: keyCipherBytes, nonce: keyNonceBytes, key: masterKeyBytes);
    if (keyDecryptionResult.isFailure) return null;
    Uint8List keyBytes =
        keyDecryptionResult.getResult()![AppString.decrypted.string];

    String cipherTextBase64 = map[AppString.cipherText.string];
    String cipherNonceBase64 = map[AppString.cipherNonce.string];
    Uint8List cipherBytes = base64Decode(cipherTextBase64);
    Uint8List nonceBytes = base64Decode(cipherNonceBase64);

    ExecutionResult decryptionResult = decryptBytes(
        cipherBytes: cipherBytes, nonce: nonceBytes, key: keyBytes);
    if (decryptionResult.isFailure) return null;

    Uint8List decryptedBytes =
        decryptionResult.getResult()![AppString.decrypted.string];
    return decryptedBytes;
  }

  Map<String, dynamic> getFileEncryptionKeyCipher(
      Uint8List encryptionKeyBytes, Uint8List masterKeyBytes) {
    ExecutionResult keyEncryptionResult =
        encryptBytes(plainBytes: encryptionKeyBytes, key: masterKeyBytes);
    Uint8List keyCipherBytes =
        keyEncryptionResult.getResult()![AppString.encrypted.string];
    Uint8List keyNonceBytes =
        keyEncryptionResult.getResult()![AppString.nonce.string];
    String keyCipherBase64 = base64Encode(keyCipherBytes);
    String keyNonceBase64 = base64Encode(keyNonceBytes);
    return {
      AppString.keyCipher.string: keyCipherBase64,
      AppString.keyNonce.string: keyNonceBase64
    };
  }

  Uint8List? getFileEncryptionKeyBytes(
      String keyCipherBase64, String keyNonceBase64, String masterKeyBase64) {
    Uint8List keyCipherBytes = base64Decode(keyCipherBase64);
    Uint8List keyNonceBytes = base64Decode(keyNonceBase64);
    Uint8List masterKeyBytes = base64Decode(masterKeyBase64);
    ExecutionResult keyDecryptionResult = decryptBytes(
        cipherBytes: keyCipherBytes, nonce: keyNonceBytes, key: masterKeyBytes);
    if (keyDecryptionResult.isFailure) return null;
    Uint8List keyBytes =
        keyDecryptionResult.getResult()![AppString.decrypted.string];
    return keyBytes;
  }

  Future<ExecutionResult> generatePasswordKeys(String password,
      {Uint8List? masterKeyBytes}) async {
    if (masterKeyBytes == null) {
      SecureKey masterKey = generateKey();
      masterKeyBytes = masterKey.extractBytes();
      masterKey.dispose();
    }
    String masterKeyBase64 = base64Encode(masterKeyBytes);
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
    Map<String, dynamic> serverKeys = {
      "cipher": masterKeyEncryptedWithPasswordKeyBase64,
      "nonce": masterKeyPasswordKeyNonceBase64,
      "salt": passwordSaltBase64,
    };
    Map<String, dynamic> privateKeys = {
      "master_key": masterKeyBase64,
    };
    return ExecutionResult.success(
        {"server_keys": serverKeys, "private_keys": privateKeys});
  }

  ExecutionResult generateKeys({Uint8List? masterKeyBytes}) {
    if (masterKeyBytes == null) {
      SecureKey masterKey = generateKey();
      masterKeyBytes = masterKey.extractBytes();
      masterKey.dispose();
    }
    String masterKeyBase64 = base64Encode(masterKeyBytes);

    SecureKey accessKey = generateKey();
    Uint8List accessKeyBytes = accessKey.extractBytes();
    accessKey.dispose();
    String accessKeyBase64 = base64Encode(accessKeyBytes);

    ExecutionResult masterKeyEncryptedWithAccessKeyResult =
        encryptBytes(plainBytes: masterKeyBytes, key: accessKeyBytes);
    Uint8List masterKeyEncryptedWithAccessKeyBytes =
        masterKeyEncryptedWithAccessKeyResult.getResult()!["encrypted"];
    Uint8List masterKeyAccessKeyNonceBytes =
        masterKeyEncryptedWithAccessKeyResult.getResult()!["nonce"];
    String masterKeyEncryptedWithAccessKeyBase64 =
        base64Encode(masterKeyEncryptedWithAccessKeyBytes);
    String masterKeyAccessKeyNonceBase64 =
        base64Encode(masterKeyAccessKeyNonceBytes);

    Map<String, dynamic> serverKeysBase64 = {
      "cipher": masterKeyEncryptedWithAccessKeyBase64,
      "nonce": masterKeyAccessKeyNonceBase64,
      "salt": null,
    };

    Map<String, dynamic> privateKeysBase64 = {
      "master_key": masterKeyBase64,
      "access_key": accessKeyBase64
    };
    return ExecutionResult.success(
        {"server_keys": serverKeysBase64, "private_keys": privateKeysBase64});
  }

  static Future<String> generateSHA1(String filePath) async {
    final file = File(filePath);
    Stream<List<int>> stream = file.openRead();
    final sha = await stream.transform(sha1).first;
    return sha.toString();
  }
}

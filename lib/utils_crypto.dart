import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ntsapp/common.dart';
import 'package:sodium_libs/sodium_libs.dart';

class CryptoUtils {
  final Sodium _sodium;

  CryptoUtils(this._sodium);

  static init() {
    SodiumInit.init();
  }

  SecureKey generateKey() {
    return _sodium.crypto.secretBox.keygen(); // Generate 256-bit (32-byte) key
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

  ExecutionResult generateKeys() {
    SecureKey masterKey = generateKey();
    Uint8List masterKeyBytes = masterKey.extractBytes();
    masterKey.dispose();
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
      "mk_ew_ak": masterKeyEncryptedWithAccessKeyBase64,
      "mk_ak_nonce": masterKeyAccessKeyNonceBase64,
    };

    Map<String, dynamic> privateKeysBase64 = {
      "master_key": masterKeyBase64,
      "access_key": accessKeyBase64
    };
    return ExecutionResult.success(
        {"server_keys": serverKeysBase64, "private_keys": privateKeysBase64});
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/utils_crypto.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';

class PageDummy extends StatefulWidget {
  const PageDummy({super.key});

  @override
  State<PageDummy> createState() => _PageDummyState();
}

class _PageDummyState extends State<PageDummy> {
  String? masterKeyStr;
  String? saltStr;
  String? deriveKeyStr;
  bool encryptionDecryptionWorks = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      testEncryptions();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> testEncryptions() async {
    final SodiumSumo sodium = await SodiumSumoInit.init();
    final CryptoUtils cryptoUtils = CryptoUtils(sodium);

    SecureKey masterKey = cryptoUtils.generateKey();
    final Uint8List masterKeyBytes = masterKey.extractBytes();
    setState(() {
      masterKeyStr = bytesToHex(masterKeyBytes);
    });
    masterKey.dispose();

    final Uint8List salt = cryptoUtils.generateSalt();
    setState(() {
      saltStr = bytesToHex(salt);
    });

    SecureKey derivedKey = await cryptoUtils.deriveKeyFromPassword(
        password: "helloworld", salt: salt);
    final Uint8List deriveKeyBytes = derivedKey.extractBytes();
    derivedKey.dispose();
    setState(() {
      deriveKeyStr = bytesToHex(deriveKeyBytes);
    });

    // encrypt masterKey with derivedKey
    Map<String, dynamic>? encryptionResult =
        cryptoUtils.encryptBytes(masterKeyBytes, deriveKeyBytes).getResult();
    Uint8List encryptedMasterKey = encryptionResult!["encrypted"];
    Uint8List masterKeyEncryptionNonce = encryptionResult["nonce"];

    // decrypt encryptedMasterKey with derivedKey
    Map<String, dynamic>? decryptionResult = cryptoUtils
        .decryptBytes(
            encryptedMasterKey, masterKeyEncryptionNonce, deriveKeyBytes)
        .getResult();
    Uint8List decryptedMasterKey = decryptionResult!["decrypted"];

    setState(() {
      encryptionDecryptionWorks =
          bytesToHex(decryptedMasterKey) == bytesToHex(masterKeyBytes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Page Dummy"),
      ),
      body: Column(
        children: [
          CircularProgressIndicator(),
          Text("MasterKey:$masterKeyStr"),
          Text("Salt:$saltStr"),
          Text("DeriveKeyStr:$deriveKeyStr"),
          Text("Works:$encryptionDecryptionWorks"),
        ],
      ),
    );
  }
}

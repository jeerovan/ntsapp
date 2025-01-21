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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      doEncryptions();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> doEncryptions() async {
    final SodiumSumo sodium = await SodiumSumoInit.init();
    final CryptoUtils cryptoUtils = CryptoUtils(sodium);
    SecureKey masterKey = cryptoUtils.generateKey();
    // Access the binary data from the SecureKey
    final keyBytes = masterKey.extractBytes();
    setState(() {
      masterKeyStr = bytesToHex(keyBytes);
    });
    masterKey.dispose();

    final Uint8List salt = cryptoUtils.generateSalt();
    setState(() {
      saltStr = bytesToHex(salt);
    });

    SecureKey deriveKey = await cryptoUtils.deriveKeyFromPassword(
        password: "helloworld", salt: salt);
    final deriveKeyBytes = deriveKey.extractBytes();
    deriveKey.dispose();
    setState(() {
      deriveKeyStr = bytesToHex(deriveKeyBytes);
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
        ],
      ),
    );
  }
}

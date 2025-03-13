import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:ntsapp/utils_crypto.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';

class PagePasswordKeyInput extends StatefulWidget {
  final Map<String, dynamic> cipherData;
  const PagePasswordKeyInput({super.key, required this.cipherData});

  @override
  State<PagePasswordKeyInput> createState() => _PagePasswordKeyInputState();
}

class _PagePasswordKeyInputState extends State<PagePasswordKeyInput> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  bool processing = false;
  SecureStorage storage = SecureStorage();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Processes the validated 24 words further
  Future<void> _submitForm(String passwordString) async {
    setState(() {
      processing = true;
    });
    SodiumSumo sodium = await SodiumSumoInit.init();
    CryptoUtils cryptoUtils = CryptoUtils(sodium);

    String masterKeyCipheredBase64 = widget.cipherData["cipher"];
    String keyNonceBase64 = widget.cipherData["nonce"];
    String keySaltBase64 = widget.cipherData["salt"];

    Uint8List masterKeyCipheredBytes = base64Decode(masterKeyCipheredBase64);
    Uint8List keyNonceBytes = base64Decode(keyNonceBase64);
    Uint8List keySaltBytes = base64Decode(keySaltBase64);

    SecureKey passwordKey = await cryptoUtils.deriveKeyFromPassword(
        password: passwordString, salt: keySaltBytes);
    Uint8List passwordKeyBytes = passwordKey.extractBytes();
    passwordKey.dispose();

    ExecutionResult masterKeyDecryptionResult = cryptoUtils.decryptBytes(
        cipherBytes: masterKeyCipheredBytes,
        nonce: keyNonceBytes,
        key: passwordKeyBytes);
    if (masterKeyDecryptionResult.isFailure) {
      if (mounted) {
        showAlertMessage(context, "Failure", "Invalid password key");
      }
    } else {
      Uint8List decryptedMasterKeyBytes =
          masterKeyDecryptionResult.getResult()!["decrypted"];
      String decryptedMasterKeyBase64 = base64Encode(decryptedMasterKeyBytes);

      String userId = widget.cipherData["id"];
      String keyForMasterKey = '${userId}_mk';
      String keyForKeyType = '${userId}_kt';
      // save keys to secure storage
      await storage.write(
          key: keyForMasterKey, value: decryptedMasterKeyBase64);
      await storage.write(key: keyForKeyType, value: "password");

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
    setState(() {
      processing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enable Sync'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TextField with Validation
              TextFormField(
                controller: _textController,
                maxLines: null, // Allows all words to be visible
                decoration: InputDecoration(
                  labelText: 'Enter key',
                  border: OutlineInputBorder(),
                  hintText: 'Enter key',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter key';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitForm(_textController.text.trim());
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (processing)
                      Padding(
                        padding: const EdgeInsets.only(
                            right:
                                8.0), // Add spacing between indicator and text
                        child: SizedBox(
                          width: 16, // Set width and height for the indicator
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, // Set color to white
                          ),
                        ),
                      ),
                    Text(
                      'Submit',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }
}

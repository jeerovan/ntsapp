import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ntsapp/utils/common.dart';
import 'package:ntsapp/storage/storage_secure.dart';
import 'package:ntsapp/utils/utils_crypto.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';

import '../common_widgets.dart';
import '../../utils/enums.dart';
import '../../models/model_preferences.dart';
import 'page_user_task.dart';
import '../../utils/utils_sync.dart';

class PagePasswordKeyInput extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  final Map<String, dynamic> cipherData;
  const PagePasswordKeyInput(
      {super.key,
      required this.cipherData,
      required this.runningOnDesktop,
      this.setShowHidePage});

  @override
  State<PagePasswordKeyInput> createState() => _PagePasswordKeyInputState();
}

class _PagePasswordKeyInputState extends State<PagePasswordKeyInput> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  bool processing = false;
  SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    if (simulateOnboarding()) {
      simulatePasswordInput();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> simulatePasswordInput() async {
    String userId = widget.cipherData["id"];
    String keyForAccessKey = '${userId}_ak';
    String? passwordBase64 = await secureStorage.read(key: keyForAccessKey);
    if (passwordBase64 != null) {
      List<int> passwordBytes = base64Decode(passwordBase64);
      String password = utf8.decode(passwordBytes);
      if (mounted) {
        setState(() {
          _textController.text = password;
        });
      }
    }
  }

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
      await secureStorage.write(
          key: keyForMasterKey, value: decryptedMasterKeyBase64);
      await secureStorage.write(key: keyForKeyType, value: "password");
      // push local content
      bool pushedLocalContent = await ModelPreferences.get(
              AppString.pushedLocalContentForSync.string,
              defaultValue: "no") ==
          "yes";
      if (!pushedLocalContent) {
        SyncUtils.pushLocalChanges();
      }
      if (widget.runningOnDesktop) {
        if (!pushedLocalContent) {
          widget.setShowHidePage!(PageType.userTask, true,
              PageParams(appTask: AppTask.pushLocalContent));
        }
        widget.setShowHidePage!(PageType.passwordInput, false, PageParams());
      } else {
        if (mounted) {
          if (pushedLocalContent) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacement(
              AnimatedPageRoute(
                child: PageUserTask(
                  task: AppTask.pushLocalContent,
                  runningOnDesktop: widget.runningOnDesktop,
                  setShowHidePage: widget.setShowHidePage,
                ),
              ),
            );
          }
        }
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
        leading: widget.runningOnDesktop
            ? BackButton(
                onPressed: () {
                  widget.setShowHidePage!(
                      PageType.passwordInput, false, PageParams());
                },
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                  "Please enter the key (password) you had created. Its a min 10 characters long with minimum 1 numeric, 1 lowercase, 1 uppercase and 1 special character."),
              SizedBox(
                height: 40,
              ),
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
                            color: Colors.black,
                            strokeWidth: 2, // Set color to white
                          ),
                        ),
                      ),
                    Text(
                      'Submit',
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
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

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/utils/common.dart';
import 'package:ntsapp/ui/common_widgets.dart';
import 'package:ntsapp/ui/pages/page_user_task.dart';
import 'package:ntsapp/storage/storage_secure.dart';
import 'package:ntsapp/utils/utils_crypto.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';

import '../../utils/enums.dart';
import '../../models/model_preferences.dart';
import '../../utils/utils_sync.dart';

class PageAccessKeyInput extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  final Map<String, dynamic> cipherData;
  const PageAccessKeyInput(
      {super.key,
      required this.cipherData,
      required this.runningOnDesktop,
      this.setShowHidePage});

  @override
  State<PageAccessKeyInput> createState() => _PageAccessKeyInputState();
}

class _PageAccessKeyInputState extends State<PageAccessKeyInput> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  String _loadedFileContent = '';
  bool processing = false;
  SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    if (simulateOnboarding()) {
      simulateKeyInput();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> simulateKeyInput() async {
    String userId = widget.cipherData["id"];
    String keyForAccessKey = '${userId}_ak';
    String? accessKeyBase64 = await secureStorage.read(key: keyForAccessKey);
    Uint8List accessKeyBytes = base64Decode(accessKeyBase64!);
    String accessKeyHex = bytesToHex(accessKeyBytes);
    if (mounted) {
      setState(() {
        _textController.text = bip39.entropyToMnemonic(accessKeyHex);
      });
    }
  }

  /// Validates input to ensure it contains exactly 24 words
  bool _validateWordCount(String input) {
    final words = input.trim().split(RegExp(r'\s+'));
    return words.length == 24;
  }

  /// Processes the validated 24 words further
  Future<void> _processWords(String words) async {
    words = words.trim();
    setState(() {
      processing = true;
    });
    words = utf8.decode(utf8.encode(words));
    words = words.trim().replaceAll(RegExp(r'\s+'), ' ');
    SodiumSumo sodium = await SodiumSumoInit.init();
    CryptoUtils cryptoUtils = CryptoUtils(sodium);
    if (!bip39.validateMnemonic(words)) {
      if (mounted) {
        showAlertMessage(context, "Error", "Invalid word list");
        setState(() {
          processing = false;
        });
      }
      return;
    }
    String accessKeyHex = bip39.mnemonicToEntropy(words);
    Uint8List accessKeyBytes = hexToBytes(accessKeyHex);

    String masterKeyCipheredBase64 = widget.cipherData["cipher"];
    String masterKeyNonceBase64 = widget.cipherData["nonce"];

    Uint8List masterKeyCipheredBytes = base64Decode(masterKeyCipheredBase64);
    Uint8List masterKeyNonceBytes = base64Decode(masterKeyNonceBase64);
    ExecutionResult masterKeyDecryptionResult = cryptoUtils.decryptBytes(
        cipherBytes: masterKeyCipheredBytes,
        nonce: masterKeyNonceBytes,
        key: accessKeyBytes);
    if (masterKeyDecryptionResult.isFailure) {
      if (mounted) {
        showAlertMessage(context, "Failure", "Invalid access key");
      }
    } else {
      Uint8List decryptedMasterKeyBytes =
          masterKeyDecryptionResult.getResult()!["decrypted"];
      String decryptedMasterKeyBase64 = base64Encode(decryptedMasterKeyBytes);

      String userId = widget.cipherData["id"];
      String keyForMasterKey = '${userId}_mk';
      String keyForAccessKey = '${userId}_ak';
      String keyForKeyType = '${userId}_kt';
      // save keys to secure storage
      await secureStorage.write(
          key: keyForMasterKey, value: decryptedMasterKeyBase64);
      await secureStorage.write(
          key: keyForAccessKey, value: base64Encode(accessKeyBytes));
      await secureStorage.write(key: keyForKeyType, value: "key");
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
        widget.setShowHidePage!(PageType.accessKeyInput, false, PageParams());
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

  /// Handles file selection and validation
  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );
      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        if (_validateWordCount(content)) {
          setState(() {
            _loadedFileContent = content.trim();
          });
          _processWords(_loadedFileContent);
        } else {
          if (mounted) {
            showAlertMessage(context, "Error",
                'The file does not contain exactly 24 words.');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        displaySnackBar(context, message: "Error reading file", seconds: 2);
      }
    }
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
                      PageType.accessKeyInput, false, PageParams());
                },
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Text Widget
                Text(
                  "Please enter your 24-word recovery phrase or load a .txt file containing it.",
                  style: TextStyle(fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),

                // TextField with Validation
                TextFormField(
                  controller: _textController,
                  autofocus: true,
                  maxLines: null, // Allows all words to be visible
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Enter your 24-word phrase',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your recovery phrase here',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your recovery phrase';
                    }
                    if (!_validateWordCount(value)) {
                      return 'Recovery phrase must contain exactly 24 words';
                    }
                    return null;
                  },
                  onEditingComplete: () {
                    _processWords(_textController.text);
                  },
                ),
                SizedBox(height: 20.0),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _processWords(_textController.text);
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

                // Separator Line
                Row(
                  children: [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Or',
                        style: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                SizedBox(height: 20.0),

                // File Upload Button
                ElevatedButton.icon(
                  onPressed: _selectFile,
                  icon: Icon(
                    LucideIcons.upload,
                    color: Colors.black,
                  ),
                  label: Text(
                    "Select .txt File",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

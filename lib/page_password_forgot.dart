import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/page_password.dart';
import 'package:ntsapp/utils_crypto.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';

class PageForgotPassword extends StatefulWidget {
  final Map<String, dynamic> profileData;
  const PageForgotPassword({super.key, required this.profileData});

  @override
  State<PageForgotPassword> createState() => _PageForgotPasswordState();
}

class _PageForgotPasswordState extends State<PageForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  String _loadedFileContent = '';
  AndroidOptions getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );
  late FlutterSecureStorage storage;

  @override
  void initState() {
    super.initState();
    storage = FlutterSecureStorage(aOptions: getAndroidOptions());
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Validates input to ensure it contains exactly 24 words
  bool _validateWordCount(String input) {
    final words = input.trim().split(RegExp(r'\s+'));
    return words.length == 24;
  }

  /// Processes the validated 24 words further
  Future<void> _processWords(String words) async {
    SodiumSumo sodium = await SodiumSumoInit.init();
    CryptoUtils cryptoUtils = CryptoUtils(sodium);

    String recoveryKeyHex = bip39.mnemonicToEntropy(words);
    Uint8List recoveryKeyBytes = hexToBytes(recoveryKeyHex);

    String userId = widget.profileData["id"];
    String keyForMasterKey = '${userId}_mk';
    String keyForRecoveryKey = '${userId}_rk';

    String? masterKeyEncryptedWithRecoveryKeyBase64 =
        widget.profileData["mk_ew_rk"];
    String? masterKeyRecoveryKeyNonceBase64 = widget.profileData["mk_rk_nonce"];

    if (masterKeyEncryptedWithRecoveryKeyBase64 != null &&
        masterKeyRecoveryKeyNonceBase64 != null) {
      Uint8List masterKeyEncryptedWithRecoveryKeyBytes =
          base64Decode(masterKeyEncryptedWithRecoveryKeyBase64);
      Uint8List masterKeyRecoveryKeyNonce =
          base64Decode(masterKeyRecoveryKeyNonceBase64);
      ExecutionResult masterKeyDecryptionResult = cryptoUtils.decryptBytes(
          cipherBytes: masterKeyEncryptedWithRecoveryKeyBytes,
          nonce: masterKeyRecoveryKeyNonce,
          key: recoveryKeyBytes);
      if (masterKeyDecryptionResult.isFailure) {
        if (mounted) {
          showAlertMessage(context, "Failure", "Invalid recovery key");
        }
      } else {
        Uint8List decryptedMasterKeyBytes =
            masterKeyDecryptionResult.getResult()!["decrypted"];
        String decryptedMasterKeyBase64 = base64Encode(decryptedMasterKeyBytes);

        // save keys to secure storage
        await storage.write(
            key: keyForMasterKey, value: decryptedMasterKeyBase64);
        await storage.write(
            key: keyForRecoveryKey, value: base64Encode(recoveryKeyBytes));

        // navigate to password change
        navigateToPasswordReset();
      }
    }
  }

  void navigateToPasswordReset() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PagePassword(
          isChangingPassword: true,
        ),
        settings: const RouteSettings(name: "Change Password"),
      ),
    );
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('The file does not contain exactly 24 words.')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forget Password'),
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
                maxLines: null, // Allows all words to be visible
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
              ),
              SizedBox(height: 20.0),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _processWords(_textController.text.trim());
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(fontSize: 16.0),
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
                icon: Icon(Icons.upload_file),
                label: Text("Select .txt File"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

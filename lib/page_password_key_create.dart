import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:ntsapp/utils_crypto.dart';
import 'package:ntsapp/utils_sync.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PagePasswordKeyCreate extends StatefulWidget {
  final bool recreate;
  const PagePasswordKeyCreate({
    super.key,
    required this.recreate,
  });

  @override
  State<PagePasswordKeyCreate> createState() => _PagePasswordKeyCreateState();
}

class _PagePasswordKeyCreateState extends State<PagePasswordKeyCreate> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _passwordCopyController = TextEditingController();
  SupabaseClient supabaseClient = Supabase.instance.client;
  SecureStorage secureStorage = SecureStorage();
  bool processing = false;

  bool hasMinOneWord = false;
  bool hasMinTwoUppercase = false;
  bool hasMinTwoLowercase = false;
  bool hasMinTwoDigits = false;
  bool hasMinTwoSpecialChars = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      setState(() {
        hasMinOneWord = false;
      });
      return 'Please enter key';
    }
    setState(() {
      List<String> words = password.trim().split(RegExp(r'\s+'));
      hasMinOneWord = words.isNotEmpty && words[0].isNotEmpty;
      hasMinTwoUppercase = RegExp(r'[A-Z]').allMatches(password).length >= 2;
      hasMinTwoLowercase = RegExp(r'[a-z]').allMatches(password).length >= 2;
      hasMinTwoDigits = RegExp(r'\d').allMatches(password).length >= 2;
      hasMinTwoSpecialChars =
          RegExp(r'[!@#\$%^&*(),.?":{}|<>]').allMatches(password).length >= 2;
    });
    if (!hasMinOneWord ||
        !hasMinTwoUppercase ||
        !hasMinTwoLowercase ||
        !hasMinTwoDigits ||
        !hasMinTwoSpecialChars) {
      return '';
    }
    return null;
  }

  /// Processes the validated 24 words further
  Future<void> _submitForm(String password) async {
    SodiumSumo sodium = await SodiumSumoInit.init();
    CryptoUtils cryptoUtils = CryptoUtils(sodium);
    String? userId = SyncUtils.getSignedInUserId();
    if (userId == null) {
      return;
    }
    setState(() {
      processing = true;
    });
    String keyForMasterKey = '${userId}_mk';
    String keyForKeyType = '${userId}_kt';
    Uint8List? masterKeyBytes;
    if (widget.recreate) {
      String? masterKeyBase64 = await secureStorage.read(key: keyForMasterKey);
      masterKeyBytes =
          masterKeyBase64 == null ? null : base64Decode(masterKeyBase64);
    }
    ExecutionResult generationResult = await cryptoUtils
        .generatePasswordKeys(password, masterKeyBytes: masterKeyBytes);
    if (generationResult.isSuccess) {
      Map<String, dynamic> passwordKeys = generationResult.getResult()!;
      Map<String, dynamic> serverKeys = passwordKeys["server_keys"];
      serverKeys["id"] = userId;
      // save keys to server
      try {
        await supabaseClient.from("keys").upsert(serverKeys).eq("id", userId);
        // save locally

        String masterKeyBase64 = passwordKeys["private_keys"]["master_key"];
        await secureStorage.write(key: keyForMasterKey, value: masterKeyBase64);
        await secureStorage.write(key: keyForKeyType, value: "password");
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        debugPrint(e.toString());
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
        title: Text('Encryption key'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                    "Please enter a long and hard to guess key (password). Remember to save it somewhere safe. If it lost/forgotten, it can not be recovered."),
                SizedBox(
                  height: 40,
                ),
                TextFormField(
                  controller: _passwordController,
                  maxLines: null, // Allows all words to be visible
                  decoration: InputDecoration(
                    labelText: 'Enter key',
                    border: OutlineInputBorder(),
                    hintText: 'Enter key',
                  ),
                  validator: (value) {
                    return _validatePassword(value);
                  },
                  onChanged: (value) {
                    _validatePassword(value);
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordCopyController,
                  maxLines: null, // Allows all words to be visible
                  decoration: InputDecoration(
                    labelText: 'Enter key again',
                    border: OutlineInputBorder(),
                    hintText: 'Enter key again',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter key again';
                    }
                    if (value != _passwordController.text) {
                      return 'Keys do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildRuleItem("At least one word", hasMinOneWord),
                _buildRuleItem(
                    "At least 2 uppercase letters", hasMinTwoUppercase),
                _buildRuleItem(
                    "At least 2 lowercase letters", hasMinTwoLowercase),
                _buildRuleItem("At least 2 numeric letters", hasMinTwoDigits),
                _buildRuleItem(
                    "At least 2 special characters", hasMinTwoSpecialChars),
                SizedBox(height: 20.0),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _submitForm(_passwordController.text.trim());
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
      ),
    );
  }

  Widget _buildRuleItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
              fontSize: 16, color: isValid ? Colors.green : Colors.red),
        ),
      ],
    );
  }
}

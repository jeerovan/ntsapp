import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/page_plan_status.dart';
import 'package:ntsapp/storage_hive.dart';
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

  bool hasTenChars = false;
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasDigits = false;
  bool hasSpecialChars = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  bool _checkForSequences(String input) {
    bool found = false;

    // Check for sequences of 3+ consecutive letters or numbers
    for (int i = 0; i < input.length - 2; i++) {
      // Check numeric sequences (123, 234, etc.)
      if (isNumeric(input[i]) &&
          isNumeric(input[i + 1]) &&
          isNumeric(input[i + 2])) {
        int first = int.parse(input[i]);
        int second = int.parse(input[i + 1]);
        int third = int.parse(input[i + 2]);

        if ((second == first + 1 && third == second + 1) ||
            (second == first - 1 && third == second - 1)) {
          found = true;
          break;
        }
      }

      // Check alphabetical sequences (abc, xyz, etc.)
      if (isLetter(input[i]) &&
          isLetter(input[i + 1]) &&
          isLetter(input[i + 2])) {
        int first = input[i].toLowerCase().codeUnitAt(0);
        int second = input[i + 1].toLowerCase().codeUnitAt(0);
        int third = input[i + 2].toLowerCase().codeUnitAt(0);

        if ((second == first + 1 && third == second + 1) ||
            (second == first - 1 && third == second - 1)) {
          found = true;
          break;
        }
      }
    }

    return found;
  }

  bool isNumeric(String s) {
    return s.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
        s.codeUnitAt(0) <= '9'.codeUnitAt(0);
  }

  bool isLetter(String s) {
    var code = s.toLowerCase().codeUnitAt(0);
    return code >= 'a'.codeUnitAt(0) && code <= 'z'.codeUnitAt(0);
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      setState(() {
        hasTenChars = false;
        hasUppercase = false;
        hasLowercase = false;
        hasDigits = false;
        hasSpecialChars = false;
      });
      return 'Please enter key';
    }
    setState(() {
      hasTenChars = password.replaceAll(' ', '').length >= 10;
      hasUppercase = RegExp(r'[A-Z]').allMatches(password).isNotEmpty;
      hasLowercase = RegExp(r'[a-z]').allMatches(password).isNotEmpty;
      hasDigits = RegExp(r'\d').allMatches(password).isNotEmpty;
      hasSpecialChars =
          RegExp(r'[!@#\$%^&*(),.?":{}|<>]').allMatches(password).isNotEmpty;
    });
    if (!hasTenChars ||
        !hasUppercase ||
        !hasLowercase ||
        !hasDigits ||
        !hasSpecialChars) {
      return '';
    }
    if (_checkForSequences(password)) {
      return 'Sequence not accepted';
    }
    if (password == 'I would love 2 have @ll ...' ||
        password == '(A6r4K4D46r4)' ||
        password == 'Mykey@2025' ||
        password == 'C0ffee !s great f0r pr0ductivity') {
      return 'Examples not accepted';
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
        if (!StorageHive().get(AppString.pushedLocalContentForSync.string,
            defaultValue: false)) {
          await SyncUtils.pushLocalChanges();
        }
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PagePlanStatus(),
            ),
          );
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    setState(() {
      processing = false;
    });
  }

  void _showExamplesPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Examples'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('I would love 2 have @ll ...'),
            Divider(),
            Text('(A6r4K4D46r4)'),
            Divider(),
            Text('Mykey@2025'),
            Divider(),
            Text('C0ffee !s great f0r pr0ductivity'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
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
                    suffixIcon: IconButton(
                      icon: Icon(Icons.info_outline),
                      tooltip: 'See examples',
                      onPressed: () {
                        _showExamplesPopup(context);
                      },
                    ),
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
                _buildRuleItem("1 uppercase letter", hasUppercase),
                _buildRuleItem("1 lowercase letter", hasLowercase),
                _buildRuleItem("1 numeric letter", hasDigits),
                _buildRuleItem("1 special character", hasSpecialChars),
                _buildRuleItem("min 10 characters", hasTenChars),
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
            size: 16.0, color: isValid ? Colors.green : Colors.red),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
              fontSize: 12, color: isValid ? Colors.green : Colors.red),
        ),
      ],
    );
  }
}

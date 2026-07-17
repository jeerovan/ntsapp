import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ntsapp/l10n/app_localizations.dart';
import 'package:ntsapp/utils/common.dart';
import 'package:ntsapp/utils/enums.dart';
import 'package:ntsapp/ui/pages/page_plan_status.dart';
import 'package:ntsapp/ui/pages/page_user_task.dart';
import 'package:ntsapp/storage/storage_secure.dart';
import 'package:ntsapp/utils/utils_crypto.dart';
import 'package:ntsapp/utils/utils_sync.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../common_widgets.dart';
import '../../models/model_preferences.dart';

class PagePasswordKeyCreate extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  final bool recreate;
  const PagePasswordKeyCreate({
    super.key,
    required this.recreate,
    required this.runningOnDesktop,
    this.setShowHidePage,
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
    final loc = AppLocalizations.of(context)!;
    if (password == null || password.isEmpty) {
      setState(() {
        hasTenChars = false;
        hasUppercase = false;
        hasLowercase = false;
        hasDigits = false;
        hasSpecialChars = false;
      });
      return loc.pleaseEnterKey;
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
      return loc.sequenceNotAcceptedError;
    }
    if (password == loc.passwordExample1 ||
        password == loc.passwordExample2 ||
        password == loc.passwordExample3 ||
        password == loc.passwordExample4) {
      return loc.examplesNotAcceptedError;
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
    String keyForAccessKey = '${userId}_ak';
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
        if (simulateOnboarding()) {
          await ModelPreferences.set(
              AppString.debugCipherData.string, jsonEncode(serverKeys));
        } else {
          await supabaseClient.from("keys").upsert(serverKeys).eq("id", userId);
        }
        // save locally
        String masterKeyBase64 = passwordKeys["private_keys"]["master_key"];
        await secureStorage.write(key: keyForMasterKey, value: masterKeyBase64);
        await secureStorage.write(
            key: keyForAccessKey,
            value: base64Encode(
                utf8.encode(password))); // used for testing simulation
        await secureStorage.write(key: keyForKeyType, value: "password");
        bool pushedLocalContent = await ModelPreferences.get(
                AppString.pushedLocalContentForSync.string,
                defaultValue: "no") ==
            "yes";
        if (!pushedLocalContent) {
          SyncUtils.pushLocalChanges();
        }
        if (mounted) {
          if (widget.runningOnDesktop) {
            if (pushedLocalContent) {
              widget.setShowHidePage!(PageType.planStatus, true, PageParams());
            } else {
              widget.setShowHidePage!(PageType.userTask, true,
                  PageParams(appTask: AppTask.pushLocalContent));
            }
            widget.setShowHidePage!(
                PageType.passwordCreate, false, PageParams());
          } else {
            Navigator.of(context).pushReplacement(
              AnimatedPageRoute(
                child: pushedLocalContent
                    ? PagePlanStatus(
                        runningOnDesktop: widget.runningOnDesktop,
                        setShowHidePage: widget.setShowHidePage,
                      )
                    : PageUserTask(
                        task: AppTask.pushLocalContent,
                        runningOnDesktop: widget.runningOnDesktop,
                        setShowHidePage: widget.setShowHidePage,
                      ),
              ),
            );
          }
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
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.examplesTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.passwordExample1),
            const Divider(),
            Text(loc.passwordExample2),
            const Divider(),
            Text(loc.passwordExample3),
            const Divider(),
            Text(loc.passwordExample4),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.gotItButtonLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.encryptionKeyTitle),
        leading: widget.runningOnDesktop
            ? BackButton(
                onPressed: () {
                  widget.setShowHidePage!(
                      PageType.passwordCreate, false, PageParams());
                },
              )
            : null,
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
                    loc.createKeyDescription),
                SizedBox(
                  height: 40,
                ),
                TextFormField(
                  controller: _passwordController,
                  autofocus: true,
                  maxLines: null, // Allows all words to be visible
                  decoration: InputDecoration(
                    labelText: loc.enterKeyLabel,
                    border: OutlineInputBorder(),
                    hintText: loc.enterKeyLabel,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.info_outline),
                      tooltip: loc.seeExamplesTooltip,
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
                    labelText: loc.enterKeyAgainLabel,
                    border: OutlineInputBorder(),
                    hintText: loc.enterKeyAgainLabel,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return loc.pleaseEnterKeyAgainError;
                    }
                    if (value != _passwordController.text) {
                      return loc.keysDoNotMatchError;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildRuleItem(loc.ruleUppercaseLetter, hasUppercase),
                _buildRuleItem(loc.ruleLowercaseLetter, hasLowercase),
                _buildRuleItem(loc.ruleNumericLetter, hasDigits),
                _buildRuleItem(loc.ruleSpecialCharacter, hasSpecialChars),
                _buildRuleItem(loc.ruleMinTenCharacters, hasTenChars),
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
                              color: Colors.black,
                              strokeWidth: 2, // Set color to white
                            ),
                          ),
                        ),
                      Text(
                        loc.submitLabel,
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

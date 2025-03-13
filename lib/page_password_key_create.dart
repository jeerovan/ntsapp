import 'package:flutter/material.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:ntsapp/utils_crypto.dart';
import 'package:ntsapp/utils_sync.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PagePasswordKeyCreate extends StatefulWidget {
  const PagePasswordKeyCreate({
    super.key,
  });

  @override
  State<PagePasswordKeyCreate> createState() => _PagePasswordKeyCreateState();
}

class _PagePasswordKeyCreateState extends State<PagePasswordKeyCreate> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _passwordCopyController = TextEditingController();
  SupabaseClient supabaseClient = Supabase.instance.client;
  SecureStorage storage = SecureStorage();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  /// Processes the validated 24 words further
  Future<void> _submitForm(String password) async {
    SodiumSumo sodium = await SodiumSumoInit.init();
    CryptoUtils cryptoUtils = CryptoUtils(sodium);
    String? userId = SyncUtils.getSignedInUserId();
    if (userId == null) {
      return;
    }
    ExecutionResult generationResult =
        await cryptoUtils.generatePasswordKeys(password);
    if (generationResult.isSuccess) {
      Map<String, dynamic> passwordKeys = generationResult.getResult()!;
      Map<String, dynamic> serverKeys = passwordKeys["server_keys"];
      serverKeys["id"] = userId;
      // save keys to server
      await supabaseClient.from("keys").upsert(serverKeys).eq("id", userId);
      // save locally
      String keyForMasterKey = '${userId}_mk';
      String keyForKeyType = '${userId}_kt';
      String masterKeyBase64 = passwordKeys["private_keys"]["master_key"];
      await storage.write(key: keyForMasterKey, value: masterKeyBase64);
      await storage.write(key: keyForKeyType, value: "password");
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Encryption key'),
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
              TextFormField(
                controller: _passwordController,
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
              SizedBox(height: 20.0),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitForm(_passwordController.text.trim());
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
            ],
          ),
        ),
      ),
    );
  }
}

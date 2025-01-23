import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/utils_crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'page_recovery_key.dart';

class PagePassword extends StatefulWidget {
  const PagePassword({super.key});

  @override
  State<PagePassword> createState() => _PagePasswordState();
}

class _PagePasswordState extends State<PagePassword> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool fetchedFromSupabase = false;
  bool processingPassword = false;
  Map<String, dynamic>? profileData;

  @override
  void initState() {
    super.initState();
    fetchFromSupabase();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> fetchFromSupabase() async {
    User? user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      String userId = user.id;
      final List<Map<String, dynamic>> data = await Supabase.instance.client
          .from("profiles")
          .select()
          .eq('id', userId);
      profileData = data.first;
      setState(() {
        fetchedFromSupabase = true;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (mounted) {
        setState(() {
          processingPassword = true;
        });
      }

      String password = _passwordController.text.trim();

      SodiumSumo sodium = await SodiumSumoInit.init();
      CryptoUtils cryptoUtils = CryptoUtils(sodium);
      ExecutionResult result =
          await cryptoUtils.updateGenerateKeys(password, profileData!);
      if (result.isFailure) {
        if (mounted) {
          showAlertMessage(context, "Error", result.failureReason!);
        }
      } else {
        final SharedPreferencesAsync preferencesAsync =
            SharedPreferencesAsync();
        await preferencesAsync.setBool("can_sync", true);

        bool generated = result.getResult()!["generated"];
        if (generated) {
          // show recovery key page
          Uint8List recoveryKeyBytes = result.getResult()!["recovery_key"];
          String recoveryKeyHex = bytesToHex(recoveryKeyBytes);
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => PageRecoveryKey(
                  recoveryKeyHex: recoveryKeyHex,
                ),
                settings: const RouteSettings(name: "Page Recovery Key"),
              ),
            );
          }
        } else {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        }
      }
      if (mounted) {
        setState(() {
          processingPassword = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fetchedFromSupabase ? 'Encryption Password' : 'Synching'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: fetchedFromSupabase && !processingPassword
            ? Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),

                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        } else if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.0),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submit,
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
                  ],
                ),
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

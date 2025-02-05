import 'package:flutter/material.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/page_access_key_input.dart';
import 'package:ntsapp/utils_crypto.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'page_access_key.dart';

class PagePassword extends StatefulWidget {
  final bool isChangingPassword;
  const PagePassword({super.key, this.isChangingPassword = false});
  @override
  State<PagePassword> createState() => _PagePasswordState();
}

class _PagePasswordState extends State<PagePassword> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;
  String? userId;
  bool fetchedFromSupabase = false;
  bool processingPassword = false;
  bool hasMasterKeyCipher = false;
  bool showForgotPassword = false;
  bool changingPassword = false;
  bool errorFetchingProfiles = false;
  bool errorUpdatingProfiles = false;
  bool showRecoveryKeyPageAfterGeneratingKeys = false;
  Map<String, dynamic>? profileData;
  Map<String, dynamic>? updatedProfilesData;
  @override
  void initState() {
    super.initState();
    changingPassword = widget.isChangingPassword;
    debugPrint("Changing Password:$changingPassword");
    User? user = supabase.auth.currentUser;
    if (user != null) {
      userId = user.id;
    }
    if (!changingPassword) {
      fetchFromSupabase();
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> fetchFromSupabase() async {
    setState(() {
      errorFetchingProfiles = false;
    });
    try {
      if (userId != null) {
        final List<Map<String, dynamic>> data =
            await supabase.from("profiles").select().eq('id', userId!);
        profileData = data.first;
        setState(() {
          fetchedFromSupabase = true;
        });
        hasMasterKeyCipher = profileData!["mk_ew_rk"] != null;
        errorFetchingProfiles = false;
        debugPrint("Fetched profile from supabase");
      }
    } catch (e) {
      setState(() {
        errorFetchingProfiles = true;
      });
      debugPrint("Error fetching profiles");
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
      if (changingPassword) {
        ExecutionResult result =
            await cryptoUtils.generateKeysForNewPassword(password, userId!);
        updatedProfilesData = result.getResult()!["keys"];
        pushUpdatesToSupabase();
      } else {
        ExecutionResult result =
            await cryptoUtils.updateGenerateKeys(password, profileData!);
        if (result.isFailure) {
          if (mounted) {
            showAlertMessage(context, "Error", result.failureReason!);
          }
          showForgotPassword = true;
        } else {
          bool generated = result.getResult()!["generated"];
          if (generated) {
            updatedProfilesData = result.getResult()!["keys"];
            showRecoveryKeyPageAfterGeneratingKeys = true;
            pushUpdatesToSupabase();
          } else {
            if (mounted) {
              Navigator.of(context).pop(true);
            }
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

  Future<void> pushUpdatesToSupabase() async {
    setState(() {
      processingPassword = true;
    });
    try {
      await supabase
          .from("profiles")
          .update(updatedProfilesData!)
          .eq('id', userId!);
      if (showRecoveryKeyPageAfterGeneratingKeys) {
        navigateToRecoveryKeyPage();
      } else {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      errorUpdatingProfiles = true;
    }
    setState(() {
      processingPassword = false;
    });
  }

  void navigateToForgotPassword() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PageAccessKeyInput(
          profileData: profileData!,
        ),
        settings: const RouteSettings(name: "Forgot Password"),
      ),
    );
  }

  void navigateToRecoveryKeyPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PageAccessKey(),
        settings: const RouteSettings(name: "RecoveryKey"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(processingPassword
            ? 'Synching'
            : changingPassword
                ? 'Change password'
                : 'Encryption password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: errorFetchingProfiles && !changingPassword
            ? Center(
                child: Column(
                  children: [
                    Text("Could not fetch data"),
                    SizedBox(
                      height: 24,
                    ),
                    ElevatedButton(
                        onPressed: fetchFromSupabase, child: Text("Retry"))
                  ],
                ),
              )
            : errorUpdatingProfiles
                ? Center(
                    child: Column(
                      children: [
                        Text("Could not update"),
                        SizedBox(
                          height: 24,
                        ),
                        ElevatedButton(
                            onPressed: pushUpdatesToSupabase,
                            child: Text("Retry"))
                      ],
                    ),
                  )
                : processingPassword ||
                        (!fetchedFromSupabase && !changingPassword)
                    ? Center(child: CircularProgressIndicator())
                    : Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                padding: EdgeInsets.all(16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                changingPassword ? 'Change' : 'Submit',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                            SizedBox(height: 24.0),
                            // Forget Password Button
                            if (hasMasterKeyCipher &&
                                showForgotPassword &&
                                !changingPassword)
                              ElevatedButton(
                                onPressed: navigateToForgotPassword,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.all(16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                          ],
                        ),
                      ),
      ),
    );
  }
}

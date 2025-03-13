import 'package:flutter/material.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/model_category.dart';
import 'package:ntsapp/model_profile.dart';
import 'package:ntsapp/page_access_key_input.dart';
import 'package:ntsapp/page_password_key_input.dart';
import 'package:ntsapp/page_select_key_type.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:ntsapp/storage_hive.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:ntsapp/utils_sync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'enums.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final logger = AppLogger(prefixes: ["page_signin"]);
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  SecureStorage storage = SecureStorage();
  bool processing = false;
  bool otpSent = false;
  bool canResend = false;
  bool errorSendingOtp = false;
  bool errorVerifyingOtp = false;
  String email =
      StorageHive().get(AppString.otpSentTo.string, defaultValue: "");
  final SupabaseClient supabase = Supabase.instance.client;
  bool signedIn = false;
  bool canSync = false;

  @override
  void initState() {
    super.initState();
    if (supabase.auth.currentSession == null) {
      int sentOtpAt =
          StorageHive().get(AppString.otpSentAt.string, defaultValue: 0);
      int nowUtc = DateTime.now().toUtc().millisecondsSinceEpoch;
      if (nowUtc - sentOtpAt < 900000) {
        otpSent = true;
      }
    } else {
      signedIn = true;
    }
    checkIfReadyToSync();
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    super.dispose();
  }

  Future<void> checkIfReadyToSync() async {
    User? user = supabase.auth.currentUser;
    if (user != null) {
      String userId = user.id;
      String keyForMasterKey = '${userId}_mk';

      bool hasMasterKeyCipher = await storage.containsKey(key: keyForMasterKey);
      setState(() {
        canSync = hasMasterKeyCipher;
      });
    }
  }

  // OTP expire after 15min
  Future<void> sendOtp() async {
    if (processing) return;
    email = emailController.text;
    if (email.isNotEmpty) {
      setState(() {
        processing = true;
      });
      try {
        await supabase.auth.signInWithOtp(
          email: email,
        );
        int nowUtc = DateTime.now().toUtc().millisecondsSinceEpoch;
        await StorageHive().put(AppString.otpSentTo.string, email);
        await StorageHive().put(AppString.otpSentAt.string, nowUtc);
        setState(() {
          otpSent = true;
        });
        errorSendingOtp = false;
      } catch (e, s) {
        logger.error("sendOTP", error: e, stackTrace: s);
        errorSendingOtp = true;
        if (mounted) {
          displaySnackBar(context,
              message: 'Sending OTP failed. Please try again!', seconds: 2);
        }
      }
      setState(() {
        processing = false;
      });
    }
  }

  // cases: First time, Re-login
  Future<void> verifyOtp() async {
    if (processing) return;
    final otp = otpController.text;
    final String email =
        StorageHive().get(AppString.otpSentTo.string, defaultValue: "");
    if (email.isNotEmpty && otp.isNotEmpty) {
      setState(() {
        processing = true;
      });
      try {
        AuthResponse response = await supabase.auth
            .verifyOTP(email: email, token: otp, type: OtpType.email);
        Session? session = response.session;
        if (session != null) {
          await StorageHive().delete(AppString.otpSentTo.string);
          await StorageHive().delete(AppString.otpSentAt.string);
          User user = session.user;
          ModelProfile profile =
              await ModelProfile.fromMap({"id": user.id, "email": user.email!});
          // if exists, update no fields.
          await profile.upcertChangeFromServer();
          // associate existing categories with this profile if not already associated
          await ModelCategory.associateWithProfile(user.id);
          await navigateAfterSignin();
        }
        errorVerifyingOtp = false;
      } catch (e, s) {
        logger.error("verifyOtp", error: e, stackTrace: s);
        errorVerifyingOtp = true;
        if (mounted) {
          displaySnackBar(context,
              message: 'OTP verification failed. Please try again!',
              seconds: 2);
        }
      }
      setState(() {
        processing = false;
      });
    }
  }

  Future<void> navigateAfterSignin() async {
    String? userId = SyncUtils.getSignedInUserId();
    if (userId == null) return;
    //check where to navigate
    try {
      final List<Map<String, dynamic>> keyRows =
          await supabase.from("keys").select().eq("id", userId);
      if (keyRows.isEmpty) {
        navigateToKeySelectPage();
      } else if (mounted) {
        Map<String, dynamic> keyRow = keyRows.first;
        if (keyRow["salt"] != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PagePasswordKeyInput(
                cipherData: keyRow,
              ),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PageAccessKeyInput(
                cipherData: keyRow,
              ),
            ),
          );
        }
      }
    } catch (e, s) {
      logger.error("navigateAfterSignin", error: e, stackTrace: s);
    }
    // TODO If sync is enabled, ready local data to be pushed if not already done
    //SyncUtils.pushLocalChanges(); // no wait
  }

  Future<void> changeEmail() async {
    await StorageHive().delete(AppString.otpSentTo.string);
    await StorageHive().delete(AppString.otpSentAt.string);
    setState(() {
      otpSent = false;
    });
  }

  Future<void> signOut() async {
    try {
      String? userId = SyncUtils.getSignedInUserId();
      if (userId != null) {
        await supabase.auth.signOut();
        String keyForMasterKey = '${userId}_mk';
        String keyForAccessKey = '{$userId}_ak';
        String keyForPasswordKey = '{$userId}_pk';
        String keyForKeyType = '${userId}_kt';
        await storage.delete(key: keyForMasterKey);
        await storage.delete(key: keyForAccessKey);
        await storage.delete(key: keyForKeyType);
        await storage.delete(key: keyForPasswordKey);
      }
      setState(() {
        signedIn = false;
      });
    } catch (e, s) {
      logger.error("signOut", error: e, stackTrace: s);
    }
  }

  void navigateToKeySelectPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PageSelectKeyType(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(otpSent ? 'Verify OTP' : 'Email SignIn')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (!signedIn && !otpSent)
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Enter Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
              SizedBox(height: 20),
              if (!signedIn && !otpSent)
                ElevatedButton(
                    onPressed: sendOtp,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (processing)
                          Padding(
                            padding: const EdgeInsets.only(
                                right:
                                    8.0), // Add spacing between indicator and text
                            child: SizedBox(
                              width:
                                  16, // Set width and height for the indicator
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, // Set color to white
                              ),
                            ),
                          ),
                        Text(errorSendingOtp ? 'Retry' : 'Send OTP'),
                      ],
                    )),
              SizedBox(
                height: 40,
              ),
              if (!signedIn && otpSent)
                Text(
                    "We have sent a one-time password (OTP) to your email $email"),
              SizedBox(height: 20),
              if (!signedIn && otpSent)
                TextField(
                  controller: otpController,
                  decoration: InputDecoration(labelText: 'Enter OTP'),
                  keyboardType: TextInputType.number,
                ),
              SizedBox(height: 20),
              if (!signedIn && otpSent)
                ElevatedButton(
                    onPressed: verifyOtp,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
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
                      Text(errorVerifyingOtp ? 'Retry' : 'Verify OTP')
                    ])),
              Expanded(
                child: SizedBox(
                  height: 20,
                ),
              ),
              if (!signedIn && otpSent)
                TextButton(onPressed: changeEmail, child: Text('Change email')),
              SizedBox(
                height: 20,
              ),
              if (signedIn)
                TextButton(onPressed: signOut, child: Text('Sign Out')),
              SizedBox(
                height: 20,
              ),
              if (signedIn)
                TextButton(
                    onPressed: navigateAfterSignin,
                    child: Text('After Sign In')),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

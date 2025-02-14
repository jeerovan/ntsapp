import 'package:flutter/material.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/model_category.dart';
import 'package:ntsapp/model_profile.dart';
import 'package:ntsapp/page_access_key.dart';
import 'package:ntsapp/page_checks.dart';
import 'package:ntsapp/page_dummy.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:ntsapp/storage_hive.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:ntsapp/supa_db_explorer.dart';
import 'package:ntsapp/utils_sync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'enums.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final logger = AppLogger(prefixes: ["page_signing"]);
  final emailController = TextEditingController();
  final otpController = TextEditingController();

  bool otpSent = false;
  bool canResend = false;
  bool errorSendingOtop = false;
  bool errorVerifyingOtp = false;
  String email =
      StorageHive().get(AppString.otpSentTo.string, defaultValue: "");
  final SupabaseClient supabase = Supabase.instance.client;
  bool signedIn = Supabase.instance.client.auth.currentSession != null;
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
    }
    init();
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    super.dispose();
  }

  Future<void> init() async {
    User? user = supabase.auth.currentUser;
    if (user != null) {
      String userId = user.id;
      String keyForMasterKey = '${userId}_mk';

      SecureStorage storage = SecureStorage();
      bool hasMasterKeyCipher = await storage.containsKey(key: keyForMasterKey);
      setState(() {
        canSync = hasMasterKeyCipher;
      });
    }
  }

  // TODO have a resend OTP option with a timer to expire otpSent
  // New OTP should be sent after five minute. they expire after 15min

  Future<void> sendOtp() async {
    email = emailController.text;
    if (email.isNotEmpty) {
      try {
        // Sends a magic link/OTP to the user's email
        await supabase.auth.signInWithOtp(
          email: email,
        );
        int nowUtc = DateTime.now().toUtc().millisecondsSinceEpoch;
        await StorageHive().put(AppString.otpSentTo.string, email);
        await StorageHive().put(AppString.otpSentAt.string, nowUtc);
        setState(() {
          otpSent = true;
        });
        errorSendingOtop = false;
      } catch (e, s) {
        logger.error("sendOTP", error: e, stackTrace: s);
        errorSendingOtop = true;
        if (mounted) {
          displaySnackBar(context,
              message: 'Sending OTP failed. Please try again!', seconds: 2);
        }
      }
    }
  }

  // cases: First time, Re-login
  Future<void> verifyOtp() async {
    final otp = otpController.text;
    final String email =
        StorageHive().get(AppString.otpSentTo.string, defaultValue: "");
    if (email.isNotEmpty && otp.isNotEmpty) {
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
          // If sync is enabled, ready local data to be pushed if not already done
          // TODO uncomment
          //SyncUtils.pushLocalChanges(); // no wait
          navigateToChecksPage();
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
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      setState(() {
        signedIn = false;
      });
    } catch (e, s) {
      logger.error("signOut", error: e, stackTrace: s);
    }
  }

  void navigateToChecksPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PageChecks(
          task: AppTask.checkForKeys,
        ),
      ),
    );
  }

  void navigateToAccessPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PageAccessKey(),
      ),
    );
  }

  void navigateToDummyPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PageDummy(),
      ),
    );
  }

  void navigateToSupaDbPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SupaDatabaseExplorer(),
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
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
              SizedBox(height: 20),
              if (!signedIn && !otpSent)
                ElevatedButton(
                    onPressed: sendOtp,
                    child: Text(errorSendingOtop ? 'Retry' : 'Send OTP')),
              SizedBox(
                height: 40,
              ),
              if (!signedIn && otpSent)
                TextField(
                  controller: otpController,
                  decoration: InputDecoration(labelText: 'OTP'),
                ),
              SizedBox(height: 20),
              if (!signedIn && otpSent)
                ElevatedButton(
                    onPressed: verifyOtp,
                    child: Text(errorVerifyingOtp ? 'Retry' : 'Verify OTP')),
              SizedBox(
                height: 20,
              ),
              if (signedIn)
                ElevatedButton(onPressed: signOut, child: Text('Sign Out')),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: navigateToChecksPage, child: Text('Checks Page')),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: navigateToDummyPage, child: Text('Dummy Page')),
              SizedBox(
                height: 20,
              ),
              if (canSync)
                ElevatedButton(
                    onPressed: navigateToAccessPage, child: Text('Access Key')),
              SizedBox(
                height: 20,
              ),
              if (canSync)
                ElevatedButton(
                    onPressed: navigateToSupaDbPage, child: Text('SupaDb')),
            ],
          ),
        ),
      ),
    );
  }
}

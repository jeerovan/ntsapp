import 'package:flutter/material.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/model_setting.dart';
import 'package:ntsapp/page_access_key.dart';
import 'package:ntsapp/page_checks.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'enums.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final emailController = TextEditingController();
  final otpController = TextEditingController();

  bool otpSent = false;
  bool canResend = false;
  bool errorSendingOtop = false;
  bool errorVerifyingOtp = false;
  String email = ModelSetting.getForKey("otp_sent_to", "");
  final SupabaseClient supabase = Supabase.instance.client;
  bool signedIn = Supabase.instance.client.auth.currentSession != null;
  bool canSync = false;

  @override
  void initState() {
    super.initState();
    if (supabase.auth.currentSession == null) {
      String sentAtStr = ModelSetting.getForKey("otp_sent_at", "0");
      int sentAt = int.parse(sentAtStr);
      int nowUtc = DateTime.now().toUtc().millisecondsSinceEpoch;
      if (nowUtc - sentAt < 900000) {
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
        debugPrint('OTP sent to $email');
        int nowUtc = DateTime.now().toUtc().millisecondsSinceEpoch;
        ModelSetting.update("otp_sent_to", email);
        ModelSetting.update("otp_sent_at", nowUtc.toString());
        setState(() {
          otpSent = true;
        });
        errorSendingOtop = false;
      } catch (e) {
        errorSendingOtop = true;
        debugPrint('Error sending OTP: $e');
        if (mounted) {
          displaySnackBar(context,
              message: 'Sending OTP failed. Please try again!', seconds: 2);
        }
      }
    }
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text;
    final String email = ModelSetting.getForKey("otp_sent_to", "");
    if (email.isNotEmpty && otp.isNotEmpty) {
      try {
        AuthResponse response = await supabase.auth
            .verifyOTP(email: email, token: otp, type: OtpType.email);
        Session? session = response.session;
        if (session != null) {
          navigateToChecksPage();
        }
        errorVerifyingOtp = false;
      } catch (e) {
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
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void navigateToChecksPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PageChecks(
          task: Task.checkForKeys,
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
              if (canSync)
                ElevatedButton(
                    onPressed: navigateToAccessPage, child: Text('Access Key')),
            ],
          ),
        ),
      ),
    );
  }
}

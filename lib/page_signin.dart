import 'package:flutter/material.dart';
import 'package:ntsapp/model_setting.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  String email = ModelSetting.getForKey("otp_sent_to", "");
  final SupabaseClient supabase = Supabase.instance.client;
  bool signedIn = Supabase.instance.client.auth.currentSession != null;

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
  }
  // TODO have a resend OTP option with a timer to expire otpSent
  // OTP can be sent after one minute and they expire after 15min

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
      } catch (e) {
        debugPrint('Error sending OTP: $e');
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
          setState(() {
            signedIn = true;
          });
        }
      } catch (e) {
        debugPrint(e.toString());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(otpSent ? 'Verify OTP' : 'Email SignIn')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!signedIn && !otpSent)
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            SizedBox(height: 20),
            if (!signedIn && !otpSent)
              ElevatedButton(onPressed: sendOtp, child: Text('Send OTP')),
            SizedBox(
              height: 40,
            ),
            if (!signedIn && otpSent)
              TextField(
                controller: otpController,
                decoration: InputDecoration(labelText: 'OTP'),
                keyboardType: TextInputType.emailAddress,
              ),
            SizedBox(height: 20),
            if (!signedIn && otpSent)
              ElevatedButton(onPressed: verifyOtp, child: Text('Verify OTP')),
            SizedBox(
              height: 20,
            ),
            if (signedIn)
              ElevatedButton(onPressed: signOut, child: Text('Sign Out')),
          ],
        ),
      ),
    );
  }
}

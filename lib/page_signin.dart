import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/model_category.dart';
import 'package:ntsapp/model_profile.dart';
import 'package:ntsapp/page_user_task.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:ntsapp/storage_hive.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'enums.dart';

class PageSignin extends StatefulWidget {
  const PageSignin({super.key});

  @override
  State<PageSignin> createState() => _PageSigninState();
}

class _PageSigninState extends State<PageSignin> {
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
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    super.dispose();
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
          // assign a device Id
          String? existingDeviceId =
              StorageHive().get(AppString.deviceId.string);
          if (existingDeviceId == null) {
            String newDeviceId = Uuid().v4();
            await StorageHive().put(AppString.deviceId.string, newDeviceId);
          }
          //If subscribed to plan, associate
          if (Platform.isAndroid) {
            try {
              CustomerInfo customerInfo = await Purchases.getCustomerInfo();
              if (customerInfo.entitlements.active.isNotEmpty) {
                await Purchases.logIn(user.id);
              }
            } on PlatformException catch (e) {
              logger.error("purchaseAssociationAfterSignin", error: e);
            }
          }
          navigateToOnboardCheck();
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

  Future<void> navigateToOnboardCheck() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PageUserTask(
          task: AppTask.checkCloudSync,
        ),
      ),
    );
  }

  Future<void> changeEmail() async {
    await StorageHive().delete(AppString.otpSentTo.string);
    await StorageHive().delete(AppString.otpSentAt.string);
    setState(() {
      otpSent = false;
    });
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
                        Text(
                          errorSendingOtp ? 'Retry' : 'Send OTP',
                          style: TextStyle(color: Colors.black),
                        ),
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
                      Text(
                        errorVerifyingOtp ? 'Retry' : 'Verify OTP',
                        style: TextStyle(color: Colors.black),
                      )
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
            ],
          ),
        ),
      ),
    );
  }
}

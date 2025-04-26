import 'package:flutter/material.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/model_preferences.dart';
import 'package:ntsapp/page_user_task.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:ntsapp/storage_hive.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'common.dart';
import 'enums.dart';

class PageSignin extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  const PageSignin(
      {super.key, required this.runningOnDesktop, this.setShowHidePage});

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
  int debugExceptionCount = 0;

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

  // OTP expire after 5min
  Future<void> sendOtp(String text) async {
    if (processing) return;
    email = text.trim();
    if (email.isNotEmpty) {
      setState(() {
        processing = true;
      });
      try {
        if (isDebugEnabled()) {
          await Future.delayed(const Duration(seconds: 1));
          if (debugExceptionCount == 0) {
            debugExceptionCount = 1;
            throw Exception("Debug SignIn Exception");
          }
        } else {
          await supabase.auth.signInWithOtp(
            email: email,
          );
        }
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
  Future<void> verifyOtp(String text) async {
    if (processing) return;
    final otp = text.trim();
    final String email =
        StorageHive().get(AppString.otpSentTo.string, defaultValue: "");
    if (email.isNotEmpty && otp.isNotEmpty) {
      setState(() {
        processing = true;
      });
      try {
        Session? session;
        if (isDebugEnabled()) {
          await Future.delayed(const Duration(seconds: 1));
          if (debugExceptionCount == 1) {
            debugExceptionCount = 2;
            throw Exception("Debug OTP Exception");
          }
        } else {
          AuthResponse response = await supabase.auth
              .verifyOTP(email: email, token: otp, type: OtpType.email);
          session = response.session;
        }
        if (session != null || isDebugEnabled()) {
          await StorageHive().delete(AppString.otpSentTo.string);
          await StorageHive().delete(AppString.otpSentAt.string);
          // assign a device Id
          String? existingDeviceId =
              await ModelPreferences.get(AppString.deviceId.string);
          if (existingDeviceId == null) {
            String newDeviceId = Uuid().v4();
            await ModelPreferences.set(AppString.deviceId.string, newDeviceId);
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
    if (widget.runningOnDesktop) {
      widget.setShowHidePage!(
          PageType.userTask, true, PageParams(appTask: AppTask.checkCloudSync));
      widget.setShowHidePage!(PageType.signIn, false, PageParams());
    } else {
      Navigator.of(context).pushReplacement(
        AnimatedPageRoute(
          child: PageUserTask(
            runningOnDesktop: widget.runningOnDesktop,
            setShowHidePage: widget.setShowHidePage,
            task: AppTask.checkCloudSync,
          ),
        ),
      );
    }
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
      appBar: AppBar(
        title: Text(otpSent ? 'Verify OTP' : 'Email SignIn'),
        leading: widget.runningOnDesktop
            ? BackButton(
                onPressed: () {
                  widget.setShowHidePage!(PageType.signIn, false, PageParams());
                },
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (!signedIn && !otpSent)
                TextField(
                  autofocus: true,
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Enter Email'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: sendOtp,
                ),
              SizedBox(height: 20),
              if (!signedIn && !otpSent)
                ElevatedButton(
                    onPressed: () {
                      sendOtp(emailController.text);
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
                              width:
                                  16, // Set width and height for the indicator
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.black,
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
                  autofocus: true,
                  controller: otpController,
                  decoration: InputDecoration(labelText: 'Enter OTP'),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onSubmitted: verifyOtp,
                ),
              SizedBox(height: 20),
              if (!signedIn && otpSent)
                ElevatedButton(
                    onPressed: () {
                      verifyOtp(otpController.text);
                    },
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
                              color: Colors.black,
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

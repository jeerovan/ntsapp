import 'package:flutter/material.dart';
import 'package:ntsapp/ui/common_widgets.dart';
import 'package:ntsapp/models/model_preferences.dart';
import 'package:ntsapp/models/model_setting.dart';
import 'package:ntsapp/ui/pages/page_user_task.dart';
import 'package:ntsapp/services/service_logger.dart';
import 'package:ntsapp/storage/storage_secure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../utils/common.dart';
import '../../utils/enums.dart';

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
  String email = ModelSetting.get(AppString.otpSentTo.string, "");
  final SupabaseClient supabase = Supabase.instance.client;
  bool signedIn = false;

  @override
  void initState() {
    super.initState();
    if (supabase.auth.currentSession == null) {
      int sentOtpAt =
          int.parse(ModelSetting.get(AppString.otpSentAt.string, 0).toString());
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
        if (email == 'tester@notesafe.app') {
          await Future.delayed(const Duration(seconds: 1));
          await ModelSetting.set(AppString.simulateTesting.string, "yes");
        } else {
          await supabase.auth.signInWithOtp(
            email: email,
          );
        }
        int nowUtc = DateTime.now().toUtc().millisecondsSinceEpoch;
        await ModelSetting.set(AppString.otpSentTo.string, email);
        await ModelSetting.set(AppString.otpSentAt.string, nowUtc);
        otpSent = true;
        errorSendingOtp = false;
      } catch (e, s) {
        logger.error("sendOTP", error: e, stackTrace: s);
        errorSendingOtp = true;
        if (mounted) {
          displaySnackBar(context,
              message: 'Sending OTP failed. Please try again!', seconds: 2);
        }
      }
      if (mounted) {
        setState(() {
          processing = false;
        });
      }
    }
  }

  // cases: First time, Re-login
  Future<void> verifyOtp(String text) async {
    if (processing) return;
    final otp = text.trim();
    final String email = ModelSetting.get(AppString.otpSentTo.string, "");
    if (email.isNotEmpty && otp.isNotEmpty) {
      setState(() {
        processing = true;
      });
      try {
        Session? session;
        if (simulateOnboarding()) {
          if (await ModelPreferences.get(AppString.dataSeeded.string,
                  defaultValue: "no") ==
              "no") {
            await seedGroupsAndNotes();
            await signalToUpdateHome(); // update home with data
          }
        } else {
          AuthResponse response = await supabase.auth
              .verifyOTP(email: email, token: otp, type: OtpType.email);
          session = response.session;
        }
        if (session != null || simulateOnboarding()) {
          await ModelSetting.delete(AppString.otpSentTo.string);
          await ModelSetting.delete(AppString.otpSentAt.string);
          String? existingDeviceId =
              await ModelPreferences.get(AppString.deviceId.string);
          if (existingDeviceId == null) {
            String newDeviceId = Uuid().v4();
            await ModelPreferences.set(AppString.deviceId.string, newDeviceId);
          }
          await ModelSetting.set(
              AppString.signedIn.string, "yes"); // used for simulation
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
      if (mounted) {
        setState(() {
          processing = false;
        });
      }
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
    await ModelSetting.delete(AppString.otpSentTo.string);
    await ModelSetting.delete(AppString.otpSentAt.string);
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

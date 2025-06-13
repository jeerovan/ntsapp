import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/model_preferences.dart';
import 'package:ntsapp/model_setting.dart';
import 'package:ntsapp/page_plan_subscribe.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'common_widgets.dart';
import 'model_category.dart';
import 'model_profile.dart';
import 'page_access_key_input.dart';
import 'page_devices.dart';
import 'page_password_key_input.dart';
import 'page_select_key_type.dart';
import 'page_signin.dart';
import 'utils_sync.dart';

class PageUserTask extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  final AppTask task;
  const PageUserTask(
      {super.key,
      required this.task,
      required this.runningOnDesktop,
      this.setShowHidePage});

  @override
  State<PageUserTask> createState() => _PageUserTaskState();
}

class _PageUserTaskState extends State<PageUserTask> {
  final logger = AppLogger(prefixes: ["page_onboard_task"]);
  bool processing = true;
  SupabaseClient supabaseClient = Supabase.instance.client;

  SecureStorage secureStorage = SecureStorage();

  String taskTitle = "";
  String displayMessage = "";
  String buttonText = "";

  // keys checks
  bool fetchedFromSupabase = false;
  bool errorFetching = false;
  bool errorUpdating = false;
  bool deviceLimitExceeded = false;
  bool userIdMismatch = false;
  Map<String, dynamic>? updatedData;

  Session? currentSession = Supabase.instance.client.auth.currentSession;

  @override
  void initState() {
    super.initState();
    switch (widget.task) {
      case AppTask.registerDevice:
        registerDevice();
        break;
      case AppTask.checkEncryptionKeys:
        checkEncryptionKeys();
        break;
      case AppTask.checkCloudSync:
        checkCloudSync();
        break;
      case AppTask.signOut:
        signOut();
        break;
      case AppTask.pushLocalContent:
        pushLocalContent();
        break;
    }
  }

  Future<void> pushLocalContent() async {
    setState(() {
      taskTitle = "Encrypting notes";
      processing = true;
    });
    Timer.periodic(Duration(seconds: 1), (timer) async {
      bool pushedLocalContent = await ModelPreferences.get(
              AppString.pushedLocalContentForSync.string,
              defaultValue: "no") ==
          "yes";
      if (pushedLocalContent) {
        timer.cancel();
        if (widget.runningOnDesktop) {
          widget.setShowHidePage!(PageType.userTask, false, PageParams());
        } else if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  Future<void> checkCloudSync() async {
    setState(() {
      taskTitle = "Fetching details";
      processing = true;
      errorFetching = false;
    });
    bool hasSubscriptionPlan = false;
    bool hasValidPlan = false;
    String rcId = "";
    // check signed in
    bool signedIn = simulateOnboarding()
        ? ModelSetting.get(AppString.signedIn.string, "no") == "yes"
        : currentSession != null;
    String? userId = SyncUtils.getSignedInUserId();
    if (signedIn) {
      if (userId != null && !simulateOnboarding()) {
        try {
          final planResponse = await supabaseClient
              .from("plans")
              .select("expires_at,rc_id")
              .eq("user_id", userId)
              .order("expires_at", ascending: false) // Get the latest plan
              .limit(1) // Ensure only one row is returned
              .maybeSingle();
          if (planResponse != null) {
            int expiresAt = int.parse(planResponse["expires_at"].toString());
            int now = DateTime.now().toUtc().millisecondsSinceEpoch;
            if (expiresAt > now) {
              hasValidPlan = true;
              rcId = planResponse["rc_id"];
              await ModelPreferences.set(AppString.hasValidPlan.string, "yes");
            } else {
              logger.info("User signed-in but no valid plan");
            }
          }
        } catch (e) {
          logger.error("Error Fetching Plan:", error: e);
        }
        if (revenueCatSupported && hasValidPlan) {
          LogInResult loginResult = await Purchases.logIn(rcId);
          hasSubscriptionPlan = true;
          logger.info("Has valid plan:${loginResult.customerInfo.toString()}");
        }
      }
    } else {
      logger.info("Not signed-in");
    }
    // check plan in rc
    if (revenueCatSupported && !hasValidPlan) {
      String? savedPlanRcId = await ModelPreferences.get(
          AppString.planRcId.string); // set only after a purchase
      try {
        CustomerInfo customerInfo = await Purchases.getCustomerInfo();
        if (savedPlanRcId != null &&
            savedPlanRcId != customerInfo.originalAppUserId) {
          logger.warning("Purchase:PurchaserId and CustomerId do not match");
          LogInResult logInResult = await Purchases.logIn(savedPlanRcId);
          if (logInResult.customerInfo.entitlements.active.isNotEmpty) {
            hasSubscriptionPlan = true;
            rcId = savedPlanRcId;
            await ModelPreferences.set(AppString.hasValidPlan.string, "yes");
            logger.info(
                "Purchaser has subscription plan:${logInResult.customerInfo.toString()}");
          }
        } else if (customerInfo.entitlements.active.isNotEmpty) {
          hasSubscriptionPlan = true;
          rcId = customerInfo.originalAppUserId;
          await ModelPreferences.set(AppString.hasValidPlan.string, "yes");
          logger.info(
              "Customer has subscription plan:${customerInfo.toString()}");
        }
      } on PlatformException catch (e) {
        logger.error("checkRcPlan", error: e);
        setState(() {
          processing = false;
          errorFetching = true;
          displayMessage = "Could not fetch";
          buttonText = "Retry";
        });
        return;
      }
    }
    // check association of rc id with supa user id
    if (hasSubscriptionPlan && signedIn) {
      try {
        logger.info("Setting userId for rcId:$rcId");
        await supabaseClient.functions
            .invoke("set_id_rc", body: {"rc_id": rcId});
        hasValidPlan = true;
      } on FunctionException catch (e) {
        errorFetching = false;
        Map<String, dynamic> errorDetails =
            e.details is String ? jsonDecode(e.details) : e.details;
        setState(() {
          processing = false;
          displayMessage = errorDetails["error"];
          if (displayMessage.contains("mismatch")) {
            displayMessage =
                "Your subscription is associated with another email. Please sign-out and use that to enable cloud storage.";
            userIdMismatch = true;
          }
          buttonText = "Continue";
        });
        return;
      } catch (e, s) {
        logger.error("set id rc", error: e, stackTrace: s);
        setState(() {
          processing = false;
          errorFetching = true;
          displayMessage = "Error checking plan details";
          buttonText = "Retry";
        });
        return;
      }
    }
    bool deviceRegistered = await ModelPreferences.get(
            AppString.deviceRegistered.string,
            defaultValue: "no") ==
        userId;
    bool canSync = await SyncUtils.canSync();
    // set debug params
    if (simulateOnboarding()) {
      await Future.delayed(const Duration(seconds: 1));
      hasValidPlan = true;
      hasSubscriptionPlan = true;
      await ModelPreferences.set(AppString.hasValidPlan.string, "yes");
    }
    setState(() {
      processing = false;
    });
    if (revenueCatSupported && !hasSubscriptionPlan && mounted) {
      if (widget.runningOnDesktop) {
        widget.setShowHidePage!(PageType.planSubscribe, true, PageParams());
        widget.setShowHidePage!(PageType.userTask, false, PageParams());
      } else if (mounted) {
        Navigator.of(context).pushReplacement(
          AnimatedPageRoute(
            child: PagePlanSubscribe(
              runningOnDesktop: widget.runningOnDesktop,
              setShowHidePage: widget.setShowHidePage,
            ),
          ),
        );
      }
    } else if (!signedIn && mounted) {
      if (widget.runningOnDesktop) {
        widget.setShowHidePage!(PageType.signIn, true, PageParams());
        widget.setShowHidePage!(PageType.userTask, false, PageParams());
      } else {
        Navigator.of(context).pushReplacement(
          AnimatedPageRoute(
            child: PageSignin(
              runningOnDesktop: widget.runningOnDesktop,
              setShowHidePage: widget.setShowHidePage,
            ),
          ),
        );
      }
    } else if (!hasValidPlan && mounted) {
      if (widget.runningOnDesktop) {
        widget.setShowHidePage!(PageType.planSubscribe, true, PageParams());
        widget.setShowHidePage!(PageType.userTask, false, PageParams());
      } else if (mounted) {
        Navigator.of(context).pushReplacement(
          AnimatedPageRoute(
            child: PagePlanSubscribe(
              runningOnDesktop: widget.runningOnDesktop,
              setShowHidePage: widget.setShowHidePage,
            ),
          ),
        );
      }
    } else if (!deviceRegistered) {
      registerDevice();
    } else if (!canSync || simulateOnboarding()) {
      checkEncryptionKeys();
    } else if (mounted) {
      await signalToUpdateHome();
      if (mounted) {
        if (widget.runningOnDesktop) {
          widget.setShowHidePage!(PageType.userTask, false, PageParams());
        } else {
          Navigator.of(context).pop();
        }
      }
    }
  }

  Future<void> registerDevice() async {
    setState(() {
      taskTitle = "Register device";
      processing = true;
      errorFetching = false;
    });
    try {
      if (simulateOnboarding()) {
        await Future.delayed(const Duration(seconds: 1));
        await ModelPreferences.set(AppString.deviceRegistered.string, "tester");
        bool canSync = await SyncUtils.canSync();
        if (!canSync) {
          checkEncryptionKeys();
        } else if (mounted) {
          if (widget.runningOnDesktop) {
            widget.setShowHidePage!(PageType.userTask, false, PageParams());
          } else {
            Navigator.of(context).pop();
          }
        }
      } else if (currentSession != null) {
        String? deviceId =
            await ModelPreferences.get(AppString.deviceId.string);
        if (deviceId == null) {
          deviceId = Uuid().v4();
          await ModelPreferences.set(AppString.deviceId.string, deviceId);
        }
        String deviceTitle = await getDeviceName();
        String? fcmId = await ModelPreferences.get(AppString.fcmId.string);
        await supabaseClient.functions.invoke("register_device",
            body: {"deviceId": deviceId, "title": deviceTitle, "fcmId": fcmId});
        User user = currentSession!.user;
        String userId = user.id;
        await ModelPreferences.set(AppString.deviceRegistered.string, userId);
        ModelProfile profile =
            await ModelProfile.fromMap({"id": userId, "email": user.email!});
        // if exists, update no fields.
        await profile.upcertChangeFromServer();
        // associate existing categories with this profile if not already associated
        await ModelCategory.associateWithProfile(user.id);
        bool canSync = await SyncUtils.canSync();
        if (!canSync) {
          checkEncryptionKeys();
        } else if (mounted) {
          if (widget.runningOnDesktop) {
            widget.setShowHidePage!(PageType.userTask, false, PageParams());
          } else {
            Navigator.of(context).pop();
          }
        }
      }
    } on FunctionException catch (e) {
      errorFetching = false;
      Map<String, dynamic> errorDetails =
          e.details is String ? jsonDecode(e.details) : e.details;
      displayMessage = errorDetails["error"];
      buttonText = "Continue";
      if (displayMessage.contains("limit")) {
        deviceLimitExceeded = true;
        buttonText = "Manage";
      }
    } catch (e, s) {
      logger.error("registerDevice", error: e, stackTrace: s);
      setState(() {
        errorFetching = true;
        displayMessage = "Could not fetch";
        buttonText = "Retry";
      });
    }
    setState(() {
      processing = false;
    });
  }

  Future<void> checkEncryptionKeys() async {
    setState(() {
      taskTitle = "Fetching Keys";
      processing = true;
      errorFetching = false;
    });
    if (simulateOnboarding()) {
      await Future.delayed(const Duration(seconds: 1));
    }
    String? userId = SyncUtils.getSignedInUserId();
    if (userId == null && !simulateOnboarding()) return;
    //check where to navigate
    try {
      List<Map<String, dynamic>> keyRows = [];
      if (simulateOnboarding()) {
        if (await ModelPreferences.get(AppString.hasEncryptionKeys.string,
                defaultValue: "no") ==
            "yes") {
          keyRows = [
            jsonDecode(
                await ModelPreferences.get(AppString.debugCipherData.string))
          ];
        }
      } else {
        keyRows = await supabaseClient.from("keys").select().eq("id", userId!);
      }
      if (keyRows.isEmpty && mounted) {
        if (widget.runningOnDesktop) {
          widget.setShowHidePage!(PageType.selectKeyType, true, PageParams());
          widget.setShowHidePage!(PageType.userTask, false, PageParams());
        } else {
          Navigator.of(context).pushReplacement(
            AnimatedPageRoute(
              child: PageSelectKeyType(
                runningOnDesktop: widget.runningOnDesktop,
                setShowHidePage: widget.setShowHidePage,
              ),
            ),
          );
        }
      } else if (mounted) {
        Map<String, dynamic> keyRow = keyRows.first;
        if (keyRow["salt"] != null) {
          if (widget.runningOnDesktop) {
            widget.setShowHidePage!(
                PageType.passwordInput, true, PageParams(cipherData: keyRow));
            widget.setShowHidePage!(PageType.userTask, false, PageParams());
          } else {
            Navigator.of(context).pushReplacement(
              AnimatedPageRoute(
                child: PagePasswordKeyInput(
                  runningOnDesktop: widget.runningOnDesktop,
                  setShowHidePage: widget.setShowHidePage,
                  cipherData: keyRow,
                ),
              ),
            );
          }
        } else {
          if (widget.runningOnDesktop) {
            widget.setShowHidePage!(
                PageType.accessKeyInput, true, PageParams(cipherData: keyRow));
            widget.setShowHidePage!(PageType.userTask, false, PageParams());
          } else {
            Navigator.of(context).pushReplacement(
              AnimatedPageRoute(
                child: PageAccessKeyInput(
                  cipherData: keyRow,
                  runningOnDesktop: widget.runningOnDesktop,
                  setShowHidePage: widget.setShowHidePage,
                ),
              ),
            );
          }
        }
      }
    } catch (e, s) {
      logger.error("navigateAfterRegistering", error: e, stackTrace: s);
      setState(() {
        errorFetching = true;
        displayMessage = "Could not fetch";
        buttonText = "Retry";
      });
    }
    setState(() {
      processing = false;
    });
  }

  Future<void> signOut() async {
    setState(() {
      processing = true;
      errorFetching = false;
      taskTitle = "Signing out";
    });
    // check internet
    bool hasInternet = await hasInternetConnection();
    if (!hasInternet && mounted) {
      setState(() {
        errorFetching = true;
        processing = false;
        displayMessage = "Please check internet";
        buttonText = "Retry";
      });
    }
    bool success = await SyncUtils.signout();
    if (success && mounted) {
      if (widget.runningOnDesktop) {
        widget.setShowHidePage!(PageType.userTask, false, PageParams());
        widget.setShowHidePage!(PageType.planStatus, false, PageParams());
      } else {
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        errorFetching = true;
        processing = false;
        displayMessage = "Something went wrong";
        buttonText = "Retry";
      });
    }
  }

  Future<void> takeAction() async {
    if (errorFetching) {
      displayMessage = "";
      buttonText = "";
      switch (widget.task) {
        case AppTask.registerDevice:
          registerDevice();
          break;
        case AppTask.checkEncryptionKeys:
          checkEncryptionKeys();
          break;
        case AppTask.checkCloudSync:
          checkCloudSync();
          break;
        case AppTask.signOut:
          break;
        case AppTask.pushLocalContent:
          break;
      }
    } else if (deviceLimitExceeded) {
      if (widget.runningOnDesktop) {
        widget.setShowHidePage!(PageType.devices, true, PageParams());
        widget.setShowHidePage!(PageType.userTask, false, PageParams());
      } else {
        Navigator.of(context).pushReplacement(
          AnimatedPageRoute(
            child: PageDevices(
              runningOnDesktop: widget.runningOnDesktop,
              setShowHidePage: widget.setShowHidePage,
            ),
          ),
        );
      }
    } else if (userIdMismatch) {
      await supabaseClient.auth.signOut();
      if (widget.runningOnDesktop) {
        widget.setShowHidePage!(PageType.userTask, false, PageParams());
      } else {
        if (mounted) Navigator.of(context).pop();
      }
    } else if (displayMessage.isNotEmpty) {
      if (widget.runningOnDesktop) {
        widget.setShowHidePage!(PageType.userTask, false, PageParams());
      } else {
        if (mounted) Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(taskTitle),
          leading: widget.runningOnDesktop
              ? BackButton(
                  onPressed: () {
                    widget.setShowHidePage!(
                        PageType.userTask, false, PageParams());
                  },
                )
              : null,
        ),
        body: processing
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        displayMessage,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    buttonText.isEmpty
                        ? const SizedBox.shrink()
                        : ElevatedButton(
                            onPressed: takeAction,
                            child: Text(
                              buttonText,
                              style: TextStyle(color: Colors.black),
                            ))
                  ],
                ),
              ));
  }
}

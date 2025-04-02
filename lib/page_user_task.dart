import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/page_plan_subscribe.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:ntsapp/storage_hive.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'page_access_key_input.dart';
import 'page_devices.dart';
import 'page_password_key_input.dart';
import 'page_select_key_type.dart';
import 'page_signin.dart';
import 'utils_sync.dart';

class PageUserTask extends StatefulWidget {
  final AppTask task;
  const PageUserTask({super.key, required this.task});

  @override
  State<PageUserTask> createState() => _PageUserTaskState();
}

class _PageUserTaskState extends State<PageUserTask> {
  final logger = AppLogger(prefixes: ["page_onboard_task"]);
  bool processing = true;
  bool revenueCatSupported =
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  final SupabaseClient supabase = Supabase.instance.client;

  SecureStorage secureStorage = SecureStorage();

  late String taskTitle;
  String displayMessage = "";
  String buttonText = "";

  // keys checks
  bool fetchedFromSupabase = false;
  bool errorFetching = false;
  bool errorUpdating = false;
  bool deviceLimitExceeded = false;
  Map<String, dynamic>? updatedData;
  String? userId;

  @override
  void initState() {
    super.initState();
    User? user = supabase.auth.currentUser;
    if (user != null) {
      userId = user.id;
    }
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
    }
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
    bool signedIn =
        StorageHive().get(AppString.deviceId.string, defaultValue: null) !=
            null;
    if (signedIn) {
      String? userId = SyncUtils.getSignedInUserId();
      if (userId != null) {
        try {
          final planResponse = await supabase
              .from("plans")
              .select("expires_at")
              .eq("user_id", userId)
              .order("expires_at", ascending: false) // Get the latest plan
              .limit(1) // Ensure only one row is returned
              .maybeSingle();
          int expiresAt = int.parse(planResponse!["expires_at"].toString());
          int now = DateTime.now().toUtc().millisecondsSinceEpoch;
          if (expiresAt > now) {
            hasValidPlan = true;
          }
        } catch (e) {
          logger.error("Error Fetching Plan:", error: e);
        }
        if (revenueCatSupported) {
          LogInResult loginResult = await Purchases.logIn(userId);
          logger.info(loginResult.customerInfo.toString());
        }
      }
    }
    // check plan in rc
    if (revenueCatSupported) {
      try {
        CustomerInfo customerInfo = await Purchases.getCustomerInfo();
        if (customerInfo.entitlements.active.isNotEmpty) {
          hasSubscriptionPlan = true;
          rcId = customerInfo.originalAppUserId;
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
    if (hasSubscriptionPlan && rcId.isNotEmpty && signedIn) {
      try {
        await supabase.functions.invoke("set_id_rc", body: {"rc_id": rcId});
      } on FunctionException catch (e) {
        errorFetching = false;
        Map<String, dynamic> errorDetails =
            e.details is String ? jsonDecode(e.details) : e.details;
        setState(() {
          processing = false;
          displayMessage = errorDetails["error"];
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
    bool deviceRegistered = StorageHive()
        .get(AppString.deviceRegistered.string, defaultValue: false);
    bool canSync = await SyncUtils.canSync();
    setState(() {
      processing = false;
    });
    if (revenueCatSupported && !hasSubscriptionPlan && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PagePlanSubscribe(),
        ),
      );
    } else if (!signedIn && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PageSignin(),
        ),
      );
    } else if (!hasValidPlan && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PagePlanSubscribe(),
        ),
      );
    } else if (!deviceRegistered) {
      registerDevice();
    } else if (!canSync) {
      checkEncryptionKeys();
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> registerDevice() async {
    setState(() {
      taskTitle = "Register device";
      processing = true;
      errorFetching = false;
    });
    try {
      if (userId != null) {
        String deviceId = StorageHive().get(AppString.deviceId.string);
        String deviceTitle = await getDeviceName();
        await supabase.functions.invoke("register_device",
            body: {"deviceId": deviceId, "title": deviceTitle});
        await StorageHive().put(AppString.deviceRegistered.string, true);
        bool canSync = await SyncUtils.canSync();
        if (!canSync) {
          checkEncryptionKeys();
        } else if (mounted) {
          Navigator.of(context).pop();
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
    String? userId = SyncUtils.getSignedInUserId();
    if (userId == null) return;
    //check where to navigate
    try {
      final List<Map<String, dynamic>> keyRows =
          await supabase.from("keys").select().eq("id", userId);
      if (keyRows.isEmpty && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PageSelectKeyType(),
          ),
        );
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
      Navigator.of(context).pop();
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
      }
    } else if (deviceLimitExceeded) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PageDevices(),
        ),
      );
    } else if (displayMessage.isNotEmpty) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(taskTitle),
        ),
        body: processing
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Column(
                  children: [
                    Text(
                      displayMessage,
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
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

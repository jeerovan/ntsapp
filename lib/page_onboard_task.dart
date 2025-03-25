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
import 'page_password_key_input.dart';
import 'page_select_key_type.dart';
import 'page_signin.dart';
import 'utils_sync.dart';

class PageOnBoardTask extends StatefulWidget {
  final AppTask task;
  const PageOnBoardTask({super.key, required this.task});

  @override
  State<PageOnBoardTask> createState() => _PageOnBoardTaskState();
}

class _PageOnBoardTaskState extends State<PageOnBoardTask> {
  final logger = AppLogger(prefixes: ["page_onboard_task"]);
  bool processing = true;
  final SupabaseClient supabase = Supabase.instance.client;

  SecureStorage secureStorage = SecureStorage();

  late String taskTitle;
  String displayMessage = "";
  String buttonText = "";

  // keys checks
  bool fetchedFromSupabase = false;
  bool errorFetching = false;
  bool errorUpdating = false;
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
    }
  }

  Future<void> checkCloudSync() async {
    setState(() {
      taskTitle = "Onboarding";
      processing = true;
      errorFetching = false;
    });
    bool hasPlanInRC = false;
    // check payments
    if (Platform.isAndroid) {
      try {
        CustomerInfo customerInfo = await Purchases.getCustomerInfo();
        logger.info(customerInfo.toString());
        if (customerInfo.entitlements.active.isNotEmpty) {
          hasPlanInRC = true;
        }
      } on PlatformException catch (e) {
        logger.error("checkPlan", error: e);
        setState(() {
          processing = false;
          errorFetching = true;
          displayMessage = "Could not fetch";
          buttonText = "Retry";
        });
        return;
      }
    } else {
      // TODO add support for other platforms
      hasPlanInRC = true;
    }
    setState(() {
      processing = false;
    });
    // check signed in
    bool signedIn =
        StorageHive().get(AppString.deviceId.string, defaultValue: null) !=
            null;
    bool deviceRegistered = StorageHive()
        .get(AppString.deviceRegistered.string, defaultValue: false);
    bool canSync = await SyncUtils.canSync();
    if (!hasPlanInRC && mounted) {
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
      displayMessage = jsonDecode(e.details)["error"];
      buttonText = "Continue";
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
      }
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
                    Text(displayMessage),
                    SizedBox(
                      height: 24,
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

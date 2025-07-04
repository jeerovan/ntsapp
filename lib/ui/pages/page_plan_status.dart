import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/utils/common.dart';
import 'package:ntsapp/ui/common_widgets.dart';
import 'package:ntsapp/ui/pages/page_access_key.dart';
import 'package:ntsapp/ui/pages/page_devices.dart';
import 'package:ntsapp/ui/pages/page_password_key_create.dart';
import 'package:ntsapp/services/service_events.dart';
import 'package:ntsapp/services/service_logger.dart';
import 'package:ntsapp/storage/storage_secure.dart';
import 'package:ntsapp/utils/utils_sync.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/enums.dart';
import '../../models/model_preferences.dart';
import 'page_user_task.dart';

class PagePlanStatus extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  const PagePlanStatus(
      {super.key, required this.runningOnDesktop, this.setShowHidePage});
  @override
  State<PagePlanStatus> createState() => _PagePlanStatusState();
}

class _PagePlanStatusState extends State<PagePlanStatus> {
  final AppLogger logger = AppLogger(prefixes: ["Account"]);
  bool processing = true;
  bool errorFetching = false;
  int totalStorageBytes = 0;
  int usedStorageBytes = 0;
  bool hasPlan = false;
  bool planExpired = false;
  String accessKeyType = "";
  String keyManagementTitle = "";
  String? subscriptionManagementUrl;

  SupabaseClient supabaseClient = Supabase.instance.client;
  Session? currentSession = Supabase.instance.client.auth.currentSession;
  SecureStorage secureStorage = SecureStorage();
  final String? email = SyncUtils.getSignedInEmailId();
  final String? userId = SyncUtils.getSignedInUserId();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPlanDetails();
    });
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  String formatStorage(int bytes) {
    if (bytes < 1024) return "$bytes B";
    double kb = bytes / 1024;
    if (kb < 1024) return "${kb.toStringAsFixed(2)} KB";
    double mb = kb / 1024;
    if (mb < 1024) return "${mb.toStringAsFixed(2)} MB";
    double gb = mb / 1024;
    return "${gb.toStringAsFixed(2)} GB";
  }

  Future<void> fetchPlanDetails() async {
    if (currentSession == null && !simulateOnboarding()) return;
    if (mounted) {
      setState(() {
        processing = true;
        errorFetching = false;
      });
    }
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        CustomerInfo customerInfo = await Purchases.getCustomerInfo();
        subscriptionManagementUrl = customerInfo.managementURL;
      } catch (e) {
        logger.error("Error fetching customer info from purchases");
      }
    }
    String keyForKeyType = '${userId}_kt';
    String? keyType = await secureStorage.read(key: keyForKeyType);
    if (keyType != null) {
      accessKeyType = keyType;
      if (accessKeyType == "key") {
        keyManagementTitle = "View access key";
      } else {
        keyManagementTitle = "Change key password";
      }
    }
    try {
      Map<String, dynamic> usedStorageResponse = {"b2_size": 12345678};
      Map<String, dynamic>? planResponse = {
        "b2_limit": 53687091200,
        "expires_at": 1749969096241
      };
      if (!simulateOnboarding()) {
        usedStorageResponse = await supabaseClient
            .from("storage")
            .select("b2_size")
            .eq("id", userId!)
            .single(); // Fetches row

        planResponse = await supabaseClient
            .from("plans")
            .select("b2_limit,expires_at")
            .eq("user_id", userId!)
            .order("expires_at", ascending: false) // Get the latest plan
            .limit(1) // Ensure only one row is returned
            .maybeSingle();
      }

      setState(() {
        usedStorageBytes = int.parse(usedStorageResponse["b2_size"].toString());
        if (planResponse != null) {
          hasPlan = true;
          totalStorageBytes = int.parse(planResponse["b2_limit"].toString());
          totalStorageBytes = totalStorageBytes > 0 ? totalStorageBytes : 1;

          int expiresAt = int.parse(planResponse["expires_at"].toString());
          int now = DateTime.now().toUtc().millisecondsSinceEpoch;
          if (expiresAt < now) {
            planExpired = true;
          } else {}
        }
      });
      if (planExpired) {
        await ModelPreferences.set(AppString.hasValidPlan.string, "no");
      } else {
        await ModelPreferences.set(AppString.hasValidPlan.string, "yes");
      }
      EventStream().publish(AppEvent(type: EventType.checkPlanStatus));
    } catch (e) {
      errorFetching = true;
    } finally {
      processing = false;
    }
    refresh();
  }

  Future<void> signOut() async {
    if (widget.runningOnDesktop) {
      widget.setShowHidePage!(
          PageType.userTask, true, PageParams(appTask: AppTask.signOut));
    } else {
      Navigator.of(context).pushReplacement(
        AnimatedPageRoute(
          child: PageUserTask(
            runningOnDesktop: widget.runningOnDesktop,
            setShowHidePage: widget.setShowHidePage,
            task: AppTask.signOut,
          ),
        ),
      );
    }
  }

  Future<void> manageDevices() async {
    if (widget.runningOnDesktop) {
      widget.setShowHidePage!(PageType.devices, true, PageParams());
    } else {
      Navigator.of(context).push(
        AnimatedPageRoute(
          child: PageDevices(
            runningOnDesktop: widget.runningOnDesktop,
            setShowHidePage: widget.setShowHidePage,
          ),
        ),
      );
    }
  }

  Future<void> manageKey() async {
    if (accessKeyType == "key") {
      if (widget.runningOnDesktop) {
        widget.setShowHidePage!(PageType.accessKey, true, PageParams());
      } else {
        Navigator.of(context).pushReplacement(
          AnimatedPageRoute(
            child: PageAccessKey(
              runningOnDesktop: widget.runningOnDesktop,
              setShowHidePage: widget.setShowHidePage,
            ),
          ),
        );
      }
    } else {
      if (widget.runningOnDesktop) {
        widget.setShowHidePage!(
            PageType.passwordCreate, true, PageParams(recreatePassword: true));
      } else {
        Navigator.of(context).pushReplacement(
          AnimatedPageRoute(
            child: PagePasswordKeyCreate(
              runningOnDesktop: widget.runningOnDesktop,
              setShowHidePage: widget.setShowHidePage,
              recreate: true,
            ),
          ),
        );
      }
    }
  }

  Future<void> navigateToOnboardCheck() async {
    if (widget.runningOnDesktop) {
      widget.setShowHidePage!(
          PageType.userTask, true, PageParams(appTask: AppTask.checkCloudSync));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account"),
        leading: widget.runningOnDesktop
            ? BackButton(
                onPressed: () {
                  widget.setShowHidePage!(
                      PageType.planStatus, false, PageParams());
                },
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: processing
            ? Center(
                child: CircularProgressIndicator(),
              )
            : errorFetching
                ? Center(
                    child: Column(
                      children: [
                        Text(
                          "Could not fetch details",
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                            onPressed: fetchPlanDetails,
                            child: Text(
                              "Retry",
                              style: TextStyle(color: Colors.black),
                            ))
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Signed in as:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 4),
                      Text(
                        email ?? "",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Divider(height: 30),

                      // Storage Usage
                      if (hasPlan) ...[
                        Text(
                          "Storage Usage",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: usedStorageBytes / totalStorageBytes,
                          backgroundColor: Colors.grey[300],
                          color: Colors.blueAccent,
                          minHeight: 10,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${formatStorage(usedStorageBytes)} / ${formatStorage(totalStorageBytes)}",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ] else ...[
                        ListTile(
                          leading: Icon(LucideIcons.creditCard),
                          title: Text("Subscribe"),
                          onTap: navigateToOnboardCheck,
                          trailing: Icon(Icons.arrow_forward_ios, size: 18),
                        ),
                      ],
                      Divider(height: 30),

                      if (planExpired) ...[
                        ListTile(
                          leading: Icon(
                            LucideIcons.alertTriangle,
                            color: Colors.red,
                          ),
                          title: Text(
                            "Plan expired! Renew",
                          ),
                          onTap: navigateToOnboardCheck,
                          trailing: Icon(Icons.arrow_forward_ios, size: 18),
                        ),
                        Divider()
                      ],
                      // Manage Devices Button
                      ListTile(
                        leading: Icon(LucideIcons.monitorSmartphone),
                        title: Text("Manage devices"),
                        onTap: manageDevices,
                        trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      ),
                      Divider(),

                      // Key manage
                      if (accessKeyType.isNotEmpty) ...[
                        ListTile(
                          leading: Icon(LucideIcons.key),
                          title: Text(keyManagementTitle),
                          onTap: manageKey,
                          trailing: Icon(Icons.arrow_forward_ios, size: 18),
                        ),
                        Divider()
                      ],

                      // Subscription manage
                      if (subscriptionManagementUrl != null) ...[
                        ListTile(
                          leading: Icon(LucideIcons.receipt),
                          title: Text("Manage subscription"),
                          onTap: () {
                            openURL(subscriptionManagementUrl!);
                          },
                          trailing: Icon(Icons.arrow_forward_ios, size: 18),
                        ),
                        Divider()
                      ],

                      // Sign Out Button
                      ListTile(
                        leading: Icon(LucideIcons.logOut, color: Colors.red),
                        title: Text("Sign Out",
                            style: TextStyle(color: Colors.red)),
                        onTap: signOut,
                      ),
                    ],
                  ),
      ),
    );
  }
}

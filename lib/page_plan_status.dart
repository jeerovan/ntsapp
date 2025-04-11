import 'package:flutter/material.dart';
import 'package:ntsapp/page_access_key.dart';
import 'package:ntsapp/page_devices.dart';
import 'package:ntsapp/page_password_key_create.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:ntsapp/utils_sync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'enums.dart';
import 'page_user_task.dart';

class PagePlanStatus extends StatefulWidget {
  const PagePlanStatus({super.key});
  @override
  State<PagePlanStatus> createState() => _PagePlanStatusState();
}

class _PagePlanStatusState extends State<PagePlanStatus> {
  bool processing = true;
  bool errorFetching = false;
  int totalStorageBytes = 0;
  int usedStorageBytes = 0;
  String accessKeyType = "";
  String keyManagementTitle = "";

  SupabaseClient supabaseClient = Supabase.instance.client;
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
    if (userId == null) return;
    setState(() {
      processing = true;
      errorFetching = false;
    });
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
      final usedStorageResponse = await supabaseClient
          .from("storage")
          .select("b2_size")
          .eq("id", userId!)
          .single(); // Fetches row

      final totalStorageResponse = await supabaseClient
          .from("plans")
          .select("b2_limit")
          .eq("user_id", userId!)
          .order("expires_at", ascending: false) // Get the latest plan
          .limit(1) // Ensure only one row is returned
          .maybeSingle();

      setState(() {
        usedStorageBytes = int.parse(usedStorageResponse["b2_size"].toString());
        totalStorageBytes =
            int.parse(totalStorageResponse!["b2_limit"].toString());
        totalStorageBytes = totalStorageBytes > 0 ? totalStorageBytes : 1;
      });
    } catch (e) {
      setState(() {
        errorFetching = true;
      });
    } finally {
      setState(() {
        processing = false;
      });
    }
  }

  Future<void> signOut() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PageUserTask(
          task: AppTask.signOut,
        ),
      ),
    );
  }

  Future<void> manageDevices() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PageDevices(),
      ),
    );
  }

  Future<void> manageKey() async {
    if (accessKeyType == "key") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PageAccessKey(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PagePasswordKeyCreate(
            recreate: true,
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
                      Divider(height: 30),

                      // Manage Devices Button
                      ListTile(
                        leading: Icon(Icons.devices),
                        title: Text("Manage devices"),
                        onTap: manageDevices,
                        trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      ),
                      Divider(),

                      // Key manage
                      ListTile(
                        leading: Icon(Icons.key),
                        title: Text(keyManagementTitle),
                        onTap: manageKey,
                        trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      ),
                      Divider(),

                      // Sign Out Button
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.red),
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

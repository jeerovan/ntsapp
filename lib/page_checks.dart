import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/page_access_key_input.dart';
import 'package:ntsapp/utils_crypto.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'page_access_key.dart';

class PageChecks extends StatefulWidget {
  final Task task;
  const PageChecks({super.key, required this.task});

  @override
  State<PageChecks> createState() => _PageChecksState();
}

class _PageChecksState extends State<PageChecks> {
  bool processing = false;
  final SupabaseClient supabase = Supabase.instance.client;
  AndroidOptions getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );
  late FlutterSecureStorage storage;

  bool taskIsCheckForKeys = false;

  // keys checks
  bool fetchedFromSupabase = false;
  bool errorFetchingKeys = false;
  bool errorUpdatingKeys = false;
  Map<String, dynamic>? updatedKeysData;
  String? userId;

  @override
  void initState() {
    super.initState();
    User? user = supabase.auth.currentUser;
    if (user != null) {
      userId = user.id;
    }
    storage = FlutterSecureStorage(aOptions: getAndroidOptions());
    switch (widget.task) {
      case Task.checkForKeys:
        taskIsCheckForKeys = true;
        checkForKeys();
        break;
    }
  }

  Future<void> checkForKeys() async {
    setState(() {
      processing = true;
      errorFetchingKeys = false;
    });
    try {
      if (userId != null) {
        final List<Map<String, dynamic>> data =
            await supabase.from("keys").select();
        setState(() {
          fetchedFromSupabase = true;
        });

        if (data.isEmpty) {
          String keyForMasterKey = '${userId}_mk';
          String keyForAccessKey = '${userId}_ak';

          Sodium sodium = await SodiumInit.init();
          CryptoUtils cryptoUtils = CryptoUtils(sodium);

          ExecutionResult result = cryptoUtils.generateKeys();
          Map<String, dynamic> keys = result.getResult()!;
          Map<String, dynamic> privateKeys = keys["private_keys"];
          updatedKeysData = keys["server_keys"];
          updatedKeysData!['id'] = userId;

          String masterKeyBase64 = privateKeys["master_key"];
          String accessKeyBase64 = privateKeys["access_key"];
          await storage.write(key: keyForMasterKey, value: masterKeyBase64);
          await storage.write(key: keyForAccessKey, value: accessKeyBase64);
          pushUpdatedProfileToSupabase();
        } else {
          navigateToAccessKeyInputPage(data.first);
        }
      }
    } catch (e) {
      setState(() {
        errorFetchingKeys = true;
      });
      debugPrint("Error fetching profiles");
    }
    setState(() {
      processing = false;
    });
  }

  void navigateToAccessKeyInputPage(Map<String, dynamic> profileData) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PageAccessKeyInput(
          profileData: profileData,
        ),
        settings: const RouteSettings(name: "AcessKeyInput"),
      ),
    );
  }

  Future<void> pushUpdatedProfileToSupabase() async {
    setState(() {
      processing = true;
    });
    try {
      await supabase.from("keys").upsert(updatedKeysData!);
      navigateToAccessKeyPage();
    } catch (e) {
      debugPrint(e.toString());
      errorUpdatingKeys = true;
    }
    setState(() {
      processing = false;
    });
  }

  void navigateToAccessKeyPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PageAccessKey(),
        settings: const RouteSettings(name: "AcessKey"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Syncing'),
        ),
        body: processing
            ? Center(
                child: CircularProgressIndicator(),
              )
            : taskIsCheckForKeys
                ? errorFetchingKeys
                    ? Center(
                        child: Column(
                          children: [
                            Text("Could not fetch data"),
                            SizedBox(
                              height: 24,
                            ),
                            ElevatedButton(
                                onPressed: checkForKeys, child: Text("Retry"))
                          ],
                        ),
                      )
                    : const SizedBox.shrink()
                : const SizedBox.shrink());
  }
}

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

  bool taskIsCheckProfileForKeys = false;

  // profile checks
  bool fetchedFromSupabase = false;
  bool errorFetchingProfile = false;
  bool errorUpdatingProfile = false;
  Map<String, dynamic>? updatedProfileData;
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
      case Task.checkProfileForKeys:
        taskIsCheckProfileForKeys = true;
        checkProfileForKeys();
        break;
    }
  }

  Future<void> checkProfileForKeys() async {
    setState(() {
      processing = true;
      errorFetchingProfile = false;
    });
    try {
      if (userId != null) {
        final List<Map<String, dynamic>> data =
            await supabase.from("profiles").select().eq('id', userId!);
        Map<String, dynamic> profileData = data.first;
        setState(() {
          fetchedFromSupabase = true;
        });

        if (profileData["mk_ew_ak"] == null) {
          String userId = profileData["id"];
          String keyForMasterKey = '${userId}_mk';
          String keyForAccessKey = '${userId}_ak';

          Sodium sodium = await SodiumInit.init();
          CryptoUtils cryptoUtils = CryptoUtils(sodium);

          ExecutionResult result = cryptoUtils.generateKeys();
          Map<String, dynamic> keys = result.getResult()!;
          Map<String, dynamic> privateKeys = keys["private_keys"];
          updatedProfileData = keys["server_keys"];

          String masterKeyBase64 = privateKeys["master_key"];
          String accessKeyBase64 = privateKeys["access_key"];
          await storage.write(key: keyForMasterKey, value: masterKeyBase64);
          await storage.write(key: keyForAccessKey, value: accessKeyBase64);
          pushUpdatedProfileToSupabase();
        } else {
          navigateToAccessKeyInputPage(profileData);
        }
      }
    } catch (e) {
      setState(() {
        errorFetchingProfile = true;
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
      await supabase
          .from("profiles")
          .update(updatedProfileData!)
          .eq('id', userId!);
      navigateToAccessKeyPage();
    } catch (e) {
      debugPrint(e.toString());
      errorUpdatingProfile = true;
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
            : taskIsCheckProfileForKeys
                ? errorFetchingProfile
                    ? Center(
                        child: Column(
                          children: [
                            Text("Could not fetch data"),
                            SizedBox(
                              height: 24,
                            ),
                            ElevatedButton(
                                onPressed: checkProfileForKeys,
                                child: Text("Retry"))
                          ],
                        ),
                      )
                    : const SizedBox.shrink()
                : const SizedBox.shrink());
  }
}

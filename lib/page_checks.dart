import 'package:flutter/material.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/page_access_key_input.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:ntsapp/utils_crypto.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'page_access_key.dart';

class PageChecks extends StatefulWidget {
  final AppTask task;
  const PageChecks({super.key, required this.task});

  @override
  State<PageChecks> createState() => _PageChecksState();
}

class _PageChecksState extends State<PageChecks> {
  final logger = AppLogger(prefixes: ["page_checks"]);
  bool processing = false;
  final SupabaseClient supabase = Supabase.instance.client;

  SecureStorage secureStorage = SecureStorage();

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
    switch (widget.task) {
      case AppTask.checkForKeys:
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

          SodiumSumo sodium = await SodiumSumoInit.init();
          CryptoUtils cryptoUtils = CryptoUtils(sodium);

          ExecutionResult result = cryptoUtils.generateKeys();
          Map<String, dynamic> keys = result.getResult()!;
          Map<String, dynamic> privateKeys = keys["private_keys"];
          updatedKeysData = keys["server_keys"];
          updatedKeysData!['id'] = userId;

          String masterKeyBase64 = privateKeys["master_key"];
          String accessKeyBase64 = privateKeys["access_key"];
          await secureStorage.write(
              key: keyForMasterKey, value: masterKeyBase64);
          await secureStorage.write(
              key: keyForAccessKey, value: accessKeyBase64);
          pushUpdatedKeys();
        } else {
          navigateToAccessKeyInputPage(data.first);
        }
      }
    } catch (e, s) {
      logger.error("checkForKeys", error: e, stackTrace: s);
      setState(() {
        errorFetchingKeys = true;
      });
    }
    setState(() {
      processing = false;
    });
  }

  void navigateToAccessKeyInputPage(Map<String, dynamic> profileData) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PageAccessKeyInput(
          cipherData: profileData,
        ),
        settings: const RouteSettings(name: "AcessKeyInput"),
      ),
    );
  }

  Future<void> pushUpdatedKeys() async {
    setState(() {
      processing = true;
    });
    try {
      await supabase.from("keys").insert(updatedKeysData!);
      navigateToAccessKeyPage();
    } catch (e, s) {
      logger.error("pushUpdatedKeys", error: e, stackTrace: s);
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
                                onPressed: checkForKeys,
                                child: Text(
                                  "Retry",
                                  style: TextStyle(color: Colors.black),
                                ))
                          ],
                        ),
                      )
                    : const SizedBox.shrink()
                : const SizedBox.shrink());
  }
}

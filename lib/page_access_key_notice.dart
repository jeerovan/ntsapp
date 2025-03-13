import 'package:flutter/material.dart';
import 'package:ntsapp/app_config.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:ntsapp/utils_sync.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'common.dart';
import 'enums.dart';
import 'page_access_key.dart';
import 'storage_secure.dart';
import 'utils_crypto.dart';

class PageAccessKeyNotice extends StatefulWidget {
  const PageAccessKeyNotice({super.key});

  @override
  State<PageAccessKeyNotice> createState() => _PageAccessKeyNoticeState();
}

class _PageAccessKeyNoticeState extends State<PageAccessKeyNotice> {
  SupabaseClient supabaseClient = Supabase.instance.client;
  SecureStorage secureStorage = SecureStorage();
  AppLogger logger = AppLogger(prefixes: ["PageAccessKeyNotice"]);

  Future<void> generateKeys() async {
    String? userId = SyncUtils.getSignedInUserId();
    if (userId == null) return;
    SodiumSumo sodium = await SodiumSumoInit.init();
    CryptoUtils cryptoUtils = CryptoUtils(sodium);

    ExecutionResult generationResult = cryptoUtils.generateKeys();
    Map<String, dynamic> keys = generationResult.getResult()!;
    Map<String, dynamic> privateKeys = keys["private_keys"];
    Map<String, dynamic> serverKeys = keys["server_keys"];
    serverKeys['id'] = userId;
    try {
      await supabaseClient.from("keys").upsert(serverKeys).eq("id", userId);
      String keyForMasterKey = '${userId}_mk';
      String keyForAccessKey = '${userId}_ak';
      String keyForKeyType = '${userId}_kt';
      String masterKeyBase64 = privateKeys["master_key"];
      String accessKeyBase64 = privateKeys["access_key"];
      await secureStorage.write(key: keyForMasterKey, value: masterKeyBase64);
      await secureStorage.write(key: keyForAccessKey, value: accessKeyBase64);
      await secureStorage.write(key: keyForKeyType, value: "key");
      // navigate to display key
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PageAccessKey(),
            settings: const RouteSettings(name: "PageAcessKey"),
          ),
        );
      }
    } catch (e, s) {
      logger.error("generateKeys", error: e, stackTrace: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    String appName = AppConfig.get(AppString.appName.string);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Important'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'On the next page you\'ll see a series of 24 words. This is your unique and private encryption key and it is the ONLY way to recover your notes in case of logout, device loss or malfunction.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 20),
            Text(
              'It is YOUR responsibility to store it in a safe place outside of $appName app.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Handle create key for user
              },
              child: Text(
                'I understand. Show me the key.',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

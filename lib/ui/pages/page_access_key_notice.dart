import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:ntsapp/models/model_preferences.dart';
import 'package:ntsapp/services/service_logger.dart';
import 'package:ntsapp/utils/utils_sync.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/common.dart';
import '../common_widgets.dart';
import '../../utils/enums.dart';
import 'page_access_key.dart';
import '../../storage/storage_secure.dart';
import '../../utils/utils_crypto.dart';

class PageAccessKeyNotice extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  const PageAccessKeyNotice(
      {super.key, required this.runningOnDesktop, this.setShowHidePage});

  @override
  State<PageAccessKeyNotice> createState() => _PageAccessKeyNoticeState();
}

class _PageAccessKeyNoticeState extends State<PageAccessKeyNotice> {
  SupabaseClient supabaseClient = Supabase.instance.client;
  SecureStorage secureStorage = SecureStorage();
  bool processing = false;
  String? appName = "";
  AppLogger logger = AppLogger(prefixes: ["PageAccessKeyNotice"]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialize();
    });
  }

  Future<void> initialize() async {
    appName = await secureStorage.read(key: AppString.appName.string);
    setState(() {});
  }

  Future<void> generateKeys() async {
    String? userId = SyncUtils.getSignedInUserId();
    if (userId == null) return;
    setState(() {
      processing = true;
    });

    SodiumSumo sodium = await SodiumSumoInit.init();
    CryptoUtils cryptoUtils = CryptoUtils(sodium);

    ExecutionResult generationResult = cryptoUtils.generateKeys();
    Map<String, dynamic> keys = generationResult.getResult()!;
    Map<String, dynamic> privateKeys = keys["private_keys"];
    Map<String, dynamic> serverKeys = keys["server_keys"];
    serverKeys['id'] = userId;
    try {
      if (simulateOnboarding()) {
        await ModelPreferences.set(
            AppString.debugCipherData.string, jsonEncode(serverKeys));
      } else {
        await supabaseClient.from("keys").upsert(serverKeys).eq("id", userId);
      }
      String keyForMasterKey = '${userId}_mk';
      String keyForAccessKey = '${userId}_ak';
      String keyForKeyType = '${userId}_kt';
      String masterKeyBase64 = privateKeys["master_key"];
      String accessKeyBase64 = privateKeys["access_key"];
      await secureStorage.write(key: keyForMasterKey, value: masterKeyBase64);
      await secureStorage.write(key: keyForAccessKey, value: accessKeyBase64);
      await secureStorage.write(key: keyForKeyType, value: "key");
      // push local content
      bool pushedLocalContent = await ModelPreferences.get(
              AppString.pushedLocalContentForSync.string,
              defaultValue: "no") ==
          "yes";
      if (!pushedLocalContent) {
        SyncUtils.pushLocalChanges();
      }
      // navigate to display key
      if (mounted) {
        if (widget.runningOnDesktop) {
          widget.setShowHidePage!(PageType.accessKey, true, PageParams());
          widget.setShowHidePage!(
              PageType.accessKeyCreate, false, PageParams());
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
      }
    } catch (e, s) {
      logger.error("generateKeys", error: e, stackTrace: s);
    }
    setState(() {
      processing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
          title: Text(loc.importantTitle),
          leading: widget.runningOnDesktop
              ? BackButton(
                  onPressed: () {
                    widget.setShowHidePage!(
                        PageType.accessKeyCreate, false, PageParams());
                  },
                )
              : null),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    loc.accessKeyNoticeDescription1,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 20),
                  Text(
                    loc.accessKeyNoticeDescription2(appName ?? ""),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: processing ? null : generateKeys,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (processing)
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    Text(
                      loc.iUnderstandShowMeTheKey,
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

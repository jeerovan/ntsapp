import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/storage_hive.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:ntsapp/utils_crypto.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncUtils {
  // constatants
  static String keySyncProcess = "sync_process";

  static String? getSignedInUserId() {
    if (StorageHive().get("supabase_initialized")) {
      SupabaseClient supabaseClient = Supabase.instance.client;
      User? currentUser = supabaseClient.auth.currentUser;
      if (currentUser != null) {
        return currentUser.id;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<String?> getMasterKey() async {
    String? signedInUserId = getSignedInUserId();
    if (signedInUserId == null) {
      return null;
    }

    SecureStorage storage = SecureStorage();
    String keyForMasterKey = '${signedInUserId}_mk';
    String? masterKeyBase64 = await storage.read(key: keyForMasterKey);
    return masterKeyBase64;
  }

  // to sync, one must have masterKey with an active plan
  static Future<bool> canSync() async {
    String? masterKeyBase64 = await getMasterKey();
    return masterKeyBase64 != null;
  }

  static Future<void> pushChange(Map<String, dynamic> map) async {
    String? masterKeyBase64 = await getMasterKey();
    if (masterKeyBase64 != null) {
      String table = map["table"];
      SupabaseClient supabaseClient = Supabase.instance.client;
      String messageId = map['id'];
      int updatedAt = map['updated_at'];
      SodiumSumo sodium = await SodiumSumoInit.init();
      CryptoUtils cryptoUtils = CryptoUtils(sodium);
      try {
        String jsonString = jsonEncode(map);
        Uint8List jsonBytes = Uint8List.fromList(utf8.encode(jsonString));
        Uint8List masterKeyBytes = base64Decode(masterKeyBase64);
        ExecutionResult encryptionResult = cryptoUtils.encryptBytes(
            plainBytes: jsonBytes, key: masterKeyBytes);
        Uint8List cipherBytes = encryptionResult.getResult()!["encrypted"];
        Uint8List nonceBytes = encryptionResult.getResult()!["nonce"];
        String cipherBase64 = base64Encode(cipherBytes);
        String nonceBase64 = base64Encode(nonceBytes);
        Map<String, dynamic> changeMap = {
          "id": messageId,
          "updated_at": updatedAt,
          "cipher_text": cipherBase64,
          "cipher_nonce": nonceBase64,
        }; // user_id is not required for insert/update. Also doesn't take different user_id than auth_user_id
        await supabaseClient
            .from(table)
            .upsert(changeMap, onConflict: 'id')
            .eq('id', messageId)
            .gt('updated_at', updatedAt);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }
}

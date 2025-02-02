import 'package:ntsapp/storage_secure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncUtils {
  // constatants
  static String keySyncProcess = "sync_process";

  static String? getSignedInUserId() {
    SupabaseClient supabaseClient = Supabase.instance.client;
    User? currentUser = supabaseClient.auth.currentUser;
    if (currentUser != null) {
      return currentUser.id;
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

  static Future<bool> isMasterKeyAvailable() async {
    String? masterKeyBase64 = await getMasterKey();
    return masterKeyBase64 != null;
  }
}

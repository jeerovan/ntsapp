enum ItemType {
  text,
  image,
  video,
  audio,
  document,
  location,
  contact,
  date,
  task,
  completedTask,
}

extension ItemTypeExtension on ItemType {
  int get value {
    switch (this) {
      case ItemType.text:
        return 100000;
      case ItemType.image:
        return 110000;
      case ItemType.video:
        return 120000;
      case ItemType.audio:
        return 130000;
      case ItemType.document:
        return 140000;
      case ItemType.location:
        return 150000;
      case ItemType.contact:
        return 160000;
      case ItemType.date:
        return 170000;
      case ItemType.task:
        return 180000;
      case ItemType.completedTask:
        return 180010;
    }
  }

  static ItemType? fromValue(int value) {
    switch (value) {
      case 100000:
        return ItemType.text;
      case 110000:
        return ItemType.image;
      case 120000:
        return ItemType.video;
      case 130000:
        return ItemType.audio;
      case 140000:
        return ItemType.document;
      case 150000:
        return ItemType.location;
      case 160000:
        return ItemType.contact;
      case 170000:
        return ItemType.date;
      case 180000:
        return ItemType.task;
      case 180010:
        return ItemType.completedTask;
      default:
        return null;
    }
  }
}

enum ExecutionStatus {
  failure,
  success,
}

enum AppTask {
  registerDevice,
  checkEncryptionKeys,
  checkCloudSync,
  signOut,
}

enum AppString {
  // app
  appName,
  deviceId,
  installedAt,
  reviewDialogShown,
  deviceRegistered,

  // Supabase
  supabaseKey,
  supabaseUrl,
  supabaseInitialzed,

  // RevenueCat
  rcKeyAndroid,
  planExpired,
  planFull,

  //sign-in
  otpSentTo,
  otpSentAt,

  // Sync
  pushedLocalContentForSync,
  lastChangesFetchedAt,

  // Cipher
  key,
  nonce,
  encrypted,
  decrypted,
  keyCipher,
  keyNonce,
  cipherText,
  cipherNonce,
}

extension AppStringExtension on AppString {
  String get string {
    switch (this) {
      case AppString.pushedLocalContentForSync:
        return 'pushed_local_content_for_sync';
      case AppString.planExpired:
        return 'rc_plan_expired';
      case AppString.planFull:
        return 'rc_plan_full';
      case AppString.rcKeyAndroid:
        return "rc_key_android";
      case AppString.deviceRegistered:
        return "device_registered";
      case AppString.appName:
        return "app_name";
      case AppString.reviewDialogShown:
        return "review_dialog_shown";
      case AppString.installedAt:
        return "installed_at";
      case AppString.deviceId:
        return "device_id";
      case AppString.supabaseKey:
        return "supabase_key";
      case AppString.supabaseUrl:
        return "supabase_url";
      case AppString.supabaseInitialzed:
        return "supabase_initialized";
      case AppString.lastChangesFetchedAt:
        return "last_changes_fetched_at";
      case AppString.otpSentTo:
        return "otp_sent_to";
      case AppString.otpSentAt:
        return "otp_sent_at";
      case AppString.keyCipher:
        return "key_cipher";
      case AppString.keyNonce:
        return "key_nonce";
      case AppString.cipherText:
        return "cipher_text";
      case AppString.cipherNonce:
        return "cipher_nonce";
      case AppString.key:
        return "key";
      case AppString.nonce:
        return "nonce";
      case AppString.encrypted:
        return "encrypted";
      case AppString.decrypted:
        return "decrypted";
    }
  }
}

enum SyncChangeTask {
  delete, // delete current change
  pushMap, // text,tasks,contact,location
  pushMapFile, // audio,documents
  pushFile, // upload file after data/thumbnail upload
  pushMapThumbnailFile, // image,video
  pushThumbnailFile, // upload thumbnail and file after data upload
  pushMapThumbnail, // for category/groups
  pushThumbnail, // for category/groups after data upload

  fetchThumbnail, // requires only thumbnail: category,groups
  fetchThumbnailFile, // requires thumbnail + file : image/video
  fetchFile, // requires only file: audio,document or after thumbnail

  pushMapDeleteThumbnailFile,
  pushMapDeleteThumbnail,
  deleteThumbnailFile,
  deleteThumbnail,
}

extension SyncChangeTaskExtension on SyncChangeTask {
  int get value {
    switch (this) {
      case SyncChangeTask.delete:
        return 0;
      case SyncChangeTask.pushMap:
        return 10;
      case SyncChangeTask.pushFile:
        return 20;
      case SyncChangeTask.pushMapThumbnailFile:
        return 30;
      case SyncChangeTask.pushMapFile:
        return 40;
      case SyncChangeTask.pushThumbnailFile:
        return 50;
      case SyncChangeTask.pushMapThumbnail:
        return 60;
      case SyncChangeTask.pushThumbnail:
        return 70;
      case SyncChangeTask.fetchThumbnail:
        return 80;
      case SyncChangeTask.fetchThumbnailFile:
        return 90;
      case SyncChangeTask.fetchFile:
        return 100;
      case SyncChangeTask.pushMapDeleteThumbnailFile:
        return 110;
      case SyncChangeTask.pushMapDeleteThumbnail:
        return 120;
      case SyncChangeTask.deleteThumbnailFile:
        return 130;
      case SyncChangeTask.deleteThumbnail:
        return 140;
    }
  }

  static SyncChangeTask? fromValue(int value) {
    switch (value) {
      case 0:
        return SyncChangeTask.delete;
      case 10:
        return SyncChangeTask.pushMap;
      case 20:
        return SyncChangeTask.pushFile;
      case 30:
        return SyncChangeTask.pushMapThumbnailFile;
      case 40:
        return SyncChangeTask.pushMapFile;
      case 50:
        return SyncChangeTask.pushThumbnailFile;
      case 60:
        return SyncChangeTask.pushMapThumbnail;
      case 70:
        return SyncChangeTask.pushThumbnail;
      case 80:
        return SyncChangeTask.fetchThumbnail;
      case 90:
        return SyncChangeTask.fetchThumbnailFile;
      case 100:
        return SyncChangeTask.fetchFile;
      case 110:
        return SyncChangeTask.pushMapDeleteThumbnailFile;
      case 120:
        return SyncChangeTask.pushMapDeleteThumbnail;
      case 130:
        return SyncChangeTask.deleteThumbnailFile;
      case 140:
        return SyncChangeTask.deleteThumbnail;
      default:
        return null;
    }
  }
}

enum SyncState {
  initial,
  uploading,
  uploaded,
  downloading,
  downloaded,
  downloadable, // mark only when file is available to download (fully uploaded on server from other device),
}

extension SyncStateExtension on SyncState {
  int get value {
    switch (this) {
      case SyncState.initial:
        return 0;
      case SyncState.uploading:
        return 10;
      case SyncState.uploaded:
        return 20;
      case SyncState.downloading:
        return 30;
      case SyncState.downloaded:
        return 40;
      case SyncState.downloadable:
        return 50;
    }
  }

  static SyncState? fromValue(int value) {
    switch (value) {
      case 0:
        return SyncState.initial;
      case 10:
        return SyncState.uploading;
      case 20:
        return SyncState.uploaded;
      case 30:
        return SyncState.downloading;
      case 40:
        return SyncState.downloaded;
      case 50:
        return SyncState.downloadable;
      default:
        return null;
    }
  }
}

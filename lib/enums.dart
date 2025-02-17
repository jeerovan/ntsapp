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
  checkForKeys,
}

enum AppString {
  deviceId,

  // Supabase
  supabaseKey,
  supabaseUrl,
  supabaseInitialzed,

  //sign-in
  otpSentTo,
  otpSentAt,

  // Sync
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

enum ChangeType {
  delete, // delete current change
  uploadData, // text,tasks,contact,location
  uploadDataFile, // audio,documents
  uploadFile, // upload file after data/thumbnail upload
  uploadDataThumbnailFile, // image,video
  uploadThumbnailFile, // upload thumbnail and file after data upload
  uploadDataThumbnail, // for category/groups
  uploadThumbnail, // for category/groups after data upload

  downloadThumbnail, // requires only thumbnail: category,groups
  downloadThumbnailFile, // requires thumbnail + file : image/video
  downloadFile, // requires only file: audio,document or after thumbnail
}

extension ChangeTypeExtension on ChangeType {
  int get value {
    switch (this) {
      case ChangeType.delete:
        return 0;
      case ChangeType.uploadData:
        return 1;
      case ChangeType.uploadFile:
        return 2;
      case ChangeType.uploadDataThumbnailFile:
        return 3;
      case ChangeType.uploadDataFile:
        return 4;
      case ChangeType.uploadThumbnailFile:
        return 5;
      case ChangeType.uploadDataThumbnail:
        return 6;
      case ChangeType.uploadThumbnail:
        return 7;
      case ChangeType.downloadThumbnail:
        return 8;
      case ChangeType.downloadThumbnailFile:
        return 9;
      case ChangeType.downloadFile:
        return 10;
    }
  }

  static ChangeType? fromValue(int value) {
    switch (value) {
      case 0:
        return ChangeType.delete;
      case 1:
        return ChangeType.uploadData;
      case 2:
        return ChangeType.uploadFile;
      case 3:
        return ChangeType.uploadDataThumbnailFile;
      case 4:
        return ChangeType.uploadDataFile;
      case 5:
        return ChangeType.uploadThumbnailFile;
      case 6:
        return ChangeType.uploadDataThumbnail;
      case 7:
        return ChangeType.uploadThumbnail;
      case 8:
        return ChangeType.downloadThumbnail;
      case 9:
        return ChangeType.downloadThumbnailFile;
      case 10:
        return ChangeType.downloadFile;
      default:
        return null;
    }
  }
}

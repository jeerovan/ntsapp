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

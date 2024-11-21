enum NoteType {
  text,
  image,
  video,
  audio,
  document,
  location,
  contact,
  date,
}

extension NoteTypeExtension on NoteType {
  int get value {
    switch (this) {
      case NoteType.text:
        return 100000;
      case NoteType.image:
        return 110000;
      case NoteType.video:
        return 120000;
      case NoteType.audio:
        return 130000;
      case NoteType.document:
        return 140000;
      case NoteType.location:
        return 150000;
      case NoteType.contact:
        return 160000;
      case NoteType.date:
        return 170000;
    }
  }

  static NoteType? fromValue(int value) {
    switch (value) {
      case 100000:
        return NoteType.text;
      case 110000:
        return NoteType.image;
      case 120000:
        return NoteType.video;
      case 130000:
        return NoteType.audio;
      case 140000:
        return NoteType.document;
      case 150000:
        return NoteType.location;
      case 160000:
        return NoteType.contact;
      case 170000:
        return NoteType.date;
      default:
        return null;
    }
  }
}

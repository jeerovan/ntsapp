import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

class FileSplitter {
  final File file;
  final int fileSize;
  late List<int> partSizes; // Store calculated part sizes

  FileSplitter(
    this.file,
  ) : fileSize = file.lengthSync() {
    partSizes = _calculatePartSizes(); // Precompute part sizes
  }

  /// Determines the part sizes based on the file size
  List<int> _calculatePartSizes() {
    int maxPartSize = _getMaxPartSize(fileSize);
    List<int> parts = [];
    int remainingSize = fileSize;

    while (remainingSize > maxPartSize) {
      parts.add(maxPartSize);
      remainingSize -= maxPartSize;
    }
    if (remainingSize > 0) {
      parts.add(remainingSize);
    }
    return parts;
  }

  /// Returns max part size based on file size
  int _getMaxPartSize(int size) {
    if (size <= 100 * 1024 * 1024) return 10 * 1024 * 1024;
    if (size <= 200 * 1024 * 1024) return 20 * 1024 * 1024;
    if (size <= 300 * 1024 * 1024) return 30 * 1024 * 1024;
    if (size <= 400 * 1024 * 1024) return 40 * 1024 * 1024;
    if (size <= 500 * 1024 * 1024) return 50 * 1024 * 1024;
    if (size <= 600 * 1024 * 1024) return 60 * 1024 * 1024;
    if (size <= 700 * 1024 * 1024) return 70 * 1024 * 1024;
    if (size <= 800 * 1024 * 1024) return 80 * 1024 * 1024;
    return 90 * 1024 * 1024;
  }

  /// Fetches a specific part of the file as bytes
  Future<Uint8List?> getPart(int partNumber) async {
    int partIndex = partNumber - 1;
    if (partIndex < 0 || partIndex >= partSizes.length) {
      return null;
    }

    RandomAccessFile raf = await file.open(mode: FileMode.read);
    int offset = partSizes
        .sublist(0, partIndex)
        .fold(0, (sum, element) => sum + element);
    int partSize = partSizes[partIndex];

    await raf.setPosition(offset); // Seek to the correct position
    Uint8List partBytes = await raf.read(partSize);
    await raf.close();

    return partBytes;
  }
}

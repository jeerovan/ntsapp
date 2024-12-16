import 'dart:io';
import 'dart:math' as math;
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'app_config.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

bool canUseVideoPlayer =
    Platform.isAndroid || Platform.isIOS || Platform.isMacOS || kIsWeb;

String? validateString(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter data';
  }
  return null;
}

String? validateNumber(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.isNotEmpty && int.tryParse(value) == null) {
    return 'A number';
  }
  return null;
}

String? validateNonEmptyNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter data';
  }
  if (value.isNotEmpty && int.tryParse(value) == null) {
    return 'A number';
  }
  return null;
}

String? validateDecimal(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  // Regular expression to match decimals and whole numbers
  RegExp regExp = RegExp(r'^\d*\.?\d+$');
  if (!regExp.hasMatch(value)) {
    return 'Please enter valid data';
  }
  return null;
}

String? validateSelection(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please select an option';
  }
  return null;
}

String capitalize(String text) {
  if (text.isEmpty) return "";
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

Future<void> openURL(String link) async {
  try {
    await launchUrlString(link);
  } catch (e) {
    // Handle error if the PDF viewer app is not installed or cannot be launched
    debugPrint('Error opening: $e');
  }
}

void openMedia(String filePath) async {
  try {
    OpenFilex.open(filePath);
  } catch (e) {
    debugPrint(e.toString());
  }
}

void showAlertMessage(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
        ],
      );
    },
  );
}

void showProcessingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Processing...", style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );
    },
  );
}

String stringFromIntDate(int date) {
  String input = date.toString();
  DateTime dateTime = dateFromStringDate(input);
  // Format the DateTime object to "MMM YY"
  return DateFormat('dd MMM yy').format(dateTime);
}

DateTime dateFromStringDate(String date) {
  // Parse the string to DateTime object
  // Assume the input is always valid and in the format "YYYYMM"
  int year = int.parse(date.substring(0, 4));
  int month = int.parse(date.substring(4, 6));
  int day = int.parse(date.substring(6, 8));
  return DateTime(year, month, day);
}

String stringFromDateRange(DateTimeRange dateRange) {
  String start = DateFormat('dd MMM yy').format(dateRange.start);
  String end = DateFormat('dd MMM yy').format(dateRange.end);
  return '$start - $end';
}

int daysDifference(DateTime date1, DateTime date2) {
  DateTime bigDate = date1.isAfter(date2) ? date1 : date2;
  DateTime smallDate = bigDate == date1 ? date2 : date1;
  Duration difference = bigDate.difference(smallDate);
  return difference.inDays;
}

int getRandomInt(int range) {
  return Random().nextInt(range);
}

int dateFromDateTime(DateTime datetime) {
  return int.parse(DateFormat('yyyyMMdd').format(datetime));
}

String getTodayDate() {
  DateTime now = DateTime.now();
  int year = now.year;
  int month = now.month;
  int date = now.day;
  String monthFormatted = month < 10 ? '0$month' : month.toString();
  String dayFormatted = date < 10 ? '0$date' : date.toString();
  return '$year$monthFormatted$dayFormatted';
}

String getDateFromUtcMilliSeconds(int utcMilliSeconds) {
  final DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(utcMilliSeconds, isUtc: true);
  int year = dateTime.year;
  int month = dateTime.month;
  int date = dateTime.day;
  String monthFormatted = month < 10 ? '0$month' : month.toString();
  String dayFormatted = date < 10 ? '0$date' : date.toString();
  return '$year$monthFormatted$dayFormatted';
}

String getReadableDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  if (date.isAfter(today)) {
    return "Today";
  } else if (date.isAfter(yesterday)) {
    return "Yesterday";
  } else if (now.difference(date).inDays < 7) {
    return DateFormat('EEEE')
        .format(date); // Day of the week for the last 7 days
  } else {
    return DateFormat('MMMM d, yyyy')
        .format(date); // Full date for older messages
  }
}

String getNoteGroupDateTitle() {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  final now = DateTime.now();
  final dayOfWeek = days[now.weekday - 1];
  final day = now.day.toString().padLeft(2, '0'); // Ensure 2 digits
  final month = months[now.month - 1];
  final year = now.year % 100; // Last two digits of the year

  return "$dayOfWeek $day $month'$year";
}

String getFormattedTime(int utcMilliSeconds) {
  final DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(utcMilliSeconds, isUtc: true);
  final String formattedTime = DateFormat('hh:mm a')
      .format(dateTime.toLocal()); // Converts to local time and formats
  return formattedTime;
}

DateTime getLocalDateFromUtcMilliSeconds(int utcMilliSeconds) {
  final DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(utcMilliSeconds, isUtc: true);
  final localDateTime = dateTime.toLocal();
  return DateTime(localDateTime.year, localDateTime.month, localDateTime.day);
}

String mediaFileDuration(int seconds) {
  final int hours = seconds ~/ 3600;
  final int minutes = (seconds % 3600) ~/ 60;
  final int secs = seconds % 60;

  final String hoursStr = hours.toString().padLeft(2, '0');
  final String minutesStr = minutes.toString().padLeft(2, '0');
  final String secondsStr = secs.toString().padLeft(2, '0');

  return hours > 0
      ? "$hoursStr:$minutesStr:$secondsStr"
      : "$minutesStr:$secondsStr";
}

Widget rotatedWidget(Widget widget) {
  return Transform.rotate(
    angle: 180 * math.pi / 180,
    child: widget,
  );
}

Uint8List? getImageThumbnail(Uint8List bytes) {
  int maxSize = 150;
  img.Image? src = img.decodeImage(bytes);
  if (src != null) {
    img.Image resized = img.copyResize(src, width: maxSize);
    return Uint8List.fromList(img.encodePng(resized));
  }
  return null;
}

String getImageDimension(Uint8List bytes) {
  img.Image? src = img.decodeImage(bytes);
  if (src != null) {
    int srcWidth = src.width;
    int srcHeight = src.height;
    return '${srcWidth}x$srcHeight';
  }
  return '0x0';
}

Uint8List getBlankImage(int size) {
  int width = size;
  int height = size;
  final img.Image blankImage = img.Image(width: width, height: height);
  int r = getRandomInt(256);
  int g = getRandomInt(256);
  int b = getRandomInt(256);
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      blankImage.setPixel(x, y, img.ColorUint8.rgb(r, g, b));
    }
  }
  return Uint8List.fromList(img.encodePng(blankImage));
}

String readableBytes(int bytes, [int decimals = 2]) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB"];
  final i = (log(bytes) / log(1024)).floor();
  final size = bytes / pow(1024, i);
  return "${size.toStringAsFixed(decimals)} ${suffixes[i]}";
}

Color getMaterialColor(int index) {
  return Colors.primaries[index % Colors.primaries.length];
}

Color colorFromHex(String hexString) {
  hexString = hexString.replaceFirst('#', ''); // Remove # if present
  int colorInt = int.parse(hexString, radix: 16);
  return Color(colorInt);
}

String colorToHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

Future<File?> getFile(String fileType, String fileName) async {
  String filePath = await getMediaPath(fileType, fileName);
  File file = File(filePath);
  if (file.existsSync()) {
    return file;
  }
  return null;
}

Future<String> getMediaPath(String fileType, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  String mediaDir = AppConfig.get("media_dir");
  return path.join(directory.path, mediaDir, fileType, fileName);
}

void copyFile(Map<String, String> mediaData) {
  File systemFile = File(mediaData["oldPath"]!);
  String newPath = mediaData["newPath"]!;
  systemFile.copySync(newPath);
}

Future<void> checkAndCreateDirectory(String filePath) async {
  String dirPath = path.dirname(filePath);
  final directory = Directory(dirPath);
  bool exists = await directory.exists();
  if (!exists) {
    // Create the directory if it does not exist
    await directory.create(recursive: true);
  }
}

Future<Map<String, dynamic>> processAndGetFileAttributes(
    String filePath) async {
  File file = File(filePath);
  String fileName = basename(file.path);
  int fileSize = file.lengthSync();
  String mime = "application/unknown";
  String? fileMime = lookupMimeType(filePath);
  if (fileMime != null) {
    mime = fileMime;
  }
  String directory = mime.split("/").first;
  File? existing = await getFile(directory, fileName);
  String newPath = await getMediaPath(directory, fileName);
  await checkAndCreateDirectory(newPath);
  if (existing == null) {
    Map<String, String> mediaData = {"oldPath": filePath, "newPath": newPath};
    // TODO if file is in cache, rename it to move to newPath
    await compute(copyFile, mediaData);
  }
  return {"path": newPath, "name": fileName, "size": fileSize, "mime": mime};
}

void addEditTitlePopup(
    BuildContext context, String title, Function(String) onSubmit,
    [String initialText = ""]) {
  final TextEditingController controller =
      TextEditingController(text: initialText);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 1,
          decoration: const InputDecoration(
            hintText: 'Enter text here...',
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              onSubmit(controller.text.trim());
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<String?> getAudioDuration(String filePath) async {
  final player = AudioPlayer();
  String? audioDuration;
  try {
    // Retrieve duration after the audio is loaded
    player.onDurationChanged.listen((duration) {
      audioDuration = mediaFileDuration(duration.inSeconds);
    });

    // Set the audio source to the local file
    await player.setSourceDeviceFile(filePath);

    // Play briefly to trigger duration loading, then immediately stop
    await player.resume();
    await player.pause();
  } catch (e) {
    debugPrint(e.toString());
  } finally {
    player.dispose();
  }
  return audioDuration;
}

class VideoInfoExtractor {
  final String filePath;
  late Player? _player;
  late VideoController _videoController;

  VideoInfoExtractor(this.filePath) {
    try {
      // Create player
      _player = Player(
        configuration: const PlayerConfiguration(
          bufferSize: 1024 * 1024, // 1 MB buffer
          ready: null,
        ),
      );
      _videoController = VideoController(_player!);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Get video metadata information
  Future<Map<String, dynamic>> getVideoInfo() async {
    try {
      // Open the file
      await _player!.open(Media(filePath), play: false);

      // Wait a moment to ensure metadata is loaded
      await Future.delayed(const Duration(milliseconds: 1000));

      // Get video information
      final duration = _player!.state.duration.inSeconds;
      final aspectRatio = _player!.state.videoParams.aspect ?? 1 / 1;

      return {
        'duration': duration,
        'aspect': aspectRatio,
      };
    } catch (e) {
      debugPrint('Error extracting video info: $e');
      return {
        'duration': 0,
        'aspect': 1 / 1,
      };
    }
  }

  // Get thumbnail image
  // Make sure to call this after getinfo
  Future<Uint8List?> getThumbnail({Duration? seekPosition}) async {
    try {
      // Seek to specific position if provided
      if (seekPosition != null) {
        await _player!.seek(seekPosition);
        // Give a moment for seeking to complete
        await Future.delayed(const Duration(milliseconds: 300));
        await _player!.pause();
      }

      // Capture screenshot
      final screenshot = await _player!.screenshot(format: "image/png");

      // Check if screenshot is valid
      if (screenshot == null) {
        debugPrint('Failed to capture screenshot');
        return null;
      }

      return screenshot;
    } catch (e) {
      debugPrint('Error getting thumbnail: $e');
      return null;
    }
  }

  // Dispose resources
  void dispose() {
    if (_player != null) {
      _player!.dispose();
    }
  }
}

Map<String, String> getMapUrls(double lat, double lng) {
  return {
    "google": 'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    "apple": 'https://maps.apple.com/?q=$lat,$lng'
  };
}

Future<void> openLocationInMap(double lat, double lng) async {
  Map<String, String> mapUrls = getMapUrls(lat, lng);
  final googleMapsUri = Uri.parse(mapUrls["google"]!);
  final appleMapsUri = Uri.parse(mapUrls["apple"]!);

  if (await canLaunchUrl(googleMapsUri)) {
    await launchUrl(googleMapsUri);
  } else if (await canLaunchUrl(appleMapsUri)) {
    await launchUrl(appleMapsUri);
  } else {
    // Open Google Maps URL in the browser as a fallback
    await launchUrl(
      googleMapsUri,
      mode: LaunchMode
          .externalApplication, // Ensures it opens in the external browser
    );
  }
}

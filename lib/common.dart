import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mime/mime.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/model_setting.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:ntsapp/storage_hive.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:ntsapp/storage_sqlite.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'model_category.dart';
import 'model_item_group.dart';
import 'utils_crypto.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

bool canUseVideoPlayer =
    Platform.isAndroid || Platform.isIOS || Platform.isMacOS || kIsWeb;

bool isDebugEnabled() {
  return false;
}

bool simulateOnboarding() {
  return false;
}

final List<Color> predefinedColors = [
  "#06b6d4",
  "#0ea5e9",
  "#3b82f6",
  "#6366f1",
  "#8b5cf6",
  "#ec4899",
  "#14b8a6",
  "#22c55e",
  "#84cc16",
  "#eab308",
  "#f97316",
  "#ef4444",
  "#ffffff",
  "#e5e7eb",
  "#9ca3af",
  "#4b5563",
  "#1f2937",
  "#000000"
].map((colorText) {
  return colorFromHex(colorText);
}).toList();

int getRandomInt(int range) {
  return Random().nextInt(range);
}

dynamic getValueFromMap(Map<String, dynamic> map, String key,
    {dynamic defaultValue}) {
  dynamic value;
  if (map.containsKey(key)) {
    if (map[key] == null) {
      value = defaultValue;
    } else {
      value = map[key];
    }
  } else {
    value = defaultValue;
  }
  return value;
}

/* input validations -- starts */
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
/* input validations -- ends */

String capitalize(String text) {
  if (text.isEmpty) return "";
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

Future<void> openURL(String link) async {
  final logger = AppLogger(prefixes: ["common", "openURL"]);
  try {
    await launchUrlString(link);
  } catch (e, s) {
    logger.error("Exception", error: e, stackTrace: s);
  }
}

void openMedia(String filePath) async {
  final logger = AppLogger(prefixes: ["common", "openMedia"]);
  try {
    OpenFilex.open(filePath);
  } catch (e, s) {
    logger.error("Exeption", error: e, stackTrace: s);
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

/* date/time conversions -- starts */
String nowUtcInISO() {
  DateTime nowUtc = DateTime.now().toUtc();
  String formattedTimestamp = nowUtc.toIso8601String();

  // Adjusting format to match "YYYY-MM-DD HH:MM:SS.ssssss+00"
  formattedTimestamp = formattedTimestamp
      .replaceFirst("T", " ") // Replace 'T' with space
      .replaceFirst("Z", "+00"); // Replace 'Z' with '+00'

  return formattedTimestamp;
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
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
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
  //final year = now.year % 100; // Last two digits of the year

  return "$month $day, $dayOfWeek";
}

String getFormattedTime(int utcMilliSeconds) {
  final DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(utcMilliSeconds, isUtc: true);
  final String formattedTime = DateFormat('hh:mm a')
      .format(dateTime.toLocal()); // Converts to local time and formats
  return formattedTime;
}

String getFormattedDateTime(int utcMilliSeconds) {
  final DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(utcMilliSeconds, isUtc: true);
  final String formattedTime = DateFormat('dd MMM yy hh:mm a')
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
/* date/time conversion -- ends */

Uint8List? getImageThumbnail(Uint8List bytes) {
  int maxSize = 200;
  img.Image? src = img.decodeImage(bytes);
  if (src != null) {
    img.Image resized = img.copyResize(src, width: maxSize);
    return Uint8List.fromList(img.encodePng(resized));
  }
  return null;
}

Map<String, int> getImageDimension(Uint8List bytes) {
  img.Image? src = img.decodeImage(bytes);
  if (src != null) {
    int srcWidth = src.width;
    int srcHeight = src.height;
    return {"width": srcWidth, "height": srcHeight};
  }
  return {"width": 0, "height": 0};
}

String readableFileSizeFromBytes(int bytes, [int decimals = 2]) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB"];
  final i = (log(bytes) / log(1024)).floor();
  final size = bytes / pow(1024, i);
  return "${size.toStringAsFixed(decimals)} ${suffixes[i]}";
}

Color getIndexedColor(int count) {
  int predefinedColorsLength = 12;
  int index = count % predefinedColorsLength;
  return predefinedColors[index];
}

Color colorFromHex(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) {
    buffer.write('FF'); // Add opacity if not provided
  }
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

String colorToHex(Color color) {
  final red =
      (color.r * 255).toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
  final green =
      (color.g * 255).toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
  final blue =
      (color.b * 255).toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
  final alpha =
      (color.a * 255).toInt().toRadixString(16).padLeft(2, '0').toUpperCase();

  return '$alpha$red$green$blue';
}

Future<File?> getFile(String fileType, String fileName) async {
  String filePath = await getFilePath(fileType, fileName);
  File file = File(filePath);
  if (file.existsSync()) {
    return file;
  }
  return null;
}

Future<String> getDbStoragePath() async {
  String? dbDirPath;
  if (Platform.isMacOS || Platform.isIOS) {
    Directory libDir = await getLibraryDirectory();
    dbDirPath = libDir.path;
  } else if (Platform.isWindows) {
    dbDirPath = Platform.environment['APPDATA'];
  } else if (Platform.isLinux) {
    Directory supportDir = await getApplicationSupportDirectory();
    dbDirPath = supportDir.path;
  }
  if (dbDirPath == null) {
    Directory documentsPath = await getApplicationDocumentsDirectory();
    dbDirPath = documentsPath.path;
  }
  Directory dbDir = Directory(dbDirPath); // Ensure directory exists
  if (!dbDir.existsSync()) {
    await dbDir.create(recursive: true);
  }
  return dbDirPath;
}

Future<String> getFilePath(String mimeDirectory, String fileName) async {
  SecureStorage secureStorage = SecureStorage();
  final directory = await getApplicationDocumentsDirectory();
  String? mediaDir = await secureStorage.read(key: "media_dir");
  return path.join(directory.path, mediaDir, mimeDirectory, fileName);
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
    await directory.create(recursive: true);
  }
}

Future<void> initializeDirectories() async {
  SecureStorage secureStorage = SecureStorage();
  final directory = await getApplicationDocumentsDirectory();
  String? mediaDir = await secureStorage.read(key: "media_dir");
  String mediaDirPath = path.join(directory.path, mediaDir);
  final mediaDirectory = Directory(mediaDirPath);
  if (!mediaDirectory.existsSync()) {
    await mediaDirectory.create(recursive: true);
  }
  String? backupDir = await secureStorage.read(key: "backup_dir");
  String backupDirPath = path.join(directory.path, backupDir);
  final backupDirectory = Directory(backupDirPath);
  if (!backupDirectory.existsSync()) {
    await backupDirectory.create(recursive: true);
  }
}

Future<String> getHashOfFile(File file) async {
  final Stream<List<int>> stream = file.openRead();
  final sha256hash = await stream.transform(sha256).first;
  return sha256hash.toString();
}

Future<Map<String, dynamic>?> processAndGetFileAttributes(
    String filePath) async {
  File file = File(filePath);
  if (!file.existsSync()) {
    return null;
  }
  String mime = "application/unknown";
  final String extension = path.extension(filePath);
  String? fileMime = lookupMimeType(filePath);
  if (fileMime == null) {
    return null;
  } else {
    mime = fileMime;
  }
  String hash = await getHashOfFile(file);
  String fileTitle = path.basename(file.path);
  String fileName = '$hash$extension';
  int fileSize = file.lengthSync();
  String mimeDirectory = mime.split("/").first;
  File? existing = await getFile(mimeDirectory, fileName);
  String newPath = await getFilePath(mimeDirectory, fileName);
  await checkAndCreateDirectory(newPath);
  if (existing == null) {
    Map<String, String> mediaData = {"oldPath": filePath, "newPath": newPath};
    await compute(copyFile, mediaData);
  }
  return {
    "path": newPath,
    "name": fileName,
    "size": fileSize,
    "mime": mime,
    "title": fileTitle
  };
}

Future<int> checkDownloadNetworkImage(String itemId, String imageUrl) async {
  final logger = AppLogger(prefixes: ["common", "checkDownloadNetworkImage"]);
  String fileName = '$itemId-urlimage.png';
  String directory = "image";
  String newPath = await getFilePath(directory, fileName);
  await checkAndCreateDirectory(newPath);
  int portrait = 1;
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      Uint8List imageBytes = response.bodyBytes;
      Uint8List? thumbnail = getImageThumbnail(imageBytes);
      if (thumbnail != null) {
        final file = File(newPath);
        await file.writeAsBytes(thumbnail);
        Map<String, int> imageDimension = getImageDimension(thumbnail);
        int imageWidth = imageDimension["width"]!;
        int imageHeight = imageDimension["height"]!;
        if (imageWidth > 0 && imageHeight > 0) {
          if (imageWidth > imageHeight) {
            portrait = 0;
          }
        }
      }
    }
  } catch (e, s) {
    logger.error("Exception", error: e, stackTrace: s);
  }
  return portrait;
}

Future<Map<String, dynamic>> getDataToDownloadFile(String fileName) async {
  SupabaseClient supabase = Supabase.instance.client;
  Map<String, dynamic> downloadData = {};
  try {
    final res = await supabase.functions
        .invoke('get_download_url', body: {'fileName': fileName});
    Map<String, dynamic> data = jsonDecode(res.data);
    downloadData.addAll(data);
  } on FunctionException catch (e) {
    downloadData["error"] = e.details.toString();
  } catch (e) {
    downloadData["error"] = e.toString();
  }
  return downloadData;
}

Future<String?> getAudioDuration(String filePath) async {
  final logger = AppLogger(prefixes: ["common", "getAudioDuration"]);
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
  } catch (e, s) {
    logger.error("Exception", error: e, stackTrace: s);
  } finally {
    player.dispose();
  }
  return audioDuration;
}

class VideoInfoExtractor {
  final logger = AppLogger(prefixes: ["common", "VideoInfoExtractor"]);

  final String filePath;
  late Player? _player;

  // ignore: unused_field
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
    } catch (e, s) {
      logger.error("Player", error: e, stackTrace: s);
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
    } catch (e, s) {
      logger.error("getVideoInfo", error: e, stackTrace: s);
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
        logger.error("getThumbnail", error: 'Failed to capture screenshot');
        return null;
      }

      Uint8List? thumbnail = getImageThumbnail(screenshot);

      return thumbnail;
    } catch (e, s) {
      logger.error("getThumbnail", error: e, stackTrace: s);
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

class FontSizeController extends ChangeNotifier {
  double _scaleFactor = double.parse(ModelSetting.get("fontScale", "1.2"));

  double get scaleFactor => _scaleFactor;

  TextScaler get textScaler => TextScaler.linear(_scaleFactor);

  // Get the scaled size based on base font size
  double getScaledSize(double fontSize) => fontSize * _scaleFactor;

  // Increase font size by 10%
  void increaseFontSize() {
    if (_scaleFactor < 1.8) {
      _scaleFactor += 0.1;
      ModelSetting.set("fontScale", _scaleFactor);
      notifyListeners();
    }
  }

  // Decrease font size by 10%
  void decreaseFontSize() {
    if (_scaleFactor > 0.7) {
      // Prevent text from becoming too small
      _scaleFactor -= 0.1;
      ModelSetting.set("fontScale", _scaleFactor);
      notifyListeners();
    }
  }

  // Reset to default size
  void resetFontSize() {
    _scaleFactor = 1.2;
    ModelSetting.set("fontScale", _scaleFactor);
    notifyListeners();
  }
}

class ExecutionResult<T> {
  // Status of the execution using enum
  final ExecutionStatus status;

  // Holds the success result as a Map
  final Map<String, dynamic>? successResult;

  // Holds the failure reason if execution failed
  final String? failureReason;

  // Optional failure key for categorizing different types of failures
  final String? failureKey;

  ExecutionResult._({
    required this.status,
    this.successResult,
    this.failureReason,
    this.failureKey,
  });

  // Factory constructor for successful execution
  factory ExecutionResult.success(Map<String, dynamic> result) {
    return ExecutionResult._(
      status: ExecutionStatus.success,
      successResult: result,
      failureReason: null,
      failureKey: null,
    );
  }

  // Factory constructor for failed execution
  factory ExecutionResult.failure({
    required String reason,
    String? key,
  }) {
    return ExecutionResult._(
      status: ExecutionStatus.failure,
      successResult: null,
      failureReason: reason,
      failureKey: key,
    );
  }

  // Helper method to check if execution was successful
  bool get isSuccess => status == ExecutionStatus.success;

  // Helper method to check if execution failed
  bool get isFailure => status == ExecutionStatus.failure;

  // Helper method to safely get success result
  Map<String, dynamic>? getResult() {
    return isSuccess ? successResult : null;
  }

  // Helper method to safely get failure information
  Map<String, dynamic>? getFailureInfo() {
    if (!isFailure) return null;

    return {
      'reason': failureReason,
      if (failureKey != null) 'key': failureKey,
    };
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ExecutionResult(${status.name}): $successResult';
    } else {
      return 'ExecutionResult(${status.name}): ${failureReason ?? "No reason provided"}${failureKey != null ? " (Key: $failureKey)" : ""}';
    }
  }
}

class PageParams {
  ModelGroup? group;
  ModelCategory? category;
  String? id;
  bool? isAuthenticated;
  int? mediaIndexInGroup;
  int? mediaCountInGroup;
  AppTask? appTask;
  Map<String, dynamic>? cipherData;
  bool? recreatePassword;

  PageParams({
    this.group,
    this.category,
    this.id,
    this.isAuthenticated,
    this.mediaCountInGroup,
    this.mediaIndexInGroup,
    this.appTask,
    this.cipherData,
    this.recreatePassword,
  });
}

/* hexadecimal from/to conversions */
/// Converts a list of bytes to a hex string
String bytesToHex(List<int> bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

/// Converts a hex string to a list of bytes
Uint8List hexToBytes(String hex) {
  final length = hex.length;
  if (length % 2 != 0) {
    throw FormatException('Hex string must have an even length');
  }

  return Uint8List.fromList(
    List.generate(length ~/ 2, (i) {
      final byte = hex.substring(i * 2, i * 2 + 2);
      return int.parse(byte, radix: 16);
    }),
  );
}

Future<String> getDeviceName() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return '${androidInfo.manufacturer} ${androidInfo.model}';
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return '${iosInfo.name} (${iosInfo.model})';
  } else if (Platform.isMacOS) {
    MacOsDeviceInfo macInfo = await deviceInfo.macOsInfo;
    return 'MacOS ${macInfo.computerName}';
  } else if (Platform.isWindows) {
    WindowsDeviceInfo winInfo = await deviceInfo.windowsInfo;
    return '${winInfo.productName} ${winInfo.computerName}';
  } else if (Platform.isLinux) {
    LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
    return 'Linux ${linuxInfo.name}';
  } else {
    return 'Unknown Device';
  }
}

// Helper to check internet connectivity
Future<bool> hasInternetConnection() async {
  try {
    if (kIsWeb) {
      // For Web, perform an HTTP request
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(Duration(seconds: 2));
      return response.statusCode == 200;
    }

    // For mobile and desktop, use DNS ping
    final result = await InternetAddress.lookup('8.8.8.8');
    return result.isNotEmpty;
  } catch (_) {
    return false;
  }
}

SupabaseClient? getSupabaseClient() {
  try {
    return Supabase.instance.client;
  } catch (e, s) {
    AppLogger(prefixes: ["Common"])
        .error("Supaclient", error: e, stackTrace: s);
    return null;
  }
}

Future<void> initializeDependencies({String mode = "Common"}) async {
  bool runningOnMobile = Platform.isIOS || Platform.isAndroid;
  await StorageHive().initialize();
  if (!runningOnMobile) {
    // Initialize sqflite for FFI (non-mobile platforms)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // initialize sqlite
  StorageSqlite dbSqlite = StorageSqlite.instance;
  await dbSqlite.ensureInitialized();
  List<Map<String, dynamic>> keyValuePairs = await dbSqlite.getAll('setting');
  ModelSetting.settingJson = {
    for (var pair in keyValuePairs) pair['id']: pair['value']
  };
  await ModelSetting.set(AppString.supabaseInitialized.string, "no");
  await initializeDirectories();
  CryptoUtils.init();

  final String supaUrl = const String.fromEnvironment("SUPABASE_URL");
  final String supaKey = const String.fromEnvironment("SUPABASE_KEY");
  if (supaUrl.isNotEmpty && supaKey.isNotEmpty) {
    Supabase _ = await Supabase.initialize(url: supaUrl, anonKey: supaKey);
    await ModelSetting.set(AppString.supabaseInitialized.string, "yes");
    AppLogger(prefixes: [mode]).info("Initialized Supabase");
  }
  AppLogger(prefixes: [mode]).info("Initialized Dependencies");
}

Future<void> signalToUpdateHome() async {
  ModelCategory dndCategory = await ModelCategory.getDND();
  await StorageHive().put(AppString.changedCategoryId.string, dndCategory.id);
}

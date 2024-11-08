import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:math' as math;
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

import 'package:video_player/video_player.dart';


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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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

class MessageInCenter extends StatelessWidget {
  final String text;
  const MessageInCenter({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text),
          ),
        ],
      ),
    );
  }
}

class Loading extends StatelessWidget {
  const Loading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
        ],
      ),
    );
  }
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

String getReadableDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  if (date.isAfter(today)) {
    return "Today";
  } else if (date.isAfter(yesterday)) {
    return "Yesterday";
  } else if (now.difference(date).inDays < 7) {
    return DateFormat('EEEE').format(date); // Day of the week for the last 7 days
  } else {
    return DateFormat('MMMM d, yyyy').format(date); // Full date for older messages
  }
}

Widget rotatedWidget(Widget widget) {
  return Transform.rotate(
    angle: 180 * math.pi / 180,
    child: widget,
  );
}

Uint8List? getImageThumbnail(Uint8List bytes) {
  int maxSize = 200;
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

Uint8List getBlankImage(int size){
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

int getMessageType(String? mime){
  if(mime != null){
    String type = mime.split("/").first;
    switch(type){
      case "image":
        switch(mime){
          case "image/gif":
            return 110100;
          default:
              return 110000;
        }
      case "audio":
        return 120000;
      case "video":
        return 130000;
      default:
        return 140000;
    }
  }
  return 140000;
}

Future<File?> getFile(String fileType,String fileName) async {
  String filePath = await getFilePath(fileType,fileName);
  File file = File(filePath);
  if (file.existsSync()) {
    return file;
  }
  return null;
}

Future<String> getFilePath(String fileType,String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  String filePath = path.join(fileType,fileName);
  return path.join(directory.path, filePath);
}

String copyFile(Map<String,String> mediaData) {
  File systemFile = File(mediaData["oldPath"]!);
  String newPath = mediaData["newPath"]!;
  systemFile.copySync(newPath);
  return newPath;
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

class FloatingActionButtonWithBadge extends StatelessWidget {
  final int filterCount;
  final VoidCallback onPressed;
  final Icon icon;

  const FloatingActionButtonWithBadge({
    super.key,
    required this.filterCount,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      clipBehavior:
          Clip.none, // Allows the badge to be positioned outside the FAB
      children: [
        FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: onPressed,
          child: icon,
        ),
        if (filterCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                '$filterCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class IconButtonWithBadge extends StatelessWidget {
  final int filterCount;
  final VoidCallback onPressed;
  final Icon icon;

  const IconButtonWithBadge({
    super.key,
    required this.filterCount,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      clipBehavior:
          Clip.none, // Allows the badge to be positioned outside the FAB
      children: [
        IconButton(
          onPressed: onPressed,
          icon: icon,
        ),
        if (filterCount > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                '$filterCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class KeyValueTable extends StatelessWidget {
  final Map data;

  const KeyValueTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(), // Column for keys
        1: IntrinsicColumnWidth(), // Column for values
      },
      children: data.entries.map((entry) {
        return TableRow(
          children: [
            Container(
              padding: const EdgeInsets.all(11.0),
              child: Text(
                capitalize(entry.key),
                textAlign: TextAlign.right,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                entry.value.toString(),
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

void addEditTitlePopup(BuildContext context, String title, Function(String) onSubmit, [String initialText = ""]) {
    final TextEditingController controller = TextEditingController(text: initialText);
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
                onSubmit(controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

class BlankPage extends StatefulWidget {
  const BlankPage({super.key});

  @override
  BlankPageState createState() => BlankPageState();
}

class BlankPageState extends State<BlankPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}


class VideoThumbnail extends StatefulWidget {
  final String videoPath;

  const VideoThumbnail({super.key, required this.videoPath});

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _fileAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    File videoFile = File(widget.videoPath);
    if (videoFile.existsSync()) {
      _fileAvailable = true;
      _controller = VideoPlayerController.file(File(widget.videoPath));
      // Initialize the controller and display the first frame as a thumbnail
      await _controller.initialize();
      await _controller.setLooping(false); // No looping
      await _controller.pause(); // Pause to display the first frame
    }
    
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? _fileAvailable
            ? Stack(
                alignment: Alignment.center, // Center the play button overlay
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  // Play button overlay
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.7), // Semi-transparent grey background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              )
            : Image.file(
                File("assets/image.webp"),
                fit: BoxFit.cover, // Ensures the image covers the available space
              )
        : const Center(child: CircularProgressIndicator());
  }
}


import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:math' as math;
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as pimg;

final List<Map<String, String>> months = [
  {"value": "01", "text": "Jan"},
  {"value": "02", "text": "Feb"},
  {"value": "03", "text": "Mar"},
  {"value": "04", "text": "Apr"},
  {"value": "05", "text": "May"},
  {"value": "06", "text": "Jun"},
  {"value": "07", "text": "Jul"},
  {"value": "08", "text": "Aug"},
  {"value": "09", "text": "Sep"},
  {"value": "10", "text": "Oct"},
  {"value": "11", "text": "Nov"},
  {"value": "12", "text": "Dec"}
];
List<DropdownMenuItem<String>> monthDropdown = months
    .map((month) => DropdownMenuItem<String>(
          value: month['value'],
          child: Text(month['text']!),
        ))
    .toList();

final List<Map<String, String>> doses = [
  {"value": "", "text": "Unit"},
  {"value": "Spoon", "text": "Spoon"},
  {"value": "Tablet", "text": "Tablet"},
  {"value": "Drops", "text": "Drops"},
];
List<DropdownMenuItem<String>> dosesDropdown = doses
    .map((dose) => DropdownMenuItem<String>(
          value: dose['value'],
          child: Text(dose['text']!),
        ))
    .toList();

List<int> generateListOfInts(int start, int end) {
  if (start > end) {
    throw ArgumentError('Start year must be less than or equal to end year.');
  }
  return List.generate(end - start + 1, (index) => start + index);
}

List<DropdownMenuItem<String>> yearDropdown(int start, int end) {
  List<int> years = List.generate(end - start + 1, (index) => start + index);
  return years
      .map((year) => DropdownMenuItem<String>(
            value: year.toString(),
            child: Text(year.toString()),
          ))
      .toList();
}

String? validateString(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter data';
  }
  return null;
}

String? validateStockLocation(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.isNotEmpty && value.length > 3) {
    return "Max 3 characters";
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

String? validatePIN(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.isNotEmpty && int.tryParse(value) == null) {
    return 'Must be a number';
  }
  if (value.length != 6) {
    return 'Enter valid PIN';
  }
  return null;
}

String? validateMobile(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.isNotEmpty && int.tryParse(value) == null) {
    return 'Must be a number';
  }
  if (value.length != 10) {
    return 'Enter 10 digit mobile';
  }
  return null;
}

String? validatePacking(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter packing';
  }
  RegExp regExp = RegExp(r'^1\*\d+$');
  if (!regExp.hasMatch(value)) {
    return 'Format: 1*X(Items in MRP pack)';
  }
  return null;
}

String? validatePrice(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter data';
  }
  RegExp decimalRegExp = RegExp(r'^\d*\.?\d+$');
  if (!decimalRegExp.hasMatch(value)) {
    return 'Please enter valid data';
  }
  return null;
}

String? validateQuantity(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter quantity';
  }
  RegExp xyRegExp = RegExp(r'^\d+\+\d+$');
  if (!xyRegExp.hasMatch(value)) {
    return 'Format: X(Pack)+Y(Loose)';
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

class ModelDropdownSuggestion {
  final int id;
  final String text;
  ModelDropdownSuggestion({required this.id, required this.text});
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

int getFutureYearMonth(int yearMonth, int monthsToAdd) {
  // Extract year and month
  int year = yearMonth ~/ 100;
  int month = yearMonth % 100;

  // Create a DateTime object
  DateTime dateTime = DateTime(year, month);

  // Add months
  DateTime newDateTime = DateTime(dateTime.year, dateTime.month + monthsToAdd);

  // Convert back to YYYYMM format
  int newYearMonth = newDateTime.year * 100 + newDateTime.month;

  return newYearMonth;
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

Widget rotatedWidget(Widget widget) {
  return Transform.rotate(
    angle: 180 * math.pi / 180,
    child: widget,
  );
}

Uint8List getResizedCroppedImage(Uint8List bytes) {
  int maxSize = 512;
  pimg.Image? src = pimg.decodeImage(bytes);
  if (src != null) {
    int srcWidth = src.width;
    int srcHeight = src.height;
    if (srcWidth < srcHeight) {
      pimg.Image resized = pimg.copyResize(src, width: maxSize);
      int offsetY = (resized.height - maxSize) ~/ 2;
      pimg.Image destImage = pimg.copyCrop(resized,
          x: 0, y: offsetY, width: maxSize, height: maxSize);
      return Uint8List.fromList(pimg.encodePng(destImage));
    } else {
      pimg.Image resized = pimg.copyResize(src, height: maxSize);
      int offsetX = (resized.width - maxSize) ~/ 2;
      pimg.Image destImage = pimg.copyCrop(resized,
          x: offsetX, y: 0, width: maxSize, height: maxSize);
      return Uint8List.fromList(pimg.encodePng(destImage));
    }
  }
  return Uint8List(0);
}

Uint8List getBlankImage(int size){
  int width = size;
  int height = size;
  final pimg.Image blankImage = pimg.Image(width: width, height: height);
  int r = getRandomInt(256);
  int g = getRandomInt(256);
  int b = getRandomInt(256);
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      blankImage.setPixel(x, y, pimg.ColorUint8.rgb(r, g, b));
    }
  }
  return Uint8List.fromList(pimg.encodePng(blankImage));
}

Future<File?> getImageFile(String prefix, int id) async {
  String filePath = await getFilePath(prefix, id);
  File file = File(filePath);
  if (file.existsSync()) {
    return file;
  }
  return null;
}

Future<String> getFilePath(String prefix, int id) async {
  final directory = await getApplicationDocumentsDirectory();
  final String fileName = path.join(prefix, id.toString());
  return path.join(directory.path, fileName);
}

List<Offset> parseCoordinates(String coordinatesString) {
  // Split the string by '+' to get individual coordinate pairs
  List<String> pairs = coordinatesString.split('+');

  // Create an empty list to store the points
  List<Offset> points = [];

  // Iterate through each pair and split by ',' to get x and y values
  for (String pair in pairs) {
    List<String> coords = pair.split(',');
    double x = double.parse(coords[0]);
    double y = double.parse(coords[1]);
    points.add(Offset(x, y));
  }

  return points;
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

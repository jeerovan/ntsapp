import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:ntsapp/widgets_item.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'common.dart';
import 'model_category_group.dart';
import 'model_item.dart';

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

class WidgetKeyValueTable extends StatelessWidget {
  final Map data;

  const WidgetKeyValueTable({super.key, required this.data});

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

class WidgetCategoryGroupAvatar extends StatelessWidget {
  final String type;
  final Uint8List? thumbnail;
  final double size;
  final String color;
  final String title;

  const WidgetCategoryGroupAvatar(
      {super.key,
      required this.type,
      required this.size,
      this.thumbnail,
      required this.color,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return type == "group"
        ? Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(Icons.circle,
                size: 14, color: colorFromHex(color).withOpacity(0.8)),
          )
        : Padding(
            padding: const EdgeInsets.all(5.0),
            child: Icon(
              Icons.workspaces,
              color: colorFromHex(color).withOpacity(0.8),
            ),
          );
  }
}

class WidgetCategoryGroup extends StatelessWidget {
  final ModelCategoryGroup categoryGroup;
  final bool showSummary;
  final bool showCategorySign;

  const WidgetCategoryGroup(
      {super.key,
      required this.categoryGroup,
      required this.showSummary,
      required this.showCategorySign});

  @override
  Widget build(BuildContext context) {
    double size = 40;
    return ListTile(
      leading: WidgetCategoryGroupAvatar(
        type: categoryGroup.type,
        size: size,
        color: categoryGroup.color,
        title: categoryGroup.title,
        thumbnail: categoryGroup.thumbnail,
      ),
      horizontalTitleGap: 20.0,
      title: Row(
        children: [
          Expanded(
            child: Text(
              categoryGroup.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
      subtitle: showSummary
          ? categoryGroup.type == "group"
              ? NotePreviewSummary(
                  item: categoryGroup.group!.lastItem,
                  showTimestamp: false,
                  showImagePreview: false,
                  expanded: true,
                )
              : Text(
                  (categoryGroup.category!.groupCount == 1)
                      ? "${categoryGroup.category!.groupCount} note group"
                      : "${categoryGroup.category!.groupCount} note groups",
                  overflow: TextOverflow.ellipsis, // Ellipsis for long text
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                )
          : const SizedBox.shrink(),
      trailing: categoryGroup.type == "category"
          ? showCategorySign
              ? Icon(
                  LucideIcons.chevronRight,
                  color: Theme.of(context).colorScheme.outlineVariant,
                )
              : const SizedBox.shrink()
          : const SizedBox.shrink(),
    );
  }
}

class WidgetVideoImageThumbnail extends StatefulWidget {
  final ModelItem item;
  final double iconSize;

  const WidgetVideoImageThumbnail(
      {super.key, required this.item, required this.iconSize});

  @override
  State<WidgetVideoImageThumbnail> createState() =>
      _WidgetVideoImageThumbnailState();
}

class _WidgetVideoImageThumbnailState extends State<WidgetVideoImageThumbnail> {
  @override
  Widget build(BuildContext context) {
    ModelItem item = widget.item;
    return Stack(
      alignment: Alignment.center, // Center the play button overlay
      children: [
        AspectRatio(
          aspectRatio: item.data == null ? 16 / 9 : item.data!['aspect'],
          child: Image.memory(
            item.thumbnail!,
            width: double.infinity, // Full width of container
            fit: BoxFit.cover,
          ),
        ),
        // Play button overlay
        Container(
          width: widget.iconSize,
          height: widget.iconSize,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            // Semi-transparent grey background
            shape: BoxShape.circle,
          ),
          child: Icon(
            LucideIcons.play,
            color: Colors.white,
            size: widget.iconSize / 2,
          ),
        ),
      ],
    );
  }
}

class WidgetVideoPlayerThumbnail extends StatefulWidget {
  final ModelItem item;
  final double iconSize;

  const WidgetVideoPlayerThumbnail(
      {super.key, required this.item, required this.iconSize});

  @override
  State<WidgetVideoPlayerThumbnail> createState() =>
      _WidgetVideoPlayerThumbnailState();
}

class _WidgetVideoPlayerThumbnailState
    extends State<WidgetVideoPlayerThumbnail> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _fileAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    String videoPath = widget.item.data!["path"];
    File videoFile = File(videoPath);
    if (videoFile.existsSync()) {
      _fileAvailable = true;
      _controller = VideoPlayerController.file(File(videoPath));
      // Initialize the controller and display the first frame as a thumbnail
      await _controller.initialize();
      await _controller.setLooping(false); // No looping
      await _controller.pause(); // Pause to display the first frame
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
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
                    width: widget.iconSize,
                    height: widget.iconSize,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      // Semi-transparent grey background
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.play,
                        color: Colors.white, size: widget.iconSize / 2),
                  ),
                ],
              )
            : Image.asset(
                // handle downloading with icon
                'assets/image.webp',
                fit: BoxFit
                    .cover, // Ensures the image covers the available space
              )
        : const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
  }
}

class WidgetMediaKitThumbnail extends StatefulWidget {
  final ModelItem item;
  final double iconSize;

  const WidgetMediaKitThumbnail(
      {super.key, required this.item, required this.iconSize});

  @override
  State<WidgetMediaKitThumbnail> createState() =>
      _WidgetMediaKitThumbnailState();
}

class _WidgetMediaKitThumbnailState extends State<WidgetMediaKitThumbnail> {
  // Create a [Player] to control playback.
  late final player = Player();

  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  bool _isInitialized = false;
  bool _fileAvailable = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.data != null) {
      String videoPath = widget.item.data!["path"];
      File videoFile = File(videoPath);
      if (videoFile.existsSync()) {
        _fileAvailable = true;
        player.open(Media(videoPath), play: false);
      }
    }
    _isInitialized = true;
  }

  @override
  void dispose() {
    player.dispose();
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
                    aspectRatio: widget.item.data == null
                        ? 1 / 1
                        : widget.item.data!["aspect"],
                    child: Video(
                      controller: controller,
                      controls: NoVideoControls,
                    ),
                  ),
                  // Play button overlay
                  Container(
                    width: widget.iconSize,
                    height: widget.iconSize,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      // Semi-transparent grey background
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.play,
                      color: Colors.white,
                      size: widget.iconSize / 2,
                    ),
                  ),
                ],
              )
            : Image.asset(
                // handle downloading with icon
                'assets/image.webp',
                fit: BoxFit
                    .cover, // Ensures the image covers the available space
              )
        : const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
  }
}

class WidgetAudio extends StatefulWidget {
  final ModelItem item;

  const WidgetAudio({super.key, required this.item});

  @override
  State<WidgetAudio> createState() => _WidgetAudioState();
}

class _WidgetAudioState extends State<WidgetAudio> {
  late AudioPlayer _audioPlayer;
  Duration _totalDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Load audio file duration
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
        debugPrint("TotalDuration:${_totalDuration.inSeconds}");
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = !_isPlaying;
      });
    });

    // Track current position of the audio
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.setSourceDeviceFile(widget.item.data!["path"]);
      await _audioPlayer.resume();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause_circle : Icons.play_circle,
            size: 40,
          ),
          onPressed: _togglePlayPause,
        ),
        Expanded(
          child: Slider(
            activeColor: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.primary
                : Colors.blue,
            inactiveColor: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                : Colors.grey[300],
            min: 0,
            max: _totalDuration.inMilliseconds.toDouble(),
            value: _currentPosition.inMilliseconds.toDouble(),
            onChanged: (value) async {
              // Seek to the new position in the audio
              final newPosition = Duration(milliseconds: value.toInt() - 1);
              await _audioPlayer.seek(newPosition);
            },
          ),
        ),
        Text(
          _totalDuration.inSeconds == 0
              ? widget.item.data!["duration"]
              : mediaFileDuration(
                  _totalDuration.inSeconds - _currentPosition.inSeconds),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

Widget widgetAudioDetails(ModelItem item, bool showTimestamp) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      WidgetTimeStampPinnedStarred(
        item: item,
        showTimestamp: showTimestamp,
      ),
    ],
  );
}

class WidgetTextWithLinks extends StatefulWidget {
  final String text;
  final TextAlign? align;

  const WidgetTextWithLinks({super.key, required this.text, this.align});

  @override
  State<WidgetTextWithLinks> createState() => _WidgetTextWithLinksState();
}

class _WidgetTextWithLinksState extends State<WidgetTextWithLinks> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeController>(builder: (context, controller, child) {
      return RichText(
        text: TextSpan(
          children: _buildTextWithLinks(context, controller, widget.text),
        ),
        textAlign: widget.align == null ? TextAlign.left : widget.align!,
      );
    });
  }

  List<TextSpan> _buildTextWithLinks(
      BuildContext context, FontSizeController controller, String text) {
    final List<TextSpan> spans = [];
    final RegExp linkRegExp = RegExp(r'(https?://[^\s]+)');
    final matches = linkRegExp.allMatches(text);

    int lastMatchEnd = 0;

    double fontSize = 15;

    for (final match in matches) {
      final start = match.start;
      final end = match.end;

      // Add plain text before the link
      if (start > lastMatchEnd) {
        spans.add(
          TextSpan(
              text: text.substring(lastMatchEnd, start),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: controller.getScaledSize(fontSize))),
        );
      }

      // Add the link text
      final linkText = text.substring(start, end);
      try {
        final linkUri = Uri.parse(linkText);
        spans.add(TextSpan(
          text: linkText,
          style: TextStyle(
              color: Colors.blue, fontSize: controller.getScaledSize(fontSize)),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (await canLaunchUrl(linkUri)) {
                await launchUrl(linkUri);
              } else {
                debugPrint("Could not launch $linkText");
              }
            },
        ));
      } catch (e) {
        spans.add(
          TextSpan(
              text: linkText,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: controller.getScaledSize(fontSize))),
        );
      }

      lastMatchEnd = end;
    }

    // Add the remaining plain text after the last link
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
          text: text.substring(lastMatchEnd),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: controller.getScaledSize(fontSize),
          )));
    }

    return spans;
  }
}

class TimerWidget extends StatefulWidget {
  final int runningState;

  const TimerWidget({
    super.key,
    required this.runningState,
  });

  @override
  State<TimerWidget> createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  late int _secondsElapsed;
  Timer? _timer;
  int runningState = 0;

  @override
  void initState() {
    super.initState();
    _secondsElapsed = 0; // Initialize timer duration
  }

  @override
  void dispose() {
    _timer?.cancel(); // Clean up the timer when the widget is disposed
    super.dispose();
  }

  /// Start the timer
  void start() {
    if (_timer != null && _timer!.isActive) return; // Prevent multiple timers
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  /// Stop the timer
  void stop() {
    _timer?.cancel();
  }

  /// Reset the timer
  void reset() {
    stop();
    setState(() {
      _secondsElapsed = 0;
    });
  }

  String get _formattedTime {
    final minutes = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void setRunningState() {
    if (widget.runningState == 2) {
      stop();
    } else if (widget.runningState == 1) {
      start();
    } else if (widget.runningState == 0) {
      reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    setRunningState();
    return Text(
      _formattedTime,
      style: TextStyle(
        color: Colors.red,
        fontSize: 16.0,
      ),
    );
  }
}

class ColorPickerDialog extends StatefulWidget {
  final String? color;

  const ColorPickerDialog({super.key, this.color});

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color selectedColor = colorFromHex("#06b6d4"); // Default selected color
  double hue = 0.0; // Default hue for the color bar

  @override
  void initState() {
    super.initState();
    if (widget.color != null) {
      selectedColor = colorFromHex(widget.color!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 15.0, // Horizontal spacing between circles
              runSpacing: 15.0, // Vertical spacing between rows
              children: predefinedColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: color,
                    radius: 15, // Fixed size for the circles
                    child: selectedColor == color
                        ? Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Fourth row with color preview and slider
            Row(
              children: [
                // Circle to show the selected color
                CircleAvatar(
                  backgroundColor: selectedColor,
                  radius: 15,
                ),
                const SizedBox(width: 10),

                // Color slider
                Expanded(
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      // HSV gradient as slider background
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                for (double i = 0; i <= 1; i += 0.1)
                                  HSVColor.fromAHSV(1.0, i * 360, 1.0, 1.0)
                                      .toColor()
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),

                      // Actual slider overlay
                      Slider(
                        value: hue,
                        onChanged: (newHue) {
                          setState(() {
                            hue = newHue;
                            selectedColor =
                                HSVColor.fromAHSV(1.0, hue * 360, 1.0, 1.0)
                                    .toColor();
                          });
                        },
                        min: 0.0,
                        max: 1.0,
                        activeColor: Colors.transparent,
                        // Transparent for gradient
                        inactiveColor: Colors.transparent,
                        thumbColor: Colors.transparent,
                        secondaryActiveColor: Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null); // Cancel action
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(selectedColor); // Return selected color
          },
          child: const Text('Ok'),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:ntsapp/services/service_logger.dart';
import 'package:ntsapp/ui/widgets_item.dart';
import 'package:provider/provider.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_bidi_text/flutter_bidi_text.dart';


import '../utils/common.dart';
import '../utils/enums.dart';
import '../models/model_category_group.dart';
import '../models/model_item.dart';
import '../utils/utils_crypto.dart';

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
  final String heroTag;

  const FloatingActionButtonWithBadge({
    super.key,
    required this.filterCount,
    required this.onPressed,
    required this.icon,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      clipBehavior:
          Clip.none, // Allows the badge to be positioned outside the FAB
      children: [
        FloatingActionButton(
          heroTag: heroTag,
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
                size: 14, color: colorFromHex(color).withValues(alpha: 0.8)),
          )
        : Padding(
            padding: const EdgeInsets.all(5.0),
            child: Icon(
              Icons.workspaces,
              color: colorFromHex(color).withValues(alpha: 0.8),
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
  final VoidCallback onPressed;
  final ModelItem item;
  final double iconSize;

  const WidgetVideoImageThumbnail(
      {super.key,
      required this.item,
      required this.iconSize,
      required this.onPressed});

  @override
  State<WidgetVideoImageThumbnail> createState() =>
      _WidgetVideoImageThumbnailState();
}

class _WidgetVideoImageThumbnailState extends State<WidgetVideoImageThumbnail> {
  @override
  Widget build(BuildContext context) {
    bool showPlay = widget.item.state != SyncState.downloadable.value;
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
        VideoPlayDownloadButton(
            iconSize: widget.iconSize,
            onPressed: widget.onPressed,
            showPlay: showPlay),
      ],
    );
  }
}

class WidgetVideoPlayerThumbnail extends StatefulWidget {
  final VoidCallback onPressed;
  final ModelItem item;
  final double iconSize;

  const WidgetVideoPlayerThumbnail(
      {super.key,
      required this.item,
      required this.iconSize,
      required this.onPressed});

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
    bool showPlay = widget.item.state != SyncState.downloadable.value;
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
                  VideoPlayDownloadButton(
                      iconSize: widget.iconSize,
                      onPressed: widget.onPressed,
                      showPlay: showPlay),
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
  final VoidCallback onPressed;
  final ModelItem item;
  final double iconSize;

  const WidgetMediaKitThumbnail(
      {super.key,
      required this.item,
      required this.iconSize,
      required this.onPressed});

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
    bool showPlay = widget.item.state != SyncState.downloadable.value;
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
                  VideoPlayDownloadButton(
                      iconSize: widget.iconSize,
                      onPressed: widget.onPressed,
                      showPlay: showPlay),
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
    int savedDurationSeconds =
        mediaFileDurationFromString(widget.item.data!["duration"]);
    _totalDuration = Duration(seconds: savedDurationSeconds);
    _audioPlayer = AudioPlayer();

    // Load audio file duration
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          if (duration.inMilliseconds > 0) {
            _totalDuration = duration;
          }
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false; // Fixed: Set to false instead of toggling
          _currentPosition = Duration.zero; // Reset position
        });
      }
    });

    // Track current position of the audio
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          // Ensure position is within valid bounds
          if (position < Duration.zero) {
            _currentPosition = Duration.zero;
          } else if (_totalDuration.inMilliseconds > 0 &&
              position.inMilliseconds > _totalDuration.inMilliseconds) {
            _currentPosition = _totalDuration;
          } else {
            _currentPosition = position;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> downloadMedia() async {
    SodiumSumo sodium = await SodiumSumoInit.init();
    CryptoUtils cryptoUtils = CryptoUtils(sodium);
    widget.item.state = SyncState.downloading.value;
    widget.item.update(["state"], pushToSync: false);
    if (mounted) {
      setState(() {});
    }
    bool downloadedDecrypted =
        await cryptoUtils.downloadDecryptFile(widget.item.data!);
    if (downloadedDecrypted) {
      widget.item.state = SyncState.downloaded.value;
      widget.item.update(["state"], pushToSync: false);
      if (mounted) {
        setState(() {});
      }
    } else {
      widget.item.state = SyncState.downloadable.value;
      widget.item.update(["state"], pushToSync: false);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _togglePlayPause() async {
    String filePath = widget.item.data!["path"];
    File audioFile = File(filePath);
    if (!audioFile.existsSync()) {
      if (mounted) {
        showAlertMessage(context, "Please wait", "File not available yet.");
      }
      return;
    }
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.setSourceDeviceFile(filePath);
      await _audioPlayer.resume();
    }
    if (mounted) {
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool displayDownloadButton =
        widget.item.state == SyncState.downloadable.value;

    // Calculate safe slider value to avoid range errors
    double sliderMax = max(_totalDuration.inMilliseconds.toDouble(), 1.0);
    double sliderValue =
        min(max(_currentPosition.inMilliseconds.toDouble(), 0.0), sliderMax);

    return Row(
      children: [
        displayDownloadButton
            ? DownloadButton(
                onPressed: downloadMedia,
                item: widget.item,
                iconSize: 30,
              )
            : IconButton(
                tooltip: "Play/pause",
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
                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)
                : Colors.grey[300],
            min: 0,
            max: sliderMax,
            value: sliderValue,
            onChanged: (value) async {
              // Seek to the new position in the audio
              Duration newPosition = Duration(milliseconds: value.toInt());
              await _audioPlayer.seek(newPosition);

              // Update position immediately for more responsive UI
              if (mounted) {
                setState(() {
                  _currentPosition = newPosition;
                });
              }
            },
          ),
        ),
        Text(
          _currentPosition > Duration.zero
              ? mediaFileDurationFromSeconds(
                  max(0, _totalDuration.inSeconds - _currentPosition.inSeconds))
              : mediaFileDurationFromSeconds(_totalDuration.inSeconds),
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
      return BidiRichText(
        text: TextSpan(
          children: _buildTextWithLinks(context, controller, widget.text),
        ),
        textAlign: widget.align == null ? TextAlign.start : widget.align!,
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
                final logger = AppLogger(
                    prefixes: ["common_widgets", "WidgetTextWithLink"]);
                logger.error("Could not launch $linkText");
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

Future<void> displaySnackBar(BuildContext context,
    {required String message, required int seconds}) async {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      message,
    ),
    duration: Duration(seconds: seconds),
  ));
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

class AnimatedWidgetSwap extends StatefulWidget {
  final Widget firstWidget;
  final Widget secondWidget;
  final bool showFirst;
  final Duration duration;

  const AnimatedWidgetSwap({
    super.key,
    required this.firstWidget,
    required this.secondWidget,
    required this.showFirst,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedWidgetSwap> createState() => _AnimatedWidgetSwapState();
}

class _AnimatedWidgetSwapState extends State<AnimatedWidgetSwap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideOutAnimation;
  late Animation<Offset> _slideInAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideInAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(AnimatedWidgetSwap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showFirst != widget.showFirst) {
      if (widget.showFirst) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SlideTransition(
          position: _slideOutAnimation,
          child: widget.showFirst ? widget.firstWidget : Container(),
        ),
        SlideTransition(
          position: _slideInAnimation,
          child: widget.showFirst ? Container() : widget.secondWidget,
        ),
      ],
    );
  }
}

class AnimatedPageRoute extends PageRouteBuilder {
  final Widget child;

  AnimatedPageRoute({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: const Duration(milliseconds: 150),
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // Animation for the new screen (Child)
    const curve = Curves.linear;
    final childSlideAnimation = Tween(
      begin: const Offset(0.0, 0.02),
      end: Offset.zero,
    ).chain(CurveTween(curve: curve)).animate(animation);

    final childFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).chain(CurveTween(curve: curve)).animate(animation);

    // Animation for the previous screen (Parent)
    final parentScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).chain(CurveTween(curve: curve)).animate(secondaryAnimation);

    final parentFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).chain(CurveTween(curve: curve)).animate(secondaryAnimation);

    return Stack(
      children: [
        // Animate the Parent screen
        FadeTransition(
          opacity: parentFadeAnimation,
          child: ScaleTransition(
            scale: parentScaleAnimation,
            child: Container(), // This will be the parent screen
          ),
        ),
        // Animate the Child screen
        FadeTransition(
          opacity: childFadeAnimation,
          child: SlideTransition(
            position: childSlideAnimation,
            child: child,
          ),
        ),
      ],
    );
  }
}

class UploadDownloadIndicator extends StatefulWidget {
  final double size;
  final bool uploading;
  const UploadDownloadIndicator(
      {super.key, required this.size, required this.uploading});
  @override
  State<UploadDownloadIndicator> createState() =>
      UploadDownloadIndicatorState();
}

class UploadDownloadIndicatorState extends State<UploadDownloadIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Opacity(
        opacity: 0.6,
        child: Icon(
          widget.uploading ? Icons.arrow_upward : Icons.arrow_downward,
          size: widget.size,
        ),
      ),
    );
  }
}

class DownloadButton extends StatefulWidget {
  final VoidCallback onPressed;
  final ModelItem item;
  final double iconSize;

  const DownloadButton({
    super.key,
    required this.item,
    this.iconSize = 30.0,
    required this.onPressed, // Default icon size
  });

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
          width: 2.0,
        ),
      ),
      child: IconButton(
        tooltip: "Download",
        icon: Opacity(
          opacity: 0.5,
          child: Icon(
            Icons.arrow_downward,
            size: widget.iconSize,
          ),
        ),
        onPressed: widget.onPressed,
      ),
    );
  }
}

class VideoPlayDownloadButton extends StatelessWidget {
  final double iconSize;
  final bool showPlay;
  final VoidCallback onPressed;
  const VideoPlayDownloadButton(
      {super.key,
      required this.iconSize,
      required this.showPlay,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        // Semi-transparent grey background
        shape: BoxShape.circle,
      ),
      child: showPlay
          ? Icon(
              LucideIcons.play,
              color: Colors.white,
              size: iconSize / 2,
            )
          : IconButton(
              tooltip: "Download",
              icon: Icon(
                Icons.arrow_downward,
                color: Colors.white,
                size: iconSize / 2,
              ),
              onPressed: onPressed,
            ),
    );
  }
}

class ImageDownloadButton extends StatefulWidget {
  final VoidCallback onPressed;
  final ModelItem item;
  final double iconSize;
  const ImageDownloadButton({
    super.key,
    required this.iconSize,
    required this.item,
    required this.onPressed,
  });

  @override
  State<ImageDownloadButton> createState() => _ImageDownloadButtonState();
}

class _ImageDownloadButtonState extends State<ImageDownloadButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.iconSize,
      height: widget.iconSize,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        // Semi-transparent grey background
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: "Download",
        icon: Icon(
          Icons.arrow_downward,
          color: Colors.white,
          size: widget.iconSize / 2,
        ),
        onPressed: widget.onPressed,
      ),
    );
  }
}

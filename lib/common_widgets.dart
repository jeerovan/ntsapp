import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:ntsapp/widgets_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'common.dart';
import 'model_item.dart';
import 'model_item_group.dart';

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

class WidgetGroup extends StatefulWidget {
  final ModelGroup group;
  final bool showLastItemSummary;

  const WidgetGroup({
    super.key,
    required this.group,
    required this.showLastItemSummary,
  });

  @override
  State<WidgetGroup> createState() => _WidgetGroupState();
}

class _WidgetGroupState extends State<WidgetGroup> {
  @override
  Widget build(BuildContext context) {
    double size = 40;
    ModelGroup item = widget.group;
    return ListTile(
      leading: item.thumbnail == null
          ? Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: colorFromHex(item.color),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              // Center the text inside the circle
              child: Text(
                item.title[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize:
                      size / 2, // Adjust font size relative to the circle size
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : SizedBox(
              width: size,
              height: size,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Center(
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: MemoryImage(item.thumbnail!),
                  ),
                ),
              ),
            ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.pinned == 1)
            const Icon(
              Icons.push_pin_outlined,
              size: 12,
            ),
        ],
      ),
      subtitle: widget.showLastItemSummary
          ? NotePreviewSummary(
              item: item.lastItem,
              showTimestamp: true,
              showImagePreview: false,
              expanded: true,
            )
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
            Icons.play_arrow,
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
                    child: Icon(Icons.play_arrow,
                        color: Colors.white, size: widget.iconSize / 2),
                  ),
                ],
              )
            : Image.file(
                // handle downloading with icon
                File("assets/image.webp"),
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
                      Icons.play_arrow,
                      color: Colors.white,
                      size: widget.iconSize / 2,
                    ),
                  ),
                ],
              )
            : Image.file(
                // handle downloading with icon
                File("assets/image.webp"),
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

    /* _audioPlayer.onPlayerComplete.listen((event){
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }); */
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
            max: _totalDuration.inSeconds.toDouble(),
            value: _currentPosition.inSeconds.toDouble(),
            onChanged: (value) async {
              // Seek to the new position in the audio
              final newPosition = Duration(seconds: value.toInt() - 1);
              await _audioPlayer.seek(newPosition);
            },
          ),
        ),
        Text(
          mediaFileDuration(_currentPosition.inSeconds),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

Widget widgetAudioDetails(ModelItem item) {
  return Row(
    children: [
      // File size text at the left
      Row(
        children: [
          const Icon(Icons.audiotrack, size: 15),
          const SizedBox(
            width: 2,
          ),
          Text(
            item.data!["duration"],
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
      Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              item.data!["name"],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ),
      ),
      WidgetTimeStamp(item: item),
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
    return RichText(
      text: TextSpan(
        children: _buildTextWithLinks(context, widget.text),
      ),
      textAlign: widget.align == null ? TextAlign.left : widget.align!,
    );
  }

  List<TextSpan> _buildTextWithLinks(BuildContext context, String text) {
    final List<TextSpan> spans = [];
    final RegExp linkRegExp = RegExp(r'(https?://[^\s]+)');
    final matches = linkRegExp.allMatches(text);

    int lastMatchEnd = 0;

    for (final match in matches) {
      final start = match.start;
      final end = match.end;

      // Add plain text before the link
      if (start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, start),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      }

      // Add the link text
      final linkText = text.substring(start, end);
      final linkUri = Uri.parse(linkText);
      spans.add(TextSpan(
        text: linkText,
        style: TextStyle(
          color: Colors.blue,
          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            if (await canLaunchUrl(linkUri)) {
              await launchUrl(linkUri);
            } else {
              debugPrint("Could not launch $linkText");
            }
          },
      ));

      lastMatchEnd = end;
    }

    // Add the remaining plain text after the last link
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: Theme.of(context).textTheme.bodyLarge,
      ));
    }

    return spans;
  }
}

Widget iconStarCrossed() {
  return Stack(
    alignment: Alignment.center, // Align icons at the center
    children: [
      const Icon(
        Icons.star_outline_sharp,
      ),
      Transform.rotate(
        angle: 0.785398, // Angle in radians (e.g., 45 degrees = π/4 ≈ 0.785398)
        child: const Icon(
          Icons.horizontal_rule_sharp,
        ),
      ),
    ],
  );
}

Widget iconPinCrossed() {
  return Stack(
    alignment: Alignment.center, // Align icons at the center
    children: [
      const Icon(
        Icons.push_pin_outlined,
      ),
      Transform.rotate(
        angle: 0.785398, // Angle in radians (e.g., 45 degrees = π/4 ≈ 0.785398)
        child: const Icon(
          Icons.horizontal_rule_sharp,
        ),
      ),
    ],
  );
}

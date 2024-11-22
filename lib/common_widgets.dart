import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'common.dart';
import 'package:video_player/video_player.dart';

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

class WidgetVideo extends StatefulWidget {
  final String videoPath;
  const WidgetVideo({super.key,required this.videoPath});

  @override
  State<WidgetVideo> createState() => _WidgetVideoState();
}
class _WidgetVideoState extends State<WidgetVideo> {
  late final VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath));
    initialize();
  }

  Future<void> initialize() async {
    await _controller.initialize();
    _chewieController = ChewieController(
                          videoPlayerController: _controller,
                          autoPlay: true,
                          looping: true,
                        );
    setState(() {
      
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
            padding: const EdgeInsets.all(20),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  _chewieController == null ? const SizedBox.shrink() : Chewie(controller: _chewieController!),
                  //_ControlsOverlay(controller: _controller),
                  //VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
            ),
          );
  }
}

class WidgetVideoThumbnail extends StatefulWidget {
  final String videoPath;

  const WidgetVideoThumbnail({super.key, required this.videoPath});

  @override
  State<WidgetVideoThumbnail> createState() => _WidgetVideoThumbnailState();
}

class _WidgetVideoThumbnailState extends State<WidgetVideoThumbnail> {
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.7), // Semi-transparent grey background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              )
            : Image.file(
                File("assets/image.webp"),
                fit: BoxFit.cover, // Ensures the image covers the available space
              )
        : const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: CircularProgressIndicator()),
        );
  }
}

class WidgetAudio extends StatefulWidget {
  final ModelItem item;
  const WidgetAudio({super.key,required this.item});
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
      if(mounted) {
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
              final newPosition = Duration(seconds: value.toInt()-1);
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

Widget widgetAudioDetails(ModelItem item){
  final String formattedTime = getFormattedTime(item.at!);
  return Row(
    children: [
      // File size text at the left
      Row(
        children: [
          const Icon(Icons.audiotrack,size: 15),
          const SizedBox(width: 2,),
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
              style: const TextStyle( fontSize: 15),
            ),
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          item.starred == 1 ? const Icon(Icons.star,size: 10,) : const SizedBox.shrink(),
          const SizedBox(width:5),
          Text(
            formattedTime,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    ],
  );
}

class WidgetTextWithLinks extends StatefulWidget {
  final String text;
  final TextAlign? align;
  const WidgetTextWithLinks({super.key,required this.text,this.align});

  @override
  State<WidgetTextWithLinks> createState() => _WidgetTextWithLinksState();
}

class _WidgetTextWithLinksState extends State<WidgetTextWithLinks> {
  @override
  Widget build(BuildContext context) {
    return RichText(
          softWrap: true,
          overflow: TextOverflow.visible,
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
        spans.add(TextSpan(
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
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
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

Widget iconStarCrossed(){
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
Widget iconPinCrossed(){
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
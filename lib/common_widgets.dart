import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
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
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath));

    _controller.addListener(() {
      if (mounted)setState(() {});}
    );
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                  VideoPlayer(_controller),
                  _ControlsOverlay(controller: _controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
            ),
          );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  static const List<Duration> _exampleCaptionOffsets = <Duration>[
    Duration(seconds: -10),
    Duration(seconds: -3),
    Duration(seconds: -1, milliseconds: -500),
    Duration(milliseconds: -250),
    Duration.zero,
    Duration(milliseconds: 250),
    Duration(seconds: 1, milliseconds: 500),
    Duration(seconds: 3),
    Duration(seconds: 10),
  ];
  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : const ColoredBox(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topLeft,
          child: PopupMenuButton<Duration>(
            initialValue: controller.value.captionOffset,
            tooltip: 'Caption Offset',
            onSelected: (Duration delay) {
              controller.setCaptionOffset(delay);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<Duration>>[
                for (final Duration offsetDuration in _exampleCaptionOffsets)
                  PopupMenuItem<Duration>(
                    value: offsetDuration,
                    child: Text('${offsetDuration.inMilliseconds}ms'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
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
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.7), // Semi-transparent grey background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
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
      Text(
        formattedTime,
        style: const TextStyle(fontSize: 10),
      ),
    ],
  );
}
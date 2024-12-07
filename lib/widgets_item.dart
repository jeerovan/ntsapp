import 'package:flutter/material.dart';
import 'package:ntsapp/enum_item_type.dart';
import 'package:ntsapp/model_setting.dart';

import 'common.dart';
import 'common_widgets.dart';
import 'model_item.dart';

class ItemWidgetDate extends StatefulWidget {
  final ModelItem item;

  const ItemWidgetDate({super.key, required this.item});

  @override
  State<ItemWidgetDate> createState() => _ItemWidgetDateState();
}

class _ItemWidgetDateState extends State<ItemWidgetDate> {
  @override
  Widget build(BuildContext context) {
    String dateText = getReadableDate(
        DateTime.fromMillisecondsSinceEpoch(widget.item.at!, isUtc: true));
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min, // Shrinks to fit the text width
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              dateText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WidgetTimeStamp extends StatefulWidget {
  final ModelItem item;

  const WidgetTimeStamp({super.key, required this.item});

  @override
  State<WidgetTimeStamp> createState() => _WidgetTimeStampState();
}

class _WidgetTimeStampState extends State<WidgetTimeStamp> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        widget.item.pinned == 1
            ? Icon(Icons.push_pin,
                size: 10, color: Theme.of(context).colorScheme.inversePrimary)
            : const SizedBox.shrink(),
        const SizedBox(width: 2),
        widget.item.starred == 1
            ? Icon(Icons.star,
                size: 11, color: Theme.of(context).colorScheme.inversePrimary)
            : const SizedBox.shrink(),
        const SizedBox(width: 3),
        Text(
          getFormattedTime(widget.item.at!),
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}

class ItemWidgetText extends StatefulWidget {
  final ModelItem item;

  const ItemWidgetText({super.key, required this.item});

  @override
  State<ItemWidgetText> createState() => _ItemWidgetTextState();
}

class _ItemWidgetTextState extends State<ItemWidgetText> {
  bool isRTL = ModelSetting.getForKey("rtl", "no") == "yes";

  @override
  Widget build(BuildContext context) {
    ModelItem item = widget.item;
    return Column(
      crossAxisAlignment:
          isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        WidgetTextWithLinks(text: item.text),
        const SizedBox(height: 5),
        WidgetTimeStamp(item: item),
      ],
    );
  }
}

class ItemWidgetImage extends StatefulWidget {
  final ModelItem item;
  final Function(ModelItem) onTap;

  const ItemWidgetImage({super.key, required this.item, required this.onTap});

  @override
  State<ItemWidgetImage> createState() => _ItemWidgetImageState();
}

class _ItemWidgetImageState extends State<ItemWidgetImage> {
  @override
  Widget build(BuildContext context) {
    ModelItem item = widget.item;
    double size = 200;
    return GestureDetector(
      onTap: () {
        widget.onTap(item);
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: size,
              child: Image.memory(
                item.thumbnail!,
                width: double.infinity, // Full width of container
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    // Transparent black at the top
                    Colors.black.withOpacity(0.3),
                    // Darker black at the bottom
                  ],
                ),
              ),
              child: WidgetTimeStamp(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemWidgetVideo extends StatefulWidget {
  final ModelItem item;
  final Function(ModelItem) onTap;

  const ItemWidgetVideo({super.key, required this.item, required this.onTap});

  @override
  State<ItemWidgetVideo> createState() => _ItemWidgetVideoState();
}

class _ItemWidgetVideoState extends State<ItemWidgetVideo> {
  @override
  Widget build(BuildContext context) {
    ModelItem item = widget.item;
    double size = 200;
    return GestureDetector(
      onTap: () {
        widget.onTap(item);
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: size,
              height: size / item.data!["aspect"],
              child: WidgetVideoThumbnail(videoPath: item.data!["path"]),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            width: size,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    // Transparent black at the top
                    Colors.black.withOpacity(0.3),
                    // Darker black at the bottom
                  ],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // File size text at the left
                  Row(
                    children: [
                      const Icon(Icons.videocam, size: 20),
                      const SizedBox(
                        width: 2,
                      ),
                      Text(
                        item.data!["duration"],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                  WidgetTimeStamp(item: item),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemWidgetAudio extends StatefulWidget {
  final ModelItem item;

  const ItemWidgetAudio({
    super.key,
    required this.item,
  });

  @override
  State<ItemWidgetAudio> createState() => _ItemWidgetAudioState();
}

class _ItemWidgetAudioState extends State<ItemWidgetAudio> {
  @override
  Widget build(BuildContext context) {
    ModelItem item = widget.item;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WidgetAudio(item: item),
        widgetAudioDetails(item),
      ],
    );
  }
}

class ItemWidgetDocument extends StatefulWidget {
  final ModelItem item;
  final Function(ModelItem) onTap;

  const ItemWidgetDocument(
      {super.key, required this.item, required this.onTap});

  @override
  State<ItemWidgetDocument> createState() => _ItemWidgetDocumentState();
}

class _ItemWidgetDocumentState extends State<ItemWidgetDocument> {
  @override
  Widget build(BuildContext context) {
    ModelItem item = widget.item;
    return GestureDetector(
      onTap: () {
        widget.onTap(item);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        //mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.insert_drive_file,
                size: 40,
              ),
              Expanded(
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
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // File size text at the left
              Text(
                readableBytes(item.data!["size"]),
                style: const TextStyle(fontSize: 10),
              ),
              WidgetTimeStamp(item: item),
            ],
          ),
        ],
      ),
    );
  }
}

class ItemWidgetLocation extends StatefulWidget {
  final ModelItem item;
  final Function(ModelItem) onTap;

  const ItemWidgetLocation(
      {super.key, required this.item, required this.onTap});

  @override
  State<ItemWidgetLocation> createState() => _ItemWidgetLocationState();
}

class _ItemWidgetLocationState extends State<ItemWidgetLocation> {
  @override
  Widget build(BuildContext context) {
    ModelItem item = widget.item;
    return GestureDetector(
      onTap: () {
        widget.onTap(item);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.location_on,
                color: Colors.blue,
                size: 40,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "Location",
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          WidgetTimeStamp(item: item),
        ],
      ),
    );
  }
}

class ItemWidgetContact extends StatefulWidget {
  final ModelItem item;
  final Function(ModelItem) onTap;

  const ItemWidgetContact({super.key, required this.item, required this.onTap});

  @override
  State<ItemWidgetContact> createState() => _ItemWidgetContactState();
}

class _ItemWidgetContactState extends State<ItemWidgetContact> {
  @override
  Widget build(BuildContext context) {
    ModelItem item = widget.item;
    return GestureDetector(
      onTap: () {
        widget.onTap(item);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: item.thumbnail != null
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: MemoryImage(item.thumbnail!),
                      )
                    : const CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person, size: 50),
                      ),
              ),
              // Name Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${item.data!["name"]}'.trim(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              // Phones Row
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.blue),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...item.data!["phones"].map((phone) => Text(
                              phone,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ))
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              // Emails Row (if available)
              if (item.data!["emails"].isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.email, size: 16, color: Colors.red),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...item.data!["emails"].map((email) => (Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              )))
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 5),
              // Addresses Row (if available)
              if (item.data!["addresses"].isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.home, size: 16, color: Colors.green),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...item.data!["addresses"].map((address) => (Text(
                                address,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ))),
                        ],
                      ),
                    ),
                  ],
                ),
              WidgetTimeStamp(item: item),
            ],
          ),
        ),
      ),
    );
  }
}

class NotePreviewSummary extends StatelessWidget {
  final ModelItem? item;
  final bool? showTimestamp;
  final bool? showImagePreview;
  final bool? expanded;

  const NotePreviewSummary({
    super.key,
    this.item,
    this.showTimestamp,
    this.showImagePreview,
    this.expanded,
  });

  IconData _getIcon() {
    if (item == null) {
      return Icons.notes;
    } else {
      switch (item!.type) {
        case ItemType.text:
          return Icons.notes;
        case ItemType.image:
          return Icons.image;
        case ItemType.video:
          return Icons.videocam;
        case ItemType.audio:
          return Icons.audiotrack;
        case ItemType.contact:
          return Icons.contact_phone;
        case ItemType.location:
          return Icons.location_on;
        case ItemType.task:
          return Icons.radio_button_unchecked;
        case ItemType.completedTask:
          return Icons.check_circle;
        default: // Document
          return Icons.description;
      }
    }
  }

  String _getMessageText() {
    if (item == null) {
      return "So empty...";
    } else {
      switch (item!.type) {
        case ItemType.text:
          return item!.text; // Text content
        case ItemType.image:
        case ItemType.video:
        case ItemType.audio:
        case ItemType.document:
          return item!.data!["name"]; // File name for media types
        case ItemType.contact:
          return item!.data!["name"]; // Contact name
        case ItemType.location:
          return "Location";
        case ItemType.task:
        case ItemType.completedTask:
          return item!.text;
        default:
          return "Unknown";
      }
    }
  }

  Widget _previewImage(ModelItem item) {
    switch (item.type) {
      case ItemType.image:
      case ItemType.video:
      case ItemType.contact:
        return item.thumbnail == null
            ? const SizedBox.shrink()
            : ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  width: 40,
                  child: Image.memory(
                    item.thumbnail!, // Full width of container
                    fit: BoxFit.cover,
                  ),
                ),
              );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getIcon(),
          size: 13,
        ),
        const SizedBox(width: 5),
        expanded == true
            ? Expanded(
                child: Text(
                  _getMessageText(),
                  overflow: TextOverflow.ellipsis, // Ellipsis for long text
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              )
            : Flexible(
                child: Text(
                  _getMessageText(),
                  overflow: TextOverflow.ellipsis, // Ellipsis for long text
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
        const SizedBox(width: 8),
        if (showImagePreview!) _previewImage(item!),
        const SizedBox(width: 8),
        if (showTimestamp!)
          Text(
            item == null ? "" : getFormattedTime(item!.at!),
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
      ],
    );
  }
}

class ItemWidgetTask extends StatefulWidget {
  final ModelItem item;

  const ItemWidgetTask({super.key, required this.item});

  @override
  State<ItemWidgetTask> createState() => _ItemWidgetTaskState();
}

class _ItemWidgetTaskState extends State<ItemWidgetTask> {
  @override
  Widget build(BuildContext context) {
    ModelItem item = widget.item;
    bool isRTL = ModelSetting.getForKey("rtl", "no") == "yes";
    return Column(
      crossAxisAlignment:
          isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.item.type == ItemType.completedTask
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: widget.item.type == ItemType.task
                  ? Theme.of(context).colorScheme.inversePrimary
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Flexible(child: WidgetTextWithLinks(text: widget.item.text)),
          ],
        ),
        const SizedBox(height: 5),
        WidgetTimeStamp(item: item),
      ],
    );
  }
}

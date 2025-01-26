import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/enums.dart';
import 'package:path/path.dart' as path;

import 'common.dart';
import 'common_widgets.dart';
import 'model_item.dart';

class ItemWidgetDate extends StatelessWidget {
  final ModelItem item;

  const ItemWidgetDate({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    String dateText = getReadableDate(
        DateTime.fromMillisecondsSinceEpoch(item.at!, isUtc: true));
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min, // Shrinks to fit the text width
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Opacity(
                opacity: 0.3,
                child: Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}

class WidgetTimeStampPinnedStarred extends StatelessWidget {
  final ModelItem item;
  final bool showTimestamp;

  const WidgetTimeStampPinnedStarred(
      {super.key, required this.item, required this.showTimestamp});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        item.pinned == 1
            ? Icon(LucideIcons.pin,
                size: 12, color: Theme.of(context).colorScheme.inversePrimary)
            : const SizedBox.shrink(),
        const SizedBox(width: 2),
        item.starred == 1
            ? Icon(LucideIcons.star,
                size: 12, color: Theme.of(context).colorScheme.inversePrimary)
            : const SizedBox.shrink(),
        const SizedBox(width: 4),
        if (showTimestamp)
          Opacity(
            opacity: 0.6,
            child: Text(
              getFormattedTime(item.at!),
              style: const TextStyle(fontSize: 10),
            ),
          ),
      ],
    );
  }
}

class ItemWidgetText extends StatelessWidget {
  final ModelItem item;
  final bool showTimestamp;

  const ItemWidgetText(
      {super.key, required this.item, required this.showTimestamp});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(width: 4),
        Flexible(child: WidgetTextWithLinks(text: item.text)),
        WidgetTimeStampPinnedStarred(
          item: item,
          showTimestamp: showTimestamp,
        ),
      ],
    );
  }
}

class ItemWidgetTask extends StatelessWidget {
  final ModelItem item;
  final bool showTimestamp;

  const ItemWidgetTask(
      {super.key, required this.item, required this.showTimestamp});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: WidgetTextWithLinks(text: item.text)),
              const SizedBox(width: 8),
              Icon(
                item.type == ItemType.completedTask
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: item.type == ItemType.task
                    ? Theme.of(context).colorScheme.inversePrimary
                    : Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
        WidgetTimeStampPinnedStarred(item: item, showTimestamp: showTimestamp)
      ],
    );
  }
}

class ItemWidgetImage extends StatelessWidget {
  final ModelItem item;
  final Function(ModelItem) onTap;
  final bool showTimestamp;

  const ItemWidgetImage(
      {super.key,
      required this.item,
      required this.onTap,
      required this.showTimestamp});

  @override
  Widget build(BuildContext context) {
    double size = 200;
    return GestureDetector(
      onTap: () {
        onTap(item);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: size,
              child: item.thumbnail == null
                  ? Image.asset(
                      "assets/image.webp",
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.memory(
                      item.thumbnail!,
                      width: double.infinity, // Full width of container
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          WidgetTimeStampPinnedStarred(
            item: item,
            showTimestamp: showTimestamp,
          ),
        ],
      ),
    );
  }
}

class ItemWidgetVideo extends StatelessWidget {
  final ModelItem item;
  final Function(ModelItem) onTap;
  final bool showTimestamp;

  const ItemWidgetVideo(
      {super.key,
      required this.item,
      required this.onTap,
      required this.showTimestamp});

  @override
  Widget build(BuildContext context) {
    double size = 200;
    return GestureDetector(
      onTap: () {
        onTap(item);
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: size,
              height: size / item.data!["aspect"],
              child: item.thumbnail == null
                  ? canUseVideoPlayer
                      ? WidgetVideoPlayerThumbnail(
                          item: item,
                          iconSize: 40,
                        )
                      : WidgetMediaKitThumbnail(
                          item: item,
                          iconSize: 40,
                        )
                  : WidgetVideoImageThumbnail(
                      item: item,
                      iconSize: 40,
                    ),
            ),
          ),
          SizedBox(
            width: size,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // File size text at the left
                Row(
                  children: [
                    const Icon(LucideIcons.video, size: 20),
                    const SizedBox(
                      width: 2,
                    ),
                    Text(
                      item.data!["duration"],
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
                WidgetTimeStampPinnedStarred(
                  item: item,
                  showTimestamp: showTimestamp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ItemWidgetAudio extends StatelessWidget {
  final ModelItem item;
  final bool showTimestamp;

  const ItemWidgetAudio({
    super.key,
    required this.item,
    required this.showTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WidgetAudio(item: item),
        widgetAudioDetails(item, showTimestamp),
      ],
    );
  }
}

class ItemWidgetDocument extends StatelessWidget {
  final ModelItem item;
  final Function(ModelItem) onTap;
  final bool showTimestamp;

  const ItemWidgetDocument(
      {super.key,
      required this.item,
      required this.onTap,
      required this.showTimestamp});

  @override
  Widget build(BuildContext context) {
    String title = item.data!.containsKey("title")
        ? item.data!["title"]
        : item.data!["name"];
    return GestureDetector(
      onTap: () {
        onTap(item);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        //mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.file,
                size: 40,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
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
                readableFileSizeFromBytes(item.data!["size"]),
                style: const TextStyle(fontSize: 10),
              ),
              WidgetTimeStampPinnedStarred(
                item: item,
                showTimestamp: showTimestamp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ItemWidgetLocation extends StatelessWidget {
  final ModelItem item;
  final Function(ModelItem) onTap;
  final bool showTimestamp;

  const ItemWidgetLocation(
      {super.key,
      required this.item,
      required this.onTap,
      required this.showTimestamp});

  @override
  Widget build(BuildContext context) {
    double size = 200;
    return GestureDetector(
      onTap: () {
        onTap(item);
      },
      child: SizedBox(
        width: size,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  LucideIcons.mapPin,
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
            WidgetTimeStampPinnedStarred(
              item: item,
              showTimestamp: showTimestamp,
            ),
          ],
        ),
      ),
    );
  }
}

class ItemWidgetContact extends StatelessWidget {
  final ModelItem item;
  final Function(ModelItem) onTap;
  final bool showTimestamp;

  const ItemWidgetContact(
      {super.key,
      required this.item,
      required this.onTap,
      required this.showTimestamp});

  @override
  Widget build(BuildContext context) {
    double size = 200;
    return GestureDetector(
      onTap: () {
        onTap(item);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: size,
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
                        child: Icon(LucideIcons.user, size: 50),
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
                  const Icon(LucideIcons.phone, size: 16, color: Colors.blue),
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
                    Icon(LucideIcons.mail, size: 16, color: Colors.red),
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
                    Icon(LucideIcons.home, size: 16, color: Colors.green),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  WidgetTimeStampPinnedStarred(
                    item: item,
                    showTimestamp: showTimestamp,
                  ),
                ],
              ),
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

  String _getMessageText() {
    if (item == null) {
      return "Empty";
    } else {
      switch (item!.type) {
        case ItemType.text:
          return item!.text; // Text content
        case ItemType.image:
          return "Image";
        case ItemType.video:
          return "Video";
        case ItemType.audio:
          return "Audio";
        case ItemType.document:
          return "Document";
        case ItemType.contact:
          return "Contact";
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
        /* Icon(
          _getIcon(),
          size: 13,
          color: Colors.grey,
        ),
        const SizedBox(width: 5), */
        expanded == true
            ? Expanded(
                child: Text(
                  _getMessageText(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Ellipsis for long text
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              )
            : Flexible(
                child: Text(
                  _getMessageText(),
                  maxLines: 1,
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

class NoteUrlPreview extends StatelessWidget {
  final String itemId;
  final String imageDirectory;
  final Map<String, dynamic> urlInfo;

  const NoteUrlPreview(
      {super.key,
      required this.urlInfo,
      required this.itemId,
      required this.imageDirectory});

  @override
  Widget build(BuildContext context) {
    String fileName = '$itemId-urlimage.png';
    String filePath = path.join(imageDirectory, fileName);
    File imageFile = File(filePath);
    bool imageAvailable = imageFile.existsSync();
    bool portrait = urlInfo["portrait"] == 1 ? true : false;
    if (imageAvailable) {}
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.start, // For desktops
      children: [
        if (!portrait)
          Image.file(
            imageFile,
            height: 100,
            fit: BoxFit.contain,
          ),
        ListTile(
          leading: imageAvailable && portrait
              ? Image.file(
                  imageFile,
                  width: 80,
                  fit: BoxFit.contain,
                )
              : null,
          title: urlInfo["title"] == null
              ? null
              : Text(
                  urlInfo["title"],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
          subtitle: urlInfo["desc"] == null
              ? null
              : Text(
                  urlInfo["desc"],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ],
    );
  }
}

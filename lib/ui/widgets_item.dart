import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/utils/enums.dart';
import 'package:path/path.dart' as path;
import 'package:sodium_libs/sodium_libs_sumo.dart';

import '../utils/common.dart';
import 'common_widgets.dart';
import '../models/model_item.dart';
import '../utils/utils_crypto.dart';

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

  Widget itemStateIcon(ModelItem item) {
    if (item.state == SyncState.uploading.value) {
      return UploadDownloadIndicator(uploading: true, size: 12);
    } else if (item.state == SyncState.downloading.value) {
      return UploadDownloadIndicator(uploading: false, size: 12);
    } else if (item.state == SyncState.uploaded.value ||
        item.state == SyncState.downloaded.value ||
        item.state == SyncState.downloadable.value) {
      return Opacity(
        opacity: 0.6,
        child: Icon(
          LucideIcons.check,
          size: 12,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

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
        const SizedBox(
          width: 2,
        ),
        itemStateIcon(item),
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

class ItemWidgetText extends StatefulWidget {
  final ModelItem item;
  final bool showTimestamp;

  const ItemWidgetText(
      {super.key, required this.item, required this.showTimestamp});

  @override
  State<ItemWidgetText> createState() => _ItemWidgetTextState();
}

class _ItemWidgetTextState extends State<ItemWidgetText> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(width: 4),
        Flexible(child: WidgetTextWithLinks(text: widget.item.text)),
        WidgetTimeStampPinnedStarred(
          item: widget.item,
          showTimestamp: widget.showTimestamp,
        ),
      ],
    );
  }
}

class ItemWidgetTask extends StatefulWidget {
  final ModelItem item;
  final bool showTimestamp;

  const ItemWidgetTask(
      {super.key, required this.item, required this.showTimestamp});

  @override
  State<ItemWidgetTask> createState() => _ItemWidgetTaskState();
}

class _ItemWidgetTaskState extends State<ItemWidgetTask> {
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
              Flexible(child: WidgetTextWithLinks(text: widget.item.text)),
              const SizedBox(width: 8),
              Icon(
                widget.item.type == ItemType.completedTask
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: widget.item.type == ItemType.task
                    ? Theme.of(context).colorScheme.inversePrimary
                    : Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
        WidgetTimeStampPinnedStarred(
            item: widget.item, showTimestamp: widget.showTimestamp)
      ],
    );
  }
}

class ItemWidgetImage extends StatefulWidget {
  final ModelItem item;
  final Function(ModelItem) onTap;
  final bool showTimestamp;

  const ItemWidgetImage(
      {super.key,
      required this.item,
      required this.onTap,
      required this.showTimestamp});

  @override
  State<ItemWidgetImage> createState() => _ItemWidgetImageState();
}

class _ItemWidgetImageState extends State<ItemWidgetImage> {
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

  @override
  Widget build(BuildContext context) {
    bool displayDownloadButton =
        widget.item.state == SyncState.downloadable.value;
    double size = 200;
    return GestureDetector(
      onTap: () {
        widget.onTap(widget.item);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: size,
              child: widget.item.thumbnail == null
                  ? Image.asset(
                      "assets/image.webp",
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.memory(
                          widget.item.thumbnail!,
                          width: double.infinity, // Full width of container
                          fit: BoxFit.cover,
                        ),
                        if (displayDownloadButton)
                          ImageDownloadButton(
                              item: widget.item,
                              onPressed: downloadMedia,
                              iconSize: 50)
                      ],
                    ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          WidgetTimeStampPinnedStarred(
            item: widget.item,
            showTimestamp: widget.showTimestamp,
          ),
        ],
      ),
    );
  }
}

class ItemWidgetVideo extends StatefulWidget {
  final ModelItem item;
  final Function(ModelItem) onTap;
  final bool showTimestamp;

  const ItemWidgetVideo(
      {super.key,
      required this.item,
      required this.onTap,
      required this.showTimestamp});

  @override
  State<ItemWidgetVideo> createState() => _ItemWidgetVideoState();
}

class _ItemWidgetVideoState extends State<ItemWidgetVideo> {
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

  @override
  Widget build(BuildContext context) {
    double size = 200;
    return GestureDetector(
      onTap: () {
        widget.onTap(widget.item);
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: size,
              height: size / widget.item.data!["aspect"],
              child: widget.item.thumbnail == null
                  ? canUseVideoPlayer
                      ? WidgetVideoPlayerThumbnail(
                          onPressed: downloadMedia,
                          item: widget.item,
                          iconSize: 50,
                        )
                      : WidgetMediaKitThumbnail(
                          onPressed: downloadMedia,
                          item: widget.item,
                          iconSize: 50,
                        )
                  : WidgetVideoImageThumbnail(
                      onPressed: downloadMedia,
                      item: widget.item,
                      iconSize: 50,
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
                    Opacity(
                        opacity: 0.6,
                        child: const Icon(LucideIcons.video, size: 20)),
                    const SizedBox(
                      width: 2,
                    ),
                    Opacity(
                      opacity: 0.6,
                      child: Text(
                        widget.item.data!["duration"],
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                WidgetTimeStampPinnedStarred(
                  item: widget.item,
                  showTimestamp: widget.showTimestamp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ItemWidgetAudio extends StatefulWidget {
  final ModelItem item;
  final bool showTimestamp;

  const ItemWidgetAudio({
    super.key,
    required this.item,
    required this.showTimestamp,
  });

  @override
  State<ItemWidgetAudio> createState() => _ItemWidgetAudioState();
}

class _ItemWidgetAudioState extends State<ItemWidgetAudio> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WidgetAudio(item: widget.item),
        widgetAudioDetails(widget.item, widget.showTimestamp),
      ],
    );
  }
}

class ItemWidgetDocument extends StatefulWidget {
  final ModelItem item;
  final Function(ModelItem) onTap;
  final bool showTimestamp;

  const ItemWidgetDocument(
      {super.key,
      required this.item,
      required this.onTap,
      required this.showTimestamp});

  @override
  State<ItemWidgetDocument> createState() => _ItemWidgetDocumentState();
}

class _ItemWidgetDocumentState extends State<ItemWidgetDocument> {
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

  @override
  Widget build(BuildContext context) {
    bool displayDownloadButton =
        widget.item.state == SyncState.downloadable.value;
    String title = widget.item.data!.containsKey("title")
        ? widget.item.data!["title"]
        : widget.item.data!["name"];
    return GestureDetector(
      onTap: () {
        widget.onTap(widget.item);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        //mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              displayDownloadButton
                  ? Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: DownloadButton(
                        onPressed: downloadMedia,
                        item: widget.item,
                        iconSize: 30,
                      ),
                    )
                  : Opacity(
                      opacity: 0.6,
                      child: const Icon(
                        LucideIcons.file,
                        size: 40,
                      ),
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
              Opacity(
                opacity: 0.6,
                child: Text(
                  readableFileSizeFromBytes(widget.item.data!["size"]),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
              WidgetTimeStampPinnedStarred(
                item: widget.item,
                showTimestamp: widget.showTimestamp,
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

class NoteUrlPreview extends StatefulWidget {
  final String itemId;
  final String imageDirectory;
  final Map<String, dynamic> urlInfo;

  const NoteUrlPreview(
      {super.key,
      required this.urlInfo,
      required this.itemId,
      required this.imageDirectory});

  @override
  State<NoteUrlPreview> createState() => _NoteUrlPreviewState();
}

class _NoteUrlPreviewState extends State<NoteUrlPreview> {
  bool removed = false;

  Future<void> remove() async {
    removed = await ModelItem.removeUrlInfo(widget.itemId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String fileName = '${widget.itemId}-urlimage.png';
    String filePath = path.join(widget.imageDirectory, fileName);
    File imageFile = File(filePath);
    bool imageAvailable = imageFile.existsSync();
    bool portrait = widget.urlInfo["portrait"] == 1 ? true : false;
    if (imageAvailable) {}
    return removed
        ? const SizedBox.shrink()
        : Stack(
            alignment: Alignment.topRight,
            children: [
              Column(
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
                    title: widget.urlInfo["title"] == null
                        ? null
                        : Text(
                            widget.urlInfo["title"],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                    subtitle: widget.urlInfo["desc"] == null
                        ? null
                        : Text(
                            widget.urlInfo["desc"],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ],
              ),
              IconButton(onPressed: remove, icon: Icon(Icons.close))
            ],
          );
  }
}

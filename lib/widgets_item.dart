

import 'package:flutter/material.dart';

import 'common.dart';
import 'common_widgets.dart';
import 'model_item.dart';

class ItemWidgetDate extends StatefulWidget {
  final ModelItem item;
  const ItemWidgetDate({super.key,required this.item});

  @override
  State<ItemWidgetDate> createState() => _ItemWidgetDateState();
}

class _ItemWidgetDateState extends State<ItemWidgetDate> {
  @override
  Widget build(BuildContext context) {
    String dateText = getReadableDate(DateTime.fromMillisecondsSinceEpoch(widget.item.at! * 1000, isUtc: true));
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

class ItemWidgetText extends StatefulWidget {
  final ModelItem item;
  const ItemWidgetText({super.key,required this.item});

  @override
  State<ItemWidgetText> createState() => _ItemWidgetTextState();
}

class _ItemWidgetTextState extends State<ItemWidgetText> {
  @override
  Widget build(BuildContext context) {
    ModelItem item = widget.item;
    final String formattedTime = getFormattedTime(item.at!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          item.text,
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
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
}

class ItemWidgetImage extends StatefulWidget {
  final ModelItem item;
  final Function(ModelItem) onTap;
  const ItemWidgetImage({
    super.key,
    required this.item,
    required this.onTap});

  @override
  State<ItemWidgetImage> createState() => _ItemWidgetImageState();
}

class _ItemWidgetImageState extends State<ItemWidgetImage> {
  @override
  Widget build(BuildContext context) {
    ModelItem item = widget.item;
    double size = 200;
    final String formattedTime = getFormattedTime(item.at!);
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
                    Colors.black.withOpacity(0.1), // Transparent black at the top
                    Colors.black.withOpacity(0.3), // Darker black at the bottom
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  item.starred == 1 ? const Icon(Icons.star,size: 10,) : const SizedBox.shrink(),
                  const SizedBox(width:5),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
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
  const ItemWidgetVideo({
    super.key,
    required this.item,
    required this.onTap});

  @override
  State<ItemWidgetVideo> createState() => _ItemWidgetVideoState();
}

class _ItemWidgetVideoState extends State<ItemWidgetVideo> {
  @override
  Widget build(BuildContext context) {
    ModelItem item = widget.item;
    double size = 200;
    final String formattedTime = getFormattedTime(item.at!);
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
              height: size/item.data!["aspect"],
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
                    Colors.black.withOpacity(0.1), // Transparent black at the top
                    Colors.black.withOpacity(0.3), // Darker black at the bottom
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
                      const SizedBox(width: 2,),
                      Text(
                        item.data!["duration"],
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      item.starred == 1 ? const Icon(Icons.star,size: 10,) : const SizedBox.shrink(),
                      const SizedBox(width:5),
                      Text(
                        formattedTime,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
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
  const ItemWidgetDocument({
    super.key,
    required this.item,
    required this.onTap});

  @override
  State<ItemWidgetDocument> createState() => _ItemWidgetDocumentState();
}

class _ItemWidgetDocumentState extends State<ItemWidgetDocument> {
  @override
  Widget build(BuildContext context) {
    ModelItem item = widget.item;
    final String formattedTime = getFormattedTime(item.at!);
    return GestureDetector(
      onTap: (){
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
                    style: const TextStyle( fontSize: 15),
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
          ),
        ],
      ),
    );
  }
}

class ItemWidgetLocation extends StatefulWidget {
  final ModelItem item;
  final Function(ModelItem) onTap;
  const ItemWidgetLocation({
    super.key,
    required this.item,
    required this.onTap});

  @override
  State<ItemWidgetLocation> createState() => _ItemWidgetLocationState();
}

class _ItemWidgetLocationState extends State<ItemWidgetLocation> {
  @override
  Widget build(BuildContext context) {
    ModelItem item = widget.item;
    final String formattedTime = getFormattedTime(item.at!);
    return GestureDetector(
      onTap: (){
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
              SizedBox(width: 5,),
              Text(
                "Location",
                style: TextStyle( fontSize: 15),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              item.starred == 1 ? const Icon(Icons.star,size: 10,) : const SizedBox.shrink(),
              const SizedBox(width:5),
              Text(
                formattedTime,
                style: const TextStyle( fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ItemWidgetContact extends StatefulWidget {
  final ModelItem item;
  final Function(ModelItem) onTap;
  const ItemWidgetContact({
    super.key,
    required this.item,
    required this.onTap});

  @override
  State<ItemWidgetContact> createState() => _ItemWidgetContactState();
}

class _ItemWidgetContactState extends State<ItemWidgetContact> {
  @override
  Widget build(BuildContext context) {
    ModelItem item = widget.item;
    final String formattedTime = getFormattedTime(item.at!);
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
                child:item.thumbnail != null
                ? CircleAvatar(
                    radius: 50,
                    backgroundImage: MemoryImage(item.thumbnail!),
                  )
                : const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person,size:50),
                  ),
              ),
              // Name Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${item.data!["name"]}'.trim(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
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
                        ...item.data!["phones"].map((phone) => 
                        Text(
                          phone,
                          style: const TextStyle(fontSize: 14,),
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
                          ...item.data!["emails"].map((email) => (
                            Text(
                              email,
                              style: const TextStyle(fontSize: 14,),
                              overflow: TextOverflow.ellipsis,
                            )
                          ))
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
                          ...item.data!["addresses"].map((address) => (
                          Text(
                            address,
                            style: const TextStyle(fontSize: 14,),
                            overflow: TextOverflow.ellipsis,
                          )
                          )),
                        ],
                      ),
                    ),
                  ],
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
          ),
        ),
      ),
    );
  }
}
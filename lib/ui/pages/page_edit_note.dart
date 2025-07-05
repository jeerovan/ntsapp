import 'package:flutter/material.dart';
import 'package:ntsapp/utils/enums.dart';
import 'package:ntsapp/models/model_item.dart';
import 'package:ntsapp/services/service_events.dart';

import '../../utils/common.dart';

class PageEditNote extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  final String itemId;

  const PageEditNote(
      {super.key,
      required this.itemId,
      required this.runningOnDesktop,
      this.setShowHidePage});

  @override
  State<PageEditNote> createState() => _PageEditNoteState();
}

class _PageEditNoteState extends State<PageEditNote> {
  final TextEditingController controller = TextEditingController();
  ModelItem? item;
  @override
  void initState() {
    super.initState();
    loadText();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> loadText() async {
    ModelItem? dbItem = await ModelItem.get(widget.itemId);
    if (dbItem != null) {
      item = dbItem;
      setState(() {
        controller.text = dbItem.text;
      });
    }
  }

  Future<void> saveItem(String text) async {
    if (item != null && text.isNotEmpty) {
      item!.text = text.trim();
      await item!.update(["text"]);
      EventStream()
          .publish(AppEvent(type: EventType.changedItemId, value: item!.id));
      if (widget.runningOnDesktop) {
        widget.setShowHidePage!(PageType.editNote, false, PageParams());
      } else {
        if (mounted) Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit",
          style: TextStyle(fontSize: 18),
        ),
        leading: widget.runningOnDesktop
            ? BackButton(
                onPressed: () {
                  widget.setShowHidePage!(
                      PageType.editNote, false, PageParams());
                },
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
            maxLines: null,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            onSubmitted: saveItem,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: "save_note",
        onPressed: () {
          saveItem(controller.text);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

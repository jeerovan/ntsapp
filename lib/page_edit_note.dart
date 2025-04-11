import 'package:flutter/material.dart';

class PageEditNote extends StatefulWidget {
  final String noteText;

  const PageEditNote({super.key, required this.noteText});

  @override
  State<PageEditNote> createState() => _PageEditNoteState();
}

class _PageEditNoteState extends State<PageEditNote> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        controller.text = widget.noteText;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
              maxLines: null,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

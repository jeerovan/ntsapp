import 'package:flutter/material.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PageDummy extends StatefulWidget {
  const PageDummy({super.key});

  @override
  State<PageDummy> createState() => _PageDummyState();
}

class _PageDummyState extends State<PageDummy> {
  AppLogger logger = AppLogger(prefixes: ["PageDummy"]);
  bool processing = true;
  String response = "";
  String text = "";
  SupabaseClient supabaseClient = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> simulate() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Page Dummy"),
      ),
      body: Column(
        children: [
          if (processing) CircularProgressIndicator(),
          Text(text),
          ElevatedButton(
              onPressed: simulate,
              child: Text(
                "Simulate",
                style: TextStyle(color: Colors.black),
              )),
        ],
      ),
    );
  }
}

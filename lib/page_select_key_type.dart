import 'package:flutter/material.dart';
import 'package:ntsapp/app_config.dart';
import 'package:ntsapp/page_access_key_notice.dart';
import 'package:ntsapp/page_password_key_create.dart';

import 'enums.dart';

class PageSelectKeyType extends StatefulWidget {
  const PageSelectKeyType({super.key});

  @override
  State<PageSelectKeyType> createState() => _PageSelectKeyTypeState();
}

class _PageSelectKeyTypeState extends State<PageSelectKeyType> {
  bool welcomed = false;
  String appName = AppConfig.get(AppString.appName.string);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(welcomed ? 'Important' : 'Hello'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: welcomed
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'To encrypt your data, we’ll need a master encryption key.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'There are 2 options - either you create a key yourself (similar to password) or we create it for you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'In either case, you’ll be responsible for keeping it safe. If it’s lost/forgotten, it cannot be recovered and you’ll lose all your data.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => PageAccessKeyNotice(),
                        ),
                      );
                    },
                    child: Text(
                      'Create the key for me',
                    ),
                  ),
                  SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => PagePasswordKeyCreate(),
                        ),
                      );
                    },
                    child: Text(
                      'I’ll create the key myself',
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Welcome to $appName',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'We use end-to-end encryption to make sure that all of your notes are safe and no one else can see them, not even us.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Time to start the encryption!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        welcomed = true;
                      });
                    },
                    child: Text(
                      'Next',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

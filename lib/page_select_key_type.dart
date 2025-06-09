import 'package:flutter/material.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/model_preferences.dart';
import 'package:ntsapp/page_access_key_notice.dart';
import 'package:ntsapp/page_password_key_create.dart';
import 'package:ntsapp/storage_secure.dart';

import 'common.dart';
import 'enums.dart';

class PageSelectKeyType extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  const PageSelectKeyType(
      {super.key, required this.runningOnDesktop, this.setShowHidePage});

  @override
  State<PageSelectKeyType> createState() => _PageSelectKeyTypeState();
}

class _PageSelectKeyTypeState extends State<PageSelectKeyType> {
  SecureStorage secureStorage = SecureStorage();
  bool welcomed = false;
  bool agreedTerms = false;
  String? appName = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialize();
    });
  }

  Future<void> initialize() async {
    appName = await secureStorage.read(key: AppString.appName.string);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final edgeToEdgePadding = MediaQuery.of(context).padding;
    return Scaffold(
      appBar: AppBar(
        leading: widget.runningOnDesktop
            ? BackButton(
                onPressed: () {
                  widget.setShowHidePage!(
                      PageType.selectKeyType, false, PageParams());
                },
              )
            : null,
        title: Text(welcomed ? 'Important' : 'Hello'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + edgeToEdgePadding.bottom),
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
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Checkbox(
                        value: agreedTerms,
                        onChanged: (bool? value) {
                          setState(() {
                            agreedTerms = value ?? false;
                          });
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      const Expanded(
                        child: Text(
                          'I understand that if I lose/forget encryption key, I may lose the data.',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (agreedTerms) {
                        ModelPreferences.set(
                            AppString.encryptionKeyType.string, "key");
                        if (widget.runningOnDesktop) {
                          widget.setShowHidePage!(
                              PageType.accessKeyCreate, true, PageParams());
                          widget.setShowHidePage!(
                              PageType.selectKeyType, false, PageParams());
                        } else {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => PageAccessKeyNotice(
                                runningOnDesktop: widget.runningOnDesktop,
                                setShowHidePage: widget.setShowHidePage,
                              ),
                            ),
                          );
                        }
                      } else {
                        displaySnackBar(context,
                            message: "Please acknowledge!", seconds: 2);
                      }
                    },
                    child: Column(
                      children: [
                        Text(
                          'Create the key for me',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text('(Recommended)',
                            style: TextStyle(
                                fontSize: 10,
                                color: const Color.fromARGB(255, 53, 53, 53))),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      if (agreedTerms) {
                        ModelPreferences.set(
                            AppString.encryptionKeyType.string, "password");
                        if (widget.runningOnDesktop) {
                          widget.setShowHidePage!(PageType.passwordCreate, true,
                              PageParams(recreatePassword: false));
                          widget.setShowHidePage!(
                              PageType.selectKeyType, false, PageParams());
                        } else {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => PagePasswordKeyCreate(
                                runningOnDesktop: false,
                                recreate: false,
                              ),
                            ),
                          );
                        }
                      } else {
                        displaySnackBar(context,
                            message: "Please acknowledge!", seconds: 2);
                      }
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
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

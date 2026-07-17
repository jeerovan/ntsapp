import 'package:flutter/material.dart';
import 'package:ntsapp/l10n/app_localizations.dart';
import 'package:ntsapp/ui/common_widgets.dart';
import 'package:ntsapp/models/model_preferences.dart';
import 'package:ntsapp/ui/pages/page_access_key_notice.dart';
import 'package:ntsapp/ui/pages/page_password_key_create.dart';
import 'package:ntsapp/storage/storage_secure.dart';

import '../../utils/common.dart';
import '../../utils/enums.dart';

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
    final loc = AppLocalizations.of(context)!;
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
        title: Text(welcomed ? loc.importantTitle : loc.helloTitle),
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
                    loc.selectKeyMasterKeyDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 20),
                  Text(
                    loc.selectKeyTwoOptionsDescription,
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
                      Expanded(
                        child: Text(
                          loc.understandLoseKeyAcknowledgement,
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
                            message: loc.pleaseAcknowledgeMessage, seconds: 2);
                      }
                    },
                    child: Column(
                      children: [
                        Text(
                          loc.createKeyForMeButtonLabel,
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(loc.recommendedLabel,
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
                            message: loc.pleaseAcknowledgeMessage, seconds: 2);
                      }
                    },
                    child: Text(
                      loc.createKeyMyselfButtonLabel,
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
                    loc.welcomeToAppName(appName ?? ""),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 20),
                  Text(
                    loc.e2eEncryptionDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 20),
                  Text(
                    loc.timeToStartEncryptionLabel,
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
                      loc.nextButtonLabel,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

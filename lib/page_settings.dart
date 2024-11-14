
import 'package:flutter/material.dart';
import 'package:ntsapp/model_setting.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import 'common.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  const SettingsPage({super.key,required this.isDarkMode,required this.onThemeToggle});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool _isMove = ModelSetting.getForKey("move_file", false);
  
  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
                title: const Text("Settings"),
              ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.contrast),
            title: const Text("Theme"),
            onTap: widget.onThemeToggle,
            trailing: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  // Use both fade and rotation transitions
                  return FadeTransition(
                    opacity: animation,
                    child: RotationTransition(
                      turns: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  key: ValueKey(widget.isDarkMode ? 'dark' : 'light'), // Unique key for AnimatedSwitcher
                  color: widget.isDarkMode ? Colors.orange : Colors.black,
                ),
              ),
              onPressed: (){},
            ),
          ),
          ListTile(
            leading: const Icon(Icons.file_copy),
            title: const Text('Files to NTS'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Copy",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: !_isMove ? Colors.blue : Colors.grey,
                  ),
                ),
                Switch(
                  value: _isMove,
                  onChanged: (value) {
                    setState(() {
                      _isMove = value;
                      ModelSetting.update("move_file", value);
                    });
                  },
                ),
                Text(
                  "Move",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _isMove ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rate App'),
            onTap: () => _redirectToFeedback(),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {_share();},
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final version = snapshot.data?.version ?? '';
                final buildNumber = snapshot.data?.buildNumber ?? '';
                return ListTile(
                  leading: const Icon(Icons.info),
                  title: Text('App Version: $version+$buildNumber'),
                  onTap: null,
                );
              } else {
                return const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Loading...'),
                );
              }
            },
          ),
        ],
      )
    );
  }

  void _redirectToFeedback() {
    const url = 'https://play.google.com/store/apps/details?id=com.makenotetoself';
    // Use your package name
    openURL(url);
  }

  void _share() {
    const String appLink = 'https://play.google.com/store/apps/details?id=com.makenotetoself';
    Share.share("Make a note to yourself: $appLink");
  }
}
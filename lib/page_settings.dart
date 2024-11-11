
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  const SettingsPage({super.key,required this.isDarkMode,required this.onThemeToggle});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  
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
            title: const Text("Theme"),
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
              onPressed: widget.onThemeToggle,
            ),
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
}
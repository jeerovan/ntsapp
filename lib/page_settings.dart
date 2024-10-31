
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'globals.dart';
import 'model_setting.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key,});

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
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          ListTile(
            title: const Text('Show all items'),
            trailing: Switch(
              value: ModelSetting.getForKey("show_all", false),
              onChanged: (bool value) {
                setState(() {
                  ModelSetting.update("show_all",value);
                });
              },
            ),
          ),
          const Divider(indent: 10.0,endIndent: 10.0,),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            onTap: () => _redirectToFeedback(),
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Github'),
            onTap: () => _redirectToGithub(),
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
    const url = 'https://play.google.com/store/apps/details?id=com.forget.it';
    // Use your package name
    openURL(url);
  }

  void _redirectToGithub() {
    const url = 'https://github.com/jeerovan/forgetit';
    // Use your package name
    openURL(url);
  }
}
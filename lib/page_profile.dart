import 'package:flutter/material.dart';
import 'page_profile_edit.dart';
import 'common.dart';

import 'model_profile.dart';

class ProfilePage extends StatefulWidget {
  final Function(String) onSelect;
  const ProfilePage({super.key,required this.onSelect});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void addEditProfile(String? profileId){
    Navigator.of(context)
    .push(MaterialPageRoute(
      builder: (context) => AddEditProfile(
        profileId: profileId,
        onUpdate: (){setState(() {
          
        });},
        ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    double size = 100;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profiles"),
      ),
      body: FutureBuilder(
        future: ModelProfile.all(), 
        builder: (context,snapshot){
          if (snapshot.connectionState == ConnectionState.done) {
            List<ModelProfile> profiles = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                   const Text("Tap to select Or long press to edit",
                      style: TextStyle(fontSize: 15,),
                    ),
                    const SizedBox(height: 16,),
                    Center(
                      child: Wrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        children: profiles.map((profile) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                    widget.onSelect(profile.id!);
                                    Navigator.of(context).pop();
                                  },
                                  onLongPress: () {
                                    addEditProfile(profile.id!);
                                  },
                                child: profile.thumbnail == null
                                  ? Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      color: colorFromHex(profile.color),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center, // Center the text inside the circle
                                    child: Text(
                                      profile.title[0].toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: size / 2, // Adjust font size relative to the circle size
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                  width: size,
                                  height: size,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Center(
                                        child: CircleAvatar(
                                          radius: size/2,
                                          backgroundImage: MemoryImage(profile.thumbnail!),
                                        ),
                                      ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(profile.title),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16,),
                    Center(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            addEditProfile(null);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(10),
                          ),
                          child: const Icon(Icons.add, size: 30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Scaffold();
          }
        }
      )
    );
  }
}

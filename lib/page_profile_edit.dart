import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'model_profile.dart';
import 'package:image_picker/image_picker.dart';

import 'common.dart';

class AddEditProfile extends StatefulWidget {
  final String? profileId;
  final Function() onUpdate;
  const AddEditProfile({super.key,this.profileId,required this.onUpdate});

  @override
  State<AddEditProfile> createState() => _AddEditProfileState();
}

class _AddEditProfileState extends State<AddEditProfile> {
  final TextEditingController profileController = TextEditingController();

  ModelProfile? profile;
  Uint8List? image;
  String title = "";

  bool processing = false;
  bool itemChanged = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (widget.profileId != null){
      ModelProfile? existingProfile = await ModelProfile.get(widget.profileId!);
      if (existingProfile != null){
        setState(() {
          profile = existingProfile;
          image = profile!.thumbnail;
          title = profile!.title;
          profileController.text = profile!.title;
        });
      }
    }
  }

  Future<void> _getPicture(ImageSource source) async {
    final pickedFile =
        await ImagePicker().pickImage(source: source);
    setState(() {
      processing = true;
    });
    if (pickedFile != null) {
      Uint8List bytes = await File(pickedFile.path).readAsBytes();
      image = await compute(getImageThumbnail, bytes);
      itemChanged = true;
    }
    setState(() {
      processing = false;
    });
  }
  Future<void> _showMediaPickerDialog() async {
    if(ImagePicker().supportsImageSource(ImageSource.camera)){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Choose image source"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Gallery"),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getPicture(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text("Camera"),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getPicture(ImageSource.camera);
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      await _getPicture(ImageSource.gallery);
    }
  }

  void saveProfile() async {
    if (itemChanged && title.isNotEmpty){
      if (profile == null){
        int count = await ModelProfile.getCount();
        Color color = getMaterialColor(count+1);
        String hexCode = colorToHex(color);
        ModelProfile newProfile = await ModelProfile.fromMap({"title":title,"color":hexCode,"thumbnail":image});
        await newProfile.insert();
      } else {
        profile!.thumbnail = image;
        profile!.title = title;
        await profile!.update();
      }
      widget.onUpdate();
    }
    if(mounted)Navigator.of(context).pop();
  }

  Widget getBoxContent() {
    double size = 100;
    if (processing) {
        return  const CircularProgressIndicator();
    } else if (image != null) {
        return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: CircleAvatar(
                      radius: 50,
                      backgroundImage: MemoryImage(image!),
                    ),
                ),
              ),
          );
    } else if (title.isNotEmpty){
      return Text(
              title[0].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: size / 2, // Adjust font size relative to the circle size
                fontWeight: FontWeight.bold,
              ),
            );
    } else {
      return const Text("Tap here.",style: TextStyle(color: Colors.black),);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String task = profile == null ? "Add" : "Edit";
    double size = 100;
    Color circleColor = profile == null ? const Color.fromARGB(255, 207, 207, 207) : colorFromHex(profile!.color);
    return Scaffold(
      appBar: AppBar(
        title: Text("$task Profile",style: const TextStyle(fontSize: 20,)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20,),
          Expanded(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    _showMediaPickerDialog();
                  },
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center, // Center the text inside the circle
                    child: Center(
                      child: getBoxContent()
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: profileController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Profile Title', // Placeholder
                    ),
                    onChanged: (value) {
                      title = value.trim();
                      itemChanged = true;
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              color: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.check),
              onPressed: () {
                saveProfile();
              },
            ),
          ),
        ],
      ),
    );
  }
}
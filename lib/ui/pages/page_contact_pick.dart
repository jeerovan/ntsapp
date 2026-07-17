import 'package:flutter/material.dart';
import 'package:ntsapp/l10n/app_localizations.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

class PageContacts extends StatefulWidget {
  const PageContacts({super.key});

  @override
  State<PageContacts> createState() => _PageContactsState();
}

class _PageContactsState extends State<PageContacts> {
  List<Contact>? _contacts;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchContacts();
    });
  }

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission()) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts(
          withProperties: true, withThumbnail: true);
      setState(() => _contacts = contacts);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(title: Text(loc.pickContactTitle)), body: _body());
  }

  Widget _body() {
    final loc = AppLocalizations.of(context)!;
    if (_permissionDenied) {
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.permissionRequiredText,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                openAppSettings(); // Open app settings on tap
              },
              child: Text(
                loc.grantPermissionButtonLabel,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      );
    }
    if (_contacts == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      itemCount: _contacts!.length,
      itemBuilder: (context, index) {
        Contact contact = _contacts![index];

        return ListTile(
          leading: contact.thumbnail != null
              ? CircleAvatar(
                  backgroundImage: MemoryImage(contact.thumbnail!),
                )
              : const CircleAvatar(
                  child: Icon(LucideIcons.userCircle),
                ),
          title: Text(
            contact.displayName.trim(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: contact.phones.map((phone) {
              return Text(phone.number);
            }).toList(),
          ),
          onTap: () async {
            Navigator.of(context).pop(contact);
          },
        );
      },
    );
  }
}

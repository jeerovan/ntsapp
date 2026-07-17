import 'package:flutter/material.dart';
import 'package:ntsapp/l10n/app_localizations.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

  Future<void> _fetchContacts() async {
    final status =
        await FlutterContacts.permissions.request(PermissionType.readWrite);

    // Support both granted and limited permissions (important on iOS/macOS)
    if (status == PermissionStatus.granted ||
        status == PermissionStatus.limited) {
      final contacts = await FlutterContacts.getAll(properties: {
        ContactProperty.name,
        ContactProperty.phone,
        ContactProperty.photoThumbnail,
      });
      setState(() => _contacts = contacts);
    } else {
      setState(() => _permissionDenied = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.pickContactTitle)),
      body: _body(),
    );
  }

  Widget _body() {
    final loc = AppLocalizations.of(context)!;
    if (_permissionDenied) {
      // FIXED: Added missing 'return' statement here
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.permissionRequiredText,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Using the native API instead of the external permission_handler
                FlutterContacts.permissions.openSettings();
              },
              child: Text(
                loc.grantPermissionButtonLabel,
                style: const TextStyle(color: Colors.black),
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
          leading: CircleAvatar(
            backgroundImage: contact.photo?.thumbnail != null
                ? MemoryImage(contact.photo!.thumbnail!)
                : null,
            child: contact.photo?.thumbnail == null
                ? const Icon(LucideIcons.userCircle)
                : null,
          ),
          title: Text(
            contact.displayName ?? "",
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
          onTap: () {
            Navigator.of(context).pop(contact);
          },
        );
      },
    );
  }
}

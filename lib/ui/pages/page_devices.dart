import 'package:flutter/material.dart';
import 'package:ntsapp/utils/common.dart';
import 'package:ntsapp/ui/common_widgets.dart';
import 'package:ntsapp/utils/enums.dart';
import 'package:ntsapp/models/model_preferences.dart';
import 'package:ntsapp/services/service_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PageDevices extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  const PageDevices(
      {super.key, required this.runningOnDesktop, this.setShowHidePage});

  @override
  State<PageDevices> createState() => _PageDevicesState();
}

class _PageDevicesState extends State<PageDevices> {
  AppLogger logger = AppLogger(prefixes: ["PageDevices"]);
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> devices = [];
  bool processing = true;

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    try {
      final response = await supabase
          .from('devices')
          .select('id, title, last_at, status')
          .order('status', ascending: false)
          .order('last_at', ascending: false);

      if (response.isNotEmpty) {
        setState(() {
          devices = List<Map<String, dynamic>>.from(response);
          processing = false;
        });
      } else {
        setState(() {
          processing = false;
        });
      }
    } catch (e, s) {
      logger.error("fetching Devices", error: e, stackTrace: s);
    }
  }

  Future<void> disableDevice(String deviceId) async {
    try {
      setState(() {
        processing = true;
      });
      await supabase.functions
          .invoke("remove_device", body: {"deviceId": deviceId});
      if (mounted) {
        displaySnackBar(context, message: 'Device disabled!', seconds: 2);
        fetchDevices(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        displaySnackBar(context, message: 'Please try again!', seconds: 2);
      }
    } finally {
      if (mounted) {
        setState(() {
          processing = false;
        });
      }
    }
  }

  Future<void> showDisableDialog(String deviceId) async {
    String? thisDeviceId =
        await ModelPreferences.get(AppString.deviceId.string);
    if (thisDeviceId != null && deviceId == thisDeviceId && mounted) {
      displaySnackBar(context,
          message: "Can't remove this device!", seconds: 2);
      return;
    }
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Remove"),
        content:
            Text("Are you sure? This will delete all the data on the device."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              disableDevice(deviceId);
            },
            child: Text("OK", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registered Devices"),
        leading: widget.runningOnDesktop
            ? BackButton(
                onPressed: () {
                  widget.setShowHidePage!(
                      PageType.devices, false, PageParams());
                },
              )
            : null,
      ),
      body: processing
          ? Center(child: CircularProgressIndicator())
          : devices.isEmpty
              ? Center(child: Text("No devices found"))
              : ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    final bool isEnabled = device['status'] == 1;
                    String lastAt = getFormattedDateTime(device["last_at"]);
                    return ListTile(
                      title: Text(device['title'], style: TextStyle()),
                      subtitle: Text(
                        lastAt,
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isEnabled ? "Enabled" : "Disabled",
                            style: TextStyle(
                                color: isEnabled ? Colors.green : Colors.red),
                          ),
                          if (isEnabled) // Show disable button only if enabled
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => showDisableDialog(device['id']),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

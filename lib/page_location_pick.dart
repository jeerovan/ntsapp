import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:ntsapp/common.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng _selectedLocation = const LatLng(20.5937, 78.9629);
  late MapController _mapController;
  bool serviceEnabled = false;
  double zoomLevel = 13.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getLastLocation();
  }

  Future<void> _getLastLocation() async {
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    Position? position = await Geolocator.getLastKnownPosition();
    if (position != null) {
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_selectedLocation, zoomLevel);
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Permission Required"),
          content: const Text(
              "Please enable location permissions in the app settings."),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Open Settings"),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  void _showServiceDisabled() {
    showAlertMessage(context, "Location Services", "Please enable!");
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      _showServiceDisabled();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        _showPermissionDeniedDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      _showPermissionDeniedDialog();
      return;
    }

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    // Get current location
    Position position =
        await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    // position is null, shows sentry
    // ignore: unnecessary_null_comparison
    if (position != null) {
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        serviceEnabled = true;
      });
      // Move the map to the current location
      _mapController.move(_selectedLocation, zoomLevel);
    }
  }

  // Function to handle map tap for location selection
  void _onMapTap(LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select location"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop(_selectedLocation);
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _selectedLocation,
          // Default location if current location not available
          initialZoom: 5.0,
          onTap: (tapPosition, latLng) =>
              _onMapTap(latLng), // Set location on map tap
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: _selectedLocation,
              child: const Icon(
                Icons.location_on,
                color: Color.fromARGB(255, 255, 7, 7),
              ),
            ),
          ]),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        tooltip: "Use current location",
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

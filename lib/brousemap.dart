import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {}; // Use Set to store unique markers
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _fetchScooterLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fetchScooterLocation() {
    // Listen for changes in the scooter location data from Firebase
    _database.child("scooter").onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      
      // Check if data contains lat and lang
      if (data != null && data["lat"] != null && data["lang"] != null) {
        final scooterLat = data["lat"];
        final scooterLng = data["lang"];

        // Update markers whenever the scooter location changes
        setState(() {
          _markers.clear(); // Clear existing markers before adding new ones
          _markers.add(Marker(
            markerId: MarkerId("scooter"),
            position: LatLng(scooterLat, scooterLng),
            infoWindow: InfoWindow(
              title: "Scooter",
              snippet: "Location of the scooter",
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Scooter Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Back to previous screen
        ),
      ),
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(8.361005073025808, 80.50334762480115), // Default location
            zoom: 15.0,
          ),
          markers: _markers, // Display markers on the map
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
        ),
      ),
    );
  }
}

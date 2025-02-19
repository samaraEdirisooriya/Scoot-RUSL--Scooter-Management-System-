import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:free_map/free_map.dart';



class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  Set<Marker> _markers = {};
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
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
      if (data != null && data["lat"] != null && data["lang"] != null) {
        final scooterLat = data["lat"];
        final scooterLng = data["lang"];

        // Update markers whenever the scooter location changes
        setState(() {
          _markers.add(Marker(
            point: LatLng(scooterLat, scooterLng),
            child: const Icon(
              size: 40.0,
              color: Colors.red,
              Icons.location_on_rounded,
            ),
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
        child: Stack(
          children: [
            _map, // Display map
          ],
        ),
      ),
    );
  }

  // Full-screen map widget
  Widget get _map {
    return FmMap(
      mapController: _mapController,
      mapOptions: MapOptions(
        minZoom: 15,
        maxZoom: 18,
        initialZoom: 15,
        initialCenter: LatLng(37.4165849896396, -122.08051867783071), // Example initial location
      ),
      markers: _markers.toList(),
    );
  }
}

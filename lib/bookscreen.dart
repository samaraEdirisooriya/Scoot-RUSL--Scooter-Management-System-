import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:free_map/free_map.dart';

class MapScreen2 extends StatefulWidget {
  const MapScreen2({super.key});

  @override
  State<MapScreen2> createState() => _MapScreen2State();
}

class _MapScreen2State extends State<MapScreen2> {
  late final MapController _mapController;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Set<Marker> _markers = {}; // Holds all markers
  Map<String, dynamic>? scooterData;

  // Default parking location
  static const LatLng _parkingLocation = LatLng(8.360983843415836, 80.50287555604814);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeMarkers(); // Load initial markers
    fetchScooter(); // Fetch real-time scooter data
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // Add initial parking marker
  void _initializeMarkers() {
    setState(() {
      _markers.add(
        Marker(
          width: 300,
          height: 300,
          point: _parkingLocation,
          child: Container(
            width: 100,
            height: 100,
            
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20)
            ),
          )
        ),
      );
    });
  }

  // Fetch scooter location from Firebase
  void fetchScooter() {
    _database.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null && data["availability"] == true) {
        print("Data from Firebase: $data");

        setState(() {
          scooterData = {
            "name": data["name"],
            "lat": data["lat"],
            "lang": data["lang"],
            "owneruid": data["owneruid"],
            "parkingopen": data["parkingopen"],
          };
          _mapController.move(
            LatLng(scooterData!['lat'], scooterData!['lang']),
            18, // Zoom level (adjust as needed)
          );
          LatLng scooterLocation = LatLng(scooterData!['lat'], scooterData!['lang']);

          // Update markers (Parking + Scooter)
          _markers = {
           Marker(
          width: 100,
          height: 100,
          point: _parkingLocation,
          child: Container(
            width: 100,
            height: 100,
            color: Colors.red,
          )
        ),
            Marker(
              width: 90,
              height: 90,
              point: scooterLocation,
              child: Image.asset("images/New Project (10).png"),
            ),
          };

          print("Updated Markers: $_markers"); // Debugging

          // Adjust the map to show both markers
          _updateMapView();
        });
      }
    });
  }

  // Adjusts the map to center between both markers
  void _updateMapView() {
    if (_markers.length < 2) return; // Ensure we have both markers

    List<LatLng> points = _markers.map((m) => m.point).toList();

    // Compute center
    double avgLat = (points[0].latitude + points[1].latitude) / 2;
    double avgLng = (points[0].longitude + points[1].longitude) / 2;
    LatLng center = LatLng(avgLat, avgLng);

    // Move map to the center with an appropriate zoom level
    _mapController.move(center, 19); // Adjust zoom level as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Scooter Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _map, // Display map with markers
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
        initialZoom: 19,
        initialCenter: _parkingLocation, // Default map center
      ),
      markers: _markers.toList(), // Convert Set to List for the map
    );
  }
}

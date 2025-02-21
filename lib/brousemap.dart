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
  Map<String, dynamic>? scooterData;

  // 🅿️ Fixed Parking Location
  static const LatLng _parkingLocation = LatLng(8.361005073025808, 80.50334762480115);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeMarkers(); // Load fixed markers
    fetchScooter(); // Fetch real-time scooter data
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _initializeMarkers() {
    setState(() {
      _markers.add(
        Marker(
          point: _parkingLocation,
          child: const Icon(
            Icons.local_parking,
            size: 40.0,
            color: Colors.blue,
          ),
        ),
      );
    });
  }

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

          LatLng scooterLocation = LatLng(scooterData!['lat'], scooterData!['lang']);

          // 🏍️ Update Markers: Keep Parking + Scooter
          _markers = {
           
            Marker(
              height: 100,
              width: 100,
              point: scooterLocation,
              child: Image.asset("images/New Project (10).png"),
            ),
          };

          print("Updated Markers: $_markers"); // Debugging

          // Move camera to focus on the scooter location
          _mapController.move(scooterLocation, 18);
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

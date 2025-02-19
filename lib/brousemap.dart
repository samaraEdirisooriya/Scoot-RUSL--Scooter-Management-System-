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

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    fetchScooter();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();

  }

 void fetchScooter() {
  _database.onValue.listen((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;
    if (data != null) {
      print("Data from Firebase: $data");
      if (data["availability"] == true) {
        setState(() {
          scooterData = {
            "name": data["name"],
            "lat": data["lat"],
            "lang": data["lang"],
            "owneruid": data["owneruid"],
            "parkingopen": data["parkingopen"],
          };
        });
      }
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
        initialCenter: LatLng(8.361005073025808, 80.50334762480115), // Default initial location
      ),
      markers:[
       
        Marker(
          point: LatLng(scooterData!['lat'], scooterData!['lang']),
          child: const Icon(
            size: 40.0,
            color: Colors.red,
            Icons.location_on_rounded,
          ),
        ),
      ], // Pass the markers as a list
    );
  }
}

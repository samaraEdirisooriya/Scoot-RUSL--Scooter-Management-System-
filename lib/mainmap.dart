import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:scootrusl/parkingqrcoode.dart';
import 'package:scootrusl/qrcode.dart';

class MapScreen3 extends StatefulWidget {
  const MapScreen3({super.key});

  @override
  State<MapScreen3> createState() => _MapScreen3State();
}

class _MapScreen3State extends State<MapScreen3> {
  late final MapController _mapController;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Set<Marker> _markers = {}; // Holds all markers
  List<LatLng> _polylinePoints = []; // Holds polyline points
  Map<String, dynamic>? scooterData;

  // Fixed Locations
  static const LatLng _parkingLocation =
      LatLng(8.360983843415836, 80.50287555604814);
  static const LatLng _fixedLocation =
      LatLng(8.361500, 80.503000); // Another fixed location

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

  // Add initial markers
  void _initializeMarkers() {
    setState(() {
      _markers.add(
        Marker(
          width: 600,
          height: 600,
          point: _parkingLocation,
          child: Container(
            width: 600,
            height: 600,
            decoration: BoxDecoration(
              color: const Color.fromARGB(47, 244, 67, 54),
              borderRadius: BorderRadius.circular(600),
              border: Border.all(color: Colors.black, width: 3),
            ),
          ),
        ),
      );

      _markers.add(
        Marker(
          width: 100,
          height: 100,
          point: _fixedLocation,
          child: const Icon(
            Icons.location_pin,
            size: 40.0,
            color: Colors.green,
          ),
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

          // Convert latitude and longitude strings to double
          double? lat = double.tryParse(scooterData!["lat"].toString());
          double? lang = double.tryParse(scooterData!["lang"].toString());

          if (lat != null && lang != null) {
            LatLng scooterLocation = LatLng(lat, lang);

            // Update markers
            _markers = {
              Marker(
                width: 600,
                height: 600,
                point: _parkingLocation,
                child: Container(
                  width: 600,
                  height: 600,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(47, 244, 67, 54),
                    borderRadius: BorderRadius.circular(600),
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                ),
              ),
              Marker(
                width: 100,
                height: 100,
                point: _fixedLocation,
                child: const Icon(
                  Icons.location_pin,
                  size: 40.0,
                  color: Colors.green,
                ),
              ),
              Marker(
                width: 90,
                height: 90,
                point: scooterLocation,
                child: Image.asset("images/New Project (10).png"),
              ),
            };

            // Update polyline points
            _polylinePoints = [_fixedLocation, scooterLocation];

            print("Updated Markers: $_markers"); // Debugging

            // Adjust the map to focus on the scooter location
            _mapController.move(scooterLocation, 18);
          } else {
            print("Invalid latitude or longitude");
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _map, // Display map with markers and polyline
          ],
        ),
      ),
    );
  }

  // Full-screen map widget
  Widget get _map {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            minZoom: 15,
            maxZoom: 18,
            initialZoom: 19,
            initialCenter: _parkingLocation, // Default map center
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _polylinePoints,
                  strokeWidth: 3,
                  color: Colors.blue,
                ),
              ],
            ),
            MarkerLayer(markers: _markers.toList()),
          ],
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.greenAccent, Colors.cyan],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(100)),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 200),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QRScannerScreen1()));
                    },
                    child: Container(
                      width: 100,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(240, 197, 243, 185),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: const Center(child: Text('Park Now')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Image.asset(
            'images/project covwer.png',
            height: 250,
            fit: BoxFit.cover,
          ),
        ),
        
      ],
    );
  }
}

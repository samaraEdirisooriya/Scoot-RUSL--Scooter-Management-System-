import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:free_map/free_map.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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

  // Device location
  LatLng? _deviceLocation;

  // Stream subscription for real-time location updates


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
// Cancel the stream subscription
    super.dispose();
  }

  // Add initial markers
  void _initializeMarkers() {
    setState(() {
      _markers = {
        // Parking Location Marker
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

        // Blue Dot for Device Location (if available)
        if (_deviceLocation != null)
          Marker(
            width: 40,
            height: 40,
            point: _deviceLocation!,
            child: Container(
              width: 60,
              height: 60,
              child: Center(
                child: Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 33, 149, 243),
                  ),
                ),
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(106, 33, 142, 243),
              ),
            ),
          ),

        // Fixed Location Marker
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
      };
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
              // Parking Location Marker
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

              // Blue Dot for Device Location (if available)
              if (_deviceLocation != null)
                Marker(
                  width: 40,
                  height: 40,
                  point: _deviceLocation!,
                  child: Container(
                    width: 60,
                    height: 60,
                    child: Center(
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(255, 33, 149, 243),
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(106, 33, 142, 243),
                    ),
                  ),
                ),

              // Scooter Location Marker
              Marker(
                width: 90,
                height: 90,
                point: scooterLocation,
                child: Image.asset("images/New Project (10).png"),
              ),
            };

          

            _mapController.move(scooterLocation, 18);
          } else {
            print("Invalid latitude or longitude");
          }
        });
      }
    });
  }

  // Get the device's current location

    // Get current location



  // Start real-time location updates


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
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
      ],
    );
  }
}
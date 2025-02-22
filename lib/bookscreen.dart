import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:scootrusl/qrcode.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator package

class MapScreen2 extends StatefulWidget {
  const MapScreen2({super.key});

  @override
  State<MapScreen2> createState() => _MapScreen2State();
}

class _MapScreen2State extends State<MapScreen2> {
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
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeMarkers(); // Load initial markers
    fetchScooter(); // Fetch real-time scooter data
    _getDeviceLocation(); // Get device location
    _startLocationUpdates(); // Start real-time location updates
  }

  @override
  void dispose() {
    _mapController.dispose();
    _positionStreamSubscription?.cancel(); // Cancel the stream subscription
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

            // Update polyline points with device location and scooter location
            if (_deviceLocation != null) {
              _polylinePoints = [_deviceLocation!, scooterLocation];
            } else {
              _polylinePoints = [_fixedLocation, scooterLocation];
            }

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

  // Get the device's current location
  Future<void> _getDeviceLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print("Location permission denied");
        return;
      }
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Update the device location
    setState(() {
      _deviceLocation = LatLng(position.latitude, position.longitude);
    });

    // Update markers and polyline with the device location
    _initializeMarkers();
    fetchScooter();

    // Center the map to the device location
    if (_deviceLocation != null) {
      _mapController.move(_deviceLocation!, 18);
    }
  }

  // Start real-time location updates
  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update location every 10 meters
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      // Update the device location
      setState(() {
        _deviceLocation = LatLng(position.latitude, position.longitude);
      });

      // Update markers and polyline with the new device location
      _initializeMarkers();
      fetchScooter();
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
                              builder: (context) => QRScannerScreen()));
                    },
                    child: Container(
                      width: 100,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(240, 197, 243, 185),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: const Center(child: Text('Book Now')),
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
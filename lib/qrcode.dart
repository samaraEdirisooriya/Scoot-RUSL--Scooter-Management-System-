import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:scootrusl/confitaniamation.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController();
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref(); // Reference to the root of the database
  String? firebaseQR;
  StreamSubscription<BarcodeCapture>? _barcodeSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchExpectedQR();
    _startScanner();
  }

  void fetchExpectedQR() {
    try {
      _database.child("qr").onValue.listen((event) {
        final data = event.snapshot.value;
        if (data != null) {
          setState(() {
            firebaseQR = data.toString(); // Fetch the QR code from Firebase
          });
        }
      });
    } catch (e) {
      print("Error fetching QR from Firebase: $e");
    }
  }

  void _startScanner() {
    try {
      _barcodeSubscription = _controller.barcodes.listen((barcodeCapture) {
        final barcodes = barcodeCapture.barcodes;
        for (final barcode in barcodes) {
          final scannedQR = barcode.rawValue;
          print("aaaaaaaaaaaaaaaa");
          print(scannedQR);
          // Compare scanned QR with Firebase QR
          if (firebaseQR != null && scannedQR == firebaseQR) {
            _database.child("availability").set(false);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NotePage()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FailurePage()),
            );
          }
        }
      });

      _controller.start();
    } catch (e) {
      print("Error starting scanner: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    try {
      if (!_controller.value.hasCameraPermission) return;

      switch (state) {
        case AppLifecycleState.resumed:
          _startScanner();
          break;
        case AppLifecycleState.paused:
          _barcodeSubscription?.cancel();
          _controller.stop();
          break;
        default:
          break;
      }
    } catch (e) {
      print("Error handling lifecycle state: $e");
    }
  }

  @override
  void dispose() {
    try {
      WidgetsBinding.instance.removeObserver(this);
      _barcodeSubscription?.cancel();
      _controller.dispose();
    } catch (e) {
      print("Error disposing resources: $e");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: MobileScanner(
        controller: _controller,
        fit: BoxFit.cover,
      ),
    );
  }
}

// Success Page
class SuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("✅ Scan Success!",
            style: TextStyle(fontSize: 24, color: Colors.green)),
      ),
    );
  }
}

// Failure Page
class FailurePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Column(
        children: [
          Positioned(
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
          Center(
            child: Text("❌ Scan Failed!",
                style: TextStyle(fontSize: 24, color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

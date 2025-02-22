import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:scootrusl/parked.dart';

class QRScannerScreen1 extends StatefulWidget {
  const QRScannerScreen1({super.key});

  @override
  State<QRScannerScreen1> createState() => _QRScannerScreen1State();
}

class _QRScannerScreen1State extends State<QRScannerScreen1>
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
      _database.child("qr2").onValue.listen((event) {
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
            _database.child("availability").set(true);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NotePage1()),
            );
          } else {
            Navigator.pushReplacement(
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
      body: Center(
        child: Text("❌ Scan Failed!",
            style: TextStyle(fontSize: 24, color: Colors.red)),
      ),
    );
  }
}

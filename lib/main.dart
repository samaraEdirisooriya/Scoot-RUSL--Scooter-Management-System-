import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:scootrusl/bookscreen.dart';
import 'package:scootrusl/brousemap.dart';
import 'package:scootrusl/confitaniamation.dart';
import 'package:scootrusl/homescreen.dart';
import 'package:scootrusl/mainmap.dart';
import 'package:scootrusl/navigateto.dart';
import 'package:scootrusl/parked.dart';
import 'package:scootrusl/qrcode.dart';
import 'package:scootrusl/singup.dart';
import 'package:scootrusl/supportpage.dart';
import 'package:scootrusl/test.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    runApp(MyApp());
  } catch (e) {
    print("Firebase initialization error: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen2(),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:scootrusl/singup.dart';
import 'package:scootrusl/supportpage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpScreen(),
    );
  }
}


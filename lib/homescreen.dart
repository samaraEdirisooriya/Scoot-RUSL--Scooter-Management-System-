import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scootrusl/bookscreen.dart';
import 'package:scootrusl/brousemap.dart';
import 'package:scootrusl/singup.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Map<String, dynamic>? scooterData;
  String? userName;
  String? userUid;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  // Get current authenticated user
  void getCurrentUser() {
    User? user = _auth.currentUser;
    if (user != null) {
      userUid = user.uid; // Get UID of logged-in user
      fetchUserName(userUid);
      fetchScooter();
    } else {
      print("No user is signed in.");
    }
  }

  // Fetch user name from Firestore based on UID
  void fetchUserName(String? uid) async {
    if (uid != null) {
      try {
        DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userSnapshot.exists) {
          setState(() {
            userName = userSnapshot['name']; // Assuming 'name' is the field in Firestore
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  // Fetch scooter data from Firebase Realtime Database
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
  void _logout(BuildContext context) async {
    await _auth.signOut(); // Sign out from Firebase
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()), // Redirect to Splash
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.cyan],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.black),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName != null ? 'Hello $userName,' : 'Hello User,',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Wanna take a ride today?',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
                 IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white), 
            onPressed: () => _logout(context),
          ),
              ],
              
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.wb_sunny, size: 40, color: Colors.orange),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '28° Cloudy',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Rajarata',
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    '28 September, Wednesday',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Near You',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                     Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MapScreen()),
                            );
                  },
                  child: Text(
                    'Browse Map >',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  scooterData != null
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MapScreen2()),
                            );
                          },
                          child: Container(
                            width: 180,
                            margin: EdgeInsets.only(right: 10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'images/project covwer.png',
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(height: 10),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.greenAccent, Colors.blue],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Distance 150m',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  scooterData!["name"],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'Available',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          child: Text("No data"),
                        ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:scootrusl/bookscreen.dart';
import 'package:scootrusl/brousemap.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? scooterData;

  @override
  void initState() {
    super.initState();
    fetchScooter();
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
                      'Hello Madhuvantha,',
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
                )
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
                            style:
                                TextStyle(fontSize: 16, color: Colors.black54),
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
                          child: Text("No data "),
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

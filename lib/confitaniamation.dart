import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:scootrusl/bookscreen.dart';
import 'package:scootrusl/mainmap.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final ConfettiController _confettiController = ConfettiController();

  @override
  void initState() {
    super.initState();
    // Start the confetti animation when the page loads
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose(); // Dispose the confetti controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.greenAccent, Colors.cyan],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Message
                  Image.asset(
                    'images/project covwer.png',
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    "Successfully Booked Scooter!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Enjoy Raide",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  // Confetti Animation
                  ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality
                        .explosive, // Confetti flies in all directions
                    shouldLoop: true, // Keep the animation looping
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple,
                    ], // Confetti colors
                  ),
                  GestureDetector(
                    onTap: () {
                        Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MapScreen6()),
            );
                    },
                    child: Container(
                      width: 100,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(240, 197, 243, 185),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: const Center(child: Text('Continue')),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Confetti Animation Controller
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14, // Confetti flies upwards
              emissionFrequency: 0.05, // How often confetti is emitted
              numberOfParticles: 20, // Number of confetti particles
              maxBlastForce: 20, // Maximum force of confetti blast
              minBlastForce: 10, // Minimum force of confetti blast
              gravity: 0.1, // Gravity effect on confetti
            ),
          ),
        ],
      ),
    );
  }
}

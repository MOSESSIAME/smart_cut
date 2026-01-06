import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D47A1), // Deep Blue
              Color(0xFFE3F2FD), // Light Blue / White
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo Image
                      Image.asset('assets/images/CutLogo2.png', height: 100),

                      const SizedBox(height: 20),

                      // App Title
                      const Text(
                        'SMART CUT',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description Text
                      const Text(
                        'Welcome to Smart Cut — the smart way to generate aluminium cutting sheets, optimize layouts, and minimize material waste.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Get Started Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 6,
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/projects');
                        },
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            color: Color(0xFF0D47A1),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                '© Smart Cut 2025',
                style: TextStyle(color: Colors.blueGrey, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

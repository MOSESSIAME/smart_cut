import 'package:flutter/material.dart';

/// The welcome screen of the app.
/// Includes a gradient background, app icon, title, "Get Started" button,
/// and a footer with copyright.
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Main app background with gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.green], // Gradient from teal to green
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // Use Column to position main content and footer
        child: Column(
          children: [
            // Expanded so main content is centered vertically
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App icon
                      const Icon(
                        Icons.construction,
                        color: Colors.white,
                        size: 100,
                      ),
                      const SizedBox(height: 20),
                      // App title
                      const Text(
                        'SMART CUT',
                        style: TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // "Get Started" button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // Navigate to the projects screen
                          Navigator.pushReplacementNamed(context, '/projects');
                        },
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer copyright section
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Copyright © Moses Siame 2025', // Copyright notice
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
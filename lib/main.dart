import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/project_list_screen.dart';

void main() {
  runApp(SmartCutApp());
}

/// The root widget of the SMART CUT app.
class SmartCutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMART CUT',
      debugShowCheckedModeBanner: false, // Hide the debug banner in the top right corner
      theme: ThemeData(
        primarySwatch: Colors.teal, // Set the primary theme color
        visualDensity: VisualDensity.adaptivePlatformDensity, // Adaptive density for different platforms
      ),
      home: WelcomeScreen(), // The first screen shown when the app launches
      routes: {
        '/projects': (context) => ProjectListScreen(), // Route for the project list screen
      },
    );
  }
}
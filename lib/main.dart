import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/project_list_screen.dart';

void main() {
  runApp(SmartCutApp());
}

class SmartCutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMART CUT',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WelcomeScreen(),
      routes: {
        '/projects': (context) => ProjectListScreen(),
      },
    );
  }
}

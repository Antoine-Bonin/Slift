import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart'; // Import de ta page d'accueil

void main() {
  runApp(const StreetLiftingApp());
}

class StreetLiftingApp extends StatelessWidget {
  const StreetLiftingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SL Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF4F1EA), 
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6B5E55), 
          secondary: Color(0xFFD0C3B4), 
          surface: Color(0xFFFCFBF9), 
          onSurface: Color(0xFF332D29), 
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
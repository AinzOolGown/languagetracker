import 'package:flutter/material.dart';
import 'screens/home_screen.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(LanguageTrackerApp());
}

class LanguageTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
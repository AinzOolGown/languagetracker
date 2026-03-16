import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'database/database_helper.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await testDatabase();
  runApp(LanguageTrackerApp());
}

Future<void> testDatabase() async {

  final db = DatabaseHelper.instance;

}

class LanguageTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
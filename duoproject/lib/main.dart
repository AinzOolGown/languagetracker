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

  int id = await db.insertTask({
    'title': 'Test Task',
    'description': 'SQLite is working',
    'completed': 0
  });

  print("Inserted task id: $id");

  final rows = await db.getTasks();

  print("Current tasks in database:");
  for (var row in rows) {
    print(row);
  }
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
import 'package:duoproject/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();

  /**/ 
  await NotificationService.instance.scheduleNotification(
    id: 999,
    title: "Test Notification",
    body: "This should fire in 30 seconds",
    scheduledDate: DateTime.now().add(Duration(seconds: 30)),
  );

  runApp(LanguageTrackerApp());
}

class LanguageTrackerApp extends StatelessWidget {
  const LanguageTrackerApp({super.key});

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
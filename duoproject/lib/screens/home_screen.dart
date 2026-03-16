import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import 'task_screen.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future loadTasks() async {

    final data = await DatabaseHelper.instance.readAllTasks();

    setState(() {
      tasks = data;
    });
  }

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Language Tracker"),
      ),
      body: Center(
        child: Text("Home Screen"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
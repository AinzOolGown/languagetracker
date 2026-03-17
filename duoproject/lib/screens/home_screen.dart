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

  void openTaskCreator() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaskScreen(),
    );

    // refresh tasks after closing
    loadTasks();
  }

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Language Tasks"),
      ),
      
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {

          final task = tasks[index];

          return ListTile(
            title: Text(task.title),
            subtitle: Text(task.description),
            leading: Checkbox(
              value: task.completed,
              onChanged: (_) {},
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: openTaskCreator,
        child: const Icon(Icons.add),
      ),
    );
  }
}
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
    final data = await DatabaseHelper.instance.readActiveTasks();

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

  Future toggleTask(Task task) async {
    task.completed = !task.completed;

    await DatabaseHelper.instance.updateTask(task);

    loadTasks();
  }

  Future deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTask(id);

    loadTasks();
  }

  @override
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
            title: Text(task.name),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${task.type}"),
                Text(
                  task.dueDate != null
                    ? "Due: ${task.dueDate}"
                    : "Goal (no due date)"
                ),
                Text("XP: ${task.xp}"),
              ],
            ),

            leading: Checkbox(
              value: task.completed,
              onChanged: (_) {
                toggleTask(task);
              },
            ),

            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteTask(task.id!);
              },
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
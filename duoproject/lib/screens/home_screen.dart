import 'package:duoproject/screens/history_screen.dart';
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
  Set<int> removingTasks = {};

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

  Future completeTaskWithAnimation(Task task) async {
    setState(() {
      removingTasks.add(task.id!);
    });
    await Future.delayed(Duration(milliseconds: 300));
    task.completed = true;
    await DatabaseHelper.instance.updateTask(task);
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Language Tasks"),
        actions: [
          IconButton(
            tooltip: "History",
            icon: Icon(Icons.history_rounded),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
        ],
      ),
      
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {

          final task = tasks[index];

          return AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: removingTasks.contains(task.id) ? 0.0 : 1.0,

            child: AnimatedSlide(
              duration: Duration(milliseconds: 300),
              offset: removingTasks.contains(task.id)
                  ? Offset(1, 0)
                  : Offset(0, 0),

              child: ListTile(
                title: Text(task.name),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Type: ${task.type}"),
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
                  onChanged: (_) async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Complete Task"),
                        content: Text("Mark this task as completed?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text("Confirm"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      completeTaskWithAnimation(task);
                    }
                  },
                ),

                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteTask(task.id!);
                  },
                ),
              ),
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
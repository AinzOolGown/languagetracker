import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  Future saveTask() async {

    final task = Task(
      title: titleController.text,
      description: descriptionController.text,
      completed: false,
    );

    await DatabaseHelper.instance.createTask(task);

    Navigator.pop(context); // close modal
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
    );
  }
}
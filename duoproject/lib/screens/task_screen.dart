import 'package:duoproject/constants/task_constants.dart';
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

  String selectedType = taskTypes[0];
  int difficulty = 1;
  DateTime? selectedDate;

  Future saveTask() async {

    final task = Task(
      name: titleController.text,
      comments: descriptionController.text,
      type: selectedType,
      difficulty: difficulty,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Text(
            "Create Task",
            style: TextStyle(fontSize: 20),
          ),

          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: "Task Name",
            ),
          ),

          DropdownButton<String>(
            value: selectedType,
            isExpanded: true,
            items: taskTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedType = value!;
                descriptionController.text = defaultComments[value]!;
              });
            },
          ),

          DropdownButton<int>(
            value: difficulty,
            items: [1, 2, 3, 4].map((level) {
              return DropdownMenuItem(
                value: level,
                child: Text("Level $level"),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                difficulty = value!;
              });
            },
          ),

          ElevatedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );

              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
            child: Text(
              selectedDate == null
                ? "Select Due Date (Optional)"
                : selectedDate.toString().split(' ')[0],
            ),
          ),

          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: "Description",
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: saveTask,
            child: const Text("Save Task"),
          ),

          const SizedBox(height: 10),

        ],
      ),
    );
  }
}
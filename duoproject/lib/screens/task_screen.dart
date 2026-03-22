import 'package:duoproject/constants/task_constants.dart';
import 'package:duoproject/services/notification_service.dart';
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
  DateTime? selectedDateTime;

  String formatDateTime(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  Future saveTask() async {

    final task = Task(
      name: titleController.text,
      type: selectedType,
      dueDate: selectedDateTime?.toString(),
      difficulty: difficulty,
      comments: descriptionController.text,
      completed: false,
    );

    final id = await DatabaseHelper.instance.createTask(task);
    
    if (selectedDateTime != null) {
      final due = selectedDateTime!;

      // 1 DAY BEFORE
      final oneDayBefore = due.subtract(Duration(days: 1));

      // 1 HOUR BEFORE
      final oneHourBefore = due.subtract(Duration(hours: 1));

      // Only schedule if future time
      if (oneDayBefore.isAfter(DateTime.now())) {
        await NotificationService.instance.scheduleNotification(
          id: id * 2,
          title: "Task Due Soon",
          body: "${task.name} is due in 1 day",
          scheduledDate: oneDayBefore,
        );
      }

      if (oneHourBefore.isAfter(DateTime.now())) {
        await NotificationService.instance.scheduleNotification(
          id: id * 2 + 1,
          title: "Task Due Soon",
          body: "${task.name} is due in 1 hour",
          scheduledDate: oneHourBefore,
        );
      }
      
    }

    print("Scheduling notification at: ${selectedDateTime?.toString()}");
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

              // Step 1: Pick date
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDateTime ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );

              if (pickedDate == null) return;

              // Step 2: Pick time
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(
                  selectedDateTime ?? DateTime.now(),
                ),
              );

              if (pickedTime == null) return;

              // Step 3: Combine into DateTime
              final combined = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );

              setState(() {
                selectedDateTime = combined;
              });
            },

            child: Text(
              selectedDateTime == null
                ? "Select Due Date & Time (Optional)"
                : formatDateTime(selectedDateTime!),
            ),
            
          ),

          if (selectedDateTime != null)
            TextButton(
              onPressed: () {
                setState(() {
                  selectedDateTime = null;
                });
              },
              child: const Text("Clear Due Date"),
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
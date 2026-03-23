import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController writingResponseController;

  @override
  void initState() {
    super.initState();
    writingResponseController = TextEditingController(
      text: widget.task.writingResponse ?? "",
    );
  }

  int wordCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  void saveWritingResponse() {
    final text = writingResponseController.text.trim();

    if (wordCount(text) > 250) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Writing response must be under 250 words")),
      );
      return;
    }

    setState(() {
      widget.task.writingResponse = text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Writing saved")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.task.category == "Reading") {
      return Scaffold(
        appBar: AppBar(title: Text(widget.task.title)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: SingleChildScrollView(
              child: Text(
                widget.task.readingParagraph?.isNotEmpty == true
                    ? widget.task.readingParagraph!
                    : "No reading paragraph added.",
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.7,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (widget.task.category == "Writing") {
      return Scaffold(
        appBar: AppBar(title: Text(widget.task.title)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if ((widget.task.writingPrompt ?? "").isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Prompt",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.task.writingPrompt!,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: writingResponseController,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        labelText: "Write your response here",
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Word count: ${wordCount(writingResponseController.text)} / 250",
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: saveWritingResponse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF58CC02),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Save Writing"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.task.title)),
      body: const Center(child: Text("No detail available")),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController taskController = TextEditingController();
  final TextEditingController xpController = TextEditingController(text: "10");

  final TextEditingController readingController = TextEditingController();
  final TextEditingController writingPromptController = TextEditingController();
  final TextEditingController listeningLinkController = TextEditingController();
  final TextEditingController speakingNoteController = TextEditingController();

  List<TextEditingController> vocabWordControllers = [];
  List<TextEditingController> vocabMeaningControllers = [];

  String category = "Vocabulary";

  final List<String> categories = [
    "Vocabulary",
    "Speaking",
    "Listening",
    "Reading",
    "Writing",
  ];

  @override
  void initState() {
    super.initState();
    _initVocabRows();
  }

  void _initVocabRows() {
    vocabWordControllers = List.generate(5, (_) => TextEditingController());
    vocabMeaningControllers = List.generate(5, (_) => TextEditingController());
  }

  Widget buildCategoryFields() {
    if (category == "Reading") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Optional paragraph under 250 words"),
          const SizedBox(height: 8),
          TextField(
            controller: readingController,
            maxLines: 6,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Paste a short reading paragraph here...",
            ),
          ),
        ],
      );
    }

    if (category == "Writing") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Question / note prompt"),
          const SizedBox(height: 8),
          TextField(
            controller: writingPromptController,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter the writing question or note...",
            ),
          ),
        ],
      );
    }

    if (category == "Listening") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Add 1 YouTube or website link"),
          const SizedBox(height: 8),
          TextField(
            controller: listeningLinkController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "https://...",
            ),
          ),
        ],
      );
    }

    if (category == "Speaking") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Add a short speaking note"),
          const SizedBox(height: 8),
          TextField(
            controller: speakingNoteController,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Example: Talk about your weekend for 1 minute",
            ),
          ),
        ],
      );
    }

    if (category == "Vocabulary") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Add 5 vocabulary rows"),
          const SizedBox(height: 8),
          ...List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: vocabWordControllers[index],
                      decoration: InputDecoration(
                        labelText: "Word ${index + 1}",
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: vocabMeaningControllers[index],
                      decoration: InputDecoration(
                        labelText: "Meaning ${index + 1}",
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    }

    return const SizedBox();
  }

  int wordCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  void saveTask() {
    final title = taskController.text.trim();
    final xpText = xpController.text.trim();

    if (title.isEmpty || xpText.isEmpty) {
      return;
    }

    if (category == "Reading" && wordCount(readingController.text) > 250) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reading paragraph must be under 250 words")),
      );
      return;
    }

    List<Map<String, String>>? vocabList;
    if (category == "Vocabulary") {
      vocabList = [];
      for (int i = 0; i < 5; i++) {
        final word = vocabWordControllers[i].text.trim();
        final meaning = vocabMeaningControllers[i].text.trim();
        if (word.isNotEmpty || meaning.isNotEmpty) {
          vocabList.add({"word": word, "meaning": meaning});
        }
      }
    }

    final task = TaskModel(
      title: title,
      category: category,
      xp: int.tryParse(xpText) ?? 10,
      completed: false,
      createdAt: DateTime.now(),
      readingParagraph: category == "Reading" ? readingController.text.trim() : null,
      writingPrompt: category == "Writing" ? writingPromptController.text.trim() : null,
      listeningLink: category == "Listening" ? listeningLinkController.text.trim() : null,
      speakingNote: category == "Speaking" ? speakingNoteController.text.trim() : null,
      vocabularyList: category == "Vocabulary" ? vocabList : null,
    );

    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Task"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: const InputDecoration(
                labelText: "Task Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: xpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "XP Reward",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              items: categories.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  category = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            buildCategoryFields(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveTask,
              child: const Text("Save Task"),
            ),
          ],
        ),
      ),
    );
  }
}
import '../models/task_model.dart';

class StorageService {
  static List<TaskModel> getInitialTasks() {
    return [
      TaskModel(
        title: "Practice Vocabulary",
        category: "Vocabulary",
        xp: 10,
        completed: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
        vocabularyList: [
          {"word": "apple", "meaning": "a fruit"},
          {"word": "book", "meaning": "something you read"},
          {"word": "chair", "meaning": "something to sit on"},
          {"word": "door", "meaning": "entry to a room"},
          {"word": "water", "meaning": "a drink"},
        ],
      ),
      TaskModel(
        title: "Short Reading Practice",
        category: "Reading",
        xp: 15,
        completed: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        readingParagraph:
            "Learning a new language takes time and practice. Reading every day helps learners improve vocabulary and understand sentence patterns more naturally.",
      ),
      TaskModel(
        title: "Listening Exercise",
        category: "Listening",
        xp: 20,
        completed: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        listeningLink: "https://www.youtube.com/",
      ),
      TaskModel(
        title: "Speaking Practice",
        category: "Speaking",
        xp: 12,
        completed: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        speakingNote: "Practice introducing yourself for 2 minutes.",
      ),
    ];
  }
}
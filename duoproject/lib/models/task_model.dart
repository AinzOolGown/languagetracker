class TaskModel {
  String title;
  String category;
  int xp;
  bool completed;
  DateTime createdAt;

  String? readingParagraph;
  String? writingPrompt;
  String? writingResponse;
  String? listeningLink;
  String? speakingNote;
  List<Map<String, String>>? vocabularyList;

  bool isExpanded;

  TaskModel({
    required this.title,
    required this.category,
    required this.xp,
    required this.completed,
    required this.createdAt,
    this.readingParagraph,
    this.writingPrompt,
    this.writingResponse,
    this.listeningLink,
    this.speakingNote,
    this.vocabularyList,
    this.isExpanded = false,
  });
}
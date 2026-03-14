class Task {
  int? id;
  String title;
  String description;
  bool completed;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.completed = false,
  });
}
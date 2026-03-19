class Task {
  int? id;
  String name;
  String type;        // category
  String? dueDate;    // nullable → goal if null
  int difficulty;     // 1–4
  String comments;
  bool completed;

  Task({
    this.id,
    required this.name,
    required this.type,
    this.dueDate,
    required this.difficulty,
    required this.comments,
    this.completed = false,
  });

  int get xp {
    if (dueDate == null) {
      // goal
      return difficulty * 100;
    } else {
      // task
      return difficulty * 25;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'dueDate': dueDate,
      'difficulty': difficulty,
      'comments': comments,
      'completed': completed ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      dueDate: map['dueDate'],
      difficulty: map['difficulty'],
      comments: map['comments'],
      completed: map['completed'] == 1,
    );
  }
}
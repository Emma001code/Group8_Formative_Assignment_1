/// Represents a student assignment with all required fields.
/// 
/// We use a mutable isCompleted flag so we can toggle completion status
/// without creating a new object.
class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;
  final String course;
  final String priority; // High, Medium, Low
  final String type; // Formative or Summative
  bool isCompleted;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.course,
    this.priority = 'Medium',
    this.type = 'Formative',
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'course': course,
      'priority': priority,
      'type': type,
      'isCompleted': isCompleted,
    };
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      dueDate: DateTime.parse(json['dueDate']),
      course: json['course'] ?? '',
      priority: json['priority'] ?? 'Medium',
      type: json['type'] ?? 'Formative',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

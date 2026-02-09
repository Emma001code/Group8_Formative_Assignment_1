/// Represents a student user with email, password, and course list.
/// 
/// We always ensure exactly 3 courses exist for consistency across the app.
class Student {
  final String email;
  final String password;
  final List<String> courses; // Exactly 3 courses with editable names

  Student({
    required this.email,
    required this.password,
    required this.courses,
  });

  /// Creates a student with default course names if not provided.
  /// Ensures exactly 3 courses are always present.
  factory Student.withDefaultCourses({
    required String email,
    required String password,
    List<String>? courses,
  }) {
    final defaultCourses = [
      'Course 1',
      'Course 2',
      'Course 3',
    ];
    
    return Student(
      email: email,
      password: password,
      courses: courses ?? defaultCourses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'courses': courses,
      // Keep backward compatibility
      'selectedCourses': courses,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    // Support both old 'selectedCourses' and new 'courses' field
    final coursesList = json['courses'] ?? json['selectedCourses'] ?? [];
    List<String> courses = List<String>.from(coursesList);
    
    // Ensure exactly 3 courses
    while (courses.length < 3) {
      courses.add('Course ${courses.length + 1}');
    }
    courses = courses.take(3).toList();
    
    return Student(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      courses: courses,
    );
  }
}

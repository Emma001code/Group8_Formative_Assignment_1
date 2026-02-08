import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../models/assignment.dart';
import '../models/academic_session.dart';

/// Database abstraction layer using SharedPreferences for all platforms.
/// 
/// Design Decision: This file provides a unified interface for data storage
/// that works across all platforms (web, mobile, desktop) using SharedPreferences.
/// 
/// Storage Strategy:
/// - All platforms: Uses SharedPreferences (JSON serialization)
/// - Web: Browser localStorage
/// - Mobile/Desktop: Native SharedPreferences (no NDK required)
/// 
/// This approach eliminates the need for NDK and SQLite, making the app
/// easier to build and deploy across all platforms.
/// 
/// Design Pattern: Singleton ensures only one instance exists, preventing
/// multiple storage connections and ensuring data consistency.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  SharedPreferences? _prefs;

  DatabaseHelper._init();

  /// Initializes SharedPreferences storage.
  /// 
  /// We use lazy initialization (only init when needed) instead of doing it
  /// in the constructor. This speeds up app startup since we don't wait for
  /// storage to be ready until we actually need to save/load data.
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Student Operations
  Future<void> insertStudent(Student student) async {
    await _init();
    await _prefs!.setString('student_email', student.email);
    await _prefs!.setString('student_password', student.password);
    await _prefs!.setStringList('student_courses', student.courses);
  }

  Future<Student?> getStudent() async {
    await _init();
    final email = _prefs!.getString('student_email');
    if (email == null) return null;
    final courses = _prefs!.getStringList('student_courses') ?? [];
    return Student.fromJson({
      'email': email,
      'password': _prefs!.getString('student_password') ?? '',
      'courses': courses,
    });
  }

  // Assignment Operations
  
  /// Saves an assignment using an upsert pattern (insert or update).
  /// 
  /// We use removeWhere + add instead of separate update method because
  /// SharedPreferences doesn't support partial updates. This approach works
  /// for both creating new assignments and updating existing ones.
  Future<void> insertAssignment(Assignment assignment) async {
    await _init();
    final assignmentsJson = _prefs!.getString('assignments') ?? '[]';
    final List<dynamic> assignments = jsonDecode(assignmentsJson);
    // Remove existing if updating, then add (upsert pattern)
    assignments.removeWhere((a) => a['id'] == assignment.id);
    assignments.add({
      'id': assignment.id,
      'title': assignment.title,
      'dueDate': assignment.dueDate.toIso8601String(),
      'course': assignment.course,
      'priority': assignment.priority,
      'type': assignment.type,
      'isCompleted': assignment.isCompleted,
    });
    await _prefs!.setString('assignments', jsonEncode(assignments));
  }

  Future<List<Assignment>> getAssignments() async {
    await _init();
    final assignmentsJson = _prefs!.getString('assignments') ?? '[]';
    final List<dynamic> assignments = jsonDecode(assignmentsJson);
    return assignments.map((map) => Assignment(
      id: map['id'] as String,
      title: map['title'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      course: map['course'] as String,
      priority: map['priority'] as String,
      type: map['type'] as String? ?? 'Formative',
      isCompleted: map['isCompleted'] as bool,
    )).toList();
  }

  Future<void> updateAssignment(Assignment assignment) async {
    await insertAssignment(assignment); // Same as insert
  }

  Future<void> deleteAssignment(String id) async {
    await _init();
    final assignmentsJson = _prefs!.getString('assignments') ?? '[]';
    final List<dynamic> assignments = jsonDecode(assignmentsJson);
    assignments.removeWhere((a) => a['id'] == id);
    await _prefs!.setString('assignments', jsonEncode(assignments));
  }

  // Academic Session Operations
  Future<void> insertSession(AcademicSession session) async {
    await _init();
    final sessionsJson = _prefs!.getString('sessions') ?? '[]';
    final List<dynamic> sessions = jsonDecode(sessionsJson);
    sessions.removeWhere((s) => s['id'] == session.id);
    sessions.add({
      'id': session.id,
      'title': session.title,
      'date': session.date.toIso8601String(),
      'startTime': session.startTime,
      'endTime': session.endTime,
      'location': session.location,
      'sessionType': session.sessionType,
      'isAttended': session.isAttended,
    });
    await _prefs!.setString('sessions', jsonEncode(sessions));
  }

  Future<List<AcademicSession>> getSessions() async {
    await _init();
    final sessionsJson = _prefs!.getString('sessions') ?? '[]';
    final List<dynamic> sessions = jsonDecode(sessionsJson);
    return sessions.map((map) => AcademicSession(
      id: map['id'] as String,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      location: map['location'] as String? ?? '',
      sessionType: map['sessionType'] as String,
      isAttended: map['isAttended'] as bool,
    )).toList();
  }

  Future<void> updateSession(AcademicSession session) async {
    await insertSession(session); // Same as insert
  }

  Future<void> deleteSession(String id) async {
    await _init();
    final sessionsJson = _prefs!.getString('sessions') ?? '[]';
    final List<dynamic> sessions = jsonDecode(sessionsJson);
    sessions.removeWhere((s) => s['id'] == id);
    await _prefs!.setString('sessions', jsonEncode(sessions));
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _init();
    await _prefs!.remove('student_email');
    await _prefs!.remove('student_password');
    await _prefs!.remove('student_courses');
    await _prefs!.remove('assignments');
    await _prefs!.remove('sessions');
  }
}

import '../models/student.dart';
import '../models/assignment.dart';
import '../models/academic_session.dart';
import 'database_helper.dart';

/// Business logic layer for data operations.
/// 
/// Design Decision: This service acts as an abstraction layer between
/// the UI and database. It provides a clean API for screens to interact
/// with data without knowing the underlying storage implementation
/// (SQLite for mobile, SharedPreferences for web).
/// 
/// Benefits:
/// - Separation of concerns (UI doesn't know about database details)
/// - Easy to test and mock
/// - Centralized business logic (e.g., attendance calculation)
class DataService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ==================== Student Operations ====================
  
  /// Saves student data to persistent storage.
  /// 
  /// Design: Single user app, so we replace existing student data
  /// rather than supporting multiple users.
  Future<void> saveStudent(Student student) async {
    await _dbHelper.insertStudent(student);
  }

  /// Retrieves the current student's data.
  /// Returns null if no student has signed up yet.
  Future<Student?> getStudent() async {
    return await _dbHelper.getStudent();
  }

  // ==================== Assignment Operations ====================
  
  /// Saves multiple assignments at once.
  /// Used for bulk operations or data migration.
  Future<void> saveAssignments(List<Assignment> assignments) async {
    for (var assignment in assignments) {
      await _dbHelper.insertAssignment(assignment);
    }
  }

  /// Retrieves all assignments from storage.
  /// Note: Sorting by due date should be done in the UI layer
  /// to allow for different sorting strategies.
  Future<List<Assignment>> getAssignments() async {
    return await _dbHelper.getAssignments();
  }

  /// Adds a new assignment to storage.
  Future<void> addAssignment(Assignment assignment) async {
    await _dbHelper.insertAssignment(assignment);
  }

  /// Updates an existing assignment.
  /// The assignment ID is used to identify which record to update.
  Future<void> updateAssignment(Assignment assignment) async {
    await _dbHelper.updateAssignment(assignment);
  }

  /// Deletes an assignment by its unique ID.
  Future<void> deleteAssignment(String id) async {
    await _dbHelper.deleteAssignment(id);
  }

  // ==================== Session Operations ====================
  
  /// Saves multiple sessions at once.
  /// Used for bulk operations or data migration.
  Future<void> saveSessions(List<AcademicSession> sessions) async {
    for (var session in sessions) {
      await _dbHelper.insertSession(session);
    }
  }

  /// Retrieves all academic sessions from storage.
  Future<List<AcademicSession>> getSessions() async {
    return await _dbHelper.getSessions();
  }

  /// Adds a new session to storage.
  Future<void> addSession(AcademicSession session) async {
    await _dbHelper.insertSession(session);
  }

  /// Updates an existing session.
  /// Used when toggling attendance or modifying session details.
  Future<void> updateSession(AcademicSession session) async {
    await _dbHelper.updateSession(session);
  }

  /// Deletes a session by its unique ID.
  Future<void> deleteSession(String id) async {
    await _dbHelper.deleteSession(id);
  }

  // ==================== Attendance Calculation ====================
  
  /// Calculates attendance percentage from all sessions.
  /// 
  /// We include both past and future sessions in the calculation. This gives
  /// a complete view of engagement, not just historical attendance. The 75%
  /// threshold matches ALU's attendance policy requirement.
  /// Returns 0.0 if no sessions exist to avoid dividing by zero.
  double calculateAttendancePercentage(List<AcademicSession> sessions) {
    if (sessions.isEmpty) return 0.0;
    final attendedCount = sessions.where((s) => s.isAttended).length;
    return (attendedCount / sessions.length) * 100;
  }

  // ==================== Utility Operations ====================
  
  /// Clears all stored data.
  /// Useful for testing or account reset functionality.
  Future<void> clearAllData() async {
    await _dbHelper.clearAllData();
  }
}

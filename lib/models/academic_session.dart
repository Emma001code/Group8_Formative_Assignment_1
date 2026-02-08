/// Represents an academic session (class, study group, etc.).
/// 
/// The isAttended flag can be toggled to track attendance, which affects
/// the overall attendance percentage calculation.
class AcademicSession {
  final String id;
  final String title;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String location;
  final String sessionType; // Class, Mastery Session, Study Group, PSL Meeting
  bool isAttended;

  AcademicSession({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location = '',
    required this.sessionType,
    this.isAttended = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'sessionType': sessionType,
      'isAttended': isAttended,
    };
  }

  factory AcademicSession.fromJson(Map<String, dynamic> json) {
    return AcademicSession(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      date: DateTime.parse(json['date']),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      location: json['location'] ?? '',
      sessionType: json['sessionType'] ?? 'Class',
      isAttended: json['isAttended'] ?? false,
    );
  }
}

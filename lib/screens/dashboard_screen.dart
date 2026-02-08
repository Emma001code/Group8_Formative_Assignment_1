import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/assignment.dart';
import '../models/academic_session.dart';
import '../services/data_service.dart';
import 'login_screen.dart';
import 'manage_courses_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final DataService _dataService = DataService();
  List<Assignment> _assignments = [];
  List<AcademicSession> _sessions = [];
  double _attendancePercentage = 0.0;
  bool _isLoading = true;
  List<String> _courses = [];
  String _currentCourse = 'All Courses';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Public method to refresh data from other screens.
  /// Called when returning from create/edit screens.
  void refreshData() {
    _loadData();
  }

  /// Loads all dashboard data from storage.
  /// 
  /// We check mounted before setState to avoid errors if the widget was
  /// disposed during async operations. We provide default courses if none
  /// exist so the UI always has something to display.
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final student = await _dataService.getStudent();
      final assignments = await _dataService.getAssignments();
      final sessions = await _dataService.getSessions();
      final attendancePercentage = _dataService.calculateAttendancePercentage(sessions);

      if (mounted) {
        setState(() {
          // Default courses ensure dropdown always has options
          _courses = student?.courses ?? ['Course 1', 'Course 2', 'Course 3'];
          _assignments = assignments;
          _sessions = sessions;
          _attendancePercentage = attendancePercentage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: ALUColors.warningRed,
          ),
        );
      }
    }
  }

  /// Gets assignments due within the next 7 days.
  /// 
  /// We use a 7-day window to show immediate priorities without
  /// overwhelming the dashboard. Only incomplete assignments are shown.
  /// Results are sorted by due date so most urgent ones appear first.
  List<Assignment> _getUpcomingAssignments() {
    final now = DateTime.now();
    final sevenDaysFromNow = now.add(const Duration(days: 7));
    
    var filtered = _assignments
        .where((assignment) =>
            !assignment.isCompleted &&
            assignment.dueDate.isAfter(now) &&
            assignment.dueDate.isBefore(sevenDaysFromNow))
        .toList();
    
    // Apply course filter if user selected a specific course
    if (_currentCourse != 'All Courses') {
      filtered = filtered.where((a) => a.course == _currentCourse).toList();
    }
    
    // Sort by due date - earliest first
    filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return filtered;
  }

  /// Gets today's scheduled academic sessions.
  List<AcademicSession> _getTodaySessions() {
    final now = DateTime.now();
    return _sessions
        .where((session) =>
            session.date.year == now.year &&
            session.date.month == now.month &&
            session.date.day == now.day)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Gets the count of pending (incomplete) assignments.
  /// This is the "Summary count of pending assignments" requirement.
  int _getPendingAssignmentsCount() {
    if (_currentCourse == 'All Courses') {
      return _assignments.where((a) => !a.isCompleted).length;
    } else {
      return _assignments
          .where((a) => !a.isCompleted && a.course == _currentCourse)
          .length;
    }
  }

  /// Calculates current academic week number.
  /// 
  /// We assume the academic year starts in September. If current month
  /// is before September, we use the previous year as the start.
  /// Week 1 is the first week of September.
  String _getCurrentAcademicWeek() {
    final now = DateTime.now();
    // Academic year starts in September
    final academicYearStart = DateTime(
      now.month >= 9 ? now.year : now.year - 1,
      9,
      1,
    );
    // Calculate weeks since start, add 1 so first week is Week 1
    final weekNumber = now.difference(academicYearStart).inDays ~/ 7 + 1;
    return 'Week $weekNumber';
  }

  /// Returns color based on attendance percentage.
  /// 
  /// Green for 75%+, yellow for 60-74%, red below 60%.
  /// This matches ALU's attendance policy where 75% is the minimum.
  Color _getAttendanceColor() {
    if (_attendancePercentage >= 75) return ALUColors.attendanceGood;
    if (_attendancePercentage >= 60) return ALUColors.attendanceWarning;
    return ALUColors.attendanceCritical;
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ALUColors.cardBackground,
        title: const Text(
          'Logout',
          style: TextStyle(color: ALUColors.textWhite),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: ALUColors.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: ALUColors.warningRed,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayDate = DateFormat('EEEE, MMM d').format(DateTime.now());
    final upcomingAssignments = _getUpcomingAssignments();
    final todaySessions = _getTodaySessions();
    final pendingCount = _getPendingAssignmentsCount();

    return Scaffold(
      backgroundColor: ALUColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: ALUColors.backgroundDark,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: ALUColors.textWhite),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: ALUColors.textWhite),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageCoursesScreen(),
                ),
              );
              if (result == true) {
                await _loadData();
              }
            },
            tooltip: 'Manage Courses',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: ALUColors.textWhite),
            color: ALUColors.cardBackground,
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: ALUColors.textWhite, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(color: ALUColors.textWhite),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: ALUColors.accentYellow,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: ALUColors.accentYellow,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Selector Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ALUColors.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _currentCourse,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: ALUColors.cardBackground,
                        style: const TextStyle(
                          color: ALUColors.textWhite,
                          fontSize: 14,
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: ALUColors.textWhite,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'All Courses',
                            child: Text('All Courses'),
                          ),
                          ..._courses.map((course) {
                            return DropdownMenuItem(
                              value: course,
                              child: Text(course),
                            );
                          }),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _currentCourse = newValue!;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Visual Warning Indicator (if attendance < 75%)
                    if (_attendancePercentage < 75)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ALUColors.warningRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: ALUColors.textWhite,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'AT RISK WARNING - Attendance below 75%',
                                style: TextStyle(
                                  color: ALUColors.textWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_attendancePercentage < 75) const SizedBox(height: 16),

                    // Today's Date and Current Academic Week
                    Text(
                      todayDate,
                      style: const TextStyle(
                        color: ALUColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCurrentAcademicWeek(),
                      style: const TextStyle(
                        color: ALUColors.textGray,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Summary Count of Pending Assignments
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ALUColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.assignment,
                            color: ALUColors.accentYellow,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pending Assignments',
                                style: TextStyle(
                                  color: ALUColors.textGray,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '$pendingCount',
                                style: const TextStyle(
                                  color: ALUColors.textWhite,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Today's Scheduled Academic Sessions
                    const Text(
                      "Today's Classes",
                      style: TextStyle(
                        color: ALUColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (todaySessions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ALUColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'No classes scheduled for today',
                            style: TextStyle(
                              color: ALUColors.textGray,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ...todaySessions.map((session) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildSessionCard(session),
                          )),

                    const SizedBox(height: 24),

                    // Assignments Due Within Next 7 Days
                    const Text(
                      'Upcoming Assignments',
                      style: TextStyle(
                        color: ALUColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (upcomingAssignments.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ALUColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'No assignments due in the next 7 days',
                            style: TextStyle(
                              color: ALUColors.textGray,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ...upcomingAssignments.map((assignment) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildAssignmentCard(assignment),
                          )),

                    const SizedBox(height: 24),

                    // Current Overall Attendance Percentage
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ALUColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Overall Attendance',
                            style: TextStyle(
                              color: ALUColors.textWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getAttendanceColor(),
                            ),
                            child: Center(
                              child: Text(
                                '${_attendancePercentage.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: ALUColors.textWhite,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_attendancePercentage < 75)
                            const Text(
                              'Warning: Attendance below 75%',
                              style: TextStyle(
                                color: ALUColors.warningRed,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSessionCard(AcademicSession session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ALUColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: const TextStyle(
                    color: ALUColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.startTime} - ${session.endTime}',
                  style: const TextStyle(
                    color: ALUColors.textGray,
                    fontSize: 14,
                  ),
                ),
                if (session.location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    session.location,
                    style: const TextStyle(
                      color: ALUColors.textGray,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: session.isAttended
                  ? ALUColors.successGreen
                  : ALUColors.cardLightBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              session.isAttended ? 'Present' : 'Absent',
              style: const TextStyle(
                color: ALUColors.textWhite,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(Assignment assignment) {
    final daysUntilDue = assignment.dueDate.difference(DateTime.now()).inDays;
    final isOverdue = assignment.dueDate.isBefore(DateTime.now()) && !assignment.isCompleted;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ALUColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  assignment.title,
                  style: const TextStyle(
                    color: ALUColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Due ${DateFormat('MMM d, yyyy').format(assignment.dueDate)}',
            style: TextStyle(
              color: isOverdue
                  ? ALUColors.warningRed
                  : ALUColors.textGray,
              fontSize: 14,
              fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            assignment.course,
            style: const TextStyle(
              color: ALUColors.textGray,
              fontSize: 12,
            ),
          ),
          if (daysUntilDue >= 0 && daysUntilDue <= 7 && !assignment.isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Due in $daysUntilDue ${daysUntilDue == 1 ? 'day' : 'days'}',
                style: const TextStyle(
                  color: ALUColors.warningRed,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/academic_session.dart';
import '../services/data_service.dart';
import 'create_session_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen> {
  final DataService _dataService = DataService();
  List<AcademicSession> _sessions = [];
  DateTime _currentWeekStart = _getWeekStart(DateTime.now());
  bool _isLoading = true;

  static DateTime _getWeekStart(DateTime date) {
    // Get Monday of the week
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }


  Future<void> _loadSessions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final sessions = await _dataService.getSessions();
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sessions: $e'),
            backgroundColor: ALUColors.warningRed,
          ),
        );
      }
    }
  }

  /// Public method to refresh data from other screens.
  /// Called when returning from create/edit screens.
  void refreshData() {
    _loadSessions();
  }

  /// Gets all sessions for the current week being displayed.
  /// 
  /// We normalize dates (remove time) because sessions might have different
  /// times but we only care about which day they're on. Using milliseconds
  /// for comparison avoids timezone and time-of-day issues.
  List<AcademicSession> _getSessionsForWeek() {
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));
    
    // Normalize to date-only for comparison (ignore time)
    final weekStartDay = DateTime(_currentWeekStart.year, _currentWeekStart.month, _currentWeekStart.day);
    final weekEndDay = DateTime(weekEnd.year, weekEnd.month, weekEnd.day);
    
    return _sessions.where((session) {
      final sessionDay = DateTime(session.date.year, session.date.month, session.date.day);
      // Milliseconds comparison is more reliable than date arithmetic
      final sessionMs = sessionDay.millisecondsSinceEpoch;
      final startMs = weekStartDay.millisecondsSinceEpoch;
      final endMs = weekEndDay.millisecondsSinceEpoch;
      return sessionMs >= startMs && sessionMs <= endMs;
    }).toList();
  }

  /// Groups sessions by day of the week.
  /// 
  /// We create entries for all 7 days (even empty ones) so the UI always
  /// shows a complete week view. This makes navigation predictable - users
  /// always see Monday through Sunday. Sessions within each day are sorted
  /// by start time so they appear in chronological order.
  Map<DateTime, List<AcademicSession>> _groupSessionsByDay() {
    final weekSessions = _getSessionsForWeek();
    final Map<DateTime, List<AcademicSession>> grouped = {};

    // Initialize all 7 days of the week
    for (var i = 0; i < 7; i++) {
      final day = _currentWeekStart.add(Duration(days: i));
      final normalizedDay = DateTime(day.year, day.month, day.day);
      grouped[normalizedDay] = [];
    }

    // Add sessions to their respective days
    for (var session in weekSessions) {
      final sessionDay = DateTime(session.date.year, session.date.month, session.date.day);
      if (grouped.containsKey(sessionDay)) {
        grouped[sessionDay]!.add(session);
      }
    }

    // Sort by start time so earliest sessions appear first
    for (var day in grouped.keys) {
      grouped[day]!.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    return grouped;
  }

  void _navigateWeek(int direction) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: direction * 7));
    });
  }

  void _goToCurrentWeek() {
    setState(() {
      _currentWeekStart = _getWeekStart(DateTime.now());
    });
  }

  String _getWeekRange() {
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));
    if (_currentWeekStart.year == weekEnd.year) {
      return '${DateFormat('MMM d').format(_currentWeekStart)} - ${DateFormat('MMM d, yyyy').format(weekEnd)}';
    }
    return '${DateFormat('MMM d, yyyy').format(_currentWeekStart)} - ${DateFormat('MMM d, yyyy').format(weekEnd)}';
  }

  @override
  Widget build(BuildContext context) {
    final groupedSessions = _groupSessionsByDay();
    final isCurrentWeek = _getWeekStart(DateTime.now()) == _currentWeekStart;

    return Scaffold(
      backgroundColor: ALUColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: ALUColors.backgroundDark,
        elevation: 0,
        title: const Text(
          'Schedule',
          style: TextStyle(color: ALUColors.textWhite),
        ),
        actions: [
          if (!isCurrentWeek)
            TextButton(
              onPressed: _goToCurrentWeek,
              child: const Text(
                'Today',
                style: TextStyle(color: ALUColors.accentYellow),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: ALUColors.accentYellow,
              ),
            )
          : Column(
              children: [
                // Week Navigation
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: ALUColors.cardBackground,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: ALUColors.textWhite),
                        onPressed: () => _navigateWeek(-1),
                      ),
                      Expanded(
        child: Text(
                          _getWeekRange(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
            color: ALUColors.textWhite,
            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: ALUColors.textWhite),
                        onPressed: () => _navigateWeek(1),
                      ),
                    ],
                  ),
                ),

                // Create Session Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ALUColors.accentYellow,
                        foregroundColor: ALUColors.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Create Session',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateSessionScreen(),
                          ),
                        );
                        // Always refresh after returning to show new session immediately
                        // Small delay to ensure navigation animation completes and data is saved
                        if (mounted) {
                          await Future.delayed(const Duration(milliseconds: 150));
                          await _loadSessions();
                        }
                      },
                    ),
                  ),
                ),

                // Weekly Schedule
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadSessions,
                    color: ALUColors.accentYellow,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        final day = _currentWeekStart.add(Duration(days: index));
                        // Normalize the day to match the grouped sessions keys
                        final normalizedDay = DateTime(day.year, day.month, day.day);
                        final daySessions = groupedSessions[normalizedDay] ?? [];
                        final isToday = day.year == DateTime.now().year &&
                            day.month == DateTime.now().month &&
                            day.day == DateTime.now().day;

                        return _buildDaySection(day, daySessions, isToday);
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDaySection(DateTime day, List<AcademicSession> sessions, bool isToday) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isToday ? ALUColors.accentYellow : ALUColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  DateFormat('EEEE').format(day),
                  style: TextStyle(
                    color: isToday ? ALUColors.primaryDark : ALUColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM d').format(day),
                  style: TextStyle(
                    color: isToday ? ALUColors.primaryDark : ALUColors.textGray,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  '${sessions.length} ${sessions.length == 1 ? 'session' : 'sessions'}',
                  style: TextStyle(
                    color: isToday ? ALUColors.primaryDark : ALUColors.textGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Sessions for this day
          if (sessions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No sessions scheduled',
                  style: TextStyle(color: ALUColors.textGray),
                ),
              ),
            )
          else
            ...sessions.map((session) => _buildSessionCard(session)),
        ],
      ),
    );
  }

  Widget _buildSessionCard(AcademicSession session) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: ALUColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title,
                          style: const TextStyle(
                            color: ALUColors.textWhite,
                            fontSize: 18,
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
                  Row(
                    children: [
                      // Attendance Toggle
                      GestureDetector(
                        onTap: () async {
                          session.isAttended = !session.isAttended;
                          await _dataService.updateSession(session);
                          await _loadSessions();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: session.isAttended
                                ? ALUColors.successGreen
                                : ALUColors.cardLightBackground,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                session.isAttended ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: ALUColors.textWhite,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                session.isAttended ? 'Present' : 'Absent',
                                style: const TextStyle(
                                  color: ALUColors.textWhite,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildCircleButton(
                        Icons.edit,
                        ALUColors.accentYellow,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateSessionScreen(
                                initialSession: session,
                              ),
                            ),
                          );
                          if (result != null) {
                            await _loadSessions();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildCircleButton(
                        Icons.delete,
                        ALUColors.warningRed,
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: ALUColors.cardBackground,
                              title: const Text(
                                'Delete Session',
                                style: TextStyle(color: ALUColors.textWhite),
                              ),
                              content: const Text(
                                'Are you sure you want to delete this session?',
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
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await _dataService.deleteSession(session.id);
                            await _loadSessions();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTag(session.sessionType, ALUColors.infoBlue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: color,
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: ALUColors.textWhite,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'dashboard_screen.dart';
import 'assignments_screen.dart';
import 'schedule_screen.dart';

/// Main navigation container with bottom navigation bar.
/// 
/// Implements the three-tab navigation structure as required:
/// - Dashboard: Main overview screen
/// - Assignments: Assignment management interface
/// - Schedule: Session planning and calendar view
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final GlobalKey<DashboardScreenState> _dashboardKey = GlobalKey<DashboardScreenState>();
  final GlobalKey<ScheduleScreenState> _scheduleKey = GlobalKey<ScheduleScreenState>();

  /// All screens in the navigation. We use keys for Dashboard and Schedule
  /// so we can refresh them when switching tabs.
  List<Widget> get _screens => [
    DashboardScreen(key: _dashboardKey),
    const AssignmentScreen(),
    ScheduleScreen(key: _scheduleKey),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using IndexedStack keeps all screens in memory but preserves their state
      // when switching tabs. This is fine for just 3 screens.
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: ALUColors.cardBackground,
        selectedItemColor: ALUColors.accentYellow,
        unselectedItemColor: ALUColors.textGray,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Refresh the screen when switching to it
          _refreshScreen(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }

  /// Refreshes the screen when switching to it so data stays up-to-date.
  /// We use post-frame callback to make sure the screen is built first.
  void _refreshScreen(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (index == 0) {
        _dashboardKey.currentState?.refreshData();
      } else if (index == 2) {
        _scheduleKey.currentState?.refreshData();
      }
    });
  }
}

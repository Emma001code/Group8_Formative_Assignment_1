import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'constants/colors.dart';

/// Main entry point for the ALU Student Academic Platform application.
/// 
/// This app serves as a personal academic assistant for ALU students,
/// helping them manage assignments, track schedules, and monitor attendance.
void main() {
  runApp(const StudentAcademicPlatformApp());
}

/// Root widget of the application.
/// 
/// We use a dark theme to match ALU's brand colors. All colors come from
/// ALUColors constants to keep things consistent.
class StudentAcademicPlatformApp extends StatelessWidget {
  const StudentAcademicPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU Student Academic Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: ALUColors.primaryDark,
        scaffoldBackgroundColor: ALUColors.backgroundDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ALUColors.accentYellow,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const InitialScreen(),
    );
  }
}

/// Initial screen - always shows login first.
/// 
/// We require login on every app launch for security. Users can sign up
/// if they don't have an account yet.
class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}

import 'package:flutter/material.dart';

/// ALU Brand Colors
class ALUColors {
  // Primary Colors
  static const Color primaryDark = Color(0xFF001F3F); // Dark Navy Blue
  static const Color accentYellow = Color(0xFFFDB827); // Gold/Yellow
  static const Color warningRed = Color(0xFFDC3545); // Red for warnings
  
  // Text Colors
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFB0B0B0);
  
  // Background Colors
  static const Color backgroundDark = Color(0xFF001F3F);
  static const Color cardBackground = Color(0xFF0A2540);
  static const Color cardLightBackground = Color(0xFF1A3550);
  
  // Status Colors
  static const Color successGreen = Color(0xFF28A745);
  static const Color infoBlue = Color(0xFF17A2B8);
  
  // Attendance Status Colors
  static const Color attendanceGood = Color(0xFF28A745); // Green > 75%
  static const Color attendanceWarning = Color(0xFFFDB827); // Yellow 60-75%
  static const Color attendanceCritical = Color(0xFFDC3545); // Red < 60%
}

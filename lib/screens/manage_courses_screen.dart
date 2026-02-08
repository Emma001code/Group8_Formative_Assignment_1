import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/student.dart';
import '../services/data_service.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({super.key});

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  final DataService _dataService = DataService();
  final List<TextEditingController> _courseControllers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final student = await _dataService.getStudent();
    final courses = student?.courses ?? ['Course 1', 'Course 2', 'Course 3'];
    
    // Ensure exactly 3 courses
    while (courses.length < 3) {
      courses.add('Course ${courses.length + 1}');
    }
    
    setState(() {
      _courseControllers.clear();
      for (var course in courses.take(3)) {
        _courseControllers.add(TextEditingController(text: course));
      }
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    for (var controller in _courseControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveCourses() async {
    final student = await _dataService.getStudent();
    if (student == null) return;

    final courses = _courseControllers.map((c) => c.text.trim()).toList();
    
    // Ensure no empty courses
    for (int i = 0; i < courses.length; i++) {
      if (courses[i].isEmpty) {
        courses[i] = 'Course ${i + 1}';
      }
    }

    final updatedStudent = Student(
      email: student.email,
      password: student.password,
      courses: courses,
    );

    await _dataService.saveStudent(updatedStudent);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ALUColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: ALUColors.backgroundDark,
        elevation: 0,
        title: const Text(
          'Manage Courses',
          style: TextStyle(color: ALUColors.textWhite),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: ALUColors.accentYellow,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit your course names',
                    style: TextStyle(
                      color: ALUColors.textWhite,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Course ${index + 1}',
                            style: const TextStyle(
                              color: ALUColors.textGray,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _courseControllers[index],
                            style: const TextStyle(color: ALUColors.textWhite),
                            decoration: InputDecoration(
                              hintText: 'Enter course name',
                              hintStyle: const TextStyle(color: ALUColors.textGray),
                              filled: true,
                              fillColor: ALUColors.cardBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ALUColors.accentYellow,
                        foregroundColor: ALUColors.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveCourses,
                      child: const Text(
                        'Save Courses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

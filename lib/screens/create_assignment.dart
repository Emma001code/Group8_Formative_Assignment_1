import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/assignment.dart';
import '../services/data_service.dart';

class CreateAssignmentScreen extends StatefulWidget {
  final Assignment? initialAssignment;

  const CreateAssignmentScreen({super.key, this.initialAssignment});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final DataService _dataService = DataService();

  // Controllers to track changes fron inputs fields
  late TextEditingController _titleController;
  late TextEditingController _dueDateController;

  String _priority = 'Medium';
  String _type = 'Formative';
  String? _selectedCourse;
  List<String> _courses = [];
  DateTime? _selectedDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final student = await _dataService.getStudent();
    final courses = student?.courses ?? ['Course 1', 'Course 2', 'Course 3'];
    
    final assignment = widget.initialAssignment;
    
    setState(() {
      _courses = courses;
      _selectedCourse = assignment?.course ?? (courses.isNotEmpty ? courses.first : null);
      _titleController = TextEditingController(text: assignment?.title ?? '');
      _dueDateController = TextEditingController(
        text: assignment != null
            ? DateFormat('MMM d, yyyy').format(assignment.dueDate)
            : '',
      );
      _priority = assignment?.priority ?? 'Medium';
      _type = assignment?.type ?? 'Formative';
      _selectedDate = assignment?.dueDate;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  /// Validates and saves the assignment form.
  /// 
  /// If initialAssignment exists, we update it. Otherwise we create a new one.
  /// We use timestamp as ID for new assignments to ensure uniqueness.
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a due date'),
            backgroundColor: ALUColors.warningRed,
          ),
        );
        return;
      }

      if (_selectedCourse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a course'),
            backgroundColor: ALUColors.warningRed,
          ),
        );
        return;
      }

      try {
        // Use existing ID if editing, otherwise generate new one from timestamp
        final assignment = Assignment(
          id: widget.initialAssignment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          course: _selectedCourse!,
          dueDate: _selectedDate!,
          priority: _priority,
          type: _type,
          isCompleted: widget.initialAssignment?.isCompleted ?? false,
        );

        if (widget.initialAssignment != null) {
          await _dataService.updateAssignment(assignment);
        } else {
          await _dataService.addAssignment(assignment);
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving assignment: $e'),
              backgroundColor: ALUColors.warningRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: ALUColors.accentYellow,
              onPrimary: ALUColors.primaryDark,
              surface: ALUColors.cardBackground,
              onSurface: ALUColors.textWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dueDateController.text = DateFormat('MMM d, yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ALUColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: ALUColors.backgroundDark,
        elevation: 0,
        title: Text(
          widget.initialAssignment != null
              ? 'Edit Assignment'
              : 'Create Assignment',
          style: const TextStyle(color: ALUColors.textWhite),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Assignment Title'),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'Enter assignment title',
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Course'),
                    _buildCourseDropdown(),
                    const SizedBox(height: 20),
              _buildLabel('Due Date'),
              _buildDateField(),
              const SizedBox(height: 20),
              _buildLabel('Priority'),
              _buildPriorityDropdown(),
              const SizedBox(height: 20),
              _buildLabel('Assignment Type'),
              _buildTypeDropdown(),
              const SizedBox(height: 40),
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
                  onPressed: _submitForm,
                  child: Text(
                    widget.initialAssignment != null
                        ? 'Update Assignment'
                        : 'Save Assignment',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: ALUColors.textWhite,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: ALUColors.textWhite),
      decoration: _inputDecoration(hint),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dueDateController,
      readOnly: true,
      onTap: _pickDate,
      style: const TextStyle(color: ALUColors.textWhite),
      decoration: _inputDecoration('Select due date').copyWith(
        suffixIcon: const Icon(Icons.calendar_today, color: ALUColors.textGray),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a due date';
        }
        return null;
      },
    );
  }

  Widget _buildPriorityDropdown() {
    return _buildDropdown(
      value: _priority,
      items: const ['High', 'Medium', 'Low'],
      onChanged: (value) {
        if (value != null) setState(() => _priority = value);
      },
    );
  }

  Widget _buildTypeDropdown() {
    return _buildDropdown(
      value: _type,
      items: const ['Formative', 'Summative'],
      onChanged: (value) {
        if (value != null) setState(() => _type = value);
      },
    );
  }

  Widget _buildCourseDropdown() {
    return _buildDropdown(
      value: _selectedCourse,
      items: _courses,
      onChanged: (value) {
        if (value != null) setState(() => _selectedCourse = value);
      },
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ALUColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        dropdownColor: ALUColors.cardBackground,
        iconEnabledColor: ALUColors.textWhite,
        decoration: const InputDecoration(border: InputBorder.none),
        style: const TextStyle(color: ALUColors.textWhite),
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a course';
          }
          return null;
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: ALUColors.textGray),
      filled: true,
      fillColor: ALUColors.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

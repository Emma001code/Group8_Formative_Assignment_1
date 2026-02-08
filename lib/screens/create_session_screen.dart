import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/academic_session.dart';
import '../services/data_service.dart';

class CreateSessionScreen extends StatefulWidget {
  final AcademicSession? initialSession;

  const CreateSessionScreen({super.key, this.initialSession});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final DataService _dataService = DataService();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  String _sessionType = 'Class session';
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  @override
  void initState() {
    super.initState();
    final session = widget.initialSession;

    _titleController = TextEditingController(text: session?.title ?? '');
    _locationController = TextEditingController(text: session?.location ?? '');
    _dateController = TextEditingController(
      text: session != null
          ? DateFormat('MMM d, yyyy').format(session.date)
          : '',
    );
    _startTimeController = TextEditingController(
      text: session?.startTime ?? '',
    );
    _endTimeController = TextEditingController(
      text: session?.endTime ?? '',
    );

    _sessionType = session?.sessionType ?? 'Class session';
    _selectedDate = session?.date;
    
    // Parse existing times if editing
    if (session != null) {
      final startParts = session.startTime.split(':');
      final endParts = session.endTime.split(':');
      if (startParts.length == 2) {
        _selectedStartTime = TimeOfDay(
          hour: int.parse(startParts[0]),
          minute: int.parse(startParts[1]),
        );
      }
      if (endParts.length == 2) {
        _selectedEndTime = TimeOfDay(
          hour: int.parse(endParts[0]),
          minute: int.parse(endParts[1]),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  /// Validates and saves the session form.
  /// 
  /// Updates existing session if initialSession is provided, otherwise creates new one.
  /// We format times as "HH:mm" strings for storage.
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a date'),
            backgroundColor: ALUColors.warningRed,
          ),
        );
        return;
      }

      if (_selectedStartTime == null || _selectedEndTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select start and end times'),
            backgroundColor: ALUColors.warningRed,
          ),
        );
        return;
      }

      try {
        final session = AcademicSession(
          id: widget.initialSession?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          date: _selectedDate!,
          startTime: _formatTime(_selectedStartTime!),
          endTime: _formatTime(_selectedEndTime!),
          location: _locationController.text.trim(),
          sessionType: _sessionType,
          isAttended: widget.initialSession?.isAttended ?? false,
        );

        // Save the session and wait for it to complete
        if (widget.initialSession != null) {
          await _dataService.updateSession(session);
        } else {
          await _dataService.addSession(session);
        }
        
        // Ensure data is persisted before returning
        // Small delay to ensure database write completes
        await Future.delayed(const Duration(milliseconds: 100));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session saved successfully'),
              backgroundColor: ALUColors.successGreen,
              duration: Duration(seconds: 1),
            ),
          );
          // Return true to indicate success
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving session: $e'),
              backgroundColor: ALUColors.warningRed,
            ),
          );
        }
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatTimeDisplay(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
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
        _dateController.text = DateFormat('MMM d, yyyy').format(picked);
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
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
        _selectedStartTime = picked;
        _startTimeController.text = _formatTimeDisplay(picked);
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? TimeOfDay.now(),
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
        _selectedEndTime = picked;
        _endTimeController.text = _formatTimeDisplay(picked);
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
          widget.initialSession != null ? 'Edit Session' : 'Create Session',
          style: const TextStyle(color: ALUColors.textWhite),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Session Title'),
              _buildTextField(
                controller: _titleController,
                hint: 'Enter session title',
              ),
              const SizedBox(height: 20),
              _buildLabel('Date'),
              _buildDateField(),
              const SizedBox(height: 20),
              _buildLabel('Start Time'),
              _buildTimeField(
                controller: _startTimeController,
                onTap: _pickStartTime,
                hint: 'Select start time',
              ),
              const SizedBox(height: 20),
              _buildLabel('End Time'),
              _buildTimeField(
                controller: _endTimeController,
                onTap: _pickEndTime,
                hint: 'Select end time',
              ),
              const SizedBox(height: 20),
              _buildLabel('Location (Optional)'),
              _buildTextField(
                controller: _locationController,
                hint: 'Enter location',
                required: false,
              ),
              const SizedBox(height: 20),
              _buildLabel('Session Type'),
              _buildSessionTypeDropdown(),
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
                    widget.initialSession != null
                        ? 'Update Session'
                        : 'Save Session',
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
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: ALUColors.textWhite),
      decoration: _inputDecoration(hint),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: _pickDate,
      style: const TextStyle(color: ALUColors.textWhite),
      decoration: _inputDecoration('Select date').copyWith(
        suffixIcon: const Icon(Icons.calendar_today, color: ALUColors.textGray),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a date';
        }
        return null;
      },
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required VoidCallback onTap,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: const TextStyle(color: ALUColors.textWhite),
      decoration: _inputDecoration(hint).copyWith(
        suffixIcon: const Icon(Icons.access_time, color: ALUColors.textGray),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a time';
        }
        return null;
      },
    );
  }

  Widget _buildSessionTypeDropdown() {
    return _buildDropdown(
      value: _sessionType,
      items: const [
        'Class session',
        'Group activity session',
        'Group study session',
        'Office hours session',
      ],
      onChanged: (value) {
        if (value != null) setState(() => _sessionType = value);
      },
    );
  }

  Widget _buildDropdown({
    required String value,
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

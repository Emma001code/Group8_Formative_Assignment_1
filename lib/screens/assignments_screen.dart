import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/assignment.dart';
import '../services/data_service.dart';
import 'create_assignment.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  final DataService _dataService = DataService();
  List<Assignment> _assignments = [];
  String _selectedFilter = 'All'; // All, Formative, Summative
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }


  /// Loads assignments and sorts them by due date.
  /// 
  /// We sort ascending (earliest first) so the most urgent assignments
  /// appear at the top. This helps students prioritize their work.
  Future<void> _loadAssignments() async {
    setState(() => _isLoading = true);
    final assignments = await _dataService.getAssignments();
    // Sort ascending - earliest due dates first
    assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    setState(() {
      _assignments = assignments;
      _isLoading = false;
    });
  }

  /// Filters assignments by type (All, Formative, or Summative).
  /// Returns all assignments if filter is 'All', otherwise filters by type.
  List<Assignment> _getFilteredAssignments() {
    if (_selectedFilter == 'All') {
      return _assignments;
    }
    return _assignments.where((a) => a.type == _selectedFilter).toList();
  }

  //funtion to set colors based on priority color

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case "High":
        return ALUColors.warningRed;
      case "Medium":
        return ALUColors.accentYellow;
      case "Low":
        return ALUColors.successGreen;
      default:
        return ALUColors.textGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAssignments = _getFilteredAssignments();

    return Scaffold(
      backgroundColor: ALUColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: ALUColors.backgroundDark,
        elevation: 0,
        title: const Text(
          'Assignments',
          style: TextStyle(color: ALUColors.textWhite),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: ALUColors.accentYellow,
              ),
            )
          : Column(
              children: [
                // Filter Chips to filter assignments based on assignment type

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Formative'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Summative'),
                    ],
                  ),
                ),

                // Create Assignment Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        'Create Assignment',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateAssignmentScreen(),
                          ),
                        );

                        if (result != null) {
                          await _loadAssignments();
                        }
                      },
                    ),
                  ),
                ),

                // Assignments List ,if nothing is in the list  display nothing
                Expanded(
                  child: filteredAssignments.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadAssignments,
                          color: ALUColors.accentYellow,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: filteredAssignments.length,
                            itemBuilder: (context, index) {
                              final assignment = filteredAssignments[index];
                              return _buildAssignmentCard(assignment);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: ALUColors.accentYellow,
      checkmarkColor: ALUColors.primaryDark,
      labelStyle: TextStyle(
        color: isSelected ? ALUColors.primaryDark : ALUColors.textWhite,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: ALUColors.cardBackground,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: ALUColors.textGray,
          ),
          const SizedBox(height: 16),
          Text(
            'No Assignments Yet',
            style: TextStyle(
              color: ALUColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap 'Create Assignment' to get started",
            style: TextStyle(color: ALUColors.textGray),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(Assignment assignment) {
    final daysUntilDue = assignment.dueDate.difference(DateTime.now()).inDays;
    final isOverdue = assignment.dueDate.isBefore(DateTime.now()) && !assignment.isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: assignment.isCompleted
              ? ALUColors.cardBackground.withValues(alpha: 0.5)
              : ALUColors.cardBackground,
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
                          assignment.title,
                          style: TextStyle(
                            color: ALUColors.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: assignment.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 6),
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
                        if (daysUntilDue >= 0 && daysUntilDue <= 7 && !assignment.isCompleted)
                          Text(
                            'Due in $daysUntilDue ${daysUntilDue == 1 ? 'day' : 'days'}',
                            style: const TextStyle(
                              color: ALUColors.warningRed,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildCircleButton(
                        Icons.check,
                        assignment.isCompleted
                            ? ALUColors.successGreen
                            : ALUColors.textGray,
                        onTap: () async {
                          assignment.isCompleted = !assignment.isCompleted;
                          await _dataService.updateAssignment(assignment);
                          await _loadAssignments();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildCircleButton(
                        Icons.edit,
                        ALUColors.accentYellow,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateAssignmentScreen(
                                initialAssignment: assignment,
                              ),
                            ),
                          );
                          if (result != null) {
                            await _loadAssignments();
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
                                'Delete Assignment',
                                style: TextStyle(color: ALUColors.textWhite),
                              ),
                              content: const Text(
                                'Are you sure you want to delete this assignment?',
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
                            await _dataService.deleteAssignment(assignment.id);
                            await _loadAssignments();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTag(assignment.course, ALUColors.infoBlue),
                  const SizedBox(width: 8),
                  _buildTag(assignment.priority, _getPriorityColor(assignment.priority)),
                  const SizedBox(width: 8),
                  _buildTag(assignment.type, ALUColors.cardLightBackground),
                ],
              ),
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

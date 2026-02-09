# ALU Student Academic Platform

A mobile application designed to help African Leadership University students manage their academic responsibilities. The app serves as a personal academic assistant, helping students track assignments, manage class schedules, and monitor attendance throughout the term.

## Purpose

This application addresses common challenges faced by ALU students across all campuses: keeping track of assignments, remembering class schedules, and monitoring attendance. By centralizing these academic management tasks in one place, students can reduce missed deadlines, improve attendance, and better balance their university life.

## Features

### Dashboard
The main screen provides a comprehensive overview of the student's academic status:
- Today's date and current academic week display
- List of today's scheduled academic sessions
- Assignments due within the next seven days
- Overall attendance percentage with visual indicators
- Warning alerts when attendance falls below 75%
- Summary count of pending assignments

### Assignment Management
Students can create, view, edit, and manage their assignments:
- Create assignments with title, due date, course name, and priority level
- View all assignments sorted by due date
- Mark assignments as completed
- Edit assignment details
- Delete assignments when no longer needed

### Session Scheduling
Comprehensive scheduling system for academic sessions:
- Create sessions with title, date, start/end times, location, and session type
- View weekly schedule with all sessions organized by day
- Record attendance for each session using Present/Absent toggle
- Edit session details
- Remove cancelled sessions

### Attendance Tracking
Automatic attendance calculation and monitoring:
- Real-time attendance percentage calculation
- Visual indicators on the dashboard
- Warning system when attendance drops below 75%
- Complete attendance history maintained through session records

## Architecture

The application follows a three-layer architecture pattern for clean separation of concerns:

### UI Layer (`lib/screens/`)
Contains all user interface components and screens:
- `login_screen.dart` - User authentication
- `signup_screen.dart` - New user registration
- `main_navigation.dart` - Bottom navigation bar container
- `dashboard_screen.dart` - Main overview screen
- `assignments_screen.dart` - Assignment list and management
- `create_assignment.dart` - Assignment creation and editing form
- `schedule_screen.dart` - Weekly schedule view
- `create_session_screen.dart` - Session creation and editing form
- `manage_courses_screen.dart` - Course management interface

### Business Logic Layer (`lib/services/`)
Handles all business operations and data manipulation:
- `data_service.dart` - Main service for all data operations including attendance calculation
- `database_helper.dart` - Database abstraction layer using SharedPreferences

### Data Layer (`lib/models/`)
Data models representing core entities:
- `student.dart` - Student information and course list
- `assignment.dart` - Assignment data structure
- `academic_session.dart` - Academic session data structure

### Constants (`lib/constants/`)
- `colors.dart` - ALU brand color palette and theme constants

## Technical Details

### Navigation Structure
The app uses a BottomNavigationBar with three primary tabs:
1. Dashboard - Main overview screen
2. Assignments - Assignment management interface
3. Schedule - Session planning and calendar view

State is preserved across tab switches using IndexedStack, ensuring smooth user experience when navigating between screens.

### Data Storage
The application uses SharedPreferences for data persistence. This provides a simple, reliable storage solution that works across all platforms (Android, iOS, Web, Windows, Linux, macOS). All data is stored locally on the device.

The database helper abstracts the storage implementation, making it easy to switch to a different storage solution in the future if needed.

### Attendance Calculation
Attendance percentage is calculated automatically based on all recorded sessions. The formula is straightforward: (Number of attended sessions / Total sessions) × 100. The system includes all sessions (past and future) in the calculation to provide a complete view of engagement.

### Academic Week Calculation
The app calculates the current academic week assuming the academic year starts in September. If the current month is before September, it uses the previous year as the start date. Week 1 is the first week of September.

## Setup Instructions

### Prerequisites
- Flutter SDK (version 3.10.4 or higher)
- Dart SDK (included with Flutter)
- Android Studio or VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Installation Steps

1. Clone the repository:
```bash
git clone https://github.com/Emma001code/Group8_Formative_Assignment_1.git
cd Group8_Formative_Assignment_1/student_academic_platform
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

### Running on Specific Platforms

For Android emulator:
```bash
flutter run -d <device-id>
```

For iOS simulator (macOS only):
```bash
flutter run -d <device-id>
```

For web:
```bash
flutter run -d chrome
```

### Troubleshooting

If you encounter build issues on Windows:
- Ensure Gradle daemon is stopped: `gradlew --stop`
- Clean the build directory: `flutter clean`
- Get dependencies again: `flutter pub get`

The `gradle.properties` file includes configurations to prevent file locking issues on Windows systems.

## Project Structure

```
lib/
├── constants/
│   └── colors.dart          # ALU color palette
├── models/
│   ├── student.dart         # Student data model
│   ├── assignment.dart      # Assignment data model
│   └── academic_session.dart # Session data model
├── screens/
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── main_navigation.dart
│   ├── dashboard_screen.dart
│   ├── assignments_screen.dart
│   ├── create_assignment.dart
│   ├── schedule_screen.dart
│   ├── create_session_screen.dart
│   └── manage_courses_screen.dart
├── services/
│   ├── data_service.dart    # Business logic layer
│   └── database_helper.dart # Data persistence layer
└── main.dart                # Application entry point
```

## Dependencies

- `flutter` - Core Flutter framework
- `shared_preferences` - Local data storage
- `shared_preferences_linux` - Linux platform support
- `shared_preferences_windows` - Windows platform support
- `intl` - Internationalization and date formatting
- `cupertino_icons` - iOS-style icons

## Team Contributions

This project was developed collaboratively by Group 8 members:

- **Samuel Kwizera Ihimbazwe** - Login and signup screens, authentication flow
- **Emmanuel Ngwoke** - Dashboard screen, main navigation, and course management
- **Solace Afadhali Aziza** - Assignment management screens (list view and creation/editing)
- **Kelly Nshuti Dushimimana** - Session scheduling screens (weekly view and creation/editing)

Each team member worked on their assigned features in separate branches, which were then merged into the main branch. The commit history reflects individual contributions, and each merge commit is attributed to the respective team member.

## Design Decisions

### Color Scheme
The app uses ALU's official color palette with a dark theme. All colors are centralized in the `colors.dart` file to ensure consistency across the application.

### State Management
We use Flutter's built-in StatefulWidget for state management. This keeps the codebase simple and avoids additional dependencies while still providing the necessary functionality.

### Data Persistence
SharedPreferences was chosen for its simplicity and cross-platform compatibility. While SQLite would offer more structured storage, SharedPreferences meets all current requirements and keeps the codebase maintainable.

### Navigation
IndexedStack is used to preserve screen state when switching tabs. This ensures that when users navigate between Dashboard, Assignments, and Schedule, their scroll position and any temporary state is maintained.

## Future Enhancements

Potential improvements for future versions:
- Push notifications for upcoming assignments and sessions
- Calendar integration with device calendar apps
- Export functionality for assignments and attendance records
- Multi-user support for shared devices
- Cloud sync for data backup

## License

This project is developed for academic purposes as part of the ALU curriculum.

## Contact

For questions or issues, please contact the development team through the repository's issue tracker.

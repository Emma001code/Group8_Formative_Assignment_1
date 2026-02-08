# Student Academic Platform - ALU

A mobile application that serves as a personal academic assistant for African Leadership University (ALU) students. This app helps students organize their coursework, track their schedule, and monitor their academic engagement throughout the term.

## Project Overview

This Flutter application addresses common challenges faced by ALU students:
- **Tracking assignments** - Never miss a deadline
- **Remembering schedules** - Stay on top of classes and sessions
- **Monitoring attendance** - Get alerts when attendance drops below 75%

## Features

### Authentication
- **Login Screen** - Secure email/password authentication
- **Sign Up Screen** - New user registration with course selection
- **Logout** - Secure session management

### ✅ Home Dashboard
- Today's date and current academic week
- List of today's scheduled academic sessions
- Assignments due within the next seven days
- Current overall attendance percentage with visual indicator
- Visual warning when attendance falls below 75%
- Summary count of pending assignments
- Course filter dropdown
- Pull-to-refresh functionality

### ✅ Assignment Management
- **Create Assignments** - Title, due date, course, priority (High/Medium/Low), type (Formative/Summative)
- **View All Assignments** - Sorted by due date (ascending)
- **Filter Assignments** - By type (All/Formative/Summative)
- **Mark Complete** - Toggle assignment completion status
- **Edit Assignments** - Update assignment details
- **Delete Assignments** - Remove assignments with confirmation

### ✅ Academic Session Scheduling
- **Create Sessions** - Title, date, start/end time, location (optional), session type
- **Session Types** - Class, Mastery Session, Study Group, PSL Meeting
- **Weekly Calendar View** - Navigate between weeks, view all sessions
- **Attendance Tracking** - Present/Absent toggle for each session
- **Edit Sessions** - Modify session details
- **Delete Sessions** - Remove sessions with confirmation

### ✅ Attendance Tracking
- **Automatic Calculation** - Attendance percentage calculated from all sessions
- **Dashboard Display** - Clear visual indicator with color coding:
  - Green (≥75%): Good attendance
  - Yellow (60-74%): Warning
  - Red (<60%): Critical
- **Alerts** - Warning banner when attendance drops below 75%
- **History** - All attendance records maintained in database

## Architecture

### Project Structure

```
lib/
├── constants/
│   └── colors.dart              # ALU brand color definitions
├── models/
│   ├── student.dart             # Student data model (email, password, courses)
│   ├── assignment.dart         # Assignment model (title, dueDate, course, priority, type)
│   └── academic_session.dart    # Session model (title, date, times, location, type, attendance)
├── screens/
│   ├── login_screen.dart        # User authentication (simple email/password matching)
│   ├── signup_screen.dart       # New user registration with course selection
│   ├── dashboard_screen.dart    # Main overview with metrics and 7-day assignment window
│   ├── assignments_screen.dart  # Assignment management interface with filtering
│   ├── create_assignment.dart   # Create/edit assignment form (upsert pattern)
│   ├── schedule_screen.dart     # Weekly calendar view with week navigation
│   ├── create_session_screen.dart # Create/edit session form (upsert pattern)
│   ├── manage_courses_screen.dart # Course management (not in main nav)
│   └── main_navigation.dart    # Bottom navigation bar (IndexedStack for state preservation)
├── services/
│   ├── data_service.dart        # Business logic layer (abstraction between UI and data)
│   └── database_helper.dart     # Data storage layer (SharedPreferences for all platforms)
└── main.dart                    # App entry point
```

### Data Storage

The app uses **SharedPreferences** for all platforms (web, mobile, desktop):
- **Storage Format**: JSON serialization of data models
- **Platform Implementation**: 
  - Web: Browser localStorage
  - Mobile/Desktop: Native SharedPreferences (no NDK required)
- **Benefits**: 
  - Unified codebase across all platforms
  - No platform-specific database code needed
  - Simpler builds (no SQLite/NDK dependencies)
  - Works seamlessly on web, Android, iOS, Windows, macOS, Linux

All data operations go through `DatabaseHelper`, which provides a clean abstraction layer.

### Architecture Layers

The app follows a **three-layer architecture**:

1. **UI Layer** (`screens/`)
   - StatefulWidgets for local UI state
   - Handles user input and displays data
   - No direct database access

2. **Business Logic Layer** (`services/data_service.dart`)
   - Abstracts UI from data storage details
   - Provides high-level operations (getAssignments, calculateAttendance, etc.)
   - Handles data transformations and business rules

3. **Data Layer** (`services/database_helper.dart`)
   - Handles all storage operations
   - JSON serialization/deserialization
   - Singleton pattern ensures data consistency

### Key Design Decisions

1. **Unified Storage**: SharedPreferences for all platforms eliminates platform-specific code and simplifies deployment
2. **Separation of Concerns**: Clear separation between UI, business logic, and data storage
3. **State Management**: StatefulWidget for local state, DataService for data operations (no external state management needed for this scope)
4. **Navigation**: IndexedStack preserves screen state when switching tabs, improving UX
5. **Color System**: Centralized ALUColors constants ensure consistent branding across all screens
6. **Upsert Pattern**: Single insert method handles both create and update operations (simpler API)
7. **Lazy Initialization**: DatabaseHelper only initializes storage when first needed, improving startup time
8. **Date Normalization**: Sessions are compared by date-only (ignoring time) for reliable week filtering
9. **Attendance Calculation**: Includes all sessions (past and future) to give complete engagement picture
10. **7-Day Window**: Dashboard shows assignments due within 7 days to balance urgency with manageability

## Setup Instructions

### Prerequisites

- **Flutter SDK**: 3.10.4 or higher
- **Dart SDK**: Included with Flutter
- **IDE**: VS Code or Android Studio (recommended)
- **Platform-Specific Tools** (optional, for mobile development):
  - Android Studio (for Android)
  - Xcode (for iOS, macOS only)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd student_academic_platform
   ```

2. **Verify Flutter installation**
   ```bash
   flutter doctor
   ```
   Ensure Flutter is properly configured for your target platform(s).

3. **Install dependencies**
   ```bash
   flutter pub get
   ```
   This installs all packages listed in `pubspec.yaml`.

4. **Run the app**
   ```bash
   # List available devices
   flutter devices
   
   # Run on specific device
   flutter run -d chrome          # Web browser
   flutter run -d windows         # Windows desktop
   flutter run -d android         # Android device/emulator
   flutter run -d ios              # iOS device/simulator (macOS only)
   flutter run -d linux            # Linux desktop
   flutter run -d macos            # macOS desktop
   
   # Or just run (Flutter will pick a device)
   flutter run
   ```

### Troubleshooting

**Windows Build Issues:**
- If you encounter file locking errors during Android builds, the app is configured with workarounds in `android/gradle.properties`
- Try running `flutter clean` and then `flutter pub get` if build fails

**Platform-Specific Setup:**
- **Android**: Ensure Android SDK is installed and `ANDROID_HOME` is set
- **iOS**: Requires macOS and Xcode installed
- **Web**: No additional setup needed, works out of the box

### First Time Setup

1. Launch the app - you'll see the **Login Screen**
2. Click **"Sign Up"** to create a new account
3. Enter your university email and password
4. Select at least one course
5. Click **"Sign Up"** - you'll be automatically logged in
6. You'll see the **Dashboard** with your academic overview

## Usage Guide

### Creating Assignments
1. Navigate to **Assignments** tab
2. Click **"Create Assignment"** button
3. Fill in:
   - Assignment title (required)
   - Course name (required)
   - Due date (required) - use date picker
   - Priority level (High/Medium/Low)
   - Assignment type (Formative/Summative)
4. Click **"Save Assignment"**

### Managing Sessions
1. Navigate to **Schedule** tab
2. Click **"Create Session"** button
3. Fill in:
   - Session title (required)
   - Date (required) - use date picker
   - Start time (required) - use time picker
   - End time (required) - use time picker
   - Location (optional)
   - Session type (Class/Mastery Session/Study Group/PSL Meeting)
4. Click **"Save Session"**

### Tracking Attendance
1. Navigate to **Schedule** tab
2. Find the session you attended
3. Click the **"Present/Absent"** toggle button
4. The attendance percentage on the Dashboard updates automatically

### Filtering Assignments
- Use the filter chips at the top of the Assignments screen
- Options: **All**, **Formative**, **Summative**

### Navigating Schedule
- Use **←** and **→** buttons to navigate between weeks
- Click **"Today"** to jump to the current week
- Sessions are grouped by day

## Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8                    # iOS-style icons
  shared_preferences: ^2.2.2                 # Local data storage (all platforms)
  shared_preferences_linux: ^2.3.0          # Linux platform support
  shared_preferences_windows: ^2.2.0        # Windows platform support
  intl: ^0.19.0                              # Date/time formatting and localization
```

### Development Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0                      # Code linting rules
  flutter_launcher_icons: ^0.13.1           # App icon generation
```

### Why These Dependencies?

- **shared_preferences**: Provides unified storage across all platforms without platform-specific code
- **intl**: Handles date formatting (e.g., "Monday, January 15") and time display
- **flutter_lints**: Ensures code quality and consistency across team members
- **No state management library**: StatefulWidget + DataService is sufficient for this app's scope

## Color Palette

The app uses ALU's official brand colors:

```dart
Primary Dark: #001F3F (Dark Navy Blue)
Accent Yellow: #FDB827 (Gold/Yellow for buttons)
Warning Red: #DC3545 (For alerts and warnings)
Text White: #FFFFFF
Text Gray: #B0B0B0
Card Background: #0A2540
Card Light Background: #1A3550
Success Green: #28A745
Info Blue: #17A2B8
```

## Testing

### Running Tests
```bash
flutter test
```

### Manual Testing Checklist
- [ ] Login with valid credentials
- [ ] Sign up with new account
- [ ] Create assignment and verify it appears
- [ ] Edit assignment and verify changes persist
- [ ] Mark assignment as complete
- [ ] Delete assignment
- [ ] Create session and verify it appears
- [ ] Toggle attendance and verify percentage updates
- [ ] Navigate between weeks in schedule
- [ ] Logout and verify return to login screen
- [ ] Close and reopen app - verify data persists

## Critical Components

### Data Models (`lib/models/`)

- **Student**: Stores email, password, and exactly 3 courses (enforced in factory constructor)
- **Assignment**: Includes id, title, dueDate, course, priority (High/Medium/Low), type (Formative/Summative), isCompleted
- **AcademicSession**: Contains id, title, date, startTime, endTime, location (optional), sessionType, isAttended

### Business Logic (`lib/services/data_service.dart`)

Key operations:
- `getStudent()`: Retrieves current student data
- `getAssignments()`: Gets all assignments (sorted by due date)
- `getSessions()`: Retrieves all academic sessions
- `calculateAttendancePercentage()`: Calculates attendance from all sessions (past and future)
- `insertAssignment()` / `updateAssignment()`: Save assignment data
- `insertSession()` / `updateSession()`: Save session data

### Data Storage (`lib/services/database_helper.dart`)

- **Singleton Pattern**: Ensures only one instance exists
- **Lazy Initialization**: Storage only initialized when first needed
- **Upsert Pattern**: Single method handles both insert and update operations
- **JSON Serialization**: All complex data stored as JSON strings in SharedPreferences
- **Storage Keys**:
  - `student_email`, `student_password`, `student_courses`: Student data
  - `assignments`: JSON array of all assignments
  - `sessions`: JSON array of all academic sessions

### Navigation Flow

```
LoginScreen → SignUpScreen (if new user)
     ↓
MainNavigation (after login)
     ├── DashboardScreen (default)
     ├── AssignmentScreen
     └── ScheduleScreen
```

All three main screens are kept in memory via `IndexedStack` to preserve state when switching tabs.

## Technical Notes

- **Data Persistence**: All data stored locally using SharedPreferences (no cloud sync)
- **No Backend**: Standalone application with local-only storage
- **Academic Week Calculation**: Assumes academic year starts in September. If current month is before September, uses previous year as start
- **Attendance Calculation**: Based on ALL sessions (past and future) to give complete engagement picture. Threshold: 75% (ALU requirement)
- **7-Day Assignment Window**: Dashboard shows assignments due within next 7 days to balance urgency with manageability
- **Date Normalization**: Sessions compared by date-only (time ignored) for reliable week filtering
- **Platform Support**: Works on Android, iOS, Web, Windows, macOS, Linux
- **Authentication**: Simple email/password matching (no encryption). Suitable for local-only app

## Contributing

### Code Style Guidelines

This project follows Flutter best practices and the assignment rubric requirements:

1. **Code Structure**
   - Clear separation of concerns: UI (`screens/`), logic (`services/`), data (`models/`)
   - Modular, reusable code structure
   - Consistent naming conventions (camelCase for variables, PascalCase for classes)

2. **Comments**
   - Inline comments explain **design decisions**, not just functionality
   - Use Dart doc comments (`///`) for public APIs and class-level documentation
   - Explain WHY choices were made, not just WHAT the code does

3. **Formatting**
   - Consistent indentation (2 spaces)
   - Proper line breaks for readability
   - Meaningful variable and function names

### Git Workflow

1. **Main Branch**: Contains the complete, working codebase
2. **Feature Branches**: Create branches for individual features or contributions
3. **Commit Messages**: Use clear, descriptive commit messages explaining what was changed and why

### Adding New Features

1. Create a feature branch from `main`
2. Implement your feature following the existing architecture
3. Add comments explaining design decisions
4. Test on your target platform(s)
5. Submit a pull request with a clear description

### Team Collaboration

- **Branch Strategy**: Each team member should work on their own feature branch
- **Code Review**: Review each other's code before merging to main
- **Commit History**: Ensure meaningful commits that reflect actual work done
- **Documentation**: Update README if adding new features or changing architecture

## License

Built for African Leadership University
*Empowering students to manage their academic journey*

---

---

## Project Information

**Version**: 1.0.0  
**Last Updated**: 2024  
**Developed for**: African Leadership University  
**Team**: Group 8

### Team Members
- Emmanuel Ngwoke
- Solace Afadhali Aziza
- Kelly Nshuti Dushimimana
- Samuel kwizera Ihimbazwe

---

*Empowering students to manage their academic journey*

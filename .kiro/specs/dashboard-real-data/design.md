# Design Document: Dashboard Real Data Integration

## Overview

This feature replaces all hardcoded/fake data in `child_home_screen.dart` with real data from Firebase through existing providers (AuthProvider, MedicationProvider, ReminderProvider, AlertProvider). The dashboard will display actual user data including medications, reminders, alerts, and compliance metrics.

The implementation maintains the current StatelessWidget structure and uses Provider pattern for state management. All data flows from Firebase through providers to the UI, ensuring real-time updates and accurate information display.

## Architecture

### Component Structure

```
ChildHomeScreen (StatelessWidget)
├── Provider.of<AuthProvider>() → User info
├── Provider.of<MedicationProvider>() → Medications, check-ins, compliance
├── Provider.of<ReminderProvider>() → Reminders
└── Provider.of<AlertProvider>() → Alerts
```

### Data Flow

1. **Authentication Layer**: AuthProvider provides user identity and effectiveParentId
2. **Data Providers**: MedicationProvider, ReminderProvider, AlertProvider listen to Firebase streams
3. **UI Layer**: ChildHomeScreen reads from providers using Provider.of or Consumer
4. **Real-time Updates**: Firebase streams automatically update providers, triggering UI rebuilds

### Provider Integration Pattern

The dashboard uses `Provider.of<T>(context)` to access provider data:

```dart
final authProvider = Provider.of<AuthProvider>(context);
final medicationProvider = Provider.of<MedicationProvider>(context);
final reminderProvider = Provider.of<ReminderProvider>(context);
final alertProvider = Provider.of<AlertProvider>(context);
```

For sections requiring frequent updates, `Consumer<T>` widgets can be used to optimize rebuilds.

## Components and Interfaces

### 1. Header Section

**Purpose**: Display user greeting with real name

**Data Source**: `AuthProvider.userModel.displayName`

**Interface**:
```dart
Widget _buildHeader(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context);
  final displayName = authProvider.userModel?.displayName ?? 'Người dùng';
  
  // Display greeting with displayName
}
```

**Fallback**: If displayName is null/empty, display "Người dùng"

### 2. Status Section

**Purpose**: Display today's medication status

**Data Sources**:
- `MedicationProvider.medications` - List of all medications
- `MedicationProvider.todayCheckIns` - Today's check-in records

**Interface**:
```dart
Widget _buildStatusSection(BuildContext context) {
  final medicationProvider = Provider.of<MedicationProvider>(context);
  final medications = medicationProvider.medications;
  final todayCheckIns = medicationProvider.todayCheckIns;
  
  // Map medications with their check-in status
  // Display status cards
}
```

**Status Mapping**:
- If check-in exists with status='completed' → Show green icon, "Đã uống lúc HH:mm"
- If check-in exists with status='missed' → Show red icon, "Đã bỏ lỡ"
- If no check-in and time passed → Show orange icon, "Chưa uống"
- If no check-in and time not passed → Show blue icon, "Sắp tới"

**Empty State**: Display "Chưa có lịch thuốc" when medications list is empty

### 3. Reminders Section

**Purpose**: Display reminders from family members

**Data Source**: `ReminderProvider.reminders`

**Interface**:
```dart
Widget _buildRemindersSection(BuildContext context) {
  final reminderProvider = Provider.of<ReminderProvider>(context);
  final reminders = reminderProvider.reminders;
  
  // Display reminder cards with content and timestamp
}
```

**Display Format**:
- Title: First line of content (truncated if needed)
- Subtitle: Full content
- Time: Format timestamp as "HH:mm - dd/MM"

**Empty State**: Display "Chưa có lời nhắn" when reminders list is empty

### 4. Alerts Section

**Purpose**: Display unread alerts about medication compliance

**Data Source**: `AlertProvider.unreadAlerts`

**Interface**:
```dart
Widget _buildAlertsSection(BuildContext context) {
  final alertProvider = Provider.of<AlertProvider>(context);
  final alerts = alertProvider.unreadAlerts;
  
  // Display alert cards with title, message, timestamp
}
```

**Display Format**:
- Title: alert.title
- Subtitle: alert.message
- Time: Format timestamp as "HH:mm - dd tháng MM"

**Empty State**: Display "Không có cảnh báo" when alerts list is empty

### 5. Compliance Rate Section

**Purpose**: Display monthly medication compliance percentage

**Data Source**: `MedicationProvider.complianceRate`

**Interface**:
```dart
Widget _buildWeeklyComplianceSection(BuildContext context) {
  final medicationProvider = Provider.of<MedicationProvider>(context);
  final complianceRate = medicationProvider.complianceRate;
  
  // Display percentage with format "XX%"
}
```

**Display Format**:
- Percentage: `"${complianceRate.toStringAsFixed(0)}%"`
- Month: Current month/year "Tháng MM/YYYY"

### 6. Weekly Compliance Section

**Purpose**: Display daily compliance status for current week

**Data Source**: `MedicationProvider.weeklyCompliance`

**Interface**:
```dart
Widget _buildWeeklyComplianceSection(BuildContext context) {
  final medicationProvider = Provider.of<MedicationProvider>(context);
  final weeklyData = medicationProvider.weeklyCompliance;
  
  // Display 7 day status icons
}
```

**Status Icon Mapping**:
- 'completed' → Green check icon (Icons.check)
- 'missed' → Red close icon (Icons.close)
- 'pending' → Orange clock icon (Icons.access_time)
- 'upcoming' → Navy circle icon (Icons.remove_circle_outline)

**Data Structure**: `List<Map<String, dynamic>>` with keys 'day' and 'status'

## Data Models

### AuthProvider Data

```dart
class AuthProvider {
  User? user;                    // Firebase user
  UserModel? userModel;          // Custom user model
  String? effectiveParentId;     // Parent ID for data queries
}

class UserModel {
  String displayName;
  String email;
  String role;
  String? parentId;
}
```

### MedicationProvider Data

```dart
class MedicationProvider {
  List<MedicationModel> medications;
  List<CheckInModel> todayCheckIns;
  double complianceRate;
  List<Map<String, dynamic>> weeklyCompliance;
}

class MedicationModel {
  String id;
  String name;
  String time;        // 'HH:mm'
  String type;        // 'Thuốc' | 'Bữa ăn' | 'Hoạt động'
}

class CheckInModel {
  String id;
  String medicationId;
  String status;      // 'completed' | 'missed'
  DateTime? timestamp;
}
```

### ReminderProvider Data

```dart
class ReminderProvider {
  List<ReminderModel> reminders;
}

class ReminderModel {
  String id;
  String content;
  DateTime? timestamp;
}
```

### AlertProvider Data

```dart
class AlertProvider {
  List<AlertModel> unreadAlerts;
}

class AlertModel {
  String id;
  String title;
  String message;
  DateTime? timestamp;
}
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Display Name Rendering

*For any* non-null, non-empty displayName string, when rendered in the header, the output SHALL contain that exact displayName text.

**Validates: Requirements 1.2**

### Property 2: Medication Card Data Completeness

*For any* medication with non-empty name, time, and status, when rendered as a medication card, the output SHALL contain the medication's name, time, and status fields.

**Validates: Requirements 2.4**

### Property 3: Reminder Card Data Completeness

*For any* reminder with non-empty content and valid timestamp, when rendered as a reminder card, the output SHALL contain the reminder's content and formatted timestamp.

**Validates: Requirements 3.3**

### Property 4: Alert Card Data Completeness

*For any* alert with non-empty title, message, and valid timestamp, when rendered as an alert card, the output SHALL contain the alert's title, message, and formatted timestamp.

**Validates: Requirements 4.3**

### Property 5: Compliance Rate Formatting

*For any* compliance rate value between 0 and 100, when displayed, the output SHALL be formatted as a string matching the pattern "XX%" where XX is the rate rounded to the nearest integer.

**Validates: Requirements 5.2**

### Property 6: Date Formatting

*For any* valid DateTime object, when formatted for display, the output SHALL match the pattern "Tháng MM/YYYY" where MM is the month number and YYYY is the four-digit year.

**Validates: Requirements 5.4**

### Property 7: Weekly Status Icon Mapping

*For any* day status value in the set {'completed', 'missed', 'pending', 'upcoming'}, the rendered icon SHALL match the following mapping:
- 'completed' → Icons.check with green color
- 'missed' → Icons.close with red color
- 'pending' → Icons.access_time with orange color
- 'upcoming' → Icons.remove_circle_outline with navy color

**Validates: Requirements 6.3, 6.4, 6.5, 6.6**

## Error Handling

### Provider Data Unavailability

**Scenario**: Provider data is null or unavailable during initial load

**Handling**:
- Display loading indicators while `isLoading` is true
- Show empty state messages when lists are empty
- Use fallback values for null data (e.g., "Người dùng" for null displayName)

**Implementation**:
```dart
final displayName = authProvider.userModel?.displayName ?? 'Người dùng';
final medications = medicationProvider.medications; // Empty list if null
```

### Firebase Connection Errors

**Scenario**: Firebase stream encounters an error

**Handling**:
- Providers handle errors internally and set `errorMessage`
- Dashboard can optionally display error messages from providers
- Existing data remains displayed until new data arrives

**Implementation**:
```dart
if (medicationProvider.errorMessage != null) {
  // Optionally show error snackbar
}
```

### Invalid Data Formats

**Scenario**: Data from Firebase has unexpected format (e.g., invalid time string)

**Handling**:
- Models use safe parsing with fallback values
- UI displays fallback values gracefully
- No crashes or exceptions propagate to UI

**Example**:
```dart
time: data['time'] as String? ?? '08:00',  // Fallback to default time
```

### Empty States

**Scenario**: User has no medications, reminders, or alerts

**Handling**:
- Display friendly empty state messages
- Provide context about what the section shows
- Maintain consistent UI layout

**Messages**:
- Medications: "Chưa có lịch thuốc"
- Reminders: "Chưa có lời nhắn"
- Alerts: "Không có cảnh báo"

## Testing Strategy

### Dual Testing Approach

This feature requires both unit tests and property-based tests for comprehensive coverage:

**Unit Tests** focus on:
- Specific examples of data rendering
- Edge cases (empty lists, null values, zero compliance rate)
- Integration with providers
- Widget tree structure verification

**Property Tests** focus on:
- Universal properties across all possible inputs
- Data completeness for any valid medication/reminder/alert
- Format consistency for any date or percentage value
- Icon mapping correctness for any status value

### Property-Based Testing Configuration

**Library**: Use `flutter_test` with custom property test helpers or `test` package with manual randomization

**Configuration**:
- Minimum 100 iterations per property test
- Each test references its design document property
- Tag format: **Feature: dashboard-real-data, Property {number}: {property_text}**

### Unit Test Examples

```dart
testWidgets('displays user displayName in header', (tester) async {
  // Arrange: Mock AuthProvider with displayName
  // Act: Render ChildHomeScreen
  // Assert: Find displayName text in widget tree
});

testWidgets('displays empty state when medications list is empty', (tester) async {
  // Arrange: Mock MedicationProvider with empty list
  // Act: Render ChildHomeScreen
  // Assert: Find empty state message
});

testWidgets('displays zero compliance rate correctly', (tester) async {
  // Arrange: Mock MedicationProvider with 0% compliance
  // Act: Render ChildHomeScreen
  // Assert: Find "0%" text
});
```

### Property Test Examples

```dart
test('Property 1: Display Name Rendering', () {
  // Feature: dashboard-real-data, Property 1: Display Name Rendering
  for (int i = 0; i < 100; i++) {
    final displayName = generateRandomNonEmptyString();
    final rendered = renderHeaderWithDisplayName(displayName);
    expect(rendered, contains(displayName));
  }
});

test('Property 5: Compliance Rate Formatting', () {
  // Feature: dashboard-real-data, Property 5: Compliance Rate Formatting
  for (int i = 0; i < 100; i++) {
    final rate = generateRandomDouble(0, 100);
    final formatted = formatComplianceRate(rate);
    final expected = '${rate.toStringAsFixed(0)}%';
    expect(formatted, equals(expected));
  }
});

test('Property 7: Weekly Status Icon Mapping', () {
  // Feature: dashboard-real-data, Property 7: Weekly Status Icon Mapping
  final statusMap = {
    'completed': (Icons.check, AppColors.success),
    'missed': (Icons.close, AppColors.error),
    'pending': (Icons.access_time, AppColors.accentOrange),
    'upcoming': (Icons.remove_circle_outline, AppColors.secondaryNavy),
  };
  
  for (int i = 0; i < 100; i++) {
    final status = statusMap.keys.elementAt(Random().nextInt(4));
    final (icon, color) = getIconForStatus(status);
    final (expectedIcon, expectedColor) = statusMap[status]!;
    expect(icon, equals(expectedIcon));
    expect(color, equals(expectedColor));
  }
});
```

### Test Coverage Goals

- **Unit Tests**: Cover all edge cases, empty states, and specific examples
- **Property Tests**: Cover all 7 correctness properties with 100+ iterations each
- **Integration Tests**: Verify provider integration and data flow
- **Widget Tests**: Verify UI structure and navigation

### Testing Constraints

- Tests must not create new files (use existing test structure)
- Tests must not require Firebase emulator (use mocked providers)
- Tests must run quickly (< 5 seconds for full suite)
- Tests must be deterministic (no flaky tests)

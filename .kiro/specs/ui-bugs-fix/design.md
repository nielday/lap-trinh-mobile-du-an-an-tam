# UI Bugs Fix Design

## Overview

This design addresses four distinct UI bugs in the Flutter app:
1. **Vietnamese Text Encoding**: Garbled Vietnamese characters due to incorrect file encoding
2. **Navigation Bar Visibility**: Bottom navigation bar disappears when switching tabs
3. **Schedule Type Icons**: Wrong icons displayed for meal and activity schedule types
4. **Dashboard Fake Data**: Hardcoded data instead of real Firestore data from providers

The fix approach is minimal and targeted:
- Bug #1: Convert source files from Latin-1 to UTF-8 encoding
- Bug #2: Replace Navigator.push with state management for tab switching
- Bug #3: Add proper icon mapping logic for schedule types
- Bug #4: Replace hardcoded widgets with Consumer widgets that read from providers

## Glossary

- **Bug_Condition (C)**: The conditions that trigger each of the four bugs
- **Property (P)**: The desired correct behavior for each bug
- **Preservation**: Existing functionality that must remain unchanged
- **child_home_screen.dart**: The main dashboard file at `lib/src/features/home/presentation/child_home_screen.dart`
- **daily_schedule_screen.dart**: The schedule screen file at `lib/src/features/schedule/presentation/daily_schedule_screen.dart`
- **UTF-8**: Unicode character encoding that properly supports Vietnamese diacritics
- **Latin-1**: Legacy encoding that causes Vietnamese characters to display incorrectly
- **Navigator.push**: Flutter navigation that creates a new screen stack (hides bottom nav)
- **State Management**: Using setState or provider to switch content without navigation
- **MedicationProvider**: Provider that manages medication schedules and check-ins
- **ReminderProvider**: Provider that manages reminders from parent to child
- **AlertProvider**: Provider that manages unread alerts
- **Consumer**: Flutter widget that rebuilds when provider data changes


## Bug Details

### Bug Condition #1: Vietnamese Text Encoding

The bug manifests when Vietnamese text is rendered in the app. The source files are encoded in Latin-1 instead of UTF-8, causing Vietnamese diacritics to be misinterpreted.

**Formal Specification:**
```
FUNCTION isBugCondition1(file)
  INPUT: file of type SourceFile
  OUTPUT: boolean
  
  RETURN file.encoding == 'Latin-1'
         AND file.containsVietnameseText == true
         AND file.renderedText != file.intendedText
END FUNCTION
```

**Examples:**
- "Chào mừng trở lại" renders as "Ch├áo mß╗½ng trß╗ƒ lß║íi"
- "Bố nhờ mua đồ" renders as "Bß╗æ nhß╗¥ mua ─æß╗ô"
- "Thuốc Huyết áp" renders as "Thuß╗æc Huyß║┐t ├íp"

### Bug Condition #2: Navigation Bar Visibility

The bug manifests when the user taps Schedule or Settings tabs. The code uses Navigator.push which creates a new screen and hides the bottom navigation bar.

**Formal Specification:**
```
FUNCTION isBugCondition2(interaction)
  INPUT: interaction of type UserTapEvent
  OUTPUT: boolean
  
  RETURN interaction.target IN ['Schedule tab', 'Settings tab']
         AND navigationMethod == 'Navigator.push'
         AND bottomNavBar.visible == false
END FUNCTION
```

**Examples:**
- Tap Schedule tab → new screen opens → bottom nav disappears
- Tap Settings tab → new screen opens → bottom nav disappears
- Tap Dashboard tab → stays on same screen → bottom nav remains (correct)

### Bug Condition #3: Schedule Type Icons

The bug manifests when schedule items have type "Bữa ăn" (meal) or "Hoạt động" (activity). The icon mapping logic defaults to medication icon for all types.

**Formal Specification:**
```
FUNCTION isBugCondition3(scheduleItem)
  INPUT: scheduleItem of type ScheduleItem
  OUTPUT: boolean
  
  RETURN scheduleItem.type IN ['Bữa ăn', 'Hoạt động']
         AND displayedIcon == Icons.medication
         AND displayedIcon != expectedIconForType(scheduleItem.type)
END FUNCTION
```

**Examples:**
- Type "Bữa ăn" → shows medication icon → should show restaurant icon
- Type "Hoạt động" → shows medication icon → should show directions_walk icon
- Type "Thuốc" → shows medication icon → correct (no change needed)

### Bug Condition #4: Dashboard Fake Data

The bug manifests when the Dashboard screen is displayed. All sections show hardcoded fake data instead of fetching real data from Firestore providers.

**Formal Specification:**
```
FUNCTION isBugCondition4(dashboardSection)
  INPUT: dashboardSection of type DashboardWidget
  OUTPUT: boolean
  
  RETURN dashboardSection.dataSource == 'hardcoded'
         AND dashboardSection.name IN ['Status', 'Reminders', 'Alerts', 'Recent Activities', 'Weekly Compliance']
         AND NOT dashboardSection.usesProvider()
END FUNCTION
```

**Examples:**
- Status section shows "Thuốc Huyết áp", "DI khám mắt" → should show MedicationProvider.todayCheckIns
- Reminders show "Bố nhờ mua đồ" → should show ReminderProvider.reminders
- Alerts show "Cảnh báo uống thuốc" → should show AlertProvider.unreadAlerts
- Recent activities show "Đã uống thuốc huyết áp" → should show recent check-ins from MedicationProvider
- Weekly compliance shows hardcoded 30%, T2-CN → should show MedicationProvider.weeklyCompliance


## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Dashboard tab navigation must continue to work correctly
- Action buttons (call, message) must continue using Navigator.push for modal screens
- Status cards, reminders, alerts visual styling must remain unchanged
- Weekly compliance day status icons must maintain correct colors and states
- Schedule items with type "Thuốc" or null must continue showing medication icon
- All other UI components not mentioned in the bug conditions must remain unchanged

**Scope:**
All inputs that do NOT involve the four specific bug conditions should be completely unaffected by this fix. This includes:
- Other navigation flows (login, chat, etc.)
- Other text that is already displaying correctly
- Other schedule types that already have correct icons
- Other dashboard interactions (scrolling, tapping cards, etc.)

## Hypothesized Root Cause

Based on the bug descriptions, the root causes are:

1. **Vietnamese Text Encoding Issue**:
   - Source files were saved with Latin-1 encoding instead of UTF-8
   - Flutter/Dart expects UTF-8 by default
   - When Latin-1 bytes are interpreted as UTF-8, Vietnamese diacritics become garbled

2. **Navigation Bar Visibility Issue**:
   - Bottom navigation bar is defined in child_home_screen.dart
   - Schedule and Settings tabs use Navigator.push to navigate
   - Navigator.push creates a new route that doesn't include the bottom nav bar
   - Should use state management (e.g., IndexedStack or PageView) to switch content

3. **Schedule Type Icons Issue**:
   - Icon mapping logic in daily_schedule_screen.dart doesn't handle all schedule types
   - Likely uses a default case that returns medication icon
   - Missing explicit cases for "Bữa ăn" and "Hoạt động"

4. **Dashboard Fake Data Issue**:
   - child_home_screen.dart uses hardcoded widgets instead of Consumer widgets
   - No provider integration in the dashboard sections
   - Providers (MedicationProvider, ReminderProvider, AlertProvider) exist and have data
   - Need to wrap sections with Consumer widgets and map provider data to UI


## Correctness Properties

Property 1: Bug Condition - Vietnamese Text Display

_For any_ source file containing Vietnamese text where the file encoding is Latin-1, the fixed code SHALL convert the file to UTF-8 encoding so that Vietnamese characters render correctly with proper diacritics.

**Validates: Requirements 2.1**

Property 2: Bug Condition - Navigation Bar Visibility

_For any_ user interaction where the Schedule or Settings tab is tapped, the fixed code SHALL display the corresponding screen content while keeping the bottom navigation bar visible, using state management instead of Navigator.push.

**Validates: Requirements 2.2, 2.3**

Property 3: Bug Condition - Schedule Type Icons

_For any_ schedule item where the type is "Bữa ăn" or "Hoạt động", the fixed code SHALL display the correct icon (restaurant for meals, directions_walk for activities) with the appropriate color.

**Validates: Requirements 2.4, 2.5**

Property 4: Bug Condition - Dashboard Real Data

_For any_ dashboard section (Status, Reminders, Alerts, Recent Activities, Weekly Compliance), the fixed code SHALL fetch and display real data from the corresponding provider (MedicationProvider, ReminderProvider, AlertProvider) instead of showing hardcoded fake data.

**Validates: Requirements 2.6, 2.7, 2.8, 2.9, 2.10**

Property 5: Preservation - Existing Functionality

_For any_ user interaction or UI component that is NOT part of the four bug conditions, the fixed code SHALL produce exactly the same behavior as the original code, preserving all existing functionality.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8**


## Fix Implementation

### Changes Required

Assuming our root cause analysis is correct:

**Bug #1: Vietnamese Text Encoding**

**Files**: 
- `lib/src/features/home/presentation/child_home_screen.dart`
- Any other files with garbled Vietnamese text

**Specific Changes**:
1. **Convert File Encoding**: Use a text editor or command-line tool to convert files from Latin-1 to UTF-8
   - Ensure "Chào mừng trở lại" displays correctly
   - Verify all Vietnamese strings render properly

**Bug #2: Navigation Bar Visibility**

**File**: `lib/src/features/home/presentation/child_home_screen.dart`

**Specific Changes**:
1. **Add State Management**: Add a `_selectedIndex` state variable to track current tab
2. **Replace Navigator.push**: Remove Navigator.push calls for Schedule and Settings tabs
3. **Implement Tab Switching**: Use IndexedStack or conditional rendering to switch between Dashboard, Schedule, and Settings screens
4. **Update onTap Handlers**: Change tab onTap to call setState and update `_selectedIndex`
5. **Keep Bottom Nav Visible**: Ensure bottom navigation bar remains visible across all tabs

**Bug #3: Schedule Type Icons**

**File**: `lib/src/features/schedule/presentation/daily_schedule_screen.dart`

**Specific Changes**:
1. **Update Icon Mapping Logic**: Add explicit cases for "Bữa ăn" and "Hoạt động"
   - "Bữa ăn" → Icons.restaurant, color: Color(0xFF66BB6A)
   - "Hoạt động" → Icons.directions_walk, color: Color(0xFF42A5F5)
   - "Thuốc" or null → Icons.medication, color: Color(0xFF7E57C2) (existing)

**Bug #4: Dashboard Fake Data**

**File**: `lib/src/features/home/presentation/child_home_screen.dart`

**Specific Changes**:
1. **Add Provider Imports**: Import MedicationProvider, ReminderProvider, AlertProvider
2. **Wrap with Consumer Widgets**: Replace hardcoded sections with Consumer widgets
3. **Status Section**: Use Consumer<MedicationProvider> to display todayCheckIns
   - Map check-ins to _StatusCard widgets
   - Show medication name, time, completion status
4. **Reminders Section**: Use Consumer<ReminderProvider> to display reminders
   - Map reminders to _ReminderCard widgets
   - Show reminder content, timestamp
5. **Alerts Section**: Use Consumer<AlertProvider> to display unreadAlerts
   - Map alerts to _AlertCard widgets
   - Show alert content, timestamp
6. **Recent Activities**: Use Consumer<MedicationProvider> to display recent completed check-ins
   - Filter todayCheckIns for completed status
   - Show most recent activity
7. **Weekly Compliance**: Use Consumer<MedicationProvider> to display weeklyCompliance
   - Use complianceRate getter for percentage
   - Use weeklyCompliance getter for T2-CN status
8. **Handle Empty States**: Add conditional rendering for empty lists
9. **Handle Loading States**: Show loading indicators when isLoading is true


## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate each bug on unfixed code, then verify the fixes work correctly and preserve existing behavior.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate the bugs BEFORE implementing the fixes. Confirm or refute the root cause analysis.

**Test Plan**: Write tests that check for each bug condition. Run these tests on the UNFIXED code to observe failures and understand the root causes.

**Test Cases**:
1. **Vietnamese Text Test**: Open the app and verify Vietnamese text displays as garbled (will fail on unfixed code)
2. **Navigation Bar Test**: Tap Schedule tab and verify bottom nav disappears (will fail on unfixed code)
3. **Schedule Icon Test**: Create schedule items with type "Bữa ăn" and verify medication icon is shown (will fail on unfixed code)
4. **Dashboard Data Test**: Open dashboard and verify hardcoded data is shown instead of provider data (will fail on unfixed code)

**Expected Counterexamples**:
- Vietnamese characters render as garbled text (e.g., "Ch├áo mß╗½ng")
- Bottom navigation bar is hidden after tapping Schedule/Settings tabs
- Meal and activity schedule items show medication icon
- Dashboard shows "Thuốc Huyết áp", "Bố nhờ mua đồ" regardless of Firestore data

### Fix Checking

**Goal**: Verify that for all inputs where the bug conditions hold, the fixed code produces the expected behavior.

**Pseudocode:**
```
FOR ALL file WHERE isBugCondition1(file) DO
  result := renderVietnameseText_fixed(file)
  ASSERT result.encoding == 'UTF-8'
  ASSERT result.displayedText == result.intendedText
END FOR

FOR ALL interaction WHERE isBugCondition2(interaction) DO
  result := handleTabTap_fixed(interaction)
  ASSERT result.bottomNavBar.visible == true
  ASSERT result.screenContent == expectedScreen(interaction.target)
END FOR

FOR ALL scheduleItem WHERE isBugCondition3(scheduleItem) DO
  result := getScheduleIcon_fixed(scheduleItem)
  ASSERT result.icon == expectedIconForType(scheduleItem.type)
  ASSERT result.color == expectedColorForType(scheduleItem.type)
END FOR

FOR ALL dashboardSection WHERE isBugCondition4(dashboardSection) DO
  result := renderDashboardSection_fixed(dashboardSection)
  ASSERT result.dataSource == 'provider'
  ASSERT result.data == providerData(dashboardSection.name)
END FOR
```

### Preservation Checking

**Goal**: Verify that for all inputs where the bug conditions do NOT hold, the fixed code produces the same result as the original code.

**Pseudocode:**
```
FOR ALL interaction WHERE NOT (isBugCondition1 OR isBugCondition2 OR isBugCondition3 OR isBugCondition4) DO
  ASSERT originalBehavior(interaction) = fixedBehavior(interaction)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss
- It provides strong guarantees that behavior is unchanged for all non-buggy inputs

**Test Plan**: Observe behavior on UNFIXED code first for non-bug interactions, then write property-based tests capturing that behavior.

**Test Cases**:
1. **Dashboard Tab Preservation**: Verify Dashboard tab continues to work correctly
2. **Action Buttons Preservation**: Verify call and message buttons continue using Navigator.push
3. **Medication Icon Preservation**: Verify schedule items with type "Thuốc" continue showing medication icon
4. **Other Text Preservation**: Verify non-Vietnamese text or already-correct text remains unchanged
5. **UI Layout Preservation**: Verify all visual styling, colors, spacing remain unchanged

### Unit Tests

- Test Vietnamese text rendering with UTF-8 encoded files
- Test tab switching with state management (no Navigator.push)
- Test icon mapping for all schedule types (Thuốc, Bữa ăn, Hoạt động)
- Test dashboard sections with mock provider data
- Test empty states when providers have no data
- Test loading states when providers are loading

### Property-Based Tests

- Generate random schedule types and verify correct icons are displayed
- Generate random provider data and verify dashboard displays it correctly
- Generate random tab interactions and verify bottom nav remains visible
- Test that all non-buggy interactions continue to work across many scenarios

### Integration Tests

- Test full app flow with Vietnamese text display
- Test switching between all three tabs (Dashboard, Schedule, Settings)
- Test creating and viewing different schedule types
- Test dashboard with real Firestore data from providers
- Test dashboard with empty provider data
- Test dashboard with loading provider states

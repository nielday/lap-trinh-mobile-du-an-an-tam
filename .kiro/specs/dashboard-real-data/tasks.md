# Implementation Plan: Dashboard Real Data Integration

## Overview

Replace all hardcoded/fake data in `child_home_screen.dart` with real data from Firebase through existing providers (AuthProvider, MedicationProvider, ReminderProvider, AlertProvider). The implementation maintains the current StatelessWidget structure and uses Provider.of pattern for state management.

## Tasks

- [x] 1. Integrate AuthProvider for user information
  - Add Provider.of<AuthProvider>(context) to _buildHeader method
  - Replace hardcoded greeting text with authProvider.userModel?.displayName
  - Implement fallback to "Người dùng" when displayName is null/empty
  - _Requirements: 1.1, 1.2, 1.3_

- [ ]* 1.1 Write property test for display name rendering
  - **Property 1: Display Name Rendering**
  - **Validates: Requirements 1.2**

- [x] 2. Integrate MedicationProvider for status section
  - [x] 2.1 Add Provider.of<MedicationProvider>(context) to _buildStatusSection
    - Retrieve medications list and todayCheckIns from provider
    - Map medications with their check-in status
    - _Requirements: 2.1, 2.2_
  
  - [x] 2.2 Implement status mapping logic
    - Map check-in status to icon colors and text
    - Handle completed, missed, pending, and upcoming states
    - Format timestamps as "HH:mm"
    - _Requirements: 2.4_
  
  - [x] 2.3 Implement empty state for medications
    - Display "Chưa có lịch thuốc" when medications list is empty
    - _Requirements: 2.3_

- [ ]* 2.4 Write property test for medication card data completeness
  - **Property 2: Medication Card Data Completeness**
  - **Validates: Requirements 2.4**

- [x] 3. Integrate ReminderProvider for reminders section
  - [x] 3.1 Add Provider.of<ReminderProvider>(context) to _buildRemindersSection
    - Retrieve reminders list from provider
    - Display reminder cards with content and timestamp
    - _Requirements: 3.1, 3.2_
  
  - [x] 3.2 Format reminder timestamps
    - Format timestamps as "HH:mm - dd/MM"
    - Handle null timestamps gracefully
    - _Requirements: 3.3_
  
  - [x] 3.3 Implement empty state for reminders
    - Display "Chưa có lời nhắn" when reminders list is empty
    - _Requirements: 3.2_

- [ ]* 3.4 Write property test for reminder card data completeness
  - **Property 3: Reminder Card Data Completeness**
  - **Validates: Requirements 3.3**

- [x] 4. Integrate AlertProvider for alerts section
  - [x] 4.1 Add Provider.of<AlertProvider>(context) to _buildAlertsSection
    - Retrieve unreadAlerts list from provider
    - Display alert cards with title, message, and timestamp
    - _Requirements: 4.1, 4.2_
  
  - [x] 4.2 Format alert timestamps
    - Format timestamps as "HH:mm - dd tháng MM"
    - Handle null timestamps gracefully
    - _Requirements: 4.3_
  
  - [x] 4.3 Implement empty state for alerts
    - Display "Không có cảnh báo" when alerts list is empty
    - _Requirements: 4.2_

- [ ]* 4.4 Write property test for alert card data completeness
  - **Property 4: Alert Card Data Completeness**
  - **Validates: Requirements 4.3**

- [x] 5. Checkpoint - Ensure all sections display real data
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Integrate MedicationProvider for compliance rate section
  - [x] 6.1 Add Provider.of<MedicationProvider>(context) to _buildWeeklyComplianceSection
    - Retrieve complianceRate from provider
    - Format as percentage with "XX%" pattern
    - _Requirements: 5.1, 5.2_
  
  - [x] 6.2 Display current month and year
    - Format current date as "Tháng MM/YYYY"
    - Use DateTime.now() for current date
    - _Requirements: 5.4_
  
  - [x] 6.3 Handle zero compliance rate
    - Display "0%" when complianceRate is 0
    - _Requirements: 5.3_

- [ ]* 6.4 Write property test for compliance rate formatting
  - **Property 5: Compliance Rate Formatting**
  - **Validates: Requirements 5.2**

- [ ]* 6.5 Write property test for date formatting
  - **Property 6: Date Formatting**
  - **Validates: Requirements 5.4**

- [x] 7. Integrate MedicationProvider for weekly compliance section
  - [x] 7.1 Retrieve weeklyCompliance data from provider
    - Access weeklyCompliance list from MedicationProvider
    - Map each day's status to corresponding icon and color
    - _Requirements: 6.1, 6.2_
  
  - [x] 7.2 Implement status icon mapping
    - Map 'completed' to green check icon
    - Map 'missed' to red close icon
    - Map 'pending' to orange clock icon
    - Map 'upcoming' to navy circle icon
    - _Requirements: 6.3, 6.4, 6.5, 6.6_

- [ ]* 7.3 Write property test for weekly status icon mapping
  - **Property 7: Weekly Status Icon Mapping**
  - **Validates: Requirements 6.3, 6.4, 6.5, 6.6**

- [x] 8. Verify widget type and navigation preservation
  - [x] 8.1 Confirm StatelessWidget structure is maintained
    - Verify ChildHomeScreen remains a StatelessWidget
    - Ensure no conversion to StatefulWidget
    - _Requirements: 7.1, 7.2_
  
  - [x] 8.2 Verify bottom navigation bar behavior
    - Confirm Navigator.push is used for Schedule and Settings navigation
    - Verify bottom navbar remains visible after navigation
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [x] 9. Final checkpoint - Ensure compilation and no new files
  - Verify code compiles without syntax, type, or import errors
  - Confirm only child_home_screen.dart was modified
  - Confirm no new files were created
  - Ensure all tests pass, ask the user if questions arise.
  - _Requirements: 9.1, 9.2, 9.3, 10.1, 10.2, 10.3_

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- All implementation must maintain StatelessWidget structure
- Use Provider.of pattern consistently throughout

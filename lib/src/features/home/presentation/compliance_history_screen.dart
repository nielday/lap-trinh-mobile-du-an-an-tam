import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../providers/medication_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../repositories/medication_repository.dart';
import '../../../repositories/appointment_repository.dart';
import '../../../models/check_in_model.dart';
import '../../../models/appointment_model.dart';

/// Màn hình lịch sử tuân thủ chi tiết với calendar view và chọn tháng
class ComplianceHistoryScreen extends StatefulWidget {
  const ComplianceHistoryScreen({super.key});

  @override
  State<ComplianceHistoryScreen> createState() => _ComplianceHistoryScreenState();
}

class _ComplianceHistoryScreenState extends State<ComplianceHistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime _selectedMonth = DateTime.now();
  List<CheckInModel> _selectedMonthCheckIns = [];
  List<AppointmentModel> _selectedMonthAppointments = [];
  bool _isLoadingMonth = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadMonthData();
  }

  Future<void> _loadMonthData() async {
    setState(() {
      _isLoadingMonth = true;
    });

    final parentId = context.read<AuthProvider>().effectiveParentId;
    
    if (parentId == null) {
      setState(() {
        _isLoadingMonth = false;
      });
      return;
    }

    try {
      final medRepo = MedicationRepository();
      final apptRepo = AppointmentRepository();
      final startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final endOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);
      
      // Load check-ins và appointments cho tháng được chọn
      final checkIns = await medRepo.getCheckInsInRange(parentId, startOfMonth, endOfMonth);
      final appointments = await apptRepo.getAppointmentsInRange(parentId, startOfMonth, endOfMonth);
      
      debugPrint('=== Load Month Data ===');
      debugPrint('parentId: $parentId');
      debugPrint('startOfMonth: $startOfMonth');
      debugPrint('endOfMonth: $endOfMonth');
      debugPrint('checkIns loaded: ${checkIns.length}');
      debugPrint('appointments loaded: ${appointments.length}');
      for (final appt in appointments) {
        debugPrint('  - ${appt.title}: ${appt.date} (status: ${appt.status})');
      }
      
      setState(() {
        _selectedMonthCheckIns = checkIns;
        _selectedMonthAppointments = appointments;
        _isLoadingMonth = false;
      });
    } catch (e) {
      debugPrint('Error loading month data: $e');
      setState(() {
        _isLoadingMonth = false;
      });
    }
  }

  void _changeMonth(int monthOffset) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + monthOffset, 1);
      _focusedDay = _selectedMonth;
    });
    _loadMonthData();
  }

  @override
  Widget build(BuildContext context) {
    final medProvider = context.watch<MedicationProvider>();
    
    // Sử dụng dữ liệu từ tháng được chọn
    final monthCheckIns = _selectedMonthCheckIns;
    final monthAppointments = _selectedMonthAppointments;
    
    // Tính tổng số hoạt động và hoàn thành
    final totalActivities = monthCheckIns.length + monthAppointments.length;
    final completedCheckIns = monthCheckIns.where((c) => c.status == 'completed').length;
    final completedAppointments = monthAppointments.where((a) => a.status == 'completed').length;
    final totalCompleted = completedCheckIns + completedAppointments;
    
    // Tính tỷ lệ tuân thủ cho tháng được chọn
    final rate = totalActivities == 0 ? 0.0 : (totalCompleted / totalActivities) * 100;
    
    final monthLabel = DateFormat('MMMM yyyy', 'vi_VN').format(_selectedMonth);

    // Debug
    debugPrint('=== ComplianceHistoryScreen Debug ===');
    debugPrint('Selected month: $_selectedMonth');
    debugPrint('monthCheckIns length: ${monthCheckIns.length}');
    debugPrint('monthAppointments length: ${monthAppointments.length}');
    debugPrint('totalActivities: $totalActivities');
    debugPrint('totalCompleted: $totalCompleted');
    debugPrint('complianceRate: $rate');
    
    // Nhóm check-ins và appointments theo ngày
    final Map<DateTime, List<dynamic>> activitiesByDate = {};
    
    // Thêm check-ins
    for (final checkIn in monthCheckIns) {
      if (checkIn.timestamp == null) continue;
      final date = DateTime(
        checkIn.timestamp!.year,
        checkIn.timestamp!.month,
        checkIn.timestamp!.day,
      );
      if (!activitiesByDate.containsKey(date)) {
        activitiesByDate[date] = [];
      }
      activitiesByDate[date]!.add({'type': 'checkin', 'data': checkIn});
    }
    
    // Thêm appointments
    for (final appointment in monthAppointments) {
      final date = DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
      );
      if (!activitiesByDate.containsKey(date)) {
        activitiesByDate[date] = [];
      }
      activitiesByDate[date]!.add({'type': 'appointment', 'data': appointment});
    }

    debugPrint('Grouped by date: ${activitiesByDate.length} days');

    // Lấy activities của ngày được chọn
    final selectedActivities = _selectedDay != null 
        ? (activitiesByDate[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? []) 
        : [];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lịch sử tuân thủ',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoadingMonth
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month selector
                  _buildMonthSelector(),
                  
                  const SizedBox(height: 16),
                  
                  // Tổng quan tháng
                  _buildMonthSummary(monthLabel, rate, totalCompleted),
                  
                  const SizedBox(height: 16),
                  
                  // Calendar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      locale: 'vi_VN',
                      headerVisible: false, // Ẩn header mặc định vì đã có custom month selector
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                          _selectedMonth = DateTime(focusedDay.year, focusedDay.month, 1);
                        });
                        _loadMonthData();
                      },
                      eventLoader: (day) {
                        final normalizedDay = DateTime(day.year, day.month, day.day);
                        return activitiesByDate[normalizedDay] ?? [];
                      },
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, events) {
                          if (events.isEmpty) return null;
                          
                          final normalizedDay = DateTime(day.year, day.month, day.day);
                          final dayActivities = activitiesByDate[normalizedDay] ?? [];
                          
                          if (dayActivities.isEmpty) return null;
                          
                          // Đếm số hoạt động hoàn thành
                          final completedCount = dayActivities.where((activity) {
                            if (activity['type'] == 'checkin') {
                              return (activity['data'] as CheckInModel).status == 'completed';
                            } else {
                              return (activity['data'] as AppointmentModel).status == 'completed';
                            }
                          }).length;
                          
                          final totalCount = dayActivities.length;
                          final isFullyCompleted = completedCount == totalCount;
                          
                          return Positioned(
                            bottom: 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: isFullyCompleted ? AppColors.success : AppColors.accentOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Chi tiết ngày được chọn
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDay != null
                              ? DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(_selectedDay!)
                              : 'Chọn một ngày',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (selectedActivities.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 48,
                                    color: AppColors.textLight,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Không có hoạt động',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...selectedActivities.map((activity) {
                            if (activity['type'] == 'checkin') {
                              final checkIn = activity['data'] as CheckInModel;
                              final medication = medProvider.medications
                                  .where((m) => m.id == checkIn.medicationId)
                                  .firstOrNull;
                              
                              if (medication == null) return const SizedBox.shrink();

                              return _buildCheckInItem(
                                medication.name,
                                checkIn.status,
                                checkIn.timestamp ?? DateTime.now(),
                                medicationType: medication.type,
                              );
                            } else {
                              final appointment = activity['data'] as AppointmentModel;
                              return _buildAppointmentItem(appointment);
                            }
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildMonthSelector() {
    final monthLabel = DateFormat('MMMM yyyy', 'vi_VN').format(_selectedMonth);
    final isCurrentMonth = _selectedMonth.year == DateTime.now().year && 
                           _selectedMonth.month == DateTime.now().month;
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            monthLabel,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: isCurrentMonth ? AppColors.textLight : AppColors.textPrimary,
            ),
            onPressed: isCurrentMonth ? null : () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSummary(String monthLabel, double rate, int totalCheckIns) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            monthLabel,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${rate.toStringAsFixed(0)}%',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 48,
                    ),
                  ),
                  Text(
                    'Tỷ lệ tuân thủ',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textWhite.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.textWhite.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '$totalCheckIns',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Lần',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInItem(String name, String status, DateTime timestamp, {String? medicationType}) {
    final timeStr = DateFormat('HH:mm').format(timestamp);
    final isCompleted = status == 'completed';
    
    // Xác định icon và màu dựa trên loại medication
    IconData icon = Icons.medication;
    Color iconBgColor = const Color(0xFF7E57C2); // Tím cho thuốc
    
    if (medicationType == 'Bữa ăn') {
      icon = Icons.restaurant;
      iconBgColor = const Color(0xFF66BB6A); // Xanh lá cho bữa ăn
    } else if (medicationType == 'Hoạt động') {
      icon = Icons.directions_walk;
      iconBgColor = const Color(0xFF42A5F5); // Xanh dương cho hoạt động
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.textWhite,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      isCompleted ? 'Đã hoàn thành' : 'Bỏ lỡ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isCompleted ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Đã uống lúc $timeStr',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.textWhite,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(AppointmentModel appointment) {
    final timeStr = DateFormat('HH:mm').format(appointment.date);
    final isCompleted = appointment.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.accentOrange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: AppColors.textWhite,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      isCompleted ? 'Đã hoàn thành' : 'Lịch khám',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isCompleted ? AppColors.success : AppColors.accentOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isCompleted ? 'Đã khám lúc $timeStr' : 'Lịch khám lúc $timeStr',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.textWhite,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/appointment_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/health_metric_provider.dart';
import '../../../providers/medication_provider.dart';
import '../../../repositories/user_repository.dart';
import '../../../models/user_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'appointment_schedule_screen.dart';
import 'daily_schedule_screen.dart';
import 'history_schedule_screen.dart';

/// Schedule screen - Medication and appointment schedule
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  // Helper: format thời gian tương đối
  String _formatRelativeTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Vừa cập nhật';
    if (diff.inMinutes < 60) return 'Cập nhật ${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return 'Cập nhật ${diff.inHours} giờ trước';
    return 'Cập nhật ${diff.inDays} ngày trước';
  }

  @override
  Widget build(BuildContext context) {
    final medProvider = context.watch<MedicationProvider>();
    final apptProvider = context.watch<AppointmentProvider>();
    final metricProvider = context.watch<HealthMetricProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: medProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    _buildStatusCard(context),
                    const SizedBox(height: 24),
                    _buildUpcomingAppointments(apptProvider),
                    const SizedBox(height: 24),
                    _buildTodayMedication(medProvider),
                    const SizedBox(height: 24),
                    _buildHealthMetrics(metricProvider),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'An Tâm',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: AppColors.textPrimary,
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                color: AppColors.textPrimary,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final parentId = context.read<AuthProvider>().parentId ?? '';
    if (parentId.isEmpty) {
      return const SizedBox.shrink();
    }
    final userRepo = context.read<UserRepository>();
    return StreamBuilder<UserModel>(
      stream: userRepo.streamParentStatus(parentId),
      builder: (context, snapshot) {
        final name = snapshot.data?.name ?? '...';
        final status = snapshot.data?.status ?? '';
        final lastUpdated = snapshot.data?.lastUpdated;
        final subtitle = status.isNotEmpty
            ? '$status${lastUpdated != null ? ' · ${_formatRelativeTime(lastUpdated)}' : ''}'
            : _formatRelativeTime(lastUpdated);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home, color: AppColors.textWhite, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpcomingAppointments(AppointmentProvider apptProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Các lịch khám sắp tới',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (apptProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (apptProvider.errorMessage != null)
            Text(
              'Không thể tải lịch khám',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            )
          else if (apptProvider.appointments.isEmpty)
            Text(
              'Chưa có lịch khám nào.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            )
          else
            ...apptProvider.appointments.map((appt) {
              final d = appt.date;
              final dateStr =
                  '${_weekdayName(d.weekday)}, ${d.day}/${d.month}';
              final daysLeft = d.difference(DateTime.now()).inDays;
              final tag = daysLeft == 0
                  ? 'Hôm nay'
                  : daysLeft == 1
                      ? 'Ngày mai'
                      : 'Còn $daysLeft ngày';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AppointmentCard(
                  date: dateStr,
                  title: appt.title,
                  doctor: appt.doctorName,
                  tag: tag,
                ),
              );
            }),
        ],
      ),
    );
  }

  String _weekdayName(int weekday) {
    const names = ['', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
    return names[weekday];
  }

  Widget _buildTodayMedication(MedicationProvider medProvider) {
    final meds = medProvider.medications;
    final checkIns = medProvider.todayCheckIns;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thứ tự thuốc hôm nay',
              style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (meds.isEmpty)
            Text('Chưa có lịch thuốc nào.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary))
          else
            ...meds.map((med) {
              final taken = checkIns.any(
                  (c) => c.medicationId == med.id && c.status == 'completed');
              // Label cho dosage tuỳ theo loại
              final String dosageLabel;
              switch (med.type) {
                case 'Bữa ăn':
                  dosageLabel = 'Bữa ăn';
                  break;
                case 'Hoạt động':
                  dosageLabel = 'Hoạt động thể chất';
                  break;
                default:
                  dosageLabel = '${med.dosage} viên';
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MedicationCard(
                  time: med.time,
                  name: med.name,
                  dosage: dosageLabel,
                  type: med.type,
                  status: taken ? 'taken' : 'pending',
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildHealthMetrics(HealthMetricProvider metricProvider) {
    final m = metricProvider.latestMetric;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chỉ số sức khỏe hôm nay',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (metricProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.favorite_border,
                    iconColor: AppColors.error,
                    value: m?.bloodPressure.isNotEmpty == true ? m!.bloodPressure : '--',
                    unit: 'mmHg',
                    label: 'Huyết áp',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.favorite_border,
                    iconColor: const Color(0xFFFFD54F),
                    value: m != null && m.heartRate > 0 ? '${m.heartRate}' : '--',
                    unit: 'bpm',
                    label: 'Nhịp tim',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.water_drop_outlined,
                    iconColor: AppColors.textPrimary,
                    value: m != null && m.bloodSugar > 0 ? '${m.bloodSugar}' : '--',
                    unit: 'mg/dL',
                    label: 'Đường huyết',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.monitor_weight_outlined,
                    iconColor: AppColors.textSecondary,
                    value: m != null && m.weight > 0 ? m.weight.toStringAsFixed(1) : '--',
                    unit: 'kg',
                    label: 'Cân nặng',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quản lý lịch',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.access_time,
                  label: 'Lịch trình',
                  iconColor: AppColors.info,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DailyScheduleScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'Lịch khám',
                  iconColor: AppColors.primaryGreen,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppointmentScheduleScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.history,
                  label: 'Lịch sử',
                  iconColor: AppColors.info,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScheduleScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Appointment card widget
class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.date,
    required this.title,
    required this.doctor,
    required this.tag,
  });

  final String date;
  final String title;
  final String doctor;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.indicatorInactive),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  doctor,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tag,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.info,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Medication card widget – hỗ trợ 3 loại: Thuốc / Bữa ăn / Hoạt động
class _MedicationCard extends StatelessWidget {
  const _MedicationCard({
    required this.time,
    required this.name,
    required this.dosage,
    required this.status,
    this.type = 'Thuốc',
  });

  final String time;
  final String name;
  final String dosage;
  final String status;
  final String type;

  IconData get _icon {
    switch (type) {
      case 'Bữa ăn':    return Icons.restaurant_outlined;
      case 'Hoạt động': return Icons.directions_walk_outlined;
      default:           return Icons.medication_outlined;
    }
  }

  Color get _iconColor {
    switch (type) {
      case 'Bữa ăn':    return const Color(0xFF66BB6A);
      case 'Hoạt động': return const Color(0xFF42A5F5);
      default:           return const Color(0xFF7E57C2);
    }
  }

  String get _takenLabel {
    switch (type) {
      case 'Bữa ăn':    return 'Đã ăn';
      case 'Hoạt động': return 'Đã làm';
      default:           return 'Đã uống';
    }
  }

  String get _pendingLabel {
    switch (type) {
      case 'Bữa ăn':    return 'Chưa ăn';
      case 'Hoạt động': return 'Chưa làm';
      default:           return 'Chưa uống';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.indicatorInactive),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: _iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  dosage,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: status == 'taken'
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status == 'taken' ? _takenLabel : _pendingLabel,
              style: AppTextStyles.bodySmall.copyWith(
                color: status == 'taken' ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Metric card widget
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.unit,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.indicatorInactive),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Icon(icon, color: iconColor, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Text(
                    unit,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// Quick action button widget
class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.indicatorInactive),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

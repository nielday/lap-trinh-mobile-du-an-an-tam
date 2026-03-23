import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/medication_provider.dart';
import '../../../providers/reminder_provider.dart';
import '../../../providers/alert_provider.dart';
import '../../../providers/appointment_provider.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../schedule/presentation/schedule_screen.dart';
import '../../settings/presentation/settings_screen.dart';

/// Child home screen - Main dashboard after login
/// Uses a persistent bottom navbar with IndexedStack so tabs maintain their state.
/// All data is loaded from Firebase via existing Providers.
class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  int _currentIndex = 0;

  // Screens are kept alive thanks to IndexedStack
  final List<Widget> _screens = const [
    _DashboardTab(),
    ScheduleScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dashboard Tab (index 0) – full scrollable content
// ---------------------------------------------------------------------------

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildActionButtons(context),
                    const SizedBox(height: 20),
                    _buildStatusSection(context),
                    const SizedBox(height: 24),
                    _buildUpcomingAppointmentsSection(context),
                    const SizedBox(height: 24),
                    _buildRemindersSection(context),
                    const SizedBox(height: 24),
                    _buildAlertsSection(context),
                    const SizedBox(height: 24),
                    _buildRecentActivitiesSection(context),
                    const SizedBox(height: 24),
                    _buildWeeklyComplianceSection(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;
    final alerts = context.watch<AlertProvider>();
    final displayName = user?.name ?? auth.user?.displayName ?? 'Người dùng';

    // Greeting by time of day
    final hour = DateTime.now().hour;
    final String greeting;
    if (hour < 12) {
      greeting = 'Chào buổi sáng';
    } else if (hour < 18) {
      greeting = 'Chào buổi chiều';
    } else {
      greeting = 'Chào buổi tối';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGreen, width: 2),
              color: AppColors.primaryGreen.withValues(alpha: 0.15),
            ),
            child: auth.user?.photoURL != null
                ? ClipOval(
                    child: Image.network(
                      auth.user!.photoURL!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  )
                : const Icon(Icons.person, color: AppColors.primaryGreen),
          ),

          const SizedBox(width: 12),

          // Greeting text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  displayName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Notification bell with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications,
                  color: AppColors.textWhite,
                  size: 20,
                ),
              ),
              if (alerts.unreadCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${alerts.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Action buttons ───────────────────────────────────────────────────────

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.phone,
            label: 'Gọi điện',
            backgroundColor: AppColors.secondaryNavy,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.message,
            label: 'Nhắn tin',
            backgroundColor: AppColors.secondaryNavy,
            onTap: () {
              final auth = context.read<AuthProvider>();
              final parentId = auth.effectiveParentId;
              if (parentId == null || parentId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chưa liên kết với gia đình'),
                  ),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    otherUserId: parentId,
                    otherUserName: 'Gia đình',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Status section – lịch thuốc hôm nay từ Firebase ──────────────────────

  Widget _buildStatusSection(BuildContext context) {
    final medProvider = context.watch<MedicationProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trạng thái hôm nay',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (medProvider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (medProvider.medications.isEmpty)
          _EmptyState(
            icon: Icons.medication_outlined,
            message: 'Chưa có lịch thuốc nào hôm nay',
          )
        else
          ...medProvider.medications.take(3).map((med) {
            final checkIn = medProvider.todayCheckIns.where((c) => c.medicationId == med.id).firstOrNull;
            final isCompleted = checkIn?.status == 'completed';
            final timeLabel = isCompleted && checkIn?.timestamp != null
                ? 'Đã uống lúc ${DateFormat('HH:mm').format(checkIn!.timestamp!)}'
                : 'Chưa uống - ${med.time}';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StatusCard(
                icon: _iconForType(med.type ?? 'Thuốc'),
                iconColor: isCompleted ? AppColors.success : _colorForType(med.type ?? 'Thuốc'),
                title: med.name,
                subtitle: isCompleted ? 'Đã hoàn thành' : 'Chưa thực hiện',
                time: timeLabel,
                status: isCompleted ? 'completed' : 'pending',
              ),
            );
          }),
      ],
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'Bữa ăn':
        return Icons.restaurant;
      case 'Hoạt động':
        return Icons.directions_walk;
      default:
        return Icons.medication;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'Bữa ăn':
        return const Color(0xFF66BB6A);
      case 'Hoạt động':
        return const Color(0xFF42A5F5);
      default:
        return const Color(0xFF7E57C2);
    }
  }

  // ── Reminders section – từ Firebase ──────────────────────────────────────

  Widget _buildRemindersSection(BuildContext context) {
    final reminderProvider = context.watch<ReminderProvider>();
    final auth = context.watch<AuthProvider>();
    final uid = auth.user?.uid;

    // Chỉ hiển thị reminders gửi đến user hiện tại (không phải do họ tạo)
    final incoming = reminderProvider.reminders
        .where((r) => r.toUserId == uid)
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lời nhắn từ gia đình',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (reminderProvider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (incoming.isEmpty)
          _EmptyState(
            icon: Icons.chat_bubble_outline,
            message: 'Chưa có lời nhắn nào',
          )
        else
          ...incoming.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ReminderCard(
                  icon: Icons.message,
                  iconColor: AppColors.info,
                  title: 'Lời nhắn',
                  subtitle: r.content,
                  time: r.timestamp != null
                      ? DateFormat('HH:mm - dd/MM').format(r.timestamp!)
                      : '',
                ),
              )),
      ],
    );
  }

  // ── Alerts section – từ Firebase ──────────────────────────────────────────

  Widget _buildAlertsSection(BuildContext context) {
    final alertProvider = context.watch<AlertProvider>();
    final auth = context.watch<AuthProvider>();
    final uid = auth.user?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cảnh báo & Thông báo',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (alertProvider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (alertProvider.unreadAlerts.isEmpty)
          _EmptyState(
            icon: Icons.check_circle_outline,
            message: 'Không có cảnh báo mới',
          )
        else
          ...alertProvider.unreadAlerts.take(3).map(
                (alert) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AlertCard(
                    icon: _iconForAlertType(alert.type),
                    iconColor: _colorForAlertType(alert.type),
                    title: alert.title,
                    subtitle: alert.message,
                    time: alert.timestamp != null
                        ? DateFormat('HH:mm - dd/MM/yyyy').format(alert.timestamp!)
                        : '',
                    onDismiss: uid != null
                        ? () => context.read<AlertProvider>().markAsRead(alert.id, uid)
                        : null,
                  ),
                ),
              ),
      ],
    );
  }

  IconData _iconForAlertType(String type) {
    switch (type) {
      case 'sos':
        return Icons.sos;
      case 'missed_medication':
        return Icons.medication_liquid;
      default:
        return Icons.warning;
    }
  }

  Color _colorForAlertType(String type) {
    switch (type) {
      case 'sos':
        return AppColors.error;
      case 'missed_medication':
        return AppColors.accentOrange;
      default:
        return AppColors.info;
    }
  }

  // ── Upcoming Appointments section – từ Firebase ───────────────────────────

  Widget _buildUpcomingAppointmentsSection(BuildContext context) {
    final apptProvider = context.watch<AppointmentProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Các lịch khám sắp tới',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (apptProvider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (apptProvider.appointments.isEmpty)
          _EmptyState(
            icon: Icons.calendar_month_outlined,
            message: 'Chưa có lịch khám nào sắp tới',
          )
        else
          ...apptProvider.appointments.take(3).map((appt) {
            final d = appt.date;
            final dateStr = '${_weekdayName(d.weekday)}, ${d.day}/${d.month}';
            final daysLeft = d.difference(DateTime.now()).inDays;
            final tag = daysLeft == 0
                ? 'Hôm nay'
                : daysLeft == 1
                    ? 'Ngày mai'
                    : 'Còn $daysLeft ngày';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AppointmentCard(
                dateStr: dateStr,
                title: appt.title,
                doctor: appt.doctorName,
                tag: tag,
                isCompleted: appt.status == 'completed',
              ),
            );
          }),
      ],
    );
  }

  String _weekdayName(int weekday) {
    const names = ['', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
    return names[weekday];
  }

  // ── Recent activities section ─────────────────────────────────────────────

  Widget _buildRecentActivitiesSection(BuildContext context) {
    final medProvider = context.watch<MedicationProvider>();
    final completedToday = medProvider.todayCheckIns
        .where((c) => c.status == 'completed')
        .length;

    if (medProvider.todayCheckIns.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check, color: AppColors.textWhite, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hoạt động hôm nay',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Đã hoàn thành $completedToday / ${medProvider.todayCheckIns.length} nhiệm vụ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Weekly compliance section – từ Firebase ───────────────────────────────

  Widget _buildWeeklyComplianceSection(BuildContext context) {
    final medProvider = context.watch<MedicationProvider>();
    final rate = medProvider.complianceRate;
    final weekly = medProvider.weeklyCompliance;

    final now = DateTime.now();
    final monthLabel = DateFormat('MM/yyyy').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lịch sử tuân thủ',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Xem tất cả',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tháng $monthLabel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${rate.toStringAsFixed(0)}%',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tỷ lệ tuân thủ',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
        ),
        const SizedBox(height: 12),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: rate / 100,
            backgroundColor: AppColors.indicatorInactive,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tuần này',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        if (weekly.isEmpty)
          _EmptyState(
            icon: Icons.bar_chart,
            message: 'Chưa có dữ liệu tuần này',
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekly.map((item) {
              final status = item['status'] as String;
              final label = item['day'] as String;
              final Color color;
              switch (status) {
                case 'completed':
                  color = AppColors.success;
                  break;
                case 'missed':
                  color = AppColors.error;
                  break;
                case 'pending':
                  color = AppColors.accentOrange;
                  break;
                default:
                  color = AppColors.secondaryNavy;
              }
              return _DayStatusIcon(label: label, status: status, color: color);
            }).toList(),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom Nav Bar – Persistent
// ---------------------------------------------------------------------------

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavBarItem(
                icon: Icons.home_outlined,
                label: 'Dashboard',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavBarItem(
                icon: Icons.calendar_today_outlined,
                label: 'Schedule',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavBarItem(
                icon: Icons.settings_outlined,
                label: 'Setting',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable Widgets
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(icon, color: AppColors.textLight, size: 36),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textWhite, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.status,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final String status;

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
              color: iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.textWhite, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          if (status == 'completed')
            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;

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
              color: iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.textWhite, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    this.onDismiss,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.textWhite, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: AppColors.textLight),
              onPressed: onDismiss,
              tooltip: 'Đánh dấu đã đọc',
            ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.dateStr,
    required this.title,
    required this.doctor,
    required this.tag,
    this.isCompleted = false,
  });

  final String dateStr;
  final String title;
  final String doctor;
  final String tag;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.indicatorInactive.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.calendar_today_outlined,
            color: isCompleted ? AppColors.success : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
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
                if (doctor.isNotEmpty)
                  Text(
                    doctor,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Đã khám',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
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

class _DayStatusIcon extends StatelessWidget {
  const _DayStatusIcon({
    required this.label,
    required this.status,
    required this.color,
  });

  final String label;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final IconData iconData;
    switch (status) {
      case 'completed':
        iconData = Icons.check;
        break;
      case 'missed':
        iconData = Icons.close;
        break;
      case 'pending':
        iconData = Icons.access_time;
        break;
      case 'upcoming':
        iconData = Icons.remove_circle_outline;
        break;
      default:
        iconData = Icons.help_outline;
    }

    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            iconData,
            color: AppColors.textWhite,
            size: status == 'upcoming' ? 24 : 22,
          ),
        ),
      ],
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.info : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isActive ? AppColors.info : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

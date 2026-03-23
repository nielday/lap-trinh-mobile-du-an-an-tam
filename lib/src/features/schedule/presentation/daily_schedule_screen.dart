import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'add_schedule_screen.dart';

/// Daily schedule detailed screen
class DailyScheduleScreen extends StatelessWidget {
  const DailyScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Current status card
                    _buildStatusCard(),
                    const SizedBox(height: 24),
                    // Date Filters
                    _buildDateFilters(),
                    const SizedBox(height: 24),
                    // Medications
                    _buildMedicationSection(),
                    const SizedBox(height: 24),
                    // Meals and Water
                    _buildMealAndWaterSection(),
                    const SizedBox(height: 24),
                    // Light Activities
                    _buildActivitySection(),
                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 20, top: 12, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                color: AppColors.textPrimary,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
              Text(
                'Lịch trình',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF7E57C2), width: 1.5),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF7E57C2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.home_outlined,
              color: AppColors.info,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hôm nay của mẹ',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '3 lịch thuốc - 2 bữa ăn - 1 hoạt động',
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
  }

  Widget _buildDateFilters() {
    return Row(
      children: [
        _DateFilterButton(
          text: 'Hôm nay',
          isActive: true,
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _DateFilterButton(
          text: 'Ngày mai',
          isActive: false,
          onTap: () {},
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DateFilterButton(
            text: 'Chọn ngày',
            icon: Icons.calendar_today_outlined,
            isActive: false,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thuốc hôm nay',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        const _ScheduleCard(
          icon: Icons.medication_outlined,
          time: '8:00',
          title: 'Thuốc huyết áp',
          subtitle: '1 viên',
          statusText: 'ĐÃ UỐNG',
          statusColor: AppColors.success,
          isActive: true, // Show blue border focus
        ),
        const SizedBox(height: 12),
        const _ScheduleCard(
          icon: Icons.medication_outlined,
          time: '19:00',
          title: 'Thuốc tiểu đường',
          subtitle: '2 viên',
          statusText: 'CHƯA UỐNG',
          statusColor: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildMealAndWaterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bữa ăn và nước',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        const _ScheduleCard(
          icon: Icons.restaurant_outlined,
          time: '7:00',
          title: 'Ăn sáng',
          subtitle: 'Ít muối, nhiều rau',
          statusText: 'ĐÃ ĂN',
          statusColor: AppColors.success,
        ),
        const SizedBox(height: 12),
        const _ScheduleCard(
          icon: Icons.local_drink_outlined,
          time: '10:00',
          title: 'Uống nước',
          subtitle: '1 cốc',
          statusText: 'ĐÃ ĐẾN GIỜ',
          statusColor: Color(0xFFFBC02D),
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoạt động nhẹ',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        const _ScheduleCard(
          icon: Icons.directions_walk,
          time: '17:30',
          title: 'Đi bộ',
          subtitle: '10 phút quanh nhà',
          statusText: 'CHƯA LÀM',
          statusColor: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.indicatorInactive.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddScheduleScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF7E57C2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Thêm lịch',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF7E57C2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.text,
    this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String text;
  final IconData? icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.info : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? AppColors.info : AppColors.indicatorInactive,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isActive ? AppColors.textWhite : AppColors.textPrimary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isActive ? AppColors.textWhite : AppColors.textPrimary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.icon,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.statusText,
    required this.statusColor,
    this.isActive = false,
  });

  final IconData icon;
  final String time;
  final String title;
  final String subtitle;
  final String statusText;
  final Color statusColor;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? AppColors.info.withValues(alpha: 0.05) : AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.info : AppColors.indicatorInactive.withValues(alpha: 0.5),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.textPrimary,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
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
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: AppTextStyles.bodySmall.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

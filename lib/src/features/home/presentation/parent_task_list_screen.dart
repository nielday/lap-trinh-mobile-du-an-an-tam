import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Parent task list screen - Shows all tasks for elderly users
class ParentTaskListScreen extends StatelessWidget {
  const ParentTaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Danh sách việc cần làm',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _TaskItem(
            icon: Icons.medication,
            iconColor: AppColors.success,
            title: 'Thuốc Huyết áp',
            subtitle: 'Đã hoàn thành',
            isCompleted: true,
          ),
          const SizedBox(height: 12),
          _TaskItem(
            icon: Icons.visibility,
            iconColor: AppColors.accentOrange,
            title: 'Đi khám mắt',
            subtitle: '14:00 - Hôm nay',
            isCompleted: false,
          ),
          const SizedBox(height: 12),
          _TaskItem(
            icon: Icons.fitness_center,
            iconColor: AppColors.secondaryNavy,
            title: 'Tập thể dục',
            subtitle: '07:00 - Ngày mai',
            isCompleted: false,
          ),
          const SizedBox(height: 12),
          _TaskItem(
            icon: Icons.calendar_today,
            iconColor: AppColors.secondaryNavy,
            title: 'Đi chợ tại 120 Yên Lãng',
            subtitle: '14:00 - Ngày mai',
            isCompleted: false,
          ),
          const SizedBox(height: 12),
          _TaskItem(
            icon: Icons.calendar_today,
            iconColor: AppColors.secondaryNavy,
            title: 'Đi xem vua nhà Lý',
            subtitle: '18:00 - Ngày mai',
            isCompleted: false,
          ),
          const SizedBox(height: 12),
          _TaskItem(
            icon: Icons.calendar_today,
            iconColor: AppColors.secondaryNavy,
            title: 'Nghe Quang nhịn thân',
            subtitle: '21:00 - Ngày mai',
            isCompleted: false,
          ),
          const SizedBox(height: 24),
          // Add more button
          Material(
            color: AppColors.secondaryNavy,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                // TODO: Add new task
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Xem thêm',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Task item widget
class _TaskItem extends StatelessWidget {
  const _TaskItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (isCompleted)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.textWhite,
                size: 24,
              ),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.textWhite, size: 24),
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
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isCompleted
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontSize: 13,
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

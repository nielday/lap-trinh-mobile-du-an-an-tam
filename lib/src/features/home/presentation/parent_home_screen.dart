import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'parent_medication_reminder_screen.dart';
import 'parent_task_list_screen.dart';

/// Parent home screen - Ultra simple interface for elderly users
/// Based on design mockup with weather, health stats, tasks, and family photos
class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weather and date header
              _buildWeatherHeader(),
              
              const SizedBox(height: 20),
              
              // Health stats cards
              _buildHealthStats(),
              
              const SizedBox(height: 20),
              
              // Action buttons (Call and Message)
              _buildActionButtons(context),
              
              const SizedBox(height: 20),
              
              // Completed button
              _buildCompletedButton(context),
              
              const SizedBox(height: 24),
              
              // Tasks section
              _buildTasksSection(context),
              
              const SizedBox(height: 24),
              
              // Family album section
              _buildFamilyAlbumSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Weather info
          Row(
            children: [
              const Icon(
                Icons.wb_sunny,
                color: AppColors.accentOrange,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                '24°C',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          // Date
          Text(
            'Thứ Sáu, 13/6',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStats() {
    return Row(
      children: [
        Expanded(
          child: _HealthStatCard(
            icon: Icons.favorite,
            iconColor: AppColors.error,
            value: '72 bpm',
            label: 'Nhịp tim',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _HealthStatCard(
            icon: Icons.show_chart,
            iconColor: AppColors.accentOrange,
            value: '120/80',
            label: 'Huyết áp',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _HealthStatCard(
            icon: Icons.close,
            iconColor: AppColors.textSecondary,
            value: 'N/A',
            label: 'Đường',
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.phone,
                label: 'Gọi điện',
                backgroundColor: AppColors.secondaryNavy,
                onTap: () {
                  _showCallDialog(context);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.message,
                label: 'Nhắn tin',
                backgroundColor: AppColors.secondaryNavy,
                onTap: () {
                  // TODO: Implement message functionality
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // SOS Button
        Material(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              _showSOSConfirmation(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emergency, color: AppColors.textWhite, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'KHẨN CẤP - SOS',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Gọi điện cho ai?',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CallContactButton(
              name: 'Con',
              icon: Icons.person,
              onTap: () {
                Navigator.pop(context);
                // TODO: Make call to child
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang gọi cho Con...')),
                );
              },
            ),
            const SizedBox(height: 12),
            _CallContactButton(
              name: 'Bác sĩ',
              icon: Icons.medical_services,
              onTap: () {
                Navigator.pop(context);
                // TODO: Make call to doctor
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang gọi cho Bác sĩ...')),
                );
              },
            ),
            const SizedBox(height: 12),
            _CallContactButton(
              name: 'Người thân khác',
              icon: Icons.people,
              onTap: () {
                Navigator.pop(context);
                // TODO: Show contact list
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSOSConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emergency,
                color: AppColors.textWhite,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'KHẨN CẤP!',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Gọi ngay cho Con và\ngửi thông báo khẩn cấp?',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'HỦY',
                          style: AppTextStyles.buttonLarge.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Material(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Make emergency call and send notification
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đang gọi khẩn cấp và gửi thông báo...'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'GỌI NGAY',
                          style: AppTextStyles.buttonLarge.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedButton(BuildContext context) {
    return Material(
      color: AppColors.primaryGreen,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          _showCheckInConfirmation(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Đã hoàn thành',
            style: AppTextStyles.buttonMedium.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Việc cần làm sắp tới',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ParentTaskListScreen(),
                  ),
                );
              },
              child: Text(
                'Xem tất cả',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _TaskItem(
          icon: Icons.medication,
          iconColor: AppColors.success,
          title: 'Thuốc Huyết áp',
          subtitle: 'Đã hoàn thành',
          isCompleted: true,
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _TaskItem(
          icon: Icons.visibility,
          iconColor: AppColors.accentOrange,
          title: 'Đi khám mắt',
          subtitle: '14:00 - Hôm nay',
          isCompleted: false,
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _TaskItem(
          icon: Icons.fitness_center,
          iconColor: AppColors.secondaryNavy,
          title: 'Tập thể dục',
          subtitle: '07:00 - Ngày mai',
          isCompleted: false,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildFamilyAlbumSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'album ảnh gia đình',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full album
              },
              child: Text(
                'Xem tất cả',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FamilyPhotoCard(
                imageUrl: 'https://via.placeholder.com/150',
                caption: 'Ảnh ông bà',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FamilyPhotoCard(
                imageUrl: 'https://via.placeholder.com/150',
                caption: 'Ảnh gia đình sum họp',
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCheckInConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.textWhite,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ĐÃ GHI NHẬN!',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Công việc đã được hoàn thành',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Material(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'ĐÓNG',
                    style: AppTextStyles.buttonLarge.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Call contact button widget
class _CallContactButton extends StatelessWidget {
  const _CallContactButton({
    required this.name,
    required this.icon,
    required this.onTap,
  });

  final String name;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryGreen,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textWhite, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
              const Icon(
                Icons.phone,
                color: AppColors.textWhite,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Health stat card widget
class _HealthStatCard extends StatelessWidget {
  const _HealthStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button widget
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
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: AppColors.textWhite, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
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
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (isCompleted)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.textWhite,
                    size: 16,
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
        ),
      ),
    );
  }
}

/// Family photo card widget
class _FamilyPhotoCard extends StatelessWidget {
  const _FamilyPhotoCard({
    required this.imageUrl,
    required this.caption,
  });

  final String imageUrl;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          caption,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

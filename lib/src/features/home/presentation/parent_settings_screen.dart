import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Parent settings screen - Configuration and preferences
class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

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
          'Cài đặt',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryGreen, width: 3),
                    image: const DecorationImage(
                      image: NetworkImage('https://via.placeholder.com/70'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uiia',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chỉnh sửa hồ sơ',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Settings options
          _SettingItem(
            icon: Icons.person,
            title: 'Tài khoản và bảo mật',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: Icons.people,
            title: 'Liên kết gia đình',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: Icons.delete,
            title: 'Dữ liệu nhắn nhở',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: Icons.security,
            title: 'Bảo kê & khôi phục',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: Icons.notifications,
            title: 'Thông báo và cảnh báo',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: Icons.phone,
            title: 'Cuộc gọi & SOS',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: Icons.calendar_today,
            title: 'Nhật ký nhắn sắc',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: Icons.accessibility,
            title: 'Giao diện & ngôn ngữ',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: Icons.info,
            title: 'Thông tin về ứng dụng',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: Icons.help,
            title: 'Liên hệ hỗ trợ',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: Icons.lock,
            title: 'Chính sách bảo mật',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// Setting item widget
class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
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
              Icon(
                icon,
                color: AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

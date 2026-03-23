import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Parent account settings screen
class ParentAccountSettingsScreen extends StatelessWidget {
  const ParentAccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tài khoản và bảo mật',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SettingItem(
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
            subtitle: 'Tên, ngày sinh, giới tính',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: Icons.phone_outlined,
            title: 'Số điện thoại',
            subtitle: '+84 xxx xxx xxx',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'example@email.com',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            subtitle: 'Cập nhật mật khẩu của bạn',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: Icons.fingerprint,
            title: 'Sinh trắc học',
            subtitle: 'Vân tay, Face ID',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: Icons.security,
            title: 'Xác thực 2 bước',
            subtitle: 'Tăng cường bảo mật tài khoản',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
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

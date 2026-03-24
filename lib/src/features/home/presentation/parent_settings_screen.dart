import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../settings/presentation/parent_account_settings_screen.dart';
import '../../settings/presentation/parent_family_link_screen.dart';
import '../../auth/presentation/role_selection_screen.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

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
                    color: AppColors.backgroundWhite,
                  ),
                  child: const Icon(Icons.person, color: AppColors.textSecondary, size: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phụ huynh',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chế độ theo dõi sức khỏe',
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
            icon: Icons.people,
            title: 'Liên kết gia đình',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ParentFamilyLinkScreen(),
                ),
              );
            },
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
          const SizedBox(height: 24),
          _SettingItem(
            icon: Icons.logout,
            title: 'Đăng xuất',
            textColor: AppColors.error,
            iconColor: AppColors.error,
            onTap: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoleSelectionScreen(),
                  ),
                  (route) => false,
                );
              }
            },
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
    this.textColor,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

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
                color: iconColor ?? AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: textColor ?? AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(
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

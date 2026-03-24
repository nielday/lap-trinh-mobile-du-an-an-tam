import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../auth/presentation/role_selection_screen.dart';
import '../../../repositories/user_repository.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Cài đặt',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGreen.withValues(alpha: 0.2),
                      border: Border.all(
                        color: AppColors.primaryGreen,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    authProvider.userModel?.name ?? 
                    authProvider.user?.displayName ?? 
                    'Người dùng',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Edit profile text
                  Text(
                    'Chỉnh sửa hồ sơ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Settings list
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _SettingItem(
                    icon: Icons.shield_outlined,
                    title: 'Tài khoản và bảo mật',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _SettingItem(
                    icon: Icons.phone_android,
                    title: 'Cập nhật số điện thoại',
                    onTap: () {
                      _showUpdatePhoneDialog(context, authProvider);
                    },
                  ),
                  _buildDivider(),
                  _SettingItem(
                    icon: Icons.medical_services_outlined,
                    title: 'Dữ liệu chăm sóc',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _SettingItem(
                    icon: Icons.backup_outlined,
                    title: 'Sao lưu & khôi phục',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _SettingItem(
                    icon: Icons.notifications_outlined,
                    title: 'Thông báo và cảnh báo',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _SettingItem(
                    icon: Icons.phone_outlined,
                    title: 'Cuộc gọi & SOS',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _SettingItem(
                    icon: Icons.history,
                    title: 'Nhật ký chăm sóc',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _SettingItem(
                    icon: Icons.language_outlined,
                    title: 'Giao diện & ngôn ngữ',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _SettingItem(
                    icon: Icons.info_outline,
                    title: 'Thông tin về an tâm',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _SettingItem(
                    icon: Icons.help_outline,
                    title: 'Liên hệ hỗ trợ',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _SettingItem(
                    icon: Icons.lock_outline,
                    title: 'Chính sách bảo mật',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Đăng xuất'),
                        content: const Text('Bạn có chắc muốn đăng xuất?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Đăng xuất'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      await authProvider.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RoleSelectionScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Đăng xuất',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showUpdatePhoneDialog(BuildContext context, AuthProvider authProvider) {
    final TextEditingController phoneController = TextEditingController(text: authProvider.userModel?.phone ?? '');
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.backgroundWhite,
              title: Text(
                'Cập nhật Số điện thoại',
                style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nhập số điện thoại của bạn để thiết bị Bố/Mẹ có thể tìm và liên kết:',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      hintText: '09xxxxxxxxx',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                  onPressed: isLoading
                      ? null
                      : () async {
                          final phone = phoneController.text.trim();
                          if (phone.isEmpty) return;

                          setState(() => isLoading = true);
                          try {
                            final userRepo = UserRepository();
                            await userRepo.updatePhone(authProvider.user!.uid, phone);
                            await authProvider.reloadUserModel();

                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('Cập nhật số điện thoại thành công!')),
                              );
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text('Lỗi: $e')),
                              );
                            }
                          } finally {
                            if (ctx.mounted) setState(() => isLoading = false);
                          }
                        },
                  child: const Text('Lưu lại', style: TextStyle(color: AppColors.textWhite)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.backgroundLight,
      indent: 60,
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textLight,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

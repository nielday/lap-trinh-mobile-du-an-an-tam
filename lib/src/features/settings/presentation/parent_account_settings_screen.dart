import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../repositories/user_repository.dart';
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
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.userModel;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SettingItem(
                icon: Icons.person_outline,
                title: 'Thông tin cá nhân',
                subtitle: user?.name ?? 'Tên người dùng',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _SettingItem(
                icon: Icons.phone_outlined,
                title: 'Số điện thoại',
                subtitle: (user?.phone != null && user!.phone!.isNotEmpty) 
                    ? user.phone! 
                    : 'Chưa cập nhật (Bấm để thêm)',
                onTap: () => _updatePhone(context, auth),
              ),
              const SizedBox(height: 12),
              _SettingItem(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: user?.email ?? 'example@email.com',
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
      );
    },
      ),
    );
  }

  void _updatePhone(BuildContext context, AuthProvider auth) {
    if (auth.user == null) return;
    
    final controller = TextEditingController(text: auth.userModel?.phone ?? '');
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Cập nhật số điện thoại'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Nhập số điện thoại (VD: 0912345678)',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (isLoading) const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  final phone = controller.text.trim();
                  if (phone.isEmpty) return;
                  
                  setState(() => isLoading = true);
                  try {
                    await UserRepository().updatePhone(auth.user!.uid, phone);
                    await auth.reloadUserModel(); // Reload local state
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
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
                child: const Text('Lưu'),
              ),
            ],
          );
        },
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

import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../repositories/user_repository.dart';
import '../../../models/user_model.dart';

/// Parent family link screen
class ParentFamilyLinkScreen extends StatelessWidget {
  const ParentFamilyLinkScreen({super.key});

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
          'Liên kết gia đình',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryGreen, size: 28),
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              _showLinkToChildDialog(context, authProvider);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Thêm người thân để họ có thể theo dõi sức khỏe và nhắc nhở bạn',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Danh sách người thân',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Family members
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              if (authProvider.user == null) return const SizedBox.shrink();
              if (authProvider.effectiveParentId == authProvider.user?.uid || authProvider.effectiveParentId == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      'Chưa có người thân (Con cái) nào được liên kết',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }

              return StreamBuilder<UserModel>(
                stream: UserRepository().streamUser(authProvider.effectiveParentId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(child: Text('Không thể tải thông tin Người thân: ${snapshot.error}'));
                  }

                  final child = snapshot.data!;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _FamilyMemberCard(
                          name: child.name,
                          relationship: 'Người chăm sóc (Con cái)',
                          phone: child.phone ?? child.email, // Hiển thị số điện thoại hoặc email
                          isPrimary: true,
                          onTap: () {},
                        ),
                      ),
                    ]
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FamilyMemberCard extends StatelessWidget {
  const _FamilyMemberCard({
    required this.name,
    required this.relationship,
    required this.phone,
    required this.isPrimary,
    required this.onTap,
  });

  final String name;
  final String relationship;
  final String phone;
  final bool isPrimary;
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isPrimary 
                      ? AppColors.primaryGreen 
                      : AppColors.secondaryNavy,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.textWhite,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (isPrimary) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Chính',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textWhite,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      relationship,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.phone, color: AppColors.primaryGreen),
                onPressed: () {
                  // TODO: Make call
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showLinkToChildDialog(BuildContext context, AuthProvider authProvider) {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.backgroundWhite,
            title: Text(
              'Thêm Người thân',
              style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nhập số điện thoại tài khoản của Con (Người thân) để liên kết thiết bị:',
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
                          final childUser = await userRepo.getUserByPhone(phone, role: 'child');

                          if (childUser == null || childUser.role != 'child') {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('Không tìm thấy tài khoản Con/Người thân nào đăng ký với Số điện thoại này')),
                              );
                            }
                          } else {
                            // Update the PARENT'S parentId to be the CHILD'S UID! (Con là trung tâm dữ liệu)
                            await userRepo.updateParentId(authProvider.user!.uid, childUser.id);
                            
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('Liên kết thành công! Thiết bị của bạn giờ đã nhận được dữ liệu từ Con.')),
                              );
                            }
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
                child: const Text('Liên kết ngay', style: TextStyle(color: AppColors.textWhite)),
              ),
            ],
          );
        },
      );
    },
  );
}

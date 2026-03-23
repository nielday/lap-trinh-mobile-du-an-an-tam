import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

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
              // TODO: Add family member
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
          _FamilyMemberCard(
            name: 'Con',
            relationship: 'Con trai/gái',
            phone: '+84 xxx xxx xxx',
            isPrimary: true,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _FamilyMemberCard(
            name: 'Bác sĩ gia đình',
            relationship: 'Bác sĩ',
            phone: '+84 xxx xxx xxx',
            isPrimary: false,
            onTap: () {},
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

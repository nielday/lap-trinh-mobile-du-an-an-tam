import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Parent calling screen - Shows active call in progress
class ParentCallingScreen extends StatelessWidget {
  const ParentCallingScreen({
    super.key,
    required this.callerName,
    this.callerAvatar,
  });

  final String callerName;
  final String? callerAvatar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),
              
              // Avatar
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGreen, width: 4),
                  image: DecorationImage(
                    image: NetworkImage(
                      callerAvatar ?? 'https://via.placeholder.com/140',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Caller name
              Text(
                callerName,
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 36,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Call status
              Text(
                'Đang gọi...',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 20,
                ),
              ),
              
              const Spacer(),
              
              // End call button
              Material(
                color: AppColors.error,
                shape: const CircleBorder(),
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 80,
                    height: 80,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.call_end,
                      color: AppColors.textWhite,
                      size: 40,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Kết thúc',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Additional actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SmallActionButton(
                    icon: Icons.mic_off,
                    label: 'Tắt tiếng',
                    onTap: () {},
                  ),
                  _SmallActionButton(
                    icon: Icons.volume_up,
                    label: 'Loa ngoài',
                    onTap: () {},
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small action button (Mute/Speaker)
class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: AppColors.backgroundWhite,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: AppColors.textSecondary,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

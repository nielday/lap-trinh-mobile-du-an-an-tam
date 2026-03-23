import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Parent incoming call screen - Shows incoming call from child
class ParentIncomingCallScreen extends StatelessWidget {
  const ParentIncomingCallScreen({
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
              
              // Call duration or status
              Text(
                '3:22',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 24,
                ),
              ),
              
              const Spacer(),
              
              // Call action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decline button
                  _CallActionButton(
                    icon: Icons.call_end,
                    backgroundColor: AppColors.error,
                    label: 'Từ chối',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  
                  // Accept button
                  _CallActionButton(
                    icon: Icons.call,
                    backgroundColor: AppColors.success,
                    label: 'Trả lời',
                    onTap: () {
                      // TODO: Accept call
                      Navigator.pop(context);
                    },
                  ),
                ],
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

/// Call action button (Accept/Decline)
class _CallActionButton extends StatelessWidget {
  const _CallActionButton({
    required this.icon,
    required this.backgroundColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color backgroundColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: backgroundColor,
          shape: const CircleBorder(),
          elevation: 4,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: AppColors.textWhite,
                size: 40,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
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

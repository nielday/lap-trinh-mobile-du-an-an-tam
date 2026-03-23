import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Parent SOS screen - Emergency call screen
/// Full-screen red alert for emergency situations
class ParentSOSScreen extends StatelessWidget {
  const ParentSOSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.error,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // Emergency call label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.phone_forwarded,
                      color: AppColors.textWhite,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Emergency call',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textWhite,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Avatar
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.textWhite, width: 4),
                  image: const DecorationImage(
                    image: NetworkImage('https://via.placeholder.com/140'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // SOS Text
              Text(
                'SOS',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.textWhite,
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Emergency Services text
              Text(
                'Emergency Services',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textWhite,
                  fontSize: 20,
                ),
              ),
              
              const Spacer(),
              
              // Call button
              Material(
                color: AppColors.textWhite,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    // TODO: Make emergency call
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.phone,
                          color: AppColors.error,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Nhấn cuộc gọi',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.mic_off,
                    onTap: () {},
                  ),
                  _ActionButton(
                    icon: Icons.volume_up,
                    onTap: () {},
                  ),
                  _ActionButton(
                    icon: Icons.dialpad,
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

/// Action button widget for SOS screen
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: AppColors.textWhite,
            size: 28,
          ),
        ),
      ),
    );
  }
}

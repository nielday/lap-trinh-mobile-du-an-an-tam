import 'package:flutter/material.dart';
import '../../../common_widgets/mascot_avatar.dart';
import '../../../common_widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'child_auth_screen.dart';

/// Role selection screen - first screen when opening the app
/// Users select whether they are "Người thân" (Caregiver) or "Cha/mẹ" (Elder)
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _onCaregiverPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const ChildAuthScreen(),
      ),
    );
  }

  void _onElderPressed(BuildContext context) {
    // TODO: Navigate to Elder auth screen
    debugPrint('Navigate to Elder Auth Screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              // Top spacer
              const Spacer(flex: 2),

              // Mascot avatar
              const MascotAvatar(size: 100),

              const SizedBox(height: 32),

              // Welcome title
              Text(
                'CHÀO MỪNG ĐẾN AN TÂM',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Caregiver button (Người thân)
              PrimaryButton(
                text: 'Tôi là người thân',
                onPressed: () => _onCaregiverPressed(context),
                backgroundColor: AppColors.primaryGreen,
              ),

              const SizedBox(height: 16),

              // Elder button (Cha/mẹ)
              PrimaryButton(
                text: 'Tôi là cha/mẹ',
                onPressed: () => _onElderPressed(context),
                backgroundColor: AppColors.secondaryNavy,
              ),

              const SizedBox(height: 24),

              // Hint text
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.accentOrange,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'Gợi ý: Con cái nên cài đặt trước, sau đó thiết lập cho cha mẹ.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.accentOrange,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Bottom spacer
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

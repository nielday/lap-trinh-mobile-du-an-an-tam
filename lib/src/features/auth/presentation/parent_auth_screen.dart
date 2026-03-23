import 'package:flutter/material.dart';
import '../../../common_widgets/mascot_avatar.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../home/presentation/parent_home_screen.dart';
import '../../home/presentation/parent_medication_reminder_screen.dart';

/// Parent auth screen - Simple authentication for elderly users
/// Ultra simple interface with minimal steps
class ParentAuthScreen extends StatelessWidget {
  const ParentAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              
              const Spacer(),
              
              // Mascot avatar
              const MascotAvatar(size: 120),
              
              const SizedBox(height: 40),
              
              // Welcome message
              Text(
                'CHÀO BỐ/MẸ!',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 40,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Con đã thiết lập sẵn mọi thứ\nBố/Mẹ chỉ cần bấm nút bên dưới',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 20,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 60),
              
              // Start button
              Material(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(24),
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ParentHomeScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.touch_app,
                          color: AppColors.textWhite,
                          size: 56,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'BẤM ĐỂ BẮT ĐẦU',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w700,
                            fontSize: 28,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Demo button for testing medication reminder
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ParentMedicationReminderScreen(
                        medicationName: 'Thuốc Huyết Áp',
                        dosage: '1 viên',
                        scheduledTime: '8:00 sáng',
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  side: const BorderSide(color: AppColors.accentOrange, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.alarm, color: AppColors.accentOrange),
                    const SizedBox(width: 8),
                    Text(
                      'XEM NHẮC UỐNG THUỐC (Demo)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

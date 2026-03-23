import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Parent medication reminder screen
/// Shows when it's time to take medicine with audio alert
/// Follows FR2.3 requirements from specification
class ParentMedicationReminderScreen extends StatelessWidget {
  const ParentMedicationReminderScreen({
    super.key,
    required this.medicationName,
    required this.dosage,
    required this.scheduledTime,
  });

  final String medicationName;
  final String dosage;
  final String scheduledTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentOrange,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textWhite,
                    size: 36,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bell icon with animation
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.textWhite,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        color: AppColors.accentOrange,
                        size: 72,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Title
                    Text(
                      'ĐẾN GIỜ UỐNG THUỐC!',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w700,
                        fontSize: 36,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Medication info card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.textWhite,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          // Medication icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.medication,
                              color: AppColors.textWhite,
                              size: 48,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Medication name
                          Text(
                            medicationName,
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 32,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Dosage
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              dosage,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Scheduled time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: AppColors.textSecondary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                scheduledTime,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Check-in button
                    _buildCheckInButton(context),
                    
                    const SizedBox(height: 16),
                    
                    // Snooze button
                    _buildSnoozeButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInButton(BuildContext context) {
    return Material(
      color: AppColors.success,
      borderRadius: BorderRadius.circular(24),
      elevation: 8,
      child: InkWell(
        onTap: () {
          _showCheckInConfirmation(context);
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.textWhite,
                size: 40,
              ),
              const SizedBox(width: 16),
              Text(
                'ĐÃ UỐNG THUỐC',
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
    );
  }

  Widget _buildSnoozeButton(BuildContext context) {
    return Material(
      color: AppColors.textWhite,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          // TODO: Implement snooze functionality
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.snooze,
                color: AppColors.textSecondary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'NHỚ TÔI SAU 10 PHÚT',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCheckInConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.all(40),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.textWhite,
                size: 60,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Success message
            Text(
              'TUYỆT VỜI!',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 36,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Con đã biết bố/mẹ\nđã uống thuốc',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontSize: 22,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Close button
            Material(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close reminder screen
                  // TODO: Send check-in notification to child
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'ĐÓNG',
                    style: AppTextStyles.buttonLarge.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

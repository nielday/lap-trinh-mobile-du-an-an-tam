import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Parent home screen - Ultra simple interface for elderly users
/// Features 3 large buttons: SOS, Check-in, Call Child
/// Follows FR2 requirements from specification
class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header with greeting
              _buildHeader(),
              
              const SizedBox(height: 40),
              
              // Main buttons
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SOS Button (FR2.2)
                    _buildSOSButton(context),
                    
                    const SizedBox(height: 24),
                    
                    // Check-in Button (FR2.3)
                    _buildCheckInButton(context),
                    
                    const SizedBox(height: 24),
                    
                    // Call Child Button (FR2.4)
                    _buildCallChildButton(context),
                  ],
                ),
              ),
              
              // Time display
              _buildTimeDisplay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryGreen, width: 3),
          ),
          child: const Icon(
            Icons.person,
            color: AppColors.primaryGreen,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 20,
                ),
              ),
              Text(
                'Bố/Mẹ',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSOSButton(BuildContext context) {
    return _LargeButton(
      icon: Icons.emergency,
      label: 'KHẨN CẤP',
      subtitle: 'Bấm khi cần trợ giúp ngay',
      backgroundColor: AppColors.error,
      onTap: () {
        _showSOSConfirmation(context);
      },
    );
  }

  Widget _buildCheckInButton(BuildContext context) {
    return _LargeButton(
      icon: Icons.check_circle,
      label: 'ĐÃ UỐNG THUỐC',
      subtitle: 'Bấm sau khi uống thuốc',
      backgroundColor: AppColors.success,
      onTap: () {
        _showCheckInConfirmation(context);
      },
    );
  }

  Widget _buildCallChildButton(BuildContext context) {
    return _LargeButton(
      icon: Icons.phone,
      label: 'GỌI CON',
      subtitle: 'Nhờ con gọi lại khi rảnh',
      backgroundColor: AppColors.info,
      onTap: () {
        _showCallRequestConfirmation(context);
      },
    );
  }

  Widget _buildTimeDisplay() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.indicatorInactive),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.access_time,
            color: AppColors.primaryGreen,
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(
            '$hour:$minute',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 36,
            ),
          ),
        ],
      ),
    );
  }

  void _showSOSConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emergency,
                color: AppColors.textWhite,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'GỌI KHẨN CẤP?',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 28,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Sẽ gọi điện cho con ngay lập tức',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: 'HỦY',
                    backgroundColor: AppColors.textLight,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DialogButton(
                    label: 'GỌI NGAY',
                    backgroundColor: AppColors.error,
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement SOS call
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckInConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.textWhite,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ĐÃ GHI NHẬN!',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 28,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Con sẽ biết bố/mẹ đã uống thuốc',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _DialogButton(
              label: 'ĐÓNG',
              backgroundColor: AppColors.success,
              onTap: () {
                Navigator.pop(context);
                // TODO: Send check-in notification
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCallRequestConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.info,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone,
                color: AppColors.textWhite,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ĐÃ GỬI YÊU CẦU!',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 28,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Con sẽ gọi lại khi rảnh',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _DialogButton(
              label: 'ĐÓNG',
              backgroundColor: AppColors.info,
              onTap: () {
                Navigator.pop(context);
                // TODO: Send call request notification
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Large button widget for parent interface
/// Extra large size for elderly users with accessibility needs
class _LargeButton extends StatelessWidget {
  const _LargeButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: AppColors.textWhite,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textWhite.withValues(alpha: 0.9),
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog button widget
class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            label,
            style: AppTextStyles.buttonLarge.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

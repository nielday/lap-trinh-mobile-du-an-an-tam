import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../common_widgets/mascot_avatar.dart';
import '../../../common_widgets/page_indicator.dart';
import '../../../common_widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'terms_screen.dart';

/// Auth welcome screen for Child (Con) role
/// This is the second screen after selecting "Con cái" role
class ChildAuthScreen extends StatefulWidget {
  const ChildAuthScreen({super.key});

  @override
  State<ChildAuthScreen> createState() => _ChildAuthScreenState();
}

class _ChildAuthScreenState extends State<ChildAuthScreen> {
  final int _currentPage = 0;
  late final TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _onTermsPressed;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const RegisterScreen(),
      ),
    );
  }

  void _onLoginPressed() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const LoginScreen(),
      ),
    );
  }

  void _onTermsPressed() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const TermsScreen(),
      ),
    );
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
              const MascotAvatar(size: 140),

              const SizedBox(height: 40),

              // App name
              const Text(
                'AN TÂM',
                style: AppTextStyles.heading1,
              ),

              const SizedBox(height: 12),

              // Tagline
              Text(
                'Bảo vệ sức khỏe, an tâm mỗi ngày',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Page indicator
              PageIndicator(
                count: 3,
                currentIndex: _currentPage,
              ),

              // Bottom spacer
              const Spacer(flex: 3),

              // Register button
              PrimaryButton(
                text: 'Đăng ký',
                onPressed: _onRegisterPressed,
                backgroundColor: AppColors.primaryGreen,
              ),

              const SizedBox(height: 12),

              // Login button
              PrimaryButton(
                text: 'Đăng nhập',
                onPressed: _onLoginPressed,
                backgroundColor: AppColors.secondaryNavy,
              ),

              const SizedBox(height: 20),

              // Terms text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.bodySmall,
                  children: [
                    const TextSpan(
                      text: 'Tiếp tục đồng nghĩa bạn đồng ý với\n',
                    ),
                    TextSpan(
                      text: 'Điều khoản',
                      style: AppTextStyles.link,
                      recognizer: _termsRecognizer,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

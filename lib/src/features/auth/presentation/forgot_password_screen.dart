import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/mascot_avatar.dart';
import '../../../common_widgets/primary_button.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'privacy_policy_screen.dart';

/// Forgot password screen
/// "Quên mật khẩu" - Reset password flow
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSendResetEmailPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendPasswordResetEmail(
      _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email đặt lại mật khẩu đã được gửi. Vui lòng kiểm tra hộp thư của bạn.'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 4),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Gửi email thất bại'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _onBackPressed() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Mascot avatar
                const MascotAvatar(size: 100),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Quên mật khẩu',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Nhập email của bạn để nhận link đặt lại mật khẩu',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Nhập email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.textLight,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // Send button
                PrimaryButton(
                  text: 'Gửi email đặt lại mật khẩu',
                  onPressed: authProvider.isLoading ? null : _onSendResetEmailPressed,
                  backgroundColor: AppColors.primaryGreen,
                  isLoading: authProvider.isLoading,
                  showArrow: false,
                ),

                const SizedBox(height: 16),

                // Back button
                PrimaryButton(
                  text: 'Quay lại',
                  onPressed: _onBackPressed,
                  backgroundColor: AppColors.secondaryNavy,
                  showArrow: false,
                ),

                const SizedBox(height: 24),

                // Privacy policy text
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Chính sách quyền riêng tư',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

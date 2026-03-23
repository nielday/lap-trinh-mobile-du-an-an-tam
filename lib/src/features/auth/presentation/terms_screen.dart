import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Điều khoản sử dụng',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ĐIỀU KHOẢN SỬ DỤNG ỨNG DỤNG AN TÂM',
              style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Cập nhật lần cuối: 23/11/2025\n\n'
              'Chào mừng bạn đến với ứng dụng An Tâm - Giải pháp hỗ trợ chăm sóc sức khỏe '
              'và theo dõi lịch trình cho người cao tuổi và gia đình.\n\n'
              'Vui lòng đọc kỹ các Điều khoản Sử dụng này trước khi sử dụng ứng dụng. '
              'Bằng việc truy cập hoặc sử dụng ứng dụng, bạn đồng ý tuân thủ các điều khoản và điều kiện được nêu tại đây.\n\n'
              '1. BẢO MẬT THÔNG TIN\n'
              'Chúng tôi cam kết bảo mật tuyệt đối các thông tin y tế, lịch khám, và thông tin cá nhân của người dùng. '
              'Dữ liệu của bạn được mã hóa an toàn và không chia sẻ cho bất kỳ bên thứ ba nào khi chưa có sự đồng ý của bạn.\n\n'
              '2. QUYỀN LỢI & TRÁCH NHIỆM\n'
              'Người dùng (bao gồm con cái và người lớn tuổi) có quyền tận dụng mọi chức năng như nhắc nhở lịch uống thuốc, theo dõi chỉ số sức khỏe, và định vị khẩn cấp. '
              'Tuy nhiên, An Tâm chỉ đóng vai trò công cụ hỗ trợ và không thay thế cho các chẩn đoán hoặc quyết định y tế chuyên nghiệp.\n\n'
              '3. THÔNG BÁO VÀ CHIA SẺ\n'
              'Hệ thống sẽ đồng bộ thông báo giữa tài khoản người quản lý (con cái) và người được quản lý (cha mẹ). Bạn toàn quyền tùy chỉnh các cảnh báo này trong mục Cài đặt.\n\n'
              '4. SỬA ĐỔI ĐIỀU KHOẢN\n'
              'Chúng tôi có thể cập nhật Điều khoản Sử dụng này tùy theo sự phát triển của ứng dụng. '
              'Người dùng sẽ nhận được thông báo rõ ràng trước khi các thay đổi có hiệu lực.\n\n'
              'Nếu bạn có bất kỳ câu hỏi nào về Điều khoản này, vui lòng liên hệ với bộ phận hỗ trợ qua ứng dụng.',
              style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Tôi đã hiểu và Đồng ý',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textWhite),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

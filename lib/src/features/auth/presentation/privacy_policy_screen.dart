import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Chính sách quyền riêng tư',
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
              'CHÍNH SÁCH BẢO MẬT & QUYỀN RIÊNG TƯ AN TÂM',
              style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Cập nhật lần cuối: 23/11/2026\n\n'
              'Tại An Tâm, sự riêng tư và bảo mật thông tin cá nhân của bạn, đặc biệt là các dữ liệu sức khỏe nhạy cảm, là ưu tiên hàng đầu của chúng tôi.\n\n'
              '1. THU THẬP THÔNG TIN\n'
              'Chúng tôi thu thập các thông tin cần thiết để cung cấp dịch vụ tốt nhất, bao gồm: tên, số điện thoại, email, lịch sử khám chữa bệnh, lịch trình dùng thuốc và dữ liệu vị trí (dành cho tính năng khẩn cấp SOS và tìm kiếm).\n\n'
              '2. SỬ DỤNG THÔNG TIN\n'
              'Dữ liệu của bạn được sử dụng riêng biệt cho mục đích:\n'
              '- Nhắc nhở và quản lý lịch trình chăm sóc sức khỏe.\n'
              '- Gửi cảnh báo đến tài khoản người thân (người giám hộ) khi có bất thường.\n'
              '- Nâng cấp và cá nhân hóa trải nghiệm người dùng trên ứng dụng.\n\n'
              '3. BẢO VỆ DỮ LIỆU\n'
              'Mọi thông tin tải lên ứng dụng đều được áp dụng công nghệ mã hóa chuẩn quốc tế, đảm bảo an toàn tuyệt đối trước các truy cập trái phép. Chúng tôi KHÔNG bán hay chia sẻ thông tin cá nhân của bạn cho bên thứ ba vì mục đích quảng cáo.\n\n'
              '4. QUYỀN CỦA NGƯỜI DÙNG\n'
              'Bạn có toàn quyền kiểm soát dữ liệu của mình: quyền yêu cầu truy cập, sửa đổi, hoặc xóa bỏ vĩnh viễn dữ liệu tài khoản bất kỳ lúc nào thông qua phần Cài đặt ứng dụng.\n\n'
              'Bằng cách tiếp tục sử dụng An Tâm, bạn đồng ý với việc thu thập và sử dụng thông tin thiết yếu như đã nêu trên.',
              style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryNavy, // Matching the 'Quay lại' tone
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Quay lại',
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

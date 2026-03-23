import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'add_appointment_screen.dart';

class AppointmentScheduleScreen extends StatelessWidget {
  const AppointmentScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    _buildTopCard(),
                    const SizedBox(height: 24),
                    Text(
                      'Sắp tới',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAppointmentList(),
                    const SizedBox(height: 100), // FAB space
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 20, top: 12, bottom: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Lịch khám và di chuyển',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                fontSize: 20,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF7E57C2), width: 1.5),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF7E57C2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF4DD0E1), // Cyan/Teal color
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lịch khám tuần này',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '2 lịch khám - 1 di chuyển',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList() {
    return Column(
      children: [
        _AppointmentItemCard(
          dateText: 'Thứ 6, 15/11',
          title: 'Tái khám tim mạch',
          personName: 'Bác sĩ Nguyễn Văn Minh',
          location: 'Bệnh viện Đa khoa Hà Đông, 01 Quang Trung',
          tagText: 'Chưa xác nhận',
          tagColor: const Color(0xFFFFD54F), // Amber
        ),
        const SizedBox(height: 16),
        _AppointmentItemCard(
          dateText: 'Chủ nhật, 17/11',
          title: 'Đi chợ với bạn',
          personName: 'Bà Lan - Hàng xóm',
          location: 'Chợ Hà Đông, đường Lê Trọng Tấn',
          tagText: 'Đã nhắc',
          tagColor: const Color(0xFF81C784), // Light green
        ),
        const SizedBox(height: 16),
        _AppointmentItemCard(
          dateText: 'Thứ 3, 19/11',
          title: 'Khám tổng quát',
          personName: 'Bác sĩ Lê Thị Bích',
          location: 'Phòng khám Đa khoa Quang Trung, Hà Đông',
          tagText: 'Nhắc trước 2 ngày',
          tagColor: const Color(0xFFE57373), // Red/Salmon
        ),
        const SizedBox(height: 16),
        _AppointmentItemCard(
          dateText: 'Thứ 5, 21/11',
          title: 'Đo huyết áp định kỳ',
          personName: 'Trạm y tế phường Văn Quán',
          location: 'Trạm Y tế Văn Quán, Hà Đông',
          tagText: 'Sắp tới',
          tagColor: const Color(0xFF81C784), // Light green
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.indicatorInactive.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddAppointmentScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF7E57C2), // Purple tone
                ),
                const SizedBox(width: 8),
                Text(
                  'Thêm lịch',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF7E57C2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppointmentItemCard extends StatelessWidget {
  const _AppointmentItemCard({
    required this.dateText,
    required this.title,
    required this.personName,
    required this.location,
    required this.tagText,
    required this.tagColor,
  });

  final String dateText;
  final String title;
  final String personName;
  final String location;
  final String tagText;
  final Color tagColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateText,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  personName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: tagColor.withValues(alpha: 0.2), // Lighten background opacity
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tagText,
              style: AppTextStyles.bodySmall.copyWith(
                color: tagColor, // Full opacity text
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

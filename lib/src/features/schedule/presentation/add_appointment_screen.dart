import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  String _selectedType = 'Khám bệnh'; // Khám bệnh, Đi chợ, Đi chơi
  DateTime? _selectedDateTime;
  String _selectedReminder = '1 ngày'; // 1 ngày, 2 ngày, 1 tuần

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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelectorBox(),
                    const SizedBox(height: 16),
                    _buildTextField(hintText: 'Tên lịch'),
                    const SizedBox(height: 16),
                    _buildDateTimeSelector(context),
                    const SizedBox(height: 16),
                    _buildTextField(hintText: 'Bác sĩ / Người đi cùng'),
                    const SizedBox(height: 16),
                    _buildTextField(hintText: 'Địa điểm'),
                    const SizedBox(height: 16),
                    _buildTextField(hintText: 'Địa chỉ chi tiết'),
                    const SizedBox(height: 24),
                    
                    _buildSectionHeader('Nhắc trước'),
                    const SizedBox(height: 12),
                    _buildReminderSelector(),
                    const SizedBox(height: 24),
                    
                    _buildSectionHeader('Ghi chú'),
                    const SizedBox(height: 12),
                    _buildTextField(hintText: 'Ghi chú thêm ....', maxLines: 4),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
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
          Text(
            'Thêm lịch khám',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }

  Widget _buildTypeSelectorBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loại lịch',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildTypeOption(
                  label: 'Khám bệnh',
                  icon: Icons.add_circle,
                  iconColor: const Color(0xFF4DD0E1), // Cyan cross
                  isSelected: _selectedType == 'Khám bệnh',
                ),
              ),
              Expanded(
                child: _buildTypeOption(
                  label: 'Đi chợ',
                  icon: Icons.shopping_cart_outlined,
                  iconColor: Colors.blueGrey,
                  isSelected: _selectedType == 'Đi chợ',
                ),
              ),
              Expanded(
                child: _buildTypeOption(
                  label: 'Đi chơi',
                  icon: Icons.directions_walk_outlined,
                  iconColor: Colors.blueGrey,
                  isSelected: _selectedType == 'Đi chơi',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required String label,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedType = label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F7FA).withValues(alpha: 0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 6),
            Flexible( // Flexible wraps the text to prevent overflow
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String hintText, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? date = await showDatePicker(
          context: context,
          initialDate: _selectedDateTime ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7E57C2)),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          if (!context.mounted) return;
          final TimeOfDay? time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time != null) {
            setState(() {
              _selectedDateTime = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
            });
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDateTime != null
                  ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
                  : 'Chọn ngày giờ',
              style: AppTextStyles.bodyMedium.copyWith(
                color: _selectedDateTime != null ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            const Icon(Icons.calendar_today_outlined, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSelector() {
    return Row(
      children: [
        _ReminderPill(
          label: '1 ngày',
          isSelected: _selectedReminder == '1 ngày',
          onTap: () => setState(() => _selectedReminder = '1 ngày'),
        ),
        const SizedBox(width: 12),
        _ReminderPill(
          label: '2 ngày',
          isSelected: _selectedReminder == '2 ngày',
          onTap: () => setState(() => _selectedReminder = '2 ngày'),
        ),
        const SizedBox(width: 12),
        _ReminderPill(
          label: '1 tuần',
          isSelected: _selectedReminder == '1 tuần',
          onTap: () => setState(() => _selectedReminder = '1 tuần'),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8ABDB5), // Teal/green matching the image
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            'Lưu lịch',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReminderPill extends StatelessWidget {
  const _ReminderPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8ABDB5).withValues(alpha: 0.6) : AppColors.backgroundWhite.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.indicatorInactive.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

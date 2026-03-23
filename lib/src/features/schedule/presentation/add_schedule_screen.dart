import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  String _selectedType = 'Thuốc'; // Thuốc, Bữa ăn, Hoạt động
  DateTime? _selectedDateTime;

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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Loại lịch'),
                    const SizedBox(height: 12),
                    _buildTypeSelector(),
                    const SizedBox(height: 24),
                    
                    _buildSectionHeader('Tiêu đề'),
                    const SizedBox(height: 12),
                    _buildTextField(hintText: 'Nhập tiêu đề'),
                    const SizedBox(height: 24),
                    
                    _buildSectionHeader('Chọn ngày giờ'),
                    const SizedBox(height: 12),
                    _buildDateTimeSelector(context),
                    const SizedBox(height: 24),
                    
                    _buildSectionHeader('Ghi chú'),
                    const SizedBox(height: 12),
                    _buildTextField(hintText: 'Ghi chú thêm ....', maxLines: 5),
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
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Text(
            'Thêm lịch',
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
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        _TypePill(
          label: 'Thuốc',
          isSelected: _selectedType == 'Thuốc',
          onTap: () => setState(() => _selectedType = 'Thuốc'),
        ),
        const SizedBox(width: 12),
        _TypePill(
          label: 'Bữa ăn',
          isSelected: _selectedType == 'Bữa ăn',
          onTap: () => setState(() => _selectedType = 'Bữa ăn'),
        ),
        const SizedBox(width: 12),
        _TypePill(
          label: 'Hoạt động',
          isSelected: _selectedType == 'Hoạt động',
          onTap: () => setState(() => _selectedType = 'Hoạt động'),
        ),
      ],
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
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF7E57C2),
                ),
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
                  : 'Chọn ngày giờ ....',
              style: AppTextStyles.bodyMedium.copyWith(
                color: _selectedDateTime != null ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            const Icon(Icons.calendar_today_outlined, color: AppColors.textPrimary),
          ],
        ),
      ),
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
            backgroundColor: const Color(0xFF8ABDB5), // Teal/green color derived from image
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

class _TypePill extends StatelessWidget {
  const _TypePill({
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF7E57C2) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

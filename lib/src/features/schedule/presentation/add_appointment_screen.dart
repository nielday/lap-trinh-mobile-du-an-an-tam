import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/appointment_model.dart';
import '../../../providers/appointment_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../repositories/appointment_repository.dart';

class AddAppointmentScreen extends StatefulWidget {
  /// Nếu truyền [existing] thì là edit mode
  final AppointmentModel? existing;
  const AddAppointmentScreen({super.key, this.existing});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _doctorController;
  late final TextEditingController _locationController;
  final _noteController = TextEditingController();

  late String _selectedType;
  DateTime? _selectedDateTime;
  String _selectedReminder = '1 ngày';
  bool _isSaving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(text: e?.title ?? '');
    _doctorController = TextEditingController(text: e?.doctorName ?? '');
    _locationController = TextEditingController(text: e?.location ?? '');
    _selectedType = e?.type.isNotEmpty == true ? e!.type : 'Khám bệnh';
    _selectedDateTime = e?.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _doctorController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên lịch')),
      );
      return;
    }
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày giờ')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final uid = authProvider.user?.uid ?? '';
    final parentId = authProvider.effectiveParentId ?? uid;

    if (uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập lại')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = AppointmentRepository();

      if (_isEdit) {
        await repo.updateAppointment(widget.existing!.id, {
          'title': title,
          'doctorName': _doctorController.text.trim(),
          'location': _locationController.text.trim(),
          'date': Timestamp.fromDate(_selectedDateTime!),
          'type': _selectedType,
        });
      } else {
        final appointment = AppointmentModel(
          id: '',
          parentId: parentId,
          title: title,
          doctorName: _doctorController.text.trim(),
          location: _locationController.text.trim(),
          date: _selectedDateTime!,
          type: _selectedType,
          status: 'upcoming',
        );
        await repo.createAppointment(appointment);
      }

      if (!mounted) return;
      context.read<AppointmentProvider>().updateUser(parentId: parentId);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lưu lịch: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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
                    _buildTextField(controller: _titleController, hintText: 'Tên lịch'),
                    const SizedBox(height: 16),
                    _buildDateTimeSelector(context),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _doctorController, hintText: 'Bác sĩ / Người đi cùng'),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _locationController, hintText: 'Địa điểm'),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Nhắc trước'),
                    const SizedBox(height: 12),
                    _buildReminderSelector(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Ghi chú'),
                    const SizedBox(height: 12),
                    _buildTextField(controller: _noteController, hintText: 'Ghi chú thêm ....', maxLines: 4),
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
            _isEdit ? 'Sửa lịch khám' : 'Thêm lịch khám',
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
          Text('Loại lịch',
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildTypeOption(label: 'Khám bệnh', icon: Icons.local_hospital_outlined, iconColor: const Color(0xFF4DD0E1), isSelected: _selectedType == 'Khám bệnh')),
              Expanded(child: _buildTypeOption(label: 'Đi chợ', icon: Icons.shopping_cart_outlined, iconColor: Colors.blueGrey, isSelected: _selectedType == 'Đi chợ')),
              Expanded(child: _buildTypeOption(label: 'Đi chơi', icon: Icons.directions_walk_outlined, iconColor: Colors.blueGrey, isSelected: _selectedType == 'Đi chơi')),
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
            Flexible(
              child: Text(label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime(2030),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7E57C2)),
            ),
            child: child!,
          ),
        );
        if (date != null) {
          if (!context.mounted) return;
          final TimeOfDay? time = await showTimePicker(
            context: context,
            initialTime: _selectedDateTime != null
                ? TimeOfDay(hour: _selectedDateTime!.hour, minute: _selectedDateTime!.minute)
                : TimeOfDay.now(),
          );
          if (time != null) {
            setState(() {
              _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
                  ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} '
                    '${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
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
        _ReminderPill(label: '1 ngày', isSelected: _selectedReminder == '1 ngày', onTap: () => setState(() => _selectedReminder = '1 ngày')),
        const SizedBox(width: 12),
        _ReminderPill(label: '2 ngày', isSelected: _selectedReminder == '2 ngày', onTap: () => setState(() => _selectedReminder = '2 ngày')),
        const SizedBox(width: 12),
        _ReminderPill(label: '1 tuần', isSelected: _selectedReminder == '1 tuần', onTap: () => setState(() => _selectedReminder = '1 tuần')),
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
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8ABDB5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  _isEdit ? 'Cập nhật' : 'Lưu lịch',
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
  const _ReminderPill({required this.label, required this.isSelected, required this.onTap});
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
          color: isSelected
              ? const Color(0xFF8ABDB5).withValues(alpha: 0.6)
              : AppColors.backgroundWhite.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.indicatorInactive.withValues(alpha: 0.3),
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

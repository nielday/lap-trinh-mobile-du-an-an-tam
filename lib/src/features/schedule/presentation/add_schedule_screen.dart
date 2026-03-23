import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/medication_model.dart';
import '../../../providers/medication_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../repositories/medication_repository.dart';

/// Icon theo loại lịch trình
IconData scheduleTypeIcon(String type) {
  switch (type) {
    case 'Bữa ăn': return Icons.restaurant_outlined;
    case 'Hoạt động': return Icons.directions_walk_outlined;
    default: return Icons.medication_outlined;
  }
}

Color scheduleTypeColor(String type) {
  switch (type) {
    case 'Bữa ăn': return const Color(0xFF66BB6A);
    case 'Hoạt động': return const Color(0xFF42A5F5);
    default: return const Color(0xFF7E57C2);
  }
}

class AddScheduleScreen extends StatefulWidget {
  /// Nếu truyền [existing] thì là edit mode
  final MedicationModel? existing;
  const AddScheduleScreen({super.key, this.existing});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _dosageController;
  final _noteController = TextEditingController();

  late String _selectedType;
  DateTime? _selectedDateTime;
  bool _isSaving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(text: e?.name ?? '');
    _dosageController = TextEditingController(text: e?.dosage.toString() ?? '1');
    // Khởi tạo type từ existing nếu có
    _selectedType = e?.type.isNotEmpty == true ? e!.type : 'Thuốc';
    if (e != null) {
      final parts = e.time.split(':');
      final hour = int.tryParse(parts[0]) ?? 8;
      final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      _selectedDateTime = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day,
        hour, minute,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dosageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề')),
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
      final timeStr =
          '${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}';
      final dosage = int.tryParse(_dosageController.text.trim()) ?? 1;
      final repo = MedicationRepository();

      if (_isEdit) {
        await repo.updateMedication(widget.existing!.id, {
          'name': title,
          'time': timeStr,
          'dosage': dosage,
          'type': _selectedType,
        });
      } else {
        final medication = MedicationModel(
          id: '',
          parentId: parentId,
          childId: uid,
          name: title,
          time: timeStr,
          frequency: 'daily',
          dosage: dosage,
          isActive: true,
          type: _selectedType,
        );
        await repo.createMedication(medication);
      }

      if (!mounted) return;
      context.read<MedicationProvider>().updateUser(parentId: parentId);
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
                    _buildTextField(controller: _titleController, hintText: 'Nhập tiêu đề'),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Chọn ngày giờ'),
                    const SizedBox(height: 12),
                    _buildDateTimeSelector(context),
                    if (_selectedType == 'Thuốc') ...[
                      const SizedBox(height: 24),
                      _buildSectionHeader('Số viên / liều'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _dosageController,
                        hintText: '1',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 24),
                    _buildSectionHeader('Ghi chú'),
                    const SizedBox(height: 12),
                    _buildTextField(
                        controller: _noteController,
                        hintText: 'Ghi chú thêm ....',
                        maxLines: 5),
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
            _isEdit ? 'Sửa lịch' : 'Thêm lịch',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
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

class _TypePill extends StatelessWidget {
  const _TypePill({required this.label, required this.isSelected, required this.onTap});
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

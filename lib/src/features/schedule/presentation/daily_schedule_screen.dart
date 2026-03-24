import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/medication_provider.dart';
import '../../../repositories/medication_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'add_schedule_screen.dart';

IconData _typeIcon(String type) {
  switch (type) {
    case 'Bữa ăn': return Icons.restaurant_outlined;
    case 'Hoạt động': return Icons.directions_walk_outlined;
    default: return Icons.medication_outlined;
  }
}

Color _typeColor(String type) {
  switch (type) {
    case 'Bữa ăn': return const Color(0xFF66BB6A);
    case 'Hoạt động': return const Color(0xFF42A5F5);
    default: return const Color(0xFF7E57C2);
  }
}

class DailyScheduleScreen extends StatelessWidget {
  const DailyScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medProvider = context.watch<MedicationProvider>();
    final meds = medProvider.medications;
    final checkIns = medProvider.todayCheckIns;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: medProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildStatusCard(meds.length),
                          const SizedBox(height: 24),
                          _buildSection(context, meds, checkIns),
                          const SizedBox(height: 100),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                color: AppColors.textPrimary,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
              Text(
                'Lịch trình',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF7E57C2), width: 1.5),
            ),
            child: const Icon(Icons.person_outline, color: Color(0xFF7E57C2)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.home_outlined, color: AppColors.info, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lịch hôm nay',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(count > 0 ? '\$count lịch' : 'Không có lịch',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, List meds, List checkIns) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lịch hôm nay',
            style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        if (meds.isEmpty)
          Text('Chưa có lịch nào.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary))
        else
          ...meds.map((med) {
            final taken = checkIns.any(
                (c) => c.medicationId == med.id && c.status == 'completed');
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
      child: _DismissibleItem(med: med, taken: taken),
            );
          }),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddScheduleScreen())),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_circle_outline, color: Color(0xFF7E57C2)),
                const SizedBox(width: 8),
                Text('Thêm lịch',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF7E57C2), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DismissibleItem extends StatelessWidget {
  const _DismissibleItem({required this.med, required this.taken});
  final dynamic med;
  final bool taken;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(med.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(color: AppColors.info, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.edit_outlined, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => AddScheduleScreen(existing: med)));
          return false;
        }
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Xóa lịch'),
            content: Text('Xóa "${med.name}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Xóa', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) async {
        try {
          await MedicationRepository().deleteMedication(med.id);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi xóa: $e')));
          }
        }
      },
      child: _Card(
        icon: _typeIcon(med.type ?? 'Thuốc'),
        iconColor: _typeColor(med.type ?? 'Thuốc'),
        time: med.time,
        title: med.name,
        subtitle: med.type == 'Thuốc'
            ? '${med.dosage} viên'
            : (med.type ?? 'Thuốc'),
        done: taken,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.icon, required this.iconColor, required this.time,
    required this.title, required this.subtitle, required this.done,
  });
  final IconData icon;
  final Color iconColor;
  final String time, title, subtitle;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.indicatorInactive.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (done ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              done ? 'XONG' : 'CHƯA',
              style: AppTextStyles.bodySmall.copyWith(
                  color: done ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w700, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
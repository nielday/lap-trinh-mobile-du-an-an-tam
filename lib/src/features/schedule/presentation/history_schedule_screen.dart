import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/medication_model.dart';
import '../../../providers/medication_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Màn hình lịch sử uống thuốc - dùng real data từ MedicationProvider
class HistoryScheduleScreen extends StatelessWidget {
  const HistoryScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medProvider = context.watch<MedicationProvider>();

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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Column(
                        children: [
                          _buildSummaryCard(medProvider.complianceRate),
                          const SizedBox(height: 24),
                          _buildHistoryList(medProvider),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
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
                'Lịch sử',
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

  Widget _buildSummaryCard(double rate) {
    final rateText = rate > 0 ? '${rate.toStringAsFixed(0)}%' : '--';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up, color: Color(0xFF00B21E), size: 36),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tuân thủ tháng này',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                rateText,
                style: AppTextStyles.heading1.copyWith(
                  color: const Color(0xFF00B21E),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(MedicationProvider medProvider) {
    // monthCheckIns chứa toàn bộ lịch sử trong tháng
    final checkIns = medProvider.monthCheckIns;
    final meds = medProvider.medications;

    if (checkIns.isEmpty) {
      return Text(
        'Chưa có lịch sử nào trong tháng này.',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      );
    }

    return Column(
      children: checkIns.map((checkIn) {
        MedicationModel? med;
        try { med = meds.firstWhere((m) => m.id == checkIn.medicationId); } catch (_) {}
        final medName = med?.name ?? 'Không rõ';
        final medType = med?.type ?? 'Thuốc';
        final taken = checkIn.status == 'completed';
        final timeStr = checkIn.timestamp != null
            ? '${checkIn.timestamp!.hour.toString().padLeft(2, '0')}:${checkIn.timestamp!.minute.toString().padLeft(2, '0')}'
            : '';

        // Label tuỳ theo loại
        final String doneLabel;
        final String notDoneLabel;
        switch (medType) {
          case 'Bữa ăn':
            doneLabel = 'Đã ăn';
            notDoneLabel = 'Chưa ăn';
            break;
          case 'Hoạt động':
            doneLabel = 'Đã làm';
            notDoneLabel = 'Chưa làm';
            break;
          default:
            doneLabel = 'Đã uống';
            notDoneLabel = 'Chưa uống';
        }

        final subtitle = taken && timeStr.isNotEmpty
            ? '$doneLabel lúc $timeStr'
            : notDoneLabel;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _HistoryItemCard(
            name: medName,
            subtitle: subtitle,
            taken: taken,
            type: medType,
          ),
        );
      }).toList(),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  const _HistoryItemCard({
    required this.name,
    required this.subtitle,
    required this.taken,
    this.type = 'Thuốc',
  });

  final String name;
  final String subtitle;
  final bool taken;
  final String type;

  IconData get _icon {
    switch (type) {
      case 'Bữa ăn':    return Icons.restaurant;
      case 'Hoạt động': return Icons.directions_walk;
      default:           return Icons.medication;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: taken
                  ? const Color(0xFF6B9B40)
                  : AppColors.error.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            taken ? Icons.check : Icons.close,
            color: taken ? const Color(0xFF00B21E) : AppColors.error,
            size: 24,
          ),
        ],
      ),
    );
  }
}

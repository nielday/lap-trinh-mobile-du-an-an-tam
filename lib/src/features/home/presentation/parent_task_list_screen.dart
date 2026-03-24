import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../../providers/medication_provider.dart';
import '../../../providers/appointment_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Parent task list screen - Shows all tasks for elderly users
class ParentTaskListScreen extends StatelessWidget {
  const ParentTaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Danh sách việc cần làm',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer2<MedicationProvider, AppointmentProvider>(
        builder: (context, medProvider, apptProvider, _) {
          final meds = medProvider.medications;
          final appts = apptProvider.appointments;
          
          // Tạo danh sách tất cả tasks (medications + appointments)
          final allTasks = <Map<String, dynamic>>[];
          
          // Thêm medications
          for (final med in meds) {
            final checkIn = medProvider.todayCheckIns.where((c) => c.medicationId == med.id).firstOrNull;
            final isCompleted = checkIn?.status == 'completed';
            
            allTasks.add({
              'type': 'medication',
              'data': med,
              'isCompleted': isCompleted,
            });
          }
          
          // Thêm appointments
          for (final appt in appts) {
            final isCompleted = appt.status == 'completed';
            
            allTasks.add({
              'type': 'appointment',
              'data': appt,
              'isCompleted': isCompleted,
            });
          }
          
          if (allTasks.isEmpty) {
            return Center(
              child: Text(
                'Không có công việc nào.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: allTasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final task = allTasks[index];
              final type = task['type'] as String;
              final isCompleted = task['isCompleted'] as bool;
              
              if (type == 'medication') {
                final med = task['data'];
                
                IconData icon = Icons.medication;
                Color color = const Color(0xFF7E57C2); // Tím
                if (med.type == 'Bữa ăn') {
                  icon = Icons.restaurant;
                  color = const Color(0xFF66BB6A);
                } else if (med.type == 'Hoạt động') {
                  icon = Icons.directions_walk;
                  color = const Color(0xFF42A5F5);
                }

                return _TaskItem(
                  icon: icon,
                  iconColor: color,
                  title: med.name,
                  subtitle: isCompleted ? 'Đã hoàn thành' : '${med.time} - Hôm nay',
                  isCompleted: isCompleted,
                  onTap: () {
                    if (!isCompleted) {
                      _showCheckInConfirmation(context, med: med, medProvider: medProvider, authProvider: context.read<AuthProvider>());
                    }
                  },
                );
              } else {
                // appointment
                final appt = task['data'];
                final daysLeft = appt.date.difference(DateTime.now()).inDays;
                final timeStr = daysLeft == 0 ? 'Hôm nay' : daysLeft == 1 ? 'Ngày mai' : 'Còn $daysLeft ngày';
                
                return _TaskItem(
                  icon: Icons.calendar_today,
                  iconColor: AppColors.accentOrange,
                  title: appt.title,
                  subtitle: isCompleted ? 'Đã hoàn thành' : timeStr,
                  isCompleted: isCompleted,
                  onTap: () {
                    if (!isCompleted) {
                      _showAppointmentConfirmation(context, appt: appt);
                    }
                  },
                );
              }
            },
          );
        },
      ),
    );
  }

  void _showCheckInConfirmation(BuildContext context, {dynamic med, required MedicationProvider medProvider, required AuthProvider authProvider}) async {
    final parentId = authProvider.effectiveParentId;
    if (parentId != null && med != null) {
      try {
        await FirebaseFirestore.instance.collection('checkIns').add({
          'medicationId': med.id,
          'parentId': parentId,
          'status': 'completed',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('check in error: $e');
      }
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.textWhite, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'ĐÃ GHI NHẬN!',
              style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Công việc đã được hoàn thành',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Material(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text('ĐÓNG', style: AppTextStyles.buttonLarge.copyWith(fontSize: 18, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppointmentConfirmation(BuildContext context, {required dynamic appt}) async {
    if (!context.mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Xác nhận khám bệnh',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary, fontSize: 22),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Bố/Mẹ ĐÃ đi khám "${appt.title}" rồi phải không ạ?',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'CHƯA ĐI',
              style: AppTextStyles.buttonMedium.copyWith(color: AppColors.textLight, fontSize: 18),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'ĐÃ KHÁM',
              style: AppTextStyles.buttonMedium.copyWith(color: AppColors.textWhite, fontSize: 18),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('appointments').doc(appt.id).update({
          'status': 'completed',
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tuyệt vời! Đã ghi nhận đi khám thành công.'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        debugPrint('appt check in error: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi cập nhật: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }
}

/// Task item widget
class _TaskItem extends StatelessWidget {
  const _TaskItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (isCompleted)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.textWhite,
                size: 24,
              ),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.textWhite, size: 24),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isCompleted
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

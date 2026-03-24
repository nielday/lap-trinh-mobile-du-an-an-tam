import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'parent_medication_reminder_screen.dart';
import 'parent_task_list_screen.dart';
import 'parent_settings_screen.dart';
import 'parent_calling_screen.dart';
import 'family_album_screen.dart';
import 'photo_upload_screen.dart';
import 'photo_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../providers/medication_provider.dart';
import '../../../providers/health_metric_provider.dart';
import '../../../providers/appointment_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/family_photo_provider.dart';
import '../../../repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Parent home screen - Ultra simple interface for elderly users
/// Based on design mockup with weather, health stats, tasks, and family photos
class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: AppColors.textPrimary,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ParentSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weather and date header
              _buildWeatherHeader(),
              
              const SizedBox(height: 20),
              
              // Health stats cards
              _buildHealthStats(context),
              
              const SizedBox(height: 20),
              
              // Action buttons (Call and Message)
              _buildActionButtons(context),
              
              const SizedBox(height: 20),
              // Completed button đã bị loại bỏ theo yêu cầu báo cáo đơn lẻ
              
              // Tasks section
              _buildTasksSection(context),
              
              const SizedBox(height: 24),
              
              // Family album section
              _buildFamilyAlbumSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Weather info
          Row(
            children: [
              const Icon(
                Icons.wb_sunny,
                color: AppColors.accentOrange,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                '24°C',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          // Date
          Text(
            DateFormat('EEEE, d/M', 'vi_VN').format(DateTime.now()),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStats(BuildContext context) {
    final metricProvider = context.watch<HealthMetricProvider>();
    final metric = metricProvider.latestMetric;

    return Row(
      children: [
        Expanded(
          child: _HealthStatCard(
            icon: Icons.favorite,
            iconColor: AppColors.error,
            value: metric?.heartRate != null ? '${metric!.heartRate} bpm' : 'N/A',
            label: 'Nhịp tim',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _HealthStatCard(
            icon: Icons.show_chart,
            iconColor: AppColors.accentOrange,
            value: metric?.bloodPressure ?? 'N/A',
            label: 'Huyết áp',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _HealthStatCard(
            icon: Icons.monitor_weight_outlined,
            iconColor: AppColors.textSecondary,
            value: metric?.weight != null ? '${metric!.weight} kg' : 'N/A',
            label: 'Cân nặng',
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.phone,
                label: 'Gọi điện',
                backgroundColor: AppColors.secondaryNavy,
                onTap: () {
                  _showCallDialog(context);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.message,
                label: 'Nhắn tin',
                backgroundColor: AppColors.secondaryNavy,
                onTap: () {
                  // TODO: Implement message functionality
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // SOS Button
        Material(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              _showSOSConfirmation(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emergency, color: AppColors.textWhite, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'KHẨN CẤP - SOS',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Gọi điện cho ai?',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CallContactButton(
              name: 'Con',
              icon: Icons.person,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ParentCallingScreen(
                      callerName: 'Con',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _CallContactButton(
              name: 'Bác sĩ',
              icon: Icons.medical_services,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ParentCallingScreen(
                      callerName: 'Bác sĩ',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _CallContactButton(
              name: 'Người thân khác',
              icon: Icons.people,
              onTap: () {
                Navigator.pop(context);
                // TODO: Show contact list
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSOSConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emergency,
                color: AppColors.textWhite,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'KHẨN CẤP!',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Gọi ngay cho Con và\ngửi thông báo khẩn cấp?',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'HỦY',
                          style: AppTextStyles.buttonLarge.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Material(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Make emergency call and send notification
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đang gọi khẩn cấp và gửi thông báo...'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'GỌI NGAY',
                          style: AppTextStyles.buttonLarge.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // (Đã xóa _buildCompletedButton theo yêu cầu sử dụng checkbox cụ thể)

  Widget _buildTasksSection(BuildContext context) {
    final medProvider = context.watch<MedicationProvider>();
    final apptProvider = context.watch<AppointmentProvider>();
    
    final tasks = <Widget>[];

    // Lấy thuốc hôm nay
    if (medProvider.medications.isNotEmpty) {
      for (final med in medProvider.medications.take(3)) {
        final checkIn = medProvider.todayCheckIns.where((c) => c.medicationId == med.id).firstOrNull;
        final isCompleted = checkIn?.status == 'completed';
        
        IconData icon = Icons.medication;
        Color color = const Color(0xFF7E57C2); // Tím
        if (med.type == 'Bữa ăn') {
          icon = Icons.restaurant;
          color = const Color(0xFF66BB6A);
        } else if (med.type == 'Hoạt động') {
          icon = Icons.directions_walk;
          color = const Color(0xFF42A5F5);
        }

        tasks.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TaskItem(
              icon: icon,
              iconColor: isCompleted ? AppColors.success : color,
              title: med.name,
              subtitle: isCompleted ? 'Đã hoàn thành' : '${med.time} - Hôm nay',
              isCompleted: isCompleted,
              onTap: () {
                if (!isCompleted) {
                  _showCheckInConfirmation(context, med: med, medProvider: medProvider, authProvider: context.read<AuthProvider>());
                }
              },
            ),
          ),
        );
      }
    }

    // Lấy lịch khám sắp tới
    if (apptProvider.appointments.isNotEmpty && tasks.length < 5) {
      for (final appt in apptProvider.appointments.take(2)) {
        final daysLeft = appt.date.difference(DateTime.now()).inDays;
        final timeStr = daysLeft == 0 ? 'Hôm nay' : daysLeft == 1 ? 'Ngày mai' : 'Còn $daysLeft ngày';
        
        final isCompleted = appt.status == 'completed';
        
        tasks.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TaskItem(
              icon: Icons.calendar_today,
              iconColor: isCompleted ? AppColors.success : AppColors.accentOrange,
              title: appt.title,
              subtitle: isCompleted ? 'Đã hoàn thành' : timeStr,
              isCompleted: isCompleted,
              onTap: () {
                if (!isCompleted) {
                  _showAppointmentConfirmation(context, appt: appt);
                }
              },
            ),
          ),
        );
      }
    }

    if (tasks.isEmpty) {
      tasks.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Không có công việc nào sắp tới.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Việc cần làm sắp tới',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ParentTaskListScreen(),
                  ),
                );
              },
              child: Text(
                'Xem tất cả',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tasks,
      ],
    );
  }

  Widget _buildFamilyAlbumSection(BuildContext context) {
    final photoProvider = context.watch<FamilyPhotoProvider>();
    final photos = photoProvider.photos.take(2).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'album ảnh gia đình',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FamilyAlbumScreen(),
                  ),
                );
              },
              child: Text(
                'Xem tất cả',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (photoProvider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (photos.isEmpty)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PhotoUploadScreen(),
                ),
              );
            },
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.indicatorInactive,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate, color: AppColors.textSecondary, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      'Thêm ảnh đầu tiên',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Row(
            children: [
              if (photos.isNotEmpty)
                Expanded(
                  child: _FamilyPhotoCard(
                    photo: photos[0],
                  ),
                ),
              if (photos.length > 1) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _FamilyPhotoCard(
                    photo: photos[1],
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  void _showCheckInConfirmation(BuildContext context, {dynamic med, required MedicationProvider medProvider, required AuthProvider authProvider}) async {
    final parentId = authProvider.effectiveParentId;
    if (parentId == null || med == null) return;

    if (!context.mounted) return;

    // HIỂN THỊ HỘP THOẠI HỎI XÁC NHẬN TRƯỚC!
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Xác nhận uống thuốc',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary, fontSize: 22),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Bố/Mẹ ĐÃ uống thuốc "${med.name}" rồi phải không ạ?',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // HỦY
            child: Text(
              'CHƯA UỐNG',
              style: AppTextStyles.buttonMedium.copyWith(color: AppColors.textLight, fontSize: 18),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // ĐÃ UỐNG
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'ĐÃ UỐNG',
              style: AppTextStyles.buttonMedium.copyWith(color: AppColors.textWhite, fontSize: 18),
            ),
          ),
        ],
      ),
    );

    // KHI ẤN ĐÃ UỐNG THÌ MỚI GHI LÊN FIREBASE
    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('checkIns').add({
          'medicationId': med.id,
          'parentId': parentId,
          'status': 'completed',
          'timestamp': Timestamp.now(), // Sử dụng thời gian thực để bên máy con cập nhật ngay lập tức
        });

        if (context.mounted) {
          // Hiển thị thông báo thành công nhanh bằng Snackbar (ko cần che cả màn hình làm mất thời gian)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tuyệt vời! Đã Ghi nhận hoàn thành thành công.'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        debugPrint('check in error: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi ghi nhận: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }

    // (Phần dialog thành công cũ che màn hình đã bị loại bỏ vì giờ xài Snackbar)
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
            onPressed: () => Navigator.pop(context, false), // HỦY
            child: Text(
              'CHƯA ĐI',
              style: AppTextStyles.buttonMedium.copyWith(color: AppColors.textLight, fontSize: 18),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // ĐÃ ĐI
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

/// Call contact button widget
class _CallContactButton extends StatelessWidget {
  const _CallContactButton({
    required this.name,
    required this.icon,
    required this.onTap,
  });

  final String name;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryGreen,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textWhite, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
              const Icon(
                Icons.phone,
                color: AppColors.textWhite,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Health stat card widget
class _HealthStatCard extends StatelessWidget {
  const _HealthStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button widget
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: AppColors.textWhite, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.textWhite,
                    size: 16,
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
              if (!isCompleted)
                IconButton(
                  onPressed: onTap,
                  icon: const Icon(
                    Icons.radio_button_unchecked,
                    color: AppColors.primaryGreen,
                    size: 32,
                  ),
                  tooltip: 'Đánh dấu hoàn thành',
                )
              else
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 32,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Family photo card widget
class _FamilyPhotoCard extends StatelessWidget {
  const _FamilyPhotoCard({
    required this.photo,
  });

  final dynamic photo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoDetailScreen(photo: photo),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: kIsWeb
                  ? Image.network(
                      photo.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image, color: AppColors.textSecondary, size: 48),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: photo.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.broken_image, color: AppColors.textSecondary, size: 48),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            photo.caption,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

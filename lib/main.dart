import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/features/auth/presentation/role_selection_screen.dart';
import 'src/features/home/presentation/child_home_screen.dart';
import 'src/features/home/presentation/parent_home_screen.dart';
import 'src/providers/alert_provider.dart';
import 'src/providers/appointment_provider.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/family_photo_provider.dart';
import 'src/providers/health_metric_provider.dart';
import 'src/providers/medication_provider.dart';
import 'src/providers/reminder_provider.dart';
import 'src/repositories/user_repository.dart';
import 'src/services/firebase_service.dart';
import 'src/theme/app_theme.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  await initializeDateFormatting('vi_VN', null);
  runApp(const AnTamApp());
}

class AnTamApp extends StatelessWidget {
  const AnTamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // UserRepository không phụ thuộc auth
        Provider(create: (_) => UserRepository()),

        // Providers phụ thuộc AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, MedicationProvider>(
          create: (_) => MedicationProvider(),
          update: (_, auth, prev) {
            final provider = prev ?? MedicationProvider();
            provider.updateUser(parentId: auth.effectiveParentId);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, AlertProvider>(
          create: (_) => AlertProvider(),
          update: (_, auth, prev) {
            final provider = prev ?? AlertProvider();
            provider.updateUser(userId: auth.user?.uid);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ReminderProvider>(
          create: (_) => ReminderProvider(),
          update: (_, auth, prev) {
            final provider = prev ?? ReminderProvider();
            provider.updateUser(userId: auth.user?.uid);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, AppointmentProvider>(
          create: (_) => AppointmentProvider(),
          update: (_, auth, prev) {
            final provider = prev ?? AppointmentProvider();
            provider.updateUser(parentId: auth.effectiveParentId);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, HealthMetricProvider>(
          create: (_) => HealthMetricProvider(),
          update: (_, auth, prev) {
            final provider = prev ?? HealthMetricProvider();
            provider.updateUser(parentId: auth.effectiveParentId);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, FamilyPhotoProvider>(
          create: (_) => FamilyPhotoProvider(),
          update: (_, auth, prev) {
            final provider = prev ?? FamilyPhotoProvider();
            provider.updateUser(parentId: auth.effectiveParentId);
            return provider;
          },
        ),
        // ChatProvider được cung cấp cục bộ tại ChatScreen
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'An Tâm',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: authProvider.isAuthenticated
                ? (authProvider.userModel?.role == 'parent'
                    ? const ParentHomeScreen()
                    : const ChildHomeScreen())
                : const RoleSelectionScreen(),
          );
        },
      ),
    );
  }
}

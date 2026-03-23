import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/features/auth/presentation/role_selection_screen.dart';
import 'src/features/home/presentation/child_home_screen.dart';
import 'src/providers/auth_provider.dart';
import 'src/services/firebase_service.dart';
import 'src/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.initialize();
  
  runApp(const AnTamApp());
}

class AnTamApp extends StatelessWidget {
  const AnTamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'An Tâm',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: authProvider.isAuthenticated
                ? const ChildHomeScreen()
                : const RoleSelectionScreen(),
          );
        },
      ),
    );
  }
}

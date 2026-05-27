import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/core/di/service_locator.dart';
import 'package:app/core/theme/app_theme.dart';

import 'package:app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:app/features/auth/presentation/screens/login_screen.dart';
import 'package:app/features/auth/presentation/screens/register_screen.dart';

import 'package:app/features/shifts/presentation/viewmodels/access_log_viewmodel.dart';
import 'package:app/features/shifts/presentation/screens/access_log_list_screen.dart';
import 'package:app/features/shifts/presentation/screens/access_log_form_screen.dart';

import 'package:app/features/visitors/presentation/viewmodels/visitor_viewmodel.dart';

import 'package:app/features/organization/presentation/viewmodels/organization_viewmodel.dart';

import 'package:app/features/user/presentation/viewmodels/user_viewmodel.dart';

import 'package:app/features/home/presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final sl = ServiceLocator();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository: sl.authRepository)
            ..tryAutoLogin(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              AccessLogViewModel(repository: sl.accessLogRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              VisitorViewModel(repository: sl.visitorRepository)..loadVisitors(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              OrganizationViewModel(repository: sl.organizationRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              UserViewModel(repository: sl.userRepository),
        ),
      ],
      child: const ShiftsApp(),
    ),
  );
}

class ShiftsApp extends StatelessWidget {
  const ShiftsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShiftsApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/access-logs': (context) => const AccessLogListScreen(),
        '/access-logs/create': (context) => const AccessLogFormScreen(),
        '/access-logs/edit': (context) => const AccessLogFormScreen(),
      },
      home: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          if (authVM.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (authVM.isAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<AccessLogViewModel>(context, listen: false)
                  .loadLogs();
            });
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}

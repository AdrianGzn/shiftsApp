import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/core/theme/app_theme.dart';

import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/auth/presentation/screens/login_screen.dart';
import 'package:app/features/auth/presentation/screens/register_screen.dart';

import 'package:app/features/shifts/presentation/providers/access_log_provider.dart';
import 'package:app/features/shifts/presentation/screens/access_log_list_screen.dart';
import 'package:app/features/shifts/presentation/screens/access_log_form_screen.dart';

import 'package:app/features/home/presentation/screens/home_screen.dart';

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
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (authProvider.isAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<AccessLogProvider>(context, listen: false)
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

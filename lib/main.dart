import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/core/di/service_locator.dart';
import 'package:app/app.dart';

import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/shifts/presentation/providers/access_log_provider.dart';
import 'package:app/features/visitors/presentation/providers/visitor_provider.dart';
import 'package:app/features/organization/presentation/providers/organization_provider.dart';
import 'package:app/features/user/presentation/providers/user_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final sl = ServiceLocator();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: sl.authRepository)
            ..tryAutoLogin(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              AccessLogProvider(repository: sl.accessLogRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              VisitorProvider(repository: sl.visitorRepository)..loadVisitors(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              OrganizationProvider(repository: sl.organizationRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              UserProvider(repository: sl.userRepository),
        ),
      ],
      child: const ShiftsApp(),
    ),
  );
}

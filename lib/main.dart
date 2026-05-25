import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import 'package:app/core/di/service_locator.dart';
import 'package:app/core/theme/app_theme.dart';

// Features - Auth
import 'package:app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:app/features/auth/presentation/screens/login_screen.dart';
import 'package:app/features/auth/presentation/screens/register_screen.dart';

// Features - Access Log
import 'package:app/features/shifts/presentation/viewmodels/access_log_viewmodel.dart';
import 'package:app/features/shifts/presentation/screens/access_log_list_screen.dart';
import 'package:app/features/shifts/presentation/screens/access_log_form_screen.dart';

// Features - Home
import 'package:app/features/home/presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inyección de dependencias manual
  final sl = ServiceLocator();

  runApp(
    /// MultiProvider en la raíz: inyecta los ViewModels
    /// para que estén disponibles en todo el árbol de widgets.
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
      ],
      child: const ShiftsApp(),
    ),
  );
}

/// Widget raíz de la aplicación.
/// Usa Material Theme 3 y Navegación 1.0 con rutas con nombre.
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
      // Navegación 1.0 con rutas con nombre
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/access-logs': (context) => const AccessLogListScreen(),
        '/access-logs/create': (context) => const AccessLogFormScreen(),
        '/access-logs/edit': (context) => const AccessLogFormScreen(),
      },
      // Home dinámico: Login o Home según el estado de autenticación
      home: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          // Mostrar loading mientras se verifica la sesión
          if (authVM.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Si está autenticado, cargar logs y mostrar Home
          if (authVM.isAuthenticated) {
            // Cargar los logs al autenticarse
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<AccessLogViewModel>(context, listen: false)
                  .loadLogs();
            });
            return const HomeScreen();
          }

          // Si no está autenticado, mostrar Login
          return const LoginScreen();
        },
      ),
    );
  }
}

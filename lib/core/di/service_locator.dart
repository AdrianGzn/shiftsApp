import 'package:app/core/network/api_client.dart';
import 'package:app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/shifts/data/datasources/access_log_remote_datasource.dart';
import 'package:app/features/shifts/data/repositories/access_log_repository_impl.dart';
import 'package:app/features/shifts/domain/repositories/access_log_repository.dart';

/// Inyección de dependencias manual.
/// Centraliza la creación de todas las dependencias de la aplicación
/// para que los ViewModels y Widgets accedan a repositorios sin
/// conocer su implementación concreta.
class ServiceLocator {
  // Singleton
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // --- Core ---
  late final ApiClient apiClient = ApiClient();

  // --- Auth Feature ---
  late final AuthRemoteDatasource authRemoteDatasource =
      AuthRemoteDatasource();

  late final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDatasource: authRemoteDatasource,
    apiClient: apiClient,
  );

  // --- Access Log Feature ---
  late final AccessLogRemoteDatasource accessLogRemoteDatasource =
      AccessLogRemoteDatasource(apiClient: apiClient);

  late final AccessLogRepository accessLogRepository =
      AccessLogRepositoryImpl(remoteDatasource: accessLogRemoteDatasource);
}

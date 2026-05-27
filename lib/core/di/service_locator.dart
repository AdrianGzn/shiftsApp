import 'package:app/core/network/api_client.dart';
import 'package:app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/shifts/data/datasources/access_log_remote_datasource.dart';
import 'package:app/features/shifts/data/repositories/access_log_repository_impl.dart';
import 'package:app/features/shifts/domain/repositories/access_log_repository.dart';
import 'package:app/features/visitors/data/datasources/visitor_remote_datasource.dart';
import 'package:app/features/visitors/data/repositories/visitor_repository_impl.dart';
import 'package:app/features/visitors/domain/repositories/visitor_repository.dart';

import 'package:app/features/organization/data/datasources/organization_remote_datasource.dart';
import 'package:app/features/organization/data/repositories/organization_repository_impl.dart';
import 'package:app/features/organization/domain/repositories/organization_repository.dart';

import 'package:app/features/user/data/datasources/user_remote_datasource.dart';
import 'package:app/features/user/data/repositories/user_repository_impl.dart';
import 'package:app/features/user/domain/repositories/user_repository.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final ApiClient apiClient = ApiClient();

  late final AuthRemoteDatasource authRemoteDatasource =
      AuthRemoteDatasource();

  late final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDatasource: authRemoteDatasource,
    apiClient: apiClient,
  );

  late final AccessLogRemoteDatasource accessLogRemoteDatasource =
      AccessLogRemoteDatasource(apiClient: apiClient);

  late final AccessLogRepository accessLogRepository =
      AccessLogRepositoryImpl(remoteDatasource: accessLogRemoteDatasource);

  late final VisitorRemoteDatasource visitorRemoteDatasource =
      VisitorRemoteDatasource(apiClient: apiClient);

  late final VisitorRepository visitorRepository =
      VisitorRepositoryImpl(remoteDatasource: visitorRemoteDatasource);

  late final OrganizationRemoteDatasource organizationRemoteDatasource =
      OrganizationRemoteDatasource(apiClient: apiClient);

  late final OrganizationRepository organizationRepository =
      OrganizationRepositoryImpl(remoteDatasource: organizationRemoteDatasource);

  late final UserRemoteDatasource userRemoteDatasource =
      UserRemoteDatasource(apiClient: apiClient);

  late final UserRepository userRepository =
      UserRepositoryImpl(remoteDatasource: userRemoteDatasource);
}

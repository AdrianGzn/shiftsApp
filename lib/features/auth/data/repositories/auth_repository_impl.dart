import 'package:app/core/network/api_client.dart';
import 'package:app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app/features/auth/domain/models/auth_user.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.apiClient,
  });

  @override
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    final user = await remoteDatasource.signInWithEmail(email, password);
    if (user != null) {
      apiClient.setAuthToken(user.idToken);
    }
    return user;
  }

  @override
  Future<AuthUser?> registerWithEmail({
    required String name,
    String? email,
    required String password,
    required String role,
    int? orgId,
  }) async {
    final user = await remoteDatasource.registerWithEmail(
      name: name,
      email: email,
      password: password,
      role: role,
      orgId: orgId,
    );
    if (user != null) {
      apiClient.setAuthToken(user.idToken);
    }
    return user;
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    final user = await remoteDatasource.signInWithGoogle();
    if (user != null) {
      apiClient.setAuthToken(user.idToken);
    }
    return user;
  }

  @override
  Future<void> signOut() async {
    apiClient.clearAuthToken();
    await remoteDatasource.signOut();
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final user = await remoteDatasource.getCurrentUser();
    if (user != null) {
      apiClient.setAuthToken(user.idToken);
    }
    return user;
  }

  @override
  Future<List<Map<String, dynamic>>> getOrganizations() async {
    return await remoteDatasource.getOrganizations();
  }
}

import 'package:app/features/auth/domain/models/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser?> signInWithEmail(String email, String password);

  Future<AuthUser?> registerWithEmail({
    required String name,
    String? email,
    required String password,
    required String role,
    int? orgId,
  });

  Future<AuthUser?> signInWithGoogle();

  Future<void> signOut();

  Future<AuthUser?> getCurrentUser();

  Future<List<Map<String, dynamic>>> getOrganizations();
}

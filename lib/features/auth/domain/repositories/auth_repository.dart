import 'package:app/features/auth/domain/models/auth_user.dart';

/// Contrato (interfaz) del repositorio de autenticación.
/// Define las operaciones que la capa de dominio espera,
/// sin importar la implementación concreta.
abstract class AuthRepository {
  /// Inicia sesión con correo y contraseña.
  Future<AuthUser?> signInWithEmail(String email, String password);

  /// Registra un nuevo usuario.
  Future<AuthUser?> registerWithEmail({
    required String name,
    String? email,
    required String password,
    required String role,
    int? orgId,
  });

  /// Inicia sesión con Google y retorna el usuario autenticado.
  Future<AuthUser?> signInWithGoogle();

  /// Cierra la sesión de Google.
  Future<void> signOut();

  /// Verifica si hay una sesión activa de Google.
  Future<AuthUser?> getCurrentUser();

  /// Obtiene el listado de organizaciones.
  Future<List<Map<String, dynamic>>> getOrganizations();
}

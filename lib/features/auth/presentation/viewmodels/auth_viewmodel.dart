import 'package:flutter/material.dart';
import 'package:app/features/auth/domain/models/auth_user.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/core/config/api_config.dart';

/// ViewModel para la funcionalidad de autenticación.
/// Implementa el patrón MVVM usando ChangeNotifier + Provider.
/// Gestiona el estado del usuario autenticado y las operaciones de login/logout.
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // --- Estado ---
  AuthUser? _user;
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _organizations = [];

  // --- Getters ---
  AuthUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get organizations => _organizations;

  /// Intenta recuperar una sesión previa al iniciar la aplicación.
  Future<void> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authRepository.getCurrentUser();
    } catch (e) {
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Inicia sesión con correo y contraseña.
  Future<void> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.signInWithEmail(email, password);
    } catch (e, stackTrace) {
      print('AuthViewModel: Error en signInWithEmail -> $e');
      print(stackTrace);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Registra un usuario con los datos correspondientes.
  Future<void> registerWithEmail({
    required String name,
    String? email,
    required String password,
    required String role,
    int? orgId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.registerWithEmail(
        name: name,
        email: email,
        password: password,
        role: role,
        orgId: orgId,
      );
    } catch (e, stackTrace) {
      print('AuthViewModel: Error en registerWithEmail -> $e');
      print(stackTrace);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Obtiene la lista de organizaciones activas.
  Future<void> fetchOrganizations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _organizations = await _authRepository.getOrganizations();
    } catch (e) {
      print('AuthViewModel: Error fetching organizations: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Asocia una organización al usuario autenticado (usado por el Administrador al crearla).
  Future<void> updateOrganizationId(int orgId) async {
    if (_user == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/users/${_user!.id}');
      print('AuthViewModel: updateOrganizationId -> PUT $url');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_user!.idToken}',
        },
        body: jsonEncode({'idOrganization': orgId}),
      );
      print('AuthViewModel: updateOrganizationId response -> Status ${response.statusCode}');
      if (response.statusCode == 200) {
        _user = AuthUser(
          id: _user!.id,
          email: _user!.email,
          displayName: _user!.displayName,
          photoUrl: _user!.photoUrl,
          idToken: _user!.idToken,
          role: _user!.role,
          idOrganization: orgId,
        );
      } else {
        throw Exception('Error al asociar organización: ${response.body}');
      }
    } catch (e) {
      print('AuthViewModel: Error updating user organization: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Inicia sesión con Google.
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.signInWithGoogle();
      if (_user == null) {
        print('AuthViewModel: signInWithGoogle -> Usuario canceló u obtuvo nulo');
        _errorMessage = 'Inicio de sesión cancelado';
      }
    } catch (e, stackTrace) {
      print('AuthViewModel: Error en signInWithGoogle -> $e');
      if (!e.toString().contains('NEEDS_REGISTRATION')) {
        print(stackTrace); // No saturar el log si es un flujo normal de registro
      }
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Cierra la sesión.
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Limpia el mensaje de error.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

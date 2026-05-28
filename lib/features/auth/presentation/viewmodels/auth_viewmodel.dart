import 'package:flutter/material.dart';
import 'package:app/features/auth/domain/models/auth_user.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/presentation/screens/auth_status.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/core/config/api_config.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  AuthUser? _user;
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  List<Map<String, dynamic>> _organizations = [];

  AuthUser? get user => _user;
  AuthStatus get status => _status;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get organizations => _organizations;

  Future<void> tryAutoLogin() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      _user = await _authRepository.getCurrentUser();
    } catch (e) {
      _user = null;
    }

    _status = _user != null ? AuthStatus.success : AuthStatus.error;
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.signInWithEmail(email, password);
    } catch (e, stackTrace) {
      print('AuthViewModel: Error en signInWithEmail -> $e');
      print(stackTrace);
      _errorMessage = 'Nombre o contraseña no válidos';
      _user = null;
    }

    _status = _user != null ? AuthStatus.success : AuthStatus.error;
    notifyListeners();
  }

  Future<void> registerWithEmail({
    required String name,
    String? email,
    required String password,
    required String role,
    int? orgId,
  }) async {
    _status = AuthStatus.loading;
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
      _errorMessage = 'No se ha podido registrar el usuario. Inténtelo más tarde.';
      _user = null;
    }

    _status = _user != null ? AuthStatus.success : AuthStatus.error;
    notifyListeners();
  }

  Future<void> fetchOrganizations() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _organizations = await _authRepository.getOrganizations();
    } catch (e) {
      print('AuthViewModel: Error fetching organizations: $e');
      _errorMessage = 'Servidor no disponible. Inténtelo más tarde.';
    } finally {
      _status = _errorMessage != null ? AuthStatus.error : AuthStatus.success;
      notifyListeners();
    }
  }

  Future<void> updateOrganizationId(int orgId) async {
    if (_user == null) return;
    _status = AuthStatus.loading;
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
      _errorMessage = 'No se han podido cambiar los datos del usuario.';
      rethrow;
    } finally {
      _status = _errorMessage != null ? AuthStatus.error : AuthStatus.success;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? name, String? email}) async {
    if (_user == null) return;
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/users/${_user!.id}');
      print('AuthViewModel: updateProfile -> PUT $url');
      final Map<String, dynamic> body = {};
      if (name != null && name.isNotEmpty) body['name'] = name;
      if (email != null && email.isNotEmpty) body['email'] = email;

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_user!.idToken}',
        },
        body: jsonEncode(body),
      );
      print('AuthViewModel: updateProfile response -> Status ${response.statusCode}');
      if (response.statusCode == 200) {
        _user = AuthUser(
          id: _user!.id,
          email: email != null && email.isNotEmpty ? email : _user!.email,
          displayName: name != null && name.isNotEmpty ? name : _user!.displayName,
          photoUrl: _user!.photoUrl,
          idToken: _user!.idToken,
          role: _user!.role,
          idOrganization: _user!.idOrganization,
        );
      } else {
        throw Exception('Error al actualizar perfil: ${response.body}');
      }
    } catch (e) {
      print('AuthViewModel: Error updating profile: $e');
      _errorMessage = 'No se han podido cambiar los datos del usuario.';
      rethrow;
    } finally {
      _status = _errorMessage != null ? AuthStatus.error : AuthStatus.success;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _status = AuthStatus.loading;
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
        print(stackTrace);
        _errorMessage = 'No se pudo iniciar sesión con Google. Inténtelo más tarde.';
      } else {
        final msg = e.toString();
        final idx = msg.indexOf('NEEDS_REGISTRATION');
        _errorMessage = idx != -1 ? msg.substring(idx) : 'NEEDS_REGISTRATION';
      }
      _user = null;
    }

    _status = _user != null ? AuthStatus.success : AuthStatus.error;
    notifyListeners();
  }

  Future<void> signOut() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _authRepository.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión';
    }

    _status = AuthStatus.idle;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/core/config/api_config.dart';

/// Cliente HTTP centralizado que maneja las peticiones a la API REST.
/// Todas las peticiones incluyen el token de autenticación de Google
/// en el header Authorization como Bearer token.
class ApiClient {
  final http.Client _client;
  String? _authToken;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Establece el token de autenticación de Google (ID Token).
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Limpia el token de autenticación al cerrar sesión.
  void clearAuthToken() {
    _authToken = null;
  }

  /// Headers comunes para todas las peticiones.
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// Realiza una petición GET.
  /// [endpoint] es la ruta relativa (ej: '/users/').
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await _client.get(url, headers: _headers);
    return response;
  }

  /// Realiza una petición GET por ID.
  /// [endpoint] incluye el ID (ej: '/users/1').
  Future<http.Response> getById(String endpoint) async {
    return get(endpoint);
  }

  /// Realiza una petición POST con un body JSON.
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await _client.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );
    return response;
  }

  /// Realiza una petición PUT con un body JSON para actualizar.
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await _client.put(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );
    return response;
  }

  /// Realiza una petición DELETE.
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await _client.delete(url, headers: _headers);
    return response;
  }

  /// Cierra el cliente HTTP.
  void dispose() {
    _client.close();
  }
}

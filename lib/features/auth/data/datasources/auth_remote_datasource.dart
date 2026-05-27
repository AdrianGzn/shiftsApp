import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:app/features/auth/domain/models/auth_user.dart';
import 'package:app/core/config/api_config.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDatasource {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '777549895961-o3vshogh18s3b2jesccn46n4btm01r72.apps.googleusercontent.com',
    serverClientId: '777549895961-o3vshogh18s3b2jesccn46n4btm01r72.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );
  
  final http.Client _client = http.Client();

  Future<AuthUser?> signInWithEmail(String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/login');
    print('AuthRemoteDatasource: signInWithEmail -> POST $url');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('AuthRemoteDatasource: signInWithEmail -> Status Code: ${response.statusCode}, Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];
      return AuthUser(
        id: user['id'].toString(),
        email: user['mail'],
        displayName: user['name'],
        idToken: data['access_token'],
        role: user['role'] ?? 'empleado',
        idOrganization: user['idOrganization'],
      );
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Error de autenticación');
    }
  }

  Future<AuthUser?> registerWithEmail({
    required String name,
    String? email,
    required String password,
    required String role,
    int? orgId,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/');
    print('AuthRemoteDatasource: registerWithEmail -> POST $url');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'mail': (email != null && email.isNotEmpty) ? email : null,
        'password': password,
        'idOrganization': orgId,
        'role': role
      }),
    );

    print('AuthRemoteDatasource: registerWithEmail -> Status Code: ${response.statusCode}, Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final loginIdentifier = (email != null && email.isNotEmpty) ? email : name;
      return signInWithEmail(loginIdentifier, password);
    } else {
      throw Exception('Error al registrar usuario: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getOrganizations() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/organizations/');
    print('AuthRemoteDatasource: getOrganizations -> GET $url');
    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    print('AuthRemoteDatasource: getOrganizations -> Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Error al obtener organizaciones');
    }
  }

  Future<AuthUser?> signInWithGoogle() async {
    print('AuthRemoteDatasource: signInWithGoogle -> Iniciando flujo nativo de Google...');
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account == null) {
      print('AuthRemoteDatasource: signInWithGoogle -> Cancelado por el usuario');
      return null;
    }

    print('AuthRemoteDatasource: signInWithGoogle -> GoogleSignInAccount obtenido: ${account.email}');
    final GoogleSignInAuthentication auth = await account.authentication;
    final String? idToken = auth.idToken;

    if (idToken == null) {
      print('AuthRemoteDatasource: signInWithGoogle -> No se pudo obtener el idToken');
      return null;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/auth/google');
    print('AuthRemoteDatasource: signInWithGoogle -> POST $url para validar el token en el servidor...');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': idToken}),
    );

    print('AuthRemoteDatasource: signInWithGoogle -> Servidor Status Code: ${response.statusCode}, Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['needs_registration'] == true) {
        print('AuthRemoteDatasource: signInWithGoogle -> El servidor requiere registro previo');
        throw Exception('NEEDS_REGISTRATION|${data['email']}|${data['name']}');
      } else {
        final user = data['user'];
        return AuthUser(
          id: user['id'].toString(),
          email: user['mail'],
          displayName: user['name'],
          idToken: data['access_token'],
          role: user['role'] ?? 'empleado',
          idOrganization: user['idOrganization'],
        );
      }
    } else {
      throw Exception('Error al validar con Google en el servidor: ${response.body}');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<AuthUser?> getCurrentUser() async {
    final GoogleSignInAccount? account =
        await _googleSignIn.signInSilently();
    if (account == null) return null;

    final GoogleSignInAuthentication auth = await account.authentication;
    final String? idToken = auth.idToken;

    if (idToken == null) return null;

    return AuthUser(
      id: account.id,
      email: account.email,
      displayName: account.displayName ?? 'Usuario',
      photoUrl: account.photoUrl,
      idToken: idToken,
      role: 'empleado',
      idOrganization: null,
    );
  }
}

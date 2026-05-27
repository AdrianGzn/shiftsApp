import 'dart:convert';
import 'package:app/core/network/api_client.dart';
import 'package:app/features/user/domain/models/user_model.dart';

class UserRemoteDatasource {
  final ApiClient apiClient;

  UserRemoteDatasource({required this.apiClient});

  Future<List<UserModel>> getEmployeesByOrganization(int orgId) async {
    final response = await apiClient.get('/users/');
    if (response.statusCode == 200) {
      final List<dynamic> allUsers = jsonDecode(response.body);
      return allUsers
          .where((u) => u['idOrganization'] == orgId)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Servidor no disponible. Inténtelo más tarde.');
    }
  }

  Future<void> deleteUser(String userId) async {
    final response = await apiClient.delete('/users/$userId');
    if (response.statusCode != 200) {
      throw Exception('No se ha podido eliminar la cuenta. Inténtelo más tarde.');
    }
  }
}

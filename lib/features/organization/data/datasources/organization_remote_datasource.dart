import 'dart:convert';
import 'package:app/core/network/api_client.dart';
import 'package:app/features/organization/domain/models/organization.dart';

class OrganizationRemoteDatasource {
  final ApiClient apiClient;

  OrganizationRemoteDatasource({required this.apiClient});

  Future<Organization> getOrganization(int id) async {
    final response = await apiClient.get('/organizations/$id');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Organization.fromJson(data);
    } else {
      throw Exception('Servidor no disponible. Inténtelo más tarde.');
    }
  }

  Future<Organization> createOrganization(Organization organization) async {
    final json = organization.toJson();
    json.remove('id'); // let database handle auto_increment id
    final response = await apiClient.post('/organizations/', json);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Organization.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Servidor no disponible. Inténtelo más tarde.');
    }
  }
}

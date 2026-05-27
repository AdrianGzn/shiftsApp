import 'dart:convert';
import 'package:app/core/network/api_client.dart';
import 'package:app/features/visitors/domain/models/visitor.dart';

class VisitorRemoteDatasource {
  final ApiClient apiClient;

  VisitorRemoteDatasource({required this.apiClient});

  Future<List<Visitor>> getVisitors() async {
    final response = await apiClient.get('/visitors/');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Visitor.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load visitors: ${response.statusCode}');
    }
  }

  Future<Visitor> createVisitor(Visitor visitor) async {
    final json = visitor.toJson();
    json.remove('id'); // let database handle auto_increment id
    final response = await apiClient.post('/visitors/', json);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Visitor.fromJson(jsonDecode(response.body));
    } else {
      try {
        final body = jsonDecode(response.body);
        final detail = body['detail'] ?? 'Failed to create visitor';
        throw Exception(detail);
      } catch (_) {
        throw Exception('Failed to create visitor: ${response.statusCode}');
      }
    }
  }
}

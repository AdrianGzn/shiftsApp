import 'dart:convert';
import 'package:app/core/network/api_client.dart';
import 'package:app/features/shifts/domain/models/access_log.dart';

class AccessLogRemoteDatasource {
  final ApiClient apiClient;

  AccessLogRemoteDatasource({required this.apiClient});

  Future<List<AccessLog>> getLogs() async {
    final response = await apiClient.get('/access-logs/');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AccessLog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load access logs');
    }
  }

  Future<AccessLog> createLog(AccessLog log) async {
    final response = await apiClient.post('/access-logs/', log.toJson());
    if (response.statusCode == 200 || response.statusCode == 201) {
      return AccessLog.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create access log');
    }
  }
}

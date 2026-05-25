import 'package:app/features/shifts/domain/models/access_log.dart';

abstract class AccessLogRepository {
  Future<List<AccessLog>> getLogs();
  Future<AccessLog> createLog(AccessLog log);
}

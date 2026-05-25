import 'package:app/features/shifts/data/datasources/access_log_remote_datasource.dart';
import 'package:app/features/shifts/domain/models/access_log.dart';
import 'package:app/features/shifts/domain/repositories/access_log_repository.dart';

class AccessLogRepositoryImpl implements AccessLogRepository {
  final AccessLogRemoteDatasource remoteDatasource;

  AccessLogRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<AccessLog>> getLogs() async {
    return await remoteDatasource.getLogs();
  }

  @override
  Future<AccessLog> createLog(AccessLog log) async {
    return await remoteDatasource.createLog(log);
  }
}

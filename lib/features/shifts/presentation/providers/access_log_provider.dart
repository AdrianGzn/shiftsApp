import 'package:flutter/foundation.dart';
import 'package:app/features/shifts/domain/models/access_log.dart';
import 'package:app/features/shifts/domain/repositories/access_log_repository.dart';
import 'package:app/features/shifts/presentation/screens/access_log_status.dart';

class AccessLogProvider extends ChangeNotifier {
  final AccessLogRepository repository;

  AccessLogProvider({required this.repository});

  List<AccessLog> _logs = [];
  List<AccessLog> get logs => _logs;

  AccessLogStatus _status = AccessLogStatus.idle;
  AccessLogStatus get status => _status;
  bool get isLoading => _status == AccessLogStatus.loading;

  String? _error;
  String? get error => _error;

  Future<void> loadLogs() async {
    _status = AccessLogStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _logs = await repository.getLogs();
    } catch (e) {
      _error = 'Servidor no disponible. Inténtelo más tarde.';
    } finally {
      _status = _error != null ? AccessLogStatus.error : AccessLogStatus.success;
      notifyListeners();
    }
  }

  Future<bool> createLog(AccessLog log) async {
    _status = AccessLogStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final newLog = await repository.createLog(log);
      _logs.insert(0, newLog);
      _status = AccessLogStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'No se ha podido registrar la entrada o salida.';
      _status = AccessLogStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerAccess({
    required int? idUser,
    required int? idVisitor,
    required int idGuard,
    String? notes,
  }) async {
    _status = AccessLogStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _logs = await repository.getLogs();

      AccessLog? latestLog;
      
      final personLogs = _logs.where((log) {
        if (idUser != null) return log.idUser == idUser;
        if (idVisitor != null) return log.idVisitor == idVisitor;
        return false;
      }).toList();

      if (personLogs.isNotEmpty) {
        personLogs.sort((a, b) => b.timestampEvent.compareTo(a.timestampEvent));
        latestLog = personLogs.first;
      }

      String nextEventType = 'entry';
      if (latestLog != null && latestLog.eventType == 'entry') {
        nextEventType = 'exit';
      }

      final newLog = AccessLog(
        id: 0,
        idUser: idUser,
        idVisitor: idVisitor,
        idGuard: idGuard,
        eventType: nextEventType,
        timestampEvent: DateTime.now(),
        notes: notes,
      );

      final createdLog = await repository.createLog(newLog);
      _logs.insert(0, createdLog);
      
      _status = AccessLogStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'No se ha podido registrar la entrada o salida.';
      _status = AccessLogStatus.error;
      notifyListeners();
      return false;
    }
  }
}

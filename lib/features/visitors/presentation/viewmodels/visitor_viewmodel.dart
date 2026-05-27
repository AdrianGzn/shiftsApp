import 'package:flutter/foundation.dart';
import 'package:app/features/visitors/domain/models/visitor.dart';
import 'package:app/features/visitors/domain/repositories/visitor_repository.dart';

class VisitorViewModel extends ChangeNotifier {
  final VisitorRepository repository;

  VisitorViewModel({required this.repository});

  List<Visitor> _visitors = [];
  List<Visitor> get visitors => _visitors;

  final Map<int, Visitor> _visitorMap = {};
  Map<int, Visitor> get visitorMap => _visitorMap;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadVisitors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _visitors = await repository.getVisitors();
      _visitorMap.clear();
      for (var v in _visitors) {
        _visitorMap[v.id] = v;
      }
    } catch (e) {
      _error = 'Servidor no disponible. Inténtelo más tarde.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Visitor?> addVisitor({
    required String fullName,
    String? documentId,
    String? company,
    required String reason,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final visitor = Visitor(
        id: 0,
        fullName: fullName,
        documentId: documentId,
        company: company,
        reason: reason,
        phone: phone,
      );
      final createdVisitor = await repository.createVisitor(visitor);
      _visitors.add(createdVisitor);
      _visitorMap[createdVisitor.id] = createdVisitor;
      _isLoading = false;
      notifyListeners();
      return createdVisitor;
    } catch (e) {
      _error = 'No se ha podido registrar el visitante.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  String getVisitorName(int id) {
    return _visitorMap[id]?.fullName ?? 'Visitante #$id';
  }
}

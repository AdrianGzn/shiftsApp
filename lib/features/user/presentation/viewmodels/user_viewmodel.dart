import 'package:flutter/material.dart';
import 'package:app/features/user/domain/models/user_model.dart';
import 'package:app/features/user/domain/repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository repository;

  UserViewModel({required this.repository});

  List<UserModel> _employees = [];
  List<UserModel> get employees => _employees;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadEmployees(int orgId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employees = await repository.getEmployeesByOrganization(orgId);
    } catch (e) {
      _error = 'Servidor no disponible. Inténtelo más tarde.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.deleteUser(userId);
      return true;
    } catch (e) {
      _error = 'No se ha podido eliminar la cuenta. Inténtelo más tarde.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

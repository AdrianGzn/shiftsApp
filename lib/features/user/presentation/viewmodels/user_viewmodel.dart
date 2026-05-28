import 'package:flutter/material.dart';
import 'package:app/features/user/domain/models/user_model.dart';
import 'package:app/features/user/domain/repositories/user_repository.dart';
import 'package:app/features/user/presentation/screens/user_status.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository repository;

  UserViewModel({required this.repository});

  List<UserModel> _employees = [];
  List<UserModel> get employees => _employees;

  UserStatus _status = UserStatus.idle;
  UserStatus get status => _status;
  bool get isLoading => _status == UserStatus.loading;

  String? _error;
  String? get error => _error;

  Future<void> loadEmployees(int orgId) async {
    _status = UserStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _employees = await repository.getEmployeesByOrganization(orgId);
    } catch (e) {
      _error = 'Servidor no disponible. Inténtelo más tarde.';
    } finally {
      _status = _error != null ? UserStatus.error : UserStatus.success;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount(String userId) async {
    _status = UserStatus.loading;
    _error = null;
    notifyListeners();

    try {
      await repository.deleteUser(userId);
      return true;
    } catch (e) {
      _error = 'No se ha podido eliminar la cuenta. Inténtelo más tarde.';
      return false;
    } finally {
      _status = _error != null ? UserStatus.error : UserStatus.success;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

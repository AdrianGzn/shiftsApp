import 'package:flutter/material.dart';
import 'package:app/features/organization/domain/models/organization.dart';
import 'package:app/features/organization/domain/repositories/organization_repository.dart';

class OrganizationViewModel extends ChangeNotifier {
  final OrganizationRepository repository;

  OrganizationViewModel({required this.repository});

  Organization? _organization;
  Organization? get organization => _organization;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadOrganization(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _organization = await repository.getOrganization(id);
    } catch (e) {
      _error = 'Servidor no disponible. Inténtelo más tarde.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Organization?> createOrganization({
    required String name,
    required String type,
    required String address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newOrg = Organization(
        id: 0,
        name: name,
        type: type,
        address: address,
      );
      final created = await repository.createOrganization(newOrg);
      _organization = created;
      return created;
    } catch (e) {
      _error = 'Servidor no disponible. Inténtelo más tarde.';
      return null;
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

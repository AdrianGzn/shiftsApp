import 'package:flutter/material.dart';
import 'package:app/features/organization/domain/models/organization.dart';
import 'package:app/features/organization/domain/repositories/organization_repository.dart';
import 'package:app/features/organization/presentation/screens/organization_status.dart';

class OrganizationProvider extends ChangeNotifier {
  final OrganizationRepository repository;

  OrganizationProvider({required this.repository});

  Organization? _organization;
  Organization? get organization => _organization;

  OrganizationStatus _status = OrganizationStatus.idle;
  OrganizationStatus get status => _status;
  bool get isLoading => _status == OrganizationStatus.loading;

  String? _error;
  String? get error => _error;

  Future<void> loadOrganization(int id) async {
    print('OrganizationProvider: loadOrganization(id: $id) started');
    _status = OrganizationStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _organization = await repository.getOrganization(id);
      print('OrganizationProvider: loadOrganization(id: $id) success: $_organization');
    } catch (e, stackTrace) {
      print('OrganizationProvider: Error loading organization (id: $id): $e');
      print(stackTrace);
      _error = 'Servidor no disponible. Inténtelo más tarde.';
    } finally {
      _status = _error != null ? OrganizationStatus.error : OrganizationStatus.success;
      print('OrganizationProvider: loadOrganization finished with status: $_status');
      notifyListeners();
    }
  }

  Future<Organization?> createOrganization({
    required String name,
    required String type,
    required String address,
  }) async {
    print('OrganizationProvider: createOrganization(name: $name, type: $type, address: $address) started');
    _status = OrganizationStatus.loading;
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
      print('OrganizationProvider: createOrganization success: $created');
      return created;
    } catch (e, stackTrace) {
      print('OrganizationProvider: Error creating organization: $e');
      print(stackTrace);
      _error = 'Servidor no disponible. Inténtelo más tarde.';
      return null;
    } finally {
      _status = _error != null ? OrganizationStatus.error : OrganizationStatus.success;
      print('OrganizationProvider: createOrganization finished with status: $_status');
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

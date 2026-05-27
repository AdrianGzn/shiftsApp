import 'package:app/features/organization/domain/models/organization.dart';
import 'package:app/features/organization/domain/repositories/organization_repository.dart';
import 'package:app/features/organization/data/datasources/organization_remote_datasource.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final OrganizationRemoteDatasource remoteDatasource;

  OrganizationRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Organization> getOrganization(int id) {
    return remoteDatasource.getOrganization(id);
  }

  @override
  Future<Organization> createOrganization(Organization organization) {
    return remoteDatasource.createOrganization(organization);
  }
}

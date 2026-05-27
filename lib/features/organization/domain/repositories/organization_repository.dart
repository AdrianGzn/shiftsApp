import 'package:app/features/organization/domain/models/organization.dart';

abstract class OrganizationRepository {
  Future<Organization> getOrganization(int id);
  Future<Organization> createOrganization(Organization organization);
}

import 'package:app/features/user/domain/models/user_model.dart';
import 'package:app/features/user/domain/repositories/user_repository.dart';
import 'package:app/features/user/data/datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource remoteDatasource;

  UserRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<UserModel>> getEmployeesByOrganization(int orgId) {
    return remoteDatasource.getEmployeesByOrganization(orgId);
  }

  @override
  Future<void> deleteUser(String userId) {
    return remoteDatasource.deleteUser(userId);
  }
}

import 'package:app/features/user/domain/models/user_model.dart';

abstract class UserRepository {
  Future<List<UserModel>> getEmployeesByOrganization(int orgId);
  Future<void> deleteUser(String userId);
}

import 'package:app/features/visitors/domain/models/visitor.dart';
import 'package:app/features/visitors/domain/repositories/visitor_repository.dart';
import 'package:app/features/visitors/data/datasources/visitor_remote_datasource.dart';

class VisitorRepositoryImpl implements VisitorRepository {
  final VisitorRemoteDatasource remoteDatasource;

  VisitorRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<Visitor>> getVisitors() {
    return remoteDatasource.getVisitors();
  }

  @override
  Future<Visitor> createVisitor(Visitor visitor) {
    return remoteDatasource.createVisitor(visitor);
  }
}

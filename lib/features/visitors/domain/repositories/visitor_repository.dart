import 'package:app/features/visitors/domain/models/visitor.dart';

abstract class VisitorRepository {
  Future<List<Visitor>> getVisitors();
  Future<Visitor> createVisitor(Visitor visitor);
}

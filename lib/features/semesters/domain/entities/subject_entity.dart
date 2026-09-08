import 'package:equatable/equatable.dart';

class SubjectEntity extends Equatable {
  final int id;
  final String name;
  final int? resourceCount;

  const SubjectEntity({
    required this.id,
    required this.name,
    this.resourceCount,
  });

  @override
  List<Object?> get props => [id, name, resourceCount];
}

import 'package:equatable/equatable.dart';

class SemestersEntity extends Equatable {
  final int id;
  final String name;
  final int? subjectCount;

  const SemestersEntity({
    required this.id,
    required this.name,
    this.subjectCount,
  });

  @override
  List<Object?> get props => [id, name, subjectCount];
}

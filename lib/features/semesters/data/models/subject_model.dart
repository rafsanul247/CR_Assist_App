import '../../domain/entities/subject_entity.dart';

class SubjectModel extends SubjectEntity {
  const SubjectModel({
    required super.id,
    required super.name,
    super.resourceCount,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    // Standard Prisma _count check kora hobe
    int count = 0;
    if (json['_count'] != null && json['_count']['resources'] != null) {
      count = json['_count']['resources'] as int;
    } else if (json['resourceCount'] != null) {
      count = json['resourceCount'] as int;
    } else if (json['resourcesCount'] != null) {
      count = json['resourcesCount'] as int;
    }

    return SubjectModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      resourceCount: count,
    );
  }
}

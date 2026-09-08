import '../../domain/entities/semesters_entity.dart';

class SemestersModel extends SemestersEntity {
  const SemestersModel({
    required super.id,
    required super.name,
    super.subjectCount,
  });

  factory SemestersModel.fromJson(Map<String, dynamic> json) {
    // Backend theke count vibinno name-e ashte pare, sob check korchi
    int count = 0;
    if (json['_count'] != null && json['_count']['subjects'] != null) {
      count = json['_count']['subjects'] as int;
    } else if (json['subjectCount'] != null) {
      count = json['subjectCount'] as int;
    } else if (json['subjectsCount'] != null) {
      count = json['subjectsCount'] as int;
    }

    return SemestersModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      subjectCount: count,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subjectCount': subjectCount,
    };
  }
}

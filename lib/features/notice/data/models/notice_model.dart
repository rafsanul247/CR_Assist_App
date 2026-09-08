import '../../domain/entities/notice_entity.dart';

class NoticeModel extends NoticeEntity {
  const NoticeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: (DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now()).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

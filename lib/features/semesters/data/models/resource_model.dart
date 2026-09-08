import '../../domain/entities/resource_entity.dart';

class ResourceModel extends ResourceEntity {
  const ResourceModel({
    required super.id,
    required super.title,
    required super.url,
    required super.type,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled',
      url: (json['fileUrl'] ?? json['url']) as String? ?? '',
      type: json['type'] as String? ?? 'PDF',
    );
  }
}

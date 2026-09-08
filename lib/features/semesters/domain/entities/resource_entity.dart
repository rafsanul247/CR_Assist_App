import 'package:equatable/equatable.dart';

class ResourceEntity extends Equatable {
  final int id;
  final String title;
  final String url;
  final String type; // PDF, IMAGE, etc.

  const ResourceEntity({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, url, type];
}

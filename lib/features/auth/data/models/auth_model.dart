import '../../domain/entities/auth_entity.dart';

// Matches the backend's login/register response shape:
// { user: { id, username, email, role, batchId, batch: { deptName, batchName, universityName } }, token }
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.role,
    required super.batchId,
    required super.deptName,
    required super.batchName,
    required super.universityName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // batch info comes nested under "batch" — only present on login
    // response (which does `include: { batch: true }`); register doesn't
    // include it, so fall back gracefully.
    final batch = json['batch'] as Map<String, dynamic>?;

    return UserModel(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'STUDENT',
      batchId: json['batchId'] as int? ?? 0,
      deptName: batch?['deptName'] as String? ?? '',
      batchName: batch?['batchName'] as String? ?? '',
      universityName: batch?['universityName'] as String? ?? '',
    );
  }
}
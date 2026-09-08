import 'package:equatable/equatable.dart';

// Business object for a logged-in user, including batch info needed
// for display (e.g. "CSE-108 | DIU" label on the Home screen)
class UserEntity extends Equatable {
  final int id;
  final String username;
  final String email;
  final String role; // "STUDENT" or "CR"
  final int batchId;
  final String deptName;
  final String batchName;
  final String universityName;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.batchId,
    required this.deptName,
    required this.batchName,
    required this.universityName,
  });

  bool get isCR => role == 'CR';

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    role,
    batchId,
    deptName,
    batchName,
    universityName,
  ];
}
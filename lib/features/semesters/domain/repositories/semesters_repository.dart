import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/resource_entity.dart';
import '../entities/semesters_entity.dart';
import '../entities/subject_entity.dart';

abstract class SemestersRepository {
  Future<Either<Failure, List<SemestersEntity>>> getSemesters();
  Future<Either<Failure, List<SubjectEntity>>> getSubjects(int semesterId);
  Future<Either<Failure, SubjectEntity>> addSubject(int semesterId, String name);
  Future<Either<Failure, void>> deleteSubject(int subjectId);
  Future<Either<Failure, List<ResourceEntity>>> getResources(int subjectId);
  Future<Either<Failure, void>> uploadResourceFile(int subjectId, String title, String filePath, String type);
  Future<Either<Failure, void>> deleteResource(int resourceId);
}

import 'package:cr_assist/core/error/exception_handler.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/api_endpoint.dart';
import '../models/resource_model.dart';
import '../models/semesters_model.dart';
import '../models/subject_model.dart';

abstract class SemestersDataSource {
  Future<List<SemestersModel>> getSemesters();
  Future<List<SubjectModel>> getSubjects(int semesterId);
  Future<SubjectModel> addSubject(int semesterId, String name);
  Future<void> deleteSubject(int subjectId);
  Future<List<ResourceModel>> getResources(int subjectId);
  Future<void> uploadResourceFile({
    required int subjectId,
    required String title,
    required String filePath,
    required String type,
  });
  Future<void> deleteResource(int resourceId);
}

class SemestersDataSourceImplement implements SemestersDataSource {
  final DioClient dioClient;

  SemestersDataSourceImplement({required this.dioClient});

  @override
  Future<List<SemestersModel>> getSemesters() async {
    try {
      final response = await dioClient.get(ApiEndpoint.semesters);
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => SemestersModel.fromJson(json)).toList();
    } catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  @override
  Future<List<SubjectModel>> getSubjects(int semesterId) async {
    try {
      final response = await dioClient.get(ApiEndpoint.subjects(semesterId));
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => SubjectModel.fromJson(json)).toList();
    } catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  @override
  Future<SubjectModel> addSubject(int semesterId, String name) async {
    try {
      final response = await dioClient.post(
        ApiEndpoint.addSubject(semesterId),
        data: {'name': name},
      );
      return SubjectModel.fromJson(response.data);
    } catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  @override
  Future<void> deleteSubject(int subjectId) async {
    try {
      await dioClient.delete(ApiEndpoint.deleteSubject(subjectId));
    } catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  @override
  Future<List<ResourceModel>> getResources(int subjectId) async {
    try {
      final response = await dioClient.get(ApiEndpoint.resources(subjectId));
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => ResourceModel.fromJson(json)).toList();
    } catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  @override
  Future<void> uploadResourceFile({
    required int subjectId,
    required String title,
    required String filePath,
    required String type,
  }) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'title': title,
        'type': type,
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      await dioClient.post(
        ApiEndpoint.uploadResource(subjectId),
        data: formData,
      );
    } catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  @override
  Future<void> deleteResource(int resourceId) async {
    try {
      await dioClient.delete(ApiEndpoint.deleteResource(resourceId));
    } catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }
}

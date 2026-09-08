import 'package:dio/dio.dart';

abstract class SettingsDataSource {
  // TODO: Define Data Source methods here
  // Future<List<SettingsModel>> getUsers();
}

class SettingsDataSourceImplement implements SettingsDataSource {
  final Dio dio;

  SettingsDataSourceImplement({required this.dio});

  // TODO: Implement Data Source methods
  // @override
  // Future<List<SettingsModel>> getUsers() async {
  //   final response = await dio.get('http://localhost:3000/users');
  //
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = response.data;
  //     return data.map((json) => SettingsModel.fromJson(json as Map<String, dynamic>)).toList();
  //   } else {
  //     throw DioException(
  //       requestOptions: response.requestOptions,
  //       response: response,
  //       type: DioExceptionType.badResponse,
  //     );
  //   }
  // }
}

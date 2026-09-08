import 'package:dio/dio.dart';

abstract class NoticeDataSource {
  // TODO: Define Data Source methods here
  // Future<List<NoticeModel>> getUsers();
}

class NoticeDataSourceImplement implements NoticeDataSource {
  final Dio dio;

  NoticeDataSourceImplement({required this.dio});

  // TODO: Implement Data Source methods
  // @override
  // Future<List<NoticeModel>> getUsers() async {
  //   final response = await dio.get('http://localhost:3000/users');
  //
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = response.data;
  //     return data.map((json) => NoticeModel.fromJson(json as Map<String, dynamic>)).toList();
  //   } else {
  //     throw DioException(
  //       requestOptions: response.requestOptions,
  //       response: response,
  //       type: DioExceptionType.badResponse,
  //     );
  //   }
  // }
}

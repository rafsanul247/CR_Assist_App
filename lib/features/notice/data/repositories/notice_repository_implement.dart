import '../../domain/repositories/notice_repository.dart';
import '../data_sources/notice_data_source.dart';

class NoticeRepositoryImplement implements NoticeRepository {
  final NoticeDataSource dataSource;

  NoticeRepositoryImplement({required this.dataSource});

  // TODO: Implement Repository methods
  // @override
  // Future<Either<Failure, List<NoticeEntity>>> getUsers() async {
  //   try {
  //     final result = await dataSource.getUsers();
  //     return right(result);
  //   } on DioException catch (e) {
  //     return left(ServerFailure(e.message ?? 'Server error'));
  //   } catch (e) {
  //     return left(ServerFailure('Unexpected error: ${e.toString()}'));
  //   }
  // }
}

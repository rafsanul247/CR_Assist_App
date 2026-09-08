import '../../domain/repositories/settings_repository.dart';
import '../data_sources/settings_data_source.dart';

class SettingsRepositoryImplement implements SettingsRepository {
  final SettingsDataSource dataSource;

  SettingsRepositoryImplement({required this.dataSource});

  // TODO: Implement Repository methods
  // @override
  // Future<Either<Failure, List<SettingsEntity>>> getUsers() async {
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

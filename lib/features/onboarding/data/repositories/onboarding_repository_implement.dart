import '../../domain/repositories/onboarding_repository.dart';
import '../../data/data_sources/onboarding_data_source.dart';

class OnboardingRepositoryImplement implements OnboardingRepository {
  final OnboardingDataSource dataSource;
    OnboardingRepositoryImplement({required this.dataSource});
}

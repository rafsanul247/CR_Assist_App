import 'package:get/get.dart';
import '../../../domain/usecases/settings_usecase.dart';

class SettingsController extends GetxController {
  final SettingsUseCase useCase;

  SettingsController(this.useCase);

  // TODO: Add your observable variables here
  // var users = <SettingsEntity>[].obs;
  // var isLoading = false.obs;
  // var errorMessage = ''.obs;

  // TODO: Add your controller methods here
  // Future<void> fetchData() async {
  //   isLoading.value = true;
  //   errorMessage.value = '';
  //
  //   final result = await useCase.getUsers(); // Update method name as needed
  //
  //   result.fold(
  //     (failure) => errorMessage.value = failure.message,
  //     (data) => users.value = data,
  //   );
  //
  //   isLoading.value = false;
  // }
}

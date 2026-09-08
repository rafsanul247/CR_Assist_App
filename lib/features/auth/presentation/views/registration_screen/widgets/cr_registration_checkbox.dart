import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CrRegistrationCheckbox extends StatelessWidget {
  const CrRegistrationCheckbox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final RegiCheckBoxController controller = Get.put(RegiCheckBoxController());
    return Row(
      children: [
        Obx(() {
          return Checkbox(value: controller.isSelected.value, onChanged: (value) {
            controller.toggleSelected();
          });
        }),
        Expanded(
            child: Text("Check if you are a CR", textAlign: TextAlign.start, style: Theme
                .of(context)
                .textTheme
                .labelLarge,))
      ],
    );
  }
}

// CONTROLLER
class RegiCheckBoxController extends GetxController {
  var isSelected = false.obs;

  void toggleSelected() {
    isSelected.value = !isSelected.value;
  }
}
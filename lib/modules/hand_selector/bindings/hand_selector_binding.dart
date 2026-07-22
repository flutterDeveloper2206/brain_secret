import 'package:get/get.dart';
import '../controllers/hand_selector_controller.dart';

class HandSelectorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HandSelectorController>(() => HandSelectorController());
  }
}

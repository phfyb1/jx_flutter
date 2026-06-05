import 'package:get/get.dart';
import '../controller/DangerSourceController.dart';

class DangerSourceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DangerSourceController());
  }
}

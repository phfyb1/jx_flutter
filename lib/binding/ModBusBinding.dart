import 'package:get/get.dart';
import '../controller/ModBusController.dart';

class ModBusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ModBusControler>(() => ModBusControler());
  }
}
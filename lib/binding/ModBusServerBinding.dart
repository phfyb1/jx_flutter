import 'package:get/get.dart';
import '../controller/ModBusServerController.dart';

class ModBusServerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ModBusServerControler>(() => ModBusServerControler());
  }
}
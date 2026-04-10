import 'package:get/get.dart';
import '../controller/AlarmToolController.dart';

class AlarmToolBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AlarmToolController>(() => AlarmToolController());
  }
}
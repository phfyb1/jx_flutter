import 'package:get/instance_manager.dart';
import 'package:jx_flutter/pages/HydrogenPage.dart';
import '../controller/HydrogenController.dart';
// import '../controller/HJ212ControllerNew.dart';

class HydrogenBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<HydrogenController>(() => HydrogenController());
    // Get.lazyPut<HJ212ControllerNew>(() => HJ212ControllerNew());
  }
}
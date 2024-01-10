import 'package:get/instance_manager.dart';
import '../controller/HJ212Controller.dart';
// import '../controller/HJ212ControllerNew.dart';

class HJ212Binding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<HJ212Controller>(() => HJ212Controller());
    // Get.lazyPut<HJ212ControllerNew>(() => HJ212ControllerNew());
  }
}
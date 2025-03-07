import 'package:get/instance_manager.dart';
import '../controller/MQTTSQLController.dart';
// import '../controller/HJ212ControllerNew.dart';

class MQTTSQLBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MQTTSQLController>(() => MQTTSQLController());
    // Get.lazyPut<HJ212ControllerNew>(() => HJ212ControllerNew());
  }
}

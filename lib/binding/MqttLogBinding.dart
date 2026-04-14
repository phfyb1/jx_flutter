import 'package:get/get.dart';
import 'package:jx_flutter/controller/MqttLogController.dart';

class MqttLogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MqttLogController>(() => MqttLogController());
  }
}

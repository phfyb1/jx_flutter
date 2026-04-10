import 'package:get/get.dart';
import '../controller/SensorAlarmRuleController.dart';

class SensorAlarmRuleBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SensorAlarmRuleController>(() => SensorAlarmRuleController());
  }
}
import 'package:get/get.dart';

import '../controller/JT809Controller.dart';

class JT809Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JT809Controller>(() => JT809Controller());
  }
}
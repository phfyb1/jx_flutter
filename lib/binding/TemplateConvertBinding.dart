import 'package:get/get.dart';
import '../controller/TemplateConvertController.dart';

class TemplateConvertBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TemplateConvertController());
  }
}

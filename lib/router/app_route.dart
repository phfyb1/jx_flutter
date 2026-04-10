import 'package:get/get.dart';

import '../binding/HJ212Binding.dart';
import '../binding/HomeBinding.dart';
import '../binding/JT809Binding.dart';
import '../binding/ModBusBinding.dart';
import '../binding/ModBusServerBinding.dart';
import '../pages/HJ212Page.dart';
import '../pages/HomePage.dart';
import '../pages/JT809Page.dart';
import '../pages/ModBusPage.dart';
import '../pages/HydrogenPage.dart';
import '../binding/HydrogenBinding.dart';
import '../pages/ModBusServerPage.dart';
import '../binding/MQTTSQLBinding.dart';
import '../pages/MQTTSQLPage.dart';
import '../binding/AlarmToolBinding.dart';
import '../pages/AlarmToolPage.dart';
import '../binding/SensorAlarmRuleBinding.dart';
import '../pages/SensorAlarmRulePage.dart';

abstract class AppRoutes {
  static const Home = '/home';
  static const JT809 = '/JT809';
  static const HJ212 = '/HJ212';
  static const ModBus = '/ModBus';
  static const ModBusServer = '/ModBusServer';
  static const Hydrogen = '/Hydrogen'; // 氢能源
  static const MQTT = '/MQTT';
  static const AlarmTool = '/AlarmTool';
  static const SensorAlarmRule = '/SensorAlarmRule'; // 传感器报警规则

  // 静态路由表
  static final routes = [
    GetPage(name: Home, page: () => HomePage(), binding: HomeBinding()),
    GetPage(name: JT809, page: () => JT809Page(), binding: JT809Binding()),
    GetPage(name: HJ212, page: () => HJ212Page(), binding: HJ212Binding()),
    GetPage(name: ModBus, page: () => ModBusPage(), binding: ModBusBinding()),
    GetPage(
        name: Hydrogen, page: () => HydrogenPage(), binding: HydrogenBinding()),
    GetPage(
        name: ModBusServer,
        page: () => ModBusServerPage(),
        binding: ModBusServerBinding()),
    GetPage(name: MQTT, page: () => MQTTPage(), binding: MQTTSQLBinding()),
    GetPage(
        name: AlarmTool,
        page: () => AlarmToolPage(),
        binding: AlarmToolBinding()),
    GetPage(
        name: SensorAlarmRule,
        page: () => SensorAlarmRulePage(),
        binding: SensorAlarmRuleBinding()),
  ];
}

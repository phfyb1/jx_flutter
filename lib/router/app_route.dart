import 'package:get/get.dart';

import '../binding/HJ212Binding.dart';
import '../binding/HomeBinding.dart';
import '../binding/JT809Binding.dart';
import '../binding/ModBusBinding.dart';
import '../pages/HJ212Page.dart';
import '../pages/HomePage.dart';
import '../pages/JT809Page.dart';
import '../pages/ModBusPage.dart';

abstract class AppRoutes{
  static const Home = '/home';
  static const JT809 = '/JT809';
  static const HJ212 = '/HJ212';
  static const ModBus = '/ModBus';
  // 静态路由表
  static final routes=[
    GetPage(name:Home, page: ()=>HomePage(),binding: HomeBinding()),
    GetPage(name:JT809, page: ()=>JT809Page(),binding: JT809Binding()),
    GetPage(name: HJ212, page: ()=>HJ212Page(),binding: HJ212Binding()),
    GetPage(name: ModBus, page: ()=>ModBusPage(),binding: ModBusBinding()),
  ];
}
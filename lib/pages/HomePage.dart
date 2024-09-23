import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jx_flutter/controller/HomeController.dart';
import 'package:jx_flutter/router/app_route.dart';

var height;
var width;
HomeControler controller = Get.put(HomeControler());

// class HomePage extends GetView<HomeControler> {
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('协议解析'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            nameButton('JT809解析', AppRoutes.JT809),
            nameButton('HJ212造数据', AppRoutes.HJ212),
            nameButton('ModBus解析', AppRoutes.ModBus),
            nameButton('加氢站建表SQL生成', AppRoutes.Hydrogen),
            // nameButton('test', AppRoutes.HJ212),
          ],
        ),
      ),
    );
  }
}


nameButton(String name, String route) {
  return Container(
    height: height * 0.1,
    width: width * 0.2,
    padding: const EdgeInsets.all(10.0),
    child: ElevatedButton(
        onPressed: () => Get.toNamed(route), child: Text(name)),
  );
}

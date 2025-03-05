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
          children:nameButtonList,
          // children: <Widget>[
          //   nameButtonArea()
          // ],
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
    child:
        ElevatedButton(onPressed: () => Get.toNamed(route), child: Text(name)),
  );
}

//存入nameButton的数组
List<Widget> nameButtonList= [
    nameButton('JT809解析', AppRoutes.JT809),
    nameButton('HJ212造数据', AppRoutes.HJ212),
    nameButton('ModBus解析', AppRoutes.ModBus),
    nameButton('加氢站建表SQL生成', AppRoutes.Hydrogen),
    // nameButton('ModBusServer解析', AppRoutes.ModBusServer),
  ];

//nameButtonArea：将nameButtonList根据序号的单双，分成两列显示nameButton，单靠左，双靠右，并返回一个Column
Column nameButtonArea() {
  List<Widget> leftColumn = [];
  List<Widget> rightColumn = [];
  for (int i = 0; i < nameButtonList.length; i++) {
    if (i % 2 == 0) {
      leftColumn.add(nameButtonList[i]);
    } else {
      rightColumn.add(nameButtonList[i]);
    }
  }
  return Column(
    children: [
      Row(
        children: [
          Expanded(child: Column(children: leftColumn)),
          Expanded(child: Column(children: rightColumn)),
        ],
      ),
    ],
  );
}


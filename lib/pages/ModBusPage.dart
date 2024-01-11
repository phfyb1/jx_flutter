// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, non_constant_identifier_names, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, prefer_typing_uninitialized_variables, unused_import, file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/ModBusController.dart';
import '../unit/editInput.dart';

var height;
var width;

final textController = TextEditingController();

class ModBusPage extends GetView<ModBusControler> {
  const ModBusPage({super.key});

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text('ModBus解析'),
          leading: IconButton(
            onPressed: () {
              // controller.clean();
              Get.back();
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
              child: Column(children: [
            choose(),
            Obx(() => adress('起始地址'),),
            Container(
                height: height * 0.1,
                alignment: Alignment.center,
                child: Data()),
            Text('解析数据结果'),
            Text(
              '若有显示问题，请按F12看后台打印的结果',
              style: TextStyle(fontSize: 10),
            ),
            Obx(() => ListView.builder(
                  padding: EdgeInsets.only(left: width * 0.1),
                  itemCount: controller.dataResultList.length,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Text(controller.dataResultList[index]);
                  },
                )),
          ])),
        ));
  }

  Widget adress(string) {
    if (controller.standard.value==true) {
      return Container(
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              width: width * 0.1,
            ),
            Container(
              width: 100,
              child: Text(
                '${string}',
                style: TextStyle(color: Colors.green),
              ),
            ),
            Container(
                width: 150,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0x30cccccc),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    fillColor: Color(0x30cccccc),
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0x00FF0000)),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0x00000000)),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                  ),
                  onChanged: (value) => controller.startAdress.value = value,
                  // onSubmitted: (value) =>
                  //     controller.startAdress.value = value as int,
                )),
          ]),
          Container(height: 10),
          // Obx(() => showType()),
        ],
      ),
    );
    }
    return Container(height: 10);
  }

  Widget Data() {
    return Container(
      height: height * 0.1,
      width: width * 0.8,
      child: TextField(
        controller: textController,
        decoration: InputDecoration(
            fillColor: Color(0x30cccccc),
            filled: true,
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0x00FF0000)),
                borderRadius: BorderRadius.all(Radius.circular(100))),
            hintText: '请输入数据',
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0x00000000)),
                borderRadius: BorderRadius.all(Radius.circular(100))),
            suffixIcon: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  textController.clear();
                  controller.clean();
                })),
        onSubmitted: (value) {
          controller.clean();
          controller.data.value = controller.main(value);
        },
        // onChanged: (value) {
        //   controller.clean();
        //   controller.data.value = controller.main(value);
        // },
      ),
    );
  }

  Widget choose() {
    return Container(
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              width: width * 0.1,
            ),
            Container(
              width: 100,
              child: Text(
                '标准ModBus',
                style: TextStyle(color: Colors.green),
              ),
            ),
            Container(
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color(0x30cccccc),
              ),
              child: DropdownButtonFormField(
                value: true,
                items: [
                  DropdownMenuItem(value: true, child: Text('是')),
                  DropdownMenuItem(value: false, child: Text('否')),
                ],
                onChanged: (value) {
                  controller.standard.value = value!;
                  // print('是否标准modbus:${controller.standard.value}，选择的：${value}');
                  // Get.snackbar('title', '${controller.mp_type.value}');
                },
                borderRadius: BorderRadius.circular(20),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0x30cccccc),
                  contentPadding: EdgeInsets.only(left: 10),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0x00FF0000)),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                ),
              ),
            ),
          ]),
          Container(height: 10),
          // Obx(() => showType()),
        ],
      ),
    );
  }
}

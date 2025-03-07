// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_import, unnecessary_import, sized_box_for_whitespace, avoid_unnecessary_containers, non_constant_identifier_names, file_names

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:jx_flutter/controller/MQTTSQLController.dart';
import 'package:jx_flutter/util/EditInput.dart';

class MQTTPage extends GetView<MQTTSQLController> {
  // class HJ212Page extends GetView<HJ212ControllerNew> {
  const MQTTPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MQTT SQL'),
      ),
      body: SingleChildScrollView(
          child: Container(
        width: MediaQuery.of(context).size.width,
        // width: 1034,
        child: Column(
          children: [
            Text('如果默认项不需要变化可以不填',
                style: TextStyle(color: Colors.purple, fontSize: 20)),
            MessageRow('username', (value) {
              controller.userName.value = value;
            }),
            MessageRow('password', (value) {
              controller.pwd.value = value;
            }, hintText: '默认username+hthj'),
            MessageRow('clientId', (value) {
              controller.clientId.value = value;
            }, hintText: '默认同username'),
            MessageRow('salt', (value) {
              controller.salt.value = value;
            }, hintText: '默认iots'),
            MessageRow('access', (value) {
              controller.access.value = value;
            }, hintText: '1:subscribe,2: publish, 3: pubsub,默认2'),
            MessageRow('topic', (value) {
              controller.topic.value = value;
            }, hintText: '默认 /iot/xpsj/v2/%c/thirdParty/realtimeData'),
            MessageRow('remark', (value) {
              controller.remark.value = value;
            }, hintText: '账号给谁用的'),
            // Container(
            //   // width: MediaQuery.of(context).size.width * 0.2,
            //   width: 1034 * 0.2,
            //   // height: MediaQuery.of(context).size.height * 0.1,
            //   height: 644 * 0.1,
            //   child: ElevatedButton(
            //     onPressed: () {
            //       // Get.snackbar('with', '${MediaQuery.of(context).size.width}');
            //       controller.packaging();
            //     },
            //     child: Text('生成SQL'),
            //   ),
            // )
            Container(
              // width: MediaQuery.of(context).size.width * 0.2,
              width: 1034 * 0.2,
              // height: MediaQuery.of(context).size.height * 0.1,
              height: 644 * 0.1,
              child: ElevatedButton(
                onPressed: () {
                  // Get.snackbar('with', '${MediaQuery.of(context).size.width}');
                  controller.sha256(
                      controller.salt.value, controller.pwd.value);
                  controller.ClientId(controller.clientId.value);
                  controller.show.value
                      ? controller.clean()
                      : controller.product();
                },
                child: Obx(() => Text(controller.buttonText.value)),
              ),
            ),
            Container(
              // padding: EdgeInsets.only(left:1034*0.15),
              alignment: Alignment.centerLeft,
              width: 1034,
              child: Obx(() => showType()),
            ),
          ],
        ),
      )),
    );
  }

  Widget MessageRow(name, onchanged, {hintText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          child: Text(
            name,
            style: TextStyle(color: Colors.green),
          ),
        ),
        editInput(hintText: hintText ?? name, onChanged: onchanged),
      ],
    );
  }

  Widget showType() {
    if (controller.show.value) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Text(
        //   '若有显示问题，请按F12看后台打印的结果',
        //   style: TextStyle(fontSize: 10),
        // ),
        // Obx(() => Text('${controller.data}')),
        Container(alignment: Alignment.centerLeft, child: Obx(() => SQLText())),
        Container(height: 10),
      ]);
    }
    return Container(
      width: width,
      height: 10,
    );
  }

  SQLText() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SelectableText(controller.SQL.value),
          ),
        ]);
  }
  // Widget choose() {
  //   return Container(
  //     child: Column(
  //       children: [
  //         Row(mainAxisAlignment: MainAxisAlignment.start, children: [
  //           Container(
  //             width: 100,
  //             child: Text('mp_type',style: TextStyle(color: Colors.green),),
  //           ),
  //           Container(
  //             width: 150,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(20),
  //               color: Color(0x30cccccc),
  //             ),
  //             child: DropdownButtonFormField(
  //               value: 'Rtd',
  //               items: [
  //                 DropdownMenuItem(value: 'Rtd', child: Text('Rtd')),
  //                 DropdownMenuItem(value: 'Avg', child: Text('Avg')),
  //               ],
  //               onChanged: (value) {
  //                 controller.mp_type.value = value ?? 'Rtd';
  //                 // Get.snackbar('title', '${controller.mp_type.value}');
  //               },
  //               borderRadius: BorderRadius.circular(20),
  //               decoration: InputDecoration(
  //                 border: InputBorder.none,
  //                 fillColor: Color(0x30cccccc),
  //                 contentPadding: EdgeInsets.only(left: 10),
  //                 enabledBorder: OutlineInputBorder(
  //                     borderSide: BorderSide(color: Color(0x00FF0000)),
  //                     borderRadius: BorderRadius.all(Radius.circular(20))),
  //               ),
  //             ),
  //           ),
  //         ]),
  //         Container(height: 10),
  //         Obx(() => showType()),
  //       ],
  //     ),
  //   );
  // }

  // Widget showType() {
  //   if (controller.mp_type.value == 'Avg') {
  //     return Column(children: [
  //       Row(mainAxisAlignment: MainAxisAlignment.start, children: [
  //         Container(
  //           width: 100,
  //           child: Text('type',style: TextStyle(color: Colors.green),),
  //         ),
  //         Container(
  //           width: 150,
  //           decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(20),
  //               color: Color(0x30cccccc),
  //             ),
  //           child: DropdownButtonFormField(
  //             value: 'hour',
  //             items: [
  //               DropdownMenuItem(value: 'hour', child: Text('hour')),
  //               DropdownMenuItem(value: 'day', child: Text('day')),
  //             ],
  //             onChanged: (value) {
  //               controller.type.value = value ?? 'hour';
  //             },
  //             borderRadius: BorderRadius.circular(20),
  //             decoration: InputDecoration(
  //               border: InputBorder.none,
  //               fillColor: Color(0x30cccccc),
  //               contentPadding: EdgeInsets.only(left: 10),
  //               enabledBorder: OutlineInputBorder(
  //                   borderSide: BorderSide(color: Color(0x00FF0000)),
  //                   borderRadius: BorderRadius.all(Radius.circular(20))),
  //             ),
  //           ),
  //         ),
  //       ]),
  //       Container(height: 10),
  //     ]);
  //   }
  //   return Container();
  // }
}

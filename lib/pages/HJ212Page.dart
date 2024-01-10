// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_import, unnecessary_import, sized_box_for_whitespace, avoid_unnecessary_containers, non_constant_identifier_names, file_names

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:jx_flutter/controller/HJ212Controller.dart';
import 'package:jx_flutter/unit/editInput.dart';

class HJ212Page extends GetView<HJ212Controller> {
  // class HJ212Page extends GetView<HJ212ControllerNew> {
  const HJ212Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HJ212造数据'),
      ),
      body: SingleChildScrollView(
        child: Container(
        width: MediaQuery.of(context).size.width,
        // width: 1034,
        child: Column(
          children: [
            // editInput(
            //     hintText: 'metric',
            //     onChanged: (value) {
            //       controller.metric.value = value;
            //     }),
            MessageRow('metric', (value) {
              controller.metric.value = value;
            }),
            // editInput(
            //     hintText: 'timeStart',
            //     onChanged: (value) {
            //       controller.timeStart.value = value;
            //     }),
            MessageRow('startTime', (value) {
              controller.timeStart.value = value;
              // Get.snackbar('time', '${controller.timeStart.value}');
            },hintText: 'YYYY-MM-DD HH:mm:ss'),
            // editInput(
            //     hintText: 'valueMin',
            //     onChanged: (value) {
            //       controller.valueMin.value = value;
            //     }),
            MessageRow('valueMin', (value) {
              controller.valueMin.value = value;
            }),
            // editInput(
            //     hintText: 'valueMax',
            //     onChanged: (value) {
            //       controller.valueMax.value = value;
            //     }),
            MessageRow('valueMax', (value) {
              controller.valueMax.value = value;
            }),
            // editInput(
            //     hintText: 'mn',
            //     onChanged: (value) {
            //       controller.mn.value = value;
            //     }),
            MessageRow('mn', (value) {
              controller.mn.value = value;
            }),
            // editInput(
            //     hintText: 'ec',
            //     onChanged: (value) {
            //       controller.ec.value = value;
            //     }),
            MessageRow('ec', (value) {
              controller.ec.value = value;
            }),
            // editInput(
            //     hintText: 'mp',
            //     onChanged: (value) {
            //       controller.mp.value = value;
            //     }),
            MessageRow('mp', (value) {
              controller.mp.value = value;
            }),
            // editInput(
            //     hintText: 'md',
            //     onChanged: (value) {
            //       controller.md.value = value;
            //     }),
            MessageRow('md', (value) {
              controller.md.value = value;
            }),
            Container(
              padding: EdgeInsets.only(left:1034*0.15),
              alignment: Alignment.centerLeft,
              width: 934,
              child: choose(),
            ),
            // editInput(
            //     hintText: 'day',
            //     onChanged: (value) {
            //       controller.day.value = value;
            //     }),
            MessageRow('day', (value) {
              controller.day.value = value;
            }),
            // editInput(
            //     hintText: 'fileName',
            //     onChanged: (value) {
            //       controller.fileName.value = value;
            //     }),
            MessageRow('fileName', (value) {
              controller.fileName.value = value;
            }),
            Container(
              // width: MediaQuery.of(context).size.width * 0.2,
              width: 1034*0.2,
              // height: MediaQuery.of(context).size.height * 0.1,
              height: 644*0.1,
              child: ElevatedButton(
                onPressed: () {
                  // Get.snackbar('with', '${MediaQuery.of(context).size.width}');
                  controller.product();
                },
                child: Text('生成数据'),
              ),
            )
          ],
        ),
      )
      ),
    );
  }

  Widget MessageRow(name, onchanged,{hintText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          child: Text(name,style: TextStyle(color: Colors.green),),
        ),
        editInput(hintText: hintText??name, onChanged: onchanged),
      ],
    );
  }

  Widget choose() {
    return Container(
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              width: 100,
              child: Text('mp_type',style: TextStyle(color: Colors.green),),
            ),
            Container(
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color(0x30cccccc),
              ),
              child: DropdownButtonFormField(
                value: 'Rtd',
                items: [
                  DropdownMenuItem(value: 'Rtd', child: Text('Rtd')),
                  DropdownMenuItem(value: 'Avg', child: Text('Avg')),
                ],
                onChanged: (value) {
                  controller.mp_type.value = value ?? 'Rtd';
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
          Obx(() => showType()),
        ],
      ),
    );
  }

  Widget showType() {
    if (controller.mp_type.value == 'Avg') {
      return Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
            width: 100,
            child: Text('type',style: TextStyle(color: Colors.green),),
          ),
          Container(
            width: 150,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color(0x30cccccc),
              ),
            child: DropdownButtonFormField(
              value: 'hour',
              items: [
                DropdownMenuItem(value: 'hour', child: Text('hour')),
                DropdownMenuItem(value: 'day', child: Text('day')),
              ],
              onChanged: (value) {
                controller.type.value = value ?? 'hour';
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
      ]);
    }
    return Container();
  }
}

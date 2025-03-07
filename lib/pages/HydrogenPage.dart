// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_import, unnecessary_import, sized_box_for_whitespace, avoid_unnecessary_containers, non_constant_identifier_names, file_names

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:jx_flutter/controller/HydrogenController.dart';
import 'package:jx_flutter/util/EditInput.dart';

class HydrogenPage extends GetView<HydrogenController> {
  // class HJ212Page extends GetView<HJ212ControllerNew> {
  const HydrogenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('加氢站建表SQL生成'),
      ),
      body: SingleChildScrollView(
          child: Container(
        width: MediaQuery.of(context).size.width,
        // width: 1034,
        child: Column(
          children: [
            Text(
              '请用英文输入',
              style: TextStyle(color: Colors.purple, fontSize: 20),
            ),
            Container(
              height: 20,
            ),
            MessageRow('username', (value) {
              controller.username.value = value;
            }, hintText: '给加氢站的用户名'),
            MessageRow('password', (value) {
              controller.password.value = value;
              // Get.snackbar('time', '${controller.timeStart.value}');
            }, hintText: '给加氢站的密码'),
            MessageRow('hydrogen_code', (value) {
              controller.hydrogen_code.value = value;
            }, hintText: '加氢站的编码'),
            MessageRow('hydrogen_gun_code', (value) {
              controller.hydrogen_gun_code.value = value;
            }, hintText: '加氢枪的编码，有多个用逗号隔开'),
            MessageRow('hydrogen_containers_num', (value) {
              controller.hydrogen_containers_num.value = value;
            }, hintText: '储氢容器的编码，有多个用逗号隔开'),

            Container(
              // width: MediaQuery.of(context).size.width * 0.2,
              width: 1034 * 0.2,
              // height: MediaQuery.of(context).size.height * 0.1,
              height: 644 * 0.1,
              child: ElevatedButton(
                onPressed: () {
                  // Get.snackbar('with', '${MediaQuery.of(context).size.width}');
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
            // Obx(() => showType()),
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

  // ButtonText(){
  //   if(controller.show.value){
  //     return Text('清空结果');
  //   }else{
  //     return Text('生成SQL');
  //   }
  // }

  Widget showType() {
    if (controller.show.value) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          '若有显示问题，请按F12看后台打印的结果',
          style: TextStyle(fontSize: 10),
        ),
        // Obx(() => Text('${controller.data}')),
        Container(
            alignment: Alignment.centerLeft,
            child: Obx(() => ListView.builder(
                  padding: EdgeInsets.only(left: width * 0.1, top: 10),
                  // padding: EdgeInsets.only(left: 10),
                  itemCount: controller.dataResultList.length,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    // return SelectableText(controller.dataResultList.value[index]);},
                    return SQLText(index);
                  },
                ))),
        Container(height: 10),
      ]);
    }
    return Container(
      width: width,
      height: 10,
    );
  }

  SQLText(index) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 180,
            child: Text(
              controller.sqlName.value[index],
              style: TextStyle(color: Colors.purple),
            ),
          ),
          Expanded(
            child: SelectableText(controller.dataResultList.value[index]),
          ),
        ]);
  }
}





// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jx_flutter/controller/HydrogenController.dart';
// import 'package:jx_flutter/util/EditInput.dart';
// var width;
// class HydrogenPage extends GetView<HydrogenController> {
//   const HydrogenPage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     width = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('加氢站建表SQL生成'),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           width: MediaQuery.of(context).size.width,
//           child: Column(
//             children: [
//               MessageRow('username', (value) {
//                 controller.username.value = value;
//               }, hintText: '给加氢站的用户名'),
//               MessageRow('password', (value) {
//                 controller.password.value = value;
//               }, hintText: '给加氢站的密码'),
//               MessageRow('hydrogen_code', (value) {
//                 controller.hydrogen_code.value = value;
//               }, hintText: '加氢站的编码'),
//               MessageRow('hydrogen_gun_code', (value) {
//                 controller.hydrogen_gun_code.value = value;
//               }, hintText: '加氢机的编码，有多个用逗号隔开'),
//               MessageRow('hydrogen_containers_num', (value) {
//                 controller.hydrogen_containers_num.value = value;
//               }, hintText: '储氢容器的编码，有多个用逗号隔开'),
//               Container(
//                 width: MediaQuery.of(context).size.width * 0.8,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     controller.product();
//                   },
//                   child: Text('生成SQL'),
//                 ),
//               ),
//               Obx(() => showType()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget MessageRow(String name, void Function(String) onChanged, {String? hintText}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           width: 100,
//           child: Text(name, style: TextStyle(color: Colors.green)),
//         ),
//         editInput(hintText: hintText ?? name, onChanged: onChanged),
//       ],
//     );
//   }

//   Widget showType() {
//     if (controller.show.value) {
//       return Column(children: [
//         Row(mainAxisAlignment: MainAxisAlignment.start, children: [
//           Container(
//             width: 100,
//             child: Text('type', style: TextStyle(color: Colors.green)),
//           ),
//           Text('SQL'),
//           Text(
//             '若有显示问题，请按F12看后台打印的结果',
//             style: TextStyle(fontSize: 10),
//           ),
//           Obx(() => ListView.builder(
//                 padding: EdgeInsets.only(left: width * 0.1),
//                 itemCount: controller.dataResultList.length,
//                 shrinkWrap: true,
//                 physics: ClampingScrollPhysics(),
//                 itemBuilder: (context, index) {
//                   return Text(controller.dataResultList[index]);
//                 },
//               )),
//         ]),
//         Container(height: 10),
//       ]);
//     }
//     return Container();
//   }
// }

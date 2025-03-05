// // ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, non_constant_identifier_names, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, prefer_typing_uninitialized_variables, unused_import, file_names

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controller/ModBusServerController.dart';
// import '../util/EditInput.dart';
// import '../util/ControllerUtils.dart' as utils;

// var height;
// var width;

// final textController = TextEditingController();

// class ModBusServerPage extends GetView<ModBusServerControler> {
//   const ModBusServerPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     height = MediaQuery.of(context).size.height;
//     width = MediaQuery.of(context).size.width;
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('ModBus解析'),
//           leading: IconButton(
//             onPressed: () {
//               // controller.clean();
//               Get.back();
//             },
//             icon: Icon(Icons.arrow_back),
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: Container(
//               child: Column(children: [
//             // choose(),
//             Container(
//                 height: height * 0.1,
//                 alignment: Alignment.center,
//                 child: Data()),
//             Text('解析数据结果'),
//             Text(
//               '若有显示问题，请按F12看后台打印的结果',
//               style: TextStyle(fontSize: 10),
//             ),
//             Obx(() => ListView.builder(
//                   padding: EdgeInsets.only(left: width * 0.1),
//                   itemCount: controller.dataResultList.length,
//                   shrinkWrap: true,
//                   physics: ClampingScrollPhysics(),
//                   itemBuilder: (context, index) {
//                     return widgetList(index,
//                         controller.dataResultList.value[index].toString());
//                   },
//                 )),
//           ])),
//         ));
//   }

//   Widget Data() {
//     return Container(
//       height: height * 0.1,
//       width: width * 0.8,
//       child: TextField(
//         controller: textController,
//         decoration: InputDecoration(
//             fillColor: Color(0x30cccccc),
//             filled: true,
//             enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Color(0x00FF0000)),
//                 borderRadius: BorderRadius.all(Radius.circular(100))),
//             hintText: '请输入数据',
//             focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Color(0x00000000)),
//                 borderRadius: BorderRadius.all(Radius.circular(100))),
//             suffixIcon: IconButton(
//                 icon: Icon(Icons.close),
//                 onPressed: () {
//                   textController.clear();
//                   controller.clean();
//                 })),
//         onSubmitted: (value) {
//           controller.clean();
//           controller.data.value = controller.main(value);
//         },
//       ),
//     );
//   }

// //创建widget列表，添加DaData,并在后面加上四个单选框
//   widgetList(index, str) {
//     print('index:${index},str:${str}');
//     var JX = '';
//     var widget = Container(
//           child: Row(
//             children: [
//               Flexible(
//                 flex: 1,
//                 child: Text('${str}'),
//               ),
//               SizedBox(width: 10),
//               Flexible(
//                 flex: 1,
//                 child: RadioListTile(
//                   title: Text('大端DCBA'),
//                   value: 1,
//                   groupValue: controller.chouse.value[index],
//                   onChanged: (value) {
//                     controller.chouse.value[index] = 1;
//                     JX = (utils.bigEndianToFloat(str)).toString();
//                     print('原始16进制 $str');
//                     print('字节序反转后 ${utils.bigEndianToFloat(str)}');
//                     print('转换后的浮点数：$JX');
//                   },
//                 ),
//               ),
//               Flexible(
//                 flex: 1,
//                 child: RadioListTile(
//                   title: Text('大端反转BADC'),
//                   value: 2,
//                   groupValue: controller.chouse.value[index],
//                   onChanged: (value) {
//                     controller.chouse.value[index] = 2;
//                     JX = (utils.bigEndianSwappedToFloat(str)).toString();
//                     print('原始16进制 $str');
//                     print('字节序反转后 ${utils.reverseByteOrderBig(str)}');
//                     print('转换后的浮点数：$JX');
//                   },
//                 ),
//               ),
//               Flexible(
//                 flex: 1,
//                 child: RadioListTile(
//                   title: Text('小端ABCD'),
//                   value: 3,
//                   groupValue: controller.chouse.value[index],
//                   onChanged: (value) {
//                     controller.chouse.value[index] = 3;
//                     JX = (utils.littleEndianToFloat(str)).toString();
//                     print('原始16进制 $str');
//                     print('字节序反转后 ${utils.reverseByteOrderBig(str)}');
//                     print('转换后的浮点数：$JX');
//                   },
//                 ),
//               ),
//               Flexible(
//                 flex: 1,
//                 child: RadioListTile(
//                   title: Text('小端反转CDAB'),
//                   value: 4,
//                   groupValue: controller.chouse.value[index],
//                   onChanged: (value) {
//                     controller.chouse.value[index] = 4;
//                     JX = (utils.littleEndianSwappedToFloat(str)).toString();
//                     print(JX);
//                     print('原始16进制 $str');
//                     print('字节序反转后 ${utils.reverseByteOrderLittle(str)}');
//                     print('转换后的浮点数：$JX');
//                   },
//                 ),
//               ),
//               SizedBox(width: 10),
//               Flexible(
//                 flex: 1,
//                 child: Container(color: Colors.blue),
//               ),
//             ],
//           ),
//         );

//     return widget;
//   }
// }

// // //创建widget列表，添加DaData,并在后面加上四个单选框
// // widgetList(str) {
// //   List<Widget> checkboxList = [];
// //   for (var i = 0; i < str.length; i++) {
// //     var JX = '';
// //     var widget = Container(
// //       child: Row(
// //         children: [
// //           Text('${str[i]}'),
// //           SizedBox(width: 10),
// //           RadioListTile(
// //             title: Text('大端DCBA'),
// //             value: 1,
// //             groupValue: 1,
// //             onChanged: (value) {
// //               JX = utils.bigEndianToFloat(str[i]);
// //             },
// //           ),
// //           RadioListTile(
// //             title: Text('大端反转BADC'),
// //             value: 2,
// //             groupValue: 2,
// //             onChanged: (value) {
// //               JX = utils.bigEndianSwappedToFloat(str[i]);
// //             },
// //           ),RadioListTile(
// //             title: Text('小端ABCD'),
// //             value: 3,
// //             groupValue: 3,
// //             onChanged: (value) {
// //               JX = utils.littleEndianToFloat(str[i]);
// //             },
// //           ),RadioListTile(
// //             title: Text('小端反转CDAB'),
// //             value: 4,
// //             groupValue: 4,
// //             onChanged: (value) {
// //               JX = utils.littleEndianSwappedToFloat(str[i]);
// //             },
// //           ),
// //           SizedBox(width: 10),
// //           Obx(() => Text('${JX}'),)
// //         ],
// //       ),
// //     );
// //     checkboxList.add(widget);
// //   }
// //   return checkboxList;
// // }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/ModBusServerController.dart';
import '../util/EditInput.dart';
import '../util/ControllerUtils.dart' as utils;

var height;
var width;

final textController = TextEditingController();

class ModBusServerPage extends GetView<ModBusServerControler> {
  const ModBusServerPage({super.key});

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text('ModBusServer解析'),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
              child: Column(children: [
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
                  controller.refresh();
                  return widgetList(
                      index, controller.dataResultList[index].toString());
                })),
                ])),
        ));
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
      ),
    );
  }

  Widget widgetList(index, str) {
    return Container(
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Text('${str}'),
          ),
          SizedBox(width: 10),
          ..._buildRadioButtons(index, str),
          SizedBox(width: 10),
          Flexible(
            flex: 1,
            child: Container(color: Colors.blue),
          ),
          Obx(
            () => Text('${controller.JXData.value[index]}'),
          )
        ],
      ),
    );
  }

  List<Widget> _buildRadioButtons(int index, String str) {
    return [
      _buildRadioButton(
        title: '大端DCBA',
        index: index,
        value: 1,
        onChanged: (value) {
          controller.chouse[index] = value;
          controller.JXData.value[index] = (utils.bigEndianToFloat(str));
          print('原始16进制 $str');
          print('字节序反转后 ${utils.bigEndianToFloat(str)}');
          print('转换后的浮点数：${controller.JXData.value[index]}');
        },
      ),
      _buildRadioButton(
        title: '大端反转BADC',
        index: index,
        value: 2,
        onChanged: (value) {
          controller.chouse[index] = value;
          controller.JXData.value[index] = (utils.bigEndianSwappedToFloat(str));
          print('原始16进制 $str');
          print('字节序反转后 ${utils.reverseByteOrderBig(str)}');
          print('转换后的浮点数：${controller.JXData.value[index]}');
        },
      ),
      _buildRadioButton(
        title: '小端ABCD',
        index: index,
        value: 3,
        onChanged: (value) {
          controller.chouse[index] = value;
          controller.JXData.value[index] = (utils.littleEndianToFloat(str));
          print('原始16进制 $str');
          print('字节序反转后 ${utils.reverseByteOrderBig(str)}');
          print('转换后的浮点数：${controller.JXData.value[index]}');
        },
      ),
      _buildRadioButton(
        title: '小端反转CDAB',
        index: index,
        value: 4,
        onChanged: (value) {
          controller.chouse[index] = value;
          controller.JXData.value[index] =
              (utils.littleEndianSwappedToFloat(str));
          print('原始16进制 $str');
          print('字节序反转后 ${utils.reverseByteOrderLittle(str)}');
          print('转换后的浮点数：${controller.JXData.value[index]}');
        },
      ),
    ];
  }

  Widget _buildRadioButton({
    required String title,
    required int index,
    required int value,
    required Function(Object?) onChanged,
  }) {
    return Flexible(
      flex: 1,
      child: RadioListTile(
        title: Text(title),
        value: value,
        groupValue: controller.chouse[index],
        // groupValue:value,
        onChanged: onChanged,
      ),
    );
  }
}

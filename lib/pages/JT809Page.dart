import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jx_flutter/controller/JT809Controller.dart';

var height;
var width;

final textController = TextEditingController();

class JT809Page extends GetView<JT809Controler> {
  const JT809Page({super.key});

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text('JT809解析'),
          leading: IconButton(
            onPressed: () {
              controller.clean();
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
            // Obx(() => Text('${controller.data}')),
            // Container(
            //     height: height * 0.8,
            //     width: width * 0.8,
            //     child:
            Obx(() => ListView.builder(
                      padding: EdgeInsets.only(left: width * 0.1),
                      itemCount: controller.dataResultList.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Text(controller.dataResultList[index]);
                      },
                    )
                // )
                ),
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
        // onChanged: (value) {
        //   controller.clean();
        //   controller.data.value = controller.main(value);
        // },
      ),
    );
  }
}

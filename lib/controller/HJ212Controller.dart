// ignore_for_file: unused_import, unnecessary_import, avoid_web_libraries_in_flutter, unused_local_variable, unrelated_type_equality_checks, unnecessary_new, avoid_print, prefer_typing_uninitialized_variables, non_constant_identifier_names, unnecessary_overrides, file_names

import 'dart:html';
import 'dart:math';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// import 'dart:js' as js;
import 'package:intl/intl.dart';
import '../util/ControllerUtils.dart' as utils;

class HJ212Controller extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  var metric = ''.obs;
  var timeStart = '2022-01-01 00:00:00'.obs;
  var valueMin = '0'.obs;
  var valueMax = '100'.obs;
  var mn = ''.obs;
  var ec = ''.obs;
  var mp = ''.obs;
  var md = ''.obs;
  var mp_type = 'Rtd'.obs;
  var type = 'hour'.obs;
  var day = '30'.obs;
  var fileName = 'TSDB'.obs;

  var line = 0.obs; //所需数据的行数
  var demo = ''; //单条数据

  var roundValue; //随机生成一个valueMin-valueMax之间的数据

  List<String> TSDBData = []; //组合后数据的存放数组

  getter() {
    print(
        'metric:${metric.value},timeStart:${timeStart.value},valueMin:${valueMin.value},valueMax:${valueMax.value},mn:${mn.value},ec:${ec.value},mp:${mp.value},md:${md.value},mpType:${mp_type.value}');
  }

  product() {
    // getter();
    lineC();
    // TSDBData.length = line;
    addPack();
    saveFile(TSDBData.join(''));
  }

  lineC() {

    // 如果mp_type.value为Rtd，则line.value的值为60*24*int.parse(day.value)
    if (mp_type.value == 'Rtd') {
      line.value = 60 * 24 * int.parse(day.value);
    } else {
      // 如果mp_type.value为hour，则line.value的值为24*int.parse(day.value)
      if (type.value == 'hour') {
        line.value = 24 * int.parse(day.value);
      } else {
        // 否则，line.value的值为int.parse(day.value)
        line.value = int.parse(day.value);
      }
    }

    // 打印line.value的值
    print('line: ${line.value}');
  }

  

  packaging(int time) {
    String demo =
        '${metric.value} $time ${utils.round(valueMin,valueMax)} mn=${mn.value} ec=${ec.value} mp=${mp.value} md=${md.value} mpType=${mp_type.value}\n';
    // print(demo);
    return demo;
  }

  addPack() {
    int endtime = 0;
    for (int index = 0; index < line.value; index++) {
      // print('循环次数: $index');
      int time;
      if (mp_type.value == 'Rtd') {
        // print('rtd');
        time = utils.dateStringToTimestamp(timeStart.value) + 60 * index;
      } else {
        // print('avg');
        if (type == 'hour') {
          // print('hour');
          time = utils.dateStringToTimestamp(timeStart.value) + 3600 * index;
        } else {
          // print('day');
          time = utils.dateStringToTimestamp(timeStart.value) + 3600 * 24 * index;
        }
      }
      endtime = time;
      // TSDBData[index] = packaging(time);
      TSDBData.add(packaging(time));
    }
    // print('endtime:${endtime}');
    // print('addPack:${TSDBData.length}');
  }

  saveFile(String text) {
    String data = text;
    String name = '$fileName.txt';
    exportRaw(data, name);
  }

// exportRaw(String data, String name) {
//   var blob = js.context.callMethod('Blob', [data]);
//   var url = js.context.callMethod('URL.createObjectURL', [blob]);

//   var a = js.context.callMethod('document.createElement', ['a']);
//   a.callMethod('setAttribute', ['href', url]);
//   a.callMethod('setAttribute', ['download', name]);

//   a.callMethod('click');
// }

  exportRaw(String text, String filename) {
    // print('text: ${text}');
    // 创建Blob对象
    Blob blob = new Blob([text]);

    // 生成下载链接
    AnchorElement anchorElement =
        new AnchorElement(href: Url.createObjectUrlFromBlob(blob));

    // 设置下载文件名
    anchorElement.download = filename;

    // 追加到document中
    document.body?.append(anchorElement);

    // 点击触发下载
    anchorElement.click();

    // 下载后移除
    anchorElement.remove();
  }


}



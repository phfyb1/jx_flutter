// ignore_for_file: unused_import, unnecessary_overrides, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_print, unrelated_type_equality_checks, unnecessary_brace_in_string_interps, file_names

import 'dart:math';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../util/ControllerUtils.dart' as utils;

class HomeControler extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  var metric = 'metric'.obs;
  var timeStart = '2022-01-01 00:00:00'.obs;
  var valueMin = '0'.obs;
  var valueMax = '100'.obs;
  var mn = 'MN'.obs;
  var ec = 'ec'.obs;
  var mp = 'mp'.obs;
  var md = 'md'.obs;
  var mp_type = 'Rtd'.obs;
  var type = 'hour'.obs;
  var day = '1'.obs;
  var fileName = 'TSDB'.obs;

  var line = 10; //所需数据的行数
  var demo = ''; //单条数据

  var roundValue; //随机生成一个valueMin-valueMax之间的数据

  List<String> TSDBData = []; //组合后数据的存放数组


  packaging(int time) {
    String demo =
        '${metric.value} $time ${utils.round(valueMin,valueMax)} mn=${mn.value} ec=${ec.value} mp=${mp.value} md=${md.value} mpType=${mp_type.value}\n';
    print(demo);
    return demo;
  }

  addPack() {
    int endtime = 0;
    for (int index = 0; index < line; index++) {
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
      TSDBData.add(packaging(time));
    }
    print('endtime:${endtime}');
    print('addPack:${TSDBData.length}');
  }
}

// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, non_constant_identifier_names, unnecessary_overrides, empty_statements, file_names

import 'package:get/get.dart';
import  '../util/ControllerUtils.dart' as utils;

class ModBusServerControler extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  var dataResult = '';
  var dataResultList = [].obs;
  var dataResultListString = [].obs;
  var data = ''.obs;
  // var BWresult = '';
  var BWresult = [];
  var BWresultList = [];
  var standard = true.obs;
  var DaData = '';
  var radioListValve = [].obs;
  var JXData = [].obs;
  var chouse = [].obs;

  void clean() {
    dataResult = '';
    data.value = '';
    dataResultList.value = [];
    BWresult = [];
    BWresultList = [];
  }

  void CleanChoose() {
    chouse.clear();
  }

//主函数
  main(str) {
    print('传参是：${str}');
    var result0 = '';
    var s = str.split('');
    for (var j = 0; j < str.length; j++) {
      if (j % 2 == 0) {
        result0 += s[j];
      } else {
        if (j == str.length - 1) {
          result0 += s[j];
        } else {
          result0 += s[j] + ' ';
        }
      }
    }
    // print(result0);
    var result1 = result0.split(' ');
    // print(result1);
    standardModBus(result1);
    //数据拆分

    print(dataResult);
    // data.value = dataResult;
    return dataResultList;
  }

//modbusserver的解析
  standardModBus(List<String> array) {
    // print('长度：'+ array.length);
    try {
      for (var i = 1; i < 6; i++) {
        switch (i) {
          case 1: //设备地址
            dataResultListString.add('设备地址: ${array[0]}\n');
            print('设备地址:, ${array[0]}');
            break;
          case 2: //功能码
            dataResultListString.add('功能码: ${utils.combination(array.sublist(1, 2))}\n');
            print('功能码: ${utils.combination(array.sublist(1, 2))}');
            break;
          case 3: //数据长度
            dataResultListString.add(
                '数据长度: ${utils.combination(array.sublist(2, 3))}字节\n');
            print(
                '数据长度: ${utils.combination(array.sublist(2, 3))}字节');
            break;
          case 4: //数据
            BWresult = array.sublist(3, array.length - 2);
            // print(BWresult.length);
            // dataResultList.add('数据: ${dataAlone(BWresult)}\n');
            dataAlone(BWresult);
            print('完整数据: ${utils.combination(BWresult)},长度：${BWresult.length}');
            // BWresult.forEach((element) { print(element); });
            break;
          case 5: //校验码
            dataResultListString.add(
                "\n校验码: ${utils.combination(array.sublist(array.length - 2, array.length))}");
            print(
                '校验码： ${utils.combination(array.sublist(array.length - 2, array.length))}');
            break;
          // default:
          //     print('报文：',result1[0],result1[1])
          //     break
        }
      }
      ;
    } catch (e) {
      print("错误信息：${e}");
    }
  }

//列出并解析单个数据的值
  dataAlone(List array) {
    for (var i = 0; i < array.length; i += 4) {
      try {
        chouse.add(1);
        JXData.add('');
        DaData =
            '${utils.combination(array.sublist(i, i + 4))}';
        // print('数据：${DaData}');
        dataResultList.add(DaData);
        // dataResultList.add(utils.combination(array.sublist(i, i + 4)));
        print('数据：${dataResultList}');
      } catch (e) {
        print("错误信息：${e}");
      }
    }
  }



  
  
}

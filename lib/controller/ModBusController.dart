// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, non_constant_identifier_names, unnecessary_overrides, empty_statements, file_names

import 'package:get/get.dart';

class ModBusControler extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  var dataResult = '';
  var dataResultList = [].obs;
  var data = ''.obs;
  // var BWresult = '';
  var BWresult = [];
  var BWresultList = [];
  var standard = true.obs;
  var DaData = '';
  var startAdress = '0'.obs;

  void clean() {
    dataResult = '';
    data.value = '';
    dataResultList.value = [];
    BWresult = [];
    BWresultList = [];
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
    if (standard.value) {
      standardModBus(result1);
    } else {
      offStandardModBus(result1);
    }
    //数据拆分

    print(dataResult);
    // data.value = dataResult;
    return dataResultList;
  }

//标准modbus协议的解析
  standardModBus(List<String> array) {
    // print('长度：'+ array.length);
    try {
      for (var i = 1; i < 6; i++) {
        switch (i) {
          case 1: //设备地址
            dataResultList.add('设备地址: ${array[0]}\n');
            print('设备地址:, ${array[0]}');
            break;
          case 2: //功能码
            dataResultList.add('功能码: ${combination(array.sublist(1, 2))}\n');
            print('功能码: ${combination(array.sublist(1, 2))}');
            break;
          case 3: //数据长度
            dataResultList.add(
                '数据长度: ${combination(array.sublist(2, 3))}，解析寄存器个数：${hexToDec(combination(array.sublist(2, 3))) / 2}\n');
            print(
                '数据长度: ${combination(array.sublist(2, 3))}，解析寄存器个数：${hexToDec(combination(array.sublist(2, 3))) / 2}');
            break;
          case 4: //数据
            BWresult = array.sublist(3, array.length - 2);
            print(BWresult.length);
            // dataResultList.add('数据: ${dataAlone(BWresult)}\n');
            dataAlone(BWresult);
            print('数据: ${combination(BWresult)}');
            break;
          case 5: //校验码
            dataResultList.add(
                "\n校验码: ${combination(array.sublist(array.length - 2, array.length))}");
            print(
                '校验码： ${combination(array.sublist(array.length - 2, array.length))}');
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

//非标准modbus协议的解析
  offStandardModBus(array) {
    try {
      for (var i = 1; i <= 6; i++) {
        switch (i) {
          case 1: //设备地址
            dataResultList.add('设备地址: ${array[0]}\n');
            print('设备地址:, ${array[0]}');
            break;
          case 2: //功能码
            dataResultList.add('功能码: ${combination(array.sublist(1, 2))}\n');
            print('功能码: ${combination(array.sublist(1, 2))}');
            break;
          case 3: //起始地址
            BWresult = array.sublist(2, 4);
            dataResultList.add('起始地址: ${combination(BWresult)}\n');
            // print(BWresult.length);
            // dataResultList.add('数据: ${dataAlone(BWresult)}\n');
            // dataAlone(BWresult);
            print('起始地址: ${combination(BWresult)}');
            break;
          case 4: //数据长度
            dataResultList.add(
                '数据长度: ${combination(array.sublist(4, 6))}，解析寄存器个数：${hexToDec(combination(array.sublist(4, 6))) / 4}\n');
            print(
                '数据长度: ${combination(array.sublist(4, 6))}，解析寄存器个数：${hexToDec(combination(array.sublist(4, 6))) / 4}');
            break;
          case 5:
            offDataAlone(array.sublist(6, 8));
            // dataResultList.add('数据: ${combination(array.sublist(6, 8))}\n');
            break;
          case 6: //校验码
            dataResultList.add(
                "\n校验码: ${combination(array.sublist(array.length - 2, array.length))}");
            print(
                '校验码： ${combination(array.sublist(array.length - 2, array.length))}');
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

//列出并解析单个地址的值
  dataAlone(List array) {
    var adress = int.parse(startAdress.value);
    for (var i = 0; i < array.length; i += 2) {
      try {
        DaData =
            '地址：${adress++}，数据：${combination(array.sublist(i, i + 2))}，解析：${hexToDec(combination(array.sublist(i, i + 2)))}';
        print(DaData);
        dataResultList.add(DaData);
      } catch (e) {
        print("错误信息：${e}");
      }
    }
  }

  //非标准modbus列出并解析单个地址的值
  offDataAlone(List array) {
    for (var i = 0; i < array.length; i += 2) {
      try {
        DaData =
            '地址：${hexToDec(combination(BWresult))+1}，数据：${combination(array.sublist(i, i + 2))}，解析：${hexToDec(combination(array.sublist(i, i + 2)))}';
        print(DaData);
        dataResultList.add(DaData);
      } catch (e) {
        print("错误信息：${e}");
      }
    }
  }

//将数组组合成字符串
  combination(a) {
    var message = '';
    for (var i = 0; i < a.length; i++) {
      message += a[i];
    }
    return message;
  }

//将数组组合成字符串
  combination2(a) {
    var message = '';
    for (var i = 0; i < a.length; i++) {
      if (i < a.length - 1) {
        message += a[i] + ' ';
      } else {
        message += a[i];
      }
    }
    return message;
  }

//转换为16进制
  String changetoHex(String hexString) {
    try {
      var str = '';
      hexString.split(' ').forEach((val) {
        str += String.fromCharCodes([int.parse(val, radix: 16)]);
      });
      return str;
    } catch (e) {
      print("转16进制错误信息：${e}");
      return '转16进制错误信息：${e}';
    }
  }

//16进制转换为10进制
  hexToDec(String hexString) {
    return int.parse(hexString, radix: 16);
  }
}

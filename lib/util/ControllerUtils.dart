// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:math';

import 'package:intl/intl.dart';

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

//字符串转换为16进制
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

//将数组组合成字符串后16进制转换为10进制
hexToDecCombination(List list) {
  return hexToDec(combination(list));
}

//将数组转成字符串后再转换为16进制
changetoHexCombination(List list) {
  return changetoHex(combination2(list));
}

//将YYYY-MM-DD HH:mm:ss格式转成秒级时间戳
dateStringToTimestamp(String dateStr) {
  var format = DateFormat('yyyy-MM-dd HH:mm:ss');
  var dateTime = format.parse(dateStr);
  return dateTime.millisecondsSinceEpoch / 1000;
}

//生成一个随机整数，范围在valueMin和valueMax之间
round(Min,Max) {
    int roundValue;
    roundValue = (Random().nextDouble() *
                (int.parse(Max.value) - int.parse(Min.value)) +
            int.parse(Min.value))
        .round();
    return roundValue.toString();
  }
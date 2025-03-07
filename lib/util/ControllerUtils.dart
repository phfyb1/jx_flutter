// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:math';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'dart:convert';

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
round(Min, Max) {
  int roundValue;
  roundValue =
      (Random().nextDouble() * (int.parse(Max.value) - int.parse(Min.value)) +
              int.parse(Min.value))
          .round();
  return roundValue.toString();
}

//将大端的16进制字符串转成32位浮点数
bigEndianToFloat(String hexString) {
  // 先进行字节序反转
  String reversedHex = BigreverseByteLittle(hexString);

  // 移除可能的0x前缀
  if (reversedHex.startsWith('0x')) {
    reversedHex = reversedHex.substring(2);
  }

  // 将16进制字符串转换为32位无符号整数
  final int hexValue = int.parse(reversedHex, radix: 16);

  // 创建一个ByteData来存储4字节整数
  final ByteData byteData = ByteData(4);
  byteData.setUint32(0, hexValue, Endian.big);

  // 将字节转换为浮点数
  return byteData.getFloat32(0, Endian.big);
}

//将大端字节交换的16进制字符串转成32位浮点数
bigEndianSwappedToFloat(String hexString) {
  // 先进行字节序反转
  String reversedHex = reverseByteOrderBig(hexString);

  // 移除可能的0x前缀
  if (reversedHex.startsWith('0x')) {
    reversedHex = reversedHex.substring(2);
  }

  // 将16进制字符串转换为32位无符号整数
  final int hexValue = int.parse(reversedHex, radix: 16);

  // 创建一个ByteData来存储4字节整数
  final ByteData byteData = ByteData(4);
  byteData.setUint32(0, hexValue, Endian.big);

  // 将字节转换为浮点数
  return byteData.getFloat32(0, Endian.big);
}

//将小端的16进制字符串转成32位浮点数
littleEndianToFloat(String hexString) {
  if (hexString.startsWith('0x')) {
    hexString = hexString.substring(2);
  }

  // 将16进制字符串转换为32位无符号整数
  final int hexValue = int.parse(hexString, radix: 16);

  // 创建一个ByteData来存储4字节整数
  final ByteData byteData = ByteData(4);
  byteData.setUint32(0, hexValue, Endian.big);

  // 将字节转换为浮点数
  return byteData.getFloat32(0, Endian.big);
}

//将小端字节交换的16进制字符串转成32位浮点数
littleEndianSwappedToFloat(String hexString) {
  // 先进行字节序反转
  String reversedHex = reverseByteOrderLittle(hexString);

  // 移除可能的0x前缀
  if (reversedHex.startsWith('0x')) {
    reversedHex = reversedHex.substring(2);
  }

  // 将16进制字符串转换为32位无符号整数
  final int hexValue = int.parse(reversedHex, radix: 16);

  // 创建一个ByteData来存储4字节整数
  final ByteData byteData = ByteData(4);
  byteData.setUint32(0, hexValue, Endian.big);

  // 将字节转换为浮点数
  return byteData.getFloat32(0, Endian.big);
}

// 小端字节序反转函数
String reverseByteOrderLittle(String hexString) {
  // 确保字符串长度是8的倍数（32位）
  if (hexString.length % 2 != 0) {
    hexString = '0' + hexString;
  }
  // 每两个字符作为一个字节，reverse这些字节
  List<String> bytes = [];
  for (int i = 0; i < hexString.length; i += 2) {
    bytes.add(hexString.substring(i, i + 2));
  }
  return '${bytes[2]}${bytes[3]}${bytes[0]}${bytes[1]}';
}

// 大端字节序反转函数
String reverseByteOrderBig(String hexString) {
  // 确保字符串长度是8的倍数（32位）
  if (hexString.length % 2 != 0) {
    hexString = '0' + hexString;
  }
  // 每两个字符作为一个字节，reverse这些字节
  List<String> bytes = [];
  for (int i = 0; i < hexString.length; i += 2) {
    bytes.add(hexString.substring(i, i + 2));
  }
  bytes = [bytes[2], bytes[3], bytes[0], bytes[1]];
  return bytes.reversed.join();
}

// 大端字节序反转函数
String BigreverseByteLittle(String hexString) {
  // 确保字符串长度是8的倍数（32位）
  if (hexString.length % 2 != 0) {
    hexString = '0' + hexString;
  }
  // 每两个字符作为一个字节，reverse这些字节
  List<String> bytes = [];
  for (int i = 0; i < hexString.length; i += 2) {
    bytes.add(hexString.substring(i, i + 2));
  }
  return bytes.reversed.join();
}

String sha256(String salt, String pwd) {
  var bytes = utf8.encode(salt + pwd);
  var digest = crypto.sha256.convert(bytes);
  return digest.toString();
}

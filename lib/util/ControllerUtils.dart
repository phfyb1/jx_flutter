// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'dart:convert';
import 'package:get/get.dart';
import 'dart:html' as html;
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

//将数组组合成字符串
combination(a) {
  var message = '';
  for (var i = 0; i < a.length; i++) {
    message += a[i];
  }
  return message;
}

Future<void> saveToFile(
    {required String content,
    required String fileName,
    String type = 'text/plain'}) async {
  try {
    if (kIsWeb) {
      // Web平台使用浏览器下载API
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes], type);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
      showSuccess('文件已开始下载: \$fileName');
    } else {
      // 移动平台使用文件系统
      final directory = await getApplicationDocumentsDirectory();
      final path = '\${directory.path}/\$fileName';
      final file = io.File(path);
      await file.writeAsString(content);
      showSuccess('文件已保存到: \$path');
    }
  } catch (e) {
    final errorMsg = '保存文件失败: \${e.toString()}\n文件名: \$fileName';
    showError(errorMsg);
  }
}

void showError(String message) {
  Get.snackbar(
    '错误',
    '',
    backgroundColor: Colors.red,
    colorText: Colors.white,
    messageText: SelectableText(
      message,
      style: TextStyle(color: Colors.white),
    ),
  );
}

void showSuccess(String message) {
  Get.snackbar(
    '成功',
    '',
    backgroundColor: Colors.green,
    colorText: Colors.white,
    messageText: SelectableText(
      message,
      style: TextStyle(color: Colors.white),
    ),
  );
}

void showWarning(String message) {
  Get.snackbar(
    '警告',
    '',
    backgroundColor: Colors.orange,
    colorText: Colors.white,
    messageText: SelectableText(
      message,
      style: TextStyle(color: Colors.white),
    ),
  );
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

// DCBA：标准大端（字节顺序 43 48 00 00 → 200.0）
double bigEndianToFloat(String hexString) {
  final hex = hexString.replaceAll(' ', '');
  final int value = int.parse(hex, radix: 16);
  final bd = ByteData(4)..setUint32(0, value, Endian.big);
  return bd.getFloat32(0, Endian.big);
}

// BADC：大端反转（字节顺序 48 43 00 00 → 200.0，等同于 DCBA）
double bigEndianSwappedToFloat(String hexString) {
  final hex = hexString.replaceAll(' ', '');
  final bytes = <String>[];
  for (var i = 0; i < hex.length; i += 2) {
    bytes.add(hex.substring(i, i + 2));
  }
  // BADC：交换前后16位
  final swapped = '${bytes[2]}${bytes[3]}${bytes[0]}${bytes[1]}';
  final bd = ByteData(4)..setUint32(0, int.parse(swapped, radix: 16), Endian.big);
  return bd.getFloat32(0, Endian.big);
}

// CDAB：小端反转（字节顺序 00 00 48 43 → 3.71e-06）
double bigEndianToFloatSwapped(String hexString) {
  final hex = hexString.replaceAll(' ', '');
  final bytes = <String>[];
  for (var i = 0; i < hex.length; i += 2) {
    bytes.add(hex.substring(i, i + 2));
  }
  // CDAB：全字节反转
  final reversed = bytes.reversed.join();
  final bd = ByteData(4)..setUint32(0, int.parse(reversed, radix: 16), Endian.big);
  return bd.getFloat32(0, Endian.big);
}

// ABCD：标准小端（字节顺序 00 00 48 43 → 3.71e-06）
double littleEndianToFloat(String hexString) {
  final hex = hexString.replaceAll(' ', '');
  final int value = int.parse(hex, radix: 16);
  final bd = ByteData(4)..setUint32(0, value, Endian.little);
  return bd.getFloat32(0, Endian.little);
}

// ── Int16 有符号 2字节 ───────────────────────────────
// 大端：AB → int16
int int16BE(String hex) {
  final v = int.parse(hex.replaceAll(' ', ''), radix: 16);
  final bd = ByteData(2)..setInt16(0, v, Endian.big);
  return bd.getInt16(0, Endian.big);
}

// 小端：BA → int16
int int16LE(String hex) {
  final v = int.parse(hex.replaceAll(' ', ''), radix: 16);
  final bd = ByteData(2)..setInt16(0, v, Endian.little);
  return bd.getInt16(0, Endian.little);
}

// ── UInt16 无符号 2字节 ──────────────────────────────
// 大端：AB → uint16
int uint16BE(String hex) {
  final v = int.parse(hex.replaceAll(' ', ''), radix: 16);
  final bd = ByteData(2)..setUint16(0, v, Endian.big);
  return bd.getUint16(0, Endian.big);
}

// 小端：BA → uint16
int uint16LE(String hex) {
  final v = int.parse(hex.replaceAll(' ', ''), radix: 16);
  final bd = ByteData(2)..setUint16(0, v, Endian.little);
  return bd.getUint16(0, Endian.little);
}

// ── Int32 有符号 4字节 ───────────────────────────────
// DCBA
int int32DCBA(String hex) {
  final v = int.parse(hex.replaceAll(' ', ''), radix: 16);
  final bd = ByteData(4)..setInt32(0, v, Endian.big);
  return bd.getInt32(0, Endian.big);
}

// BADC
int int32BADC(String hex) {
  final b = _swap16(hex);
  final v = int.parse(b, radix: 16);
  final bd = ByteData(4)..setInt32(0, v, Endian.big);
  return bd.getInt32(0, Endian.big);
}

// CDAB
int int32CDAB(String hex) {
  final b = _swap8(hex);
  final v = int.parse(b, radix: 16);
  final bd = ByteData(4)..setInt32(0, v, Endian.big);
  return bd.getInt32(0, Endian.big);
}

// ABCD
int int32ABCD(String hex) {
  final v = int.parse(hex.replaceAll(' ', ''), radix: 16);
  final bd = ByteData(4)..setInt32(0, v, Endian.big);
  return bd.getInt32(0, Endian.little);
}

// ── UInt32 无符号 4字节 ─────────────────────────────
// DCBA
int uint32DCBA(String hex) {
  final v = int.parse(hex.replaceAll(' ', ''), radix: 16);
  final bd = ByteData(4)..setUint32(0, v, Endian.big);
  return bd.getUint32(0, Endian.big);
}

// BADC
int uint32BADC(String hex) {
  final b = _swap16(hex);
  final v = int.parse(b, radix: 16);
  final bd = ByteData(4)..setUint32(0, v, Endian.big);
  return bd.getUint32(0, Endian.big);
}

// CDAB
int uint32CDAB(String hex) {
  final b = _swap8(hex);
  final v = int.parse(b, radix: 16);
  final bd = ByteData(4)..setUint32(0, v, Endian.big);
  return bd.getUint32(0, Endian.big);
}

// ABCD
int uint32ABCD(String hex) {
  final v = int.parse(hex.replaceAll(' ', ''), radix: 16);
  final bd = ByteData(4)..setUint32(0, v, Endian.big);
  return bd.getUint32(0, Endian.little);
}

// ── Float64 双精度 8字节 ─────────────────────────────
// 使用 Uint64List 先写字节再读 float64，兼容所有字节序
// DCBA·BADC：标准大端
double float64DCBA(String hex) {
  final bd = ByteData(8);
  final h = hex.replaceAll(' ', '');
  for (var i = 0; i < 8; i++) {
    bd.setUint8(i, int.parse(h.substring(i * 2, i * 2 + 2), radix: 16));
  }
  return Float64List.view(bd.buffer)[0];
}

// BADC·DCBA：前低后高互换
double float64BADC(String hex) {
  final h = hex.replaceAll(' ', '');
  final bd = ByteData(8);
  for (var i = 0; i < 4; i++) {
    bd.setUint8(i, int.parse(h.substring((4 + i) * 2, (4 + i) * 2 + 2), radix: 16));
    bd.setUint8(4 + i, int.parse(h.substring(i * 2, i * 2 + 2), radix: 16));
  }
  return Float64List.view(bd.buffer)[0];
}

// CDAB·ABCD：全字节反转
double float64CDAB(String hex) {
  final h = hex.replaceAll(' ', '');
  final bd = ByteData(8);
  for (var i = 0; i < 8; i++) {
    bd.setUint8(i, int.parse(h.substring((7 - i) * 2, (7 - i) * 2 + 2), radix: 16));
  }
  return Float64List.view(bd.buffer)[0];
}

// ABCD·CDAB：标准小端
double float64ABCD(String hex) {
  final h = hex.replaceAll(' ', '');
  final bd = ByteData(8);
  for (var i = 0; i < 8; i++) {
    bd.setUint8(i, int.parse(h.substring((7 - i) * 2, (7 - i) * 2 + 2), radix: 16));
  }
  return Float64List.view(bd.buffer, 0, 8)[0];
}

// ── 辅助：交换前后16位（4字节 hex 字符串）────────────
String _swap16(String hex) {
  final h = hex.replaceAll(' ', '');
  return '${h.substring(4, 8)}${h.substring(0, 4)}';
}

// ── 辅助：全字节反转（4字节 hex 字符串）──────────────
String _swap8(String hex) {
  final h = hex.replaceAll(' ', '');
  final bytes = <String>[];
  for (var i = 0; i < h.length; i += 2) bytes.add(h.substring(i, i + 2));
  return bytes.reversed.join();
}

String sha256(String salt, String pwd) {
  var bytes = utf8.encode(salt + pwd);
  var digest = crypto.sha256.convert(bytes);
  return digest.toString();
}

// 兼容 excel 包的 Cell 类型安全取值
String getCellString(dynamic cell) {
  if (cell == null) return '';
  try {
    final v = cell.value;
    if (v == null) return '';
    if (v is String) return v;
    if (v is num) return v.toString();
    if (v is bool) return v.toString();
    return v.toString().trim();
  } catch (_) {
    return '';
  }
}

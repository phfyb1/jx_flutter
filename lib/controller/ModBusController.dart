// ignore_for_file: file_names

import 'package:get/get.dart';
import '../util/ControllerUtils.dart' as utils;

/// 解析结果的行类型
enum ModBusRowType {
  header, // 报文头部字段（设备地址、功能码等）
  data, // 寄存器数据行
  checksum, // 校验码
  error, // 错误信息
}

/// 单行解析结果
class ModBusResultRow {
  final ModBusRowType type;
  final String label;
  final String hex;
  final String decimal;
  final int? address; // 寄存器地址（仅 data 行）

  ModBusResultRow({
    required this.type,
    required this.label,
    this.hex = '',
    this.decimal = '',
    this.address,
  });
}

class ModBusControler extends GetxController {
  // ── 状态 ──────────────────────────────────────────
  var standard = true.obs; // true=标准模式，false=非标准模式
  var startAddress = '0'.obs; // 起始寄存器地址（标准模式）
  var resultRows = <ModBusResultRow>[].obs; // 结构化结果列表
  var isError = false.obs; // 是否有解析错误
  var errorMessage = ''.obs; // 错误详情

  // ── 清空 ──────────────────────────────────────────
  void clean() {
    resultRows.value = [];
    isError.value = false;
    errorMessage.value = '';
  }

  // ── 主入口 ────────────────────────────────────────
  void parse(String input) {
    clean();

    final trimmed = input.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty) {
      _setError('输入不能为空');
      return;
    }

    // 支持两种格式：带空格 "01 03 04 ..." 和不带空格 "01030400..."
    List<String> bytes;
    if (trimmed.contains(' ')) {
      bytes = trimmed.split(' ');
    } else {
      // 每两个字符作为一个字节
      if (trimmed.length % 2 != 0) {
        _setError('十六进制数据长度不合法（字节数应为偶数）');
        return;
      }
      bytes = <String>[];
      for (var i = 0; i < trimmed.length; i += 2) {
        bytes.add(trimmed.substring(i, i + 2));
      }
    }

    // 统一转大写
    bytes = bytes.map((b) => b.toUpperCase()).toList();

    // 校验每个字节是否合法
    final hexReg = RegExp(r'^[0-9A-Fa-f]{2}$');
    for (final b in bytes) {
      if (!hexReg.hasMatch(b)) {
        _setError('包含非法字节: "$b"，请输入合法的十六进制数据');
        return;
      }
    }

    if (standard.value) {
      _parseStandard(bytes);
    } else {
      _parseOffStandard(bytes);
    }
  }

  // ── 标准 ModBus RTU 响应解析 ──────────────────────
  // 格式: [设备地址1] [功能码1] [数据长度1] [数据N] [CRC2]
  void _parseStandard(List<String> bytes) {
    if (bytes.length < 5) {
      _setError('报文长度不足（至少5字节），当前: ${bytes.length} 字节');
      return;
    }
    try {
      // 1. 设备地址
      final deviceAddr = bytes[0];
      resultRows.add(ModBusResultRow(
        type: ModBusRowType.header,
        label: '设备地址',
        hex: deviceAddr,
        decimal: utils.hexToDec(deviceAddr).toString(),
      ));

      // 2. 功能码
      final funcCode = bytes[1];
      resultRows.add(ModBusResultRow(
        type: ModBusRowType.header,
        label: '功能码',
        hex: funcCode,
        decimal: utils.hexToDec(funcCode).toString(),
      ));

      // 3. 数据长度（字节数）
      final dataLenHex = bytes[2];
      final dataLenBytes = utils.hexToDec(dataLenHex) as int;
      final registerCount = dataLenBytes ~/ 2;
      resultRows.add(ModBusResultRow(
        type: ModBusRowType.header,
        label: '数据长度',
        hex: dataLenHex,
        decimal: '$dataLenBytes 字节 / $registerCount 个寄存器',
      ));

      // 4. 校验报文结构完整性
      final expectedLen = 3 + dataLenBytes + 2;
      if (bytes.length != expectedLen) {
        _setError(
            '报文长度与数据长度字段不符\n期望: $expectedLen 字节，实际: ${bytes.length} 字节');
        return;
      }

      // 5. 解析寄存器数据
      final dataBytes = bytes.sublist(3, 3 + dataLenBytes);
      int addr = _safeParseInt(startAddress.value, defaultVal: 0);
      for (var i = 0; i < dataBytes.length; i += 2) {
        if (i + 1 >= dataBytes.length) break;
        final chunk = dataBytes.sublist(i, i + 2);
        final hexStr = utils.combination(chunk);
        final decVal = utils.hexToDecCombination(chunk);
        resultRows.add(ModBusResultRow(
          type: ModBusRowType.data,
          label: '寄存器',
          hex: hexStr,
          decimal: decVal.toString(),
          address: addr + i ~/ 2,
        ));
      }

      // 6. 校验码
      final crcBytes = bytes.sublist(bytes.length - 2);
      resultRows.add(ModBusResultRow(
        type: ModBusRowType.checksum,
        label: 'CRC校验',
        hex: utils.combination(crcBytes),
      ));
    } catch (e) {
      _setError('解析异常: $e');
    }
  }

  // ── 非标准 ModBus 请求帧解析 ──────────────────────
  // 格式: [设备地址1] [功能码1] [起始地址2] [寄存器数量2] [CRC2]
  void _parseOffStandard(List<String> bytes) {
    if (bytes.length < 8) {
      _setError('非标准报文长度不足（至少8字节），当前: ${bytes.length} 字节');
      return;
    }
    try {
      // 1. 设备地址
      resultRows.add(ModBusResultRow(
        type: ModBusRowType.header,
        label: '设备地址',
        hex: bytes[0],
        decimal: utils.hexToDec(bytes[0]).toString(),
      ));

      // 2. 功能码
      resultRows.add(ModBusResultRow(
        type: ModBusRowType.header,
        label: '功能码',
        hex: bytes[1],
        decimal: utils.hexToDec(bytes[1]).toString(),
      ));

      // 3. 起始地址（2字节）
      final addrBytes = bytes.sublist(2, 4);
      final startAddrDec = utils.hexToDecCombination(addrBytes);
      resultRows.add(ModBusResultRow(
        type: ModBusRowType.header,
        label: '起始地址',
        hex: utils.combination(addrBytes),
        decimal: startAddrDec.toString(),
      ));

      // 4. 寄存器数量（2字节）
      final cntBytes = bytes.sublist(4, 6);
      final regCount = utils.hexToDecCombination(cntBytes);
      resultRows.add(ModBusResultRow(
        type: ModBusRowType.header,
        label: '寄存器数量',
        hex: utils.combination(cntBytes),
        decimal: '$regCount 个',
      ));

      // 5. 数据段（剩余字节减去2字节CRC）
      final dataBytes = bytes.sublist(6, bytes.length - 2);
      if (dataBytes.isNotEmpty) {
        for (var i = 0; i < dataBytes.length; i += 2) {
          if (i + 1 >= dataBytes.length) break;
          final chunk = dataBytes.sublist(i, i + 2);
          final hexStr = utils.combination(chunk);
          final decVal = utils.hexToDecCombination(chunk);
          resultRows.add(ModBusResultRow(
            type: ModBusRowType.data,
            label: '数据',
            hex: hexStr,
            decimal: decVal.toString(),
            address: startAddrDec + i ~/ 2,
          ));
        }
      }

      // 6. 校验码
      final crcBytes = bytes.sublist(bytes.length - 2);
      resultRows.add(ModBusResultRow(
        type: ModBusRowType.checksum,
        label: 'CRC校验',
        hex: utils.combination(crcBytes),
      ));
    } catch (e) {
      _setError('解析异常: $e');
    }
  }

  // ── 工具方法 ──────────────────────────────────────
  void _setError(String msg) {
    isError.value = true;
    errorMessage.value = msg;
    resultRows.add(ModBusResultRow(
      type: ModBusRowType.error,
      label: '错误',
      hex: msg,
    ));
  }

  int _safeParseInt(String s, {int defaultVal = 0}) {
    return int.tryParse(s) ?? defaultVal;
  }
}

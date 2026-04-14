import 'package:get/get.dart';
import '../util/ControllerUtils.dart' as utils;

/// 数据类型定义
enum DataType {
  int16(1, 'Int16', 2),
  uint16(2, 'UInt16', 2),
  int32(3, 'Int32', 4),
  uint32(4, 'UInt32', 4),
  float32(5, 'Float32', 4),
  float64(6, 'Float64', 8);

  final int id;
  final String label;
  final int byteSize;
  const DataType(this.id, this.label, this.byteSize);

  static DataType fromId(int id) =>
      DataType.values.firstWhere((e) => e.id == id, orElse: () => DataType.float32);
}

/// 字节序定义
enum ByteOrder {
  dcba(1, 'DCBA', '大端（高位在前）'),
  badc(2, 'BADC', '大端反转（前后互换）'),
  cdab(3, 'CDAB', '小端反转（全字节互换）'),
  abcd(4, 'ABCD', '小端（低位在前）');

  final int id;
  final String label;
  final String desc;
  const ByteOrder(this.id, this.label, this.desc);

  static ByteOrder fromId(int id) =>
      ByteOrder.values.firstWhere((e) => e.id == id, orElse: () => ByteOrder.dcba);
}

class ModBusServerController extends GetxController {
  // ── 全局选择 ──────────────────────────────────────
  final dataType = DataType.float32.obs;
  final byteOrder = ByteOrder.dcba.obs;

  // ── 数据存储 ──────────────────────────────────────
  /// 每条记录的原始十六进制字符串
  final dataResultList = <String>[].obs;
  /// 每条记录对应的解析结果
  final parsedValues = <String>[].obs;
  /// 原始帧原始数据（用于 byteOrder 切换时重新解析）
  String _rawDataBytes = '';

  // ── 主入口 ───────────────────────────────────────
  /// 解析十六进制报文字符串
  void parse(String rawHex) {
    clean();
    final hex = rawHex.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    if (hex.isEmpty) return;

    // 每 2 字符一组拆成字节数组
    final bytes = <String>[];
    for (var i = 0; i + 1 < hex.length; i += 2) {
      bytes.add(hex.substring(i, i + 2));
    }
    if (bytes.length < 5) return;

    // 报文结构：[设备地址 1B][功能码 1B][数据长度 1B][数据 NB][校验 2B]
    final dataBytes = bytes.sublist(3, bytes.length - 2);
    _rawDataBytes = dataBytes.join('');

    _fillResults(dataBytes);
  }

  void _fillResults(List<String> dataBytes) {
    final byteSize = dataType.value.byteSize;
    final hexStr = dataBytes.join('');

    // 数据不足时给出提示
    if (hexStr.length < byteSize * 2) {
      dataResultList.add('数据不足（${dataBytes.length} 字节）');
      parsedValues.add('需要 ${byteSize} 字节');
      return;
    }

    // 按数据类型切分（hexStr.length 是字符数，需用 byteSize*2）
    for (var i = 0; i + byteSize * 2 <= hexStr.length; i += byteSize * 2) {
      final chunk = hexStr.substring(i, i + byteSize * 2);
      dataResultList.add(_formatHex(chunk));
      parsedValues.add(_decode(chunk));
    }
  }

  // ── 数据类型切换 ──────────────────────────────────
  void setDataType(DataType type) {
    if (dataType.value == type) return;
    dataType.value = type;
    _reparse();
    // 2字节类型默认 big，4/8字节默认 dcba
    if (type.byteSize == 2) {
      byteOrder.value = ByteOrder.dcba;
    } else {
      byteOrder.value = ByteOrder.dcba;
    }
  }

  // ── 字节序切换 ───────────────────────────────────
  void setByteOrder(ByteOrder order) {
    if (byteOrder.value == order) return;
    byteOrder.value = order;
    _reparse();
  }

  void _reparse() {
    if (_rawDataBytes.isEmpty) {
      clean();
      return;
    }
    // 还原字节数组
    final bytes = <String>[];
    for (var i = 0; i + 1 < _rawDataBytes.length; i += 2) {
      bytes.add(_rawDataBytes.substring(i, i + 2));
    }
    dataResultList.clear();
    parsedValues.clear();
    _fillResults(bytes);
  }

  // ── 解析 ─────────────────────────────────────────
  String _decode(String hex) {
    final order = byteOrder.value;
    switch (dataType.value) {
      case DataType.int16:
        return order == ByteOrder.dcba
            ? utils.int16BE(hex).toString()
            : utils.int16LE(hex).toString();
      case DataType.uint16:
        return order == ByteOrder.dcba
            ? utils.uint16BE(hex).toString()
            : utils.uint16LE(hex).toString();
      case DataType.int32:
        return _decodeInt32(hex, order);
      case DataType.uint32:
        return _decodeUInt32(hex, order);
      case DataType.float32:
        return _decodeFloat32(hex, order);
      case DataType.float64:
        return _decodeFloat64(hex, order);
    }
  }

  String _decodeInt32(String hex, ByteOrder order) {
    switch (order) {
      case ByteOrder.dcba: return utils.int32DCBA(hex).toString();
      case ByteOrder.badc: return utils.int32BADC(hex).toString();
      case ByteOrder.cdab: return utils.int32CDAB(hex).toString();
      case ByteOrder.abcd: return utils.int32ABCD(hex).toString();
    }
  }

  String _decodeUInt32(String hex, ByteOrder order) {
    switch (order) {
      case ByteOrder.dcba: return utils.uint32DCBA(hex).toString();
      case ByteOrder.badc: return utils.uint32BADC(hex).toString();
      case ByteOrder.cdab: return utils.uint32CDAB(hex).toString();
      case ByteOrder.abcd: return utils.uint32ABCD(hex).toString();
    }
  }

  String _decodeFloat32(String hex, ByteOrder order) {
    switch (order) {
      case ByteOrder.dcba: return utils.bigEndianToFloat(hex).toString();
      case ByteOrder.badc: return utils.bigEndianSwappedToFloat(hex).toString();
      case ByteOrder.cdab: return utils.bigEndianToFloatSwapped(hex).toString();
      case ByteOrder.abcd: return utils.littleEndianToFloat(hex).toString();
    }
  }

  String _decodeFloat64(String hex, ByteOrder order) {
    switch (order) {
      case ByteOrder.dcba: return utils.float64DCBA(hex).toString();
      case ByteOrder.badc: return utils.float64BADC(hex).toString();
      case ByteOrder.cdab: return utils.float64CDAB(hex).toString();
      case ByteOrder.abcd: return utils.float64ABCD(hex).toString();
    }
  }

  // ── 工具 ─────────────────────────────────────────
  /// 每 2 字符加一个空格，便于阅读
  String _formatHex(String hex) {
    return hex.replaceAllMapped(
        RegExp(r'.{2}'), (m) => '${m.group(0)} ');
  }

  /// 清空
  void clean() {
    dataResultList.clear();
    parsedValues.clear();
    _rawDataBytes = '';
  }
}

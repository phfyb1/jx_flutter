// ignore_for_file: file_names, non_constant_identifier_names

import 'package:get/get.dart';
import '../util/ControllerUtils.dart' as utils;

// ── 结果行类型枚举 ─────────────────────────────────────────────
enum JT809RowType {
  header,    // 报文头部字段（蓝色）
  body,      // 数据体字段（绿色）
  footer,    // 尾部/校验（灰色）
  error,     // 错误信息（红色）
  subTitle,  // 子标题分隔（深色）
}

// ── 结果行数据类 ──────────────────────────────────────────────
class JT809ResultRow {
  final String label;   // 字段名称
  final String hex;     // 原始16进制值
  final String parsed;  // 解析后的文字
  final JT809RowType type;

  const JT809ResultRow({
    required this.label,
    required this.hex,
    this.parsed = '',
    required this.type,
  });
}

// ─────────────────────────────────────────────────────────────
class JT809Controller extends GetxController {

  var inputText = ''.obs;
  var resultRows = <JT809ResultRow>[].obs;
  var hasResult = false.obs;
  var errorMessage = ''.obs;

  // ── 清空状态 ──────────────────────────────────────────────
  void clean() {
    inputText.value = '';
    resultRows.clear();
    hasResult.value = false;
    errorMessage.value = '';
  }

  // ── 主解析入口 ────────────────────────────────────────────
  void parse(String str) {
    clean();

    final input = str.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();
    if (input.isEmpty) {
      errorMessage.value = '请输入报文数据';
      return;
    }

    if (input.length % 2 != 0) {
      errorMessage.value = '报文长度不合法（字节数必须为偶数）';
      return;
    }

    // 将连续16进制串转为字节列表
    final List<String> bytes = [];
    for (int i = 0; i < input.length; i += 2) {
      bytes.add(input.substring(i, i + 2));
    }

    // 最小报文长度：头1 + 长4 + 序列号4 + 业务类型2 + 下级接入码4 + 版本3 + 加密标识1 + 密钥4 + 校验2 + 尾1 = 26 字节
    if (bytes.length < 26) {
      errorMessage.value = '报文过短（最少26字节），当前 ${bytes.length} 字节';
      return;
    }

    if (bytes.first != '5B') {
      errorMessage.value = '头标识错误，期望 5B，实际 ${bytes.first}';
      return;
    }

    if (bytes.last != '5D') {
      errorMessage.value = '尾标识错误，期望 5D，实际 ${bytes.last}';
      return;
    }

    final rows = <JT809ResultRow>[];

    try {
      // ── 报文头解析 ─────────────────────────────────────────
      rows.add(JT809ResultRow(
        label: '头标识', hex: bytes[0], parsed: '0x5B', type: JT809RowType.header));

      final lengthHex = bytes.sublist(1, 5).join();
      rows.add(JT809ResultRow(
        label: '数据长度', hex: lengthHex,
        parsed: '${utils.hexToDec(lengthHex)} 字节',
        type: JT809RowType.header));

      final seqHex = bytes.sublist(5, 9).join();
      rows.add(JT809ResultRow(
        label: '报文序列号', hex: seqHex,
        parsed: utils.hexToDec(seqHex).toString(),
        type: JT809RowType.header));

      final msgTypeHex = bytes.sublist(9, 11).join();
      final msgTypeDesc = _msgTypeDesc(msgTypeHex);
      rows.add(JT809ResultRow(
        label: '业务数据类型', hex: msgTypeHex,
        parsed: msgTypeDesc,
        type: JT809RowType.header));

      final accessCodeHex = bytes.sublist(11, 15).join();
      rows.add(JT809ResultRow(
        label: '下级平台接入码', hex: accessCodeHex,
        parsed: utils.hexToDec(accessCodeHex).toString(),
        type: JT809RowType.header));

      final versionHex = bytes.sublist(15, 18).join();
      rows.add(JT809ResultRow(
        label: '协议版本号', hex: versionHex,
        parsed: '${int.parse(bytes[15], radix: 16)}'
                '.${int.parse(bytes[16], radix: 16)}'
                '.${int.parse(bytes[17], radix: 16)}',
        type: JT809RowType.header));

      final encFlagHex = bytes[18];
      rows.add(JT809ResultRow(
        label: '报文加密标识', hex: encFlagHex,
        parsed: encFlagHex == '00' ? '不加密' : '加密（0x$encFlagHex）',
        type: JT809RowType.header));

      final keyHex = bytes.sublist(19, 23).join();
      rows.add(JT809ResultRow(
        label: '数据加密密钥', hex: keyHex,
        parsed: utils.hexToDec(keyHex).toString(),
        type: JT809RowType.header));

      // ── 数据体解析 ─────────────────────────────────────────
      rows.add(JT809ResultRow(
        label: '── 数据体（$msgTypeDesc）', hex: '', type: JT809RowType.subTitle));

      _parseBody(msgTypeHex, bytes, rows);

      // ── 尾部 ───────────────────────────────────────────────
      final checkHex = bytes.sublist(bytes.length - 3, bytes.length - 1).join();
      rows.add(JT809ResultRow(
        label: '校验码', hex: checkHex, type: JT809RowType.footer));

      rows.add(JT809ResultRow(
        label: '尾标识', hex: bytes.last, parsed: '0x5D', type: JT809RowType.footer));

    } catch (e) {
      rows.add(JT809ResultRow(
        label: '解析错误', hex: '', parsed: e.toString(), type: JT809RowType.error));
    }

    resultRows.value = rows;
    hasResult.value = true;
  }

  // ── 数据体分发 ────────────────────────────────────────────
  void _parseBody(String msgType, List<String> bytes, List<JT809ResultRow> rows) {
    final body = bytes.sublist(23, bytes.length - 3);

    switch (msgType) {
      case '1001':
        _parse1001(body, rows);
        break;
      case '1002':
        _parse1002(body, rows);
        break;
      case '1200':
        _parse1200(body, rows);
        break;
      default:
        rows.add(JT809ResultRow(
          label: '暂不支持解析该业务类型', hex: msgType,
          parsed: '完整数据体 HEX：${body.join()}',
          type: JT809RowType.body));
    }
  }

  // ── 1001 主链路登录请求 ────────────────────────────────────
  void _parse1001(List<String> body, List<JT809ResultRow> rows) {
    if (body.length < 15) {
      rows.add(JT809ResultRow(
        label: '数据体长度不足', hex: body.join(),
        parsed: '期望≥15字节，实际 ${body.length} 字节',
        type: JT809RowType.error));
      return;
    }

    final userHex = body.sublist(0, 4).join();
    rows.add(JT809ResultRow(
      label: '用户名', hex: userHex,
      parsed: utils.hexToDec(userHex).toString(),
      type: JT809RowType.body));

    final pwdBytes = body.sublist(4, 12);
    final pwdHex = pwdBytes.join();
    rows.add(JT809ResultRow(
      label: '密码', hex: pwdHex,
      parsed: utils.changetoHexCombination(pwdBytes),
      type: JT809RowType.body));

    if (body.length > 14) {
      final ipBytes = body.sublist(12, body.length - 2);
      final ipHex = ipBytes.join();
      rows.add(JT809ResultRow(
        label: '下级平台IP', hex: ipHex,
        parsed: utils.changetoHexCombination(ipBytes),
        type: JT809RowType.body));
    }

    final portHex = body.sublist(body.length - 2).join();
    rows.add(JT809ResultRow(
      label: '下级平台端口', hex: portHex,
      parsed: utils.hexToDec(portHex).toString(),
      type: JT809RowType.body));
  }

  // ── 1002 主链路登录应答 ────────────────────────────────────
  void _parse1002(List<String> body, List<JT809ResultRow> rows) {
    if (body.isEmpty) {
      rows.add(const JT809ResultRow(
        label: '数据体为空', hex: '', type: JT809RowType.error));
      return;
    }

    const resultMap = {
      '00': '成功',
      '01': 'IP 地址错误',
      '02': '接入码错误',
      '03': '用户未注册',
      '04': '密码错误',
      '05': '资源紧张',
      '06': '其他',
    };
    final code = body[0].toUpperCase();
    rows.add(JT809ResultRow(
      label: '应答结果', hex: code,
      parsed: resultMap[code] ?? '未知结果码',
      type: JT809RowType.body));

    if (body.length >= 5) {
      final verHex = body.sublist(1, 5).join();
      rows.add(JT809ResultRow(
        label: '校验码', hex: verHex,
        parsed: utils.hexToDec(verHex).toString(),
        type: JT809RowType.body));
    }
  }

  // ── 1200 主链路动态信息交换 ────────────────────────────────
  void _parse1200(List<String> body, List<JT809ResultRow> rows) {
    if (body.length < 29) {
      rows.add(JT809ResultRow(
        label: '数据体长度不足', hex: body.join(),
        parsed: '期望≥29字节，实际 ${body.length} 字节',
        type: JT809RowType.error));
      return;
    }

    final plateBytes = body.sublist(0, 21);
    final plateHex = plateBytes.join();
    rows.add(JT809ResultRow(
      label: '车牌号', hex: plateHex,
      parsed: utils.changetoHexCombination(plateBytes),
      type: JT809RowType.body));

    final colorHex = body[21];
    rows.add(JT809ResultRow(
      label: '车牌颜色', hex: colorHex,
      parsed: _carColor(colorHex),
      type: JT809RowType.body));

    final subTypeHex = body.sublist(22, 24).join();
    rows.add(JT809ResultRow(
      label: '子业务标识', hex: subTypeHex, type: JT809RowType.body));

    final dataLenHex = body.sublist(24, 28).join();
    rows.add(JT809ResultRow(
      label: '后续数据长度', hex: dataLenHex,
      parsed: '${utils.hexToDec(dataLenHex)} 字节',
      type: JT809RowType.body));

    if (body.length > 28) {
      final dataHex = body.sublist(28).join();
      rows.add(JT809ResultRow(
        label: '数据内容', hex: dataHex, type: JT809RowType.body));
    }
  }

  // ── 业务类型描述 ──────────────────────────────────────────
  static const _msgTypeMap = <String, String>{
    '1001': '主链路登录请求',
    '1002': '主链路登录应答',
    '1003': '主链路注销请求',
    '1004': '主链路注销应答',
    '1005': '主链路连接保持请求',
    '1006': '主链路连接保持应答',
    '1007': '主链路断开通知',
    '1008': '下级主动断开通知',
    '9001': '从链路连接请求',
    '9002': '从链路连接应答',
    '9003': '从链路注销请求',
    '9004': '从链路注销应答',
    '9005': '从链路连接保持请求',
    '9006': '从链路连接保持应答',
    '9007': '从链路断开通知',
    '9008': '上级平台主动关闭链路通知',
    '9101': '接收定位信息数量通知',
    '1200': '主链路动态信息交换',
    '9200': '从链路动态信息交换',
    '1300': '主链路平台间信息交互',
    '9300': '从链路平台间信息交互',
    '1400': '主链路报警信息交互',
    '9400': '从链路报警信息交互',
    '1500': '主链路车辆监管消息',
    '9500': '从链路车辆监管消息',
    '1600': '主链路静态信息交互',
    '9600': '从链路静态信息交互',
  };

  String _msgTypeDesc(String hex) => _msgTypeMap[hex] ?? '未知类型 (0x$hex)';

  // ── 车牌颜色 ──────────────────────────────────────────────
  static const _colorMap = <String, String>{
    '01': '蓝色',
    '02': '黄色',
    '03': '黑色',
    '04': '白色',
    '09': '其他',
  };

  String _carColor(String hex) => _colorMap[hex.toUpperCase()] ?? '未知颜色 (0x$hex)';
}

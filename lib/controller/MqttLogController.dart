import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MqttLogController extends GetxController {
  // 原始日志 JSON 文本
  final logText = ''.obs;

  // 解析后的外层 ts
  final outerTs = Rxn<int>();

  // values 列表
  final values = <Map<String, dynamic>>[].obs;

  // 查询关键词
  final queryCode = ''.obs;

  // 匹配结果
  final matched = <Map<String, dynamic>>[].obs;

  // 时间戳格式化工具
  String formatTs(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(dt)} ($ms)';
  }

  // 解析日志
  void parseLog(String text) {
    queryCode.value = '';
    matched.clear();

    if (text.trim().isEmpty) {
      logText.value = '';
      outerTs.value = null;
      values.clear();
      return;
    }

    logText.value = text;

    try {
      final root = jsonDecode(text) as Map<String, dynamic>;
      outerTs.value = root['ts'] as int?;

      final rawValues = root['values'];
      if (rawValues is List) {
        values.assignAll(rawValues.cast<Map<String, dynamic>>());
      } else {
        values.clear();
      }
    } catch (e) {
      outerTs.value = null;
      values.clear();
    }
  }

  // 按 code 查询
  void search(String code) {
    queryCode.value = code.trim();

    if (queryCode.value.isEmpty) {
      matched.clear();
      return;
    }

    matched.assignAll(
      values.where((v) {
        final vCode = (v['code'] as String?) ?? '';
        return vCode.toLowerCase() == queryCode.value.toLowerCase();
      }),
    );
  }

  void clear() {
    logText.value = '';
    outerTs.value = null;
    values.clear();
    queryCode.value = '';
    matched.clear();
  }
}

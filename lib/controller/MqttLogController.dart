import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MqttLogController extends GetxController {
  // 原始日志 JSON 文本
  final logText = ''.obs;

  // 解析后的外层 ts（多条消息时取最新一条）
  final outerTs = Rxn<int>();

  // values 列表（多条消息时合并）
  final values = <Map<String, dynamic>>[].obs;

  // 查询关键词
  final queryCode = ''.obs;

  // 在离线筛选：all=全部 / online=在线 / offline=离线
  final statusFilter = 'all'.obs;

  // 匹配结果
  final matched = <Map<String, dynamic>>[].obs;

  // 解析状态反馈：空 = 正常；非空 = 展示给用户
  final parseError = ''.obs;

  // 解析到的 MQTT 消息条数（粘贴多行日志时会 > 1）
  final msgCount = 0.obs;

  // 时间戳格式化工具
  String formatTs(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(dt)} ($ms)';
  }

  /// 离线判定（业务规则）：
  /// 1. status != 0
  /// 2. 或采集时间落后最外层上报时间 1 小时以上（数据陈旧）
  bool isSensorOffline(int sensorTs, int status) {
    if (status != 0) return true;
    final outer = outerTs.value;
    if (outer != null && outer - sensorTs > const Duration(hours: 1).inMilliseconds) {
      return true;
    }
    return false;
  }

  // 解析日志
  void parseLog(String text) {
    queryCode.value = '';
    matched.clear();
    parseError.value = '';
    msgCount.value = 0;

    if (text.trim().isEmpty) {
      logText.value = '';
      outerTs.value = null;
      values.clear();
      return;
    }

    logText.value = text;

    final rootMaps = _extractJsonFragments(text);
    if (rootMaps.isEmpty) {
      outerTs.value = null;
      values.clear();
      parseError.value =
          '未找到有效 JSON：需要 { ts, values[] } 格式，或包含"订阅到的消息是：{...}"的日志行';
      return;
    }

    final merged = <Map<String, dynamic>>[];
    int? latestTs;

    for (final root in rootMaps) {
      // ts 兼容字符串与数字两种写法（后端可能返回 "1794205981543"）
      final ts = int.tryParse(root['ts']?.toString() ?? '');
      if (ts != null) latestTs = ts;

      final rawValues = root['values'];
      if (rawValues is List) {
        for (final v in rawValues) {
          if (v is Map) {
            final m = Map<String, dynamic>.from(v);
            // timestamp 归一化为 int，避免页面强转崩溃
            m['timestamp'] =
                int.tryParse(m['timestamp']?.toString() ?? '') ?? 0;
            merged.add(m);
          }
        }
      }
    }

    msgCount.value = rootMaps.length;
    outerTs.value = latestTs;
    values.assignAll(merged);

    if (merged.isEmpty) {
      parseError.value = 'JSON 有效但未找到 values 数组';
    }
  }

  /// 从原始文本提取所有顶层 JSON 对象：
  /// 1) 整段文本就是 JSON
  /// 2) Spring Boot 日志行（如 "...订阅到的消息是：{...}"），逐行取首个 { 到末个 } 的片段
  List<Map<String, dynamic>> _extractJsonFragments(String text) {
    // 尝试整段直接解析
    try {
      final v = jsonDecode(text);
      if (v is Map<String, dynamic>) return [v];
    } catch (_) {
      // 不是纯 JSON，继续按日志行提取
    }

    final fragments = <Map<String, dynamic>>[];
    for (final line in text.split('\n')) {
      final start = line.indexOf('{');
      final end = line.lastIndexOf('}');
      if (start < 0 || end <= start) continue;
      try {
        final v = jsonDecode(line.substring(start, end + 1));
        if (v is Map<String, dynamic>) fragments.add(v);
      } catch (_) {
        // 该行无有效 JSON，跳过
      }
    }
    return fragments;
  }

  // 按 code 查询（支持精确与包含匹配）
  void search(String code) {
    queryCode.value = code.trim();

    if (queryCode.value.isEmpty) {
      matched.clear();
      return;
    }

    final q = queryCode.value.toLowerCase();
    // 优先精确匹配；无精确结果时降级为包含匹配
    final exact = values.where((v) {
      final vCode = (v['code'] as String?) ?? '';
      return vCode.toLowerCase() == q;
    }).toList();

    matched.assignAll(
      exact.isNotEmpty
          ? exact
          : values.where((v) {
              final vCode = (v['code'] as String?) ?? '';
              return vCode.toLowerCase().contains(q);
            }),
    );
  }

  void clear() {
    logText.value = '';
    outerTs.value = null;
    values.clear();
    queryCode.value = '';
    matched.clear();
    parseError.value = '';
    msgCount.value = 0;
    statusFilter.value = 'all';
  }
}

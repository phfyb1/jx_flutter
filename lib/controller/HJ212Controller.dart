// ignore_for_file: unused_import, unnecessary_import, avoid_web_libraries_in_flutter, unused_local_variable, unrelated_type_equality_checks, unnecessary_new, avoid_print, prefer_typing_uninitialized_variables, non_constant_identifier_names, unnecessary_overrides, file_names

import 'dart:math';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'dart:html' as html;

import '../util/ControllerUtils.dart' as utils;

class HJ212Controller extends GetxController {
  // ── 表单字段 ──────────────────────────────────────────────
  var metric = ''.obs;
  var timeStart = '2022-01-01 00:00:00'.obs;
  var valueMin = '0'.obs;
  var valueMax = '100'.obs;
  var mn = ''.obs;
  var ec = ''.obs;
  var mp = ''.obs;
  var md = ''.obs;
  var mpType = 'Rtd'.obs; // Rtd / Avg
  var type = 'hour'.obs; // hour / day（仅 Avg 时显示）
  var day = '30'.obs;

  /// 结束时间（与 day 二选一，由 useEndTime 决定哪个可编辑）
  var endTime = ''.obs;

  /// false = 按天数（day 可编辑，endTime 只读联动）
  /// true  = 按结束时间（endTime 可编辑，day 只读联动）
  var useEndTime = false.obs;

  var fileName = 'TSDB'.obs;

  // ── 内部状态 ──────────────────────────────────────────────
  var isGenerating = false.obs; // 生成中状态
  var previewLines = <String>[].obs; // 预览数据行

  /// md 分隔符：英文逗号、中文逗号、顿号、分号（全/半角）均兼容
  static final RegExp _mdSeparator = RegExp(r'[,，、;；]');

  /// md 列表：支持多种分隔符分隔多个，每个 md 生成一条数据
  List<String> get mdList {
    final seen = <String>{};
    final list = <String>[];
    for (final raw in md.value.split(_mdSeparator)) {
      final v = raw.trim();
      if (v.isEmpty) continue;
      if (seen.add(v)) list.add(v);
    }
    return list;
  }

  // ── 时间配置：day ↔ endTime 双向联动 ──────────────────────
  static final DateFormat _tsFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// 解析时间字符串，失败返回 null
  DateTime? _parseTs(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    try {
      return _tsFormat.parseStrict(t);
    } catch (_) {
      return null;
    }
  }

  /// 由 day 推算 endTime（day 模式）
  void _syncEndFromDay() {
    final start = _parseTs(timeStart.value);
    final d = int.tryParse(day.value.trim());
    if (start == null || d == null || d <= 0) {
      endTime.value = '';
      return;
    }
    endTime.value = _tsFormat.format(start.add(Duration(days: d)));
  }

  /// 由 endTime 推算 day（endTime 模式），支持小数天（≤2 位小数）
  void _syncDayFromEnd() {
    final start = _parseTs(timeStart.value);
    final end = _parseTs(endTime.value);
    if (start == null || end == null) {
      day.value = '';
      return;
    }
    final sec = end.difference(start).inSeconds;
    if (sec <= 0) {
      day.value = '0';
      return;
    }
    final days = sec / 86400;
    day.value = days == days.roundToDouble()
        ? days.round().toString()
        : days.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  void onInit() {
    super.onInit();
    _syncEndFromDay();
    // 只在“当前可编辑的是谁”不发生冲突时联动，避免相互回写导致死循环
    ever(day, (_) {
      if (!useEndTime.value) _syncEndFromDay();
    });
    ever(endTime, (_) {
      if (useEndTime.value) _syncDayFromEnd();
    });
    ever(timeStart, (_) {
      useEndTime.value ? _syncDayFromEnd() : _syncEndFromDay();
    });
    ever(useEndTime, (v) {
      v ? _syncDayFromEnd() : _syncEndFromDay();
    });
  }

  /// 时间跨度（秒）：day 模式按天数算，endTime 模式按实际差值算
  int get _durationSeconds {
    if (useEndTime.value) {
      final start = _parseTs(timeStart.value);
      final end = _parseTs(endTime.value);
      if (start == null || end == null) return 0;
      return end.difference(start).inSeconds;
    }
    final d = int.tryParse(day.value.trim()) ?? 0;
    return d * 86400;
  }

  /// 时间点数量（不含 md 倍数）
  int get _timePointCount {
    final dur = _durationSeconds;
    if (dur <= 0) return 0;
    final step = _stepSeconds;
    if (step <= 0) return 0;
    final n = (dur / step).ceil();
    return n < 1 ? 1 : n;
  }

  /// 每个采样点的秒步长
  int get _stepSeconds {
    if (mpType.value == 'Rtd') return 60;
    switch (type.value) {
      case 'hour':
        return 3600;
      default:
        return 3600 * 24;
    }
  }

  // ── 数据行数计算（时间点 × md 个数）────────────────────────
  int get lineCount => _timePointCount * max(1, mdList.length);

  // ── 生成数据（带校验）─────────────────────────────────────
  Future<bool> generate() async {
    // 输入校验
    final errors = _validate();
    if (errors.isNotEmpty) {
      utils.showError(errors.join('\n'));
      return false;
    }

    isGenerating.value = true;
    TSDBData.clear();

    try {
      _addPack();
      _generatePreview();
      return true;
    } catch (e) {
      utils.showError('生成数据失败: $e');
      return false;
    } finally {
      isGenerating.value = false;
    }
  }

  // ── 保存文件（自动适配 Web / 移动端）──────────────────────
  Future<void> saveFile() async {
    if (TSDBData.isEmpty) {
      utils.showWarning('无数据可保存，请先生成');
      return;
    }

    final content = TSDBData.join('');
    final filename = '${fileName.value}.txt';

    if (kIsWeb) {
      try {
        final blob = html.Blob([content]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', filename)
          ..click();
        html.Url.revokeObjectUrl(url);
        utils.showSuccess('文件已开始下载: $filename');
      } catch (e) {
        utils.showError('Web 下载失败: $e');
      }
    } else {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$filename';
        final file = io.File(path);
        await file.writeAsString(content);
        utils.showSuccess('文件已保存到: $path');
      } catch (e) {
        utils.showError('文件保存失败: $e');
      }
    }
  }

  // ── 一键生成并保存 ────────────────────────────────────────
  Future<void> product() async {
    final ok = await generate();
    if (ok) {
      await saveFile();
    }
  }

  // ── 预览数据（仅前10条）───────────────────────────────────
  void _generatePreview() {
    if (TSDBData.isEmpty) return;
    final count = TSDBData.length.clamp(0, 10);
    previewLines.value = TSDBData.sublist(0, count);
  }

  // ── 单行数据打包 ──────────────────────────────────────────
  String _packLine(int time, String mdValue) {
    final val = _randomValue();
    return '${metric.value} $time $val '
        'mn=${mn.value} ec=${ec.value} mp=${mp.value} '
        'md=$mdValue mpType=${mpType.value}\n';
  }

  // ── 随机值生成 ────────────────────────────────────────────
  String _randomValue() {
    final min = int.tryParse(valueMin.value) ?? 0;
    final max = int.tryParse(valueMax.value) ?? 100;
    final value = (Random().nextDouble() * (max - min) + min).round();
    return value.toString();
  }

  // ── 批量生成（每个时间点 × 每个 md 一条）──────────────────
  void _addPack() {
    final baseTime = utils.dateStringToTimestamp(timeStart.value).toInt();
    final mds = mdList;
    final step = _stepSeconds;
    final timePoints = _timePointCount;

    for (int i = 0; i < timePoints; i++) {
      final t = baseTime + step * i;
      for (final mdValue in mds) {
        TSDBData.add(_packLine(t, mdValue));
      }
    }
  }

  // ── 输入校验 ──────────────────────────────────────────────
  List<String> _validate() {
    final errors = <String>[];

    if (metric.value.trim().isEmpty) errors.add('metric 不能为空');
    if (mn.value.trim().isEmpty) errors.add('mn 不能为空');
    if (ec.value.trim().isEmpty) errors.add('ec 不能为空');
    if (mp.value.trim().isEmpty) errors.add('mp 不能为空');
    if (mdList.isEmpty) {
      errors.add('md 不能为空（多个用逗号分隔，如 a1,a2）');
    }

    // 时间跨度：day 与 endTime 二选一
    final start = _parseTs(timeStart.value);
    if (useEndTime.value) {
      final end = _parseTs(endTime.value);
      if (end == null) {
        errors.add('endTime 格式错误，请使用 YYYY-MM-DD HH:mm:ss');
      } else if (start == null) {
        errors.add('timeStart 格式错误，请使用 YYYY-MM-DD HH:mm:ss');
      } else {
        final sec = end.difference(start).inSeconds;
        if (sec <= 0) {
          errors.add('endTime 必须晚于 timeStart');
        } else if (sec > 365 * 86400) {
          errors.add('时间跨度最大支持 365 天');
        }
      }
    } else {
      final d = int.tryParse(day.value.trim());
      if (d == null || d <= 0) errors.add('day 必须是大于 0 的整数');
      if (d != null && d > 365) errors.add('day 最大支持 365 天');
      if (start == null) {
        errors.add('timeStart 格式错误，请使用 YYYY-MM-DD HH:mm:ss');
      }
    }

    final vMin = int.tryParse(valueMin.value);
    final vMax = int.tryParse(valueMax.value);
    if (vMin == null) errors.add('valueMin 必须是整数');
    if (vMax == null) errors.add('valueMax 必须是整数');
    if (vMin != null && vMax != null && vMin > vMax) {
      errors.add('valueMin 不能大于 valueMax');
    }

    return errors;
  }

  // ── 内部存储 ──────────────────────────────────────────────
  List<String> TSDBData = [];
}

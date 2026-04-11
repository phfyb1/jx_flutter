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
  var fileName = 'TSDB'.obs;

  // ── 内部状态 ──────────────────────────────────────────────
  var isGenerating = false.obs; // 生成中状态
  var previewLines = <String>[].obs; // 预览数据行

  // ── 数据行数计算 ──────────────────────────────────────────
  int get lineCount {
    final d = int.tryParse(day.value) ?? 0;
    if (mpType.value == 'Rtd') {
      return 60 * 24 * d; // 每分钟一条
    } else {
      if (type.value == 'hour') {
        return 24 * d; // 每小时一条
      } else {
        return d; // 每天一条
      }
    }
  }

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
  String _packLine(int time) {
    final val = _randomValue();
    return '${metric.value} $time $val '
        'mn=${mn.value} ec=${ec.value} mp=${mp.value} '
        'md=${md.value} mpType=${mpType.value}\n';
  }

  // ── 随机值生成 ────────────────────────────────────────────
  String _randomValue() {
    final min = int.tryParse(valueMin.value) ?? 0;
    final max = int.tryParse(valueMax.value) ?? 100;
    final value = (Random().nextDouble() * (max - min) + min).round();
    return value.toString();
  }

  // ── 批量生成 ──────────────────────────────────────────────
  void _addPack() {
    final baseTime = utils.dateStringToTimestamp(timeStart.value).toInt();

    for (int i = 0; i < lineCount; i++) {
      final int step;
      if (mpType.value == 'Rtd') {
        step = 60;
      } else if (type.value == 'hour') {
        step = 3600;
      } else {
        step = 3600 * 24;
      }
      TSDBData.add(_packLine(baseTime + step * i));
    }
  }

  // ── 输入校验 ──────────────────────────────────────────────
  List<String> _validate() {
    final errors = <String>[];

    if (metric.value.trim().isEmpty) errors.add('metric 不能为空');
    if (mn.value.trim().isEmpty) errors.add('mn 不能为空');
    if (ec.value.trim().isEmpty) errors.add('ec 不能为空');
    if (mp.value.trim().isEmpty) errors.add('mp 不能为空');
    if (md.value.trim().isEmpty) errors.add('md 不能为空');

    final d = int.tryParse(day.value);
    if (d == null || d <= 0) errors.add('day 必须是大于 0 的整数');
    if (d != null && d > 365) errors.add('day 最大支持 365 天');

    final vMin = int.tryParse(valueMin.value);
    final vMax = int.tryParse(valueMax.value);
    if (vMin == null) errors.add('valueMin 必须是整数');
    if (vMax == null) errors.add('valueMax 必须是整数');
    if (vMin != null && vMax != null && vMin > vMax) {
      errors.add('valueMin 不能大于 valueMax');
    }

    try {
      utils.dateStringToTimestamp(timeStart.value);
    } catch (_) {
      errors.add('timeStart 格式错误，请使用 YYYY-MM-DD HH:mm:ss');
    }

    return errors;
  }

  // ── 内部存储 ──────────────────────────────────────────────
  List<String> TSDBData = [];
}

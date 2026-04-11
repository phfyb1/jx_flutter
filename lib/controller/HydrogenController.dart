import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jx_flutter/util/ControllerUtils.dart' show saveToFile;

// ─────────────────────────────────────────────
// 结构化结果数据
// ─────────────────────────────────────────────
class HydrogenSQLItem {
  final String category; // 分类标签
  final String sql; // SQL 语句
  const HydrogenSQLItem({required this.category, required this.sql});
}

// ─────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────
class HydrogenController extends GetxController {
  // ── 表单字段 ──
  final username = ''.obs;
  final password = ''.obs;
  final hydrogenCode = ''.obs;
  final hydrogenGunCode = ''.obs;
  final hydrogenContainersNum = ''.obs;

  // ── 状态 ──
  final isGenerated = false.obs;
  final results = <HydrogenSQLItem>[].obs;
  final errorMessage = ''.obs;

  // ── 校验 ──
  String? validate() {
    if (hydrogenCode.value.trim().isEmpty) {
      return '请填写加氢站编码';
    }
    if (password.value.trim().isEmpty) {
      return '请填写密码';
    }
    return null;
  }

  // ── 核心逻辑 ──
  void generate() {
    errorMessage.value = '';
    final err = validate();
    if (err != null) {
      errorMessage.value = err;
      Get.snackbar('输入错误', err,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red);
      return;
    }

    results.clear();

    _createAPITable();
    _createRealDataTable();
    _createStatusTable();
    _createGunRealTimeTable();
    _createTransactionTable();
    _createContainerRealTimeTable();
    _createStorageRealTimeTable();
    _createStorageTable();
    _createAlarmTable();

    isGenerated.value = true;
  }

  void clear() {
    results.clear();
    errorMessage.value = '';
    isGenerated.value = false;
    username.value = '';
    password.value = '';
    hydrogenCode.value = '';
    hydrogenGunCode.value = '';
    hydrogenContainersNum.value = '';
  }

  // ── 9 个建表方法 ──
  void _add(String category, String sql) =>
      results.add(HydrogenSQLItem(category: category, sql: sql));

  void _createAPITable() {
    _add('加氢站接口账密表',
        'CREATE TABLE IF NOT EXISTS db_hydrogen_station_event_${hydrogenCode.value} USING db_hydrogen_station_event TAGS ("${hydrogenCode.value}","${password.value}");');
  }

  void _createRealDataTable() {
    if (username.value.trim().isEmpty) return;
    _add('平台实时数据用户名密码表',
        'CREATE TABLE IF NOT EXISTS db_hydrogen_platform_event_${username.value} USING db_hydrogen_platform_event TAGS ("${username.value}","${password.value}");');
  }

  void _createStatusTable() {
    _add('加氢站状态数据子表',
        'CREATE TABLE IF NOT EXISTS db_hydrogen_operation_status_${hydrogenCode.value} USING db_hydrogen_operation_status TAGS ("${hydrogenCode.value}");');
  }

  void _createGunRealTimeTable() {
    _add('加氢机实时信息子表',
        'CREATE TABLE IF NOT EXISTS db_hydrogenator_real_time_info_${hydrogenCode.value} USING db_hydrogenator_real_time_info TAGS ("${hydrogenCode.value}");');
  }

  void _createTransactionTable() {
    if (hydrogenGunCode.value.trim().isEmpty) return;
    final guns = hydrogenGunCode.value
        .split(RegExp(r'[,，]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    for (final gun in guns) {
      _add('加氢机交易记录子表',
          'CREATE TABLE IF NOT EXISTS db_hydrogenator_transaction_record_${hydrogenCode.value}_$gun USING db_hydrogenator_transaction_record TAGS ("${hydrogenCode.value}","$gun");');
    }
  }

  void _createContainerRealTimeTable() {
    _add('压缩机实时信息子表',
        'CREATE TABLE IF NOT EXISTS db_compressor_real_time_info_${hydrogenCode.value} USING db_compressor_real_time_info TAGS ("${hydrogenCode.value}");');
  }

  void _createStorageRealTimeTable() {
    _add('储氢容器实时信息子表',
        'CREATE TABLE IF NOT EXISTS db_hydrogen_containers_real_time_info_${hydrogenCode.value} USING db_hydrogen_containers_real_time_info TAGS ("${hydrogenCode.value}");');
  }

  void _createStorageTable() {
    if (hydrogenContainersNum.value.trim().isEmpty) return;
    final containers = hydrogenContainersNum.value
        .split(RegExp(r'[,，]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    for (final c in containers) {
      _add('储氢容器定期更新数据子表',
          'CREATE TABLE IF NOT EXISTS db_hydrogen_containers_periodic_update_${hydrogenCode.value}_$c USING db_hydrogen_containers_periodic_update TAGS ("${hydrogenCode.value}","$c");');
    }
  }

  void _createAlarmTable() {
    _add('加氢站报警数据表',
        'CREATE TABLE IF NOT EXISTS db_hydrogen_abnormal_alarm_${hydrogenCode.value} USING db_hydrogen_abnormal_alarm TAGS ("${hydrogenCode.value}");');
  }

  // ── 复制到剪贴板 ──
  void copyItem(HydrogenSQLItem item) {
    Clipboard.setData(ClipboardData(text: item.sql));
    Get.snackbar('已复制', '${item.category} SQL 已复制到剪贴板',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green);
  }

  // ── 下载全部 SQL ──
  Future<void> downloadAll(BuildContext context) async {
    if (results.isEmpty) return;
    final sb = StringBuffer();
    for (final item in results) {
      sb.writeln('-- ${item.category}');
      sb.writeln(item.sql);
      sb.writeln();
    }
    await saveToFile(
      content: sb.toString(),
      fileName: 'hydrogen_sql_${hydrogenCode.value}.sql',
    );
  }

  // ── 统计 ──
  int get totalTables => results.length;
}

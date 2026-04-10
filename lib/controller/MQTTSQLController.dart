import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jx_flutter/util/ControllerUtils.dart' show sha256, saveToFile;

// ─────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────
class MQTTSQLController extends GetxController {
  // ── 表单字段 ──
  final username = ''.obs;
  final pwd = ''.obs;
  final clientId = ''.obs;
  final salt = 'iots'.obs;
  final access = '2'.obs;
  final topic = '/iot/xpsj/v2/%c/thirdParty/realtimeData'.obs;
  final remark = ''.obs;

  // ── 状态 ──
  final show = false.obs;
  final buttonText = '生成 SQL'.obs;
  final errorMessage = ''.obs;

  // ── 校验 ──
  String? validate() {
    if (username.value.trim().isEmpty) {
      return '请填写用户名（username）';
    }
    return null;
  }

  // ── 核心逻辑 ──
  void _computeAndGenerate() {
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

    show.value = true;
    buttonText.value = '重新填写';
    // 触发 Obx 重建（generatedSql 依赖的 Rx 值已更新）
    update();
  }

  // ── 按钮点击（生成 / 重新填写） ──
  void handleButton() {
    if (show.value) {
      _resetAll();
    } else {
      _computeAndGenerate();
    }
  }

  void _resetAll() {
    show.value = false;
    buttonText.value = '生成 SQL';
    errorMessage.value = '';
    username.value = '';
    pwd.value = '';
    clientId.value = '';
    salt.value = 'iots';
    access.value = '2';
    topic.value = '/iot/xpsj/v2/%c/thirdParty/realtimeData';
    remark.value = '';
  }

  // ── 复制到剪贴板 ──
  void copySql(String sql) {
    Clipboard.setData(ClipboardData(text: sql));
    Get.snackbar('已复制', 'SQL 已复制到剪贴板',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green);
  }

  // ── 下载 .sql 文件 ──
  Future<void> downloadSql() async {
    if (!show.value || username.value.isEmpty) return;
    await saveToFile(
      content: _buildSqlContent(),
      fileName: 'mqtt_sql_${username.value}.sql',
    );
  }

  String _buildSqlContent() {
    final effectivePwd =
        pwd.value.trim().isEmpty ? '${username.value}hthj' : pwd.value.trim();
    final effectiveClientId =
        clientId.value.trim().isEmpty ? username.value : clientId.value.trim();
    final effectiveSalt =
        salt.value.trim().isEmpty ? 'iots' : salt.value.trim();
    final effectiveAccess =
        access.value.trim().isEmpty ? '2' : access.value.trim();
    final sha256Result = sha256(effectiveSalt, effectivePwd);
    return '''
USE mqtt;
SET collation_connection = 'utf8mb4_unicode_ci';
SET collation_server = 'utf8mb4_unicode_ci';
-- 提供给网关的用户名，一般使用设备的序列号SN
SET @username = '$username';
-- 密码：salt + 密码 sha256加密，默认salt=iots，密码默认username+hthj
SET @password = '$sha256Result';
-- ClientId，可自定义，物联网一般使用SN
SET @clientid = '$effectiveClientId';
-- Salt，用于密码加密，默认iots
SET @salt = '$effectiveSalt';
-- 权限：1:subscribe, 2:publish, 3:pubsub，默认2
SET @access = '$effectiveAccess';
-- Topic
SET @topic = '$topic';
-- 备注
SET @remark = '$remark';
INSERT INTO `mqtt_user` (username, password, salt, remark) VALUES (@username, @password, @salt, @remark);
INSERT INTO `mqtt_acl` (username, clientid, access, topic) VALUES (@username, @clientid, @access, @topic);''';
  }

  // ── 生成后的完整 SQL（供 Page 渲染） ──
  String get generatedSql =>
      show.value ? _buildSqlContent() : '';
}

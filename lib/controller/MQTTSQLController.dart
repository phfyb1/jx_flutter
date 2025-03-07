// ignore_for_file: unused_import, unnecessary_import, avoid_web_libraries_in_flutter, unused_local_variable, unrelated_type_equality_checks, unnecessary_new, avoid_print, prefer_typing_uninitialized_variables, non_constant_identifier_names, unnecessary_overrides, file_names

import 'dart:html';
import 'dart:math';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// import 'dart:js' as js;
import 'package:intl/intl.dart';
import '../util/ControllerUtils.dart' as utils;

class MQTTSQLController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  var userName = ''.obs;
  var pwd = ''.obs;
  var clientId = ''.obs; //默认和userName一样
  var salt = 'iots'.obs; //默认iots
  var access = '2'.obs; //1:subscribe,2: publish, 3: pubsub
  var topic = '/iot/xpsj/v2/%c/thirdParty/realtimeData'.obs; //订阅的topic
  var remark = ''.obs; //备注给谁用的
  var SQL = ''.obs;
  var sha256Result = ''.obs;

  var show = false.obs;
  var buttonText = '生成SQL'.obs;

  clean() {
    show.value = false;
    buttonText.value = '生成SQL';
  }

  //对pwd进行sha256加密
  sha256(salt, pwd) {
    if (pwd.isEmpty) {
      pwd = userName.value + 'hthj';
    }
    sha256Result.value = utils.sha256(salt, pwd);
    // return sha256Result;
  }

  ClientId(value) {
    value.isEmpty ? clientId.value = userName.value : clientId.value = value;
  }

  product() {
    show.value = true;
    buttonText.value = '清空结果';

    SQL.value = '''USE mqtt;
SET collation_connection = 'utf8mb4_unicode_ci';
SET collation_server = 'utf8mb4_unicode_ci';
-- 提供给网关的用户名，一般使用设备的序列号SN
SET @username = '${userName.value}';
-- 可自定义，物联网一般使用{SN}hthj，密码需要salt+密码进行sha256加密，salt默认使用了iots，在线加密 http://www.ttmd5.com/hash.php?type=9
SET @password = '${sha256Result.value}';
-- 可自定义，物联网一般使用SN
SET @clientid = '${clientId.value}';
-- 用于密码加密，可使用默认
SET @salt = '${salt.value}';
-- 可使用默认,1: subscribe, 2: publish, 3: pubsub
SET @access = '${access.value}';
-- 可使用默认
SET @topic = '${topic.value}';
-- 备注这个用户是给谁的
SET @remark = '${remark.value}';
INSERT INTO `mqtt_user` (username, password, salt, remark) VALUES (@username, @password, @salt, @remark);
INSERT INTO `mqtt_acl` (username, clientid, access, topic) VALUES (@username, @clientid, @access, @topic);''';
  }
}

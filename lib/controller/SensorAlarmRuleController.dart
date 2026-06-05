import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

enum StatusType { none, info, success, error }

class MetricConfig {
  String elementCname;
  String elementEname;
  String sensorFieldId;
  String sensorTypeId;
  String sensorSubtypeId;

  MetricConfig({
    this.elementCname = '',
    this.elementEname = '',
    this.sensorFieldId = '1',
    this.sensorTypeId = '101',
    this.sensorSubtypeId = '',
  });

  Map<String, dynamic> toJson() => {
        'element_cname': elementCname,
        'element_ename': elementEname,
        'sensor_field_id': sensorFieldId,
        'sensor_type_id': sensorTypeId,
        'sensor_subtype_id': sensorSubtypeId,
      };
}

class GeneratedFile {
  final String name;
  final String content;

  GeneratedFile({required this.name, required this.content});
}

class SensorAlarmRuleController extends GetxController {
  // 配置字段
  final RxString collectorId = 'e2394681b66611f0b4020242ac120002'.obs;
  final RxString projectId = '8d9b2673ea3f11eca1710cda411d59a5'.obs;
  final RxString firmId = '91331100774388264R'.obs;
  final RxString companyName = ''.obs;
  final RxString metric = 'asoco.aj.factory-dcs'.obs;

  // 文件相关
  final RxString xlsxFileName = ''.obs;
  Uint8List? xlsxData;
  List<dynamic> excelData = [];

  // 指标类型配置列表
  final RxList<MetricConfig> metricsConfig = <MetricConfig>[].obs;

  // 状态相关
  final RxString statusMessage = ''.obs;
  final Rx<StatusType> statusType = StatusType.none.obs;
  final RxBool isGenerating = false.obs;

  // 生成结果
  final RxMap<String, String> generatedFiles = <String, String>{}.obs;
  final RxMap<String, int> fileCounts = <String, int>{}.obs;
  final RxBool hasResult = false.obs;

  // 传感器ID映射
  Map<String, String> elementCodeToSensorId = {};

  @override
  void onInit() {
    super.onInit();
    // 初始化默认的指标类型配置
    _initDefaultMetrics();
  }

  void _initDefaultMetrics() {
    metricsConfig.addAll([
      MetricConfig(
        elementCname: '温度',
        elementEname: 'temp',
        sensorFieldId: '1',
        sensorTypeId: '101',
        sensorSubtypeId: '1010005',
      ),
      MetricConfig(
        elementCname: '压力',
        elementEname: 'pressure',
        sensorFieldId: '1',
        sensorTypeId: '101',
        sensorSubtypeId: '1010001',
      ),
      MetricConfig(
        elementCname: '液位',
        elementEname: 'liquidLevel',
        sensorFieldId: '1',
        sensorTypeId: '101',
        sensorSubtypeId: '1010003',
      ),
      MetricConfig(
        elementCname: '可燃气体',
        elementEname: 'combustibleGas',
        sensorFieldId: '1',
        sensorTypeId: '101',
        sensorSubtypeId: '1010006',
      ),
      MetricConfig(
        elementCname: '有毒气体',
        elementEname: 'poisonousGas',
        sensorFieldId: '1',
        sensorTypeId: '101',
        sensorSubtypeId: '1010007',
      ),
    ]);
  }

  void addMetricConfig() {
    metricsConfig.add(MetricConfig());
  }

  void removeMetricConfig(int index) {
    if (metricsConfig.length > 1) {
      metricsConfig.removeAt(index);
    }
  }

  void updateStatus(String message, StatusType type) {
    statusMessage.value = message;
    statusType.value = type;
  }

  String getSafeStringValue(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  double? parseNumber(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Future<void> pickXlsxFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      xlsxFileName.value = result.files.single.name;
      xlsxData = result.files.single.bytes;
      updateStatus(
          '已选择Excel文件: ${result.files.single.name}', StatusType.success);
    }
  }

  Future<void> processFiles() async {
    if (xlsxData == null) {
      updateStatus('请先上传Excel文件', StatusType.error);
      return;
    }

    if (companyName.value.isEmpty) {
      updateStatus('请输入企业名称', StatusType.error);
      return;
    }

    // 检查指标类型配置
    final validMetrics = metricsConfig
        .where((m) => m.elementCname.isNotEmpty && m.elementEname.isNotEmpty)
        .toList();
    if (validMetrics.isEmpty) {
      updateStatus('请至少配置一个有效的指标类型', StatusType.error);
      return;
    }

    isGenerating.value = true;
    updateStatus('开始处理文件...', StatusType.info);

    try {
      final currentTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      // 读取Excel数据
      readExcelData();

      // 构建指标映射：支持 "温度WD" 这类 "中文名+缩写" 的格式
      // key 用中文名，同时记录所有匹配到的原始 Excel 值用于后续显示
      final metricMap = <String, MetricConfig>{};
      final excelMetricToConfig = <String, MetricConfig>{};
      for (var m in validMetrics) {
        metricMap[m.elementCname] = m;
        excelMetricToConfig[m.elementCname] = m;
      }

      // 生成基础UUID
      String baseUUID = _generateBaseUUID();

      // 步骤0：生成传感器SQL和报警规则JSON
      final (sensorSQL, sensorCount) =
          _generateSensorSQL(excelData, metricMap, baseUUID, currentTime);
      final alarmRulesJson =
          _generateAlarmRulesJson(excelData, metricMap, baseUUID);

      // 步骤2：生成报警规则SQL
      final (ruleSQL, ruleCount) =
          _generateRuleSQL(alarmRulesJson, currentTime);

      // 步骤3：生成报警算法SQL
      final (algorithmSQL, algoCount) =
          _generateAlgorithmSQL(alarmRulesJson, currentTime);

      // 步骤4：生成规则和算法绑定SQL
      final (ruleAlgorithmRelSQL, relCount) =
          _generateRuleAlgorithmRelSQL(alarmRulesJson, currentTime);

      // 步骤5：生成传感器绑定规则SQL
      final (sensorRuleRelSQL, sensorRelCount) =
          _generateSensorRuleRelSQL(alarmRulesJson, currentTime);

      // 步骤6：生成添加metric到database的SQL
      final (metricSQL, metricCount) =
          _generateMetricSQL(alarmRulesJson, currentTime);

      // 保存生成的文件
      generatedFiles['0insert_iot_device_sensor.sql'] = sensorSQL;
      generatedFiles['1insert_single_rule.sql'] = ruleSQL;
      generatedFiles['2insert_iot_alarm_algorithm.sql'] = algorithmSQL;
      generatedFiles['3insert_iot_alarm_rule_single_algorithm_rel.sql'] =
          ruleAlgorithmRelSQL;
      generatedFiles['4insert_iot_alarm_rule_single_sensor_rel.sql'] =
          sensorRuleRelSQL;
      generatedFiles['5iot_device_sensor_database.sql'] = metricSQL;
      // JSON预览（用于对照检查）
      generatedFiles['_alarm_rules_preview.json'] = jsonEncode(alarmRulesJson);
      fileCounts['_alarm_rules_preview.json'] = alarmRulesJson.length;

      // 使用生成函数返回的计数
      fileCounts['0insert_iot_device_sensor.sql'] = sensorCount;
      fileCounts['1insert_single_rule.sql'] = ruleCount;
      fileCounts['2insert_iot_alarm_algorithm.sql'] = algoCount;
      fileCounts['3insert_iot_alarm_rule_single_algorithm_rel.sql'] = relCount;
      fileCounts['4insert_iot_alarm_rule_single_sensor_rel.sql'] =
          sensorRelCount;
      fileCounts['5iot_device_sensor_database.sql'] = metricCount;

      hasResult.value = true;
      updateStatus('所有SQL文件生成成功！', StatusType.success);
    } catch (e) {
      updateStatus('生成失败: ${e.toString()}', StatusType.error);
    } finally {
      isGenerating.value = false;
    }
  }

  void readExcelData() {
    var excel = Excel.decodeBytes(xlsxData!);

    // 打印所有工作表名称
    print('所有工作表: ${excel.tables.keys.toList()}');

    // 明确指定读取"指标信息"工作表
    var sheet = excel['指标信息'];
    if (sheet == null) {
      throw Exception('Excel文件中没有找到"指标信息"工作表');
    }

    List<List<dynamic>> rows = sheet.rows;
    if (rows.length < 4) {
      throw Exception('Excel文件格式不正确，数据行数不足');
    }

    // 数据从第4行（索引3）开始
    List<List<dynamic>> dataRows = rows.sublist(3);

    // 根据实际列名动态确定列索引
    List<dynamic> headerRow = rows[1];
    final colMap = <String, int>{};

    for (int i = 0; i < headerRow.length; i++) {
      var cell = headerRow[i];
      var headerName = cell?.value?.toString() ?? '';
      if (headerName.contains('设备名称编号')) {
        colMap['设备名称编号*'] = i;
      } else if (headerName.contains('指标类型') && !headerName.contains('编码')) {
        colMap['指标类型*'] = i;
      } else if (headerName.contains('指标编码')) {
        colMap['指标编码'] = i;
      } else if (headerName.contains('指标位号')) {
        colMap['指标位号*'] = i;
      } else if (headerName.contains('计量单位')) {
        colMap['计量单位*'] = i;
      } else if (headerName.contains('仪表量程下限')) {
        colMap['仪表量程下限*'] = i;
      } else if (headerName.contains('仪表量程上限')) {
        colMap['仪表量程上限*'] = i;
      } else if (headerName.contains('低低报')) {
        colMap['低低报'] = i;
      } else if (headerName.contains('低报') && !headerName.contains('低低')) {
        colMap['低报'] = i;
      } else if (headerName.contains('高高报')) {
        colMap['高高报'] = i;
      } else if (headerName.contains('高报') && !headerName.contains('高高')) {
        colMap['高报'] = i;
      }
    }

    excelData = dataRows.map((row) {
      final obj = <String, dynamic>{};
      colMap.forEach((key, colIndex) {
        if (colIndex < row.length && row[colIndex] != null) {
          obj[key] = row[colIndex].value;
        } else {
          obj[key] = null;
        }
      });
      return obj;
    }).where((row) {
      final values = row.values.toList();
      return values.any((v) => v != null && getSafeStringValue(v).isNotEmpty);
    }).toList();
  }

  String _generateUUID() {
    return Uuid().v4().replaceAll('-', '');
  }

  String _generateBaseUUID() {
    return _generateUUID().substring(0, 28);
  }

  String _padLeft(int num, int width) {
    return num.toString().padLeft(width, '0');
  }

  /// 从 Excel 指标类型值中匹配配置，支持关键字包含匹配
  /// 策略：
  ///   1. 特殊短关键词优先（可燃 → 可燃气体，有毒 → 有毒气体）
  ///   2. 完整中文名 contains 匹配（"温度" in "温度WD" ✅）
  ///   3. 关键字可出现在字符串任意位置
  MetricConfig? _matchMetricConfig(
      String rawMetric, Map<String, MetricConfig> metricMap) {
    final raw = rawMetric.trim();

    for (var entry in metricMap.entries) {
      final configName = entry.key;

      // 特殊短关键词：可燃气体只需"可燃"，有毒气体只需"有毒"
      String? shortKeyword;
      if (configName == '可燃气体') shortKeyword = '可燃';
      if (configName == '有毒气体') shortKeyword = '有毒';

      if (shortKeyword != null && raw.contains(shortKeyword)) {
        return entry.value;
      }

      // 通用 contains 匹配
      if (raw.contains(configName)) {
        return entry.value;
      }
    }

    return null;
  }

  (String sql, int count) _generateSensorSQL(
      List<dynamic> data,
      Map<String, MetricConfig> metricMap,
      String baseUUID,
      String currentTime) {
    final sqlStatements = <String>[];
    int counter = 1;

    for (var item in data) {
      final mappedItem = _mapExcelRow(item);

      final metricCname = mappedItem['指标类型*']?.toString() ?? '';
      final mapping = _matchMetricConfig(metricCname, metricMap);
      if (mapping == null) continue;
      final sensorId = baseUUID + _padLeft(counter, 4);
      counter++;

      final elementCode = mappedItem['指标位号*']?.toString() ?? '';
      if (elementCode.isNotEmpty) {
        elementCodeToSensorId[elementCode] = sensorId;
      }

      final scopesMin = mappedItem['仪表量程下限*'];
      final scopesMax = mappedItem['仪表量程上限*'];

      final sql = """INSERT INTO \`iot_server\`.\`iot_device_sensor\` (
    id, source_code, target_code, name, collector_id, sensor_field_id, sensor_type_id,
    sensor_subtype_id, element_code, element_ename, element_cname, source_unit, target_unit,
    scopes_min_data, scopes_max_data, project_id, monitor_status, online_status, place_firm_id,
    belong_firm_id, install_date, install_position_code, install_position_desc, longitude, latitude,
    introduce, photo_path, produce_firm_id, supply_firm_id, build_firm_id, operation_firm_id,
    device_type, operation_expire_time, guarantee_expire_time, sort, last_online_time,
    last_offline_time, device_status, remark, create_person, update_person, create_date_time,
    update_date_time, tenant_id
) VALUES (
    "$sensorId",
    "${elementCode.replaceAll("'", "''")}",
    "${(mappedItem['指标编码'] ?? '').toString().replaceAll("'", "''")}",
    "${(mappedItem['设备名称编号*'] ?? '').toString().replaceAll("'", "''")}",
    '${collectorId.value}',
    '${mapping.sensorFieldId}',
    '${mapping.sensorTypeId}',
    '${mapping.sensorSubtypeId}',
    "${elementCode.replaceAll("'", "''")}",
    '${mapping.elementEname}',
    '${mapping.elementCname}',
    '${mappedItem['计量单位*']}',
    '${mappedItem['计量单位*']}',
    ${scopesMin != null ? double.tryParse(scopesMin.toString()) ?? 'NULL' : 'NULL'},
    ${scopesMax != null ? double.tryParse(scopesMax.toString()) ?? 'NULL' : 'NULL'},
    '${projectId.value}',
    1, 0,
    '${firmId.value}',
    '${firmId.value}',
    NULL, '', '', NULL, NULL,
    '', '', '', '', '', '','', 
    NULL, NULL, 255, NULL, NULL,
    1, NULL,
    '1', '1',
    '$currentTime', '$currentTime',
    '1'
);""";

      sqlStatements.add(sql);
    }

    if (sqlStatements.isEmpty) return ('-- 没有生成传感器SQL', 0);

    // 合并为单个INSERT语句
    final valuesPart = sqlStatements
        .map((s) {
          // 提取 VALUES ( ... ); 中的内容
          final match =
              RegExp(r'VALUES\s*(\([\s\S]*?\));', caseSensitive: false)
                  .firstMatch(s);
          if (match != null) return match.group(1);
          return null;
        })
        .whereType<String>()
        .join(',\n');

    final header = sqlStatements.first.split('VALUES').first;
    final mergedSql = "${header}VALUES\n$valuesPart;";

    return (
      "START TRANSACTION;\nSET FOREIGN_KEY_CHECKS = 0;\n$mergedSql\nSET FOREIGN_KEY_CHECKS = 1;\nCOMMIT;",
      sqlStatements.length
    );
  }

  List<dynamic> _generateAlarmRulesJson(List<dynamic> data,
      Map<String, MetricConfig> metricMap, String baseUUID) {
    final alarmRulesMap = <String, Map<String, dynamic>>{};
    int counter = 1;

    // 先建立 elementCode -> sensorId 映射（保留所有行）
    elementCodeToSensorId.clear();
    for (var item in data) {
      final mappedItem = _mapExcelRow(item);
      final metricCname = mappedItem['指标类型*']?.toString() ?? '';
      if (_matchMetricConfig(metricCname, metricMap) == null) continue;

      final sensorId = baseUUID + _padLeft(counter, 4);
      counter++;
      final elementCode = mappedItem['指标位号*']?.toString() ?? '';
      if (elementCode.isNotEmpty) {
        elementCodeToSensorId[elementCode] = sensorId;
      }
    }

    // 构建报警规则
    for (var item in data) {
      final mappedItem = _mapExcelRow(item);
      if (mappedItem['低低报'] == null &&
          mappedItem['低报'] == null &&
          mappedItem['高报'] == null &&
          mappedItem['高高报'] == null) {
        continue;
      }
      final metricCname = mappedItem['指标类型*']?.toString() ?? '';
      final mapping = _matchMetricConfig(metricCname, metricMap);
      if (mapping == null) continue;

      // 使用配置中的中文名称作为规则标识（"温度" 而非 "温度WD"）
      final configCname = mapping.elementCname;

      final ll = _parseNum(mappedItem['低低报']);
      final l = _parseNum(mappedItem['低报']);
      final h = _parseNum(mappedItem['高报']);
      final hh = _parseNum(mappedItem['高高报']);

      final key = '${configCname}_${ll}_${l}_${h}_${hh}';
      if (!alarmRulesMap.containsKey(key)) {
        alarmRulesMap[key] = {
          'indicator_type': configCname,
          'rule_tuple': [ll, l, h, hh],
          'devices': <Map<String, dynamic>>[],
        };
      }

      (alarmRulesMap[key]!['devices'] as List<Map<String, dynamic>>).add({
        '设备名称编号': mappedItem['设备名称编号*'],
        '指标位号': mappedItem['指标位号*'],
        '计量单位': mappedItem['计量单位*'],
      });
    }

    // 生成JSON
    final jsonOutput = <Map<String, dynamic>>[];
    int ruleIndex = 1;

    for (var entry in alarmRulesMap.entries) {
      final rule = entry.value;
      final indicatorType = rule['indicator_type'] as String;
      final ruleTuple = rule['rule_tuple'] as List<dynamic?>;
      final devices = rule['devices'] as List<Map<String, dynamic>>;

      final ll = ruleTuple[0];
      final l = ruleTuple[1];
      final h = ruleTuple[2];
      final hh = ruleTuple[3];

      final sensorsName =
          devices.map((d) => d['设备名称编号']?.toString() ?? '').toList();
      final sensorsCode =
          devices.map((d) => d['指标位号']?.toString() ?? '').toList();
      final sensorsId =
          sensorsCode.map((code) => elementCodeToSensorId[code] ?? '').toList();

      jsonOutput.add({
        'RuleId': _generateUUID(),
        'RuleName': '${indicatorType}_$ruleIndex',
        'RuleValue': '低低报:$ll,低报:$l,高报:$h,高高报:$hh',
        'SensorCount': sensorsName.length,
        'SensorsName': sensorsName.map((e) => e?.toString() ?? '').toList(),
        'SensorsCode': sensorsCode.map((e) => e?.toString() ?? '').toList(),
        'SensorsID': sensorsId.map((e) => e?.toString() ?? '').toList(),
        'low_low_alarm': ll != null ? _generateUUID() : null,
        'low_alarm': l != null ? _generateUUID() : null,
        'low_equal':
            (ll != null && l != null && ll != l) ? _generateUUID() : null,
        'high_equal':
            (hh != null && h != null && hh != h) ? _generateUUID() : null,
        'high_alarm': h != null ? _generateUUID() : null,
        'high_high_alarm': hh != null ? _generateUUID() : null,
      });

      ruleIndex++;
    }

    return jsonOutput;
  }

  Map<String, dynamic> _mapExcelRow(dynamic item) {
    return {
      '设备名称编号*': item['设备名称编号*'],
      '指标类型*': item['指标类型*'],
      '指标编码': item['指标编码'],
      '指标位号*': item['指标位号*'],
      '计量单位*': item['计量单位*'],
      '仪表量程下限*': item['仪表量程下限*'],
      '仪表量程上限*': item['仪表量程上限*'],
      '低低报': item['低低报'],
      '低报': item['低报'],
      '高报': item['高报'],
      '高高报': item['高高报'],
    };
  }

  double? _parseNum(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    final parsed = double.tryParse(val.toString());
    return parsed;
  }

  (String sql, int count) _generateRuleSQL(
      List<dynamic> alarmRules, String currentTime) {
    final sqlStatements = <String>[];

    for (var rule in alarmRules) {
      final ruleValueStr = rule['RuleValue']?.toString() ?? '';
      if (ruleValueStr.isEmpty) {
        continue;
      }

      final ruleValueDict = <String, String>{};
      ruleValueStr.split(',').forEach((item) {
        final parts = item.split(':');
        if (parts.length == 2) {
          ruleValueDict[parts[0].trim()] = parts[1].trim();
        }
      });

      final remarkParts = <String>[];
      ruleValueDict.forEach((key, value) {
        if (value.isNotEmpty && value != 'None' && value != 'null') {
          remarkParts.add('$key:$value');
        }
      });
      final remark = remarkParts.join(', ').replaceAll("'", "''");

      final sql = """INSERT INTO \`iot_server\`.\`iot_alarm_rule_single\`
(\`id\`, \`tenant_id\`, \`name\`, \`normal_inhibit\`, \`alarm_inhibit\`, \`enabled\`, \`repeat_alarm\`, \`remark\`, \`create_person\`, \`update_person\`, \`create_date_time\`, \`update_date_time\`)
VALUES
('${rule['RuleId']}', '1', '${companyName.value}${rule['RuleName']}', 0, 0, 0, 0, '$remark', '1', '1', '$currentTime', '$currentTime');""";

      sqlStatements.add(sql);
    }

    if (sqlStatements.isEmpty) return ('-- 没有生成报警规则SQL', 0);

    // 合并为单个INSERT语句
    final valuesPart = sqlStatements
        .map((s) {
          final match =
              RegExp(r'VALUES\s*(\([\s\S]*?\));', caseSensitive: false)
                  .firstMatch(s);
          if (match != null) return match.group(1);
          return null;
        })
        .whereType<String>()
        .join(',\n');

    final header = sqlStatements.first.split('VALUES').first;
    final mergedSql = "${header}VALUES\n$valuesPart;";

    return (
      "START TRANSACTION;\nSET FOREIGN_KEY_CHECKS = 0;\n$mergedSql\nSET FOREIGN_KEY_CHECKS = 1;\nCOMMIT;",
      sqlStatements.length
    );
  }

  (String sql, int count) _generateAlgorithmSQL(
      List<dynamic> alarmRules, String currentTime) {
    final allSqlValues = <String>[];

    for (var rule in alarmRules) {
      final ruleValueStr = rule['RuleValue'] as String;

      final ruleDict = <String, double?>{};
      ruleValueStr.split(',').forEach((item) {
        final parts = item.split(':');
        if (parts.length == 2) {
          ruleDict[parts[0].trim()] = _parseNum(parts[1]);
        }
      });

      double? lowLow = ruleDict['低低报'];
      double? low = ruleDict['低报'];
      double? high = ruleDict['高报'];
      double? highHigh = ruleDict['高高报'];

      // 处理相等情况：低低报和低报相等时只保留低低报
      if (lowLow != null && low != null && lowLow == low) low = null;
      // 处理相等情况：高高报和高报相等时只保留高高报
      if (high != null && highHigh != null && high == highHigh) high = null;

      // 构建 value helper（与 py 保持一致：数值用单引号包裹，NULL 直接 NULL）
      String v(double? d) => d != null ? "'$d'" : 'NULL';

      // 超下限报警（类型6）
      if (lowLow != null) {
        // (6, 1) => low_low_alarm id
        allSqlValues.add(
            "('${rule['low_low_alarm']}', 1, 6, 1, NULL, ${v(lowLow)}, NULL, NULL, '', NULL, NULL, '1', '1', '$currentTime', '$currentTime')");
      } else if (low != null) {
        // (6, 2) => low_alarm id
        allSqlValues.add(
            "('${rule['low_alarm']}', 1, 6, 2, NULL, ${v(low)}, NULL, NULL, '', NULL, NULL, '1', '1', '$currentTime', '$currentTime')");
      }

      // 数值范围内报警 & 相等判断报警（低报）
      if (lowLow != null && low != null) {
        // (0, 2) => low_alarm id（与 py id_mapping 一致）
        allSqlValues.add(
            "('${rule['low_alarm']}', 1, 0, 2, NULL, ${v(lowLow)}, NULL, NULL, '', NULL, NULL, '1', '1', '$currentTime', '$currentTime')");
        // (3, 2) => low_equal id
        allSqlValues.add(
            "('${rule['low_equal']}', 1, 3, 2, NULL, NULL, NULL, ${v(lowLow)}, '', NULL, NULL, '1', '1', '$currentTime', '$currentTime')");
      }

      // 超上限报警（类型5）
      if (highHigh != null) {
        // (5, 4) => high_high_alarm id
        allSqlValues.add(
            "('${rule['high_high_alarm']}', 1, 5, 4, ${v(highHigh)}, NULL, NULL, NULL, '', NULL, NULL, '1', '1', '$currentTime', '$currentTime')");
      } else if (high != null) {
        // (5, 3) => high_alarm id
        allSqlValues.add(
            "('${rule['high_alarm']}', 1, 5, 3, ${v(high)}, NULL, NULL, NULL, '', NULL, NULL, '1', '1', '$currentTime', '$currentTime')");
      }

      // 数值范围内报警 & 相等判断报警（高报）
      if (highHigh != null && high != null) {
        // (0, 3) => high_alarm id（与 py id_mapping 一致）
        allSqlValues.add(
            "('${rule['high_alarm']}', 1, 0, 3, ${v(highHigh)}, ${v(high)}, NULL, NULL, '', NULL, NULL, '1', '1', '$currentTime', '$currentTime')");
        // (3, 3) => high_equal id
        allSqlValues.add(
            "('${rule['high_equal']}', 1, 3, 3, NULL, NULL, NULL, ${v(highHigh)}, '', NULL, NULL, '1', '1', '$currentTime', '$currentTime')");
      }
    }

    if (allSqlValues.isEmpty) return ('-- 没有生成报警算法SQL', 0);

    final sql = """INSERT INTO \`iot_server\`.\`iot_alarm_algorithm\`
(\`id\`, \`tenant_id\`, \`type\`, \`level\`, \`max_value\`, \`min_value\`, \`boolean_value\`, \`equal_value\`, \`remark\`, \`growth_rate_value\`, \`decline_rate_value\`, \`create_person\`, \`update_person\`, \`create_date_time\`, \`update_date_time\`)
VALUES
${allSqlValues.join(',\n')};""";

    return (
      "START TRANSACTION;\nSET FOREIGN_KEY_CHECKS = 0;\n$sql\nSET FOREIGN_KEY_CHECKS = 1;\nCOMMIT;",
      allSqlValues.length
    );
  }

  (String sql, int count) _generateRuleAlgorithmRelSQL(
      List<dynamic> alarmRules, String currentTime) {
    final sqlStatements = <String>[];
    final alarmTypes = [
      'low_low_alarm',
      'low_alarm',
      'low_equal',
      'high_equal',
      'high_alarm',
      'high_high_alarm'
    ];

    for (var rule in alarmRules) {
      for (var alarmType in alarmTypes) {
        final algorithmId = rule[alarmType];
        if (algorithmId != null && algorithmId != 'None') {
          final sql =
              """INSERT INTO \`iot_server\`.\`iot_alarm_rule_single_algorithm_rel\`
(\`id\`, \`rule_id\`, \`algorithm_id\`, \`create_person\`, \`update_person\`, \`create_date_time\`, \`update_date_time\`)
VALUES
('${_generateUUID()}', '${rule['RuleId']}', '$algorithmId', '1', '1', '$currentTime', '$currentTime');""";
          sqlStatements.add(sql);
        }
      }
    }

    if (sqlStatements.isEmpty) return ('-- 没有生成规则和算法绑定SQL', 0);

    // 合并为单个INSERT语句
    final valuesPart = sqlStatements
        .map((s) {
          final match =
              RegExp(r'VALUES\s*(\([\s\S]*?\));', caseSensitive: false)
                  .firstMatch(s);
          if (match != null) return match.group(1);
          return null;
        })
        .whereType<String>()
        .join(',\n');

    final header = sqlStatements.first.split('VALUES').first;
    final mergedSql = "${header}VALUES\n$valuesPart;";

    return (
      "START TRANSACTION;\nSET FOREIGN_KEY_CHECKS = 0;\n$mergedSql\nSET FOREIGN_KEY_CHECKS = 1;\nCOMMIT;",
      sqlStatements.length
    );
  }

  (String sql, int count) _generateSensorRuleRelSQL(
      List<dynamic> alarmRules, String currentTime) {
    final sqlStatements = <String>[];

    for (var rule in alarmRules) {
      final sensorIds = rule['SensorsID'] as List<dynamic>;
      for (var sensorId in sensorIds) {
        if (sensorId != null) {
          final sql =
              """INSERT INTO \`iot_server\`.\`iot_alarm_rule_single_sensor_rel\`
(\`id\`, \`rule_id\`, \`sensor_id\`, \`algorithm_id\`, \`alarm_date\`, \`alarm_data\`, \`alarm_data_type\`, \`alarm_status\`, \`create_person\`, \`update_person\`, \`create_date_time\`, \`update_date_time\`)
VALUES
('${_generateUUID()}', '${rule['RuleId']}', '$sensorId', NULL, NULL, NULL, 'rtd', 0, '1', '1', '$currentTime', '$currentTime');""";
          sqlStatements.add(sql);
        }
      }
    }

    if (sqlStatements.isEmpty) return ('-- 没有生成传感器绑定规则SQL', 0);

    // 合并为单个INSERT语句
    final valuesPart = sqlStatements
        .map((s) {
          final match =
              RegExp(r'VALUES\s*(\([\s\S]*?\));', caseSensitive: false)
                  .firstMatch(s);
          if (match != null) return match.group(1);
          return null;
        })
        .whereType<String>()
        .join(',\n');

    final header = sqlStatements.first.split('VALUES').first;
    final mergedSql = "${header}VALUES\n$valuesPart;";

    return (
      "START TRANSACTION;\nSET FOREIGN_KEY_CHECKS = 0;\n$mergedSql\nSET FOREIGN_KEY_CHECKS = 1;\nCOMMIT;",
      sqlStatements.length
    );
  }

  (String sql, int count) _generateMetricSQL(
      List<dynamic> alarmRules, String currentTime) {
    final valuesLines = <String>[];
    final channels = [0, 1];

    for (var rule in alarmRules) {
      final sensorIds = rule['SensorsID'] as List<dynamic>;
      for (var sid in sensorIds) {
        if (sid != null) {
          for (var ch in channels) {
            valuesLines.add(
                "('$sid', $ch, 0, '${metric.value}', '1', '1', '$currentTime', '$currentTime')");
          }
        }
      }
    }

    if (valuesLines.isEmpty) return ('-- 没有生成metric数据库SQL', 0);
    return (
      "INSERT INTO \`iot_server\`.\`iot_device_sensor_database\` VALUES\n${valuesLines.join(',\n')};",
      valuesLines.length
    );
  }

  void downloadGeneratedFile(String fileName, String content) {
    try {
      if (kIsWeb) {
        final bytes = utf8.encode(content);
        final blob = html.Blob([bytes], 'text/plain');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        updateStatus('文件已开始下载: $fileName', StatusType.success);
      } else {
        _downloadFileDesktop(fileName, content);
      }
    } catch (e) {
      updateStatus('下载文件失败: ${e.toString()}', StatusType.error);
    }
  }

  Future<void> _downloadFileDesktop(String fileName, String content) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$fileName';
      final file = File(path);
      await file.writeAsString(content);
      updateStatus('文件已下载到: $path', StatusType.success);
    } catch (e) {
      updateStatus('下载文件失败: ${e.toString()}', StatusType.error);
    }
  }

  void clearAll() {
    xlsxFileName.value = '';
    xlsxData = null;
    excelData = [];
    generatedFiles.clear();
    fileCounts.clear();
    hasResult.value = false;
    elementCodeToSensorId.clear();
    updateStatus('已清空所有数据', StatusType.success);
  }
}

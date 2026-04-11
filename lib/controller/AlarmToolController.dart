import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/services.dart';
// 导入 intl 包以使用 DateFormat
import 'package:intl/intl.dart';

enum StatusType { none, info, success, error }

class AlarmToolController extends GetxController {
  final RxString xlsxFileName = ''.obs;
  final RxString jsonFileName = ''.obs;
  final RxString status = ''.obs;
  final RxString statusType = ''.obs;
  final RxList<Map<String, dynamic>> sqlFiles = <Map<String, dynamic>>[].obs;

  Uint8List? xlsxData;
  Map<String, dynamic>? sensorData;

  Future<void> pickXlsxFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      xlsxFileName.value = result.files.single.name;
      xlsxData = result.files.single.bytes;
      updateStatus('已选择XLSX文件', StatusType.success);
    }
  }

  Future<void> pickJsonFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      jsonFileName.value = result.files.single.name;
      try {
        String jsonContent = utf8.decode(result.files.single.bytes!);
        dynamic decodedData = json.decode(jsonContent);

        // 处理JSON数组情况，转换为Map结构
        if (decodedData is List) {
          sensorData = {'rows': decodedData};
        } else if (decodedData is Map<String, dynamic>) {
          sensorData = decodedData;
        } else {
          throw Exception('JSON格式不支持，期望Map或List类型');
        }

        updateStatus('已选择JSON文件', StatusType.success);
      } catch (e) {
        final errorMessage = 'JSON文件解析失败: ${e.toString()}';
        updateStatus('$errorMessage (已复制到剪贴板)', StatusType.error);
        Clipboard.setData(ClipboardData(text: errorMessage));
        jsonFileName.value = '';
        sensorData = null;
      }
    }
  }

  Future<void> processFiles() async {
    if (xlsxData == null || sensorData == null) {
      updateStatus('请先上传两个必要的文件', StatusType.error);
      return;
    }

    updateStatus('正在处理数据...', StatusType.info);

    try {
      List<dynamic> alarmRules = parseExcelAndGenerateRules();
      List<Map<String, dynamic>> generatedSqlFiles =
          generateSQLFiles(alarmRules, sensorData!);
      sqlFiles.assignAll(generatedSqlFiles);
      updateStatus(
          '处理完成，共生成 ${generatedSqlFiles.length} 个SQL文件', StatusType.success);
    } catch (e) {
      final errorMessage = '处理出错: ${e.toString()}';
      updateStatus('$errorMessage (已复制到剪贴板)', StatusType.error);
      Clipboard.setData(ClipboardData(text: errorMessage));
      print(e);
    }
  }

  List<dynamic> parseExcelAndGenerateRules() {
    var excel = Excel.decodeBytes(xlsxData!);
    var sheet = excel['指标信息'];
    if (sheet == null) {
      throw Exception('Excel文件中未找到"指标信息"工作表');
    }

    List<List<dynamic>> rows = sheet.rows;
    if (rows.length < 4) throw Exception('Excel文件格式不正确，数据行数不足');

    List<dynamic> headers = rows[1];
    List<List<dynamic>> dataRows = rows.sublist(3);

    Map<String, int> headerIndices = {};
    headers.asMap().forEach(
        (index, header) => headerIndices[getSafeStringValue(header)] = index);

    List<String> requiredColumns = [
      '设备名称编号*',
      '指标类型*',
      '指标位号*',
      '计量单位*',
      '低低报',
      '低报',
      '高报',
      '高高报'
    ];
    List<String> missingCols = requiredColumns
        .where((col) => !headerIndices.containsKey(col))
        .toList();
    if (missingCols.isNotEmpty) {
      throw Exception('Excel文件缺少必要的列: ${missingCols.join(', ')}');
    }

    Map<String, List<Map<String, dynamic>>> alarmRulesMap = {};

    for (var row in dataRows) {
      try {
        // 检查 headerIndices 中对应列是否存在，避免 null 访问
        int? deviceCodeIndex = headerIndices['设备编码'];
        int? indicatorTypeIndex = headerIndices['指标类型*'];
        int? sensorCodeIndex = headerIndices['指标位号*'];
        int? unitIndex = headerIndices['计量单位*'];
        int? lowLowIndex = headerIndices['低低报'];
        int? lowIndex = headerIndices['低报'];
        int? highIndex = headerIndices['高报'];
        int? highHighIndex = headerIndices['高高报'];

        // 确保索引存在且行数据长度足够
        if (deviceCodeIndex == null ||
            deviceCodeIndex >= row.length ||
            indicatorTypeIndex == null ||
            indicatorTypeIndex >= row.length ||
            sensorCodeIndex == null ||
            sensorCodeIndex >= row.length ||
            unitIndex == null ||
            unitIndex >= row.length ||
            lowLowIndex == null ||
            lowLowIndex >= row.length ||
            lowIndex == null ||
            lowIndex >= row.length ||
            highIndex == null ||
            highIndex >= row.length ||
            highHighIndex == null ||
            highHighIndex >= row.length) {
          print('行数据格式不正确，跳过此行');
          continue;
        }

        String deviceCode = getSafeStringValue(row[deviceCodeIndex]);
        String indicatorType = getSafeStringValue(row[indicatorTypeIndex]);
        String sensorCode = getSafeStringValue(row[sensorCodeIndex]);
        String unit = getSafeStringValue(row[unitIndex]);

        double? lowLow = parseNumber(row[lowLowIndex]);
        double? low = parseNumber(row[lowIndex]);
        double? high = parseNumber(row[highIndex]);
        double? highHigh = parseNumber(row[highHighIndex]);

        if (lowLow == null && low == null && high == null && highHigh == null)
          continue;

        String ruleKey =
            json.encode([indicatorType, lowLow, low, high, highHigh]);

        if (!alarmRulesMap.containsKey(ruleKey)) {
          alarmRulesMap[ruleKey] = [];
        }

        alarmRulesMap[ruleKey]!
            .add({'设备名称编号': deviceCode, '指标位号': sensorCode, '计量单位': unit});
      } catch (e) {
        print('处理行数据时出错，跳过此行: $e');
      }
    }

    List<dynamic> jsonOutput = [];
    int ruleIndex = 1;
    Uuid uuid = Uuid();

    alarmRulesMap.forEach((key, devices) {
      List<dynamic> keyParts = json.decode(key);
      String indicatorType = keyParts[0];
      double? lowLow = keyParts[1];
      double? low = keyParts[2];
      double? high = keyParts[3];
      double? highHigh = keyParts[4];

      String? lowLowAlarm, lowAlarm, lowEqual;
      String? highHighAlarm, highAlarm, highEqual;

      if (lowLow != null) {
        lowLowAlarm = uuid.v4().replaceAll('-', '');
        if (low != null && lowLow != low) {
          lowAlarm = uuid.v4().replaceAll('-', '');
          lowEqual = uuid.v4().replaceAll('-', '');
        }
      } else if (low != null) {
        lowAlarm = uuid.v4().replaceAll('-', '');
      }

      if (highHigh != null) {
        highHighAlarm = uuid.v4().replaceAll('-', '');
        if (high != null && highHigh != high) {
          highAlarm = uuid.v4().replaceAll('-', '');
          highEqual = uuid.v4().replaceAll('-', '');
        }
      } else if (high != null) {
        highAlarm = uuid.v4().replaceAll('-', '');
      }

      String ruleName =
          '${companyName.value}_${indicatorType}_$ruleIndex';
      jsonOutput.add({
        'RuleId': uuid.v4().replaceAll('-', ''),
        'RuleName': ruleName,
        'RuleValue': '低低报:$lowLow,低报:$low,高报:$high,高高报:$highHigh',
        'SensorCount': devices.length,
        'SensorsName': devices.map((dev) => dev['设备名称编号']).toList(),
        'SensorsCode': devices.map((dev) => dev['指标位号']).toList(),
        'SensorsID': [],
        'low_low_alarm': lowLowAlarm,
        'low_alarm': lowAlarm,
        'low_equal': lowEqual,
        'high_equal': highEqual,
        'high_alarm': highAlarm,
        'high_high_alarm': highHighAlarm
      });

      ruleIndex++;
    });

    return jsonOutput;
  }

  final RxString companyName = ''.obs;

  List<Map<String, dynamic>> generateSQLFiles(
      List<dynamic> alarmRules, Map<String, dynamic> sensorData) {
    List<Map<String, dynamic>> sqlFiles = [];
    String currentTime = formatDateTime(DateTime.now());
    if (this.companyName.value.isEmpty) {
      throw Exception('公司名称不能为空，请先输入公司名称');
    }
    String companyName = this.companyName.value;

    Map<String, dynamic> ruleResult =
        generateRuleSQL(alarmRules, currentTime, companyName);
    sqlFiles.add({
      'name': '1insert_single_rule.sql',
      'content': ruleResult['sql'],
      'count': ruleResult['count'],
    });

    Map<String, dynamic> algoResult =
        generateAlgorithmSQL(alarmRules, currentTime);
    sqlFiles.add({
      'name': '2insert_iot_alarm_algorithm.sql',
      'content': algoResult['sql'],
      'count': algoResult['count'],
    });

    Map<String, dynamic> relResult =
        generateRuleAlgorithmRelSQL(alarmRules, currentTime);
    sqlFiles.add({
      'name': '3insert_iot_alarm_rule_single_algorithm_rel.sql',
      'content': relResult['sql'],
      'count': relResult['count'],
    });

    Map<String, dynamic> sensorResult =
        generateSensorRelSQL(alarmRules, sensorData, currentTime);
    sqlFiles.add({
      'name': '4insert_iot_alarm_rule_single_sensor_rel.sql',
      'content': sensorResult['sql'],
      'count': sensorResult['count'],
    });

    return sqlFiles;
  }

  Map<String, dynamic> generateRuleSQL(
      List<dynamic> alarmRules, String currentTime, String companyName) {
    List<String> values = [];
    int count = 0;

    for (var rule in alarmRules) {
      count++;
      String ruleId = getSafeStringValue(rule['RuleId']);
      String ruleName = getSafeStringValue(rule['RuleName']);
      String ruleValue = getSafeStringValue(rule['RuleValue']);

      Map<String, String> ruleValueDict = {};
      ruleValue.split(',').forEach((item) {
        List<String> parts = item.split(':');
        if (parts.length == 2) {
          String key = parts[0].trim();
          String value = getSafeStringValue(parts[1]);
          ruleValueDict[key] = value;
        }
      });

      List<String> remarkParts = [];
      ruleValueDict.forEach((key, value) {
        // 与 Python 步骤2一致：过滤 Python None 和字符串 'None'，保留其他值（包括 'null'）
        if (value.isNotEmpty && value != 'None') {
          remarkParts.add('$key:$value');
        }
      });
      String remark = remarkParts.join(', ').replaceAll("'", "''");

      values.add(
          "('$ruleId', '1', '${companyName}${ruleName}', 0, 0, 0, 0, '$remark', '1', '1', '$currentTime', '$currentTime')");
    }

    String sql = "START TRANSACTION;\nSET FOREIGN_KEY_CHECKS = 0;\n"
        "INSERT INTO `iot_server`.`iot_alarm_rule_single` "
        "(`id`, `tenant_id`, `name`, `normal_inhibit`, `alarm_inhibit`, `enabled`, `repeat_alarm`, `remark`, `create_person`, `update_person`, `create_date_time`, `update_date_time`) "
        "VALUES\n${values.join(',\n')};\n"
        "SET FOREIGN_KEY_CHECKS = 1;\nCOMMIT;";
    return {'sql': sql, 'count': count};
  }

  Map<String, dynamic> generateAlgorithmSQL(
      List<dynamic> alarmRules, String currentTime) {
    List<Map<String, dynamic>> sqlRecords = [];

    for (var rule in alarmRules) {
      String ruleValue = rule['RuleValue'];
      String ruleName = rule['RuleName'];

      List<Map<String, dynamic>> records = parseRuleValue(ruleValue, ruleName);

      Map<String, String> idMapping = {
        '6_1': 'low_low_alarm',
        '6_2': 'low_alarm',
        '0_2': 'low_alarm',
        '3_2': 'low_equal',
        '5_4': 'high_high_alarm',
        '5_3': 'high_alarm',
        '0_3': 'high_alarm',
        '3_3': 'high_equal'
      };

      for (var record in records) {
        String key = '${record['type']}_${record['level']}';
        if (idMapping.containsKey(key) && rule[idMapping[key]] != null) {
          record['id'] = rule[idMapping[key]];
          sqlRecords.add(record);
        }
      }
    }

    String sql = "START TRANSACTION;\nSET FOREIGN_KEY_CHECKS = 0;\n"
        "INSERT INTO `iot_server`.`iot_alarm_algorithm` "
        "(`id`, `tenant_id`, `type`, `level`, `max_value`, `min_value`, `boolean_value`, `equal_value`, `remark`, `growth_rate_value`, `decline_rate_value`, `create_person`, `update_person`, `create_date_time`, `update_date_time`) "
        "VALUES\n";

    List<String> values = [];
    for (var record in sqlRecords) {
      String maxValue =
          record['max_value'] != null ? "'${record['max_value']}'" : 'NULL';
      String minValue =
          record['min_value'] != null ? "'${record['min_value']}'" : 'NULL';
      String equalValue = record['equal_value'] != null
          ? "'${record['equal_value']}'"
          : 'NULL';

      values.add(
          "('${getSafeStringValue(record['id'])}', '1', ${getSafeStringValue(record['type'])}, ${getSafeStringValue(record['level'])}, $maxValue, $minValue, NULL, $equalValue, '', NULL, NULL, '1', '1', '$currentTime', '$currentTime')");
    }

    sql += values.join(',\n') + ';\n'
        "SET FOREIGN_KEY_CHECKS = 1;\nCOMMIT;";
    return {'sql': sql, 'count': sqlRecords.length};
  }

  List<Map<String, dynamic>> parseRuleValue(String ruleValue, String ruleName) {
    List<Map<String, dynamic>> records = [];
    Map<String, String> ruleValueDict = {};
    ruleValue.split(',').forEach((item) {
      List<String> parts = item.split(':');
      if (parts.length == 2) {
        ruleValueDict[parts[0].trim()] = getSafeStringValue(parts[1]);
      }
    });

    double? lowLow = ruleValueDict['低低报'] != null && ruleValueDict['低低报']!.isNotEmpty && ruleValueDict['低低报'] != 'null'
        ? parseNumber(ruleValueDict['低低报'])
        : null;
    double? low = ruleValueDict['低报'] != null && ruleValueDict['低报']!.isNotEmpty && ruleValueDict['低报'] != 'null'
        ? parseNumber(ruleValueDict['低报'])
        : null;
    double? high = ruleValueDict['高报'] != null && ruleValueDict['高报']!.isNotEmpty && ruleValueDict['高报'] != 'null'
        ? parseNumber(ruleValueDict['高报'])
        : null;
    double? highHigh = ruleValueDict['高高报'] != null && ruleValueDict['高高报']!.isNotEmpty && ruleValueDict['高高报'] != 'null'
        ? parseNumber(ruleValueDict['高高报'])
        : null;

    // 阈值合理性检查（与HTML一致）
    if (lowLow != null && low != null && lowLow > low) {
      throw Exception("规则 '$ruleName' 中低低报(${lowLow})大于低报(${low})");
    }
    if (high != null && highHigh != null && high > highHigh) {
      throw Exception("规则 '$ruleName' 中高报(${high})大于高高报(${highHigh})");
    }

    // 超下限报警（类型6）：低低报用equal_value，低报（单独）也用equal_value
    if (lowLow != null) {
      records.add({
        'type': 6,
        'level': 1,
        'equal_value': lowLow,
        'min_value': null,
        'max_value': null,
      });
      // 如果低低报和低报同时存在，生成type=0（范围）和type=3（等于）记录
      if (low != null) {
        records.add({
          'type': 0,
          'level': 2,
          'min_value': lowLow,
          'max_value': low,
          'equal_value': null,
        });
        records.add({
          'type': 3,
          'level': 2,
          'equal_value': lowLow,
          'min_value': null,
          'max_value': null,
        });
      }
    } else if (low != null) {
      // 只有低报，无低低报
      records.add({
        'type': 6,
        'level': 2,
        'equal_value': low,
        'min_value': null,
        'max_value': null,
      });
    }

    // 超上限报警（类型5）：高高报用equal_value，高报（单独）也用equal_value
    if (highHigh != null) {
      records.add({
        'type': 5,
        'level': 4,
        'equal_value': highHigh,
        'min_value': null,
        'max_value': null,
      });
      // 如果高高报和高报同时存在，生成type=0（范围）和type=3（等于）记录
      if (high != null) {
        records.add({
          'type': 0,
          'level': 3,
          'min_value': high,
          'max_value': highHigh,
          'equal_value': null,
        });
        records.add({
          'type': 3,
          'level': 3,
          'equal_value': highHigh,
          'min_value': null,
          'max_value': null,
        });
      }
    } else if (high != null) {
      // 只有高报，无高高报
      records.add({
        'type': 5,
        'level': 3,
        'equal_value': high,
        'min_value': null,
        'max_value': null,
      });
    }

    return records;
  }

  Map<String, dynamic> generateRuleAlgorithmRelSQL(
      List<dynamic> alarmRules, String currentTime) {
    String sql =
        "START TRANSACTION;\nSET FOREIGN_KEY_CHECKS = 0;\n"
        "INSERT INTO `iot_server`.`iot_alarm_rule_single_algorithm_rel` "
        "(`id`, `rule_id`, `algorithm_id`, `create_person`, `update_person`, "
        "`create_date_time`, `update_date_time`) "
        "VALUES\n";

    List<String> values = [];
    Uuid uuid = Uuid();
    int count = 0;

    for (var rule in alarmRules) {
      List<String> algorithmIds = [];
      if (rule['low_low_alarm'] != null)
        algorithmIds.add(getSafeStringValue(rule['low_low_alarm']));
      if (rule['low_alarm'] != null)
        algorithmIds.add(getSafeStringValue(rule['low_alarm']));
      if (rule['low_equal'] != null)
        algorithmIds.add(getSafeStringValue(rule['low_equal']));
      if (rule['high_equal'] != null)
        algorithmIds.add(getSafeStringValue(rule['high_equal']));
      if (rule['high_alarm'] != null)
        algorithmIds.add(getSafeStringValue(rule['high_alarm']));
      if (rule['high_high_alarm'] != null)
        algorithmIds.add(getSafeStringValue(rule['high_high_alarm']));

      for (int i = 0; i < algorithmIds.length; i++) {
        count++;
        String id = uuid.v4().replaceAll('-', '');
        values.add(
            "('$id', '${getSafeStringValue(rule['RuleId'])}', '${algorithmIds[i]}', '1', '1', '$currentTime', '$currentTime')");
      }
    }

    sql += values.join(',\n') + ';\n'
        "SET FOREIGN_KEY_CHECKS = 1;\nCOMMIT;";
    return {'sql': sql, 'count': count};
  }

  Map<String, dynamic> generateSensorRelSQL(List<dynamic> alarmRules,
      Map<String, dynamic> sensorData, String currentTime) {
    List<String> values = [];
    int count = 0;

    for (var rule in alarmRules) {
      List<String> sensorCodes = (rule['SensorsCode'] as List?)
              ?.map((code) => getSafeStringValue(code))
              .toList() ??
          [];
      List<String> sensorIds = [];

      for (var code in sensorCodes) {
        var sensor = sensorData['rows']?.firstWhere(
            (s) => getSafeStringValue(s['element_code']) == code,
            orElse: () => null);
        if (sensor != null) {
          String sensorId = getSafeStringValue(sensor['id']);
          if (sensorId.isNotEmpty && sensorId != 'NULL') {
            sensorIds.add(sensorId);
          }
        }
      }

      for (String sensorId in sensorIds) {
        count++;
        String id = Uuid().v4().replaceAll('-', '');
        values.add(
            "('$id', '${getSafeStringValue(rule['RuleId'])}', '$sensorId', NULL, NULL, NULL, 'rtd', 0, '1', '1', '$currentTime', '$currentTime')");
      }
    }

    String sql = "START TRANSACTION;\nSET FOREIGN_KEY_CHECKS = 0;\n"
        "INSERT INTO `iot_server`.`iot_alarm_rule_single_sensor_rel` "
        "(`id`, `rule_id`, `sensor_id`, `algorithm_id`, `alarm_date`, `alarm_data`, `alarm_data_type`, `alarm_status`, `create_person`, `update_person`, `create_date_time`, `update_date_time`) "
        "VALUES\n${values.join(',\n')};\n"
        "SET FOREIGN_KEY_CHECKS = 1;\nCOMMIT;";
    return {'sql': sql, 'count': count};
  }

  double? parseNumber(dynamic value) {
    String strValue = getSafeStringValue(value);
    if (strValue == 'NULL' || strValue.isEmpty) return null;
    return double.tryParse(strValue);
  }

  // 安全处理Data类型转换为字符串
  String getSafeStringValue(dynamic value) {
    try {
      if (value == null) return 'NULL';

      // 直接检查是否为String类型
      if (value is String) {
        return value.replaceAll("'", "''");
      }

      // 处理列表类型
      if (value is List) {
        return value
            .map((item) => getSafeStringValue(item))
            .join(', ')
            .replaceAll("'", "''");
      }

      // 尝试访问常见的数据值属性
      dynamic dataValue;
      // 优先检查非标准类型（可能是Data或其他自定义类型）
      if (!(value is String ||
          value is num ||
          value is bool ||
          value is List ||
          value is Map)) {
        // 处理Excel的Cell类型
        if (value.runtimeType.toString().contains('Cell')) {
          dataValue = (value as dynamic).value;
        } else if (RegExp(r'data', caseSensitive: false)
            .hasMatch(value.runtimeType.toString())) {
          // 显式处理Data类型（不区分大小写）并检查更多属性
          dataValue = (value as dynamic).value ??
              (value as dynamic).data ??
              (value as dynamic).text ??
              (value as dynamic).cellValue ??
              (value as dynamic).content ??
              (value as dynamic).rawValue ??
              (value as dynamic).valueData ??
              (value as dynamic).dataValue ??
              (value as dynamic).numericValue ??
              (value as dynamic).stringValue ??
              (value as dynamic).intValue ??
              (value as dynamic).val ??
              (value as dynamic).valueObj ??
              (value as dynamic).dataObj ??
              (value as dynamic).cell_data ??
              (value as dynamic).raw_data ??
              (value as dynamic).innerValue ??
              (value as dynamic).actualValue ??
              (value as dynamic).dataValue ??
              (value as dynamic).data_value ??
              (value as dynamic).valueRaw ??
              (value as dynamic).dataRaw ??
              (value as dynamic).dataObject ??
              (value as dynamic).innerData ??
              (value as dynamic).contentData ??
              (value as dynamic).rawContent ??
              (value as dynamic).originalValue ??
              (value as dynamic).sourceValue ??
              (value as dynamic).contentValue ??
              (value as dynamic).dataContent ??
              (value as dynamic).getValue?.call();
        } else {
          dataValue = (value as dynamic).value ??
              (value as dynamic).data ??
              (value as dynamic).text ??
              (value as dynamic).cellValue ??
              (value as dynamic).content ??
              (value as dynamic).rawValue ??
              (value as dynamic).valueData ??
              (value as dynamic).dataValue ??
              (value as dynamic).numericValue ??
              (value as dynamic).stringValue ??
              (value as dynamic).intValue ??
              (value as dynamic).val ??
              (value as dynamic).valueObj ??
              (value as dynamic).dataObj ??
              (value as dynamic).cell_data ??
              (value as dynamic).raw_data ??
              (value as dynamic).innerValue ??
              (value as dynamic).actualValue ??
              (value as dynamic).dataValue ??
              (value as dynamic).data_value ??
              (value as dynamic).valueRaw ??
              (value as dynamic).dataRaw ??
              (value as dynamic).getValue?.call();
        }
      } else if (value is Map) {
        dataValue = value['value'] ??
            value['data'] ??
            value['text'] ??
            value['cellValue'] ??
            value['cell_value'] ??
            value['content'] ??
            value['rawValue'] ??
            value['valueData'] ??
            value['dataValue'] ??
            value['numericValue'] ??
            value['stringValue'] ??
            value['intValue'];
      } else {
        dataValue = (value as dynamic).value ??
            (value as dynamic).data ??
            (value as dynamic).text ??
            (value as dynamic).cellValue ??
            (value as dynamic).content ??
            (value as dynamic).rawValue ??
            (value as dynamic).valueData ??
            (value as dynamic).dataValue ??
            (value as dynamic).numericValue ??
            (value as dynamic).stringValue ??
            (value as dynamic).intValue ??
            (value as dynamic).val ??
            (value as dynamic).valueObj ??
            (value as dynamic).dataObj ??
            (value as dynamic).cell_data ??
            (value as dynamic).raw_data ??
            (value as dynamic).innerValue ??
            (value as dynamic).actualValue ??
            (value as dynamic).dataValue ??
            (value as dynamic).data_value ??
            (value as dynamic).valueRaw ??
            (value as dynamic).dataRaw ??
            (value as dynamic).getValue?.call();
      }

      // 如果获取到数据值，递归处理以确保它是字符串
      if (dataValue != null) {
        return getSafeStringValue(dataValue);
      }
    } catch (e) {
      // 属性访问失败，继续尝试其他方法
    }

    try {
      // 尝试从toString()中提取值（处理多种格式）
      String str = value.toString();
      List<RegExp> regExps = [
        RegExp(r'\((.*?)\)'), // 匹配 (value)
        RegExp(r'\[(.*?)\]'), // 匹配 [value]
        RegExp(r'\{(.*?)\}'), // 匹配 {value}
        RegExp(r'=(.*?)(,|$)'), // 匹配 =value,
        RegExp(r'value[:=]\s*(.*?)($|\s)'), // 匹配 value: value 或 value=value
        RegExp(r'data[:=]\s*(.*?)($|\s)') // 匹配 data: value 或 data=value
      ];

      for (var regExp in regExps) {
        Match? match = regExp.firstMatch(str);
        if (match != null && match.groupCount >= 1) {
          String extracted = match.group(1)!.trim();

          // 处理特殊值转换
          if (extracted.toLowerCase() == 'true') {
            return '1';
          } else if (extracted.toLowerCase() == 'false') {
            return '0';
          } else if (extracted.toLowerCase() == 'null') {
            return 'NULL';
          }

          // 如果提取到的值看起来像另一个对象，递归处理
          return getSafeStringValue(extracted);
        }
      }

      // 尝试将数值类型直接转换
      if (value is num) {
        return value.toString().replaceAll("'", "''");
      }

      // 尝试将布尔类型转换
      if (value is bool) {
        return value ? '1' : '0';
      }

      // 最终回退到原始toString()
      return str.replaceAll("'", "''");
    } catch (e) {
      // 所有方法都失败，返回安全的NULL值
      return 'NULL';
    }
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  void updateStatus(String message, StatusType type) {
    status.value = message;
    statusType.value = type.toString().split('.').last;
  }

  Future<void> downloadFile({
    String? fileName,
    String? content,
    String? type,
  }) async {
    try {
      // 详细的参数验证
      if (fileName == null || fileName.isEmpty) {
        fileName = 'alarm_rule.sql';
      }
      if (content == null) {
        content = '';
      }
      if (type == null || type.isEmpty) {
        type = 'sql';
      }

      if (kIsWeb) {
        // Web平台使用浏览器下载API
        final bytes = utf8.encode(content);
        final blob = html.Blob([bytes], 'text/$type');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final _ = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        updateStatus('文件已开始下载: $fileName', StatusType.success);
      } else {
        // 移动平台使用文件系统
        final directory = await getApplicationDocumentsDirectory();
        if (directory.path.isEmpty) {
          throw Exception('获取应用文档目录失败');
        }

        final path = '${directory.path}/$fileName';
        if (path.isEmpty) {
          throw Exception('生成文件路径失败');
        }

        final file = File(path);
        await file.writeAsString(content);
        updateStatus('文件已下载到: $path', StatusType.success);
      }
    } catch (e) {
      final errorMsg =
          '下载文件失败: ${e.toString()}\n参数: fileName=$fileName, content=${content?.length ?? 0}字符, type=$type';
      updateStatus(errorMsg, StatusType.error);
    }
  }
}

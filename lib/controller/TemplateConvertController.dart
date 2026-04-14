import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/services.dart';
import 'package:jx_flutter/util/ControllerUtils.dart';

enum StatusType { success, error, info }

class TemplateConvertController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  // 用户输入
  final collectorCode = ''.obs;
  final projectId = ''.obs;
  final firmId = ''.obs;

  // 文件状态
  final xlsxFileName = ''.obs;
  final isProcessing = false.obs;
  final statusMessage = '模板转换工具已就绪'.obs;
  final statusType = StatusType.info.obs;

  // 输出结果
  final hasResult = false.obs;
  String _sensorFileName = '';
  String _sensorBase64 = '';
  String _alarmFileName = '';
  String _alarmBase64 = '';
  Uint8List? _inputFileBytes; // 用户上传的安基模板文件字节

  int sensorRowCount = 0;
  int alarmRowCount = 0;

  // 模板字节（缓存，避免重复加载）
  Uint8List? _sensorTemplateBytes;
  Uint8List? _alarmTemplateBytes;

  // 要素映射
  static const Map<String, String> _zhToEn = {
    '可燃气体': 'combustibleGas',
    '有毒气体': 'poisonousGas',
    '液位': 'liquidLevel',
    '温度': 'temp',
    '压力': 'pressure',
  };

  static const Map<String, String> _zhToCode = {
    '可燃气体': '1010006',
    '有毒气体': '1010007',
    '液位': '1010003',
    '温度': '1010005',
    '压力': '1010001',
  };

  static const List<String> _highPriority = ['温度', '压力', '液位'];
  static const Map<String, List<String>> _lowPriority = {
    '可燃气体': ['可燃气体', '可燃'],
    '有毒气体': ['有毒气体', '有毒'],
  };

  String _getMatchedElement(String? indicatorType) {
    if (indicatorType == null || indicatorType.isEmpty) return '';
    final text = indicatorType.trim();
    for (final kw in _highPriority) {
      if (text.contains(kw)) return kw;
    }
    for (final e in _lowPriority.entries) {
      for (final alias in e.value) {
        if (text.contains(alias)) return e.key;
      }
    }
    return '';
  }

  // 预加载模板（应用启动时调用一次）
  Future<void> loadTemplates() async {
    try {
      final sensorData =
          await rootBundle.load('web/传感器设备模板.xlsx');
      _sensorTemplateBytes = sensorData.buffer.asUint8List();
      final alarmData = await rootBundle.load('web/报警规则模板.xlsx');
      _alarmTemplateBytes = alarmData.buffer.asUint8List();
    } catch (e) {
      // assets 未配置时静默忽略，processFile 中会兜底提示
    }
  }

  // 选择文件（缓存字节，processFile 直接用，不再弹框）
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.name.isEmpty) return;

      _inputFileBytes = file.bytes;
      xlsxFileName.value = file.name;
      statusMessage.value = '已选择: ${xlsxFileName.value}，点击"一键转换"';
      statusType.value = StatusType.info;
    } catch (e) {
      statusMessage.value = '选择文件失败: $e';
      statusType.value = StatusType.error;
    }
  }

  // 执行转换（直接在模板文件上写入数据）
  Future<void> processFile() async {
    if (collectorCode.value.trim().isEmpty) {
      statusMessage.value = '请填写采集仪目标编码';
      statusType.value = StatusType.error;
      return;
    }
    if (projectId.value.trim().isEmpty) {
      statusMessage.value = '请填写所属项目id';
      statusType.value = StatusType.error;
      return;
    }
    if (firmId.value.trim().isEmpty) {
      statusMessage.value = '请填写企业统一社会信用代码';
      statusType.value = StatusType.error;
      return;
    }
    if (xlsxFileName.value.isEmpty || _inputFileBytes == null) {
      statusMessage.value = '请先选择安基模板 Excel';
      statusType.value = StatusType.error;
      return;
    }

    // 确保模板已加载
    if (_sensorTemplateBytes == null || _alarmTemplateBytes == null) {
      await loadTemplates();
    }
    if (_sensorTemplateBytes == null || _alarmTemplateBytes == null) {
      statusMessage.value = '模板文件未找到，请检查 assets 配置';
      statusType.value = StatusType.error;
      return;
    }

    isProcessing.value = true;
    statusMessage.value = '正在读取 Excel...';
    statusType.value = StatusType.info;

    try {
      // 直接使用 pickFile 缓存的文件字节
      final inputBytes = _inputFileBytes!;
      statusMessage.value = '正在解析数据...';
      final inputExcel = Excel.decodeBytes(inputBytes);

      final sheet = inputExcel['指标信息'];
      if (sheet == null) {
        throw Exception('未找到"指标信息"工作表');
      }

      // 提取列名（第2行，0-indexed row=1）
      final maxCol = sheet.maxCols;
      final colNames = <int, String>{};
      for (var c = 0; c < maxCol; c++) {
        final val = getCellString(
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 1)),
        );
        if (val.isNotEmpty) colNames[c] = val;
      }

      // 提取数据行（从第3行 row=3 开始）
      final dataRows = <Map<String, String>>[];
      final maxRow = sheet.maxRows;
      for (var r = 3; r < maxRow; r++) {
        final rowData = <String, String>{};
        bool hasData = false;
        for (var c = 0; c < maxCol; c++) {
          final colName = colNames[c];
          if (colName == null || colName.isEmpty) continue;
          final val = getCellString(
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r)),
          );
          rowData[colName] = val;
          if (val.isNotEmpty) hasData = true;
        }
        if (hasData) {
          final code = rowData['指标编码'] ?? '';
          if (code.trim().isNotEmpty) dataRows.add(rowData);
        }
      }

      if (dataRows.isEmpty) {
        throw Exception('文件中没有有效数据行');
      }

      statusMessage.value = '正在生成 Excel...';

      // 生成传感器设备（直接在模板上写数据）
      sensorRowCount = dataRows.length;
      _sensorFileName =
          '${xlsxFileName.value.replaceAll(RegExp(r'\.xlsx?$', caseSensitive: false), '')}_传感器设备.xlsx';
      final sensorBytes = _fillSensorTemplate(dataRows);
      _sensorBase64 = base64Encode(sensorBytes);

      // 生成报警规则（直接在模板上写数据）
      alarmRowCount = dataRows.length;
      _alarmFileName =
          '${xlsxFileName.value.replaceAll(RegExp(r'\.xlsx?$', caseSensitive: false), '')}_报警规则.xlsx';
      final alarmBytes = _fillAlarmTemplate(dataRows);
      _alarmBase64 = base64Encode(alarmBytes);

      hasResult.value = true;
      statusMessage.value =
          '转换完成！${dataRows.length} 行传感器设备 + ${dataRows.length} 行报警规则';
      statusType.value = StatusType.success;
    } catch (e) {
      statusMessage.value = '处理失败: $e';
      statusType.value = StatusType.error;
      hasResult.value = false;
    } finally {
      isProcessing.value = false;
    }
  }

  // 下载传感器设备
  Future<void> downloadSensor() async {
    if (_sensorBase64.isEmpty) return;
    await _downloadBase64(_sensorFileName, _sensorBase64);
  }

  // 下载报警规则
  Future<void> downloadAlarm() async {
    if (_alarmBase64.isEmpty) return;
    await _downloadBase64(_alarmFileName, _alarmBase64);
  }

  Future<void> _downloadBase64(String fileName, String base64Data) async {
    try {
      final bytes = base64Decode(base64Data);
      final blob = html.Blob([bytes], 'application/octet-stream');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
      statusMessage.value = '下载成功: $fileName';
      statusType.value = StatusType.success;
    } catch (e) {
      statusMessage.value = '下载失败: $e';
      statusType.value = StatusType.error;
    }
  }

  // 在传感器设备模板上写入数据（保持模板格式不变）
  Uint8List _fillSensorTemplate(List<Map<String, String>> rows) {
    final excel = Excel.decodeBytes(_sensorTemplateBytes!);

    // 找到传感器数据 sheet（排除 "基础表勿动"）
    String sensorSheetName = excel.tables.keys.firstWhere(
      (name) => name != '基础表勿动',
      orElse: () => 'Sheet1',
    );
    final sheet = excel[sensorSheetName];

    // 从第4行（0-indexed row=3）开始写入数据
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final elem = _getMatchedElement(row['指标类型*']);
      final r = 3 + i;

      _setCell(sheet, r, 0, row['指标名称'] ?? '');
      _setCell(sheet, r, 1, row['指标编码'] ?? '');
      _setCell(sheet, r, 2, row['指标位号*'] ?? '');
      _setCell(sheet, r, 3, collectorCode.value.trim());
      _setCell(sheet, r, 4, projectId.value.trim());
      _setCell(sheet, r, 5, _zhToCode[elem] ?? '');
      _setCell(sheet, r, 6, firmId.value.trim());
      _setCell(sheet, r, 7, elem);
      _setCell(sheet, r, 8, _zhToEn[elem] ?? '');
      _setCell(sheet, r, 9, row['指标位号*'] ?? '');
      _setCell(sheet, r, 10, row['计量单位*'] ?? '');
      _setCell(sheet, r, 11, row['仪表量程下限*'] ?? '');
      _setCell(sheet, r, 12, row['仪表量程上限*'] ?? '');
    }

    return Uint8List.fromList(excel.encode()!);
  }

  // 在报警规则模板上写入数据
  Uint8List _fillAlarmTemplate(List<Map<String, String>> rows) {
    final excel = Excel.decodeBytes(_alarmTemplateBytes!);

    // 找到报警规则 sheet（排除 "基础表勿动"）
    String alarmSheetName = excel.tables.keys.firstWhere(
      (name) => name != '基础表勿动',
      orElse: () => 'Sheet1',
    );
    final sheet = excel[alarmSheetName];

    // 从第4行（0-indexed row=3）开始写入数据
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final r = 3 + i;

      _setCell(sheet, r, 0, row['指标编码'] ?? '');
      _setCell(sheet, r, 1, '0'); // 数据类型: 0=rtd
      _setCell(sheet, r, 2, '1'); // 监控启用: 1
      _setCell(sheet, r, 3, '0'); // 首次报警抑制时间
      _setCell(sheet, r, 4, row['低低报'] ?? '');
      _setCell(sheet, r, 5, row['低报'] ?? '');
      _setCell(sheet, r, 6, row['高报*'] ?? '');
      _setCell(sheet, r, 7, row['高高报'] ?? '');
      _setCell(sheet, r, 8, '');
    }

    return Uint8List.fromList(excel.encode()!);
  }

  // 设置单元格值（excel 2.1.0: value 直接赋字符串）
  void _setCell(Sheet sheet, int row, int col, dynamic value) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
        .value = value ?? '';
  }

  // 清空
  void clearAll() {
    collectorCode.value = '';
    projectId.value = '';
    firmId.value = '';
    xlsxFileName.value = '';
    _inputFileBytes = null;
    hasResult.value = false;
    _sensorFileName = '';
    _sensorBase64 = '';
    _alarmFileName = '';
    _alarmBase64 = '';
    statusMessage.value = '已清空，请重新选择文件';
    statusType.value = StatusType.info;
  }
}

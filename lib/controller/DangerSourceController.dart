import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import '../util/ControllerUtils.dart' show getCellString;
import 'dart:io' as io;
import 'package:jx_flutter/util/ControllerUtils.dart' as utils;

// ══════════════════════════════════════════════════════
// 数据模型
// ══════════════════════════════════════════════════════

/// 校验问题分类
enum CheckCategory {
  missing, // 缺失数据：值为空
  format, // 格式错误：不符合规则
  mismatch, // 数据不匹配：不在范围内
  duplicate, // 数据重复：重复出现
}

/// 校验日志条目
class CheckLogEntry {
  final int index;
  final String sheet;
  final int row;
  final int col;
  final String colName;
  final String reason;
  final String suggestion;
  final CheckCategory category;
  final bool isFixable; // 是否可自动修复填充

  CheckLogEntry({
    required this.index,
    required this.sheet,
    required this.row,
    required this.col,
    required this.colName,
    required this.reason,
    required this.suggestion,
    this.category = CheckCategory.mismatch,
    this.isFixable = false,
  });

  String get addr {
    final colLetter = String.fromCharCode(65 + col);
    return '$colLetter${row + 1}';
  }

  String get categoryLabel {
    switch (category) {
      case CheckCategory.missing:
        return '缺失数据';
      case CheckCategory.format:
        return '格式错误';
      case CheckCategory.mismatch:
        return '数据不匹配';
      case CheckCategory.duplicate:
        return '数据重复';
    }
  }

  String toText() {
    final r = (row + 1).toString(); // 0-based → 1-based
    final c = (col + 1).toString();
    final fixableMark = isFixable ? '⚠️' : '❌';
    final typeSuffix = isFixable ? "（可自动修复）" : "（需人工处理）";
    return '$fixableMark [错误${index.toString().padLeft(4, "0")}] '
        "Sheet='$sheet' 行=$r 列=$c($addr) 字段='$colName'\n"
        '  类型：$categoryLabel$typeSuffix\n'
        '  问题：$reason\n'
        '  建议：$suggestion';
  }
}

/// 校验结果
class CheckResult {
  final List<CheckLogEntry> logs;
  final Uint8List excelBytes;
  CheckResult({required this.logs, required this.excelBytes});
  int get errorCount => logs.length;

  int get missingCount =>
      logs.where((l) => l.category == CheckCategory.missing).length;
  int get formatCount =>
      logs.where((l) => l.category == CheckCategory.format).length;
  int get mismatchCount =>
      logs.where((l) => l.category == CheckCategory.mismatch).length;
  int get duplicateCount =>
      logs.where((l) => l.category == CheckCategory.duplicate).length;
  int get fixableCount => logs.where((l) => l.isFixable).length;
  int get manualFixCount => logs.where((l) => !l.isFixable).length;
  bool get canFix => manualFixCount == 0;
}

/// 修复日志条目
class FixLogEntry {
  final int index;
  final String sheet;
  final int row;
  final int col;
  final String colName;
  final String oldValue;
  final String newValue;

  FixLogEntry({
    required this.index,
    required this.sheet,
    required this.row,
    required this.col,
    required this.colName,
    required this.oldValue,
    required this.newValue,
  });

  String get addr {
    final colLetter = String.fromCharCode(65 + col);
    return '$colLetter${row + 1}';
  }

  String toText() {
    return '[修复${index.toString().padLeft(4, "0")}] '
        "Sheet='$sheet' $addr '$colName'\n"
        '  旧值：$oldValue\n'
        '  新值：$newValue';
  }
}

/// 需人工处理条目
class WarnLogEntry {
  final int index;
  final String sheet;
  final int row;
  final int col;
  final String colName;
  final String reason;
  final String suggestion;

  WarnLogEntry({
    required this.index,
    required this.sheet,
    required this.row,
    required this.col,
    required this.colName,
    required this.reason,
    required this.suggestion,
  });

  String get addr {
    final colLetter = String.fromCharCode(65 + col); // 简单 A-Z
    return '$colLetter${row + 1}';
  }

  String toText() {
    return '[需人工处理${index.toString().padLeft(4, "0")}] '
        "Sheet='$sheet' $addr '$colName'\n"
        '  问题：$reason\n'
        '  建议：$suggestion';
  }
}

/// 修复结果
class FixResult {
  final List<FixLogEntry> fixLogs;
  final List<WarnLogEntry> warnLogs;
  final Uint8List excelBytes;
  FixResult({
    required this.fixLogs,
    required this.warnLogs,
    required this.excelBytes,
  });
  int get fixCount => fixLogs.length;
  int get warnCount => warnLogs.length;
}

// ══════════════════════════════════════════════════════
// Controller
// ══════════════════════════════════════════════════════

enum StatusType { success, error, info }

class DangerSourceController extends GetxController {
  // ── 响应式状态 ──
  final xlsxFileName = ''.obs;
  final isProcessing = false.obs;
  final statusMessage = '重大危险源模板校验修复工具已就绪'.obs;
  final statusType = StatusType.info.obs;
  final currentStep = 0.obs;
  final checkResult = Rx<CheckResult?>(null);
  final fixResult = Rx<FixResult?>(null);

  // ── 缓存 ──
  Uint8List? _inputFileBytes;
  String _checkXlsxB64 = '';
  String _checkLogB64 = '';
  String _fixXlsxB64 = '';
  String _fixLogB64 = '';

  // ── 常量 ──
  static const Map<String, String> _indicatorTypeMap = {
    '温度': 'WD',
    '压力': 'YL',
    '液位': 'YW',
    '可燃气体': 'QT',
    '有毒气体': 'QT',
  };

  static const Map<String, String> _categoryToSheetMap = {
    '罐': '罐、库基础信息',
    '仓库': '罐、库基础信息',
    '库': '罐、库基础信息',
    '装置': '装置基础信息',
    '气体检测': '气体泄漏检测点基础信息',
    '可燃气体': '气体泄漏检测点基础信息',
    '有毒气体': '气体泄漏检测点基础信息',
  };

  static const Map<String, String> _sheetCodeInfixMap = {
    '罐、库基础信息': 'G0',
    '装置基础信息': 'P0',
    '气体泄漏检测点基础信息': 'Q0',
  };

  static const _yellowFill = 'FFFFFF00';
  static const _greenFill = 'FFC6EFCE';
  static const _redFill = 'FFFFC7CE';

  static const _dataStartRow = 3; // 0-based (Excel第4行)
  static const _headerRow = 1; // 0-based (Excel第2行)

  // ── 表头名称常量 ──
  static const _colDangerCode = '重大危险源/区域编号*';
  static const _colDeviceNameNo = '设备名称编号*';
  static const _colDeviceCode = '设备编码';
  static const _colDeviceType = '设备类别*';
  static const _colIndicatorType = '指标类型*';
  static const _colIndicatorCode = '指标编码';
  static const _colIndicatorNo = '指标位号*';

  // ═══════════════════════════════════════════════════
  // 工具方法
  // ═══════════════════════════════════════════════════

  /// 根据表头名称查找列索引（0-based）
  int? _colIndexByHeader(Sheet sheet, String headerName) {
    final maxCol = sheet.maxCols;
    for (var c = 0; c < maxCol; c++) {
      final val = _getVal(sheet, _headerRow, c);
      if (val == headerName) return c;
    }
    return null;
  }

  /// 获取单元格字符串值
  String _getVal(Sheet sheet, int row, int col) {
    return getCellString(
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row)),
    );
  }

  /// 设置单元格值
  void _setVal(Sheet sheet, int row, int col, String value) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
        .value = value;
  }

  /// 获取有效数据行号列表（从 _dataStartRow 开始，跳过空行和说明行）
  List<int> _getDataRows(Sheet sheet) {
    final rows = <int>[];
    final maxRow = sheet.maxRows;
    for (var r = _dataStartRow; r < maxRow; r++) {
      // 跳过"填写说明"行
      final firstVal = _getVal(sheet, r, 0);
      if (firstVal.contains('填写说明')) continue;
      // 跳过全空行
      bool hasData = false;
      for (var c = 0; c < sheet.maxCols; c++) {
        if (_getVal(sheet, r, c).isNotEmpty) {
          hasData = true;
          break;
        }
      }
      if (hasData) rows.add(r);
    }
    return rows;
  }

  /// 从指标类型获取缩写后缀
  String? _getIndicatorSuffix(String indtype) {
    final cleaned = indtype.replaceAll(RegExp(r'(WD|YL|YW|QT)$'), '').trim();
    return _indicatorTypeMap[cleaned] ?? _indicatorTypeMap[indtype];
  }

  /// 设备类别 → sheet 名称
  String? _categoryToSheet(String cat) {
    return _categoryToSheetMap[cat.trim()];
  }

  /// 高亮单元格
  void _highlight(Sheet sheet, int row, int col, String colorHex) {
    final cell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.cellStyle = CellStyle(backgroundColorHex: colorHex);
  }

  /// 正确转义正则表达式特殊字符
  String _escapeRegex(String s) {
    return s.replaceAll(RegExp(r'[.*+?^${}()|[\]\\]'), r'\$&');
  }

  // ═══════════════════════════════════════════════════
  // 文件选择 & 下载
  // ═══════════════════════════════════════════════════

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
      currentStep.value = 1;
      checkResult.value = null;
      fixResult.value = null;
      statusMessage.value = '已选择: ${xlsxFileName.value}，点击"执行校验"';
      statusType.value = StatusType.info;
    } catch (e) {
      statusMessage.value = '选择文件失败: $e';
      statusType.value = StatusType.error;
    }
  }

  Future<void> _downloadBytes(
      String fileName, Uint8List bytes, String mimeType) async {
    try {
      if (kIsWeb) {
        final blob = html.Blob([bytes], mimeType);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        utils.showSuccess('文件已开始下载: $fileName');
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = io.File(path);
        await file.writeAsBytes(bytes);
        utils.showSuccess('文件已保存到: $path');
      }
    } catch (e) {
      utils.showError('下载文件失败: $e');
    }
  }

  Future<void> downloadCheckExcel() async {
    if (_checkXlsxB64.isEmpty) return;
    final bytes = base64Decode(_checkXlsxB64);
    final name = _getBaseName(xlsxFileName.value) + '_校验结果.xlsx';
    await _downloadBytes(name, bytes, 'application/octet-stream');
  }

  Future<void> downloadCheckLog() async {
    if (_checkLogB64.isEmpty) return;
    final text = utf8.decode(base64Decode(_checkLogB64));
    final name = _getBaseName(xlsxFileName.value) + '_校验日志.txt';
    await utils.saveToFile(content: text, fileName: name);
  }

  Future<void> downloadFixExcel() async {
    if (_fixXlsxB64.isEmpty) return;
    final bytes = base64Decode(_fixXlsxB64);
    final name = _getBaseName(xlsxFileName.value) + '_修复结果.xlsx';
    await _downloadBytes(name, bytes, 'application/octet-stream');
  }

  Future<void> downloadFixLog() async {
    if (_fixLogB64.isEmpty) return;
    final text = utf8.decode(base64Decode(_fixLogB64));
    final name = _getBaseName(xlsxFileName.value) + '_修复日志.txt';
    await utils.saveToFile(content: text, fileName: name);
  }

  String? getCheckLogPreview() {
    if (_checkLogB64.isEmpty) return null;
    return utf8.decode(base64Decode(_checkLogB64));
  }

  String? getFixLogPreview() {
    if (_fixLogB64.isEmpty) return null;
    return utf8.decode(base64Decode(_fixLogB64));
  }

  String _getBaseName(String fileName) {
    final dot = fileName.lastIndexOf('.');
    return dot > 0 ? fileName.substring(0, dot) : fileName;
  }

  void clearAll() {
    xlsxFileName.value = '';
    _inputFileBytes = null;
    currentStep.value = 0;
    checkResult.value = null;
    fixResult.value = null;
    _checkXlsxB64 = '';
    _checkLogB64 = '';
    _fixXlsxB64 = '';
    _fixLogB64 = '';
    statusMessage.value = '已清空，请重新选择文件';
    statusType.value = StatusType.info;
  }

  // ═══════════════════════════════════════════════════
  // 校验逻辑
  // ═══════════════════════════════════════════════════

  Future<void> runCheck() async {
    if (_inputFileBytes == null) {
      statusMessage.value = '请先选择 Excel 文件';
      statusType.value = StatusType.error;
      return;
    }

    isProcessing.value = true;
    statusMessage.value = '正在校验...';
    statusType.value = StatusType.info;
    fixResult.value = null;
    currentStep.value = 1;

    try {
      final excel = Excel.decodeBytes(_inputFileBytes!);
      final logs = <CheckLogEntry>[];

      // Step 1: 收集危险源编号
      statusMessage.value = '正在校验：危险源信息...';
      final validDangerCodes = <String>{};
      _checkDangerInfo(excel, logs, validDangerCodes);

      // Step 2: 校验设备 sheet 并建立映射
      final deviceCodeGlobal = <String, Map<String, String>>{};

      statusMessage.value = '正在校验：罐、库基础信息...';
      _checkDeviceSheet(
          excel, '罐、库基础信息', 'G0', logs, validDangerCodes, deviceCodeGlobal);

      statusMessage.value = '正在校验：装置基础信息...';
      _checkDeviceSheet(
          excel, '装置基础信息', 'P0', logs, validDangerCodes, deviceCodeGlobal);

      statusMessage.value = '正在校验：气体泄漏检测点基础信息...';
      _checkDeviceSheet(
          excel, '气体泄漏检测点基础信息', 'Q0', logs, validDangerCodes, deviceCodeGlobal);

      // Step 3: 校验指标信息
      statusMessage.value = '正在校验：指标信息...';
      _checkIndicatorSheet(excel, logs, deviceCodeGlobal);

      // 输出
      final excelBytes = Uint8List.fromList(excel.encode()!);
      _checkXlsxB64 = base64Encode(excelBytes);
      _checkLogB64 = base64Encode(utf8.encode(_buildCheckLog(logs)));

      checkResult.value = CheckResult(logs: logs, excelBytes: excelBytes);
      currentStep.value = 2;

      if (logs.isEmpty) {
        statusMessage.value = '✅ 校验完成，未发现不合规数据';
        statusType.value = StatusType.success;
      } else {
        final missingCount =
            logs.where((l) => l.category == CheckCategory.missing).length;
        final formatCount =
            logs.where((l) => l.category == CheckCategory.format).length;
        final mismatchCount =
            logs.where((l) => l.category == CheckCategory.mismatch).length;
        final duplicateCount =
            logs.where((l) => l.category == CheckCategory.duplicate).length;
        final fixableCount = logs.where((l) => l.isFixable).length;
        final manualFixCount = logs.length - fixableCount;

        final parts = <String>[];
        if (missingCount > 0) parts.add('缺失 $missingCount 项');
        if (formatCount > 0) parts.add('格式错误 $formatCount 项');
        if (mismatchCount > 0) parts.add('数据不匹配 $mismatchCount 项');
        if (duplicateCount > 0) parts.add('重复 $duplicateCount 项');

        var msg = '⚠️ 校验完成，共 ${logs.length} 条不合规项（${parts.join("、")}）';
        if (manualFixCount > 0) {
          msg += '，其中 $manualFixCount 项需人工处理';
        }
        if (fixableCount > 0) {
          msg += '，$fixableCount 项可自动修复';
        }
        if (manualFixCount == 0) {
          msg += '，可执行自动修复';
        }
        statusMessage.value = msg;
        statusType.value = StatusType.error;
      }
    } catch (e) {
      statusMessage.value = '校验失败: $e';
      statusType.value = StatusType.error;
    } finally {
      isProcessing.value = false;
    }
  }

  void _checkDangerInfo(
      Excel excel, List<CheckLogEntry> logs, Set<String> validDangerCodes) {
    final sheet = excel['危险源信息'];
    if (sheet == null) return;

    final colNum = _colIndexByHeader(sheet, _colDangerCode);
    if (colNum == null) return;

    final regExp = RegExp(r'^\d{12}$');
    final rows = _getDataRows(sheet);

    for (final r in rows) {
      final val = _getVal(sheet, r, colNum).trim();
      if (val.isEmpty) {
        _highlight(sheet, r, colNum, _yellowFill);
        logs.add(CheckLogEntry(
          index: logs.length + 1,
          sheet: '危险源信息',
          row: r,
          col: colNum,
          colName: _colDangerCode,
          reason: '值为空',
          suggestion: '必须填写9位企业编码+3位流水号，共12位数字',
          category: CheckCategory.missing,
          isFixable: false,
        ));
      } else if (!regExp.hasMatch(val)) {
        _highlight(sheet, r, colNum, _yellowFill);
        logs.add(CheckLogEntry(
          index: logs.length + 1,
          sheet: '危险源信息',
          row: r,
          col: colNum,
          colName: _colDangerCode,
          reason: "'$val' 不是12位纯数字",
          suggestion: '格式应为：9位企业编码 + 3位流水号，共12位数字',
          category: CheckCategory.format,
          isFixable: false,
        ));
      } else {
        validDangerCodes.add(val);
      }
    }
  }

  void _checkDeviceSheet(
      Excel excel,
      String sheetName,
      String codeInfix,
      List<CheckLogEntry> logs,
      Set<String> validDangerCodes,
      Map<String, Map<String, String>> deviceCodeGlobal) {
    final sheet = excel[sheetName];
    if (sheet == null) return;

    final colArea = _colIndexByHeader(sheet, _colDangerCode);
    final colDevno = _colIndexByHeader(sheet, _colDeviceNameNo);
    final colDevcode = _colIndexByHeader(sheet, _colDeviceCode);

    if (colArea == null || colDevno == null || colDevcode == null) return;

    deviceCodeGlobal[sheetName] = {};
    final seenDevno = <String>{};
    final seenDevcode = <String>{};
    final rows = _getDataRows(sheet);

    for (final r in rows) {
      final areaVal = _getVal(sheet, r, colArea).trim();
      final devnoVal = _getVal(sheet, r, colDevno).trim();
      final devcodeVal = _getVal(sheet, r, colDevcode).trim();

      // 区域编号校验
      if (areaVal.isEmpty) {
        _highlight(sheet, r, colArea, _yellowFill);
        logs.add(CheckLogEntry(
          index: logs.length + 1,
          sheet: sheetName,
          row: r,
          col: colArea,
          colName: _colDangerCode,
          reason: '值为空',
          suggestion: '必须从危险源信息中选择已有区域编号',
          category: CheckCategory.missing,
          isFixable: false,
        ));
      } else if (!validDangerCodes.contains(areaVal)) {
        _highlight(sheet, r, colArea, _yellowFill);
        logs.add(CheckLogEntry(
          index: logs.length + 1,
          sheet: sheetName,
          row: r,
          col: colArea,
          colName: _colDangerCode,
          reason: "'$areaVal' 不在危险源信息中",
          suggestion: "请从'危险源信息'sheet中已有编号中选择",
          category: CheckCategory.mismatch,
          isFixable: false,
        ));
      }

      // 设备名称编号唯一性
      if (devnoVal.isEmpty) {
        _highlight(sheet, r, colDevno, _yellowFill);
        logs.add(CheckLogEntry(
          index: logs.length + 1,
          sheet: sheetName,
          row: r,
          col: colDevno,
          colName: _colDeviceNameNo,
          reason: '值为空',
          suggestion: '设备名称编号为必填项且需唯一',
          category: CheckCategory.missing,
          isFixable: false,
        ));
      } else if (seenDevno.contains(devnoVal)) {
        _highlight(sheet, r, colDevno, _yellowFill);
        logs.add(CheckLogEntry(
          index: logs.length + 1,
          sheet: sheetName,
          row: r,
          col: colDevno,
          colName: _colDeviceNameNo,
          reason: "'$devnoVal' 在本 sheet 中重复出现",
          suggestion: '设备名称编号必须唯一，请修改重复值',
          category: CheckCategory.duplicate,
          isFixable: false,
        ));
      } else {
        seenDevno.add(devnoVal);
      }

      // 设备编码格式 + 唯一性
      if (areaVal.isNotEmpty) {
        if (devcodeVal.isEmpty) {
          // 设备编码为空，仍记录映射（供指标 sheet 查找）
          deviceCodeGlobal[sheetName]![devnoVal] = '';
        } else {
          final pattern = RegExp(
              '^${_escapeRegex(areaVal)}${_escapeRegex(codeInfix)}\\d{3}\$');
          if (!pattern.hasMatch(devcodeVal)) {
            _highlight(sheet, r, colDevcode, _yellowFill);
            logs.add(CheckLogEntry(
              index: logs.length + 1,
              sheet: sheetName,
              row: r,
              col: colDevcode,
              colName: _colDeviceCode,
              reason: "'$devcodeVal' 格式不符合规则",
              suggestion:
                  '格式应为：$areaVal$codeInfix\$_{001}（区域编号+$codeInfix+3位流水号）',
              category: CheckCategory.format,
              isFixable: true,
            ));
          }
          if (seenDevcode.contains(devcodeVal)) {
            _highlight(sheet, r, colDevcode, _yellowFill);
            logs.add(CheckLogEntry(
              index: logs.length + 1,
              sheet: sheetName,
              row: r,
              col: colDevcode,
              colName: _colDeviceCode,
              reason: "'$devcodeVal' 在本 sheet 中重复出现",
              suggestion: '设备编码必须唯一，请修改流水号使其唯一',
              category: CheckCategory.duplicate,
              isFixable: false,
            ));
          } else {
            seenDevcode.add(devcodeVal);
          }
          deviceCodeGlobal[sheetName]![devnoVal] = devcodeVal;
        }
      }
    }
  }

  void _checkIndicatorSheet(Excel excel, List<CheckLogEntry> logs,
      Map<String, Map<String, String>> deviceCodeGlobal) {
    final sheet = excel['指标信息'];
    if (sheet == null) return;

    final colDevtype = _colIndexByHeader(sheet, _colDeviceType);
    final colDevno = _colIndexByHeader(sheet, _colDeviceNameNo);
    final colDevcode = _colIndexByHeader(sheet, _colDeviceCode);
    final colIndtype = _colIndexByHeader(sheet, _colIndicatorType);
    final colIndcode = _colIndexByHeader(sheet, _colIndicatorCode);
    final colIndno = _colIndexByHeader(sheet, _colIndicatorNo);

    if (colDevtype == null ||
        colDevno == null ||
        colDevcode == null ||
        colIndtype == null ||
        colIndcode == null) return;

    final seenIndcode = <String>{};
    final seenIndno = <String>{};
    final rows = _getDataRows(sheet);

    for (final r in rows) {
      final devtypeVal = _getVal(sheet, r, colDevtype).trim();
      final devnoVal = _getVal(sheet, r, colDevno).trim();
      final devcodeVal = _getVal(sheet, r, colDevcode).trim();
      final indtypeVal = _getVal(sheet, r, colIndtype).trim();
      final indcodeVal = _getVal(sheet, r, colIndcode).trim();

      // 查找正确的设备编码（指标信息中设备编码可能为空）
      var correctDevcode = '';
      if (devnoVal.isNotEmpty) {
        final ts = devtypeVal.isNotEmpty ? _categoryToSheet(devtypeVal) : null;
        if (ts != null) {
          correctDevcode = (deviceCodeGlobal[ts] ?? {})[devnoVal] ?? '';
        }
      }
      final effectiveDevcode =
          correctDevcode.isNotEmpty ? correctDevcode : devcodeVal;

      // 设备名称编号* 必须在对应 sheet 中找到
      if (devnoVal.isNotEmpty) {
        final ts = devtypeVal.isNotEmpty ? _categoryToSheet(devtypeVal) : null;
        if (ts != null) {
          final mapping = deviceCodeGlobal[ts] ?? {};
          if (!mapping.containsKey(devnoVal)) {
            _highlight(sheet, r, colDevno, _yellowFill);
            logs.add(CheckLogEntry(
              index: logs.length + 1,
              sheet: '指标信息',
              row: r,
              col: colDevno,
              colName: _colDeviceNameNo,
              reason: "'$devnoVal' 在 '$ts' 中未找到",
              suggestion: "请确保'设备类别*'与'$ts'中存在对应的设备名称编号",
              category: CheckCategory.mismatch,
              isFixable: false,
            ));
          } else {
            // 设备编码一致性
            final expectedCode = mapping[devnoVal]!;
            if (expectedCode.isNotEmpty &&
                devcodeVal.isNotEmpty &&
                devcodeVal != expectedCode) {
              _highlight(sheet, r, colDevcode, _yellowFill);
              logs.add(CheckLogEntry(
                index: logs.length + 1,
                sheet: '指标信息',
                row: r,
                col: colDevcode,
                colName: _colDeviceCode,
                reason: "'$devcodeVal' 与 '$ts' 中该设备编码 '$expectedCode' 不一致",
                suggestion: "请将设备编码改为 '$expectedCode'",
                category: CheckCategory.format,
                isFixable: true,
              ));
            }
          }
        } else if (devtypeVal.isNotEmpty) {
          _highlight(sheet, r, colDevtype, _yellowFill);
          logs.add(CheckLogEntry(
            index: logs.length + 1,
            sheet: '指标信息',
            row: r,
            col: colDevtype,
            colName: _colDeviceType,
            reason: "'$devtypeVal' 无法识别",
            suggestion: '设备类别应为：罐 / 仓库 / 装置 / 气体检测',
            category: CheckCategory.mismatch,
            isFixable: false,
          ));
        }
      } else {
        _highlight(sheet, r, colDevno, _yellowFill);
        logs.add(CheckLogEntry(
          index: logs.length + 1,
          sheet: '指标信息',
          row: r,
          col: colDevno,
          colName: _colDeviceNameNo,
          reason: '值为空',
          suggestion: '必须填写设备名称编号',
          category: CheckCategory.missing,
          isFixable: false,
        ));
      }

      // 指标编码格式 + 唯一性
      if (indcodeVal.isNotEmpty) {
        final indSuffix = _getIndicatorSuffix(indtypeVal);
        if (indSuffix != null && effectiveDevcode.isNotEmpty) {
          final pattern = RegExp(
              '^${_escapeRegex(effectiveDevcode)}${_escapeRegex(indSuffix)}\\d{3}\$');
          if (!pattern.hasMatch(indcodeVal)) {
            _highlight(sheet, r, colIndcode, _yellowFill);
            logs.add(CheckLogEntry(
              index: logs.length + 1,
              sheet: '指标信息',
              row: r,
              col: colIndcode,
              colName: _colIndicatorCode,
              reason: "'$indcodeVal' 格式不符合规则",
              suggestion:
                  '格式应为：$effectiveDevcode$indSuffix\$_{001}（设备编码+$indSuffix+3位流水号）',
              category: CheckCategory.format,
              isFixable: true,
            ));
          }
        }
        if (seenIndcode.contains(indcodeVal)) {
          _highlight(sheet, r, colIndcode, _yellowFill);
          logs.add(CheckLogEntry(
            index: logs.length + 1,
            sheet: '指标信息',
            row: r,
            col: colIndcode,
            colName: _colIndicatorCode,
            reason: "'$indcodeVal' 在指标信息中重复出现",
            suggestion: '指标编码必须唯一，请修改流水号使其唯一',
            category: CheckCategory.duplicate,
            isFixable: false,
          ));
        } else {
          seenIndcode.add(indcodeVal);
        }
      }

      // 指标类型校验
      if (indtypeVal.isNotEmpty) {
        final cleaned =
            indtypeVal.replaceAll(RegExp(r'(WD|YL|YW|QT)$'), '').trim();
        if (!_indicatorTypeMap.containsKey(cleaned) &&
            !_indicatorTypeMap.containsKey(indtypeVal)) {
          _highlight(sheet, r, colIndtype, _yellowFill);
          logs.add(CheckLogEntry(
            index: logs.length + 1,
            sheet: '指标信息',
            row: r,
            col: colIndtype,
            colName: _colIndicatorType,
            reason: "'$indtypeVal' 不在合法指标类型列表中",
            suggestion: '合法值：温度、压力、液位、可燃气体、有毒气体',
            category: CheckCategory.mismatch,
            isFixable: false,
          ));
        }
      }

      // 指标位号唯一性
      if (colIndno != null) {
        final indnoVal = _getVal(sheet, r, colIndno).trim();
        if (indnoVal.isNotEmpty) {
          if (seenIndno.contains(indnoVal)) {
            _highlight(sheet, r, colIndno, _yellowFill);
            logs.add(CheckLogEntry(
              index: logs.length + 1,
              sheet: '指标信息',
              row: r,
              col: colIndno,
              colName: _colIndicatorNo,
              reason: "'$indnoVal' 在指标信息中重复出现",
              suggestion: '指标位号必须唯一，请修改重复值',
              category: CheckCategory.duplicate,
              isFixable: false,
            ));
          } else {
            seenIndno.add(indnoVal);
          }
        }
      }
    }
  }

  String _buildCheckLog(List<CheckLogEntry> logs) {
    final ts = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final baseName = _getBaseName(xlsxFileName.value);
    final sb = StringBuffer();
    sb.writeln('重大危险源导入模板 数据校验日志');
    sb.writeln('生成时间：$ts');
    sb.writeln('源文件：${xlsxFileName.value}');
    sb.writeln('结果文件：${baseName}_校验结果.xlsx');
    sb.writeln('=' * 60);
    sb.writeln('共发现 ${logs.length} 条问题');
    sb.writeln('=' * 60);
    sb.writeln();
    if (logs.isEmpty) {
      sb.writeln('✅ 未发现任何不合规数据，所有字段均符合填写要求。');
    } else {
      for (final log in logs) {
        sb.writeln(log.toText());
        sb.writeln();
      }
    }
    return sb.toString();
  }

  // ═══════════════════════════════════════════════════
  // 修复逻辑
  // ═══════════════════════════════════════════════════

  Future<void> runFix() async {
    if (_inputFileBytes == null) {
      statusMessage.value = '请先选择 Excel 文件';
      statusType.value = StatusType.error;
      return;
    }

    if (checkResult.value != null && checkResult.value!.manualFixCount > 0) {
      statusMessage.value =
          '❌ 存在 ${checkResult.value!.manualFixCount} 项需人工处理的问题，请先修复后再执行自动修复';
      statusType.value = StatusType.error;
      return;
    }

    isProcessing.value = true;
    statusMessage.value = '正在修复...';
    statusType.value = StatusType.info;

    try {
      // 修复基于原始文件
      final excel = Excel.decodeBytes(_inputFileBytes!);
      final fixLogs = <FixLogEntry>[];
      final warnLogs = <WarnLogEntry>[];
      final validDangerCodes = <String>{};
      final deviceCodeMap = <String, Map<String, String>>{};

      // Step 1: 收集危险源编号
      statusMessage.value = '正在修复：收集危险源编号...';
      _fixCollectDangerCodes(excel, validDangerCodes, fixLogs, warnLogs);

      // Step 1.5: ★预读指标信息页（在 _setVal 污染 SharedString 之前）
      final indicatorCache = _preReadIndicatorSheet(excel);

      // Step 2: 修复设备编码
      statusMessage.value = '正在修复：罐、库基础信息...';
      _fixDeviceCodes(excel, '罐、库基础信息', 'G0', validDangerCodes, deviceCodeMap,
          fixLogs, warnLogs);

      statusMessage.value = '正在修复：装置基础信息...';
      _fixDeviceCodes(excel, '装置基础信息', 'P0', validDangerCodes, deviceCodeMap,
          fixLogs, warnLogs);

      statusMessage.value = '正在修复：气体泄漏检测点基础信息...';
      _fixDeviceCodes(excel, '气体泄漏检测点基础信息', 'Q0', validDangerCodes,
          deviceCodeMap, fixLogs, warnLogs);

      // Step 3: 修复指标信息（使用预读缓存，不再依赖 SharedString.toString()）
      statusMessage.value = '正在修复：指标信息...';
      _fixIndicatorSheet(
          excel, indicatorCache, deviceCodeMap, fixLogs, warnLogs);

      // 输出
      final excelBytes = Uint8List.fromList(excel.encode()!);
      _fixXlsxB64 = base64Encode(excelBytes);
      _fixLogB64 = base64Encode(utf8.encode(_buildFixLog(fixLogs, warnLogs)));

      fixResult.value = FixResult(
          fixLogs: fixLogs, warnLogs: warnLogs, excelBytes: excelBytes);
      currentStep.value = 3;

      if (fixLogs.isEmpty && warnLogs.isEmpty) {
        statusMessage.value = '✅ 无需修复，所有数据已符合要求';
        statusType.value = StatusType.success;
      } else {
        statusMessage.value =
            '✅ 修复 ${fixLogs.length} 项 | ⚠️ 需人工处理 ${warnLogs.length} 项';
        statusType.value = StatusType.success;
      }
    } catch (e) {
      statusMessage.value = '修复失败: $e';
      statusType.value = StatusType.error;
    } finally {
      isProcessing.value = false;
    }
  }

  void _fixCollectDangerCodes(Excel excel, Set<String> validDangerCodes,
      List<FixLogEntry> fixLogs, List<WarnLogEntry> warnLogs) {
    final sheet = excel['危险源信息'];
    if (sheet == null) return;

    final col = _colIndexByHeader(sheet, _colDangerCode);
    if (col == null) return;

    final regExp = RegExp(r'^\d{12}$');
    final rows = _getDataRows(sheet);

    for (final r in rows) {
      final val = _getVal(sheet, r, col).trim();
      if (regExp.hasMatch(val)) {
        validDangerCodes.add(val);
      } else if (val.isNotEmpty) {
        _highlight(sheet, r, col, _redFill);
        warnLogs.add(WarnLogEntry(
          index: warnLogs.length + 1,
          sheet: '危险源信息',
          row: r,
          col: col,
          colName: _colDangerCode,
          reason: "'$val' 不是12位纯数字",
          suggestion: '请手动修正为12位数字（9位企业编码+3位流水号）',
        ));
      }
    }
  }

  void _fixDeviceCodes(
      Excel excel,
      String sheetName,
      String codeInfix,
      Set<String> validDangerCodes,
      Map<String, Map<String, String>> deviceCodeMap,
      List<FixLogEntry> fixLogs,
      List<WarnLogEntry> warnLogs) {
    final sheet = excel[sheetName];
    if (sheet == null) return;

    final colArea = _colIndexByHeader(sheet, _colDangerCode);
    final colDevno = _colIndexByHeader(sheet, _colDeviceNameNo);
    final colDevcode = _colIndexByHeader(sheet, _colDeviceCode);

    if (colArea == null || colDevno == null || colDevcode == null) return;

    deviceCodeMap[sheetName] = {};

    // 按区域编号分组
    final areaGroups = <String, List<_DeviceItem>>{};
    final rows = _getDataRows(sheet);

    for (final r in rows) {
      final area = _getVal(sheet, r, colArea).trim();
      final devno = _getVal(sheet, r, colDevno).trim();
      final devcode = _getVal(sheet, r, colDevcode).trim();
      areaGroups.putIfAbsent(area, () => []);
      areaGroups[area]!.add(_DeviceItem(r, devno, devcode));
    }

    // 对每个区域组重新分配设备编码
    for (final areaVal in areaGroups.keys) {
      final items = areaGroups[areaVal]!;

      if (areaVal.isEmpty) {
        for (final item in items) {
          if (item.devno.isEmpty) {
            _highlight(sheet, item.row, colDevno, _redFill);
            warnLogs.add(WarnLogEntry(
              index: warnLogs.length + 1,
              sheet: sheetName,
              row: item.row,
              col: colDevno,
              colName: _colDeviceNameNo,
              reason: '值为空',
              suggestion: '设备名称编号为必填项，请手动填写',
            ));
          } else {
            _highlight(sheet, item.row, colArea, _redFill);
            warnLogs.add(WarnLogEntry(
              index: warnLogs.length + 1,
              sheet: sheetName,
              row: item.row,
              col: colArea,
              colName: _colDangerCode,
              reason: '区域编号为空',
              suggestion: '请从危险源信息中选择已有编号',
            ));
          }
        }
        continue;
      }

      if (!validDangerCodes.contains(areaVal)) {
        for (final item in items) {
          _highlight(sheet, item.row, colArea, _redFill);
          warnLogs.add(WarnLogEntry(
            index: warnLogs.length + 1,
            sheet: sheetName,
            row: item.row,
            col: colArea,
            colName: _colDangerCode,
            reason: "'$areaVal' 不在危险源信息中",
            suggestion: '请修改为已有编号',
          ));
        }
        continue;
      }

      // 检查设备名称编号唯一性
      final seenDevno = <String>{};
      final dupDevnos = <String>{};
      for (final item in items) {
        if (item.devno.isEmpty) {
          _highlight(sheet, item.row, colDevno, _redFill);
          warnLogs.add(WarnLogEntry(
            index: warnLogs.length + 1,
            sheet: sheetName,
            row: item.row,
            col: colDevno,
            colName: _colDeviceNameNo,
            reason: '值为空',
            suggestion: '设备名称编号为必填项，请手动填写',
          ));
        } else if (seenDevno.contains(item.devno)) {
          dupDevnos.add(item.devno);
          _highlight(sheet, item.row, colDevno, _redFill);
          warnLogs.add(WarnLogEntry(
            index: warnLogs.length + 1,
            sheet: sheetName,
            row: item.row,
            col: colDevno,
            colName: _colDeviceNameNo,
            reason: "'${item.devno}' 重复出现",
            suggestion: '设备名称编号必须唯一，请手动修改其中一个',
          ));
        } else {
          seenDevno.add(item.devno);
        }
      }

      // 有效设备列表
      final validItems = items
          .where((i) => i.devno.isNotEmpty && !dupDevnos.contains(i.devno))
          .toList();

      // 提取已有正确格式的编码
      final existingSeq = <String, int>{};
      final correctPattern = RegExp(
          '^${_escapeRegex(areaVal)}${_escapeRegex(codeInfix)}(\\d{3})\$');
      for (final item in validItems) {
        if (item.devcode.isNotEmpty) {
          final m = correctPattern.firstMatch(item.devcode);
          if (m != null) {
            existingSeq[item.devno] = int.parse(m.group(1)!);
          }
        }
      }

      // 判断是否需要重新分配
      bool needReassign;
      if (existingSeq.length != validItems.length) {
        needReassign = true;
      } else {
        final usedSeqs = existingSeq.values.toSet();
        final expected =
            Set.from(List.generate(validItems.length, (i) => i + 1));
        needReassign = usedSeqs != expected;
      }

      if (needReassign) {
        // 收集所有已使用的序列号
        final allUsedSeqs = <int>{};
        for (final item in validItems) {
          if (item.devcode.isNotEmpty) {
            final m = correctPattern.firstMatch(item.devcode);
            if (m != null) allUsedSeqs.add(int.parse(m.group(1)!));
          }
        }

        var nextSeq = 1;
        for (final item in validItems) {
          if (item.devcode.isNotEmpty) {
            final m = correctPattern.firstMatch(item.devcode);
            if (m != null) {
              final curSeq = int.parse(m.group(1)!);
              if (curSeq == nextSeq) {
                nextSeq++;
                deviceCodeMap[sheetName]![item.devno] = item.devcode;
                continue;
              }
            }
          }
          // 跳过已占用的序号
          while (allUsedSeqs.contains(nextSeq)) nextSeq++;
          final newCode =
              '$areaVal$codeInfix${nextSeq.toString().padLeft(3, '0')}';
          final oldVal = item.devcode.isNotEmpty ? item.devcode : '(空)';
          _highlight(sheet, item.row, colDevcode, _greenFill);
          _setVal(sheet, item.row, colDevcode, newCode);
          fixLogs.add(FixLogEntry(
            index: fixLogs.length + 1,
            sheet: sheetName,
            row: item.row,
            col: colDevcode,
            colName: _colDeviceCode,
            oldValue: oldVal,
            newValue: newCode,
          ));
          deviceCodeMap[sheetName]![item.devno] = newCode;
          nextSeq++;
        }
      } else {
        for (final item in validItems) {
          deviceCodeMap[sheetName]![item.devno] = item.devcode;
        }
      }
    }
  }

  /// ★预读指标信息页所有数据（在 _setVal 污染 SharedString 前执行）
  List<_IndicatorRowCache> _preReadIndicatorSheet(Excel excel) {
    final result = <_IndicatorRowCache>[];
    final sheet = excel['指标信息'];
    if (sheet == null) return result;

    final colDevtype = _colIndexByHeader(sheet, _colDeviceType);
    final colDevno = _colIndexByHeader(sheet, _colDeviceNameNo);
    final colDevcode = _colIndexByHeader(sheet, _colDeviceCode);
    final colIndtype = _colIndexByHeader(sheet, _colIndicatorType);
    final colIndcode = _colIndexByHeader(sheet, _colIndicatorCode);

    if (colDevtype == null ||
        colDevno == null ||
        colDevcode == null ||
        colIndtype == null ||
        colIndcode == null) return result;

    for (final r in _getDataRows(sheet)) {
      result.add(_IndicatorRowCache(
        row: r,
        dtype: _getVal(sheet, r, colDevtype).trim(),
        dno: _getVal(sheet, r, colDevno).trim(),
        dc: _getVal(sheet, r, colDevcode).trim(),
        it: _getVal(sheet, r, colIndtype).trim(),
        ic: _getVal(sheet, r, colIndcode).trim(),
      ));
    }
    return result;
  }

  void _fixIndicatorSheet(
      Excel excel,
      List<_IndicatorRowCache> indicatorCache,
      Map<String, Map<String, String>> deviceCodeMap,
      List<FixLogEntry> fixLogs,
      List<WarnLogEntry> warnLogs) {
    final sheet = excel['指标信息'];
    if (sheet == null) return;

    final colDevtype = _colIndexByHeader(sheet, _colDeviceType);
    final colDevno = _colIndexByHeader(sheet, _colDeviceNameNo);
    final colDevcode = _colIndexByHeader(sheet, _colDeviceCode);
    final colIndtype = _colIndexByHeader(sheet, _colIndicatorType);
    final colIndcode = _colIndexByHeader(sheet, _colIndicatorCode);

    if (colDevtype == null ||
        colDevno == null ||
        colDevcode == null ||
        colIndtype == null ||
        colIndcode == null) return;

    // 使用预读缓存按设备分组
    // ★ 注意: 不能使用 \0（null字符），Flutter Web 编译到 JS 后 \0 会变成字符 '0'，
    // 导致设备编号中的数字 0 被错误拆分（如 "甲醇储罐V2101" → "甲醇储罐V21"+"1"）
    const sep = '\t';
    final deviceGroups = <String, List<_IndicatorItem>>{}; // key = "dtype\tdno"

    for (final row in indicatorCache) {
      final key = '${row.dtype}$sep${row.dno}';
      deviceGroups.putIfAbsent(key, () => []);
      deviceGroups[key]!.add(_IndicatorItem(row.row, row.dc, row.it, row.ic));
    }

    final allIndCodes = <String>{}; // 全局已用指标编码

    for (final key in deviceGroups.keys) {
      final parts = key.split(sep);
      final dtype = parts[0];
      final dno = parts[1];
      final items = deviceGroups[key]!;

      if (dno.isEmpty) {
        for (final item in items) {
          _highlight(sheet, item.row, colDevno, _redFill);
          warnLogs.add(WarnLogEntry(
            index: warnLogs.length + 1,
            sheet: '指标信息',
            row: item.row,
            col: colDevno,
            colName: _colDeviceNameNo,
            reason: '值为空',
            suggestion: '请手动填写设备名称编号',
          ));
        }
        continue;
      }

      if (dtype.isEmpty) {
        for (final item in items) {
          _highlight(sheet, item.row, colDevtype, _redFill);
          warnLogs.add(WarnLogEntry(
            index: warnLogs.length + 1,
            sheet: '指标信息',
            row: item.row,
            col: colDevtype,
            colName: _colDeviceType,
            reason: '值为空',
            suggestion: '请选择设备类别：罐/仓库/装置/气体检测',
          ));
        }
        continue;
      }

      final targetSheet = _categoryToSheet(dtype);
      if (targetSheet == null) {
        for (final item in items) {
          _highlight(sheet, item.row, colDevtype, _redFill);
          warnLogs.add(WarnLogEntry(
            index: warnLogs.length + 1,
            sheet: '指标信息',
            row: item.row,
            col: colDevtype,
            colName: _colDeviceType,
            reason: "'$dtype' 无法识别",
            suggestion: '应为：罐/仓库/装置/气体检测',
          ));
        }
        continue;
      }

      final mapping = deviceCodeMap[targetSheet] ?? {};
      if (!mapping.containsKey(dno)) {
        for (final item in items) {
          _highlight(sheet, item.row, colDevno, _redFill);
          warnLogs.add(WarnLogEntry(
            index: warnLogs.length + 1,
            sheet: '指标信息',
            row: item.row,
            col: colDevno,
            colName: _colDeviceNameNo,
            reason: "'$dno' 在 '$targetSheet' 中未找到",
            suggestion: "请确保设备名称编号与'$targetSheet'中一致",
          ));
        }
        continue;
      }

      final correctDevcode = mapping[dno]!;

      // 回填设备编码
      for (final item in items) {
        if (item.dc.isNotEmpty && item.dc != correctDevcode) {
          _highlight(sheet, item.row, colDevcode, _greenFill);
          _setVal(sheet, item.row, colDevcode, correctDevcode);
          fixLogs.add(FixLogEntry(
            index: fixLogs.length + 1,
            sheet: '指标信息',
            row: item.row,
            col: colDevcode,
            colName: _colDeviceCode,
            oldValue: item.dc,
            newValue: correctDevcode,
          ));
        } else if (item.dc.isEmpty) {
          _highlight(sheet, item.row, colDevcode, _greenFill);
          _setVal(sheet, item.row, colDevcode, correctDevcode);
          fixLogs.add(FixLogEntry(
            index: fixLogs.length + 1,
            sheet: '指标信息',
            row: item.row,
            col: colDevcode,
            colName: _colDeviceCode,
            oldValue: '(空)',
            newValue: correctDevcode,
          ));
        }
      }

      // 校验指标类型
      for (final item in items) {
        if (item.it.isEmpty) {
          _highlight(sheet, item.row, colIndtype, _redFill);
          warnLogs.add(WarnLogEntry(
            index: warnLogs.length + 1,
            sheet: '指标信息',
            row: item.row,
            col: colIndtype,
            colName: _colIndicatorType,
            reason: '值为空',
            suggestion: '请填写指标类型：温度/压力/液位/可燃气体/有毒气体',
          ));
          continue;
        }
        final suffix = _getIndicatorSuffix(item.it);
        if (suffix == null) {
          _highlight(sheet, item.row, colIndtype, _redFill);
          warnLogs.add(WarnLogEntry(
            index: warnLogs.length + 1,
            sheet: '指标信息',
            row: item.row,
            col: colIndtype,
            colName: _colIndicatorType,
            reason: "'${item.it}' 不在合法列表中",
            suggestion: '合法值：温度/压力/液位/可燃气体/有毒气体',
          ));
        }
      }

      // 按类型缩写分组分配指标编码
      final typeGroups = <String, List<_IndicatorItem>>{};
      for (final item in items) {
        final suffix = _getIndicatorSuffix(item.it);
        if (suffix != null) {
          typeGroups.putIfAbsent(suffix, () => []);
          typeGroups[suffix]!.add(item);
        }
      }

      for (final suffix in typeGroups.keys) {
        final typeItems = typeGroups[suffix]!;
        final codePattern = RegExp(
            '^${_escapeRegex(correctDevcode)}${_escapeRegex(suffix)}(\\d{3})\$');

        // 提取已有正确格式的编码
        final existingSeqs = <_SeqItem>[];
        for (final item in typeItems) {
          if (item.ic.isNotEmpty) {
            final m = codePattern.firstMatch(item.ic);
            if (m != null) {
              existingSeqs
                  .add(_SeqItem(int.parse(m.group(1)!), item.row, item.ic));
            }
          }
        }

        // 判断是否需要重编
        bool needReassign;
        if (existingSeqs.length != typeItems.length) {
          needReassign = true;
        } else {
          final seqSet = existingSeqs.map((s) => s.seq).toSet();
          final expected =
              Set.from(List.generate(typeItems.length, (i) => i + 1));
          needReassign = seqSet != expected;
        }

        if (needReassign) {
          final allUsedInType = existingSeqs.map((s) => s.seq).toSet();
          var nextSeq = 1;
          for (final item in typeItems) {
            if (item.ic.isNotEmpty) {
              final m = codePattern.firstMatch(item.ic);
              if (m != null) {
                final cur = int.parse(m.group(1)!);
                if (cur == nextSeq && !allIndCodes.contains(item.ic)) {
                  allIndCodes.add(item.ic);
                  nextSeq++;
                  continue;
                }
              }
            }
            // 跳过已占用的编码
            while (allIndCodes.contains(
                '$correctDevcode$suffix${nextSeq.toString().padLeft(3, '0')}')) {
              nextSeq++;
            }
            final newIc =
                '$correctDevcode$suffix${nextSeq.toString().padLeft(3, '0')}';
            final oldVal = item.ic.isNotEmpty ? item.ic : '(空)';
            _highlight(sheet, item.row, colIndcode, _greenFill);
            _setVal(sheet, item.row, colIndcode, newIc);
            fixLogs.add(FixLogEntry(
              index: fixLogs.length + 1,
              sheet: '指标信息',
              row: item.row,
              col: colIndcode,
              colName: _colIndicatorCode,
              oldValue: oldVal,
              newValue: newIc,
            ));
            allIndCodes.add(newIc);
            nextSeq++;
          }
        } else {
          for (final item in typeItems) {
            if (item.ic.isNotEmpty) allIndCodes.add(item.ic);
          }
        }
      }
    }
  }

  String _buildFixLog(List<FixLogEntry> fixLogs, List<WarnLogEntry> warnLogs) {
    final ts = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final baseName = _getBaseName(xlsxFileName.value);
    final sb = StringBuffer();
    sb.writeln('重大危险源导入模板 数据修复日志');
    sb.writeln('生成时间：$ts');
    sb.writeln('源文件：${xlsxFileName.value}');
    sb.writeln('结果文件：${baseName}_修复结果.xlsx');
    sb.writeln('=' * 60);
    sb.writeln('自动修复：${fixLogs.length} 项');
    sb.writeln('需人工处理：${warnLogs.length} 项');
    sb.writeln('=' * 60);
    sb.writeln();

    if (fixLogs.isNotEmpty) {
      sb.writeln('── 自动修复明细 ──');
      sb.writeln();
      for (final log in fixLogs) {
        sb.writeln(log.toText());
        sb.writeln();
      }
    }

    if (warnLogs.isNotEmpty) {
      sb.writeln('── 需人工处理 ──');
      sb.writeln();
      for (final log in warnLogs) {
        sb.writeln(log.toText());
        sb.writeln();
      }
    }

    if (fixLogs.isEmpty && warnLogs.isEmpty) {
      sb.writeln('✅ 无需修复，所有数据已符合要求。');
    }

    return sb.toString();
  }
}

// ══════════════════════════════════════════════════════
// 辅助数据类
// ══════════════════════════════════════════════════════

class _DeviceItem {
  final int row;
  final String devno;
  final String devcode;
  _DeviceItem(this.row, this.devno, this.devcode);
}

class _IndicatorItem {
  final int row;
  final String dc; // 设备编码
  final String it; // 指标类型
  final String ic; // 指标编码
  _IndicatorItem(this.row, this.dc, this.it, this.ic);
}

class _SeqItem {
  final int seq;
  final int row;
  final String code;
  _SeqItem(this.seq, this.row, this.code);
}

/// 指标信息行预读缓存（防止 _setVal 污染 SharedString 单例后 toString() 截断）
class _IndicatorRowCache {
  final int row;
  final String dtype; // 设备类别*
  final String dno; // 设备名称编号*
  final String dc; // 设备编码
  final String it; // 指标类型*
  final String ic; // 指标编码
  _IndicatorRowCache({
    required this.row,
    required this.dtype,
    required this.dno,
    required this.dc,
    required this.it,
    required this.ic,
  });
}

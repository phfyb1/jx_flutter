import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controller/AlarmToolController.dart';

class AlarmToolPage extends StatefulWidget {
  const AlarmToolPage({super.key});

  @override
  State<AlarmToolPage> createState() => _AlarmToolPageState();
}

class _AlarmToolPageState extends State<AlarmToolPage> {
  late final AlarmToolController controller;

  // ===== 配色方案 =====
  static const _primaryBlue = Color(0xFF1976D2);
  static const _successGreen = Color(0xFF388E3C);
  static const _errorRed = Color(0xFFD32F2F);
  static const _warningOrange = Color(0xFFF57C00);
  static const _surfaceGrey = Color(0xFFF5F5F5);
  static const _borderGrey = Color(0xFFE0E0E0);
  static const _textPrimary = Color(0xFF212121);
  static const _textSecondary = Color(0xFF757575);
  // ── 统一渐变色（与首页报警规则卡片图标一致 #EF4444）───────
  static const _gradA = Color(0xFFEF4444);
  static const _gradB = Color(0xFFDC2626);
  // ── 柔和彩虹渐变色（红系：珊瑚→橙红→红→深红→枣红）────────────
  static const _gradC = Color(0xFFF97316); // 橙色
  static const _gradD = Color(0xFFFB7185); // 珊瑚粉
  static const _gradE = Color(0xFFBE123C); // 深红

  // 步骤进度：1基本信息 2上传文件 3生成下载
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AlarmToolController());
  }

  // ===== 更新步骤进度 =====
  void _updateStep() {
    int step = 1;
    if (controller.xlsxFileName.value.isNotEmpty ||
        controller.jsonFileName.value.isNotEmpty) {
      step = 2;
    }
    if (controller.sqlFiles.isNotEmpty) {
      step = 3;
    }
    if (mounted) setState(() => _currentStep = step);
  }

  // ===== 重置 =====
  void _handleReset() {
    controller.xlsxFileName.value = '';
    controller.jsonFileName.value = '';
    controller.companyName.value = '';
    controller.sqlFiles.clear();
    controller.status.value = '';
    controller.statusType.value = '';
  }

  @override
  Widget build(BuildContext context) {
    // 监听数据变化，动态更新步骤
    ever(controller.xlsxFileName, (_) => _updateStep());
    ever(controller.jsonFileName, (_) => _updateStep());
    ever(controller.sqlFiles, (_) => _updateStep());

    return Scaffold(
      body: Stack(
        children: [
          // 渐变背景 + 装饰
          _buildGradientBackground(),
          // 内容
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildStepProgress(),
                            const SizedBox(height: 16),
                            _buildStepCard(
                              step: 1,
                              title: '基本信息',
                              icon: Icons.business,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCompanyNameInput(),
                                  const SizedBox(height: 8),
                                  Text(
                                    '公司名称将作为 SQL 规则名前缀，例如：某某化工厂',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildStepCard(
                              step: 2,
                              title: '上传文件',
                              icon: Icons.upload_file,
                              child: Column(
                                children: [
                                  _buildFileUploadCard(
                                    icon: Icons.grid_on,
                                    label: 'XLSX 配置表',
                                    hint: '请选择报警规则 Excel 文件（.xlsx）',
                                    fileNameObs: controller.xlsxFileName,
                                    onTap: controller.pickXlsxFile,
                                    accentColor: _primaryBlue,
                                  ),
                                  const SizedBox(height: 10),
                                  _buildFileUploadCard(
                                    icon: Icons.data_object,
                                    label: '传感器 JSON',
                                    hint: 'iot_device_sensor.json（需包含 id / element_code）',
                                    fileNameObs: controller.jsonFileName,
                                    onTap: controller.pickJsonFile,
                                    accentColor: _warningOrange,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildStepCard(
                              step: 3,
                              title: '生成 SQL',
                              icon: Icons.play_arrow,
                              child: Column(
                                children: [
                                  _buildGenerateButton(),
                                  const SizedBox(height: 12),
                                  Obx(() => _buildStatusDisplay(
                                        controller.status.value,
                                        controller.statusType.value,
                                      )),
                                  Obx(() => _buildSummaryStats(controller.sqlFiles)),
                                  Obx(() => _buildDownloadSection(controller.sqlFiles)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 渐变背景 + 装饰圆 ─────────────────────────────
  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1.0, -1.0),
          end: Alignment(1.0, 1.0),
          colors: [_gradD, _gradA, _gradE],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 波点阵列
          Positioned.fill(
            child: CustomPaint(painter: _DotPatternPainter()),
          ),
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -40, left: -40,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            top: 100, left: 80,
            child: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 顶部标题行 ──────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: Colors.white,
            onPressed: () => Get.back(),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '报警规则 SQL 生成工具',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  '步骤 1 · 2 · 3',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.white70,
            tooltip: '重置',
            onPressed: _handleReset,
          ),
        ],
      ),
    );
  }

  // ===== 步骤进度指示器 =====
  Widget _buildStepProgress() {
    final steps = [
      {'label': '基本信息', 'icon': Icons.business},
      {'label': '上传文件', 'icon': Icons.upload_file},
      {'label': '生成下载', 'icon': Icons.download},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final stepIndex = index + 1;
          final isActive = _currentStep >= stepIndex;
          final isCurrent = _currentStep == stepIndex;

          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: _currentStep > index
                            ? _primaryBlue
                            : _borderGrey,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isActive ? _primaryBlue : _borderGrey,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: _primaryBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: isActive && _currentStep > stepIndex
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : Text(
                              '$stepIndex',
                              style: TextStyle(
                                color: isActive ? Colors.white : _textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      steps[index]['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                        color: isActive ? _primaryBlue : _textSecondary,
                      ),
                    ),
                  ],
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: _currentStep > index + 1
                            ? _primaryBlue
                            : _borderGrey,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ===== 步骤卡片 =====
  Widget _buildStepCard({
    required int step,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCurrent
            ? Border.all(color: _primaryBlue.withOpacity(0.5), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isCurrent ? 0.07 : 0.04),
            blurRadius: isCurrent ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isActive ? _primaryBlue : _borderGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$step',
                    style: TextStyle(
                      color: isActive ? Colors.white : _textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon,
                    color: isActive ? _primaryBlue : _textSecondary, size: 20),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isActive ? _textPrimary : _textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  // ===== 公司名称输入 =====
  Widget _buildCompanyNameInput() {
    return TextField(
      onChanged: (value) => controller.companyName.value = value,
      decoration: InputDecoration(
        labelText: '公司名称',
        hintText: '例如：康地',
        prefixIcon: const Icon(Icons.business, color: _textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(fontSize: 15),
    );
  }

  // ===== 文件上传卡片 =====
  Widget _buildFileUploadCard({
    required IconData icon,
    required String label,
    required String hint,
    required RxString fileNameObs,
    required VoidCallback onTap,
    required Color accentColor,
  }) {
    return Obx(() {
      final hasFile = fileNameObs.value.isNotEmpty;
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasFile
                ? accentColor.withOpacity(0.05)
                : _surfaceGrey,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasFile
                  ? accentColor.withOpacity(0.35)
                  : _borderGrey,
              width: hasFile ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: hasFile
                      ? accentColor.withOpacity(0.12)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  hasFile ? Icons.check_circle : icon,
                  color: hasFile ? accentColor : _textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: hasFile ? _textPrimary : _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasFile ? fileNameObs.value : hint,
                      style: TextStyle(
                        fontSize: 12,
                        color: hasFile ? accentColor : _textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hasFile ? '重新选择' : '选择文件',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ===== 生成按钮 =====
  Widget _buildGenerateButton() {
    return Obx(() {
      final canGenerate = controller.xlsxFileName.value.isNotEmpty &&
          controller.jsonFileName.value.isNotEmpty &&
          controller.companyName.value.isNotEmpty;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: canGenerate ? _handleGenerateSql : null,
          icon: const Icon(Icons.auto_awesome, size: 20),
          label: const Text(
            '生成 SQL 文件',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _successGreen,
            disabledBackgroundColor: Colors.grey[300],
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.grey[600],
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 1,
          ),
        ),
      );
    });
  }

  // ===== 处理 SQL 生成 =====
  void _handleGenerateSql() {
    controller.processFiles();
  }

  // ===== 状态显示 =====
  Widget _buildStatusDisplay(String message, String type) {
    if (message.isEmpty) return const SizedBox.shrink();

    final config = _getStatusConfig(type);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: config.borderColor),
      ),
      child: Row(
        children: [
          Icon(config.icon, color: config.iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: config.textColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  _StatusDisplayConfig _getStatusConfig(String type) {
    switch (type) {
      case 'success':
        return const _StatusDisplayConfig(
          backgroundColor: Color(0xFFE8F5E9),
          borderColor: Color(0xFFA5D6A7),
          iconColor: _successGreen,
          textColor: Color(0xFF2E7D32),
          icon: Icons.check_circle,
        );
      case 'error':
        return const _StatusDisplayConfig(
          backgroundColor: Color(0xFFFFEBEE),
          borderColor: Color(0xFFEF9A9A),
          iconColor: _errorRed,
          textColor: Color(0xFFC62828),
          icon: Icons.error,
        );
      case 'info':
        return const _StatusDisplayConfig(
          backgroundColor: Color(0xFFE3F2FD),
          borderColor: Color(0xFF90CAF9),
          iconColor: _primaryBlue,
          textColor: Color(0xFF1565C0),
          icon: Icons.hourglass_empty,
        );
      default:
        return const _StatusDisplayConfig(
          backgroundColor: Color(0xFFFFF8E1),
          borderColor: Color(0xFFFFE082),
          iconColor: _warningOrange,
          textColor: Color(0xFFE65100),
          icon: Icons.info,
        );
    }
  }

  // ===== 汇总统计 =====
  Widget _buildSummaryStats(List<Map<String, dynamic>> files) {
    if (files.isEmpty) return const SizedBox.shrink();

    int totalRecords = 0;
    for (var f in files) {
      totalRecords += (f['count'] as int? ?? 0);
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _primaryBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _primaryBlue.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.summarize, color: _primaryBlue, size: 18),
          const SizedBox(width: 8),
          Text(
            '共生成 ${files.length} 个 SQL 文件，$totalRecords 条记录',
            style: const TextStyle(
              fontSize: 13,
              color: _primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ===== 下载区域（2x2 网格） =====
  Widget _buildDownloadSection(List<Map<String, dynamic>> files) {
    if (files.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        const Row(
          children: [
            Icon(Icons.download, color: _primaryBlue, size: 18),
            SizedBox(width: 6),
            Text(
              '下载文件',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.6,
          ),
          itemCount: files.length,
          itemBuilder: (context, index) => _buildFileDownloadCard(files[index]),
        ),
      ],
    );
  }

  // ===== 文件下载卡片（支持点击预览） =====
  Widget _buildFileDownloadCard(Map<String, dynamic> file) {
    if (file['name'] is! String || file['content'] is! String) {
      return const SizedBox.shrink();
    }

    final fileName = file['name'] as String;
    final content = file['content'] as String;
    final insertCount = file['count'] as int? ?? 0;

    // 根据文件名判断图标
    IconData fileIcon;
    Color iconColor;
    String shortName;
    if (fileName.contains('algorithm')) {
      fileIcon = Icons.psychology;
      iconColor = Colors.purple;
      shortName = '算法';
    } else if (fileName.contains('rel') && fileName.contains('sensor')) {
      fileIcon = Icons.sensors;
      iconColor = Colors.teal;
      shortName = '传感器绑定';
    } else if (fileName.contains('rel')) {
      fileIcon = Icons.link;
      iconColor = Colors.blue;
      shortName = '规则绑定';
    } else {
      fileIcon = Icons.rule;
      iconColor = Colors.orange;
      shortName = '规则';
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showSqlPreview(fileName, content),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _borderGrey),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(fileIcon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      shortName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$insertCount 条  ·  ${(content.length / 1024).toStringAsFixed(1)} KB',
                      style: const TextStyle(
                        fontSize: 11,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // 下载按钮
              GestureDetector(
                onTap: () => _handleFileDownload(file),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.download,
                    color: _primaryBlue,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== SQL 预览弹窗 =====
  void _showSqlPreview(String fileName, String content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.code, color: _primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    tooltip: '复制 SQL',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: content));
                      Get.snackbar(
                        '已复制',
                        'SQL 内容已复制到剪贴板',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: _successGreen,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 8,
                        duration: const Duration(seconds: 2),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      content,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFFD4D4D4),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('关闭'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _handleFileDownload({
                        'name': fileName,
                        'content': content,
                        'type': 'sql',
                      });
                    },
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('下载'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== 处理文件下载 =====
  Future<void> _handleFileDownload(Map<String, dynamic> file) async {
    try {
      HapticFeedback.mediumImpact();
      final String fileName = (file['name'] as String).isNotEmpty
          ? file['name'] as String
          : 'alarm_rule.sql';
      final String fileContent = file['content'] as String;
      final String fileType =
          (file['type'] as String?)?.isNotEmpty == true ? file['type'] as String : 'sql';
      await controller.downloadFile(
        fileName: fileName,
        content: fileContent,
        type: fileType,
      );
    } catch (e) {
      Get.snackbar(
        '下载失败',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _errorRed,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }
}

// ===== 状态显示配置 =====
class _StatusDisplayConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  const _StatusDisplayConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
  });
}
// 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€
// 娉㈢偣闃靛垪缁樺埗鍣紙涓庨椤甸鏍间竴鑷达級
// 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    const spacing = 40.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

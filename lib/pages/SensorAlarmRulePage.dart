import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/SensorAlarmRuleController.dart';

// ══════════════════════════════════════════════════════
// 波点阵列绘制器
// ══════════════════════════════════════════════════════
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
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SensorAlarmRulePage extends StatefulWidget {
  const SensorAlarmRulePage({super.key});

  @override
  State<SensorAlarmRulePage> createState() => _SensorAlarmRulePageState();
}

class _SensorAlarmRulePageState extends State<SensorAlarmRulePage> {
  final SensorAlarmRuleController controller =
      Get.put(SensorAlarmRuleController());

  // ── 主题色（与首页传感器报警规则卡片图标一致 #06B6D4）──────
  static const _accent = Color(0xFF06B6D4);   // 蓝绿
  static const _accentDark = Color(0xFF0891B2);
  static const _gradLight = Color(0xFF67E8F9); // 顶部浅蓝绿
  static const _gradEnd = Color(0xFF0891B2);   // 底部中深

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   controller.statusMessage.value = '传感器报警规则工具已就绪';
    //   controller.statusType.value = StatusType.info;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1.0, -1.0),
            end: Alignment(1.0, 1.0),
            colors: [_gradLight, _accent, _gradEnd],
          ),
        ),
        child: Stack(
          children: [
            // 波点背景
            Positioned.fill(
              child: CustomPaint(painter: _DotPatternPainter()),
            ),
            // 内容
            CustomScrollView(
              slivers: [
                // 顶部标题区
                SliverAppBar(
                  expandedHeight: 140,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    color: Colors.white,
                    onPressed: () => Get.back(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      '传感器及报警规则SQL生成工具',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-1.0, -1.0),
                          end: Alignment(1.0, 1.0),
                          colors: [_gradLight, _accent, _gradEnd],
                        ),
                      ),
                      child: const SafeArea(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 20),
                              Text(
                                '上传Excel文件，配置参数，一键生成所有传感器及报警规则相关SQL',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // 内容区
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          children: [
                            Obx(() => _buildStatusBanner()),
                            const SizedBox(height: 20),
                            _buildGlassCard(
                              title: '1. 基本配置',
                              icon: Icons.settings,
                              child: _buildConfigSection(),
                            ),
                            const SizedBox(height: 20),
                            _buildGlassCard(
                              title: '2. 上传Excel文件',
                              icon: Icons.upload_file,
                              child: _buildUploadSection(),
                            ),
                            const SizedBox(height: 20),
                            _buildGlassCard(
                              title: '3. 生成SQL',
                              icon: Icons.auto_fix_high,
                              child: _buildGenerateSection(),
                            ),
                            const SizedBox(height: 20),
                            Obx(() => controller.hasResult.value
                                ? _buildGlassCard(
                                    title: '4. 生成结果',
                                    icon: Icons.check_circle,
                                    child: _buildResultSection(),
                                  )
                                : const SizedBox.shrink()),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    final type = controller.statusType.value;
    final message = controller.statusMessage.value;

    Color bgColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case StatusType.success:
        bgColor = Colors.green.shade400;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case StatusType.error:
        bgColor = Colors.red.shade400;
        textColor = Colors.white;
        icon = Icons.error;
        break;
      case StatusType.info:
        bgColor = Colors.blue.shade400;
        textColor = Colors.white;
        icon = Icons.info;
        break;
      default:
        return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: _accent, size: 22),
                ),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSection() {
    return Obx(() {
      final configs = controller.metricsConfig;
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildTextField(
                label: '采集器ID',
                value: controller.collectorId.value,
                onChanged: (v) => controller.collectorId.value = v,
                hint: 'collector_id',
              )),
              const SizedBox(width: 15),
              Expanded(
                  child: _buildTextField(
                label: '项目ID',
                value: controller.projectId.value,
                onChanged: (v) => controller.projectId.value = v,
                hint: 'project_id',
              )),
              const SizedBox(width: 15),
              Expanded(
                  child: _buildTextField(
                label: '企业ID',
                value: controller.firmId.value,
                onChanged: (v) => controller.firmId.value = v,
                hint: '信用代码',
              )),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                  child: _buildTextField(
                label: '企业名称',
                value: controller.companyName.value,
                onChanged: (v) => controller.companyName.value = v,
                hint: '必填',
              )),
              const SizedBox(width: 15),
              Expanded(
                  child: _buildTextField(
                label: '指标/设备标识',
                value: controller.metric.value,
                onChanged: (v) => controller.metric.value = v,
                hint: 'metric',
              )),
              const SizedBox(width: 15),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.category, color: _accent, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      '指标类型配置',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const Spacer(),
                    _buildAddButton(
                      label: '添加',
                      icon: Icons.add,
                      onPressed: () => controller.addMetricConfig(),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ...configs.asMap().entries.map((entry) {
                  return _buildMetricItem(entry.key, entry.value);
                }),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMetricItem(int index, MetricConfig config) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '指标类型 ${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                ),
              ),
              const Spacer(),
              Obx(() => controller.metricsConfig.length > 1
                  ? _buildDeleteButton(
                      label: '删除',
                      onPressed: () => controller.removeMetricConfig(index),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: '中文名称',
                  value: config.elementCname,
                  onChanged: (v) => config.elementCname = v,
                  hint: '如：温度',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: '英文名称',
                  value: config.elementEname,
                  onChanged: (v) => config.elementEname = v,
                  hint: '如：temp',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildTextField(
                label: '大类ID',
                value: config.sensorFieldId,
                onChanged: (v) => config.sensorFieldId = v,
                hint: '1',
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildTextField(
                label: '小类ID',
                value: config.sensorTypeId,
                onChanged: (v) => config.sensorTypeId = v,
                hint: '101',
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildTextField(
                label: '类型ID',
                value: config.sensorSubtypeId,
                onChanged: (v) => config.sensorSubtypeId = v,
                hint: '1010005',
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Obx(() => Row(
          children: [
            _buildPrimaryButton(
              label: '选择Excel文件',
              icon: Icons.upload_file,
              onPressed: () => controller.pickXlsxFile(),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: controller.xlsxFileName.value.isNotEmpty
                      ? Colors.green.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: controller.xlsxFileName.value.isNotEmpty
                        ? Colors.green.shade200
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      controller.xlsxFileName.value.isNotEmpty
                          ? Icons.check_circle
                          : Icons.insert_drive_file_outlined,
                      color: controller.xlsxFileName.value.isNotEmpty
                          ? Colors.green
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        controller.xlsxFileName.value.isEmpty
                            ? '未选择文件'
                            : controller.xlsxFileName.value,
                        style: TextStyle(
                          fontSize: 14,
                          color: controller.xlsxFileName.value.isNotEmpty
                              ? Colors.green.shade700
                              : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildGenerateSection() {
    return Obx(() => Row(
          children: [
            _buildPrimaryButton(
              label:
                  controller.isGenerating.value ? '生成中...' : '一键生成所有SQL',
              icon: controller.isGenerating.value
                  ? Icons.hourglass_empty
                  : Icons.auto_fix_high,
              isLoading: controller.isGenerating.value,
              onPressed:
                  controller.isGenerating.value ? null : () => controller.processFiles(),
            ),
            const SizedBox(width: 15),
            _buildSecondaryButton(
              label: '清空',
              icon: Icons.clear_all,
              onPressed: () => controller.clearAll(),
            ),
          ],
        ));
  }

  Widget _buildResultSection() {
    return Obx(() {
      final files = controller.generatedFiles;
      final counts = controller.fileCounts;
      return Wrap(
        spacing: 15,
        runSpacing: 15,
        children: files.entries.map((entry) {
          return _buildDownloadCard(entry.key, entry.value, counts[entry.key] ?? 0);
        }).toList(),
      );
    });
  }

  Widget _buildDownloadCard(String fileName, String content, int count) {
    final isJson = fileName.endsWith('.json');
    final isSql = fileName.endsWith('.sql');

    Color cardColor;
    if (isJson) {
      cardColor = Colors.amber.shade400;
    } else if (isSql) {
      cardColor = _accent;
    } else {
      cardColor = Colors.grey;
    }

    return Container(
      width: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            cardColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isJson ? Icons.data_object : Icons.description,
                    color: cardColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count 条记录',
                        style: TextStyle(
                          fontSize: 12,
                          color: cardColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    controller.downloadGeneratedFile(fileName, content),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('下载文件'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF555555),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _accent, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(icon, size: 20),
      label:
          Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 15)),
      style: OutlinedButton.styleFrom(
        foregroundColor: _accent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: _accent),
      ),
    );
  }

  Widget _buildAddButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDeleteButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.delete_outline, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Colors.red.shade400,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}

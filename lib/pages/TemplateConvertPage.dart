import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/TemplateConvertController.dart';

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

class TemplateConvertPage extends StatefulWidget {
  const TemplateConvertPage({super.key});

  @override
  State<TemplateConvertPage> createState() => _TemplateConvertPageState();
}

class _TemplateConvertPageState extends State<TemplateConvertPage> {
  final controller = Get.put(TemplateConvertController());

  // ── 主题色：橙色（与首页"传感器"图标 #F59E0B 一致）────
  static const _primary = Color(0xFFF59E0B);
  static const _primaryDark = Color(0xFFD97706);
  static const _gradLight = Color(0xFFFCD34D);
  static const _gradEnd = Color(0xFFB45309);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.statusMessage.value = '模板转换工具已就绪';
      controller.statusType.value = StatusType.info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1.0, -1.0),
            end: Alignment(1.0, 1.0),
            colors: [_gradLight, _primary, _gradEnd],
          ),
        ),
        child: Stack(
          children: [
            // 波点
            Positioned.fill(
              child: CustomPaint(painter: _DotPatternPainter()),
            ),
            // 内容
            CustomScrollView(
              slivers: [
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
                      '传感器模板转换工具',
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
                          colors: [_gradLight, _primary, _gradEnd],
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
                                '上传安基模板 Excel，自动转换为传感器设备和报警规则两个模板',
                                style: TextStyle(fontSize: 14, color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
                              title: '1. 基本信息',
                              icon: Icons.info_outline,
                              child: _buildConfigSection(),
                            ),
                            const SizedBox(height: 20),
                            _buildGlassCard(
                              title: '2. 上传模板',
                              icon: Icons.upload_file,
                              child: _buildUploadSection(),
                            ),
                            const SizedBox(height: 20),
                            _buildGlassCard(
                              title: '3. 执行转换',
                              icon: Icons.transform,
                              child: _buildActionSection(),
                            ),
                            const SizedBox(height: 20),
                            Obx(() => controller.hasResult.value
                                ? _buildGlassCard(
                                    title: '4. 下载结果',
                                    icon: Icons.download,
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

    Color bgColor, textColor;
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
      default:
        bgColor = Colors.blue.shade400;
        textColor = Colors.white;
        icon = Icons.info;
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
            child: Text(message, style: TextStyle(color: textColor, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required String title, required IconData icon, required Widget child}) {
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
              color: _primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: _primary, size: 22),
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
    return Obx(() => Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildTextField(
                  label: '采集仪目标编码*',
                  value: controller.collectorCode.value,
                  onChanged: (v) => controller.collectorCode.value = v,
                  hint: 'collector_code',
                )),
                const SizedBox(width: 15),
                Expanded(child: _buildTextField(
                  label: '所属项目id*',
                  value: controller.projectId.value,
                  onChanged: (v) => controller.projectId.value = v,
                  hint: 'project_id',
                )),
              ],
            ),
            const SizedBox(height: 15),
            _buildTextField(
              label: '企业统一社会信用代码*',
              value: controller.firmId.value,
              onChanged: (v) => controller.firmId.value = v,
              hint: '统一社会信用代码',
            ),
          ],
        ));
  }

  Widget _buildUploadSection() {
    return Obx(() => Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => controller.pickFile(),
              icon: const Icon(Icons.folder_open, size: 20),
              label: const Text('选择安基模板 Excel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildActionSection() {
    return Obx(() => Row(
          children: [
            ElevatedButton.icon(
              onPressed: controller.isProcessing.value
                  ? null
                  : () => controller.processFile(),
              icon: controller.isProcessing.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Icon(Icons.transform, size: 20),
              label: Text(
                controller.isProcessing.value ? '处理中...' : '一键转换',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
            const SizedBox(width: 15),
            OutlinedButton.icon(
              onPressed: () => controller.clearAll(),
              icon: const Icon(Icons.clear_all, size: 20),
              label: const Text('清空', style: TextStyle(fontSize: 15)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: _primary),
              ),
            ),
          ],
        ));
  }

  Widget _buildResultSection() {
    return Column(
      children: [
        _buildDownloadCard(
          icon: Icons.sensors,
          title: '传感器设备模板',
          sub: '${controller.sensorRowCount} 行',
          onTap: () => controller.downloadSensor(),
        ),
        const SizedBox(height: 15),
        _buildDownloadCard(
          icon: Icons.warning_amber,
          title: '报警规则模板',
          sub: '${controller.alarmRowCount} 行',
          onTap: () => controller.downloadAlarm(),
        ),
      ],
    );
  }

  Widget _buildDownloadCard({
    required IconData icon,
    required String title,
    required String sub,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            _primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: _primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sub,
                        style: TextStyle(fontSize: 13, color: _primary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.download_rounded, color: _primary, size: 28),
              ],
            ),
          ),
        ),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              borderSide: BorderSide(color: _primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

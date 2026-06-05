import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/DangerSourceController.dart';

// ══════════════════════════════════════════════════════
// 波点阵列绘制器
// ══════════════════════════════════════════════════════
class _DotPainter extends CustomPainter {
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

// ══════════════════════════════════════════════════════
// 页面
// ══════════════════════════════════════════════════════
class DangerSourcePage extends StatefulWidget {
  const DangerSourcePage({super.key});

  @override
  State<DangerSourcePage> createState() => _DangerSourcePageState();
}

class _DangerSourcePageState extends State<DangerSourcePage> {
  final controller = Get.put(DangerSourceController());

  // 红橙色主题
  static const _primary = Color(0xFFEF4444);
  static const _primaryDark = Color(0xFFDC2626);
  static const _gradLight = Color(0xFFFCA5A5);
  static const _gradEnd = Color(0xFF991B1B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.statusMessage.value = '重大危险源模板校验修复工具已就绪';
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
            Positioned.fill(
              child: CustomPaint(painter: _DotPainter()),
            ),
            CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Obx(() => Column(
                              children: [
                                _buildStatusBanner(),
                                const SizedBox(height: 20),
                                _buildGlassCard(
                                  title: '1. 选择文件',
                                  icon: Icons.folder_open,
                                  child: _buildUploadSection(),
                                ),
                                const SizedBox(height: 20),
                                _buildGlassCard(
                                  title: '2. 执行校验',
                                  icon: Icons.search,
                                  child: _buildCheckSection(),
                                ),
                                const SizedBox(height: 20),
                                Obx(() => controller.currentStep.value >= 2
                                    ? _buildGlassCard(
                                        title: '3. 下载校验结果',
                                        icon: Icons.download,
                                        child: _buildCheckDownloadSection(),
                                      )
                                    : const SizedBox.shrink()),
                                if (controller.currentStep.value >= 2)
                                  const SizedBox(height: 20),
                                _buildGlassCard(
                                  title: '4. 执行修复',
                                  icon: Icons.build,
                                  child: _buildFixSection(),
                                ),
                                const SizedBox(height: 20),
                                Obx(() => controller.currentStep.value >= 3
                                    ? _buildGlassCard(
                                        title: '5. 下载修复结果',
                                        icon: Icons.download_done,
                                        child: _buildFixDownloadSection(),
                                      )
                                    : const SizedBox.shrink()),
                                const SizedBox(height: 40),
                              ],
                            )),
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

  // ── AppBar ──
  Widget _buildAppBar() {
    return SliverAppBar(
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
          '重大危险源模板校验修复',
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
                    '上传重大危险源 Excel，自动校验并修复不合规数据',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── 状态横幅 ──
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
            child: Text(
              message,
              style: TextStyle(color: textColor, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── 玻璃态卡片 ──
  Widget _buildGlassCard(
      {required String title, required IconData icon, required Widget child}) {
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
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

  // ── 1. 选择文件 ──
  Widget _buildUploadSection() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => controller.pickFile(),
          icon: const Icon(Icons.folder_open, size: 20),
          label: const Text('选择 Excel 文件',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }

  // ── 2. 执行校验 ──
  Widget _buildCheckSection() {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: controller.isProcessing.value
                  ? null
                  : () => controller.runCheck(),
              icon: controller.isProcessing.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.search, size: 20),
              label: Text(
                controller.isProcessing.value ? '校验中...' : '执行校验',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: _primary),
              ),
            ),
          ],
        ),
        // 校验结果摘要
        if (controller.checkResult.value != null) ...[
          const SizedBox(height: 16),
          _buildResultSummary(
            icon: Icons.error_outline,
            color: controller.checkResult.value!.errorCount > 0
                ? Colors.orange
                : Colors.green,
            text: controller.checkResult.value!.errorCount > 0
                ? '不合规单元格已标黄，详见上方分类（含是否可自动修复）'
                : '✅ 未发现不合规数据',
          ),
          if (controller.checkResult.value!.errorCount > 0) ...[
            const SizedBox(height: 10),
            _buildCheckCategoryChips(controller.checkResult.value!),
          ],
        ],
      ],
    );
  }

  // ── 3. 下载校验结果 ──
  Widget _buildCheckDownloadSection() {
    return Column(
      children: [
        _buildDownloadCard(
          icon: Icons.table_chart,
          title: '校验结果 Excel',
          sub: '不合规单元格标黄',
          onTap: () => controller.downloadCheckExcel(),
        ),
        const SizedBox(height: 15),
        _buildDownloadCard(
          icon: Icons.description,
          title: '校验日志',
          sub: '${controller.checkResult.value?.errorCount ?? 0} 条问题明细',
          onTap: () => controller.downloadCheckLog(),
        ),
        const SizedBox(height: 15),
        _buildLogPreviewButton(
          title: '预览校验日志',
          logContent: controller.getCheckLogPreview(),
        ),
      ],
    );
  }

  // ── 4. 执行修复 ──
  Widget _buildFixSection() {
    final checkDone = controller.currentStep.value >= 2;
    final hasManualFixes = checkDone &&
        controller.checkResult.value != null &&
        controller.checkResult.value!.manualFixCount > 0;
    final canFix =
        checkDone && !hasManualFixes && !controller.isProcessing.value;

    return Column(
      children: [
        if (controller.currentStep.value < 2)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '请先执行校验',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        if (hasManualFixes)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildResultSummary(
              icon: Icons.block,
              color: Colors.red,
              text:
                  '存在 ${controller.checkResult.value!.manualFixCount} 项需人工处理，请先下载校验结果修复后重新上传',
            ),
          ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: canFix ? () => controller.runFix() : null,
              icon: controller.isProcessing.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.build, size: 20),
              label: Text(
                controller.isProcessing.value
                    ? '修复中...'
                    : hasManualFixes
                        ? '请先人工修复'
                        : '执行修复',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: canFix ? _primary : Colors.grey.shade300,
                foregroundColor: canFix ? Colors.white : Colors.grey.shade600,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: canFix ? 0 : 0,
                shadowColor: canFix ? null : Colors.transparent,
              ),
            ),
          ],
        ),
        // 修复结果摘要
        if (controller.fixResult.value != null) ...[
          const SizedBox(height: 16),
          _buildResultSummary(
            icon: Icons.check_circle,
            color: Colors.green,
            text: '自动修复 ${controller.fixResult.value!.fixCount} 项（绿色标注）',
          ),
          const SizedBox(height: 8),
          _buildResultSummary(
            icon: Icons.warning,
            color: Colors.red,
            text: '需人工处理 ${controller.fixResult.value!.warnCount} 项（红色标注）',
          ),
        ],
      ],
    );
  }

  // ── 5. 下载修复结果 ──
  Widget _buildFixDownloadSection() {
    return Column(
      children: [
        _buildDownloadCard(
          icon: Icons.table_chart,
          title: '修复结果 Excel',
          sub: '绿色=已修复 / 红色=需人工',
          onTap: () => controller.downloadFixExcel(),
        ),
        const SizedBox(height: 15),
        _buildDownloadCard(
          icon: Icons.description,
          title: '修复日志',
          sub:
              '修复 ${controller.fixResult.value?.fixCount ?? 0} 项 + 需人工 ${controller.fixResult.value?.warnCount ?? 0} 项',
          onTap: () => controller.downloadFixLog(),
        ),
        const SizedBox(height: 15),
        _buildLogPreviewButton(
          title: '预览修复日志',
          logContent: controller.getFixLogPreview(),
        ),
      ],
    );
  }

  // ── 通用组件 ──
  Widget _buildCheckCategoryChips(CheckResult result) {
    final items = <_ChipData>[];
    if (result.missingCount > 0) {
      items.add(_ChipData('缺失数据', result.missingCount, Colors.red));
    }
    if (result.formatCount > 0) {
      items.add(_ChipData('格式错误', result.formatCount, Colors.orange));
    }
    if (result.mismatchCount > 0) {
      items.add(_ChipData('数据不匹配', result.mismatchCount, Colors.purple));
    }
    if (result.duplicateCount > 0) {
      items.add(_ChipData('数据重复', result.duplicateCount, Colors.blue));
    }
    if (result.manualFixCount > 0) {
      items.add(_ChipData('❌ 需人工处理', result.manualFixCount, Colors.red));
    }
    if (result.fixableCount > 0) {
      items.add(_ChipData('⚠️ 可自动修复', result.fixableCount, Colors.orange));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: items.map((d) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: d.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: d.color.withOpacity(0.4)),
          ),
          child: Text(
            '${d.label} ${d.count} 项',
            style: TextStyle(
              fontSize: 12,
              color: d.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultSummary({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: color.withOpacity(0.8)),
            ),
          ),
        ],
      ),
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

  // ── 日志预览按钮 ──
  Widget _buildLogPreviewButton({
    required String title,
    required String? logContent,
  }) {
    return ElevatedButton.icon(
      onPressed: logContent != null
          ? () => _showLogPreviewDialog(context, title, logContent)
          : null,
      icon: const Icon(Icons.preview, size: 18),
      label: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  // ── 日志预览对话框 ──
  void _showLogPreviewDialog(
      BuildContext context, String title, String content) {
    final textSpans = <TextSpan>[];
    final lines = content.split('\n');

    for (final line in lines) {
      Color? color;
      if (line.contains('❌')) {
        color = Colors.red;
      } else if (line.contains('⚠️')) {
        color = Colors.orange;
      }

      textSpans.add(TextSpan(
        text: line + '\n',
        style: TextStyle(
          fontFamily: 'Monaco',
          fontSize: 13,
          color: color ?? Colors.black87,
        ),
      ));
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 800,
            height: 500,
            child: SingleChildScrollView(
              child: RichText(
                text: TextSpan(children: textSpans),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }
}

class _ChipData {
  final String label;
  final int count;
  final Color color;
  _ChipData(this.label, this.count, this.color);
}

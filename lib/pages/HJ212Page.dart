// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables,
    // unused_import, unnecessary_import, sized_box_for_whitespace,
    // avoid_unnecessary_containers, non_constant_identifier_names, file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jx_flutter/controller/HJ212Controller.dart';

class HJ212Page extends GetView<HJ212Controller> {
  const HJ212Page({super.key});

  // ── 主题色（与首页HJ212卡片图标一致 #10B981）───────────────
  static const _primary = Color(0xFF10B981);
  static const _primaryDark = Color(0xFF059669);
  static const _gradLight = Color(0xFF6EE7B7); // 椤堕儴鏌斿拰娴呰壊
  static const _gradEnd   = Color(0xFF059669);   // 搴曢儴涓繁杩囨浮
  static const _bg = Color(0xFFF0F4F8);
  static const _cardBg = Colors.white;
  static const _hintGrey = Color(0xFF9CA3AF);
  static const _borderGrey = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 渐变背景
          _buildGradientBackground(),
          // 内容
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final horizontalPad = isWide ? (constraints.maxWidth - 600) / 2 : 16.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPad,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── 顶部标题 ──────────────────────────────────
                      _buildHeader(),
                      const SizedBox(height: 16),

                      // ── 统计信息卡 ──────────────────────────────────
                      _buildStatCard(),
                      const SizedBox(height: 16),

                      // ── 表单输入卡 ──────────────────────────────────
                      _buildFormCard(isWide),
                      const SizedBox(height: 16),

                      // ── 类型选择卡 ──────────────────────────────────
                      _buildTypeCard(),
                      const SizedBox(height: 16),

                      // ── 预览卡 ─────────────────────────────────────
                      Obx(() => controller.previewLines.isNotEmpty
                          ? _buildPreviewCard()
                          : const SizedBox.shrink()),
                      Obx(() => controller.previewLines.isNotEmpty
                          ? const SizedBox(height: 16)
                          : const SizedBox.shrink()),

                      // ── 操作按钮 ───────────────────────────────────
                      _buildActionButtons(),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── 渐变背景 ────────────────────────────────────────────────
  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1.0, -1.0),
          end: Alignment(1.0, 1.0),
          colors: [
            _primary,
            _primaryDark,
            Color(0xFF6B8DD6),
          ],
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
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 顶部标题 ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        // 返回按钮
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(12),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.eco_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HJ212 造数据',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'TSDB 格式测试数据生成',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 统计信息卡 ─────────────────────────────────────────────
  Widget _buildStatCard() {
    return Obx(() {
      final lines = controller.lineCount;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primary, _primaryDark],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '将生成数据条数',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$lines 条',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${controller.mpType.value} · ${controller.day.value}天',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── 表单输入卡 ─────────────────────────────────────────────
  Widget _buildFormCard(bool isWide) {
    final gap = isWide ? 16.0 : 12.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: '基础参数', icon: Icons.settings),
          SizedBox(height: isWide ? 16 : 12),
          // 第一行：metric + mn
          if (isWide)
            Row(
              children: [
                Expanded(child: _FieldInput(label: 'metric', hint: '监测因子', onChanged: (v) => controller.metric.value = v)),
                const SizedBox(width: 16),
                Expanded(child: _FieldInput(label: 'mn', hint: '设备编码', onChanged: (v) => controller.mn.value = v)),
              ],
            )
          else
            Column(children: [
              _FieldInput(label: 'metric', hint: '监测因子', onChanged: (v) => controller.metric.value = v),
              SizedBox(height: gap),
              _FieldInput(label: 'mn', hint: '设备编码', onChanged: (v) => controller.mn.value = v),
            ]),
          SizedBox(height: gap),
          // 第二行：ec + mp
          if (isWide)
            Row(
              children: [
                Expanded(child: _FieldInput(label: 'ec', hint: '污染物种类', onChanged: (v) => controller.ec.value = v)),
                const SizedBox(width: 16),
                Expanded(child: _FieldInput(label: 'mp', hint: '监测点编码', onChanged: (v) => controller.mp.value = v)),
              ],
            )
          else
            Column(children: [
              _FieldInput(label: 'ec', hint: '污染物种类', onChanged: (v) => controller.ec.value = v),
              SizedBox(height: gap),
              _FieldInput(label: 'mp', hint: '监测点编码', onChanged: (v) => controller.mp.value = v),
            ]),
          SizedBox(height: gap),
          // 第三行：md + day
          if (isWide)
            Row(
              children: [
                Expanded(child: _FieldInput(label: 'md', hint: '监测方式', onChanged: (v) => controller.md.value = v)),
                const SizedBox(width: 16),
                Expanded(child: _FieldInput(label: 'day', hint: '天数(1-365)', onChanged: (v) => controller.day.value = v)),
              ],
            )
          else
            Column(children: [
              _FieldInput(label: 'md', hint: '监测方式', onChanged: (v) => controller.md.value = v),
              SizedBox(height: gap),
              _FieldInput(label: 'day', hint: '天数(1-365)', onChanged: (v) => controller.day.value = v),
            ]),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          const _SectionTitle(title: '数值范围', icon: Icons.numbers),
          SizedBox(height: isWide ? 16 : 12),
          // 第四行：valueMin + valueMax
          if (isWide)
            Row(
              children: [
                Expanded(child: _FieldInput(label: 'valueMin', hint: '最小值', onChanged: (v) => controller.valueMin.value = v)),
                const SizedBox(width: 16),
                Expanded(child: _FieldInput(label: 'valueMax', hint: '最大值', onChanged: (v) => controller.valueMax.value = v)),
              ],
            )
          else
            Column(children: [
              _FieldInput(label: 'valueMin', hint: '最小值', onChanged: (v) => controller.valueMin.value = v),
              SizedBox(height: gap),
              _FieldInput(label: 'valueMax', hint: '最大值', onChanged: (v) => controller.valueMax.value = v),
            ]),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          const _SectionTitle(title: '时间配置', icon: Icons.schedule),
          SizedBox(height: isWide ? 16 : 12),
          _FieldInput(
            label: 'timeStart',
            hint: 'YYYY-MM-DD HH:mm:ss',
            onChanged: (v) => controller.timeStart.value = v,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          const _SectionTitle(title: '文件配置', icon: Icons.save_alt),
          SizedBox(height: isWide ? 16 : 12),
          _FieldInput(label: 'fileName', hint: '文件名（不含扩展名）', onChanged: (v) => controller.fileName.value = v),
        ],
      ),
    );
  }

  // ── 类型选择卡 ─────────────────────────────────────────────
  Widget _buildTypeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: '数据类型', icon: Icons.category),
          const SizedBox(height: 16),
          // mp_type 分段选择
          Obx(() => _SegmentedSelector(
            options: const {'Rtd': '实时数据', 'Avg': '统计数据'},
            value: controller.mpType.value,
            onChanged: (v) => controller.mpType.value = v,
          )),
          // type（仅 Avg 时显示）
          Obx(() => AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _SegmentedSelector(
                options: const {'hour': '小时统计', 'day': '日统计'},
                value: controller.type.value,
                onChanged: (v) => controller.type.value = v,
              ),
            ),
            crossFadeState: controller.mpType.value == 'Avg'
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          )),
        ],
      ),
    );
  }

  // ── 预览卡 ─────────────────────────────────────────────────
  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.preview, color: _primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                '数据预览（前 10 条）',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              Obx(() => Text(
                '${controller.previewLines.length} 条',
                style: const TextStyle(color: _hintGrey, fontSize: 13),
              )),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderGrey),
            ),
            child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: controller.previewLines
                  .asMap()
                  .entries
                  .map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              child: Text(
                                '${e.key + 1}',
                                style: const TextStyle(
                                  color: _hintGrey,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                e.value.trim(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            )),
          ),
        ],
      ),
    );
  }

  // ── 操作按钮 ──────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Obx(() {
      final isLoading = controller.isGenerating.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 主按钮：生成并下载
          SizedBox(
            height: 54,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, _primaryDark],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : controller.product,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _primary.withOpacity(0.4),
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '生成并下载 TSDB 文件',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 次按钮：仅预览
          SizedBox(
            height: 48,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _primary, width: 1.5),
              ),
              child: OutlinedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final ok = await controller.generate();
                        if (ok) {
                          ScaffoldMessenger.of(Get.context!).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  const Text('已生成数据，可在下方预览'),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              backgroundColor: const Color(0xFF10B981),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  shadowColor: Colors.transparent,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.preview, size: 18),
                    SizedBox(width: 6),
                    Text('仅预览数据', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
// 通用组件
// ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  static const _primary = Color(0xFF667EEA);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _primary, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _FieldInput extends StatelessWidget {
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  const _FieldInput({
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  static const _labelColor = Color(0xFF059669);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _bgColor = Color(0xFFF9FAFB);
  static const _primary = Color(0xFF667EEA);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: _labelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            filled: true,
            fillColor: _bgColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _primary, width: 1.5),
            ),
          ),
          style: const TextStyle(fontSize: 14),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SegmentedSelector extends StatelessWidget {
  final Map<String, String> options; // value -> label
  final String value;
  final ValueChanged<String> onChanged;

  const _SegmentedSelector({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  static const _primary = Color(0xFF667EEA);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: options.entries.map((e) {
          final isSelected = e.key == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  e.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? _primary
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
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

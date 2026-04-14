import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jx_flutter/controller/MqttLogController.dart';

class MqttLogPage extends GetView<MqttLogController> {
  const MqttLogPage({super.key});

  // ── 主题色（紫色调 #7C3AED）───────────────────────────────
  static const _primary     = Color(0xFF7C3AED);
  static const _primaryDark = Color(0xFF4C1D95);
  static const _gradLight   = Color(0xFFC4B5FD);
  static const _gradEnd     = Color(0xFF5B21B6);
  static const _headerClr   = Color(0xFFF5F3FF);
  static const _successClr  = Color(0xFFF0FDF4);
  static const _warnClr     = Color(0xFFFFFBEB);
  static const _errorClr    = Color(0xFFFEF2F2);
  static const _muted       = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Obx(() {
                    if (controller.values.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildResultState();
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 渐变背景 ──────────────────────────────────────────────
  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1.0, -1.0),
          end: Alignment(1.0, 1.0),
          colors: [_gradLight, _primary, _gradEnd],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: 40, left: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          CustomPaint(size: Size.infinite, painter: _DotPatternPainter()),
        ],
      ),
    );
  }

  // ── 顶部栏 ────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: Colors.white,
            onPressed: () {
              controller.clear();
              Get.back();
            },
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: const Icon(Icons.article_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MQTT 日志解析',
                  style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold,
                    color: Colors.white, letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'JSON values 计数 · code 精准查询',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 空状态 ────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogInputCard(showHint: true),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.2),
                  blurRadius: 30, offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(Icons.article_outlined, color: _primary, size: 56),
          ),
          const SizedBox(height: 24),
          const Text(
            '粘贴 JSON 日志后开始解析',
            style: TextStyle(
              color: Color(0xFF374151), fontSize: 16, fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '支持 { ts, values[] } 格式的 MQTT 日志',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── 解析后状态 ────────────────────────────────────────────
  Widget _buildResultState() {
    return Column(
      children: [
        _buildLogInputCard(showHint: false),
        const SizedBox(height: 8),
        _buildStatsCard(),
        const SizedBox(height: 8),
        _buildQueryCard(),
        const SizedBox(height: 8),
        Expanded(child: _buildMatchedList()),
      ],
    );
  }

  // ── JSON 日志输入卡 ───────────────────────────────────────
  Widget _buildLogInputCard({required bool showHint}) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(Icons.input, size: 16, color: _primary),
                const SizedBox(width: 6),
                const Text(
                  'JSON 日志',
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const Spacer(),
                if (!showHint)
                  GestureDetector(
                    onTap: controller.clear,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '清空', style: TextStyle(fontSize: 12, color: Color(0xFFDC2626)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: TextField(
              decoration: InputDecoration(
                hintText: showHint ? '粘贴 MQTT JSON 日志...' : null,
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                filled: !showHint,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _primary.withOpacity(0.5)),
                ),
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              maxLines: showHint ? 5 : 3,
              onChanged: controller.parseLog,
            ),
          ),
        ],
      ),
    );
  }

  // ── 统计卡 ────────────────────────────────────────────────
  Widget _buildStatsCard() {
    return Obx(() {
      final outerTsVal = controller.outerTs.value;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primary.withOpacity(0.1), _primaryDark.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            _StatBadge(
              label: 'values 条数',
              value: '${controller.values.length}',
              color: _primary,
            ),
            Container(
              width: 1, height: 32,
              color: _primary.withOpacity(0.15),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outerTsVal != null ? '外层 ts: ${controller.formatTs(outerTsVal)}' : '—',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (controller.values.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '时间范围: ${controller.formatTs(controller.values.last['timestamp'] as int)}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── 查询卡 ────────────────────────────────────────────────
  Widget _buildQueryCard() {
    final textController = TextEditingController();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20, color: _primary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: '输入 code 精准查询（如 AI_95T）',
                hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              onChanged: controller.search,
            ),
          ),
          Obx(() {
            if (controller.queryCode.value.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${controller.matched.length} 条',
                  style: TextStyle(fontSize: 12, color: _primary, fontWeight: FontWeight.w600),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  // ── 匹配结果列表 ──────────────────────────────────────────
  Widget _buildMatchedList() {
    return Obx(() {
      if (controller.queryCode.value.isEmpty) {
        return _buildAllValuesList();
      }
      if (controller.matched.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                '未找到 code="${controller.queryCode.value}" 的记录',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
            ],
          ),
        );
      }
      return _buildValueListView(controller.matched, highlight: controller.queryCode.value);
    });
  }

  Widget _buildAllValuesList() {
    return _buildValueListView(controller.values, highlight: null);
  }

  Widget _buildValueListView(List<Map<String, dynamic>> items, {String? highlight}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildValueRow(context, items[index], index, items.length, highlight),
        ),
      ),
    );
  }

  Widget _buildValueRow(BuildContext context, Map<String, dynamic> item, int index, int total, String? highlight) {
    final code = (item['code'] as String?) ?? '—';
    final ts = (item['timestamp'] as int?) ?? 0;
    final value = (item['value'] as num?)?.toString() ?? '—';
    final status = (item['status'] as int?) ?? 0;
    final type = (item['type'] as String?) ?? '—';
    final sn = (item['sn'] as String?) ?? '—';

    final isFirst = index == 0;
    final isLast  = index == total - 1;

    // status 颜色
    Color statusColor;
    String statusLabel;
    if (status == 1) {
      statusColor = const Color(0xFF10B981); statusLabel = '在线';
    } else {
      statusColor = const Color(0xFFF59E0B); statusLabel = '离线';
    }

    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: '''
code: $code
sn: $sn
timestamp: $ts (${controller.formatTs(ts)})
status: $status ($statusLabel)
value: $value
type: $type
'''));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('已复制')],
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            backgroundColor: const Color(0xFF10B981),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, bottom: isLast ? 0 : 1, top: isFirst ? 0 : 0),
        decoration: BoxDecoration(
          color: index % 2 == 0 ? _muted.withOpacity(0.4) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isFirst ? 10 : 4),
            topRight: Radius.circular(isFirst ? 10 : 4),
            bottomLeft: Radius.circular(isLast ? 10 : 4),
            bottomRight: Radius.circular(isLast ? 10 : 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 第一行：序号 + code + status badge
              Row(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(fontSize: 11, color: _primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HighlightText(
                      text: code,
                      highlight: highlight,
                      style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 13,
                        fontWeight: FontWeight.w700, color: Color(0xFF1F2937),
                      ),
                      highlightStyle: TextStyle(
                        fontFamily: 'monospace', fontSize: 13,
                        fontWeight: FontWeight.w700, color: _primary,
                        backgroundColor: const Color(0xFFEDE9FE),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // 第二行：value + type
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 18,
                      fontWeight: FontWeight.bold, color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 第三行：timestamp + sn
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      controller.formatTs(ts),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontFamily: 'monospace'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.device_unknown, size: 12, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    sn,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 高亮文本组件 ───────────────────────────────────────────
class _HighlightText extends StatelessWidget {
  final String text;
  final String? highlight;
  final TextStyle style;
  final TextStyle highlightStyle;

  const _HighlightText({
    required this.text, this.highlight,
    required this.style, required this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (highlight == null || highlight!.isEmpty) {
      return Text(text, style: style);
    }
    final idx = text.toLowerCase().indexOf(highlight!.toLowerCase());
    if (idx < 0) return Text(text, style: style);
    return RichText(
      text: TextSpan(
        children: [
          if (idx > 0) TextSpan(text: text.substring(0, idx), style: style),
          TextSpan(text: text.substring(idx, idx + highlight!.length), style: highlightStyle),
          if (idx + highlight!.length < text.length)
            TextSpan(text: text.substring(idx + highlight!.length), style: style),
        ],
      ),
    );
  }
}

// ── 统计徽章 ───────────────────────────────────────────────
class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

// ── 波点阵列 ───────────────────────────────────────────────
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

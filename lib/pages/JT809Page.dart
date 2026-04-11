import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jx_flutter/controller/JT809Controller.dart';

class JT809Page extends GetView<JT809Controller> {
  const JT809Page({super.key});

  // ── 主题色（与首页JT809卡片图标一致 #3B82F6）───────────────
  static const _primary     = Color(0xFF3B82F6);
  static const _primaryDark = Color(0xFF1D4ED8);
  // 渐变色：浅(顶部柔和) → 深 → 中(底部过渡)
  static const _gradLight = Color(0xFF93C5FD); // L=80% 浅蓝
  static const _gradEnd   = Color(0xFF2563EB); // L=45% 中蓝
  static const _headerClr  = Color(0xFFEEF2FF);
  static const _bodyClr    = Color(0xFFF0FDF4);
  static const _footerClr  = Color(0xFFF8FAFC);
  static const _errorClr   = Color(0xFFFEF2F2);
  static const _subTitleClr = Color(0xFFE0E7FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 渐变背景
          _buildGradientBackground(),
          // 内容
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Obx(() {
                    if (controller.errorMessage.value.isNotEmpty) {
                      return _buildErrorState(controller.errorMessage.value);
                    }
                    if (!controller.hasResult.value) {
                      return _buildEmptyState();
                    }
                    return _buildResultList();
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 渐变背景（浅→深→中，柔和过渡）+ 波点装饰 ───────────
  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1.0, -1.0),
          end: Alignment(1.0, 1.0),
          colors: [
            _gradLight,  // 顶部：柔和浅色
            _primary,    // 中部：主色
            _gradEnd,    // 底部：中深色过渡
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 装饰圆（半透明白色浮球）
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: 80,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // 波点阵列（与首页风格一致）
          CustomPaint(
            size: Size.infinite,
            painter: _DotPatternPainter(),
          ),
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
              controller.clean();
              Get.back();
            },
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.directions_bus_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JT809 协议解析',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '支持 1001 / 1002 / 1200 三种消息类型',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 输入区域 ──────────────────────────────────────────────
  Widget _buildInputArea() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: '输入 JT809 报文（16进制，可带空格）',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close, size: 18, color: Color(0xFF9CA3AF)),
            onPressed: controller.clean,
          ),
        ),
        style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
        onSubmitted: controller.parse,
      ),
    );
  }

  // ── 空状态 ────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildInputArea(),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.terminal_rounded,
              color: _primary,
              size: 56,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '输入报文后按回车解析',
            style: TextStyle(
              color: Color.fromARGB(255, 49, 54, 61),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '支持 1001 / 1002 / 1200 三种消息类型',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ── 错误状态 ──────────────────────────────────────────────
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildInputArea(),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _errorClr,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '解析失败',
                        style: TextStyle(
                          color: Color(0xFF991B1B),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 解析结果列表 ──────────────────────────────────────────
  Widget _buildResultList() {
    return Column(
      children: [
        _buildInputArea(),
        Expanded(
          child: Obx(() {
            final rows = controller.resultRows;
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: rows.length,
                  itemBuilder: (context, index) => _buildRow(context, rows[index], index),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── 单行渲染 ──────────────────────────────────────────────
  Widget _buildRow(BuildContext context, JT809ResultRow row, int index) {
    // 子标题行（分隔）
    if (row.type == JT809RowType.subTitle) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primary.withOpacity(0.1), _primaryDark.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.segment, color: _primary, size: 16),
            const SizedBox(width: 8),
            Text(
              row.label,
              style: const TextStyle(
                color: _primaryDark,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    // 颜色配置
    final colors = _rowColors(row.type);
    final bgColor  = colors[0] as Color;
    final dotColor = colors[1] as Color;
    final labelColor = colors[2] as Color;

    final bool isFirst = index == 0 || controller.resultRows[index - 1].type == JT809RowType.subTitle;
    final bool isLast  = index == controller.resultRows.length - 1 ||
        controller.resultRows[index + 1].type == JT809RowType.subTitle;

    return GestureDetector(
      onLongPress: () {
        final text = '${row.label}: ${row.hex}${row.parsed.isNotEmpty ? " (${row.parsed})" : ""}';
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text('已复制到剪贴板'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            backgroundColor: const Color(0xFF10B981),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: isLast ? 0 : 1,
          top: isFirst ? 0 : 0,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isFirst ? 12 : 4),
            topRight: Radius.circular(isFirst ? 12 : 4),
            bottomLeft: Radius.circular(isLast ? 12 : 4),
            bottomRight: Radius.circular(isLast ? 12 : 4),
          ),
          border: index % 2 == 1
              ? Border.all(color: Colors.white.withOpacity(0.6), width: 0.5)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 颜色点
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withOpacity(0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 字段名
              SizedBox(
                width: 110,
                child: Text(
                  row.label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // HEX + 解析值
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (row.hex.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          row.hex,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: Color(0xFF374151),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (row.parsed.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            size: 12,
                            color: labelColor.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              row.parsed,
                              style: TextStyle(
                                fontSize: 13,
                                color: labelColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 行颜色映射 ────────────────────────────────────────────
  List<dynamic> _rowColors(JT809RowType type) {
    switch (type) {
      case JT809RowType.header:
        return [_headerClr, const Color(0xFF667EEA), const Color(0xFF4338CA)];
      case JT809RowType.body:
        return [_bodyClr, const Color(0xFF10B981), const Color(0xFF065F46)];
      case JT809RowType.footer:
        return [_footerClr, const Color(0xFF64748B), const Color(0xFF475569)];
      case JT809RowType.error:
        return [_errorClr, const Color(0xFFEF4444), const Color(0xFF991B1B)];
      case JT809RowType.subTitle:
        return [_subTitleClr, _primary, _primaryDark];
    }
  }
}

// ─────────────────────────────────────────────
// 波点阵列绘制器（与首页风格一致）
// ─────────────────────────────────────────────
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

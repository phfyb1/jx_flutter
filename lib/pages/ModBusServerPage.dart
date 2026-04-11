import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/ModBusServerController.dart';
import '../util/ControllerUtils.dart' as utils;

var height;
var width;

final textController = TextEditingController();

class ModBusServerPage extends GetView<ModBusServerControler> {
  const ModBusServerPage({super.key});

  static const _primary = Color(0xFF667EEA);
  static const _primaryDark = Color(0xFF764BA2);
  static const _gradLight = Color(0xFFFCD34D); // 椤堕儴鏌斿拰娴呰壊
  static const _gradEnd   = Color(0xFFD97706);   // 搴曢儴涓繁杩囨浮
  static const _bg = Color(0xFFF0F4F8);

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // 渐变背景 + 装饰圆
          _buildGradientBackground(),
          // 内容
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final hPad = isWide ? (constraints.maxWidth - 600) / 2 : 16.0;
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildStatCard(),
                      const SizedBox(height: 16),
                      _buildInputCard(),
                      const SizedBox(height: 16),
                      Obx(() => controller.dataResultList.isNotEmpty
                          ? _buildResultCard()
                          : _buildEmptyState()),
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

  // ── 渐变背景 + 装饰 ────────────────────────────────
  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1.0, -1.0),
          end: Alignment(1.0, 1.0),
          colors: [_primary, _primaryDark, const Color(0xFF6B8DD6)],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 波点阵列
          Positioned.fill(
            child: CustomPaint(painter: _DotPatternPainter()),
          ),
          Positioned(
            top: -100, right: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -60, left: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            top: 120, right: 60,
            child: Container(
              width: 60, height: 60,
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

  // ── 顶部标题 ──────────────────────────────────────
  Widget _buildHeader() {
    return Row(
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
          child: const Icon(Icons.memory_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ModBusServer 解析',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                '服务器响应报文 · 4 种字节序',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 统计卡 ────────────────────────────────────────
  Widget _buildStatCard() {
    return Obx(() {
      final count = controller.dataResultList.length;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_primary, _primaryDark]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('解析结果条数', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    '$count 条',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('4 字节序', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── 输入卡片 ──────────────────────────────────────
  Widget _buildInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.input_rounded, color: _primary, size: 16),
                ),
                const SizedBox(width: 10),
                const Text(
                  '输入服务器响应报文',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
          // 输入区
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _AnimatedTextField(
                    controller: textController,
                    hint: '输入 16 进制报文',
                    onSubmitted: (v) {
                      controller.clean();
                      controller.data.value = controller.main(v);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                _GradientButton(
                  label: '解析',
                  icon: Icons.play_arrow_rounded,
                  onTap: () {
                    controller.clean();
                    controller.data.value = controller.main(textController.text);
                  },
                ),
              ],
            ),
          ),
          // 提示
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Color(0xFFB45309)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '若有显示问题，请按 F12 查看控制台输出',
                      style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 结果卡片 ─────────────────────────────────────
  Widget _buildResultCard() {
    return Obx(() {
      final results = controller.dataResultList;
      final jxData = controller.JXData;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '解析结果',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${results.length} 条',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),
            ),
            // 结果列表
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _ResultItem(
                  index: index,
                  hexStr: results[index].toString(),
                  jxData: jxData,
                );
              },
            ),
          ],
        ),
      );
    });
  }

  // ── 空状态 ────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.12),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.memory_rounded,
                color: _primary.withOpacity(0.5),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '输入报文后点击「解析」',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '支持 DCBA / BADC / ABCD / CDAB 字节序',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 组件
// ─────────────────────────────────────────────────────────────

class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onSubmitted;

  const _AnimatedTextField({
    required this.controller,
    required this.hint,
    required this.onSubmitted,
  });

  @override
  State<_AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<_AnimatedTextField> {
  bool _focused = false;
  static const _primary = Color(0xFF667EEA);

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: _primary.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: widget.controller,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14, letterSpacing: 0.8),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primary, width: 1.5),
            ),
          ),
          onSubmitted: widget.onSubmitted,
        ),
      ),
    );
  }
}

class _GradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({required this.label, required this.icon, required this.onTap});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _hovered = false;
  static const _primary = Color(0xFF667EEA);
  static const _primaryDark = Color(0xFF764BA2);
  static const _gradLight = Color(0xFFFCD34D); // 椤堕儴鏌斿拰娴呰壊
  static const _gradEnd   = Color(0xFFD97706);   // 搴曢儴涓繁杩囨浮

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_hovered ? 1.05 : 1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_primary, _primaryDark]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(_hovered ? 0.4 : 0.3),
              blurRadius: _hovered ? 12 : 8,
              offset: Offset(0, _hovered ? 4 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    widget.label,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final int index;
  final String hexStr;
  final RxList<dynamic> jxData;

  const _ResultItem({required this.index, required this.hexStr, required this.jxData});

  static const _primary = Color(0xFF667EEA);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // 十六进制值
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('原始值', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                      const SizedBox(height: 2),
                      Text(
                        hexStr,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  final jx = jxData.length > index ? jxData[index] : null;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: jx != null ? const Color(0xFF10B981).withOpacity(0.1) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      jx != null ? jx.toString() : '-',
                      style: TextStyle(
                        fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.bold,
                        color: jx != null ? const Color(0xFF10B981) : Colors.grey,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),
          // 字节序选择
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('选择字节序', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    _ByteOrderChip(label: '大端 DCBA', value: 1, index: index, hexStr: hexStr),
                    _ByteOrderChip(label: '大端反转 BADC', value: 2, index: index, hexStr: hexStr),
                    _ByteOrderChip(label: '小端 ABCD', value: 3, index: index, hexStr: hexStr),
                    _ByteOrderChip(label: '小端反转 CDAB', value: 4, index: index, hexStr: hexStr),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ByteOrderChip extends StatefulWidget {
  final String label;
  final int value;
  final int index;
  final String hexStr;

  const _ByteOrderChip({required this.label, required this.value, required this.index, required this.hexStr});

  @override
  State<_ByteOrderChip> createState() => _ByteOrderChipState();
}

class _ByteOrderChipState extends State<_ByteOrderChip> {
  bool _hovered = false;
  static const _primary = Color(0xFF667EEA);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ModBusServerControler>();
    return Obx(() {
      final selected = controller.chouse[widget.index] == widget.value;
      return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () {
            controller.chouse[widget.index] = widget.value;
            switch (widget.value) {
              case 1: controller.JXData.value[widget.index] = utils.bigEndianToFloat(widget.hexStr); break;
              case 2: controller.JXData.value[widget.index] = utils.bigEndianSwappedToFloat(widget.hexStr); break;
              case 3: controller.JXData.value[widget.index] = utils.littleEndianToFloat(widget.hexStr); break;
              case 4: controller.JXData.value[widget.index] = utils.littleEndianSwappedToFloat(widget.hexStr); break;
            }
            controller.refresh();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            transform: Matrix4.identity()..scale(_hovered || selected ? 1.04 : 1.0),
            decoration: BoxDecoration(
              color: selected ? _primary : (_hovered ? _primary.withOpacity(0.06) : Colors.white),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? _primary : (_hovered ? _primary.withOpacity(0.4) : const Color(0xFFE2E8F0)),
                width: 1.5,
              ),
              boxShadow: selected
                  ? [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))]
                  : null,
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500,
                color: selected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      );
    });
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

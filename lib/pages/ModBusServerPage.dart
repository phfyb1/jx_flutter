import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/ModBusServerController.dart';

class ModBusServerPage extends GetView<ModBusServerController> {
  const ModBusServerPage({super.key});

  static const _primary = Color(0xFF667EEA);
  static const _primaryDark = Color(0xFF764BA2);
  static const _bg = Color(0xFFF0F4F8);

  @override
  Widget build(BuildContext context) {
    final inputController = TextEditingController();

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final hPad = isWide ? (constraints.maxWidth - 640) / 2 : 16.0;
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildStatCard(),
                      const SizedBox(height: 16),
                      _buildTypeSelectorCard(),
                      const SizedBox(height: 12),
                      _buildByteOrderCard(),
                      const SizedBox(height: 12),
                      _buildInputCard(inputController),
                      const SizedBox(height: 12),
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

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1.0, -1.0),
          end: Alignment(1.0, 1.0),
          colors: [_primary, _primaryDark, Color(0xFF6B8DD6)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _DotPatternPainter()),
          ),
          Positioned(top: -100, right: -80, child: _circleDecor(300, 0.07)),
          Positioned(bottom: -60, left: -60, child: _circleDecor(200, 0.04)),
          Positioned(top: 120, right: 60, child: _circleDecor(60, 0.05)),
        ],
      ),
    );
  }

  Widget _circleDecor(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );

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
          child:
              const Icon(Icons.developer_board_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ModBus 解析',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                '支持 Int / UInt / Float 多类型 · 多字节序',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard() {
    return Obx(() {
      final count = controller.dataResultList.length;
      final type = controller.dataType.value;
      final size = type.byteSize;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_primary, _primaryDark]),
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
                  const Text('解析数量',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    '$count 条  ·  $size 字节/条',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.data_object_rounded, color: Colors.white.withOpacity(0.9), size: 14),
                  const SizedBox(width: 4),
                  Text(type.label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTypeSelectorCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.category_rounded, color: _primary, size: 16),
                const SizedBox(width: 8),
                const Text(
                  '数据类型',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B)),
                ),
                const Spacer(),
                Obx(() => Text(
                      controller.dataType.value.label,
                      style: TextStyle(
                          fontSize: 12,
                          color: _primary,
                          fontWeight: FontWeight.w600),
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              final selected = controller.dataType.value;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DataType.values.map((type) {
                  return _TypeChip(
                    type: type,
                    selected: type == selected,
                    onTap: () => controller.setDataType(type),
                  );
                }).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildByteOrderCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.swap_horiz_rounded, color: _primary, size: 16),
                const SizedBox(width: 8),
                const Text(
                  '字节序',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B)),
                ),
                const Spacer(),
                Obx(() => Text(
                      controller.byteOrder.value.label,
                      style: TextStyle(
                          fontSize: 12,
                          color: _primary,
                          fontWeight: FontWeight.w600),
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              final selected = controller.byteOrder.value;
              final is2Byte = controller.dataType.value.byteSize == 2;
              final orders =
                  is2Byte ? ByteOrder.values.take(2).toList() : ByteOrder.values;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: orders.map((order) {
                  return _ByteOrderChip(
                    order: order,
                    selected: order == selected,
                    onTap: () => controller.setByteOrder(order),
                  );
                }).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard(TextEditingController inputController) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.input_rounded, color: _primary, size: 16),
                const SizedBox(width: 8),
                const Text(
                  '输入 ModBus 响应报文',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _AnimatedTextField(
                    controller: inputController,
                    hint: '例：01 03 08 43 48 00 00 43 7A 00 00 BA 49',
                    onSubmitted: (v) => controller.parse(v),
                  ),
                ),
                const SizedBox(width: 12),
                _GradientButton(
                  label: '解析',
                  icon: Icons.play_arrow_rounded,
                  onTap: () => controller.parse(inputController.text),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Color(0xFFB45309)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '格式：[设备地址 1B][功能码 1B][数据长度 1B][数据 N*B][校验 2B]',
                      style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
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

  Widget _buildResultCard() {
    return Obx(() {
      final results = controller.dataResultList;
      final parsed = controller.parsedValues;
      final type = controller.dataType.value;
      return Container(
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF0FDF4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '解析结果',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${results.length} 条',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981)),
                    ),
                  ),
                  const Spacer(),
                  _TypeTag(label: type.label, color: _primary),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: controller.clean,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 13, color: Colors.red.shade400),
                          const SizedBox(width: 4),
                          Text('清空',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.red.shade400)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _ResultItem(
                  index: index,
                  hexStr: results[index],
                  parsedStr: parsed[index],
                  type: type,
                );
              },
            ),
          ],
        ),
      );
    });
  }

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
                Icons.developer_board_rounded,
                color: _primary.withOpacity(0.5),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '输入 ModBus 响应报文后点击「解析」',
              style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '支持 Int16 / UInt16 / Int32 / UInt32 / Float32 / Float64',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────
// 数据类型 Chip
// ─────────────────────────────────────────────────────────────
class _TypeChip extends StatefulWidget {
  final DataType type;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({required this.type, required this.selected, required this.onTap});

  @override
  State<_TypeChip> createState() => _TypeChipState();
}

class _TypeChipState extends State<_TypeChip> {
  bool _hovered = false;
  static const _primary = Color(0xFF667EEA);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          transform: Matrix4.identity()..scale(_hovered || widget.selected ? 1.04 : 1.0),
          decoration: BoxDecoration(
            color: widget.selected
                ? _primary
                : (_hovered ? _primary.withOpacity(0.06) : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.selected
                  ? _primary
                  : (_hovered ? _primary.withOpacity(0.4) : const Color(0xFFE2E8F0)),
              width: 1.5,
            ),
            boxShadow: widget.selected
                ? [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.type.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.selected ? Colors.white : const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.type.byteSize}B',
                style: TextStyle(
                  fontSize: 10,
                  color: widget.selected
                      ? Colors.white.withOpacity(0.8)
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 字节序 Chip
// ─────────────────────────────────────────────────────────────
class _ByteOrderChip extends StatefulWidget {
  final ByteOrder order;
  final bool selected;
  final VoidCallback onTap;

  const _ByteOrderChip({required this.order, required this.selected, required this.onTap});

  @override
  State<_ByteOrderChip> createState() => _ByteOrderChipState();
}

class _ByteOrderChipState extends State<_ByteOrderChip> {
  bool _hovered = false;
  static const _primary = Color(0xFF667EEA);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          transform: Matrix4.identity()..scale(_hovered || widget.selected ? 1.04 : 1.0),
          decoration: BoxDecoration(
            color: widget.selected
                ? _primary
                : (_hovered ? _primary.withOpacity(0.06) : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.selected
                  ? _primary
                  : (_hovered ? _primary.withOpacity(0.4) : const Color(0xFFE2E8F0)),
              width: 1.5,
            ),
            boxShadow: widget.selected
                ? [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.order.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.selected ? Colors.white : const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.order.desc,
                style: TextStyle(
                  fontSize: 9,
                  color: widget.selected
                      ? Colors.white.withOpacity(0.75)
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 类型标签
// ─────────────────────────────────────────────────────────────
class _TypeTag extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 结果条目
// ─────────────────────────────────────────────────────────────
class _ResultItem extends StatelessWidget {
  final int index;
  final String hexStr;
  final String parsedStr;
  final DataType type;

  const _ResultItem({
    required this.index,
    required this.hexStr,
    required this.parsedStr,
    required this.type,
  });

  static const _primary = Color(0xFF667EEA);
  static const _accent = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _primary),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HEX（${type.byteSize} 字节）',
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey.shade500)),
                  const SizedBox(height: 2),
                  Text(
                    hexStr,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _accent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _TypeTag(label: type.label, color: _accent),
                  const SizedBox(height: 4),
                  Text(
                    parsedStr,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 输入框
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
              ? [BoxShadow(color: _primary.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: TextField(
          controller: widget.controller,
          style: const TextStyle(
              fontFamily: 'monospace', fontSize: 14, letterSpacing: 0.8),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primary, width: 1.5),
            ),
          ),
          onSubmitted: widget.onSubmitted,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 渐变按钮
// ─────────────────────────────────────────────────────────────
class _GradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _hovered = false;
  static const _primary = Color(0xFF667EEA);
  static const _primaryDark = Color(0xFF764BA2);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_hovered ? 1.05 : 1.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_primary, _primaryDark]),
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
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
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

// ─────────────────────────────────────────────────────────────
// 波点背景
// ─────────────────────────────────────────────────────────────
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

// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controller/ModBusController.dart';

class ModBusPage extends GetView<ModBusControler> {
  const ModBusPage({super.key});

  // ── 配色常量 ────────────────────────────────────
  static const _colorHeader = Color(0xFF5C6BC0); // 靛蓝：报文头部字段
  static const _colorData = Color(0xFF26A69A); // 青绿：寄存器数据
  static const _colorChecksum = Color(0xFF78909C); // 蓝灰：校验码
  static const _colorError = Color(0xFFEF5350); // 红：错误
  // ── 统一渐变色（与首页ModBus卡片图标一致 #F59E0B）──────────
  static const _primary = Color(0xFFF59E0B);
  static const _primaryDark = Color(0xFFD97706);
  static const _gradLight = Color(0xFFFEF9C3);
  static const _gradC = Color(0xFFFBBF24); // 琥珀中间
  static const _gradD = Color(0xFFF59E0B);
  static const _gradE = Color(0xFFD97706);

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
                _buildHeader(),
                Expanded(
                  child: Column(
                    children: [
                      _ConfigCard(controller: controller),
                      _InputCard(controller: controller),
                      Expanded(
                        child: _ResultArea(
                          controller: controller,
                          colorHeader: _colorHeader,
                          colorData: _colorData,
                          colorChecksum: _colorChecksum,
                          colorError: _colorError,
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

  // ── 渐变背景 ──────────────────────────────────────
  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1.0, -1.0),
          end: Alignment(1.0, 1.0),
          colors: [_gradLight, _primary, _primaryDark],
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

  // ── 顶部标题 ──────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: const Color.fromARGB(255, 83, 78, 78),
            onPressed: () => Get.back(),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 110, 108, 108).withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color.fromARGB(255, 80, 76, 76).withOpacity(0.3)),
            ),
            child: const Icon(Icons.memory_rounded, color: Color.fromARGB(255, 83, 80, 80), size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ModBus 解析',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 73, 63, 63),
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  '标准 / 非标准模式',
                  style: TextStyle(fontSize: 12, color: Color.fromARGB(179, 83, 77, 77)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════
// 配置卡片：模式 + 起始地址
// ════════════════════════════════════════════════════
class _ConfigCard extends StatelessWidget {
  final ModBusControler controller;
  const _ConfigCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Obx(() {
          final isStandard = controller.standard.value;
          return Column(
            children: [
              // 模式切换行
              Row(
                children: [
                  const Icon(Icons.settings_ethernet,
                      size: 18, color: Color(0xFF5C6BC0)),
                  const SizedBox(width: 8),
                  const Text('解析模式',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  // 分段选择器
                  _SegmentSwitch(
                    selected: isStandard,
                    labelA: '标准',
                    labelB: '非标准',
                    onChanged: (val) => controller.standard.value = val,
                  ),
                ],
              ),
              // 起始地址行（仅标准模式显示）
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: isStandard
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: _AddressRow(controller: controller),
                secondChild: const SizedBox(height: 4),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── 分段选择器 ────────────────────────────────────
class _SegmentSwitch extends StatelessWidget {
  final bool selected;
  final String labelA;
  final String labelB;
  final ValueChanged<bool> onChanged;
  const _SegmentSwitch({
    required this.selected,
    required this.labelA,
    required this.labelB,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const radius = 20.0;
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Seg(
              label: labelA,
              active: selected,
              radius: radius,
              onTap: () => onChanged(true)),
          _Seg(
              label: labelB,
              active: !selected,
              radius: radius,
              onTap: () => onChanged(false)),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  final String label;
  final bool active;
  final double radius;
  final VoidCallback onTap;
  const _Seg(
      {required this.label,
      required this.active,
      required this.radius,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF5C6BC0) : Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF5C6BC0),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ── 起始地址输入行 ──────────────────────────────────
class _AddressRow extends StatelessWidget {
  final ModBusControler controller;
  const _AddressRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          const Icon(Icons.tag, size: 18, color: Color(0xFF26A69A)),
          const SizedBox(width: 8),
          const Text('起始地址',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            height: 36,
            child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: '0',
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                filled: true,
                fillColor: const Color(0xFFF0F4FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => controller.startAddress.value = v,
            ),
          ),
          const SizedBox(width: 8),
          Text('(十进制)',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════
// 输入卡片
// ════════════════════════════════════════════════════
class _InputCard extends StatefulWidget {
  final ModBusControler controller;
  const _InputCard({required this.controller});

  @override
  State<_InputCard> createState() => _InputCardState();
}

class _InputCardState extends State<_InputCard> {
  final _textCtrl = TextEditingController();

  void _submit() {
    widget.controller.parse(_textCtrl.text);
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.input_rounded,
                    size: 18, color: Color(0xFF5C6BC0)),
                const SizedBox(width: 6),
                Text(
                  '报文输入',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.grey.shade700),
                ),
                const Spacer(),
                Text(
                  '支持带空格或连续十六进制',
                  style:
                      TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        letterSpacing: 0.8),
                    decoration: InputDecoration(
                      hintText: '例: 01 03 04 00 64 01 90 F5 40',
                      hintStyle: TextStyle(
                          fontSize: 12, color: Colors.grey.shade400),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 14),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        tooltip: '清空',
                        onPressed: () {
                          _textCtrl.clear();
                          widget.controller.clean();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 解析按钮
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('解析'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C6BC0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
// 结果区域
// ════════════════════════════════════════════════════
class _ResultArea extends StatelessWidget {
  final ModBusControler controller;
  final Color colorHeader;
  final Color colorData;
  final Color colorChecksum;
  final Color colorError;

  const _ResultArea({
    required this.controller,
    required this.colorHeader,
    required this.colorData,
    required this.colorChecksum,
    required this.colorError,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = controller.resultRows;

      if (rows.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('输入报文后点击「解析」',
                  style: TextStyle(
                      color: Colors.grey.shade400, fontSize: 14)),
            ],
          ),
        );
      }

      return Card(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.analytics_outlined,
                      size: 18, color: Color(0xFF5C6BC0)),
                  const SizedBox(width: 6),
                  const Text('解析结果',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const Spacer(),
                  // 图例
                  _Legend(color: colorHeader, label: '报文头'),
                  const SizedBox(width: 8),
                  _Legend(color: colorData, label: '寄存器'),
                  const SizedBox(width: 8),
                  _Legend(color: colorChecksum, label: 'CRC'),
                ],
              ),
            ),
            const Divider(height: 1),
            // 表头
            _TableHeader(),
            const Divider(height: 1),
            // 数据列表
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: rows.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final row = rows[index];
                  return _ResultRow(
                    row: row,
                    index: index,
                    colorHeader: colorHeader,
                    colorData: colorData,
                    colorChecksum: colorChecksum,
                    colorError: colorError,
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── 图例小标签 ─────────────────────────────────────
class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}

// ── 表头 ───────────────────────────────────────────
class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
              width: 28,
              child: Text('#',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500))),
          Expanded(
              flex: 2,
              child: Text('字段',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500))),
          Expanded(
              flex: 2,
              child: Text('十六进制',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500))),
          Expanded(
              flex: 3,
              child: Text('解析值',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500))),
        ],
      ),
    );
  }
}

// ── 单行结果 ───────────────────────────────────────
class _ResultRow extends StatelessWidget {
  final ModBusResultRow row;
  final int index;
  final Color colorHeader;
  final Color colorData;
  final Color colorChecksum;
  final Color colorError;

  const _ResultRow({
    required this.row,
    required this.index,
    required this.colorHeader,
    required this.colorData,
    required this.colorChecksum,
    required this.colorError,
  });

  Color get _rowColor {
    switch (row.type) {
      case ModBusRowType.header:
        return colorHeader;
      case ModBusRowType.data:
        return colorData;
      case ModBusRowType.checksum:
        return colorChecksum;
      case ModBusRowType.error:
        return colorError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _rowColor;
    final isData = row.type == ModBusRowType.data;
    final isError = row.type == ModBusRowType.error;

    return InkWell(
      onLongPress: () {
        // 长按复制整行内容
        final text =
            '${row.label}  HEX: ${row.hex}  DEC: ${row.decimal}';
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已复制到剪贴板'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        color: index.isEven ? Colors.white : const Color(0xFFFAFAFC),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: isError
            ? Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: colorError, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      row.hex,
                      style: TextStyle(
                          color: colorError, fontSize: 13),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  // 序号
                  SizedBox(
                    width: 28,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color),
                      ),
                    ),
                  ),
                  // 字段名
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isData
                              ? '${row.label} #${row.address}'
                              : row.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 十六进制
                  Expanded(
                    flex: 2,
                    child: Text(
                      row.hex.isEmpty ? '-' : '0x${row.hex}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: Color(0xFF455A64),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // 解析值
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.decimal.isEmpty ? '-' : row.decimal,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isData
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isData
                            ? const Color(0xFF00695C)
                            : const Color(0xFF546E7A),
                      ),
                    ),
                  ),
                ],
              ),
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

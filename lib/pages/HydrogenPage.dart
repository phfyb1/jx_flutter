import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jx_flutter/controller/HydrogenController.dart';

class HydrogenPage extends GetView<HydrogenController> {
  const HydrogenPage({super.key});

  static const _primary = Color(0xFF8B5CF6);
  static const _primaryDark = Color(0xFF7C3AED);
  static const _gradLight = Color(0xFFC4B5FD); // 椤堕儴鏌斿拰娴呰壊
  static const _gradEnd   = Color(0xFF7C3AED);   // 搴曢儴涓繁杩囨浮
  static const _bg = Color(0xFFF0F4F8);
  static const _cardBg = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildFormCard(context),
                              const SizedBox(height: 16),
                              Obx(() => controller.isGenerated.value
                                  ? _buildResultCard(context)
                                  : const SizedBox.shrink()),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
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
          colors: [_primary, _primaryDark, const Color(0xFFA78BFA)],
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
            child: const Icon(Icons.local_gas_station_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '加氢站建表 SQL 生成',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'TDengine 9 类子表',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // 表单卡片
  // ─────────────────────────────────────────
  Widget _buildFormCard(BuildContext context) {
    return Container(
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
          // 标题栏
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF3E8FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_gas_station_rounded,
                      color: _primary, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TDengine 子表参数',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      '加氢站 9 类子表建表语句自动生成',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 提示
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFFB45309)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '带 * 的为必填项；加氢枪编码和储氢容器编码支持多个，用逗号分隔',
                      style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _FieldRow(
                  label: '* 加氢站编码',
                  hint: '如：station_001',
                  required: true,
                  rxValue: controller.hydrogenCode,
                ),
                const SizedBox(height: 12),
                _FieldRow(
                  label: '* 密码',
                  hint: '加氢站接口账密',
                  required: true,
                  rxValue: controller.password,
                ),
                const SizedBox(height: 12),
                _FieldRow(
                  label: '用户名',
                  hint: '平台实时数据用户名（可选）',
                  rxValue: controller.username,
                ),
                const SizedBox(height: 12),
                _FieldRow(
                  label: '加氢枪编码',
                  hint: '多个用逗号分隔，如：gun_01,gun_02',
                  rxValue: controller.hydrogenGunCode,
                ),
                const SizedBox(height: 12),
                _FieldRow(
                  label: '储氢容器编码',
                  hint: '多个用逗号分隔，如：c01,c02',
                  rxValue: controller.hydrogenContainersNum,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => ElevatedButton.icon(
                        onPressed: controller.isGenerated.value
                            ? controller.clear
                            : controller.generate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.isGenerated.value
                              ? Colors.grey.shade200
                              : _primary,
                          foregroundColor: controller.isGenerated.value
                              ? Colors.grey.shade700
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(controller.isGenerated.value
                            ? Icons.refresh_rounded
                            : Icons.auto_awesome_rounded),
                        label: Text(controller.isGenerated.value
                            ? '重新填写'
                            : '生成 SQL（${9} 类表）'),
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // 结果卡片
  // ─────────────────────────────────────────
  Widget _buildResultCard(BuildContext context) {
    return Container(
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
          // 标题栏
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF10B981), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                            '生成完成 · 共 ${controller.totalTables} 条建表语句',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          )),
                      const Text(
                        '点击任意 SQL 可复制，加氢枪/储氢容器会逐条生成',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                // 下载按钮
                TextButton.icon(
                  onPressed: () => controller.downloadAll(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                    foregroundColor: const Color(0xFF10B981),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('下载 .sql'),
                ),
              ],
            ),
          ),
          // 结果列表
          Obx(() => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: controller.results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = controller.results[index];
                  return _SQLResultTile(
                    item: item,
                    index: index,
                    onCopy: () => controller.copyItem(item),
                  );
                },
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 字段行（与 controller Rx 值双向绑定）
// ─────────────────────────────────────────────
class _FieldRow extends StatefulWidget {
  final String label;
  final String hint;
  final bool required;
  final RxString rxValue;

  const _FieldRow({
    required this.label,
    required this.hint,
    this.required = false,
    required this.rxValue,
  });

  @override
  State<_FieldRow> createState() => _FieldRowState();
}

class _FieldRowState extends State<_FieldRow> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    // 初始化时用当前 Rx 值（避免 clear 后 rebuild 时丢值）
    _ctrl = TextEditingController(text: widget.rxValue.value);
    // 监听 Rx 值变化 → 同步到 TextField（比如 clear 时）
    ever(widget.rxValue, (String val) {
      if (_ctrl.text != val) {
        final sel = _ctrl.selection;
        _ctrl.text = val;
        // 恢复光标位置，避免跳到末尾
        if (sel.isValid && sel.end <= val.length) {
          _ctrl.selection = sel;
        }
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                if (widget.required)
                  const Text(' *',
                      style: TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
              ],
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
              ),
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: (v) => widget.rxValue.value = v,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SQL 结果行
// ─────────────────────────────────────────────
class _SQLResultTile extends StatefulWidget {
  final HydrogenSQLItem item;
  final int index;
  final VoidCallback onCopy;

  const _SQLResultTile({
    required this.item,
    required this.index,
    required this.onCopy,
  });

  @override
  State<_SQLResultTile> createState() => _SQLResultTileState();
}

class _SQLResultTileState extends State<_SQLResultTile> {
  bool _copied = false;

  void _handleCopy() {
    widget.onCopy();
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: _handleCopy,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 序号
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${widget.index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      widget.item.sql,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontFamily: 'monospace',
                        color: Color(0xFF1E293B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 复制按钮
              Icon(
                _copied ? Icons.check_rounded : Icons.copy_rounded,
                size: 18,
                color: _copied
                    ? const Color(0xFF10B981)
                    : const Color(0xFF94A3B8),
              ),
            ],
          ),
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

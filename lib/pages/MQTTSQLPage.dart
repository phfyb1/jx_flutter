import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jx_flutter/controller/MQTTSQLController.dart';

class MQTTSQLPage extends GetView<MQTTSQLController> {
  const MQTTSQLPage({super.key});

  static const _primary = Color(0xFF059669); // 绿色
  static const _bg = Color(0xFFF0F4F8);
  static const _cardBg = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: const Text('MQTT SQL 生成'),
        elevation: 0,
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 24 : 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFormCard(context),
                  const SizedBox(height: 16),
                  Obx(() => controller.show.value
                      ? _buildResultCard(context)
                      : const SizedBox.shrink()),
                ],
              ),
            ),
          ),
        );
      }),
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
              color: Color(0xFFECFDF5),
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
                  child:
                      const Icon(Icons.hub_rounded, color: _primary, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EMQX 账户 SQL',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      '生成 mqtt_user + mqtt_acl INSERT 语句',
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
                      '带 * 的为必填项；不填的字段将使用默认值（密码默认 username+hthj）',
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
                  label: '* 用户名',
                  hint: '设备序列号 SN',
                  required: true,
                  rxValue: controller.username,
                ),
                const SizedBox(height: 12),
                _FieldRow(
                  label: '密码',
                  hint: '默认 username+hthj',
                  rxValue: controller.pwd,
                ),
                const SizedBox(height: 12),
                _FieldRow(
                  label: 'ClientId',
                  hint: '默认同用户名',
                  rxValue: controller.clientId,
                ),
                const SizedBox(height: 12),
                _FieldRow(
                  label: 'Salt',
                  hint: '默认 iots',
                  rxValue: controller.salt,
                ),
                const SizedBox(height: 12),
                _FieldRow(
                  label: 'Access',
                  hint: '默认 2（publish）',
                  rxValue: controller.access,
                ),
                const SizedBox(height: 12),
                _FieldRow(
                  label: 'Topic',
                  hint: '/iot/xpsj/v2/%c/thirdParty/realtimeData',
                  rxValue: controller.topic,
                ),
                const SizedBox(height: 12),
                _FieldRow(
                  label: '备注',
                  hint: '记录此账号给谁用（可选）',
                  rxValue: controller.remark,
                ),
              ],
            ),
          ),
          // 按钮区（居中加宽）
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Obx(() => ElevatedButton.icon(
                      onPressed: controller.handleButton,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            controller.show.value ? Colors.grey.shade200 : _primary,
                        foregroundColor: controller.show.value
                            ? Colors.grey.shade700
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(controller.show.value
                          ? Icons.refresh_rounded
                          : Icons.auto_awesome_rounded),
                      label: Text(controller.show.value ? '重新填写' : '生成 SQL'),
                    )),
              ),
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '生成完成',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '点击 SQL 文本可复制，或直接下载 .sql 文件',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                // 下载按钮
                TextButton.icon(
                  onPressed: () => controller.downloadSql(),
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
          // SQL 内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              final sql = controller.generatedSql;
              return GestureDetector(
                onTap: () => controller.copySql(sql),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.copy_rounded,
                              size: 14, color: Color(0xFF94A3B8)),
                          SizedBox(width: 6),
                          Text(
                            '点击复制全部 SQL',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SelectableText(
                        sql,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'monospace',
                          color: Color(0xFF1E293B),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
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
    _ctrl = TextEditingController(text: widget.rxValue.value);
    ever(widget.rxValue, (String val) {
      if (_ctrl.text != val) {
        final sel = _ctrl.selection;
        _ctrl.text = val;
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
                    const BorderSide(color: Color(0xFF059669), width: 1.5),
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

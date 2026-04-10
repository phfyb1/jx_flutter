import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jx_flutter/router/app_route.dart';

// ─────────────────────────────────────────────
// 工具条目数据模型
// ─────────────────────────────────────────────
class _ToolItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _ToolItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _ToolCategory {
  final String label;
  final List<_ToolItem> items;
  const _ToolCategory({required this.label, required this.items});
}

// ─────────────────────────────────────────────
// 工具分类数据
// ─────────────────────────────────────────────
const List<_ToolCategory> _categories = [
  _ToolCategory(label: '协议解析', items: [
    _ToolItem(
      title: 'JT809 解析',
      subtitle: '交通部协议报文解析',
      icon: Icons.directions_bus_rounded,
      color: Color(0xFF3B82F6),
      route: AppRoutes.JT809,
    ),
    _ToolItem(
      title: 'HJ212 造数据',
      subtitle: 'TSDB 格式测试数据',
      icon: Icons.eco_rounded,
      color: Color(0xFF10B981),
      route: AppRoutes.HJ212,
    ),
    _ToolItem(
      title: 'ModBus 解析',
      subtitle: '寄存器报文解析',
      icon: Icons.memory_rounded,
      color: Color(0xFFF59E0B),
      route: AppRoutes.ModBus,
    ),
  ]),
  _ToolCategory(label: 'SQL 生成', items: [
    _ToolItem(
      title: '加氢站建表 SQL',
      subtitle: 'TDengine 9 类子表建表',
      icon: Icons.local_gas_station_rounded,
      color: Color(0xFF8B5CF6),
      route: AppRoutes.Hydrogen,
    ),
    _ToolItem(
      title: 'MQTT SQL 生成',
      subtitle: 'EMQX 用户与权限',
      icon: Icons.hub_rounded,
      color: Color(0xFFEC4899),
      route: AppRoutes.MQTT,
    ),
    _ToolItem(
      title: '报警规则 SQL',
      subtitle: 'XLSX+JSON 生成规则',
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFEF4444),
      route: AppRoutes.AlarmTool,
    ),
    _ToolItem(
      title: '传感器报警规则',
      subtitle: 'XLSX 预览导出',
      icon: Icons.sensors_rounded,
      color: Color(0xFF06B6D4),
      route: AppRoutes.SensorAlarmRule,
    ),
  ]),
];

// ─────────────────────────────────────────────
// 首页
// ─────────────────────────────────────────────
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _primary = Color(0xFF4F46E5);
  static const _primaryDark = Color(0xFF3730A3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _CategorySection(
                  category: _categories[index],
                ),
                childCount: _categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      stretch: true,
      backgroundColor: _primaryDark,
      title: const Text(
        '协议解析工具箱',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primary, _primaryDark],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.developer_mode_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '协议解析工具箱',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'IoT 设备对接 / 运维开发助手',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StatsRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 顶部统计行
// ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  static int get _totalTools =>
      _categories.fold(0, (sum, c) => sum + c.items.length);
  static int get _totalCategories => _categories.length;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
            icon: Icons.widgets_rounded,
            label: '$_totalTools 个工具',
            color: Colors.white),
        const SizedBox(width: 8),
        _StatChip(
            icon: Icons.category_rounded,
            label: '$_totalCategories 个分类',
            color: Colors.white),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 分类区块
// ─────────────────────────────────────────────
class _CategorySection extends StatelessWidget {
  final _ToolCategory category;

  const _CategorySection({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分类标题
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: category.items.first.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  category.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${category.items.length} 个工具',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          // 工具卡片网格
          LayoutBuilder(builder: (context, constraints) {
            final crossCount = constraints.maxWidth > 600 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.2,
              ),
              itemCount: category.items.length,
              itemBuilder: (context, index) =>
                  _ToolCard(item: category.items[index]),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 工具卡片（横向布局：图标 + 文字）
// ─────────────────────────────────────────────
class _ToolCard extends StatefulWidget {
  final _ToolItem item;

  const _ToolCard({required this.item});

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Get.toNamed(widget.item.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -3.0 : 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.item.color.withOpacity(0.2)
                    : Colors.black.withOpacity(0.04),
                blurRadius: _isHovered ? 14 : 4,
                offset: Offset(0, _isHovered ? 6 : 2),
              ),
            ],
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            // 左侧彩色竖条（随 ClipRRect 统一圆角）
            Container(width: 4, color: widget.item.color),
            // 卡片内容
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // 图标
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _isHovered
                            ? widget.item.color.withOpacity(0.2)
                            : widget.item.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(widget.item.icon,
                          color: widget.item.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    // 文字
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.item.title,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.item.subtitle,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF94A3B8),
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }
}

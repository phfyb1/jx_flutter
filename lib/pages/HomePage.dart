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
    _ToolItem(
      title: 'ModBus 服务端解析',
      subtitle: 'float32 多字节序解析',
      icon: Icons.developer_board_rounded,
      color: Color(0xFF0EA5E9),
      route: AppRoutes.ModBusServer,
    ),
  ]),
  _ToolCategory(label: '日志解析', items: [
    _ToolItem(
      title: 'MQTT 日志解析',
      subtitle: 'JSON values 计数 · code 查询',
      icon: Icons.article_outlined,
      color: Color(0xFF7C3AED),
      route: AppRoutes.MqttLog,
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
    _ToolItem(
      title: '模板转换',
      subtitle: '安基 → 物联网',
      icon: Icons.transform_rounded,
      color: Color(0xFFF59E0B),
      route: AppRoutes.TemplateConvert,
    ),
    _ToolItem(
      title: '危险源模板校验',
      subtitle: '重大危险源 Excel 校验修复',
      icon: Icons.shield_rounded,
      color: Color(0xFFEF4444),
      route: AppRoutes.DangerSource,
    ),
  ]),
];

// ─────────────────────────────────────────────
// 首页
// ─────────────────────────────────────────────
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 渐变背景
          _GradientBackground(),
          // 内容
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
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
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        '协议解析工具箱',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    _GlassIcon(),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '协议解析工具箱',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'IoT 设备对接 / 运维开发助手',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _StatsRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 渐变背景 + 装饰
// ─────────────────────────────────────────────
class _GradientBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
            Color(0xFF6B8DD6),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 装饰圆
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
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
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // 装饰点阵
          CustomPaint(
            size: Size.infinite,
            painter: _DotPatternPainter(),
          ),
        ],
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
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

// ─────────────────────────────────────────────
// 玻璃态图标容器
// ─────────────────────────────────────────────
class _GlassIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.developer_mode_rounded,
        color: Colors.white,
        size: 32,
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
          color: Colors.white,
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.category_rounded,
          label: '$_totalCategories 个分类',
          color: Colors.white,
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
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
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分类标题
          _CategoryHeader(
            label: category.label,
            count: category.items.length,
            color: category.items.first.color,
          ),
          const SizedBox(height: 12),
          // 工具卡片网格
          LayoutBuilder(builder: (context, constraints) {
            final crossCount = constraints.maxWidth > 600 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: crossCount == 2 ? 2.8 : 4.0,
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
// 分类标题
// ─────────────────────────────────────────────
class _CategoryHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _CategoryHeader({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// 工具卡片（玻璃态设计）
// ─────────────────────────────────────────────
class _ToolCard extends StatefulWidget {
  final _ToolItem item;

  const _ToolCard({required this.item});

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      cursor: SystemMouseCursors.click,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: () => Get.toNamed(widget.item.route),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(_isHovered ? 0.95 : 0.98),
                ],
              ),
              border: Border.all(
                color: _isHovered
                    ? widget.item.color.withOpacity(0.4)
                    : Colors.white.withOpacity(0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? widget.item.color.withOpacity(0.2)
                      : Colors.black.withOpacity(0.06),
                  blurRadius: _isHovered ? 20 : 12,
                  offset: Offset(0, _isHovered ? 8 : 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // 背景装饰
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isHovered ? 0.08 : 0.04,
                      child: Icon(
                        widget.item.icon,
                        size: 100,
                        color: widget.item.color,
                      ),
                    ),
                  ),
                  // 主内容
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // 图标容器
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.item.color,
                                widget.item.color.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: widget.item.color.withOpacity(_isHovered ? 0.4 : 0.2),
                                blurRadius: _isHovered ? 12 : 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.item.icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 文字内容
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.item.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: _isHovered ? 0.3 : 0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.item.subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  height: 1.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // 箭头
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isHovered ? 1.0 : 0.3,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.item.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: widget.item.color,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
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

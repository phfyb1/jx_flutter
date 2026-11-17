import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 玻璃吸顶栏：磨砂半透明，内容从其下方滚过
///
/// 高度固定为 [height]，页面内容区顶部需预留同样高度
/// （建议 `GlassHeaderBar.height + 16` 作为滚动区的顶部内边距）。
class GlassHeaderBar extends StatelessWidget {
  /// 吸顶栏固定高度
  static const double height = 76;

  /// 栏内内容（通常是 PageHeader，也可以是各页面自定义头部）
  final Widget child;

  /// 内容最大宽度，<= 0 表示不限制（跟随屏幕宽度）
  final double maxWidth;

  /// 内层左右内边距
  final EdgeInsets padding;

  const GlassHeaderBar({
    super.key,
    required this.child,
    this.maxWidth = 0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: child);
    if (maxWidth > 0) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: content,
        ),
      );
    }
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: height,
          alignment: Alignment.center,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1,
              ),
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}

/// 统一页面头部（玻璃拟态样式）
///
/// 与首页及其余工具页保持一致：左侧返回按钮 + 图标徽标 + 标题/副标题，
/// 直接叠在渐变背景上，不再使用 SliverAppBar / AppBar。
class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  /// 是否显示返回按钮（默认显示）
  final bool showBack;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack) ...[
          _GlassBox(
            padding: const EdgeInsets.all(8),
            radius: 12,
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
        ],
        _GlassBox(
          padding: const EdgeInsets.all(12),
          radius: 14,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 半透明白色玻璃容器（返回按钮 / 图标徽标共用）
class _GlassBox extends StatelessWidget {
  final EdgeInsets padding;
  final double radius;
  final Widget child;

  const _GlassBox({
    required this.padding,
    required this.radius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: child,
    );
  }
}

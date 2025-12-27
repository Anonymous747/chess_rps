import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';

/// Shimmer animation for skeleton loaders
class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const Shimmer({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 - _controller.value * 2, 0.0),
              end: Alignment(1.0 - _controller.value * 2, 0.0),
              colors: [
                Palette.backgroundTertiary,
                Palette.backgroundSecondary,
                Palette.accent.withValues(alpha: 0.3),
                Palette.backgroundSecondary,
                Palette.backgroundTertiary,
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Base skeleton widget with shimmer effect
class Skeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;

  const Skeleton({
    Key? key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? Palette.backgroundTertiary,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton for text lines
class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final int lines;
  final double spacing;

  const SkeletonText({
    Key? key,
    this.width = double.infinity,
    this.height = 16,
    this.lines = 1,
    this.spacing = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (lines == 1) {
      return Skeleton(width: width, height: height);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        lines,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? spacing : 0),
          child: Skeleton(
            width: index == lines - 1 ? width * 0.7 : width,
            height: height,
          ),
        ),
      ),
    );
  }
}

/// Skeleton for avatar/circle
class SkeletonAvatar extends StatelessWidget {
  final double size;
  final Color? color;

  const SkeletonAvatar({
    Key? key,
    this.size = 48,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      width: size,
      height: size,
      borderRadius: size / 2,
      color: color,
    );
  }
}

/// Skeleton for card
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double height;
  final EdgeInsets? padding;
  final Widget? child;

  const SkeletonCard({
    Key? key,
    this.width,
    this.height = 120,
    this.padding,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Palette.glassBorder,
          width: 1,
        ),
      ),
      child: child ??
          ClipRect(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: SkeletonAvatar(size: 36),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: SkeletonText(width: double.infinity, height: 10, lines: 2, spacing: 4),
                ),
              ],
            ),
          ),
    );
  }
}

/// Skeleton for list item
class SkeletonListItem extends StatelessWidget {
  final bool hasAvatar;
  final bool hasTrailing;

  const SkeletonListItem({
    Key? key,
    this.hasAvatar = true,
    this.hasTrailing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Palette.glassBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (hasAvatar) ...[
            const SkeletonAvatar(size: 48),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(width: double.infinity, height: 14, lines: 1),
                const SizedBox(height: 8),
                SkeletonText(width: 200, height: 12, lines: 1),
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: 12),
            Skeleton(width: 60, height: 32, borderRadius: 8),
          ],
        ],
      ),
    );
  }
}

/// Skeleton for grid items
class SkeletonGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;

  const SkeletonGrid({
    Key? key,
    this.itemCount = 6,
    this.childAspectRatio = 1.0,
    this.crossAxisCount = 2,
    this.spacing = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return SkeletonCard(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Skeleton(width: 60, height: 60, borderRadius: 8),
              const SizedBox(height: 12),
              SkeletonText(width: double.infinity, height: 12, lines: 2),
            ],
          ),
        );
      },
    );
  }
}

/// Skeleton for profile header
class SkeletonProfileHeader extends StatelessWidget {
  const SkeletonProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Palette.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const SkeletonAvatar(size: 80),
          const SizedBox(height: 16),
          SkeletonText(width: 150, height: 18, lines: 1),
          const SizedBox(height: 8),
          SkeletonText(width: 200, height: 14, lines: 1),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(),
              _buildStatItem(),
              _buildStatItem(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem() {
    return Column(
      children: [
        SkeletonText(width: 40, height: 20, lines: 1),
        const SizedBox(height: 4),
        SkeletonText(width: 60, height: 12, lines: 1),
      ],
    );
  }
}


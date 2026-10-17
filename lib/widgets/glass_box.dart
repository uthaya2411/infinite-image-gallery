import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBox extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;
  final Color? tintColor;

  const GlassBox({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.opacity = 0.25,
    this.borderRadius,
    this.padding,
    this.border,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(16);
    final baseColor = tintColor ?? (isDark ? Colors.black : Colors.white);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: opacity),
            borderRadius: radius,
            border: border ??
                Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.6),
                  width: 1,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}

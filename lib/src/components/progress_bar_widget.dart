import 'package:flutter/material.dart';
import '../core/utils/app_colors.dart';

class AppProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? fillColor;
  final Color? backgroundColor;

  const AppProgressBar({
    super.key,
    required this.progress,
    this.height = 6,
    this.fillColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.border,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0, 1),
        child: Container(
          decoration: BoxDecoration(
            color: fillColor ?? AppColors.primary,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

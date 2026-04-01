import 'package:flutter/material.dart';
import '../core/utils/app_colors.dart';
import '../core/utils/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final bool isSecondary;
  final bool isLoading;
  final double width;
  final double radius;
  final Color? color;
  final Color? textColor;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isOutlined = false,
    this.isSecondary = false,
    this.isLoading = false,
    this.width = double.infinity,
    this.radius = 12,
    this.color,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (isSecondary) return _buildSecondary();
    if (isOutlined) return _buildOutlined();
    return _buildPrimary();
  }

  Widget _buildPrimary() {
    final bgColor = color ?? AppColors.primary;
    final fgColor = textColor ?? Colors.white;

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: _buildChild(fgColor),
      ),
    );
  }

  Widget _buildOutlined() {
    final fgColor = textColor ?? AppColors.primary;

    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: fgColor,
          side: BorderSide(color: fgColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: _buildChild(fgColor),
      ),
    );
  }

  Widget _buildSecondary() {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textHigh,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: _buildChild(AppColors.textHigh),
      ),
    );
  }

  Widget _buildChild(Color fgColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(fgColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.buttonText.copyWith(color: fgColor)),
        ],
      );
    }

    return Text(text, style: AppTextStyles.buttonText.copyWith(color: fgColor));
  }
}

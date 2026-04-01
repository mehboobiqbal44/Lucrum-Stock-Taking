import 'package:flutter/material.dart';
import '../core/utils/app_colors.dart';

enum BadgeType { info, success, warning, error, primary }

class AppBadge extends StatelessWidget {
  final String text;
  final BadgeType type;

  const AppBadge({
    super.key,
    required this.text,
    this.type = BadgeType.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (type) {
      case BadgeType.info:
        return AppColors.infoBg;
      case BadgeType.success:
        return AppColors.successBg;
      case BadgeType.warning:
        return AppColors.warningBg;
      case BadgeType.error:
        return AppColors.errorBg;
      case BadgeType.primary:
        return AppColors.primaryLight;
    }
  }

  Color get _textColor {
    switch (type) {
      case BadgeType.info:
        return AppColors.infoText;
      case BadgeType.success:
        return AppColors.successText;
      case BadgeType.warning:
        return AppColors.warningText;
      case BadgeType.error:
        return AppColors.errorText;
      case BadgeType.primary:
        return AppColors.primary;
    }
  }
}

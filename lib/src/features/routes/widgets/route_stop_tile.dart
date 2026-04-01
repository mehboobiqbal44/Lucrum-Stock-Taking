import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/models/route_stop_model.dart';
import '../../../components/badge_widget.dart';

class RouteStopTile extends StatelessWidget {
  final RouteStopModel stop;
  final bool isLast;
  final VoidCallback? onTap;

  const RouteStopTile({
    super.key,
    required this.stop,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(child: _buildInfo()),
            _buildBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _iconBgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(_icon, size: 20, color: _iconColor),
    );
  }

  IconData get _icon {
    switch (stop.status) {
      case StopStatus.completed:
        return Icons.check;
      case StopStatus.active:
        return Icons.location_on;
      case StopStatus.pending:
        return Icons.store;
    }
  }

  Color get _iconBgColor {
    switch (stop.status) {
      case StopStatus.completed:
        return AppColors.successBg;
      case StopStatus.active:
        return AppColors.primaryLight;
      case StopStatus.pending:
        return AppColors.background;
    }
  }

  Color get _iconColor {
    switch (stop.status) {
      case StopStatus.completed:
        return AppColors.successText;
      case StopStatus.active:
        return AppColors.primary;
      case StopStatus.pending:
        return AppColors.textMedium;
    }
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stop.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textHigh,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
        ),
      ],
    );
  }

  String get _subtitle {
    final parts = <String>[stop.address];
    if (stop.status == StopStatus.completed && stop.completedTime != null) {
      parts.add('Done ${stop.completedTime}');
    } else if (stop.distanceKm > 0) {
      parts.add('${stop.distanceKm}km');
      if (stop.taskCount > 0) parts.add('${stop.taskCount} tasks');
    }
    return parts.join(' · ');
  }

  Widget _buildBadge() {
    switch (stop.status) {
      case StopStatus.completed:
        return const AppBadge(text: 'Done', type: BadgeType.success);
      case StopStatus.active:
        return const AppBadge(text: 'Active', type: BadgeType.primary);
      case StopStatus.pending:
        return const AppBadge(text: 'Pending', type: BadgeType.warning);
    }
  }
}

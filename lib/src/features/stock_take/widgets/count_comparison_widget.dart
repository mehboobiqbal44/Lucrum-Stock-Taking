import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';

class CountComparisonWidget extends StatelessWidget {
  final int systemCount;
  final int actualCount;

  const CountComparisonWidget({
    super.key,
    required this.systemCount,
    required this.actualCount,
  });

  bool get hasDiscrepancy => actualCount > 0 && actualCount != systemCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildCountBox('SYSTEM COUNT', systemCount, AppColors.textHigh)),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCountBox(
            'ACTUAL COUNT',
            actualCount,
            actualCount == 0
                ? AppColors.primary
                : hasDiscrepancy
                    ? AppColors.errorText
                    : AppColors.successText,
          ),
        ),
      ],
    );
  }

  Widget _buildCountBox(String label, int count, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            actualCount == 0 && label.contains('ACTUAL') ? '—' : '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

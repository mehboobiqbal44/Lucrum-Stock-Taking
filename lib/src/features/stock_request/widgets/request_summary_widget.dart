import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';

class RequestSummaryWidget extends StatelessWidget {
  final int selectedCount;
  final int totalQty;
  final bool isUrgent;
  final VoidCallback onToggleUrgent;

  const RequestSummaryWidget({
    super.key,
    required this.selectedCount,
    required this.totalQty,
    required this.isUrgent,
    required this.onToggleUrgent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Mark as Urgent',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textHigh,
            ),
          ),
          GestureDetector(
            onTap: onToggleUrgent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: isUrgent ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(100),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    isUrgent ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

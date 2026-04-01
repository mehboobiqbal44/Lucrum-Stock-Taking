import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/models/stock_item_model.dart';
import '../../../components/app_card.dart';
import '../../../components/app_text_field.dart';
import 'count_comparison_widget.dart';

class StockTakeItemCard extends StatelessWidget {
  final StockItemModel item;
  final ValueChanged<int> onActualQtyChanged;

  const StockTakeItemCard({
    super.key,
    required this.item,
    required this.onActualQtyChanged,
  });

  bool get hasDiscrepancy =>
      item.actualQty > 0 && item.actualQty != item.systemQty;

  int get variance => item.actualQty - item.systemQty;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          CountComparisonWidget(
            systemCount: item.systemQty,
            actualCount: item.actualQty,
          ),
          if (hasDiscrepancy) ...[
            const SizedBox(height: 12),
            _buildDiscrepancyAlert(),
          ],
          const SizedBox(height: 12),
          AppTextField(
            label: 'Enter Actual Count',
            hint: 'Enter counted quantity...',
            isRequired: true,
            keyboardType: TextInputType.number,
            suffixIcon: const Icon(
              Icons.calculate_outlined,
              color: AppColors.textMedium,
              size: 20,
            ),
            onChanged: (val) {
              final qty = int.tryParse(val);
              if (qty != null) onActualQtyChanged(qty);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textHigh,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'SKU: ${item.sku} · UOM: ${item.unit.toUpperCase()}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildDiscrepancyAlert() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.errorText),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, size: 20, color: AppColors.errorText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Discrepancy detected: ${variance.abs()} units',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.errorText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

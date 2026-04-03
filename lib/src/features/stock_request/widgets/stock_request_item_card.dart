import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/models/stock_item_model.dart';

class StockRequestItemCard extends StatelessWidget {
  final StockItemModel item;
  final ValueChanged<int> onQtyChanged;
  final bool readOnly;

  const StockRequestItemCard({
    super.key,
    required this.item,
    required this.onQtyChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHigh,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'SKU: ${item.sku}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          _QtyInputControl(
            value: item.requestedQty,
            onChanged: onQtyChanged,
            readOnly: readOnly,
          ),
        ],
      ),
    );
  }
}

class _QtyInputControl extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final bool readOnly;

  const _QtyInputControl({
    required this.value,
    required this.onChanged,
    this.readOnly = false,
  });

  @override
  State<_QtyInputControl> createState() => _QtyInputControlState();
}

class _QtyInputControlState extends State<_QtyInputControl> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant _QtyInputControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != widget.value.toString()) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyTypedValue(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null) return;
    widget.onChanged(parsed < 0 ? 0 : parsed);
  }

  @override
  Widget build(BuildContext context) {
    final ro = widget.readOnly;
    return Opacity(
      opacity: ro ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.surface,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCircleButton(
              icon: Icons.remove,
              onTap: ro
                  ? null
                  : () => widget.onChanged(
                        widget.value > 0 ? widget.value - 1 : 0,
                      ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 50,
              child: TextField(
                controller: _controller,
                readOnly: ro,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHigh,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: ro ? null : _applyTypedValue,
                onChanged: ro ? null : _applyTypedValue,
              ),
            ),
            const SizedBox(width: 8),
            _buildCircleButton(
              icon: Icons.add,
              onTap: ro ? null : () => widget.onChanged(widget.value + 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? AppColors.textLow : AppColors.primary,
        ),
      ),
    );
  }
}

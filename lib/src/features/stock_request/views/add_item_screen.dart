import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/models/stock_item_model.dart';
import '../../../components/app_text_field.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  List<StockItemModel> _allItems = [];
  List<StockItemModel> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _allItems = _mockAllItems;
      _filtered = _allItems;
      _loading = false;
    });
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _allItems;
      } else {
        final lower = query.toLowerCase();
        _filtered = _allItems
            .where((i) =>
                i.name.toLowerCase().contains(lower) ||
                i.sku.toLowerCase().contains(lower))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textHigh),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Item', style: AppTextStyles.title),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              hint: 'Search all items...',
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
                color: AppColors.textMedium,
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No items found',
                          style: AppTextStyles.caption,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _filtered[index];
                          return _buildItemTile(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(StockItemModel item) {
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
                  'SKU: ${item.sku} · ${item.availableQty} ${item.unit} available',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context, item),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static final _mockAllItems = [
    const StockItemModel(
      id: '10',
      name: 'Badminton Racket Pro',
      sku: 'BR-PRO-101',
      availableQty: 25,
      systemQty: 25,
      unit: 'pcs',
    ),
    const StockItemModel(
      id: '11',
      name: 'Swimming Goggles - Anti Fog',
      sku: 'SG-AF-201',
      availableQty: 60,
      systemQty: 60,
      unit: 'pcs',
    ),
    const StockItemModel(
      id: '12',
      name: 'Basketball (Size 7)',
      sku: 'BB-S7-301',
      availableQty: 40,
      systemQty: 40,
      unit: 'pcs',
    ),
    const StockItemModel(
      id: '13',
      name: 'Table Tennis Set',
      sku: 'TT-SET-401',
      availableQty: 15,
      systemQty: 15,
      unit: 'sets',
    ),
    const StockItemModel(
      id: '14',
      name: 'Hockey Stick - Field',
      sku: 'HS-FLD-501',
      availableQty: 30,
      systemQty: 30,
      unit: 'pcs',
    ),
    const StockItemModel(
      id: '15',
      name: 'Yoga Mat - Premium',
      sku: 'YM-PRM-601',
      availableQty: 50,
      systemQty: 50,
      unit: 'pcs',
    ),
    const StockItemModel(
      id: '16',
      name: 'Boxing Gloves - 12oz',
      sku: 'BG-12-701',
      availableQty: 20,
      systemQty: 20,
      unit: 'pairs',
    ),
    const StockItemModel(
      id: '17',
      name: 'Jump Rope - Speed',
      sku: 'JR-SPD-801',
      availableQty: 80,
      systemQty: 80,
      unit: 'pcs',
    ),
  ];
}

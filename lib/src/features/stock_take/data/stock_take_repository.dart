import '../../../core/models/stock_item_model.dart';
import 'stock_take_service.dart';

class StockTakeRepository {
  final StockTakeService _service;

  StockTakeRepository(this._service);

  Future<List<StockItemModel>> getInventoryItems(
    String targetWarehouse,
  ) async {
    final data = await _service.fetchInventoryItems(targetWarehouse);
    final message = data['message'] as Map<String, dynamic>;
    final items = message['items'] as List<dynamic>? ?? [];
    return items
        .map((e) =>
            StockItemModel.fromTransferItem(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> submitStockTake({
    required String sourceWarehouse,
    required String customTask,
    required List<StockItemModel> items,
  }) async {
    final payload = items
        .where((i) => i.actualQty > 0)
        .map((i) => {
              'item_code': i.sku,
              'physical_qty': i.actualQty,
            })
        .toList();

    await _service.submitStockTake(
      sourceWarehouse: sourceWarehouse,
      customTask: customTask,
      items: payload,
    );
  }
}

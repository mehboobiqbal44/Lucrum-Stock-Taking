import '../../../core/models/stock_item_model.dart';
import 'stock_request_service.dart';

class StockRequestRepository {
  final StockRequestService _service;

  StockRequestRepository(this._service);

  Future<List<StockItemModel>> getWarehouseItems(
    String targetWarehouse,
  ) async {
    final data = await _service.fetchWarehouseItems(targetWarehouse);
    final message = data['message'] as Map<String, dynamic>;
    final items = message['items'] as List<dynamic>? ?? [];
    return items
        .map((e) =>
            StockItemModel.fromTransferItem(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<StockItemModel>> getAllItems() async {
    final data = await _service.fetchAllItems();
    return data
        .map((e) =>
            StockItemModel.fromCatalogItem(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> submitRequest({
    required String sourceWarehouse,
    required String targetWarehouse,
    required String customTask,
    required List<StockItemModel> items,
  }) async {
    final payload = items
        .where((i) => i.requestedQty > 0)
        .map((i) => {
              'item_code': i.sku,
              'qty': i.requestedQty,
            })
        .toList();

    await _service.submitRequest(
      sourceWarehouse: sourceWarehouse,
      targetWarehouse: targetWarehouse,
      customTask: customTask,
      items: payload,
    );
  }
}

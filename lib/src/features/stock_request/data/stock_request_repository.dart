import '../../../core/models/stock_item_model.dart';
import 'stock_request_service.dart';

class StockRequestRepository {
  final StockRequestService _service;

  StockRequestRepository(this._service);

  Future<List<StockItemModel>> getWarehouseItems(String stopId) async {
    try {
      final data = await _service.fetchWarehouseItems(stopId);
      return data.map((e) => StockItemModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<StockItemModel>> getAllItems() async {
    try {
      final data = await _service.fetchAllItems();
      return data.map((e) => StockItemModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> submitRequest({
    required String stopId,
    required List<StockItemModel> items,
    required bool isUrgent,
  }) async {
    try {
      await _service.submitRequest(
        stopId: stopId,
        items: items.map((e) => e.toJson()).toList(),
        isUrgent: isUrgent,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

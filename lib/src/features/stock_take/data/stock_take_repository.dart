import '../../../core/models/stock_item_model.dart';
import 'stock_take_service.dart';

class StockTakeRepository {
  final StockTakeService _service;

  StockTakeRepository(this._service);

  Future<List<StockItemModel>> getInventoryItems(String stopId) async {
    try {
      final data = await _service.fetchInventoryItems(stopId);
      return data.map((e) => StockItemModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> submitCount({
    required String stopId,
    required List<StockItemModel> items,
  }) async {
    try {
      await _service.submitCount(
        stopId: stopId,
        items: items.map((e) => e.toJson()).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

class StockTakeService {
  final DioClient _dioClient;

  StockTakeService(this._dioClient);

  Future<Map<String, dynamic>> fetchInventoryItems(
    String targetWarehouse,
  ) async {
    final response = await _dioClient.post(
      ApiEndpoints.getMaterialTransferItems,
      data: {'to_warehouse': targetWarehouse},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> submitStockTake({
    required String sourceWarehouse,
    required String customTask,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.createStockTake,
      data: {
        'source_warehouse': sourceWarehouse,
        'custom_task': customTask,
        'items': items,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}

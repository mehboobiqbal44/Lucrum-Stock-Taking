import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

class StockRequestService {
  final DioClient _dioClient;

  StockRequestService(this._dioClient);

  Future<Map<String, dynamic>> fetchWarehouseItems(
    String targetWarehouse,
  ) async {
    final response = await _dioClient.post(
      ApiEndpoints.getMaterialTransferItems,
      data: {'to_warehouse': targetWarehouse},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> fetchAllItems() async {
    final response = await _dioClient.post(ApiEndpoints.getAllItems);
    return response.data['message'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> submitRequest({
    required String sourceWarehouse,
    required String targetWarehouse,
    required String customTask,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.createStockRequest,
      data: {
        'source_warehouse': sourceWarehouse,
        'target_warehouse': targetWarehouse,
        'custom_task': customTask,
        'items': items,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}

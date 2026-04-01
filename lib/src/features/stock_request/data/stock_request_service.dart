import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

class StockRequestService {
  final DioClient _dioClient;

  StockRequestService(this._dioClient);

  Future<List<Map<String, dynamic>>> fetchWarehouseItems(
    String stopId,
  ) async {
    final response = await _dioClient.get(
      ApiEndpoints.stockItems,
      queryParams: {'stop_id': stopId},
    );
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<List<Map<String, dynamic>>> fetchAllItems() async {
    final response = await _dioClient.get(ApiEndpoints.stockItems);
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<void> submitRequest({
    required String stopId,
    required List<Map<String, dynamic>> items,
    required bool isUrgent,
  }) async {
    await _dioClient.post(
      ApiEndpoints.stockRequest,
      data: {
        'stop_id': stopId,
        'items': items,
        'is_urgent': isUrgent,
      },
    );
  }
}

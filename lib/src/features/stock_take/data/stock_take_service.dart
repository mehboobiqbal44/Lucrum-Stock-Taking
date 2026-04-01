import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

class StockTakeService {
  final DioClient _dioClient;

  StockTakeService(this._dioClient);

  Future<List<Map<String, dynamic>>> fetchInventoryItems(
    String stopId,
  ) async {
    final response = await _dioClient.get(
      ApiEndpoints.stockTake,
      queryParams: {'stop_id': stopId},
    );
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<void> submitCount({
    required String stopId,
    required List<Map<String, dynamic>> items,
  }) async {
    await _dioClient.post(
      ApiEndpoints.stockTake,
      data: {'stop_id': stopId, 'items': items},
    );
  }
}

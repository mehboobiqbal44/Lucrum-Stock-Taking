import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

class CheckinService {
  final DioClient _dioClient;

  CheckinService(this._dioClient);

  Future<Map<String, dynamic>> performCheckin({
    required String stopId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.checkin,
      data: {
        'stop_id': stopId,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}

import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

class RoutesService {
  final DioClient _dioClient;

  RoutesService(this._dioClient);

  Future<Map<String, dynamic>> fetchTaskDetails(String employeeId) async {
    final response = await _dioClient.post(
      ApiEndpoints.getTaskDetails,
      data: {'employee_id': employeeId},
    );
    return response.data as Map<String, dynamic>;
  }
}

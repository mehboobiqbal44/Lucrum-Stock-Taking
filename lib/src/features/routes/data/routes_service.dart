import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

class RoutesService {
  final DioClient _dioClient;

  RoutesService(this._dioClient);

  Future<List<Map<String, dynamic>>> fetchRoutes() async {
    final response = await _dioClient.get(ApiEndpoints.routes);
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<Map<String, dynamic>> fetchRouteDetail(String routeId) async {
    final response = await _dioClient.get('${ApiEndpoints.routes}/$routeId');
    return response.data as Map<String, dynamic>;
  }
}

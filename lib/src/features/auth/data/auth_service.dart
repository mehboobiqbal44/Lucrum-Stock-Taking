import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dioClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _dioClient.post(ApiEndpoints.logout);
  }
}

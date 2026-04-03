import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/models/user_model.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  Future<LoginResponse> login(String email, String password) async {
    final response = await _dioClient.post(
      '${ApiEndpoints.loginBaseUrl}${ApiEndpoints.login}',
      data: {'email': email, 'password': password},
    );
    return LoginResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

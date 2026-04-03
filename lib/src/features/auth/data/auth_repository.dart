import '../../../core/models/user_model.dart';
import 'auth_service.dart';

class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);

  Future<LoginResponse> login(String email, String password) async {
    return await _service.login(email, password);
  }

  Future<void> logout() async {
    // Logout is handled locally by clearing token and user state
  }
}

import 'auth_service.dart';

class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);

  Future<bool> login(String email, String password) async {
    try {
      await _service.login(email, password);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _service.logout();
    } catch (_) {
      // Handle silently
    }
  }
}

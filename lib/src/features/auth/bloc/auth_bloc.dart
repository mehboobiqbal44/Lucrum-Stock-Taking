import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/current_user.dart';
import '../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;
  final DioClient _dioClient;

  AuthBloc({
    required AuthRepository repository,
    required DioClient dioClient,
  })  : _repository = repository,
        _dioClient = dioClient,
        super(AuthCheckingSession()) {
    on<CheckSavedSession>(_onCheckSavedSession);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckSavedSession(
    CheckSavedSession event,
    Emitter<AuthState> emit,
  ) async {
    final restored = await CurrentUser.instance.restoreSession();
    if (restored && CurrentUser.instance.isLoggedIn) {
      final response = CurrentUser.instance.loginResponse!;
      _dioClient.setAuthToken(response.apiCredentials.token);
      emit(AuthAuthenticated(response));
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final loginResponse =
          await _repository.login(event.email, event.password);

      if (!loginResponse.success) {
        emit(AuthError(loginResponse.message));
        return;
      }

      CurrentUser.instance.setUser(loginResponse);
      await CurrentUser.instance.saveSession();

      _dioClient.setAuthToken(loginResponse.apiCredentials.token);

      emit(AuthAuthenticated(loginResponse));
    } catch (e) {
      String errorMessage = 'Login failed. Please try again.';
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('401') ||
          e.toString().contains('403')) {
        errorMessage = 'Invalid email or password.';
      }
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await CurrentUser.instance.clearSession();
    _dioClient.clearAuthToken();
    emit(AuthInitial());
  }
}

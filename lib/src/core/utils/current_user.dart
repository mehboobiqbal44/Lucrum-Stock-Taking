import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class CurrentUser {
  CurrentUser._internal();

  static final CurrentUser _instance = CurrentUser._internal();

  factory CurrentUser() => _instance;

  static CurrentUser get instance => _instance;

  static const _storageKey = 'lucrum_login_session';

  LoginResponse? _loginResponse;

  void setUser(LoginResponse response) {
    _loginResponse = response;
  }

  void clear() {
    _loginResponse = null;
  }

  Future<void> saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final response = _loginResponse;
    if (response == null) {
      await prefs.remove(_storageKey);
      return;
    }
    await prefs.setString(_storageKey, jsonEncode(response.toJson()));
  }

  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return false;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _loginResponse = LoginResponse.fromStoredJson(map);
      return true;
    } catch (_) {
      await prefs.remove(_storageKey);
      return false;
    }
  }

  Future<void> clearSession() async {
    _loginResponse = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  LoginResponse? get loginResponse => _loginResponse;

  UserData? get user => _loginResponse?.user;

  ApiCredentials? get credentials => _loginResponse?.apiCredentials;

  EmployeeData? get employee => _loginResponse?.employee;

  bool get isLoggedIn => _loginResponse != null;

  String get fullName => user?.fullName ?? '';

  String get firstName => user?.firstName ?? '';

  String get lastName => user?.lastName ?? '';

  String get email => user?.email ?? '';

  String get employeeId => employee?.name ?? '';

  String get employeeName => employee?.employeeName ?? '';

  String? get userImage => user?.userImage;

  String? get phone => user?.phone;

  String? get mobileNo => user?.mobileNo;

  String? get gender => user?.gender;

  String get userType => user?.userType ?? '';

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  String get authToken => credentials?.token ?? '';
}

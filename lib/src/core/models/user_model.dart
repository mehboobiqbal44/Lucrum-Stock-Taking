class LoginResponse {
  final bool success;
  final String message;
  final UserData user;
  final ApiCredentials apiCredentials;
  final EmployeeData? employee;

  const LoginResponse({
    required this.success,
    required this.message,
    required this.user,
    required this.apiCredentials,
    this.employee,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final msg = json['message'] as Map<String, dynamic>;
    return LoginResponse(
      success: msg['success'] as bool? ?? false,
      message: msg['message'] as String? ?? '',
      user: UserData.fromJson(msg['user'] as Map<String, dynamic>),
      apiCredentials:
          ApiCredentials.fromJson(msg['api_credentials'] as Map<String, dynamic>),
      employee: msg['employee'] != null
          ? EmployeeData.fromJson(msg['employee'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Restore from persisted JSON (flat shape, not API envelope).
  factory LoginResponse.fromStoredJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: true,
      message: '',
      user: UserData.fromJson(json['user'] as Map<String, dynamic>),
      apiCredentials:
          ApiCredentials.fromJson(json['api_credentials'] as Map<String, dynamic>),
      employee: json['employee'] != null
          ? EmployeeData.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'api_credentials': apiCredentials.toJson(),
        if (employee != null) 'employee': employee!.toJson(),
      };
}

class UserData {
  final String name;
  final int enabled;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? customer;
  final String language;
  final String timeZone;
  final String? userImage;
  final String? gender;
  final String? phone;
  final String? mobileNo;
  final String userType;

  const UserData({
    required this.name,
    required this.enabled,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.customer,
    required this.language,
    required this.timeZone,
    this.userImage,
    this.gender,
    this.phone,
    this.mobileNo,
    required this.userType,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      name: json['name'] as String? ?? '',
      enabled: json['enabled'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      customer: json['customer'] as String?,
      language: json['language'] as String? ?? 'en',
      timeZone: json['time_zone'] as String? ?? '',
      userImage: json['user_image'] as String?,
      gender: json['gender'] as String?,
      phone: json['phone'] as String?,
      mobileNo: json['mobile_no'] as String?,
      userType: json['user_type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'enabled': enabled,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'full_name': fullName,
        'customer': customer,
        'language': language,
        'time_zone': timeZone,
        'user_image': userImage,
        'gender': gender,
        'phone': phone,
        'mobile_no': mobileNo,
        'user_type': userType,
      };
}

class ApiCredentials {
  final String apiKey;
  final String apiSecret;

  const ApiCredentials({
    required this.apiKey,
    required this.apiSecret,
  });

  factory ApiCredentials.fromJson(Map<String, dynamic> json) {
    return ApiCredentials(
      apiKey: json['api_key'] as String? ?? '',
      apiSecret: json['api_secret'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'api_key': apiKey,
        'api_secret': apiSecret,
      };

  String get token => '$apiKey:$apiSecret';
}

class EmployeeData {
  final String name;
  final String employeeName;

  const EmployeeData({
    required this.name,
    required this.employeeName,
  });

  factory EmployeeData.fromJson(Map<String, dynamic> json) {
    return EmployeeData(
      name: json['name'] as String? ?? '',
      employeeName: json['employee_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'employee_name': employeeName,
      };
}

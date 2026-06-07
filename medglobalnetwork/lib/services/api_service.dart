import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';

class ApiService {
  String? _token;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<({String token, UserModel user})> register({
    required String firebaseUid,
    required String phoneNumber,
    String? email,
    String? displayName,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}'),
      headers: _headers,
      body: jsonEncode({
        'firebase_uid': firebaseUid,
        'phone_number': phoneNumber,
        if (email != null) 'email': email,
        if (displayName != null) 'display_name': displayName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (
      token: data['token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<({String token, UserModel user})> login({
    required String firebaseUid,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
      headers: _headers,
      body: jsonEncode({'firebase_uid': firebaseUid}),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (
      token: data['token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<UserModel> getProfile() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profileEndpoint}'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    return UserModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<UserModel> updateProfile({
    String? displayName,
    String? email,
    String? profileImageUrl,
    bool? biometricEnabled,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profileEndpoint}'),
      headers: _headers,
      body: jsonEncode({
        if (displayName != null) 'display_name': displayName,
        if (email != null) 'email': email,
        if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
        if (biometricEnabled != null) 'biometric_enabled': biometricEnabled,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    return UserModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<({String token, UserModel user})> googleAuth({
    required String firebaseUid,
    required String email,
    required String displayName,
    required String profileImageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/google'),
      headers: _headers,
      body: jsonEncode({
        'firebase_uid': firebaseUid,
        'email': email,
        'display_name': displayName,
        'profile_image_url': profileImageUrl,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (
      token: data['token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  String _parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is String) return data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {}
    return 'Request failed (${response.statusCode})';
  }
}

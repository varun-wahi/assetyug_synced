import 'package:asset_yug_debugging/config/secrets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class AuthRepositoryImpl {
  Future<String> _getMobileId() async {
    final box = await Hive.openBox('auth');
    return box.get('mobileId', defaultValue: 'UNKNOWN_MOBILE_ID');
  }

  Future<Map<String, String>> _getHeaders() async {
    final mobileId = await _getMobileId();
    return {
      'Content-Type': 'application/json',
      'mobile-id': mobileId,
    };
  }

  Future<dynamic> getLoginToken(String email, String password) async {
    final headers = await _getHeaders();
    final deviceId = await _getMobileId();
    final url = '${ApiConfig.baseUrl}customer/getLoginToken';

    print("[AuthRepositoryImpl] POST URL: $url");
    print("[AuthRepositoryImpl] Headers: $headers");

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode({
        'deviceId': deviceId,
        'email': email,
        'password': password,
      }),
    );

    print("[AuthRepositoryImpl] Status Code: ${response.statusCode}");
    print("[AuthRepositoryImpl] Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = await Hive.openBox('auth');

      if (responseData != null && responseData["token"] != null) {
        box.put('auth_token', responseData["token"]);
        box.put('role', responseData["role"]);
        print("Token: ${box.get('auth_token')}");
        print("Role: ${box.get('role')}");
      }
      print("Token saved successfully");

      return responseData;
    } else {
      print("Error Status Code: ${response.statusCode}, Body: ${response.body}");
      throw Exception('Failed to login');
    }
  }

  Future<void> register(Map<String, dynamic> formData) async {
    final headers = await _getHeaders();
    final url = '${ApiConfig.baseUrl}customer/addCustomer';

    print("[AuthRepositoryImpl] POST URL: $url");
    print("[AuthRepositoryImpl] Headers: $headers");

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(formData),
    );

    print("[AuthRepositoryImpl] Status Code: ${response.statusCode}");
    print("[AuthRepositoryImpl] Response Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to register');
    }
  }

  Future<void> addCompanyInformation(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final url = '${ApiConfig.baseUrl}customer/addCompanyInformation';

    print("[AuthRepositoryImpl] POST URL: $url");
    print("[AuthRepositoryImpl] Headers: $headers");

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(data),
    );

    print("[AuthRepositoryImpl] Status Code: ${response.statusCode}");
    print("[AuthRepositoryImpl] Response Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to add company information');
    }
  }
}

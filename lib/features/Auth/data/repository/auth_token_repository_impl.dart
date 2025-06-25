import 'dart:convert';
import 'package:asset_yug_debugging/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class AuthTokenRepositoryImpl {
  String? _mobileId;
  String? _authToken;
  bool _isInitialized = false;

  AuthTokenRepositoryImpl();

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      final box = await Hive.openBox('auth_data');
      _mobileId = box.get('mobileId', defaultValue: 'UNKNOWN_MOBILE_ID');
      _authToken = box.get('auth_token', defaultValue: 'UNKNOWN_AUTH_TOKEN');
      _isInitialized = true;
    }
  }

  Future<String?> getAuthToken() async {
    var box = await Hive.openBox('auth_data');
    return box.get('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    await _ensureInitialized();
    
    if (_mobileId == null || _mobileId!.isEmpty || _mobileId == 'UNKNOWN_MOBILE_ID') {
      final box = await Hive.openBox('auth_data');
      String? token = await getAuthToken();
      return {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $token',
        'mobile-id': box.get('mobileId', defaultValue: 'UNKNOWN_MOBILE_ID'),
      };
    } else {
      return {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $_authToken',
        'mobile-id': _mobileId!,
      };
    }
  }

  Future<Map<String, String>> _getBasicHeaders() async {
    await _ensureInitialized();
    
    if (_mobileId == null || _mobileId!.isEmpty || _mobileId == 'UNKNOWN_MOBILE_ID') {
      final box = await Hive.openBox('auth_data');
      String? token = await getAuthToken();
      return {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $token',
        // 'mobile-id': box.get('mobileId', defaultValue: 'UNKNOWN_MOBILE_ID'),
      };
    } else {
      return {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $_authToken',
        // 'mobile-id': _mobileId,
      };
    }
  }

  Future<dynamic> isSameDevice(String email, String deviceId) async {
    final headers = await _getBasicHeaders();
    print(headers);
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}customer/isSameDevice'),
      headers: headers,
      body: json.encode({'userId': email, 'mobileId': deviceId, 'userAgent': deviceId}),
    );
    // print('${ApiConfig.baseUrl}customer/isSameDevice') ;
    // print("ERRORR  "+ response.statusCode.toString() + " " + response.body);
    // print({'userId': email, 'mobileId': deviceId, 'userAgent': deviceId});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to check if same browser and device');
    }
  }

  Future<dynamic> loginToken(String email) async {
    final headers = await _getBasicHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}customer/getLoginToken/$email'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get login token');
    }
  }

  Future<dynamic> getCompanyId(String email) async {
    final headers = await _getBasicHeaders();
    final url = '${ApiConfig.baseUrl}customer/getCompanyId/$email';
    print("URL: $url");
    print("HEADERS: $headers");

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    print("RESPONSE BODY: ${response.body}");
    print("STATUS CODE: ${response.statusCode}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get company ID');
    }
  }

  Future<dynamic> getAccountInfo(String email) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}customer/accountInfo/$email'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get account info');
    }
  }

  Future<void> updateAccountInfo(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}customer/accountInfo/update'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update account info');
    }
  }

  Future<void> addLoggedInMobile({
    required String userId,
    required String userAgent,
  }) async {
    final headers = await _getHeaders();
    final body = json.encode({
      'userId': userId,
      'mobileId': _mobileId,
      'userAgent': userAgent,
    });

    print('addLoggedInMobile - URL: ${ApiConfig.baseUrl}customer/addLoggedInMobile');
    print('addLoggedInMobile - Headers: $headers');
    print('addLoggedInMobile - Body: $body');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}customer/addLoggedInMobile'),
      headers: headers,
      body: body,
    );

    print('addLoggedInMobile - Status Code: ${response.statusCode}');
    print('addLoggedInMobile - Response Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to add logged in mobile session');
    }
  }

  Future<void> removeSession(String userId) async {
    final headers = await _getHeaders();
    final url = '${ApiConfig.baseUrl}customer/removeSession/$userId';
    print('removeSession - URL: $url');
    print('removeSession - Headers: $headers');

    final response = await http.delete(
      Uri.parse(url),
      headers: headers,
    );

    print('removeSession - Status Code: ${response.statusCode}');
    print('removeSession - Response Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to remove session');
    }
  }
}
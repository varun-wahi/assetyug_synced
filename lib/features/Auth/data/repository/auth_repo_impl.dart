// data/repository/auth_repository_impl.dart
import 'package:asset_yug_debugging/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final http.Client httpClient;

  AuthRepositoryImpl({
    required this.httpClient,
  });

  @override
  Future<dynamic> login(String email, String deviceId) async {
    final response = await httpClient.get(Uri.parse('${ApiConfig.baseUrl}customer/getLoginToken/$email/$deviceId'));

    if (response.statusCode == 200) {
      print("HEREEEE");
      print(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  @override
  Future<void> register(Map<String, dynamic> formData) async {
    final response = await httpClient.post(
      Uri.parse('${ApiConfig.baseUrl}customer/addCustomer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(formData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to register');
    }
  }


  Future<bool> isSameBrowserAndDevice(Map<String, dynamic> payload) async {
    final response = await httpClient.post(
      Uri.parse('${ApiConfig.baseUrl}customer/isSameBrowserAndDevice'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    print("HERE IN isSameBrowser: RESPONSE: ${response.body}");
    if (response.statusCode == 200) {
      return json.decode(response.body) as bool;
    } else {
      throw Exception('Failed to check if the browser and device are the same');
    }
  }

  @override
  Future<void> addCompanyInformation(Map<String, dynamic> data) async {
    final response = await httpClient.post(
      Uri.parse('${ApiConfig.baseUrl}customer/addCompanyInformation'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add company information');
    }
  }
}



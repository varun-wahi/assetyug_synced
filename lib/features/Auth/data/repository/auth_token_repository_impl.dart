import 'package:asset_yug_debugging/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthTokenRepositoryImpl {
  final http.Client httpClient;

  AuthTokenRepositoryImpl({required this.httpClient});

  Future<dynamic> loginToken(String email) async {
    final response = await httpClient.get(Uri.parse('${ApiConfig.baseUrl}customer/getLoginToken/$email'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get login token');
    }
  }

  Future<dynamic> getCompanyId(String email) async {
    final response = await httpClient.get(Uri.parse('${ApiConfig.baseUrl}customer/getCompanyId/$email'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get company ID');
    }
  }

  Future<dynamic> getAccountInfo(String email) async {
    final response = await httpClient.get(Uri.parse('${ApiConfig.baseUrl}customer/accountInfo/$email'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get account info');
    }
  }

  Future<void> updateAccountInfo(Map<String, dynamic> data) async {
    final response = await httpClient.post(
      Uri.parse('${ApiConfig.baseUrl}customer/accountInfo/update'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update account info');
    }
  }
}

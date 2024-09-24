import 'dart:convert';
import 'package:asset_yug_debugging/config/api_config.dart';
import 'package:asset_yug_debugging/features/Assets/domain/repository/auth_module_repo.dart';
import 'package:http/http.dart' as http;

class AssetModuleRepositoryImpl implements AssetModuleRepository {
  final http.Client httpClient;

  AssetModuleRepositoryImpl({required this.httpClient});

  Map<String, String> get headers => {
    'Authorization': 'Bearer ${yourAuthTokenStorageFunction()}',
    'Content-Type': 'application/json',
  };

  @override
  Future<dynamic> addExtraFields(Map<String, dynamic> data) async {
    final response = await httpClient.post(
      Uri.parse('${ApiConfig.baseUrl}assets/addExtraFieldName'),
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  @override
  Future<dynamic> getExtraFields(String id) async {
    final response = await httpClient.get(
      Uri.parse('${ApiConfig.baseUrl}assets/getExtraFieldName/$id'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  @override
  Future<void> removeExtraField(String id) async {
    final response = await httpClient.delete(
      Uri.parse('${ApiConfig.baseUrl}assets/deleteExtraFieldName/$id'),
      headers: headers,
    );
    _handleResponse(response);
  }

  @override
  Future<dynamic> mandatoryFields(Map<String, dynamic> data) async {
    final response = await httpClient.post(
      Uri.parse('${ApiConfig.baseUrl}assets/mandatoryFields'),
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  @override
  Future<dynamic> showFields(Map<String, dynamic> data) async {
    final response = await httpClient.post(
      Uri.parse('${ApiConfig.baseUrl}assets/showFields'),
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  @override
  Future<dynamic> getMandatoryFields(String name, String email) async {
    final response = await httpClient.get(
      Uri.parse('${ApiConfig.baseUrl}assets/getMandatoryFields/$name/$email'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  @override
  Future<dynamic> getShowFields(String name, String email) async {
    final response = await httpClient.get(
      Uri.parse('${ApiConfig.baseUrl}assets/getShowFields/$name/$email'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  @override
  Future<dynamic> getAllMandatoryFields(String email) async {
    final response = await httpClient.get(
      Uri.parse('${ApiConfig.baseUrl}assets/getAllMandatoryFields/$email'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  @override
  Future<dynamic> getAllShowFields(String email) async {
    final response = await httpClient.get(
      Uri.parse('${ApiConfig.baseUrl}assets/getAllShowFields/$email'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  @override
  Future<void> deleteShowAndMandatoryFields(String name, String email) async {
    final response = await httpClient.delete(
      Uri.parse('${ApiConfig.baseUrl}assets/deleteShowAndMandatoryField/$name/$email'),
      headers: headers,
    );
    _handleResponse(response);
    
    }

  }

  // Helper function to handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  // Replace this with your own implementation of getting the auth token
  String yourAuthTokenStorageFunction() {
    // Implement this method to retrieve the auth token from secure storage or any other storage
    
    return 'your-auth-token';
  }


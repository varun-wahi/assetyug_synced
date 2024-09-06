import 'dart:convert';
import 'dart:io';
import 'package:asset_yug_debugging/config/api_config.dart';
import 'package:http/http.dart' as http;


class CompanyCustomerDetailsPreviewService {
  final String _authToken = 'your_auth_token'; // Replace with your token management

  // Base URLs for endpoints
  final String _companyCustomerEndpoint = '${ApiConfig.baseUrl}companycustomer/';
  final String _assetEndpoint = '${ApiConfig.baseUrl}assets/';
  final String _customerEndpoint = '${ApiConfig.baseUrl}customer/';
  final String _workorderEndpoint = '${ApiConfig.baseUrl}workorder/';

  // Utility to get common headers
  Map<String, String> _getHeaders([bool excludeContentType = false]) {
    final headers = {
      'Authorization': 'Bearer $_authToken',
      'Content-Type': excludeContentType ? '' : 'application/json',
    };
    return headers..removeWhere((key, value) => value.isEmpty);
  }

  Future<http.Response> updateCompanyCustomer(Map<String, dynamic> data) async {
    final url = Uri.parse('${_companyCustomerEndpoint}updateCompanyCustomer');
    return http.put(url, headers: _getHeaders(), body: json.encode(data));
  }

  Future<http.Response> getCompanyCustomer(String id) async {
    final url = Uri.parse('${_companyCustomerEndpoint}getCompanyCustomer/$id');
    return http.get(url, headers: _getHeaders());
  }

  Future<http.Response> addExtraFields(Map<String, dynamic> data) async {
    final url = Uri.parse('${_companyCustomerEndpoint}addfields');
    return http.post(url, headers: _getHeaders(), body: json.encode(data));
  }

  Future<http.Response> getExtraFields(String id) async {
    final url = Uri.parse('${_companyCustomerEndpoint}getExtraFields/$id');
    return http.get(url, headers: _getHeaders());
  }

  Future<http.Response> removeAsset(String id) async {
    final url = Uri.parse('${_companyCustomerEndpoint}deleteCompanyCustomer');
    return http.post(url, headers: _getHeaders(), body: json.encode(id));
  }

  Future<http.Response> getExtraFieldName(String id) async {
    final url = Uri.parse('${_companyCustomerEndpoint}getExtraFieldName/$id');
    return http.get(url, headers: _getHeaders());
  }

  Future<http.Response> getMandatoryFields(String name, String companyId) async {
    final url = Uri.parse('${_companyCustomerEndpoint}getMandatoryFields/$name/$companyId');
    return http.get(url, headers: _getHeaders());
  }

  Future<http.Response> getShowFields(String name, String companyId) async {
    final url = Uri.parse('${_companyCustomerEndpoint}getShowFields/$name/$companyId');
    return http.get(url, headers: _getHeaders());
  }

  Future<http.Response> getAllMandatoryFields(String companyId) async {
    final url = Uri.parse('${_companyCustomerEndpoint}getAllMandatoryFields/$companyId');
    return http.get(url, headers: _getHeaders());
  }

  Future<http.Response> getAllShowFields(String companyId) async {
    final url = Uri.parse('${_companyCustomerEndpoint}getAllShowFields/$companyId');
    return http.get(url, headers: _getHeaders());
  }

  Future<void> addCompanyCustomerFile(File file, String companyId) async {
    final url = Uri.parse('${_companyCustomerEndpoint}addFile/$companyId');
    var request = http.MultipartRequest('POST', url)
      ..headers.addAll(_getHeaders(true))
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    
    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('File upload failed with status code ${response.statusCode}');
    }
  }

  Future<void> download(String id, String savePath) async {
    final url = Uri.parse('${_companyCustomerEndpoint}getFile/download/$id');
    final response = await http.get(url, headers: _getHeaders());
    
    if (response.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to download file with status code ${response.statusCode}');
    }
  }

  Future<void> deleteFile(String id) async {
    final url = Uri.parse('${_companyCustomerEndpoint}deleteFile');
    final response = await http.post(url, headers: _getHeaders(), body: json.encode(id));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete file with status code ${response.statusCode}');
    }
  }

  Future<void> getCompanyCustomerFile(String assetId, String savePath) async {
    final url = Uri.parse('${_companyCustomerEndpoint}getFile/$assetId');
    final response = await http.get(url, headers: _getHeaders());
    
    if (response.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to get file with status code ${response.statusCode}');
    }
  }

  Future<http.Response> getAssetByCustomerId(String customerId, int pageNumber) async {
    final url = Uri.parse('${_assetEndpoint}getByCutomerId/$customerId/$pageNumber');
    return http.get(url, headers: _getHeaders());
  }

  Future<http.Response> getWorkOrderByCustomerId(String customerId) async {
    final url = Uri.parse('${_workorderEndpoint}getWorkOrderListByCustomerId/$customerId');
    return http.get(url, headers: _getHeaders());
  }

  Future<http.Response> getRoleAndPermission(String id, String name) async {
    final url = Uri.parse('${_customerEndpoint}roleAndPermissionByName/get/$id/$name');
    return http.get(url, headers: _getHeaders());
  }
}

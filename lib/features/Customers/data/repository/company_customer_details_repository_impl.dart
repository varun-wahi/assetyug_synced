import 'dart:convert';
import 'package:asset_yug_debugging/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CompanyCustomerDetailsService {
  final String authToken = ''; // Replace with the actual token
  final Map<String, String> headers = {
    // 'Authorization': 'Bearer ${localStorage.getItem('authToken')}', // Implement your own token retrieval
    'Content-Type': 'application/json'
  };
  final String companyCustomerEndpoint = '${ApiConfig.baseUrl}companycustomer/';
  final String customerEndpoint = '${ApiConfig.baseUrl}customer/';
  final String assetEndpoint = '${ApiConfig.baseUrl}assets/';

  // Update Company Customer
  Future<http.Response> updateCompanyCustomer(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$companyCustomerEndpoint/updateCompanyCustomer'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response;
  }

  // Get Company Customer
  Future<http.Response> getCompanyCustomer(String id) async {
    final response = await http.get(
      Uri.parse('$companyCustomerEndpoint/getCompanyCustomer/$id'),
      headers: headers,
    );
    return response;
  }

  // Add Extra Fields
  Future<http.Response> addExtraFields(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$companyCustomerEndpoint/addfields'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response;
  }

  // Get Extra Fields
  Future<http.Response> getExtraFields(String id) async {
    final response = await http.get(
      Uri.parse('$companyCustomerEndpoint/getExtraFields/$id'),
      headers: headers,
    );
    return response;
  }

  // Remove Asset
  Future<http.Response> removeAsset(String id) async {
    final response = await http.post(
      Uri.parse('$companyCustomerEndpoint/deleteCompanyCustomer'),
      headers: headers,
      body: jsonEncode(id),
    );
    return response;
  }

  // Get Extra Field Name
  Future<http.Response> getExtraFieldName(String id) async {
    final response = await http.get(
      Uri.parse('$companyCustomerEndpoint/getExtraFieldName/$id'),
      headers: headers,
    );
    return response;
  }

  // Get Mandatory Fields
  Future<http.Response> getMandatoryFields(String name, String companyId) async {
    final response = await http.get(
      Uri.parse('$companyCustomerEndpoint/getMandatoryFields/$name/$companyId'),
      headers: headers,
    );
    return response;
  }

  // Get Show Fields
  Future<http.Response> getShowFields(String name, String companyId) async {
    final response = await http.get(
      Uri.parse('$companyCustomerEndpoint/getShowFields/$name/$companyId'),
      headers: headers,
    );
    return response;
  }

  // Get All Mandatory Fields
  Future<http.Response> getAllMandatoryFields(String companyId) async {
    final response = await http.get(
      Uri.parse('$companyCustomerEndpoint/getAllMandatoryFields/$companyId'),
      headers: headers,
    );
    return response;
  }

  // Get All Show Fields
  Future<http.Response> getAllShowFields(String companyId) async {
    final response = await http.get(
      Uri.parse('$companyCustomerEndpoint/getAllShowFields/$companyId'),
      headers: headers,
    );
    return response;
  }

  // Add Company Customer File
  Future<http.StreamedResponse> addCompanyCustomerFile(http.MultipartFile file, String companyId) async {
    final uri = Uri.parse('$companyCustomerEndpoint/addFile/$companyId');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(file);

    final response = await request.send();
    return response;
  }

  // Download File
  Future<http.Response> download(String id) async {
    final response = await http.get(
      Uri.parse('$companyCustomerEndpoint/getFile/download/$id'),
      headers: headers,
    );
    return response;
  }

  // Delete File
  Future<http.Response> deleteFile(String id) async {
    final response = await http.post(
      Uri.parse('$companyCustomerEndpoint/deleteFile/$id'),
      headers: headers,
    );
    return response;
  }

  // Get Company Customer File
  Future<http.Response> getCompanyCustomerFile(String assetId) async {
    final response = await http.get(
      Uri.parse('$companyCustomerEndpoint/getFile/$assetId'),
      headers: headers,
    );
    return response;
  }

  // Get Asset By Customer ID
  Future<http.Response> getAssetByCustomerId(String customerId, int pageNumber) async {
    final response = await http.get(
      Uri.parse('$assetEndpoint/getByCutomerId/$customerId/$pageNumber'),
      headers: headers,
    );
    return response;
  }

  // Get Work Order By Customer ID
  Future<http.Response> getWorkOrderByCustomerId(String customerId) async {
    final response = await http.get(
      Uri.parse('http://localhost:8083/workorder/getWorkOrderListByCustomerId/$customerId'),
      headers: headers,
    );
    return response;
  }

  // Delete Company Customer
  Future<http.Response> deleteCompanyCustomer(String id) async {
    final response = await http.delete(
      Uri.parse('$companyCustomerEndpoint/deleteCompanyCustomer/$id'),
      headers: headers,
    );
    return response;
  }

  // Close Work Orders
  Future<http.Response> closeWorkOrders(String id) async {
    final response = await http.post(
      Uri.parse('http://localhost:8083/workorder/updateWorkOrdersWithClosed'),
      headers: headers,
      body: jsonEncode(id),
    );
    return response;
  }

  // Inactive Assets
  Future<http.Response> inActiveAssets(String id) async {
    final response = await http.post(
      Uri.parse('$assetEndpoint/updateAssetsWithInActive'),
      headers: headers,
      body: jsonEncode(id),
    );
    return response;
  }

  // Get Role And Permission
  Future<http.Response> getRoleAndPermission(String id, String name) async {
    final response = await http.get(
      Uri.parse('$customerEndpoint/roleAndPermissionByName/get/$id/$name'),
      headers: headers,
    );
    return response;
  }

  // Advance Filter
  Future<http.Response> advanceFilter(Map<String, dynamic> data, int pageIndex, int pageSize, String category) async {
    final response = await http.post(
      Uri.parse('$assetEndpoint/advanceFilter/$pageIndex/$pageSize?category=$category'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response;
  }
}

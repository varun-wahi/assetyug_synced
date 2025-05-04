import 'dart:convert';
import 'dart:io';
import 'package:asset_yug_debugging/config/api_config.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class CompanyCustomerDetailsService {
  final String companyCustomerEndpoint = '${ApiConfig.baseUrl}companycustomer/';
  final String customerEndpoint = '${ApiConfig.baseUrl}customer/';
  final String assetEndpoint = '${ApiConfig.baseUrl}assets/';

  // Function to get the auth token from Hive
  Future<String?> getAuthToken() async {
    var box = await Hive.openBox('auth_data');
    return box.get('auth_token');
  }

  // Asynchronous headers getter
  Future<Map<String, String>> getHeaders() async {
    String? token = await getAuthToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Update Company Customer
  Future<http.Response> updateCompanyCustomer(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$companyCustomerEndpoint/updateCompanyCustomer'),
      headers: await getHeaders(),
      body: jsonEncode(data),
    );
    return response;
  }

  // Get Company Customer
  Future<http.Response> getCompanyCustomer(String id) async {
    final response = await http.get(
      Uri.parse('$companyCustomerEndpoint/getCompanyCustomer/$id'),
      headers: await getHeaders(),
    );
    return response;
  }

  // Add Extra Fields
  Future<http.Response> addExtraFields(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$companyCustomerEndpoint/addfields'),
      headers: await getHeaders(),
      body: jsonEncode(data),
    );
    return response;
  }

  // Get Extra Fields
  Future<http.Response> getExtraFields(String id) async {
    final response = await http.get(
      Uri.parse('$companyCustomerEndpoint/getExtraFields/$id'),
      headers: await getHeaders(),
    );
    return response;
  }

  // Remove Asset
  Future<http.Response> removeAsset(String id) async {
    final response = await http.post(
      Uri.parse('$companyCustomerEndpoint/deleteCompanyCustomer'),
      headers: await getHeaders(),
      body: jsonEncode(id),
    );
    return response;
  }

  // Get Extra Field Name
  Future<http.Response> getExtraFieldName(String id) async {
    final response = await http.get(
      Uri.parse('$companyCustomerEndpoint/getExtraFieldName/$id'),
      headers: await getHeaders(),
    );
    return response;
  }

  // Get Mandatory Fields
  Future<http.Response> getMandatoryFields(
      String name, String companyId) async {
    final response = await http.get(
      Uri.parse('$companyCustomerEndpoint/getMandatoryFields/$name/$companyId'),
      headers: await getHeaders(),
    );
    return response;
  }

  // Get Show Fields
  Future<http.Response> getShowFields(String name, String companyId) async {
    final response = await http.get(
      Uri.parse('$companyCustomerEndpoint/getShowFields/$name/$companyId'),
      headers: await getHeaders(),
    );
    return response;
  }

  // Get All Mandatory Fields
  Future<http.Response> getAllMandatoryFields(String companyId) async {
    final response = await http.get(
      Uri.parse('$companyCustomerEndpoint/getAllMandatoryFields/$companyId'),
      headers: await getHeaders(),
    );
    return response;
  }

  // Get All Show Fields
  Future<http.Response> getAllShowFields(String companyId) async {
    final response = await http.get(
      Uri.parse('$companyCustomerEndpoint/getAllShowFields/$companyId'),
      headers: await getHeaders(),
    );
    return response;
  }

  // Add Company Customer File
  Future<http.StreamedResponse> addCompanyCustomerFile(
      File file, String customerId) async {
    // final uri = Uri.parse('$companyCustomerEndpoint/addFile/$customerId');
    // final request = http.MultipartRequest('POST', uri)
    //   ..headers.addAll(headers)
    //   ..headers.remove('Content-Type')
    //   ..files.add(file);

    // final response = await request.send();
    // return response;

    final url = Uri.parse('${companyCustomerEndpoint}addFile/$customerId');

    var myHeaders = await getHeaders();
    myHeaders.remove('Content-Type');
    print("headers: $myHeaders");

    var request = http.MultipartRequest('POST', url);
    request.headers.addAll(myHeaders);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    print("request: $request");
    return await request.send();
  }

  // Download File
  Future<http.Response> download(String id) async {
    final response = await http.get(
      Uri.parse('$companyCustomerEndpoint/getFile/download/$id'),
      headers: await getHeaders(),
    );
    return response;
  }

  // Delete File
  Future<http.Response> deleteFile(String id) async {
    final response = await http.post(
      Uri.parse('$companyCustomerEndpoint/deleteFile/$id'),
      headers: await getHeaders(),
    );
    return response;
  }

  // Get Company Customer File
  Future<http.StreamedResponse> getCompanyCustomerFile(
      String customerId) async {
    final url = "${companyCustomerEndpoint}getFile/$customerId";
    final headers = await getHeaders();
    var request = http.Request('GET', Uri.parse(url));
    request.headers.addAll(headers);

    return await http.Client().send(request);
  }

  // Get Asset By Customer ID
  Future<http.Response> getAssetByCustomerId(
      String customerId, int pageNumber) async {
    final response = await http.get(
      Uri.parse('$assetEndpoint/getByCutomerId/$customerId/$pageNumber'),
      headers: await getHeaders(),
    );
    return response;
  }

  // Get Work Order By Customer ID
  Future<http.Response> getWorkOrderByCustomerId(String customerId) async {
    final response = await http.get(
      Uri.parse(
          'http://localhost:8083/workorder/getWorkOrderListByCustomerId/$customerId'),
      headers: await getHeaders(),
    );
    return response;
  }

  // Delete Company Customer
  Future<http.Response> deleteCompanyCustomer(String id) async {
    final response = await http.delete(
      Uri.parse('$companyCustomerEndpoint/deleteCompanyCustomer/$id'),
      headers: await getHeaders(),
    );
    return response;
  }

  // Close Work Orders
  Future<http.Response> closeWorkOrders(String id) async {
    final response = await http.post(
      Uri.parse('http://localhost:8083/workorder/updateWorkOrdersWithClosed'),
      headers: await getHeaders(),
      body: jsonEncode(id),
    );
    return response;
  }

  // Inactive Assets
  Future<http.Response> inActiveAssets(String id) async {
    final response = await http.post(
      Uri.parse('$assetEndpoint/updateAssetsWithInActive'),
      headers: await getHeaders(),
      body: jsonEncode(id),
    );
    return response;
  }

  // Get Role And Permission
  Future<http.Response> getRoleAndPermission(String id, String name) async {
    final response = await http.get(
      Uri.parse('$customerEndpoint/roleAndPermissionByName/get/$id/$name'),
      headers: await getHeaders(),
    );
    return response;
  }

  // Advance Filter
  Future<http.Response> advanceFilter(Map<String, dynamic> data, int pageIndex,
      int pageSize, String category) async {
    final response = await http.post(
      Uri.parse(
          '$assetEndpoint/advanceFilter/$pageIndex/$pageSize?category=$category'),
      headers: await getHeaders(),
      body: jsonEncode(data),
    );
    return response;
  }
}

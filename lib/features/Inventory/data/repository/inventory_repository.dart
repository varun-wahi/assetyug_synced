import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../../../config/secrets.dart';

class InventoryRepository {
  final String inventoryEndpoint = '${ApiConfig.baseUrl}inventory/';
  final String basicEndpoint = '${ApiConfig.baseUrl}api/';

  // Auth token

  // Function to get the auth token from Hive
  Future<String?> getAuthToken() async {
    var box = await Hive.openBox('auth_data');
    return box.get('auth_token');
  }

  Future<String?> getCompanyId() async {
    var box = await Hive.openBox('auth_data');
    return box.get('companyId').toString();
  }

  // Asynchronous headers getter
  Future<Map<String, String>> getHeaders() async {
    final box = await Hive.openBox('auth_data');
    final mobileId = box.get('mobileId', defaultValue: 'UNKNOWN_MOBILE_ID');
    final authToken = box.get('auth_token', defaultValue: 'UNKNOWN_AUTH_TOKEN');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
      'mobile-id': mobileId,
      'Companyid': await getCompanyId() ?? 'UNKNOWN_COMPANY_ID',
    };
  }

  Future<http.Response> addInventoryItem(Map<String, dynamic> data) async {
    data.addAll({'companyId': await getCompanyId() ?? 'UNKNOWN_COMPANY_ID'});
    // final url = Uri.parse('${companyCustomerEndpoint}addCompanyCustomer');
    final url = Uri.parse('${basicEndpoint}addInventory');
    print(url);
    return await http.post(url,
        headers: await getHeaders(), body: jsonEncode(data));
  }

// http://assetyugg.com.s3-website-us-east-1.amazonaws.com/api/getAllInventory/100002
  Future<http.Response> getInventory(String companyId) async {
    final url = Uri.parse('${basicEndpoint}getAllInventory/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

// http://assetyugg.com.s3-website-us-east-1.amazonaws.com/api/getAllInventory/100002
  Future<http.Response> getInventoryWithExtraFields(String companyId) async {
    final url =
        Uri.parse('${basicEndpoint}allInventoryWithExtraFields/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  // Get asset details by ID
  Future<http.Response> getInventoryItemDetails(String id) async {
    final url = "${inventoryEndpoint}getInventoryItemDetails/$id";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> deleteCompanyCustomer(String id) async {
    final url = Uri.parse('${inventoryEndpoint}deleteCompanyCustomer/$id');
    return await http.delete(url, headers: await getHeaders());
  }

  Future<http.Response> getAllMandatoryFields(String companyId) async {
    final url =
        Uri.parse('${inventoryEndpoint}getAllMandatoryFields/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> getAllShowFields(String companyId) async {
    final url = Uri.parse('${inventoryEndpoint}getAllShowFields/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> getExtraFieldName(String id) async {
    final url = Uri.parse('${inventoryEndpoint}getExtraFieldName/$id');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> getExtraFieldNameValue(String companyId) async {
    final url =
        Uri.parse('${inventoryEndpoint}getExtraFieldNameValue/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> addExtraFields(Map<String, dynamic> data) async {
    final url = Uri.parse('${inventoryEndpoint}addfields');
    return await http.post(url,
        headers: await getHeaders(), body: jsonEncode(data));
  }

  Future<http.Response> deleteWorkorderExtraField(String id) async {
    final url =
        Uri.parse('${inventoryEndpoint}deleteCompanyCustomerExtraFields/$id');
    return await http.delete(url, headers: await getHeaders());
  }

  Future<http.Response> getAllCompanyCustomerWithExtraColumn(
      String companyId) async {
    final url = Uri.parse(
        '${inventoryEndpoint}allCompanyCustomerWithExtraFields/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> getRoleAndPermission(String id, String name) async {
    final url =
        Uri.parse('${inventoryEndpoint}roleAndPermissionByName/get/$id/$name');
    return await http.get(url, headers: await getHeaders());
  }

  // Add extra fields
  Future<http.Response> addExtraFieldsWithValue(dynamic data) async {
    final url = "${inventoryEndpoint}addfields";
    var headers = await getHeaders();
    return await http.post(Uri.parse(url), body: data, headers: headers);
  }

  // Add extra fields
  Future<http.Response> addExtraFieldsName(dynamic data) async {
    final url = "${inventoryEndpoint}addExtraFieldName";
    var headers = await getHeaders();
    return await http.post(Uri.parse(url), body: data, headers: headers);
  }

  // Get extra fields
  // NEW API
  Future<http.Response> getExtraFields(String id) async {
    final url = "${inventoryEndpoint}getExtraFields/$id";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> advanceFilter(dynamic data, int pageIndex, int pageSize,
      String category, String searchData,
      {String isAsc = 'true'}) async {
    final url = Uri.parse(
        '${inventoryEndpoint}advanceFilter/$pageIndex/$pageSize?category=$category&search=$searchData&asc=$isAsc');
    print(url);
    print(await getHeaders());
    print(jsonEncode(data));
    return await http.post(url,
        headers: await getHeaders(), body: jsonEncode(data));
  }

  Future<http.Response> working() async {
    final url = Uri.parse('${inventoryEndpoint}working');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> getCategoryList(String companyId) async {
    final url = "${inventoryEndpoint}getCategoryList/$companyId";
    print("URL: $url");
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> getAssetsByCategories(String companyId) async {
    final url = "${inventoryEndpoint}getAssetByCategory/$companyId";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }
}

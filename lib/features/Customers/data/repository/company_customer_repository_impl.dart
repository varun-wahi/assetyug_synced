import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../../../config/api_config.dart';

class CompanyCustomerRepositoryImpl {
  final String companyCustomerEndpoint = '${ApiConfig.baseUrl}companycustomer/';
  final String customerEndpoint = '${ApiConfig.baseUrl}customer/';

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

  Future<http.Response> addCompanyCustomer(Map<String, dynamic> data) async {
    // final url = Uri.parse('${companyCustomerEndpoint}addCompanyCustomer');
    final url = Uri.parse('${companyCustomerEndpoint}addCompanyCustomer');
    return await http.post(url,
        headers: await getHeaders(), body: jsonEncode(data));
  }

  Future<http.Response> getCompanyCustomer(String companyId) async {
    final url =
        Uri.parse('${companyCustomerEndpoint}allCompanyCustomer/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> addLocation(Map<String, dynamic> data) async {
    final url = Uri.parse('${customerEndpoint}addlocation');
    return await http.post(url,
        headers: await getHeaders(), body: jsonEncode(data));
  }

  Future<http.Response> addbin(Map<String, dynamic> data) async {
    final url = Uri.parse('${customerEndpoint}addbin');
    return await http.post(url,
        headers: await getHeaders(), body: jsonEncode(data));
  }

  Future<http.Response> getAllLocations(String companyId) async {
    final url = Uri.parse('${customerEndpoint}getAllLocation/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> getAllBins(String companyId) async {
    final url = Uri.parse('${customerEndpoint}getAllBin/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> getCustomerLocationsAndBins(String companyId) async {
    final url = Uri.parse('${customerEndpoint}locations-with-bins/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  // Get asset details by ID
  Future<http.Response> getCompanyCustomerDetails(String id) async {
    final url = "${companyCustomerEndpoint}getCompanyCustomer/$id";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> deleteCompanyCustomer(String id) async {
    final url =
        Uri.parse('${companyCustomerEndpoint}deleteCompanyCustomer/$id');
    return await http.delete(url, headers: await getHeaders());
  }

  Future<http.Response> getAllMandatoryFields(String companyId) async {
    final url =
        Uri.parse('${companyCustomerEndpoint}getAllMandatoryFields/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> getAllShowFields(String companyId) async {
    final url =
        Uri.parse('${companyCustomerEndpoint}getAllShowFields/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> getExtraFieldName(String id) async {
    final url = Uri.parse('${companyCustomerEndpoint}getExtraFieldName/$id');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> getExtraFieldNameValue(String companyId) async {
    final url = Uri.parse(
        '${companyCustomerEndpoint}getExtraFieldNameValue/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> addExtraFields(Map<String, dynamic> data) async {
    final url = Uri.parse('${companyCustomerEndpoint}addfields');
    return await http.post(url,
        headers: await getHeaders(), body: jsonEncode(data));
  }

  Future<http.Response> deleteWorkorderExtraField(String id) async {
    final url = Uri.parse(
        '${companyCustomerEndpoint}deleteCompanyCustomerExtraFields/$id');
    return await http.delete(url, headers: await getHeaders());
  }

  Future<http.Response> getAllCompanyCustomerWithExtraColumn(
      String companyId) async {
    final url = Uri.parse(
        '${companyCustomerEndpoint}allCompanyCustomerWithExtraFields/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> getRoleAndPermission(String id, String name) async {
    final url =
        Uri.parse('${customerEndpoint}roleAndPermissionByName/get/$id/$name');
    return await http.get(url, headers: await getHeaders());
  }

  // Add extra fields
  Future<http.Response> addExtraFieldsWithValue(dynamic data) async {
    final url = "${companyCustomerEndpoint}addfields";
    var headers = await getHeaders();
    return await http.post(Uri.parse(url), body: data, headers: headers);
  }

  // Add extra fields
  Future<http.Response> addExtraFieldsName(dynamic data) async {
    final url = "${companyCustomerEndpoint}addExtraFieldName";
    var headers = await getHeaders();
    return await http.post(Uri.parse(url), body: data, headers: headers);
  }

  // Get extra fields
  // NEW API
  Future<http.Response> getExtraFields(String id) async {
    final url = "${companyCustomerEndpoint}getExtraFields/$id";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> advanceFilter(dynamic data, int pageIndex, int pageSize,
      String category, String searchData,
      {String isAsc = 'true'}) async {
    final url = Uri.parse(
        '${companyCustomerEndpoint}advanceFilter/$pageIndex/$pageSize?category=$category&search=$searchData&asc=$isAsc');
    print(url);
    print(await getHeaders());
    print(jsonEncode(data));
    return await http.post(url,
        headers: await getHeaders(), body: jsonEncode(data));
  }

  Future<http.Response> working() async {
    final url = Uri.parse('${companyCustomerEndpoint}working');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> getCategoryList(String companyId) async {
    final url = "${companyCustomerEndpoint}getCategoryList/$companyId";
    print("URL: $url");
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> getAssetsByCategories(String companyId) async {
    final url = "${companyCustomerEndpoint}getAssetByCategory/$companyId";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> getActiveCategories(String companyId) async {
    final url = "${companyCustomerEndpoint}getCategoryActiveList/$companyId";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> statelist() async {
    final url = "${companyCustomerEndpoint}statelist";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> deleteLocation(String id) async {
    final url = Uri.parse('${customerEndpoint}deleteLocation/$id');
    return await http.delete(url, headers: await getHeaders());
  }

  Future<http.Response> deleteBin(String id) async {
    final url = Uri.parse('${customerEndpoint}deleteBin/$id');
    final res = await http.delete(url, headers: await getHeaders());
    return res;
  }
}

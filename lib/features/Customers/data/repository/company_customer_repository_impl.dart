import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class CompanyCustomerRepositoryImpl {
  final String companyCustomerEndpoint = 'http://assetyug-lb-632006544.us-east-1.elb.amazonaws.com:8080/companycustomer/';
  final String customerEndpoint = 'http://assetyug-lb-632006544.us-east-1.elb.amazonaws.com:8080/customer/';
  
  // Auth token
  
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
  } // Replace with your actual auth token retrieval logic


  Future<http.Response> addCompanyCustomer(Map<String, dynamic> data) async {
    // final url = Uri.parse('${companyCustomerEndpoint}addCompanyCustomer');
    final url = Uri.parse('${companyCustomerEndpoint}addCompanyCustomer');
    return await http.post(url, headers: await getHeaders(), body: jsonEncode(data));
  }

  Future<http.Response> getCompanyCustomer(String companyId) async {
    final url = Uri.parse('${companyCustomerEndpoint}allCompanyCustomer/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> deleteCompanyCustomer(String id) async {
    final url = Uri.parse('${companyCustomerEndpoint}deleteCompanyCustomer/$id');
    return await http.delete(url, headers: await getHeaders());
  }

  Future<http.Response> getAllMandatoryFields(String companyId) async {
    final url = Uri.parse('${companyCustomerEndpoint}getAllMandatoryFields/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> getAllShowFields(String companyId) async {
    final url = Uri.parse('${companyCustomerEndpoint}getAllShowFields/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> getExtraFieldName(String id) async {
    final url = Uri.parse('${companyCustomerEndpoint}getExtraFieldName/$id');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> getExtraFieldNameValue(String companyId) async {
    final url = Uri.parse('${companyCustomerEndpoint}getExtraFieldNameValue/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> addExtraFields(Map<String, dynamic> data) async {
    final url = Uri.parse('${companyCustomerEndpoint}addfields');
    return await http.post(url, headers: await getHeaders(), body: jsonEncode(data));
  }

  Future<http.Response> deleteWorkorderExtraField(String id) async {
    final url = Uri.parse('${companyCustomerEndpoint}deleteCompanyCustomerExtraFields/$id');
    return await http.delete(url, headers: await getHeaders());
  }

  Future<http.Response> getAllCompanyCustomerWithExtraColumn(String companyId) async {
    final url = Uri.parse('${companyCustomerEndpoint}allCompanyCustomerWithExtraFields/$companyId');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> getRoleAndPermission(String id, String name) async {
    final url = Uri.parse('${customerEndpoint}roleAndPermissionByName/get/$id/$name');
    return await http.get(url, headers: await getHeaders());
  }

  Future<http.Response> advanceFilter(
    dynamic data,
    int pageIndex,
    int pageSize,
    String category,
    String searchData,
    {String isAsc = 'true'}
  ) async {
    final url = Uri.parse('${companyCustomerEndpoint}advanceFilter/$pageIndex/$pageSize?category=$category&search=$searchData&asc=$isAsc');
    print("ORIGINAL: http://assetyug-lb-632006544.us-east-1.elb.amazonaws.com:8080/companycustomer/advanceFilter/0/10?category=&search=&asc=true");
    print(url);
    return await http.post(url, headers: await getHeaders(), body: jsonEncode(data));
  }

  Future<http.Response> working() async {
    final url = Uri.parse('${companyCustomerEndpoint}working');
    return await http.get(url, headers: await getHeaders());
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:asset_yug_debugging/config/api_config.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/asset_by_serial_dto_model.dart';
import 'package:asset_yug_debugging/features/Main/data/data_sources/api_user_data.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class AssetsRepositoryImpl {

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

  // Endpoints
  String get customerEndpoint => "${ApiConfig.baseUrl}customer/";
  String get assetEndpoint => "${ApiConfig.baseUrl}assets/";
  String get companyCustomerEndpoint => "${ApiConfig.baseUrl}companycustomer/";

  // Get assets by company ID
  //*DONE
  Future<http.Response> getAssets(String companyId) async {
    final url = "$assetEndpoint$companyId";
    print("companyId-> $companyId");
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  // Add assets
  Future<http.Response> addAssets(dynamic myFile, String companyId) async {
    final url = "$assetEndpoint/import/$companyId";
    var headers = await getHeaders();
    return await http.post(Uri.parse(url), body: myFile, headers: headers);
  }

  // Upload image
  Future<http.Response> uploadImage(dynamic data) async {
    final url = "${assetEndpoint}imageUpload";
    var headers = await getHeaders();
    return await http.post(Uri.parse(url), body: data, headers: headers);
  }

  // Remove image
  Future<http.Response> removeImage(String id) async {
    final url = "${assetEndpoint}removeImage";
    var headers = await getHeaders();
    return await http.post(Uri.parse(url), body: id, headers: headers);
  }

  // Remove asset
  Future<http.Response> removeAsset(String companyId) async {
    final url = "${assetEndpoint}removeAsset";
    var headers = await getHeaders();
    return await http.post(Uri.parse(url), body: companyId, headers: headers);
  }

  // Get extra field name by ID
  Future<http.Response> getExtraFieldName(String id) async {
    final url = "${assetEndpoint}getExtraFieldName/$id";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  // Get extra field name value by company ID
  Future<http.Response> getExtraFieldNameValue(String companyId) async {
    final url = "${assetEndpoint}getExtraFieldNameValue/$companyId";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  // Get mandatory fields
  Future<http.Response> getMandatoryFields(
      String name, String companyId) async {
    final url = "${assetEndpoint}getMandatoryFields/$name/$companyId";
    print("name $name");
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  // Get show fields
  Future<http.Response> getShowFields(String name, String companyId) async {
    final url = "${assetEndpoint}getShowFields/$name/$companyId";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  // Get all mandatory fields
  Future<http.Response> getAllMandatoryFields(String companyId) async {
    final url = "${assetEndpoint}getAllMandatoryFields/$companyId";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  // Get all show fields
  Future<http.Response> getAllShowFields(String companyId) async {
    final url = "${assetEndpoint}getAllShowFields/$companyId";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  // Add a new asset
  //*DONE
  Future<http.Response> addNewAsset(dynamic data) async {
    final url = "${assetEndpoint}addNewAssets";
    var headers = await getHeaders();
    return await http.post(Uri.parse(url), body: data, headers: headers);
  }

  // Add extra fields
  Future<http.Response> addExtraFieldsWithValue(dynamic data) async {
    final url = "${assetEndpoint}addfields";
    var headers = await getHeaders();
    return await http.post(Uri.parse(url), body: data, headers: headers);
  }

    // Add extra fields
  Future<http.Response> addExtraFieldsName(dynamic data) async {
    final url = "${assetEndpoint}addExtraFieldName";
    var headers = await getHeaders();
    return await http.post(Uri.parse(url), body: data, headers: headers);
  }

  // Get all asset details
  Future<http.Response> getAssetsAllDetails(String companyId) async {
    final url = "${assetEndpoint}getAllAssetData/$companyId";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  // // Get searched asset list
  // Future<http.Response> getSearchedAssetList(
  //     String companyId, String data, String category) async {
  //   final url =
  //       "${assetEndpoint}searchAssetlist/$companyId?data=$data&category=$category";
  //   var headers = await getHeaders();
  //   return await http.get(Uri.parse(url), headers: headers);
  // }

  // // Get sorted asset list
  // Future<http.Response> getSortedAssetList(String companyId, String category,
  //     String type, int pageIndex, int pageSize) async {
  //   final url =
  //       "${assetEndpoint}sortAssetlist/$companyId/$pageIndex/$pageSize?category=$category";
  //   var headers = await getHeaders();
  //   return await http.get(Uri.parse(url), headers: headers);
  // }

  // Get company customer list
  Future<http.Response> getCompanyCustomerList(String companyId) async {
    final url = "${companyCustomerEndpoint}allCompanyCustomer/$companyId";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  // Get role and permission by name
  Future<http.Response> getRoleAndPermission(String id, String name) async {
    final url = "${customerEndpoint}roleAndPermissionByName/get/$id/$name";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  // Advance filter
  //*MAIN
  Future<http.Response> advanceFilter(dynamic data, int pageIndex, int pageSize,
      String category, String searchData, {String isAsc = 'true'}) async {
    final url =
        // "http://assetyug-lb-632006544.us-east-1.elb.amazonaws.com:8080/assets/advanceFilter/0/5/cycle?category='Name'";

        "${assetEndpoint}advanceFilter/$pageIndex/$pageSize?category=$category&search=$searchData&asc=$isAsc";
    var headers = await getHeaders();
    print("");

    print("data: $data");
    print("");
    print("url: $url");
    print("");

    print("headers: $headers");
    print("");

    return await http.post(Uri.parse(url), body: data, headers: headers);
  }

  // Get Check In/Out List
  //!NOT WORKING
  Future<http.Response> getCheckInOutList(String id) async {
    final url = "${assetEndpoint}getCheckInOutList/$id";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  // Subject and Stream for event handling
  final _componentMethodCallSource = BehaviorSubject<dynamic>();
  Stream<dynamic> get componentMethodCalled$ =>
      _componentMethodCallSource.stream;

  void detailAsset(dynamic data) {
    _componentMethodCallSource.add(data);
  }

  Future<http.StreamedResponse> getAssetFiles(String assetId) async {
    final url = "${assetEndpoint}getFile/$assetId";
    var headers = await getHeaders();
    var request = http.Request('GET', Uri.parse(url));
    request.headers.addAll(headers);
    
    return await http.Client().send(request);
  }

  // Get asset details by ID
  Future<http.Response> getAssetDetails(String id) async {
    final url = "${assetEndpoint}getAsset/$id";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  // Integrate new APIs

  // Update asset
  // NEW API
  Future<http.Response> updateAsset(dynamic data) async {
    final url = "${assetEndpoint}addassets";
    var headers = await getHeaders();
    return await http.put(Uri.parse(url), body: data, headers: headers);
  }

  // Get extra fields
  // NEW API
  Future<http.Response> getExtraFields(String id) async {
    final url = "${assetEndpoint}getExtraFields/$id";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  // Remove extra field
  // NEW API
  Future<http.Response> removeExtraField(String id) async {
    final url = "${assetEndpoint}deleteExtraFields/$id";
    var headers = await getHeaders();
    return await http.delete(Uri.parse(url), headers: headers);
  }

  // Add check in/out
  // NEW API
  Future<http.Response> addCheckInOut(dynamic data) async {
    final url = "${assetEndpoint}addCheckInOut";
    var headers = await getHeaders();
    return await http.post(Uri.parse(url), body: data, headers: headers);
  }

  // Add asset file
  // NEW API
  Future<http.StreamedResponse> addAssetFile(File file, String assetId) async {
    final url = "${assetEndpoint}addFile/$assetId";
    var headers = await getHeaders();
    headers.remove('Content-Type');
    print("headers: $headers");

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    print("request: $request");
    return await request.send();
  }

  // Download file
  // NEW API
  Future<http.Response> downloadFile(String id) async {
    final url = "${assetEndpoint}getFile/download/$id";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  // Delete file
  // NEW API
  Future<http.Response> deleteFile(String id) async {
    final url = "${assetEndpoint}deleteFile/$id";
    var headers = await getHeaders();
    return await http.delete(Uri.parse(url), headers: headers);
  }

  // Get work orders
  // NEW API
  Future<http.Response> getWorkOrders(String id) async {
    final url = "http://localhost:8083/workorder/getworkorderlist/$id";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  // Get technical users
  // NEW API
  Future<http.Response> getTechnicalUsers(String companyId) async {
    final url = "http://localhost:8082/users/getTechnicalUser/$companyId";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  // Get QR data
  // NEW API
  Future<http.Response> getQR(String companyId) async {
    final url = "${assetEndpoint}getQRData/$companyId";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }


      // Adding new APIs


  Future<dynamic> checkInCheckOutCount(String companyId) async {
    final response = await http.get(
      Uri.parse('${assetEndpoint}checkInOutCount/$companyId'),
      headers: await getHeaders(),
    );
    return response;
  }

  // API to get assets by serial number
  
  Future<http.Response> assetFromSerialNumber(AssetBySerialDTO assetBySerialDTO) async {
    final url = "${assetEndpoint}assetBySerialNumber";
    var headers = await getHeaders();
    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(assetBySerialDTO.toJson()),  // Convert the DTO object to JSON
    );
  }

  // API to get check-in/check-out assets based on companyId and checkedIn status
  
  Future<http.Response> checkInOutAsset(String companyId, bool checkedIn) async {
    final url = "${assetEndpoint}checkInOutAsset/$companyId/$checkedIn";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

}
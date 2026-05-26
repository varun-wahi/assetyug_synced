import 'dart:convert';
import 'dart:io';
import 'package:asset_yug_debugging/config/api_config.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/asset_by_serial_dto_model.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class AssetsRepositoryImpl {
  Future<Map<String, String>> getHeaders() async {
    final box = await Hive.openBox('auth_data');
    final mobileId = box.get('mobileId', defaultValue: 'UNKNOWN_MOBILE_ID');
    final authToken = box.get('auth_token', defaultValue: 'UNKNOWN_AUTH_TOKEN');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
      'mobile-id': mobileId,
    };
  }

  // // Asynchronous headers getter
  // Future<Map<String, String>> getHeaders() async {
  //   String? token = await getAuthToken();
  //   return {
  //     'Authorization': 'Bearer $token',
  //     'Content-Type': 'application/json',
  //   };
  // }

  // Endpoints
  String get customerEndpoint => "${ApiConfig.baseUrl}customer/";
  String get assetEndpoint => "${ApiConfig.baseUrl}assets/";
  String get companyCustomerEndpoint => "${ApiConfig.baseUrl}companycustomer/";
  String get userEndpoint => "${ApiConfig.baseUrl}users/";

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

  Future<http.Response> updateAsset(Map<String, dynamic> updateData) async {
    final url = "${assetEndpoint}addassets";
    final uri = Uri.parse(url);
    final headers = await getHeaders();
    final body = jsonEncode(updateData);

    print("⬆️ Sending PUT request to: $url");
    print("📝 Request Headers: $headers");
    print("📦 Request Body: $body");

    try {
      final response = await http.put(uri, body: body, headers: headers);

      print("✅ Response Status Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      return response;
    } catch (e, stackTrace) {
      print("❌ HTTP PUT Request failed");
      print("🧾 Error: $e");
      print("🧵 StackTrace: $stackTrace");
      rethrow; // Rethrow to let calling code handle it
    }
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

  Future<http.Response> getActiveAssets(String companyId) async {
    final url = "${assetEndpoint}getActiveAssets/$companyId";
    var headers = await getHeaders();
    // print("🔍 Fetching Active Assets: $url");
    // print("📝 Headers: $headers");
    final response = await http.get(Uri.parse(url), headers: headers);
    // print("📥 Response ASSETS [${response.statusCode}]: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final List<dynamic> assets = json.decode(response.body);
        final names =
            assets.map((e) => e['name']?.toString() ?? 'Unnamed').toList();
        print("📊 Active Assets Count: ${assets.length}");
        print("🏷️ Active Asset Names: $names");
      } catch (e) {
        print("⚠️ Error parsing asset log: $e");
      }
    }
    return response;
  }

  Future<http.Response> getCategoryList(String companyId) async {
    final url = "${assetEndpoint}getCategoryList/$companyId";
    print("URL: $url");
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> getAssetsByCategories(String companyId) async {
    final url = "${assetEndpoint}getAssetByCategory/$companyId";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
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

//!_--------------------------    INSPECTION  APIS   --------------------------_!
//GET
//assets/getAllAssetInspectionInstanceByAssetId/694cc46e4df01d3deaa3bf27
// Get all inspection instances for a specific asset
  Future<http.Response> getAssetInspectionInstancesByAssetId(
    String assetId,
  ) async {
    final url =
        "${assetEndpoint}getAllAssetInspectionInstanceByAssetId/$assetId";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }
  //RESPONSE: [
//     {
//         "id": "69509eb68cb604593305ed98",
//         "assetId": "694cc46e4df01d3deaa3bf27",
//         "companyId": 100004,
//         "createdAt": "12/27/2025, 10:06:31 PM",
//         "updatedAt": "12/27/2025, 10:06:31 PM",
//         "actionPerformedBy": "Harsh Nisar",
//         "notes": "Pre trip inspection",
//         "status": "PENDING",
//         "assetCategoryInspectionId": "",
//         "assetCategoryInspectionName": "undefined ",
//         "stepValues": [
//             {
//                 "id": null,
//                 "name": "Engine Oil filter",
//                 "inspectionStepId": null,
//                 "inspectionName": null,
//                 "type": "TEXT",
//                 "value": "Need to change"
//             },
//             {
//                 "id": null,
//                 "name": "Brake pads",
//                 "inspectionStepId": null,
//                 "inspectionName": null,
//                 "type": "CHECKBOX",
//                 "value": "true"
//             },
//             {
//                 "id": null,
//                 "name": "Odometer",
//                 "inspectionStepId": null,
//                 "inspectionName": null,
//                 "type": "NUMBER",
//                 "value": "21450"
//             }
//         ],
//         "inspectionTemplates": [
//             {
//                 "inspectionName": null,
//                 "stepValues": [
//                     {
//                         "id": null,
//                         "name": "Engine Oil filter",
//                         "inspectionStepId": null,
//                         "inspectionName": null,
//                         "type": "TEXT",
//                         "value": "Need to change"
//                     },
//                     {
//                         "id": null,
//                         "name": "Brake pads",
//                         "inspectionStepId": null,
//                         "inspectionName": null,
//                         "type": "CHECKBOX",
//                         "value": "true"
//                     },
//                     {
//                         "id": null,
//                         "name": "Odometer",
//                         "inspectionStepId": null,
//                         "inspectionName": null,
//                         "type": "NUMBER",
//                         "value": "21450"
//                     }
//                 ]
//             }
//         ],
//         "selectedItemList": [
//             {
//                 "id": "69509dfa8cb604593305ed97",
//                 "name": null
//             }
//         ]
//     }
// ]

//GET
// assets/getAllAssetInspectionByCategory/100004?category=Automobile
// Get all asset inspections by category
  Future<http.Response> getAssetInspectionsByCategory(
    String companyId,
    String category,
  ) async {
    final url =
        "${assetEndpoint}getAllAssetInspectionByCategory/$companyId?category=$category";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }
// [
//     {
//         "id": "69509dfa8cb604593305ed97",
//         "name": "12-point Inspection",
//         "categoryName": "Automobile",
//         "categoryId": "692242a8c857cd4c82d3cb6e",
//         "companyId": 100004,
//         "steps": [
//             {
//                 "id": null,
//                 "stepNumber": 0,
//                 "name": "Engine Oil filter",
//                 "type": "TEXT"
//             },
//             {
//                 "id": null,
//                 "stepNumber": 0,
//                 "name": "Brake pads",
//                 "type": "CHECKBOX"
//             },
//             {
//                 "id": null,
//                 "stepNumber": 0,
//                 "name": "Odometer",
//                 "type": "NUMBER"
//             }
//         ],
//         "status": "active"
//     },
//     {
//         "id": "69509f4f8cb604593305ed9b",
//         "name": "14-point inspection",
//         "categoryName": "Automobile",
//         "categoryId": "692242a8c857cd4c82d3cb6e",
//         "companyId": 100004,
//         "steps": [
//             {
//                 "id": null,
//                 "stepNumber": 0,
//                 "name": "Tyres",
//                 "type": "CHECKBOX"
//             },
//             {
//                 "id": null,
//                 "stepNumber": 0,
//                 "name": "Brake oil",
//                 "type": "TEXT"
//             },
//             {
//                 "id": null,
//                 "stepNumber": 0,
//                 "name": "Engine RPM",
//                 "type": "NUMBER"
//             }
//         ],
//         "status": "active"
//     }
// ]

// Add asset inspection instance
  Future<http.Response> addAssetInspectionInstance(
    Map<String, dynamic> payload,
  ) async {
    final url = "${assetEndpoint}addAssetInspectionInstance";
    var headers = await getHeaders();
    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(payload),
    );
  }

//EXAMPLE PAYLOAD:
// {"assetId":"694cc46e4df01d3deaa3bf27","companyId":"100004","assetCategoryInspectionId":"","assetCategoryInspectionName":"undefined ","actionPerformedBy":"Varun Wahi","notes":"test","createdAt":"06/01/2026, 22:41:56","updatedAt":"06/01/2026, 22:41:56","status":"COMPLETED","stepValues":[{"name":"Engine Oil filter","inspectionStepId":null,"value":"sdsd","type":"TEXT"},{"name":"Brake pads","inspectionStepId":null,"value":true,"type":"CHECKBOX"},{"name":"Odometer","inspectionStepId":null,"value":"232323","type":"NUMBER"}],"inspectionTemplates":[{"stepValues":[{"name":"Engine Oil filter","inspectionStepId":null,"value":"sdsd","type":"TEXT"},{"name":"Brake pads","inspectionStepId":null,"value":true,"type":"CHECKBOX"},{"name":"Odometer","inspectionStepId":null,"value":"232323","type":"NUMBER"}]}],"selectedItemList":[{"id":"69509dfa8cb604593305ed97"}]}

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

//!_--------------------------    COMPANY CUSTOMER  APIS   --------------------------_!

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
      String category, String? searchData,
      {String isAsc = 'true'}) async {
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
    final result = await http.get(Uri.parse(url), headers: headers);
    // print("Check In/Out List Response: ${result.body}");
    return result;
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

  // Get extra fields
  // NEW API
  Future<http.Response> getExtraFields(String id) async {
    final url = "${assetEndpoint}getExtraFields/$id";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> getActiveCategories(String companyId) async {
    final url = "${assetEndpoint}getCategoryActiveList/$companyId";
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
    print("📤 Adding Check-In/Out Detail: $url");
    print("📦 Payload: $data");
    final response =
        await http.post(Uri.parse(url), body: data, headers: headers);

    print(
        "📥 Check-In/Out Response [${response.statusCode}]: ${response.body}");
    return response;
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
    final url = "http://localhost:8080/workorder/getworkorderlist/$id";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  // Get technical users
  // NEW API
  Future<http.Response> getTechnicalUsers(String companyId) async {
    final url = "${userEndpoint}getTechnicalUser/$companyId";
    var headers = await getHeaders();
    print("🔍 Fetching Technical Users: $url");
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

  Future<http.Response> assetFromSerialNumber(
      AssetBySerialDTO assetBySerialDTO) async {
    final url = "${assetEndpoint}assetBySerialNumber";

    var headers = await getHeaders();
    print("URL: $url");
    print("Headers: $headers");
    print("body: ${json.encode(assetBySerialDTO.toJson())}");
    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: json
          .encode(assetBySerialDTO.toJson()), // Convert the DTO object to JSON
    );
  }

  // API to get check-in/check-out assets based on companyId and checkedIn status

  Future<http.Response> checkInOutAsset(
      String companyId, bool checkedIn) async {
    final url = "${assetEndpoint}checkInOutAsset/$companyId/$checkedIn";
    var headers = await getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> countAssetByCategories(String companyId) async {
    final url = "${assetEndpoint}countAssetByCategories/$companyId";
    final headers = await getHeaders();
    print("🔍 [API Request] Fetching Asset Count by Categories: $url");
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      print(
          "✅ [API Success] countAssetByCategories response status: ${response.statusCode}");
      print("📥 [API Response] Body: ${response.body}");
      return response;
    } catch (e, stackTrace) {
      print("❌ [API Error] countAssetByCategories failed");
      print("🧾 Error: $e");
      print("🧵 StackTrace: $stackTrace");
      rethrow;
    }
  }
}

import 'dart:convert';

import 'package:asset_yug_debugging/config/secrets.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class InspectionRepositoryImpl {
  String get inspectionEndpoint => '${ApiConfig.baseUrl}inspection/';

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

//!_--------------------------    INSPECTION  APIS   --------------------------_!

//GET
// inspection/status-count/100004
// Get inspection counts grouped by status
  Future<http.Response> getInspectionStatusCount(String companyId) async {
    final url = '${inspectionEndpoint}status-count/$companyId';
    final headers = await getHeaders();
    final result = await http.get(Uri.parse(url), headers: headers);
    print('Inspection Status Count Response: ${result.body}');
    return result;
  }

//GET
// inspection/incomplete-by-performer/100004
// Get incomplete inspections grouped by performer
  Future<http.Response> getIncompleteInspectionsByPerformer(
    String companyId,
  ) async {
    final url = '${inspectionEndpoint}incomplete-by-performer/$companyId';
    final headers = await getHeaders();
    final result = await http.get(Uri.parse(url), headers: headers);
    print('Incomplete Inspections By Performer Response: ${result.body}');
    return result;
  }

//POST
// inspection/detailed/100004
// Get paginated detailed inspection list
  Future<http.Response> getDetailedInspections(
    String companyId, {
    int pageNumber = 0,
    int pageSize = 10,
    String sortField = 'createdAt',
    String sortDirection = 'DESC',
    Map<String, dynamic>? payload,
  }) async {
    final url = '${inspectionEndpoint}detailed/$companyId';
    final headers = await getHeaders();
    final body = jsonEncode(
      payload ??
          {
            'pageNumber': pageNumber,
            'pageSize': pageSize,
            'sortField': sortField,
            'sortDirection': sortDirection,
          },
    );

    print('Detailed Inspections Request: $url');
    print('Detailed Inspections Payload: $body');

    final result = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    print('Detailed Inspections Response: ${result.body}');
    return result;
  }
}

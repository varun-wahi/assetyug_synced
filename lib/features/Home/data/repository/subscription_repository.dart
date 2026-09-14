import 'dart:convert';

import 'package:asset_yug_debugging/config/secrets.dart';
import 'package:asset_yug_debugging/features/Home/data/models/trial_status_model.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class SubscriptionRepositoryImpl {
  String get subscriptionEndpoint => '${ApiConfig.baseUrl}subscription/';
  String get customerEndpoint => '${ApiConfig.baseUrl}customer/';

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

  Future<String> _currentCompanyId() async {
    final box = await Hive.openBox('auth_data');
    final companyId = box.get('companyId')?.toString();
    if (companyId == null || companyId.isEmpty) {
      throw Exception('Company ID not found. Please log in again.');
    }
    return companyId;
  }

  /// True while the company may use the product (paid plan *or* active trial).
  /// Do not use this to decide whether to show the trial-expiry banner.
  Future<bool> isSubscriptionValid({String? companyId}) async {
    final id = companyId ?? await _currentCompanyId();
    final url = '${subscriptionEndpoint}subscription-valid/$id';
    final headers = await getHeaders();

    print('Subscription Valid Request: $url');
    final result = await http.get(Uri.parse(url), headers: headers);
    print('Subscription Valid Response [${result.statusCode}]: ${result.body}');

    if (result.statusCode != 200) {
      throw Exception(
          'Failed to fetch subscription status: ${result.statusCode}');
    }

    final body = result.body.trim();
    if (body.toLowerCase() == 'true') return true;
    if (body.toLowerCase() == 'false') return false;

    final decoded = json.decode(body);
    if (decoded is bool) return decoded;
    return decoded.toString().toLowerCase() == 'true';
  }

  Future<TrialStatusDetails> getTrialStatusDetails({String? companyId}) async {
    final id = companyId ?? await _currentCompanyId();
    final url = '${customerEndpoint}trial-status-details/$id';
    final headers = await getHeaders();

    print('Trial Status Request: $url');
    final result = await http.get(Uri.parse(url), headers: headers);
    print('Trial Status Response [${result.statusCode}]: ${result.body}');

    if (result.statusCode != 200) {
      throw Exception('Failed to fetch trial status: ${result.statusCode}');
    }

    final decoded = json.decode(result.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected trial status response');
    }

    return TrialStatusDetails.fromJson(decoded);
  }
}

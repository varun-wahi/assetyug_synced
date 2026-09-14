import 'dart:convert';

import 'package:asset_yug_debugging/config/secrets.dart';
import 'package:asset_yug_debugging/features/Home/data/models/notification_model.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class NotificationRepositoryImpl {
  String get notificationEndpoint => '${ApiConfig.baseUrl}notification/';

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

  Future<String?> _currentUserEmail() async {
    final box = await Hive.openBox('auth_data');
    return box.get('email')?.toString();
  }

  Future<PaginatedNotifications> getUserNotifications({
    String? email,
    int pageNumber = 0,
    int pageSize = 10,
  }) async {
    final userEmail = email ?? await _currentUserEmail();
    if (userEmail == null || userEmail.isEmpty) {
      throw Exception('User email not found. Please log in again.');
    }

    final url =
        '${notificationEndpoint}user/$userEmail/paginated?pageNumber=$pageNumber&pageSize=$pageSize';
    final headers = await getHeaders();

    print('Notifications Request: $url');
    final result = await http.get(Uri.parse(url), headers: headers);
    print('Notifications Response [${result.statusCode}]: ${result.body}');

    if (result.statusCode != 200) {
      throw Exception('Failed to fetch notifications: ${result.statusCode}');
    }

    final decoded = json.decode(result.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected notifications response');
    }

    return PaginatedNotifications.fromJson(decoded);
  }
}

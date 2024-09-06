import 'package:hive/hive.dart';

Future<String?> getAuthToken() async {
  var box = await Hive.openBox('auth_data');
  return box.get('auth_token');
}

Future<Map<String, String>> getHeaders() async {
  String? token = await getAuthToken();
  return {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
}
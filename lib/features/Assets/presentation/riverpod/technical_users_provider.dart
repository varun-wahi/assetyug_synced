import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';

final assetsRepositoryProvider = Provider((ref) => AssetsRepositoryImpl());

final technicalUsersProvider = FutureProvider.family<List<String>, String>((ref, companyId) async {
  final repo = ref.read(assetsRepositoryProvider);
  final response = await repo.getTechnicalUsers(companyId);

  print("🟢 Technical Users Response [Status: ${response.statusCode}]: ${response.body}");

  if (response.statusCode == 200) {
    try {
      final List<dynamic> userList = json.decode(response.body);
      print("✅ Technical users parsed: ${userList.length} found");
      return userList.map((user) {
        final firstName = user['firstName'] ?? '';
        final lastName = user['lastName'] ?? '';
        return "$firstName $lastName".trim();
      }).toList();
    } catch (e) {
      print("❌ Error decoding technical users JSON: $e");
      print("📦 Raw Response Body: ${response.body}");
      rethrow;
    }
  } else {
    print("❌ Failed to fetch technical users. Status: ${response.statusCode}");
    throw Exception('Failed to fetch technical users: ${response.statusCode}');
  }
});

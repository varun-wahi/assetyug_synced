import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:asset_yug_debugging/features/Customers/data/repository/company_customer_repository_impl.dart';

final customerRepositoryProvider = Provider((ref) => CompanyCustomerRepositoryImpl());

final companyIdProvider = FutureProvider<String?>((ref) async {
  var box = await Hive.openBox('auth_data');
  return box.get('companyId')?.toString();
});

final customerCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final companyId = await ref.watch(companyIdProvider.future);
  if (companyId == null) return [];

  final repo = ref.read(customerRepositoryProvider);
  final response = await repo.getActiveCustomerCategories(companyId);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => item['name'].toString()).toList();
  } else {
    throw Exception('Failed to load customer categories');
  }
});

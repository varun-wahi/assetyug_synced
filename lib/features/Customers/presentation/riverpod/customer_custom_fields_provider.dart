import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../data/models/custom_field.dart';
import '../../data/repository/company_customer_repository_impl.dart';

class CustomerCustomFieldsNotifier extends StateNotifier<List<CustomerCustomField>> {
  CustomerCustomFieldsNotifier() : super([]);

  final CompanyCustomerRepositoryImpl _repo = CompanyCustomerRepositoryImpl();

  Future<void> loadCustomFields(String companyId) async {
    try {
      final mandatoryRes = await _repo.getAllMandatoryFields(companyId);
      final showRes = await _repo.getAllShowFields(companyId);

      List<CustomerCustomField> parse(http.Response res, bool isMandatory) {
        if (res.statusCode != 200) return [];
        final List<dynamic> jsonList = json.decode(res.body);
        return jsonList
            .map((e) => CustomerCustomField.fromJson({
                  ...e as Map<String, dynamic>,
                  'mandatory': isMandatory,
                }))
            .toList();
      }

      // Merge and deduplicate by id
      final Map<String, CustomerCustomField> fieldMap = {};
      for (var f in parse(mandatoryRes, true)) {
        fieldMap[f.id] = f;
      }
      for (var f in parse(showRes, false)) {
        fieldMap.putIfAbsent(f.id, () => f);
      }

      state = fieldMap.values.toList();
      print('✅ Loaded ${state.length} customer custom fields');
    } catch (e) {
      print('❌ Error loading customer custom fields: $e');
    }
  }
}

final customerCustomFieldsProvider =
    StateNotifierProvider.autoDispose<CustomerCustomFieldsNotifier, List<CustomerCustomField>>(
  (ref) => CustomerCustomFieldsNotifier(),
);

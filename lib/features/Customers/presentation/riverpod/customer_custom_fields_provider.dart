import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../core/models/custom_field_model.dart';
import '../../data/repository/company_customer_repository_impl.dart';

class CustomerCustomFieldsNotifier extends StateNotifier<List<CustomField>> {
  CustomerCustomFieldsNotifier() : super([]);

  final CompanyCustomerRepositoryImpl _repo = CompanyCustomerRepositoryImpl();

  // For view tab — loads per-customer saved values
  Future<void> loadExtraFieldsForCustomer(String customerId) async {
    try {
      print('🔄 Loading extra fields for customerId: $customerId');
      final res = await _repo.getExtraFields(customerId);
      if (!mounted) return;

      if (res.statusCode != 200) {
        state = [];
        return;
      }

      // Empty body means no fields — not an error
      if (res.body.trim().isEmpty) {
        state = [];
        return;
      }

      final decoded = json.decode(res.body);

      // API might return null or empty list
      if (decoded == null || decoded is! List) {
        state = [];
        return;
      }

      state = decoded
          .map((e) => CustomFieldWithValue.fromExtraFieldJson(
              e as Map<String, dynamic>))
          .toList();
      print('✅ Loaded ${state.length} customer extra fields');
    } catch (e, st) {
      print('❌ loadExtraFieldsForCustomer: $e\n$st');
      state = [];
    }
  }

  Future<void> loadCustomFields(String companyId) async {
    try {
      final mandatoryRes = await _repo.getAllMandatoryFields(companyId);
      final showRes = await _repo.getAllShowFields(companyId);

      List<CustomField> parse(http.Response res, bool isMandatory) {
        if (res.statusCode != 200) return [];
        final List<dynamic> jsonList = json.decode(res.body);
        return jsonList
            .map((e) => CustomField.fromJson({
                  ...e as Map<String, dynamic>,
                  'mandatory': isMandatory,
                }))
            .toList();
      }

      // Merge and deduplicate by id
      final Map<String, CustomField> fieldMap = {};
      for (var f in parse(mandatoryRes, true)) {
        fieldMap[f.name] = f;
      }
      for (var f in parse(showRes, false)) {
        fieldMap.putIfAbsent(f.name, () => f);
      }

      state = fieldMap.values.toList();
      print('✅ Loaded ${state.length} customer custom fields');
    } catch (e) {
      print('❌ Error loading customer custom fields: $e');
    }
  }
}

final customerCustomFieldsProvider = StateNotifierProvider.autoDispose<
    CustomerCustomFieldsNotifier, List<CustomField>>(
  (ref) => CustomerCustomFieldsNotifier(),
);

// Isolated per-customer provider for the custom tab
final customerExtraFieldsProvider = StateNotifierProvider.autoDispose
    .family<CustomerCustomFieldsNotifier, List<CustomField>, String>(
  (ref, customerId) {
    final notifier = CustomerCustomFieldsNotifier();
    Future.microtask(() => notifier.loadExtraFieldsForCustomer(customerId));
    return notifier;
  },
);

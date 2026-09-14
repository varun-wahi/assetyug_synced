import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../core/models/custom_field_model.dart';
import '../../data/repository/company_customer_repository_impl.dart';

class CustomerCustomFieldsNotifier extends StateNotifier<List<CustomField>> {
  CustomerCustomFieldsNotifier() : super([]);

  final CompanyCustomerRepositoryImpl _repo = CompanyCustomerRepositoryImpl();

  List<dynamic> _parseJsonList(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return [];

    final decoded = json.decode(trimmed);
    if (decoded is List) return decoded;

    print('⚠️ Unexpected custom fields response shape: ${decoded.runtimeType}');
    return [];
  }

  List<CustomField> _parseFields(http.Response res) {
    if (res.statusCode != 200) return [];
    return _parseJsonList(res.body)
        .whereType<Map<String, dynamic>>()
        .map(CustomField.fromJson)
        .where((f) => f.name.isNotEmpty)
        .toList();
  }

  /// Only names where mandatory == true (API may return mandatory:false entries).
  Set<String> _parseMandatoryNames(http.Response res) {
    return _parseFields(res)
        .where((f) => f.mandatory)
        .map((f) => f.name)
        .toSet();
  }

  /// uniqueFieldConfig uses `fieldName` + `isUnique` (same as assets).
  Set<String> _parseUniqueNames(http.Response res) {
    if (res.statusCode != 200) return {};
    return _parseJsonList(res.body)
        .whereType<Map<String, dynamic>>()
        .where((e) => e['isUnique'] == true)
        .map((e) => (e['fieldName'] ?? e['name'])?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet();
  }

  /// Parses getAllShowFields and drops anything explicitly marked show:false.
  /// If the `show` key is missing, the field is kept (endpoint implies visible).
  List<CustomField> _parseShowFields(http.Response res) {
    if (res.statusCode != 200) return [];
    return _parseJsonList(res.body).whereType<Map<String, dynamic>>().where((e) {
      if (e.containsKey('show') && e['show'] != true) return false;
      return (e['name']?.toString() ?? '').isNotEmpty;
    }).map((e) {
      final field = CustomField.fromJson(e);
      return field.copyWith(show: true);
    }).toList();
  }

  // For view tab — loads per-customer saved values (getExtraFields),
  // but only keeps fields that are also in getAllShowFields.
  // Mandatory-only fields (not in show) are never displayed.
  Future<void> loadExtraFieldsForCustomer(String customerId) async {
    if (customerId.isEmpty) {
      state = [];
      return;
    }
    // Drop stale values immediately so UI doesn't keep old data mid-fetch.
    state = [];
    try {
      print('🔄 Loading extra fields for customerId: $customerId');

      final companyId = await _repo.getCompanyId();
      final companyIdStr = (companyId == null || companyId == 'null')
          ? ''
          : companyId;

      final futures = <Future<http.Response>>[
        _repo.getExtraFields(customerId),
        if (companyIdStr.isNotEmpty) _repo.getAllShowFields(companyIdStr),
      ];
      final results = await Future.wait(futures);
      if (!mounted) return;

      final extraRes = results[0];
      if (extraRes.statusCode != 200) {
        state = [];
        return;
      }

      // Visibility is driven only by show fields — never by mandatory alone.
      final showNames = results.length > 1
          ? _parseShowFields(results[1]).map((f) => f.name).toSet()
          : <String>{};

      final decoded = _parseJsonList(extraRes.body);
      state = decoded
          .whereType<Map<String, dynamic>>()
          .map(CustomFieldWithValue.fromExtraFieldJson)
          .where((f) => showNames.contains(f.name))
          .toList();
      print(
        '✅ Loaded ${state.length} customer extra fields '
        '(filtered to show fields: $showNames)',
      );
    } catch (e, st) {
      print('❌ loadExtraFieldsForCustomer: $e\n$st');
      if (!mounted) return;
      state = [];
    }
  }

  /// Loads fields for Add Customer / filters.
  ///
  /// Rules:
  /// - Only fields from [getAllShowFields] with show == true are displayed.
  /// - Mandatory-only fields (not in show) are never displayed.
  /// - Unique flags come from [uniqueFieldConfig] (match by fieldName;
  ///   only isUnique == true). Safe if the endpoint is not live yet.
  /// - Match by name because the APIs return different Mongo IDs for the
  ///   same logical field.
  Future<void> loadCustomFields(String companyId) async {
    // Drop stale values immediately so UI doesn't keep old data mid-fetch.
    state = [];
    try {
      final results = await Future.wait([
        _repo.getAllShowFields(companyId),
        _repo.getAllMandatoryFields(companyId),
        _repo.getUniqueFieldConfig(companyId),
      ]);
      if (!mounted) return;

      print('📦 Show fields raw: ${results[0].body}');
      print('📦 Mandatory fields raw: ${results[1].body}');
      print('📦 Unique fields raw: ${results[2].statusCode} ${results[2].body}');

      final showFields = _parseShowFields(results[0]);
      final mandatoryNames = _parseMandatoryNames(results[1]);
      final uniqueNames = _parseUniqueNames(results[2]);

      // Deduplicate show fields by name; keep first occurrence.
      // Never add mandatory-only fields into this map.
      final Map<String, CustomField> byName = {};
      for (final field in showFields) {
        byName.putIfAbsent(
          field.name,
          () => field.copyWith(
            show: true,
            mandatory: mandatoryNames.contains(field.name),
            isUnique: uniqueNames.contains(field.name),
          ),
        );
      }

      state = byName.values.toList();
      print(
        '✅ Loaded ${state.length} customer custom fields '
        '[${state.map((f) => '${f.name}(show=${f.show},mand=${f.mandatory},uniq=${f.isUnique})').join(', ')}]',
      );
    } catch (e, st) {
      print('❌ Error loading customer custom fields: $e\n$st');
      if (!mounted) return;
      state = [];
    }
  }
}

final customerCustomFieldsProvider = StateNotifierProvider.autoDispose<
    CustomerCustomFieldsNotifier, List<CustomField>>(
  (ref) => CustomerCustomFieldsNotifier(),
);

// Isolated per-customer provider for the custom tab.
// Does NOT auto-fetch — callers must call [loadExtraFieldsForCustomer]
// so each visit/tab selection can force a fresh request.
final customerExtraFieldsProvider = StateNotifierProvider.autoDispose
    .family<CustomerCustomFieldsNotifier, List<CustomField>, String>(
  (ref, customerId) => CustomerCustomFieldsNotifier(),
);

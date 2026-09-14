import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';

import '../../../../core/models/custom_field_model.dart';

class AssetCustomFieldsNotifier extends StateNotifier<List<CustomField>> {
  AssetCustomFieldsNotifier() : super([]);

  final AssetsRepositoryImpl _repo = AssetsRepositoryImpl();

  List<dynamic> _parseJsonList(String body) {
    final trimmedBody = body.trim();
    if (trimmedBody.isEmpty) return [];

    final decoded = json.decode(trimmedBody);
    if (decoded is List) return decoded;

    print('⚠️ Unexpected extra fields response shape: ${decoded.runtimeType}');
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

  /// uniqueFieldConfig uses `fieldName` + `isUnique`.
  Set<String> _parseUniqueNames(http.Response res) {
    if (res.statusCode != 200) return {};
    return _parseJsonList(res.body)
        .whereType<Map<String, dynamic>>()
        .where((e) => e['isUnique'] == true)
        .map((e) => (e['fieldName'] ?? e['name'])?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet();
  }

  Future<String> _companyId() async {
    final box = await Hive.openBox('auth_data');
    final id = box.get('companyId');
    if (id == null) return '';
    final str = id.toString();
    return str == 'null' ? '' : str;
  }

  /// View / edit tab — getExtraFields filtered to show fields only.
  /// Mandatory-only / unique-only fields that are not in show are hidden.
  Future<void> loadExtraFieldsForAsset(String assetId) async {
    if (assetId.isEmpty) {
      state = [];
      return;
    }
    state = [];
    try {
      final companyId = await _companyId();
      final futures = <Future<http.Response>>[
        _repo.getExtraFields(assetId),
        if (companyId.isNotEmpty) _repo.getAllShowFields(companyId),
      ];
      final results = await Future.wait(futures);
      if (!mounted) return;

      final extraRes = results[0];
      if (extraRes.statusCode != 200) {
        state = [];
        return;
      }

      final showNames = results.length > 1
          ? _parseShowFields(results[1]).map((f) => f.name).toSet()
          : <String>{};

      state = _parseJsonList(extraRes.body)
          .whereType<Map<String, dynamic>>()
          .map(CustomFieldWithValue.fromExtraFieldJson)
          .where((f) => showNames.contains(f.name))
          .toList();
      print(
        '✅ Loaded ${state.length} asset extra fields '
        '(filtered to show: $showNames)',
      );
    } catch (e, stackTrace) {
      print('❌ Error loading extra fields: $e\n$stackTrace');
      if (!mounted) return;
      state = [];
    }
  }

  /// Edit asset — show fields with saved values + mandatory/unique flags.
  Future<void> loadExtraFieldsForEdit(String assetId, String companyId) async {
    if (assetId.isEmpty) {
      state = [];
      return;
    }
    state = [];
    try {
      final results = await Future.wait([
        _repo.getExtraFields(assetId),
        _repo.getAllShowFields(companyId),
        _repo.getAllMandatoryFields(companyId),
        _repo.getUniqueFieldConfig(companyId),
      ]);
      if (!mounted) return;

      final showFields = _parseShowFields(results[1]);
      final mandatoryNames = _parseMandatoryNames(results[2]);
      final uniqueNames = _parseUniqueNames(results[3]);

      final valuesByName = <String, CustomFieldWithValue>{};
      if (results[0].statusCode == 200) {
        for (final item in _parseJsonList(results[0].body)
            .whereType<Map<String, dynamic>>()) {
          final field = CustomFieldWithValue.fromExtraFieldJson(item);
          if (field.name.isNotEmpty) valuesByName[field.name] = field;
        }
      }

      final Map<String, CustomField> byName = {};
      for (final field in showFields) {
        final existing = valuesByName[field.name];
        byName.putIfAbsent(
          field.name,
          () => CustomFieldWithValue(
            id: existing?.id.isNotEmpty == true ? existing!.id : field.id,
            name: field.name,
            type: field.type.isNotEmpty
                ? field.type
                : (existing?.type ?? ''),
            value: existing?.value ?? '',
            assetId: existing?.assetId.isNotEmpty == true
                ? existing!.assetId
                : assetId,
            email: field.email.isNotEmpty
                ? field.email
                : (existing?.email ?? ''),
            companyId: field.companyId != 0
                ? field.companyId
                : (existing?.companyId ?? 0),
            show: true,
            mandatory: mandatoryNames.contains(field.name),
            isUnique: uniqueNames.contains(field.name),
          ),
        );
      }

      state = byName.values.toList();
      print(
        '✅ Loaded ${state.length} asset fields for edit '
        '[${state.map((f) => '${f.name}(show=${f.show},mand=${f.mandatory},uniq=${f.isUnique})').join(', ')}]',
      );
    } catch (e, st) {
      print('❌ loadExtraFieldsForEdit: $e\n$st');
      if (!mounted) return;
      state = [];
    }
  }

  /// Add Asset / filters.
  ///
  /// Rules:
  /// - Only fields from [getAllShowFields] with show == true are displayed.
  /// - Mandatory-only fields (not in show) are never displayed.
  /// - Unique flags come from [uniqueFieldConfig] (match by fieldName).
  /// - Match by name because APIs return different Mongo IDs per endpoint.
  Future<void> loadCustomFields(String companyId) async {
    state = [];
    try {
      print('🔄 Loading asset custom fields for companyId: $companyId');

      final results = await Future.wait([
        _repo.getAllShowFields(companyId),
        _repo.getAllMandatoryFields(companyId),
        _repo.getUniqueFieldConfig(companyId),
      ]);
      if (!mounted) return;

      print('📦 Show fields raw: ${results[0].body}');
      print('📦 Mandatory fields raw: ${results[1].body}');
      print('📦 Unique fields raw: ${results[2].body}');

      final showFields = _parseShowFields(results[0]);
      final mandatoryNames = _parseMandatoryNames(results[1]);
      final uniqueNames = _parseUniqueNames(results[2]);

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
        '✅ Loaded ${state.length} asset custom fields '
        '[${state.map((f) => '${f.name}(show=${f.show},mand=${f.mandatory},uniq=${f.isUnique})').join(', ')}]',
      );
    } catch (e, stackTrace) {
      print('❌ Error loading custom fields: $e');
      print('$stackTrace');
      if (!mounted) return;
      state = [];
    }
  }
}

/// Schema for Add Asset / asset list filters (show + mandatory + unique).
final assetCustomFieldsProvider =
    StateNotifierProvider<AssetCustomFieldsNotifier, List<CustomField>>(
  (ref) => AssetCustomFieldsNotifier(),
);

/// Per-asset saved values for the Custom tab (getExtraFields ∩ show).
final assetExtraFieldsProvider = StateNotifierProvider.autoDispose
    .family<AssetCustomFieldsNotifier, List<CustomField>, String>(
  (ref, assetId) => AssetCustomFieldsNotifier(),
);

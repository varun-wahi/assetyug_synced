import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  /// Call this when viewing a specific asset's custom tab
  Future<void> loadExtraFieldsForAsset(String assetId) async {
    try {
      final res = await _repo.getExtraFields(assetId);
      if (!mounted) return;

      if (res.statusCode != 200) {
        state = [];
        return;
      }

      final jsonList = _parseJsonList(res.body);
      state = jsonList
          .map((e) => CustomFieldWithValue.fromExtraFieldJson(
              e as Map<String, dynamic>))
          .toList();

      print('✅ Loaded ${state.length} extra fields');
    } catch (e, stackTrace) {
      print('❌ Error loading extra fields: $e\n$stackTrace');
      state = [];
    }
  }

  Future<void> loadExtraFieldsForEdit(String assetId) async {
    try {
      final res = await _repo.getExtraFields(assetId);
      if (!mounted) return;
      if (res.statusCode != 200) {
        state = [];
        return;
      }
      final jsonList = _parseJsonList(res.body);
      state = jsonList
          .map((e) => CustomFieldWithValue.fromExtraFieldJson(
              e as Map<String, dynamic>))
          .toList();
      print('✅ Loaded ${state.length} extra fields for edit');
    } catch (e, st) {
      print('❌ loadExtraFieldsForEdit: $e\n$st');
      state = [];
    }
  }

  Future<void> loadCustomFields(String companyId) async {
    try {
      print('🔄 Loading custom fields for companyId: $companyId');

      final mandatoryRes = await _repo.getAllMandatoryFields(companyId);

      if (!mounted) return; // ✅ Guard after every await
      print(
          '📦 Mandatory status: ${mandatoryRes.statusCode} body: ${mandatoryRes.body}');

      final showRes = await _repo.getAllShowFields(companyId);

      if (!mounted) return; // ✅ Guard after every await
      print('📦 Show status: ${showRes.statusCode} body: ${showRes.body}');

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

      final Map<String, CustomField> fieldMap = {};
      for (var f in parse(mandatoryRes, true)) {
        fieldMap[f.name] = f;
      }
      for (var f in parse(showRes, false)) {
        fieldMap.putIfAbsent(f.name, () => f);
      }

      state = fieldMap.values.toList();
      print('✅ Loaded ${state.length} custom fields');
    } catch (e, stackTrace) {
      print('❌ Error loading custom fields: $e');
      print('$stackTrace');
    }
  }
}

// final assetCustomFieldsProvider = StateNotifierProvider.autoDispose<
//     AssetCustomFieldsNotifier, List<CustomField>>(
//   (ref) => AssetCustomFieldsNotifier(),
// );
// ✅ Must NOT have autoDispose
final assetCustomFieldsProvider =
    StateNotifierProvider<AssetCustomFieldsNotifier, List<CustomField>>(
  (ref) => AssetCustomFieldsNotifier(),
);

// final assetCustomFieldsProvider = StateNotifierProvider<AssetCustomFieldsNotifier, List<CustomField>>(
//   (ref) => AssetCustomFieldsNotifier(),
// );

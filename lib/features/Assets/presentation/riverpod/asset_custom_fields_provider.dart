import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:asset_yug_debugging/features/Assets/data/models/custom_field.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';

class AssetCustomFieldsNotifier extends StateNotifier<List<CustomField>> {
  AssetCustomFieldsNotifier() : super([]);

  final AssetsRepositoryImpl _repo = AssetsRepositoryImpl();

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
        fieldMap[f.id] = f;
      }
      for (var f in parse(showRes, false)) {
        fieldMap.putIfAbsent(f.id, () => f);
      }

      state = fieldMap.values.toList();
      print('✅ Loaded ${state.length} asset custom fields');
    } catch (e) {
      print('❌ Error loading custom fields: $e');
    }
  }
}

final assetCustomFieldsProvider = StateNotifierProvider.autoDispose<AssetCustomFieldsNotifier, List<CustomField>>(
  (ref) => AssetCustomFieldsNotifier(),
);

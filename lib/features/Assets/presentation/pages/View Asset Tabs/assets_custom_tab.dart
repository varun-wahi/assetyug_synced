// assets_custom_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../config/theme/text_styles.dart';
import '../../../../../core/models/custom_field_model.dart';
import '../../../../../core/utils/constants/colors.dart';
import '../../../../../core/utils/constants/sizes.dart';
import '../../../../../core/utils/widgets/no_data_found.dart';
import '../../riverpod/asset_custom_fields_provider.dart';

class AssetCustomPage extends ConsumerStatefulWidget {
  final String assetId; // ← changed from companyId + assetData

  const AssetCustomPage({
    super.key,
    required this.assetId,
  });

  @override
  ConsumerState<AssetCustomPage> createState() => _AssetCustomPageState();
}

class _AssetCustomPageState extends ConsumerState<AssetCustomPage> {
  @override
  void initState() {
    super.initState();
    // Load on mount
    Future.microtask(
      () => ref
          .read(assetCustomFieldsProvider.notifier)
          .loadExtraFieldsForAsset(widget.assetId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customFields = ref.watch(assetCustomFieldsProvider);

    if (customFields.isEmpty) {
      return const NoDataFoundPage();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(dPadding * 2),
      itemCount: customFields.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: lighterGrey),
      itemBuilder: (context, index) {
        final field = customFields[index];
        print(
            '🔍 field[$index] runtimeType: ${field.runtimeType} name: ${field.name}');
        // Cast to get value if available, fallback to '—'
        final value = field is CustomFieldWithValue ? field.value : '—';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: dPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(field.name,
                    style: subheading(weight: FontWeight.w600)),
              ),
              Expanded(
                flex: 3,
                child: Text(value,
                    style: body(weight: FontWeight.w400),
                    textAlign: TextAlign.end),
              ),
            ],
          ),
        );
      },
    );
  }
}

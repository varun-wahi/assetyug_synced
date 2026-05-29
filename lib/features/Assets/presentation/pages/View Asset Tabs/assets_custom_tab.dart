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
  final String assetId;

  const AssetCustomPage({super.key, required this.assetId});

  @override
  ConsumerState<AssetCustomPage> createState() => _AssetCustomPageState();
}

class _AssetCustomPageState extends ConsumerState<AssetCustomPage> {
  @override
  void initState() {
    super.initState();
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

    return ListView.builder(
      padding: const EdgeInsets.all(dPadding * 2),
      itemCount: customFields.length,
      itemBuilder: (context, index) {
        final field = customFields[index];
        final value = field is CustomFieldWithValue ? field.value : '—';
        final isEmpty = value == '—' || value.trim().isEmpty;

        return Padding(
          padding: const EdgeInsets.only(bottom: dPadding),
          child: Container(
            decoration: BoxDecoration(
              color: lighterGrey.withAlpha(25),
              borderRadius: BorderRadius.circular(dBorderRadius),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: dPadding * 1.5,
              vertical: dPadding * 1.25,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Type icon badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _iconBgColor(field.type).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _iconForType(field.type),
                    size: 18,
                    color: _iconBgColor(field.type),
                  ),
                ),
                const SizedBox(width: dPadding),
                // Label
                Expanded(
                  flex: 2,
                  child: Text(
                    field.name,
                    style: subheading(weight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: dPadding),
                // Value chip
                Container(
                  constraints: const BoxConstraints(maxWidth: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: dPadding,
                    vertical: dPadding * 0.5,
                  ),
                  decoration: BoxDecoration(
                    color: isEmpty
                        ? Colors.transparent
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: isEmpty ? Border.all(color: lighterGrey) : null,
                  ),
                  child: Text(
                    isEmpty ? 'Not set' : value,
                    style: body(weight: FontWeight.w500).copyWith(
                      color: isEmpty
                          ? Colors.grey.shade400
                          : Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

IconData _iconForType(String type) {
  switch (type.toLowerCase()) {
    case 'number':
      return Icons.tag_rounded;
    case 'date':
      return Icons.calendar_today_rounded;
    case 'checkbox':
      return Icons.check_box_outlined;
    default:
      return Icons.text_fields_rounded;
  }
}

Color _iconBgColor(String type) {
  switch (type.toLowerCase()) {
    case 'number':
      return Colors.blue;
    case 'date':
      return Colors.orange;
    case 'checkbox':
      return Colors.green;
    default:
      return Colors.purple;
  }
}

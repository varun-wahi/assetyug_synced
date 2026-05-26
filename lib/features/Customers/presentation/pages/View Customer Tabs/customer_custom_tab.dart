// customers_custom_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/models/custom_field_model.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import '../../../../../core/utils/widgets/no_data_found.dart';
import '../../riverpod/customer_custom_fields_provider.dart';

class CustomersCustomPage extends ConsumerWidget {
  final String customerId;

  const CustomersCustomPage({
    super.key,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fields = ref.watch(customerExtraFieldsProvider(customerId));

    if (fields.isEmpty) {
      return const NoDataFoundPage();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(dPadding * 2),
      itemCount: fields.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: lighterGrey),
      itemBuilder: (context, index) {
        final field = fields[index];
        final value = field is CustomFieldWithValue ? field.value : '—';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: dPadding * 1.5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + label
              Expanded(
                flex: 2,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _iconForType(field.type),
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        field.name,
                        style: subheading(weight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
}

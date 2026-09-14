// customers_custom_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/models/custom_field_model.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import '../../../../../core/utils/widgets/no_data_found.dart';
import '../../riverpod/customer_custom_fields_provider.dart';

class CustomersCustomPage extends ConsumerStatefulWidget {
  final String customerId;

  const CustomersCustomPage({
    super.key,
    required this.customerId,
  });

  @override
  ConsumerState<CustomersCustomPage> createState() =>
      _CustomersCustomPageState();
}

class _CustomersCustomPageState extends ConsumerState<CustomersCustomPage> {
  /// Matches the "Custom" tab index in [BuildCustomerDetailCard].
  static const int _customTabIndex = 3;

  TabController? _tabController;
  bool _loading = false;
  bool _fetching = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = DefaultTabController.maybeOf(context);
    if (controller == _tabController) return;

    _tabController?.removeListener(_onTabChanged);
    _tabController = controller;
    _tabController?.addListener(_onTabChanged);

    // Fetch if this tab is already selected when mounted.
    if (_tabController?.index == _customTabIndex) {
      _reload();
    }
  }

  @override
  void didUpdateWidget(covariant CustomersCustomPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customerId != widget.customerId) {
      _reload();
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    final controller = _tabController;
    if (controller == null || controller.indexIsChanging) return;
    if (controller.index == _customTabIndex) {
      _reload();
    }
  }

  Future<void> _reload() async {
    if (_fetching || widget.customerId.isEmpty) return;
    _fetching = true;
    if (mounted) setState(() => _loading = true);

    try {
      // Invalidate so the family provider is recreated, then fetch fresh.
      ref.invalidate(customerExtraFieldsProvider(widget.customerId));
      await ref
          .read(customerExtraFieldsProvider(widget.customerId).notifier)
          .loadExtraFieldsForCustomer(widget.customerId);
    } finally {
      _fetching = false;
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = ref.watch(customerExtraFieldsProvider(widget.customerId));

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (fields.isEmpty) {
      return const NoDataFoundPage();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(dPadding * 2),
      itemCount: fields.length,
      itemBuilder: (context, index) {
        final field = fields[index];
        final value = field is CustomFieldWithValue ? field.value : '';
        final isEmpty = value.trim().isEmpty || value == '—';

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
                Expanded(
                  flex: 2,
                  child: Text(
                    field.name,
                    style: subheading(weight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: dPadding),
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
}

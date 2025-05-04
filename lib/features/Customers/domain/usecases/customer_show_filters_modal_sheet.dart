import 'package:asset_yug_debugging/features/Customers/presentation/riverpod/customer_filter_notifier.dart';
import 'package:asset_yug_debugging/features/Customers/presentation/riverpod/customer_sorting_notifier.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_divider.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerShowFiltersModalSheet {
  static void showFilterOptions(
    BuildContext context,
    String filterKey,
    String? selectedOption, // Track the selected option
    Map<String, Map<String, String>> pagesFilters,  // Ensure values are Map<String, String>
    WidgetRef ref,
  ) {
    print("FilterKey: $filterKey"); // status sort
    print("pageFilters: $pagesFilters"); // whole file
    print("$filterKey Keys: ${pagesFilters[filterKey]!.keys}");
    print("$filterKey Values: ${pagesFilters[filterKey]!.values}");

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(dPadding),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicator to show the modal can be dragged down
                Container(
                  height: 5,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: dPadding),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Title bar with filterKey
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: dPadding),
                  child: Text(
                    filterKey,
                    style: body(size: 18, weight: FontWeight.bold, color: tBlack),
                  ),
                ),
                // Divider
                const DDivider(),
                // Filter options
                ...pagesFilters[filterKey]!.keys.map((option) => ListTile(
                      title: Text(option),
                      leading: selectedOption == option
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () {
                        // Handle option selection
                        if (filterKey == "Sort by") {
                          // Handle option selection
                          print('Sorting selected: $option');

                          // Access the inner map associated with the selected option
                          final sortOptions = pagesFilters[filterKey] ?? {};
                          final String? selectedSortValue = sortOptions[option];

                          print("Relevant Sort Option: $selectedSortValue");

                          if (selectedSortValue != null) {
                            ref
                                .read(customerSortingProvider.notifier)
                                .updateSort(selectedSortValue);
                          }
                        } else {
                          // Handle option selection for filters
                          print('Filter selected: $option');

                          final filterOptions = pagesFilters[filterKey] ?? {};
                          final String? selectedFilterValue = filterOptions[option];

                          if (selectedFilterValue != null) {
                            ref
                                .read(customerFiltersProvider.notifier)
                                .updateFilter({filterKey: selectedFilterValue});
                          }
                        }

                        Navigator.pop(context);
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
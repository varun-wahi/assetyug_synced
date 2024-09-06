


import 'package:asset_yug_debugging/features/Work%20Orders/presentation/riverpod/wo_filter_notifier.dart';
import 'package:asset_yug_debugging/features/Work%20Orders/presentation/riverpod/wo_sorting_notifier.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_divider.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WOShowFiltersModalSheet {
  static void showFilterOptions(
    BuildContext context,
    String filterKey,
    String? selectedOption, // Track the selected option
    Map<String, Map<String, dynamic>> pagesFilters,
    WidgetRef ref,
  ) {
    print("FilterKey: $filterKey"); //status sort
    print("pageFilters: $pagesFilters"); //whole file
    print("$filterKey Keys: ${pagesFilters[filterKey]!.keys}");
    print("$filterKey Values: ${pagesFilters[filterKey]!.values}");

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(dPadding),
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
                  style:
                      body(size: 18, weight: FontWeight.bold, color: tBlack),
                ),
              ),
              // Divider
              const DDivider(),
              // Filter options
              ...pagesFilters[filterKey]!.keys.map((option) => ListTile(
                    title: Text(option),
                    onTap: () {

                      if (filterKey == "Sort by") {

                      // Handle option selection
                      print('Sorting selected: $option');

                      // Access the inner map associated with the selected option
                      //filterKey = wosFilters.keys.elementAt(index);
                      final sortOptions = pagesFilters[filterKey] ?? {};
                      //*       PAAS THE BELOW VALUE TO PROVIDER!
                      final Map<String, int>? selectedOption =
                          sortOptions[option];

                      print("Relevant Map: $selectedOption");                      

                      if (selectedOption != null) {
                        ref.read(woSortingProvider.notifier).updateSort(selectedOption);
                      } else {
                        ref.read(woFiltersProvider.notifier).updateFilter({});
                      }

                      } else {
                        // Handle option selection
                        print('Filter selected: $option');

                        // Access the inner map associated with the selected option
                        //filterKey = wosFilters.keys.elementAt(index);
                        final filterOptions = pagesFilters[filterKey] ?? {};
                        //*       PAAS THE BELOW VALUE TO PROVIDER!
                        final Map<String, dynamic>? selectedOption =
                            filterOptions[option];

                        print("Relevant Map: $selectedOption");

                        if (selectedOption != null) {
                          ref
                              .read(woFiltersProvider.notifier)
                              .updateFilter(selectedOption);
                        } else {
                          ref
                              .read(woFiltersProvider.notifier)
                              .updateFilter({});
                        }
                      }

                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  //context.read(counterProvider).state++;

  static Map<String, dynamic> returnFilter(Map<String, dynamic>? filter) {
    if (filter != null) {
      return filter;
    } else {
      return {};
    }
  }
}

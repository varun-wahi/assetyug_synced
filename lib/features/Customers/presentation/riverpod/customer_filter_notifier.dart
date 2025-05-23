import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';


class CustomerFilterNotifier extends StateNotifier<Map<String, dynamic>> {
  CustomerFilterNotifier() : super({});
    
  // Track selected filters separately
  final Map<String, String?> _selectedFilters = {};

  // Getter for selected filters
  Map<String, String?> get selectedFilters => _selectedFilters;

  void updateFilter(Map<String, dynamic> filter, [String? filterKey]) {
    state = filter;
    print("added $filter");

    // Update selected filters
    if (filterKey != null) {
      _selectedFilters[filterKey] = filter.isNotEmpty ? filter.keys.first : null;
    }
      // Notify the app to refresh the customer list

  }

  void clearFilters(){
    state = {};
    _selectedFilters.clear();

  }
}

final customerFiltersProvider = StateNotifierProvider<CustomerFilterNotifier, Map<String, dynamic>>((ref) {
  return CustomerFilterNotifier();


});




import 'package:riverpod/riverpod.dart';


class WOFilterNotifier extends StateNotifier<Map<String, dynamic>> {
  WOFilterNotifier() : super({});
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

  }

  void clearFilters(){
    state = {};
  }
}

final woFiltersProvider = StateNotifierProvider<WOFilterNotifier, Map<String, dynamic>>((ref) {
  return WOFilterNotifier();
});





import 'package:riverpod/riverpod.dart';

class AssetFilterNotifier extends StateNotifier<Map<String, dynamic>> {
  AssetFilterNotifier() : super({});

  // Track selected filters separately
  final Map<String, String?> _selectedFilters = {};

  // Getter for selected filters
  Map<String, String?> get selectedFilters => _selectedFilters;

  void updateFilter(Map<String, dynamic> filter, [String? filterKey]) {
    // Update filter state
    state = filter;
    print("added $filter");

    // Update selected filters
    if (filterKey != null) {
      _selectedFilters[filterKey] = filter.isNotEmpty ? filter.keys.first : null;
    }
  }

  void clearFilters() {
    state = {};
    _selectedFilters.clear();
  }
}

final assetFiltersProvider = StateNotifierProvider.autoDispose<AssetFilterNotifier, Map<String, dynamic>>((ref) {
  return AssetFilterNotifier();
});

import 'package:riverpod/riverpod.dart';


class InventoryFilterNotifier extends StateNotifier<Map<String, dynamic>> {
  InventoryFilterNotifier() : super({});

  void updateFilter(Map<String, dynamic> filter) {
    state = filter;
    print("added $filter");

  }

  void clearFilters(){
    state = {};
  }
}

final inventoryFiltersProvider = StateNotifierProvider<InventoryFilterNotifier, Map<String, dynamic>>((ref) {
  return InventoryFilterNotifier();
});




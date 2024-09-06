import 'package:riverpod/riverpod.dart';

class InventorySortingNotifier extends StateNotifier<Map<String, int>> {
  InventorySortingNotifier() : super({});

  void updateSort(Map<String, int> sortingRule) {
    state = sortingRule;
    print("Added sorting rule: $sortingRule");
  }

  void clearSort() {
    state = {};
  }
}

final inventorySortingProvider =
    StateNotifierProvider<InventorySortingNotifier, Map<String, int>>((ref) {
  return InventorySortingNotifier();
});

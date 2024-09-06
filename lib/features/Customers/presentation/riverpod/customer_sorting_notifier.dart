import 'package:riverpod/riverpod.dart';

class CustomerSortingNotifier extends StateNotifier<Map<String, int>> {
  CustomerSortingNotifier() : super({});

  void updateSort(Map<String, int> sortingRule) {
    state = sortingRule;
    print("Added sorting rule: $sortingRule");
  }

  void clearSort() {
    state = {};
  }
}

final customerSortingProvider =
    StateNotifierProvider<CustomerSortingNotifier, Map<String, int>>((ref) {
  return CustomerSortingNotifier();
});

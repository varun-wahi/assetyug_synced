import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerSortingNotifier extends StateNotifier<String> {
  CustomerSortingNotifier() : super('');

  void updateSort(String sortingRule) {
    state = sortingRule;
    print("Added sorting rule: $sortingRule");
  }

  void clearSort() {
    state = '';
  }
}

final customerSortingProvider =
    StateNotifierProvider<CustomerSortingNotifier, String>((ref) {
  return CustomerSortingNotifier();
});
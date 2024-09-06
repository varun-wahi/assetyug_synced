import 'package:riverpod/riverpod.dart';

class WOSortingNotifier extends StateNotifier<Map<String, int>> {
  WOSortingNotifier() : super({});

  void updateSort(Map<String, int> sortingRule) {
    state = sortingRule;
    print("Added sorting rule: $sortingRule");
  }

  void clearSort() {
    state = {};
  }
}

final woSortingProvider =
    StateNotifierProvider<WOSortingNotifier, Map<String, int>>((ref) {
  return WOSortingNotifier();
});

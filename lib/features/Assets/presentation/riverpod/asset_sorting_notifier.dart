import 'package:riverpod/riverpod.dart';

class AssetSortingNotifier extends StateNotifier<String> {
  AssetSortingNotifier() : super('');

  void updateSort(String sortingCategory) {
    state = sortingCategory;
    print("Added sorting rule: $sortingCategory");
  }

  void clearSort() {
    state = '';
  }
}

final assetSortingProvider =
    StateNotifierProvider.autoDispose<AssetSortingNotifier, String>((ref) {
  return AssetSortingNotifier();
});

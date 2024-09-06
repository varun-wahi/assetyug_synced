import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssetSearchTermNotifier extends StateNotifier<String> {
  AssetSearchTermNotifier() : super("");

  void updateSearchTerm(String newTerm) {
    print("Updating search term to: $newTerm");
    state = newTerm;
  }
}

final assetSearchTermProvider = StateNotifierProvider.autoDispose<AssetSearchTermNotifier, String>((ref) {
  return AssetSearchTermNotifier();
});
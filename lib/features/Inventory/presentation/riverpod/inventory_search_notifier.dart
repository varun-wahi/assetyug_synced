import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventorySearchTermNotifier extends StateNotifier<String> {
  InventorySearchTermNotifier() : super("");

  void updateSearchTerm(String newTerm) {
    state = newTerm;
  }
}

final inventorySearchTermProvider = StateNotifierProvider<InventorySearchTermNotifier, String>((ref) {
  return InventorySearchTermNotifier();
});
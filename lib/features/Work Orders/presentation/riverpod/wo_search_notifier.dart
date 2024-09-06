import 'package:flutter_riverpod/flutter_riverpod.dart';

class WOSearchTermNotifier extends StateNotifier<String> {
  WOSearchTermNotifier() : super("");

  void updateSearchTerm(String newTerm) {
    state = newTerm;
  }
}

final woSearchTermProvider = StateNotifierProvider<WOSearchTermNotifier, String>((ref) {
  return WOSearchTermNotifier();
});
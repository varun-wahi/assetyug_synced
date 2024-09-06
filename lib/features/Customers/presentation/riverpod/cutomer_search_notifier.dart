import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerSearchTermNotifier extends StateNotifier<String> {
  CustomerSearchTermNotifier() : super("");

  void updateSearchTerm(String newTerm) {
    state = newTerm;
  }
}

final customerSearchTermProvider = StateNotifierProvider<CustomerSearchTermNotifier, String>((ref) {
  return CustomerSearchTermNotifier();
});

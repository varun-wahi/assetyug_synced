import 'package:asset_yug_debugging/features/Home/data/models/trial_status_model.dart';
import 'package:asset_yug_debugging/features/Home/data/repository/subscription_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final subscriptionRepositoryProvider =
    Provider<SubscriptionRepositoryImpl>((ref) => SubscriptionRepositoryImpl());

/// Access is allowed (paid or trial). Not a "has paid plan" flag.
final subscriptionValidProvider = FutureProvider<bool>((ref) async {
  final repo = ref.read(subscriptionRepositoryProvider);
  return repo.isSubscriptionValid();
});

final trialStatusProvider = FutureProvider<TrialStatusDetails>((ref) async {
  final repo = ref.read(subscriptionRepositoryProvider);
  return repo.getTrialStatusDetails();
});

final trialBannerDismissedProvider = StateProvider<bool>((ref) => false);

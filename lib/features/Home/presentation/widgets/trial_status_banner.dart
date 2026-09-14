import 'package:asset_yug_debugging/features/Home/data/models/trial_status_model.dart';
import 'package:asset_yug_debugging/features/Home/presentation/riverpod/subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrialStatusBanner extends ConsumerWidget {
  const TrialStatusBanner({super.key});

  static const _background = Color(0xFFFBF3C8);
  static const _border = Color(0xFFE6D48A);
  static const _text = Color(0xFF5C4A12);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dismissed = ref.watch(trialBannerDismissedProvider);
    if (dismissed) return const SizedBox.shrink();

    final trialAsync = ref.watch(trialStatusProvider);

    return trialAsync.maybeWhen(
      data: (trial) {
        final message = _bannerMessage(trial);
        if (message == null) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: message.title,
                        style: const TextStyle(
                          color: _text,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: ' ${message.body}',
                        style: const TextStyle(
                          color: _text,
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () =>
                    ref.read(trialBannerDismissedProvider.notifier).state = true,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _text,
                  side: const BorderSide(color: _text),
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  _BannerCopy? _bannerMessage(TrialStatusDetails trial) {
    if (trial.trialEndDate == null) return null;

    final days = trial.daysRemaining;

    if (days < 0) {
      return const _BannerCopy(
        title: 'Free trial expired:',
        body: 'Your free trial has ended. Please subscribe to a plan.',
      );
    }

    if (days == 0) {
      return const _BannerCopy(
        title: 'Free trial expiring soon:',
        body: 'Your free trial expires today. Please subscribe to a plan.',
      );
    }

    final dayLabel = days == 1 ? 'day' : 'days';
    return _BannerCopy(
      title: 'Free trial expiring soon:',
      body:
          'Your free trial will expire in $days $dayLabel. Please subscribe to a plan.',
    );
  }
}

class _BannerCopy {
  final String title;
  final String body;

  const _BannerCopy({required this.title, required this.body});
}

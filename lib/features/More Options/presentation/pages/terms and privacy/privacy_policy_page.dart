import 'package:asset_yug_debugging/features/More%20Options/presentation/pages/terms%20and%20privacy/privacy_strings.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage
  ({super.key});

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title:  const Text('Privacy Policy'),
      ),
      body: Scrollbar(
        child: Padding(
          padding: const EdgeInsets.all(dPadding),
          child: ListView(
            children: privacyPolicyStrings.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entry.key.isNotEmpty) // Only show heading if it's not empty
                    Text(
                      entry.key,
                      style: headline(),
                    ),
                    const DGap(),
                  Padding(
                    padding: const EdgeInsets.all(dPadding),
                    child: Text(
                      entry.value,
                      style:  body(weight: FontWeight.w400),
                    ),
                  ),
                  const DGap(gap: dGap*2),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

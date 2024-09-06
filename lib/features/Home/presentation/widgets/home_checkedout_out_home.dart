import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Assets/presentation/riverpod/asset_filter_notifier.dart';
import '../../../Main/presentation/riverpod/tab_notifier.dart';
import '../../../Assets/data/repository/assets_mongodb.dart';
import '../../../../core/utils/constants/sizes.dart';
import '../../../../core/utils/constants/strings.dart';
import '../../../../config/theme/box_shadow_styles.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../core/utils/widgets/loading_animated_container.dart';

class BuildCheckOutAssetsContainer extends ConsumerWidget {
  const BuildCheckOutAssetsContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.read(tabProvider.notifier).setTab(1);
        ref
            .read(assetFiltersProvider.notifier)
            .updateFilter({"status": checkOutString});
      },
      child: buildCheckedOutContainer(context),
    );
  }
}

FutureBuilder buildCheckedOutContainer(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return FutureBuilder(
    future: AssetsMongoDB.fetchAssetsByCategory(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return LoadingAnimatedContainer(height: 130, width: screenWidth);
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else {
        final assetData = snapshot.data ?? [];
        return Container(
          padding: const EdgeInsets.all(dPadding),
          decoration: BoxDecoration(
            color: tWhite,
            borderRadius: BorderRadius.circular(dBorderRadius),
            boxShadow: dBoxShadow(),
            border: Border.all(width: 0.2, color: lighterGrey),
          ),
          height: 130,
          width: screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "${assetData.length}",
                  textAlign: TextAlign.center,
                  style: boldHeading(size: 30),
                ),
              ),
              const SizedBox(height: dGap * 2),
              Text(
                "Checked Out Assets",
                style: subheading(weight: FontWeight.w400),
              ),
              const SizedBox(height: dPadding),
            ],
          ),
        );
      }
    },
  );
}

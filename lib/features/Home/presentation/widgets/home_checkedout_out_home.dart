import 'dart:convert';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';  // Import Hive for local storage

import '../../../Assets/presentation/riverpod/asset_filter_notifier.dart';
import '../../../Main/presentation/riverpod/tab_notifier.dart';
import '../../../../core/utils/constants/sizes.dart';
import '../../../../core/utils/constants/strings.dart';
import '../../../../config/theme/box_shadow_styles.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../core/utils/widgets/loading_animated_container.dart';
import 'package:http/http.dart' as http;

class BuildCheckOutAssetsContainer extends ConsumerStatefulWidget {
  const BuildCheckOutAssetsContainer({super.key});

  @override
  _BuildCheckOutAssetsContainerState createState() => _BuildCheckOutAssetsContainerState();
}

class _BuildCheckOutAssetsContainerState extends ConsumerState<BuildCheckOutAssetsContainer> {
  String? companyId;

  @override
  void initState() {
    super.initState();
    fetchCompanyId();  // Fetch companyId on widget initialization
  }

  Future<void> fetchCompanyId() async {
    final box = await Hive.openBox('auth_data');
    setState(() {
      companyId = box.get('companyId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ref.read(tabProvider.notifier).setTab(1);
        // context
        //     .read(assetFiltersProvider.notifier)
        //     .updateFilter({"status": checkOutString});
      },
      child: companyId == null
          ? LoadingAnimatedContainer(
              height: 130, width: MediaQuery.of(context).size.width)
          : buildCheckedOutContainer(context),
    );
  }

  FutureBuilder buildCheckedOutContainer(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: AssetsRepositoryImpl().checkInCheckOutCount(companyId!),  // Pass the companyId here
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingAnimatedContainer(height: 130, width: screenWidth);
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data is http.Response) {
          // Parse the data from the response
          final response = snapshot.data as http.Response;
          if (response.statusCode == 200) {
            final assetData = json.decode(response.body);  // Assuming the response contains a count or list

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
                      "${assetData['checkOut'] ?? 0}",  // Adjust based on what your API returns
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
          } else {
            return Center(child: Text('Error: ${response.statusCode}'));
          }
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}
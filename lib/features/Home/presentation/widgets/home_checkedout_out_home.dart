import 'dart:convert';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart'; // Import Hive for local storage

import '../../../Assets/presentation/riverpod/asset_filter_notifier.dart';
import '../../../Main/presentation/riverpod/tab_notifier.dart';
import '../../../../core/utils/constants/sizes.dart';
import '../../../../core/utils/constants/strings.dart';
import '../../../../config/theme/box_shadow_styles.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../core/utils/widgets/loading_animated_container.dart';
import 'package:http/http.dart' as http;

class BuildAssetOverviewContainer extends ConsumerStatefulWidget {
  const BuildAssetOverviewContainer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BuildAssetOverviewContainerState createState() =>
      _BuildAssetOverviewContainerState();
}

class _BuildAssetOverviewContainerState
    extends ConsumerState<BuildAssetOverviewContainer> {
  String? companyId;

  @override
  void initState() {
    super.initState();
    fetchCompanyId();
  }

  Future<void> fetchCompanyId() async {
    final box = await Hive.openBox('auth_data');
    setState(() {
      companyId = box.get('companyId');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        _buildAssetStatusRow(screenWidth),
        const SizedBox(height: 20),
        Text("Total Avgerage Asset Uptime: 91%", style: boldHeading(size: 16)),
        const SizedBox(height: 20),
        _buildAssetCategorySection(),
        const SizedBox(height: 20),
        _buildCustomerCategorySection(),
      ],
    );
  }

  Widget _buildAssetStatusRow(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatusCard("Active Assets", "45", screenWidth * 0.35),
        FutureBuilder(
          future: AssetsRepositoryImpl().checkInCheckOutCount(companyId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildStatusCard(
                  "Checked Out Asset", "...", screenWidth * 0.45);
            } else if (snapshot.hasError) {
              return _buildStatusCard(
                  "Checked Out Asset", "Error", screenWidth * 0.45);
            } else if (snapshot.hasData && snapshot.data is http.Response) {
              final response = snapshot.data as http.Response;
              final assetData = json.decode(response.body);
              return _buildStatusCard("Checked Out Asset",
                  "${assetData['checkOut'] ?? 0}", screenWidth * 0.45);
            } else {
              return _buildStatusCard(
                  "Checked Out Asset", "No data", screenWidth * 0.45);
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String count, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(dPadding),
      decoration: BoxDecoration(
        color: tWhite,
        borderRadius: BorderRadius.circular(dBorderRadius),
        boxShadow: dBoxShadow(),
        border: Border.all(width: 0.2, color: lighterGrey),
      ),
      height: 130,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(count, style: boldHeading(size: 30)),
          const SizedBox(height: dGap),
          Text(title, style: subheading(weight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, String count, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(dPadding),
      decoration: BoxDecoration(
        color: tWhite,
        borderRadius: BorderRadius.circular(dBorderRadius),
        boxShadow: dBoxShadow(),
        border: Border.all(width: 0.2, color: lighterGrey),
      ),
      height: 130,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(count, style: boldHeading(size: 16)),
          const SizedBox(height: dGap),
          Text(title, style: subheading(weight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildAssetCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Asset by Category", style: boldHeading(size: 18)),
        const SizedBox(height: dGap),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Container(
                  decoration: BoxDecoration(
                      color: tWhite,
                      border: Border.all(color: tGreyLight),
                      borderRadius: BorderRadius.circular(dBorderRadius)),
                  width: 110,
                  child: _buildTableCell(
                      "${index + 1}A", (24 + index).toString()));
            },
            separatorBuilder: (context, index) {
              return const DGap(
                vertical: false,
                gap: 4,
              );
            },
            itemCount: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(String count, String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(count, style: boldHeading(size: 16)),
          Text(label, style: subheading(size: 14)),
        ],
      ),
    );
  }

  Widget _buildCustomerCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Asset by Customer Category", style: boldHeading(size: 18)),
        const SizedBox(height: dGap),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Container(
                  decoration: BoxDecoration(
                      color: tWhite,
                      border: Border.all(color: tGreyLight),
                      borderRadius: BorderRadius.circular(dBorderRadius)),
                  width: 110,
                  child: _buildTableCell(
                      "CST A${index + 1}", (4 + index).toString()));
            },
            separatorBuilder: (context, index) {
              return const DGap(
                vertical: false,
                gap: 4,
              );
            },
            itemCount: 5,
          ),
        ),
      ],
    );
  }
}

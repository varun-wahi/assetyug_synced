import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/View%20Asset%20Tabs/assets_files_tab.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/View%20Asset%20Tabs/assets_wO_tab.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // Add this import

import '../../data/models/assets_model.dart';
import 'View Asset Tabs/assets_check_in_out_tab.dart';
import 'View Asset Tabs/assets_custom_tab.dart';
import 'View Asset Tabs/assets_edit_details_tab.dart';

class ViewAssetPage extends StatefulWidget {
  final String assetObjectId;
  const ViewAssetPage({super.key, required this.assetObjectId});

  @override
  State<ViewAssetPage> createState() => _ViewAssetPageState();
}

class _ViewAssetPageState extends State<ViewAssetPage> {
  final AssetsRepositoryImpl _assetsRepository = AssetsRepositoryImpl();

  @override
  Widget build(BuildContext context) {
    print("asset id: ${widget.assetObjectId}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Asset Details"),
        centerTitle: true,
        actions: const [IconButton(onPressed: null, icon: Icon(Icons.more_vert))],
      ),
      body: Center(
        child: FutureBuilder(
          future: _assetsRepository.getAssetDetails(widget.assetObjectId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final assetData = snapshot.data;
              if (assetData != null) {
                final assetMap = jsonDecode(assetData.body) as Map<String, dynamic>;
                return BuildAssetDetailCard(assetData: assetMap);
              } else {
                return const Text('Asset not found');
              }
            }
          },
        ),
      ),
    );
  }
}

class BuildAssetDetailCard extends StatefulWidget {
  const BuildAssetDetailCard({
    super.key,
    required this.assetData,
  });

  final Map<String, dynamic>? assetData;

  @override
  State<BuildAssetDetailCard> createState() => _BuildAssetDetailCardState();
}

class _BuildAssetDetailCardState extends State<BuildAssetDetailCard> {
  @override
  Widget build(BuildContext context) {
    var data = AssetsModel.fromJson(widget.assetData!);
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          TabBar(
            tabAlignment: TabAlignment.center,
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: const EdgeInsets.symmetric(
                horizontal: 2 * dPadding), // Adjust padding as needed
            indicatorPadding: const EdgeInsets.symmetric(
                horizontal: dPadding / 2), // 5px gap on each side
            dividerHeight: 0.2,
            automaticIndicatorColorAdjustment: true,
            isScrollable: true,
            indicatorColor: tPrimary,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(
                  width: 5.0,
                  color: tPrimary), // Adjust thickness and color
              // insets: EdgeInsets.symmetric(horizontal: dPadding),
            ),
            // indicator: BoxDecoration(
            //   color: tPrimary,
            //   border: Border.all(color: tBlack),
            //   borderRadius: BorderRadius.circular(dBorderRadius),
            // ),
            // labelColor: tWhite,
            labelColor: tBlack,
            labelStyle: boldHeading(size: 14),
            dividerColor: tBlack,
            unselectedLabelColor: lighterGrey,
            onTap: (value) {
              //DO SOMETHING HERE
            },
            tabs: const [
              Tab(child: SizedBox(width: 100, child: Center(child: Text("Edit Details")))),
              Tab(child: SizedBox(width: 100, child: Center(child: Text("Check In/Out")))),
              Tab(child: SizedBox(width: 100, child: Center(child: Text("Files")))),
              Tab(child: SizedBox(width: 100, child: Center(child: Text("WOs")))),
              // Tab(child: SizedBox(width: 100, child: Center(child: Text("Parts")))),
              // Tab(child: SizedBox(width: 100, child: Center(child: Text("Custom")))),
            ],
          ),
          const SizedBox(height: dGap),
          Expanded(
            child: TabBarView(
              children: [
                AssetEditDetailsPage(assetData: data),
                AssetCheckInOutPage(objectId: data.id!),
                AssetFilesPage(objectId: data.id!),


                AssetWOsPage(objectId: data.id!),
                // AssetPartsPage(serialNo: data.assetId),
                // AssetCustomPage(companyId: data.companyId, assetId: data.id!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

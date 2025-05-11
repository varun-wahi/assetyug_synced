import 'dart:convert';
import 'package:asset_yug_debugging/core/usecases/capitalize_string.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart'; // Import Hive for local storage

import '../../../../core/utils/constants/sizes.dart';
import '../../../../config/theme/box_shadow_styles.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../config/theme/text_styles.dart';
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
        Text("Total Average Asset Uptime: 91%", style: boldHeading(size: 16)),
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
        // _buildStatusCard("Active Assets", "45", screenWidth * 0.35),
        FutureBuilder(
          future: AssetsRepositoryImpl().getActiveAssets(companyId ?? ""),
          // future: AssetsRepositoryImpl().getActiveAssets("66cb7047b00e537755e4d878"),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildStatusCard(
                  "Active Assets", "...", screenWidth * 0.45);
            } else if (snapshot.hasError) {
              return _buildStatusCard(
                  "Active Assets", "Error", screenWidth * 0.45);
            } else if (snapshot.hasData && snapshot.data is http.Response) {
              final response = snapshot.data as http.Response;

              if (response.statusCode == 200 && response.body.isNotEmpty) {
                try {
                  final assetData = json.decode(response.body);
                  if (assetData is List) {
                    return _buildStatusCard(
                      "Active Assets",
                      "${assetData.length}",
                      screenWidth * 0.45,
                    );
                  } else {
                    return _buildStatusCard(
                      "Active Assets",
                      "Invalid data",
                      screenWidth * 0.45,
                    );
                  }
                } catch (e) {
                  print("JSON Decoding Error: $e");
                  return _buildStatusCard(
                    "Active Assets",
                    "Invalid data",
                    screenWidth * 0.45,
                  );
                }
              } else {
                print("Empty or Error Response: ${response.body}");
                return _buildStatusCard(
                  "Active Assets",
                  "No data",
                  screenWidth * 0.45,
                );
              }
            } else {
              return _buildStatusCard(
                  "Active Assets", "No data", screenWidth * 0.45);
            }
          },
        ),

        Spacer(),

        FutureBuilder(
          future: AssetsRepositoryImpl().checkInCheckOutCount(companyId ?? ""),
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


Widget _buildAssetCategorySection() {
  return FutureBuilder(
    future: AssetsRepositoryImpl().getAssetsByCategories(companyId ?? ""),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Show a loading indicator while waiting for data
        return const Center(child: const CircularProgressIndicator());
      } else if (snapshot.hasError) {
        // Handle errors gracefully
        return const Text(
          "Error loading asset categories",
          style: TextStyle(color: Colors.red),
        );
      } else if (snapshot.hasData && snapshot.data is http.Response) {
        final response = snapshot.data as http.Response;

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          try {
            // Parse the API response
            final Map<String, dynamic> assetCategories = json.decode(response.body);

            // Extract categories and their counts
            final categories = assetCategories.keys.toList();
            final categoryCounts = categories.map((key) => assetCategories[key]?.length ?? 0).toList();

            // Render the list of categories dynamically
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
                      final category = categories[index];
                      final itemCount = categoryCounts[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: tWhite,
                          border: Border.all(color: tGreyLight),
                          borderRadius: BorderRadius.circular(dBorderRadius),
                        ),
                        width: 110,
                        child: _buildTableCell(category.toCapitalized(), "$itemCount"),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const DGap(
                        vertical: false,
                        gap: 4,
                      );
                    },
                    itemCount: categories.length,
                  ),
                ),
              ],
            );
          } catch (e) {
            // Handle JSON parsing errors
            return const Text(
              "Error parsing data",
              style: TextStyle(color: Colors.red),
            );
          }
        } else {
          // Handle empty or invalid response
          return const Text(
            "No asset categories available",
            style: TextStyle(color: Colors.grey),
          );
        }
      } else {
        // Handle any other unexpected cases
        return const Text("No data available", style: TextStyle(color: Colors.grey));
      }
    },
  );
}



  Widget _buildTableCell(String count, String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            count,
            style: boldHeading(size: 16),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            label,
            style: subheading(size: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
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

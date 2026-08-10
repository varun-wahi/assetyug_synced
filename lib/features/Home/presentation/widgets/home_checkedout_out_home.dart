import 'dart:convert';
import 'package:asset_yug_debugging/core/usecases/capitalize_string.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Customers/data/repository/company_customer_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart'; // Import Hive for local storage
import 'package:shimmer/shimmer.dart'; // Import shimmer for loading states

import '../../../../core/utils/constants/sizes.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../config/theme/text_styles.dart';
import 'package:http/http.dart' as http;

import '../../../Assets/presentation/pages/assets_page.dart';
import '../../../Main/presentation/riverpod/refresh_provider.dart';

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
      debugPrint("company id fetched: $companyId");
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Watch refreshProvider to trigger rebuilds when assets change
    ref.watch(refreshProvider);

    return Column(
      children: [
        _buildAssetStatusRow(screenWidth),
        // const SizedBox(height: 20),
        // Text("Total Average Asset Uptime: 91%", style: boldHeading(size: 16)),
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

        const Spacer(),

        FutureBuilder(
          future: AssetsRepositoryImpl().checkInCheckOutCount(companyId ?? ""),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildStatusCard(
                  "Checked Out Assets", "...", screenWidth * 0.45,
                  isCheckOutButton: true);
            } else if (snapshot.hasError) {
              return _buildStatusCard(
                  "Checked Out Assets", "Error", screenWidth * 0.45,
                  isCheckOutButton: true);
            } else if (snapshot.hasData && snapshot.data is http.Response) {
              final response = snapshot.data as http.Response;
              final assetData = json.decode(response.body);
              return _buildStatusCard("Checked Out Assets",
                  "${assetData['checkOut'] ?? 0}", screenWidth * 0.45,
                  isCheckOutButton: true);
              // "${assetData['checkOut'] ?? 0}", screenWidth * 0.45);
            } else {
              return _buildStatusCard(
                  "Checked Out Assets", "No data", screenWidth * 0.45,
                  isCheckOutButton: true);
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String count, double width,
      {bool isCheckOutButton = false}) {
    final Color cardColor =
        isCheckOutButton ? tCheckedOutCardBg : tActiveAssetsCardBg;
    final Color textColor =
        isCheckOutButton ? tCheckedOutCardText : tActiveAssetsCardText;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssetsPage(
              predefinedFilters: isCheckOutButton
                  ? {"status": "", "Checking Status": "Checked Out"}
                  : {"status": "Active", "Checking Status": "All"},
            ),
          ),
        );
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.all(dPadding),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(dBorderRadius * 1.5),
          // border: Border.all(
          //   color: textColor.withValues(alpha: 0.4),
          //   width: 1,
          // ),
          // boxShadow: [
          //   BoxShadow(
          //     color: textColor.withValues(alpha: 0.4),
          //     blurRadius: 3,
          //     offset: Offset(0, 1),
          //   ),
          // ],
        ),
        height: 110,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(count, style: boldHeading(size: 22, color: textColor)),
            const SizedBox(height: dGap),
            Text(title,
                style: subheading(weight: FontWeight.w400, color: textColor)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Shimmer placeholders
  // ---------------------------------------------------------------------

  // Horizontal shimmer placeholder mimicking the "Assets by Category" cards.
  Widget _buildAssetCategoryShimmer() {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(dBorderRadius),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const DGap(
            vertical: false,
            gap: 8,
          );
        },
        itemCount: 5,
      ),
    );
  }

  // Vertical shimmer placeholder mimicking the "Assets by Customer" rows.
  Widget _buildCustomerCategoryShimmer() {
    return Column(
      children: List.generate(5, (index) {
        final isLast = index == 4;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : dPadding),
          child: Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(dBorderRadius),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAssetCategorySection() {
    // Wait until companyId is fetched — keep the heading visible while
    // showing a shimmer placeholder instead of a bare spinner.
    if (companyId == null) {
      return _buildSection(
        "Assets by Category",
        _buildAssetCategoryShimmer(),
      );
    }
    return FutureBuilder(
      future: AssetsRepositoryImpl().countAssetByCategories(companyId ?? ""),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a shimmer placeholder while waiting for data, heading stays visible.
          return _buildSection(
            "Assets by Category",
            _buildAssetCategoryShimmer(),
          );
        } else if (snapshot.hasError) {
          // Handle errors gracefully
          return _buildSection(
            "Assets by Category",
            const Text(
              "Error loading asset categories",
              style: TextStyle(color: Colors.red),
            ),
          );
        } else if (snapshot.hasData && snapshot.data is http.Response) {
          final response = snapshot.data as http.Response;
          print('ASSET CATEGORIES RESPONSE: ${response.body}');

          if (response.statusCode == 200 && response.body.isNotEmpty) {
            try {
              // Parse the API response — now a List of category objects
              final decoded = json.decode(response.body);

              if (decoded is! List || decoded.isEmpty) {
                return _buildSection(
                  "Assets by Category",
                  _buildEmptyAssetCategoryState(),
                );
              }

              final categories = decoded.cast<Map<String, dynamic>>();

              // Render the list of categories dynamically
              return _buildSection(
                "Assets by Category",
                SizedBox(
                  height: 70,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      final categoryName =
                          (item['categoryName'] as String? ?? 'Unknown')
                              .toCapitalized();
                      final assetCount = item['assetCount'] is num
                          ? (item['assetCount'] as num).toInt()
                          : int.tryParse(
                                  item['assetCount']?.toString() ?? '0') ??
                              0;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssetsPage(
                                predefinedFilters: {
                                  "status": "Active",
                                  "Checking Status": "All",
                                  "category":
                                      categoryName, // 👈 Pass category as filter
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: tCardBackground,
                            boxShadow: [
                              BoxShadow(
                                color: tBorderPalette[
                                    index % tBorderPalette.length],
                                blurRadius: 2,
                                offset: const Offset(0, 2),
                              )
                            ],
                            // border: Border.all(
                            //     color: tBorderPalette[
                            //         index % tBorderPalette.length],
                            //     width: 0.6),
                            borderRadius: BorderRadius.circular(dBorderRadius),
                          ),
                          width: 110,
                          child: _buildTableCell(categoryName, "$assetCount"),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const DGap(
                        vertical: false,
                        gap: 8,
                      );
                    },
                    itemCount: categories.length,
                  ),
                ),
              );
            } catch (e) {
              // Handle JSON parsing errors
              print('Error parsing asset categories: $e');
              return _buildSection(
                "Assets by Category",
                const Text(
                  "Error parsing data",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
          } else {
            // Handle empty or invalid response
            return _buildSection(
              "Assets by Category",
              const Text(
                "No asset categories available",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
        } else {
          // Handle any other unexpected cases
          return _buildSection(
            "Assets by Category",
            const Text("No data available",
                style: TextStyle(color: Colors.grey)),
          );
        }
      },
    );
  }

  Widget _buildEmptyAssetCategoryState() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.inventory_2_outlined,
          size: 40,
          color: lighterGrey,
        ),
        SizedBox(height: 8),
        Text(
          "No asset categories found",
          style: TextStyle(
            color: darkGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Assets will appear here once added",
          style: TextStyle(
            color: darkGrey,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(title, style: boldHeading(size: 18))),
        const SizedBox(height: dGap),
        Align(alignment: Alignment.center, child: child),
      ],
    );
  }

  Widget _buildTableCell(String count, String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            count,
            style: body(size: 14, weight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            label,
            style: subheading(size: 17),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCategorySection() {
    return FutureBuilder(
      future: CompanyCustomerRepositoryImpl().getAssetCountByCustomer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSection(
            "Assets by Customer",
            _buildCustomerCategoryShimmer(),
          );
        } else if (snapshot.hasError) {
          return _buildSection(
            "Assets by Customer",
            const Text(
              "Error loading customer data",
              style: TextStyle(color: Colors.red),
            ),
          );
        } else if (snapshot.hasData && snapshot.data is http.Response) {
          final response = snapshot.data as http.Response;
          print('CUSTOMER CATEGORIES RESPONSE: ${response.body}');

          if (response.statusCode == 200 && response.body.isNotEmpty) {
            try {
              final decoded = json.decode(response.body);
              final List<MapEntry<String, int>> customerCounts = [];

              if (decoded is Map) {
                decoded.forEach((key, value) {
                  int count = 0;
                  if (value is num) {
                    count = value.toInt();
                  } else if (value is String) {
                    count = int.tryParse(value) ?? 0;
                  } else if (value is List) {
                    count = value.length;
                  }
                  customerCounts.add(MapEntry(key.toString(), count));
                });
              } else if (decoded is List) {
                for (var item in decoded) {
                  if (item is Map) {
                    final name = item['companyCustomerName'] ?? 'Unknown';
                    final countVal = item['assetCount'] ?? item['count'] ?? 0;
                    int count = 0;
                    if (countVal is num) {
                      count = countVal.toInt();
                    } else if (countVal is String) {
                      count = int.tryParse(countVal) ?? 0;
                    }
                    customerCounts.add(MapEntry(name.toString(), count));
                  }
                }
              }

              if (customerCounts.isEmpty) {
                return _buildSection(
                  "Assets by Customer (Top 0)",
                  const Text(
                    "No customer asset data available",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              // Show top 20
              final displayList = customerCounts.take(20).toList();

              return _buildSection(
                "Assets by Customer",
                // Vertical list instead of horizontal scroll: each customer
                // is a full-width row, stacked top to bottom.
                Column(
                  children: List.generate(displayList.length, (index) {
                    final entry = displayList[index];
                    final companycustomername = entry.key;
                    final isLast = index == displayList.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : dPadding),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssetsPage(
                                predefinedFilters: {
                                  "status": "Active",
                                  "Checking Status": "All",
                                  "customer":
                                      companycustomername == "Unassigned"
                                          ? ""
                                          : companycustomername,
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: tCardBackground,
                            // border: Border.all(
                            //     color: tBorderPalette[
                            //         index % tBorderPalette.length],
                            //     width: 0.6),
                            boxShadow: [
                              BoxShadow(
                                color: tBorderPalette[
                                    index % tBorderPalette.length],
                                blurRadius: 2,
                                offset: const Offset(0, 2),
                              )
                            ],
                            borderRadius: BorderRadius.circular(dBorderRadius),
                          ),
                          child: _buildCustomerRow(
                            entry.key,
                            "${entry.value}",
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            } catch (e) {
              return _buildSection(
                "Assets by Customer",
                const Text(
                  "Error parsing customer data",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
          } else {
            // Handle empty or invalid response, keep title
            return _buildSection(
              "Assets by Customer",
              const Text(
                "No customer asset data available",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
        } else {
          return _buildSection(
            "Assets by Customer",
            const Text("No data available",
                style: TextStyle(color: Colors.grey)),
          );
        }
      },
    );
  }

  // Row layout for a customer entry in the vertical list: name on the
  // left, count on the right (mirrors _buildTableCell's data, different
  // layout since this is now a full-width row instead of a narrow card).
  Widget _buildCustomerRow(String name, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: body(size: 14, weight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Text(
            count,
            style: subheading(size: 17),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

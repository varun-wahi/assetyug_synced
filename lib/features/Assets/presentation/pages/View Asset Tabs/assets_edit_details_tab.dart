import 'dart:convert';
import 'dart:typed_data';

import 'package:asset_yug_debugging/core/usecases/capitalize_string.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/widgets/checking_btn_widget_assets.dart';
import 'package:asset_yug_debugging/features/Main/presentation/riverpod/refresh_provider.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_check_in_out_model.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_model.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/config/theme/image_strings.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_divider.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/widgets/details_row_widget_assets.dart';

class AssetEditDetailsPage extends ConsumerWidget {
  final AssetsModel assetData;

  const AssetEditDetailsPage({super.key, required this.assetData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("ASSET DATA: ${assetData.toJson()}");
    

    final shouldRefresh = ref.watch(refreshProvider);
    // Uint8List bytes = base64.decode(assetData.image ?? defaultImage);
    final rawBase64 = (assetData.image ?? defaultImage).split(',').last;
Uint8List bytes = base64.decode(rawBase64);

    return FutureBuilder(
      future: AssetsRepositoryImpl().getCheckInOutList(assetData.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(dBorderRadius),
                child: Image.memory(
                  bytes,
                  height: 200,
                  width: MediaQuery.of(context).size.width - (4 * dPadding),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Error loading image'));
                  },
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: dPadding * 3, vertical: dPadding * 2),
                  color: tWhite,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DDetailsRow(
                          title: "Asset Name", value: assetData.name),
                      // const DDivider(),
                      DDetailsRow(
                          title: "Asset ID: ", value: assetData.assetId.toString()),
                      // const DDivider(),
                      DDetailsRow(
                          title: "Serial No: ", value: assetData.serialNumber),
                      // const DDivider(),
                      DDetailsRow(
                          title: "Category: ",
                          value:
                              assetData.category.isNotEmpty ? assetData.category : "--"),
                      // const DDivider(),
                      DDetailsRow(
                          title: "Customer: ",
                          value: (assetData.customer?.isNotEmpty ?? false)
                              ? assetData.customer!
                              : "--"),
                      // const DDivider(),
                      DDetailsRow(
                          title: "Location: ",
                          value: assetData.location.isNotEmpty
                              ? assetData.location
                              : "No location data"),
                      // const DDivider(),
                      DDetailsRow(
                          title: "Status: ",
                          value: assetData.status.isNotEmpty
                              ? assetData.status.toCapitalized()
                              : "No status data"),
                      // const DDivider(),
                      DDetailsRow(
                        title: "Current Status: ",
                        value: _getCheckingStatusValue(snapshot),
                      ),
                      const DDivider(),
                      SizedBox(
                        height: 60,
                        child: _buildCheckingStatusSection(assetData, ref, snapshot),
                      ),
                      const DGap(),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Map<String, dynamic>? _getLastCheckEntry(AsyncSnapshot snapshot) {
  try {
    if (snapshot.hasData && snapshot.data.statusCode == 202) {
      final List<dynamic> jsonData = json.decode(snapshot.data.body);
      if (jsonData.isNotEmpty) {
        final checkingDetails = AssetCheckInOutModel.fromJson(jsonData.first);
        if (checkingDetails.detailsList.isNotEmpty) {
          return {
            "status": checkingDetails.detailsList.last.status,
            "employee": checkingDetails.detailsList.last.employee,
            "date": checkingDetails.detailsList.last.date,
          };
        }
      }
    }
  } catch (e) {
    debugPrint("Error extracting last check-in/out: $e");
  }
  return null;
}

  // Widget _buildCheckingStatusSection(AssetsModel assetData, WidgetRef ref, AsyncSnapshot<dynamic> snapshot) {
  //   if (snapshot.connectionState == ConnectionState.waiting) {
  //     return const Center(
  //       child: SizedBox(
  //         width: 30,
  //         height: 30,
  //         child: CircularProgressIndicator(color: tWhite,),
  //       ),
  //     );
  //   } else if (snapshot.hasError) {
  //     return Text('Error: ${snapshot.error}');
  //   } else if (snapshot.hasData && snapshot.data.statusCode == 202) {
  //     final List<dynamic> jsonData = json.decode(snapshot.data.body);
  //     print("jsonData: $jsonData");
  //     if (jsonData.isNotEmpty) {
  //       try {
  //         final checkingDetails = AssetCheckInOutModel.fromJson(jsonData.first);              
  //         if (checkingDetails.detailsList.isNotEmpty) {
  //           final detailsListLast = checkingDetails.detailsList.last;
  //           print("detailsListLast: ${detailsListLast}");
  //           return Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(//!TO Fix Here
  //                 "${detailsListLast.status} by ${detailsListLast.employee} on \n${DateFormat('yyyy/MM/dd').format(detailsListLast.date ?? DateTime.now())}",
  //                 style: containerText(),
  //               ),
  //               AssetStatusButton(data: assetData, ref: ref)
  //             ],
  //           );
  //         }
  //       } catch (e) {
  //         print("Error parsing JSON: $e");
  //         print("jsonData: $jsonData");
  //         return Text('Error parsing data: $e');
  //       }
  //     }else{
  //       return Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(//!TO Fix Here

  //                 "Checked in by ${assetData.customer} on (fix) \n${DateFormat('yyyy/MM/dd').format(DateTime.now())}",
  //                 style: containerText(),
  //               ),
  //               AssetStatusButton(data: assetData, ref: ref)
  //             ],
  //           );
  //     }
  //   }
  //   return const NoDataFoundPage();
  // }

  Widget _buildCheckingStatusSection(
    AssetsModel assetData, WidgetRef ref, AsyncSnapshot snapshot) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
  } else if (snapshot.hasError) {
    return Text('Error: ${snapshot.error}');
  }

  final entry = _getLastCheckEntry(snapshot);
  final statusText = entry != null
      ? "${entry['status']} by ${entry['employee']} on \n${DateFormat('yyyy/MM/dd').format(entry['date'] ?? DateTime.now())}"
      : "Checked in by ${assetData.customer} on \n${DateFormat('yyyy/MM/dd').format(DateTime.now())}";

  return Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: tGreyLight,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(statusText, style: containerText()),
      ),
      AssetStatusButton(data: assetData, ref: ref),
    ],
  ),
);
}

  // String _getCheckingStatusValue(AsyncSnapshot<dynamic> snapshot) {
  //   if (snapshot.connectionState == ConnectionState.waiting) {
  //     return "Loading...";
  //   } else if (snapshot.hasError) {
  //     print("ERROR: ${snapshot.error}");
  //     return "Error loading status";
  //   } else if (snapshot.hasData) {
  //     final checkInOutData = snapshot.data;
  //     if (checkInOutData != null && checkInOutData.statusCode == 202) {
  //       final decodedData = json.decode(checkInOutData.body);
  //       if (decodedData.isNotEmpty) {
  //         final lastStatus = decodedData.last['status'];
  //         print("LAST STATUS: $lastStatus");
  //         return lastStatus ?? "Checked In (default)";
  //       }
  //     }
  //   }
  //   return "Checked In";
  // }

  String _getCheckingStatusValue(AsyncSnapshot snapshot) {
  final entry = _getLastCheckEntry(snapshot);
  if (entry != null) {
    return "${entry['status']} by ${entry['employee']} on ${DateFormat('yyyy/MM/dd').format(entry['date'] ?? DateTime.now())}";
  }
  return "Checked In";
}
}

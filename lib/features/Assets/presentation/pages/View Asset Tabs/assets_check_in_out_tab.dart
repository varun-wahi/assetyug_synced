import 'package:asset_yug_debugging/features/Assets/data/repository/assets_mongodb.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_check_in_out_model.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_checking_details_model.dart';
import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:asset_yug_debugging/config/theme/box_shadow_styles.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class AssetCheckInOutPage extends StatefulWidget {
  final String objectId;
  const AssetCheckInOutPage({super.key, required this.objectId});

  @override
  State<AssetCheckInOutPage> createState() => _AssetCheckInOutPageState();
}

class _AssetCheckInOutPageState extends State<AssetCheckInOutPage> {
  List<AssetCheckInOutModel> checkInOutData = [];

  @override
  void initState() {
    super.initState();
    fetchCheckInOutData();
  }

  Future<void> fetchCheckInOutData() async {
    try {
      final assetRepo = AssetsRepositoryImpl();
      final response = await assetRepo.getCheckInOutList(widget.objectId);
      if (response.statusCode == 202) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          checkInOutData = jsonData.map((data) => AssetCheckInOutModel.fromJson(data)).toList();
        });
      } else {
        print("Error: ${response.statusCode}");
        // Handle error state
      }
    } catch (e) {
      print("Error fetching check-in/out data: $e");
      // Handle error state
    }
  }

  @override
  Widget build(BuildContext context) {
    if (checkInOutData.isEmpty) {
      return const Center(
        child: SizedBox(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ListView.separated(
      itemBuilder: (context, index) {
        final data = checkInOutData[index].detailsList.reversed.toList();
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, detailIndex) {
            final detail = data[detailIndex];
            return Container(
              padding: const EdgeInsets.all(dPadding * 2),
              margin: const EdgeInsets.symmetric(horizontal: dPadding, vertical: dPadding),
              decoration: BoxDecoration(
                color: tPrimary,
                borderRadius: BorderRadius.circular(dBorderRadius),
              ),
              child: Column(
                children: [
                  _buildRow("Status:", detail.status ?? "--"),
                  _buildRow("Notes:", detail.notes?.isNotEmpty ?? false ? detail.notes! : "--"),
                  _buildRow("Employee:", detail.employee ?? "--"),
                  _buildRow("Location:", detail.location?.isNotEmpty ?? false ? detail.location! : "--"),
                  _buildRow("Date:", detail.date != null ? DateFormat('yyyy-MM-dd').format(detail.date!) : "--"),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => const DGap(),
          itemCount: data.length,
        );
      },
      separatorBuilder: (context, index) => const DGap(),
      itemCount: checkInOutData.length,
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: containerText(size: 15, weight: FontWeight.w600, color: tWhite)),
        Text(value, style: containerText(color: tWhite)),
      ],
    );
  }
}

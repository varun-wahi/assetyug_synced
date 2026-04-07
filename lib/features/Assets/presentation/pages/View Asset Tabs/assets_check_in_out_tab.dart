import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_check_in_out_model.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

class AssetCheckInOutPage extends StatefulWidget {
  final String objectId;
  const AssetCheckInOutPage({super.key, required this.objectId});

  @override
  State<AssetCheckInOutPage> createState() => _AssetCheckInOutPageState();
}

class _AssetCheckInOutPageState extends State<AssetCheckInOutPage> {
  List<AssetCheckInOutModel> checkInOutData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCheckInOutData();
  }

  Future<void> fetchCheckInOutData() async {
    try {
      final assetRepo = AssetsRepositoryImpl();
      final response = await assetRepo.getCheckInOutList(widget.objectId);
      if (response.statusCode == 200 || response.statusCode == 202) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          checkInOutData = jsonData
              .map((data) => AssetCheckInOutModel.fromJson(data))
              .toList();
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching check-in/out data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SingleChildScrollView(
        child: Column(
          children: List.generate(
            6,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: dPadding),
              child: Shimmer.fromColors(
                baseColor: tPrimary,
                highlightColor: tPrimary.withAlpha(50),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(dBorderRadius),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (checkInOutData.isEmpty) {
      return const NoDataFoundPage();
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
              margin: const EdgeInsets.symmetric(
                horizontal: dPadding,
              ),
              decoration: BoxDecoration(
                color: tPrimary,
                borderRadius: BorderRadius.circular(dBorderRadius),
              ),
              child: Column(
                children: [
                  _buildRow("Status:", detail.status ?? "--"),
                  _buildRow("Notes:",
                      detail.notes?.isNotEmpty ?? false ? detail.notes! : "--"),
                  _buildRow("Employee:", detail.employee ?? "--"),
                  _buildRow(
                      "Location:",
                      detail.location?.isNotEmpty ?? false
                          ? detail.location!
                          : "--"),
                  _buildRow(
                      "Date:",
                      detail.date != null
                          ? DateFormat('yyyy-MM-dd HH:mm').format(detail.date!)
                          : "--"),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => const DGap(
            gap: 2.0,
          ),
          itemCount: data.length,
        );
      },
      separatorBuilder: (context, index) => const DGap(
        gap: 0,
      ),
      itemCount: checkInOutData.length,
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: containerText(
                size: 15, weight: FontWeight.w600, color: tWhite)),
        Flexible(
            child: Text(value,
                style: containerText(color: tWhite),
                overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

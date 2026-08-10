import 'dart:convert';
import 'dart:typed_data';

import 'package:asset_yug_debugging/core/usecases/capitalize_string.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_check_in_out_model.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_model.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/view_asset_page.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/widgets/checking_btn_widget_assets.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_divider.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/widgets/details_row_widget_assets.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/add_asset_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class AssetEditDetailsPage extends ConsumerStatefulWidget {
  final AssetsModel assetData;

  const AssetEditDetailsPage({super.key, required this.assetData});

  @override
  ConsumerState<AssetEditDetailsPage> createState() =>
      _AssetEditDetailsPageState();
}

class _AssetEditDetailsPageState extends ConsumerState<AssetEditDetailsPage> {
  Map<String, dynamic>? lastCheckEntry;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchLastCheckEntry();
  }

  Future<void> _fetchLastCheckEntry() async {
    try {
      final response =
          await AssetsRepositoryImpl().getCheckInOutList(widget.assetData.id!);
      if (response.statusCode == 202) {
        final List<dynamic> jsonData = json.decode(response.body);
        if (jsonData.isNotEmpty) {
          final checkModel =
              AssetCheckInOutModel.fromJson(jsonData.last).detailsList;
          if (checkModel.isNotEmpty) {
            final last = checkModel.first;
            setState(() {
              lastCheckEntry = {
                "status": last.status,
                "employee": last.employee,
                "date": last.date,
              };
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading check-in/out: $e");
      setState(() => hasError = true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawBase64 = (widget.assetData.image)?.split(',').last ?? "";
    final bytes = base64.decode(rawBase64);

    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(dBorderRadius),
              child: Image.memory(
                bytes,
                height: 200,
                width: MediaQuery.of(context).size.width - (4 * dPadding),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width - (4 * dPadding),
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported,
                          size: 48, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: tPrimary,
                  shape: const CircleBorder(),
                ),
                icon: const Icon(Icons.edit, color: tWhite),
                onPressed: _navigateToEditPage,
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: dPadding * 3,
              vertical: dPadding * 2,
            ),
            color: tWhite,
            child: isLoading
                ? _buildShimmer()
                : hasError
                    ? const Center(child: Text("Failed to load check-in data"))
                    : _buildDetails(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    final asset = widget.assetData;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DDetailsRow(title: "Asset Name", value: asset.name),
        DDetailsRow(title: "Asset ID", value: asset.assetId ?? "--"),
        DDetailsRow(title: "Serial No", value: asset.serialNumber ?? "--"),
        DDetailsRow(
            title: "Category",
            value: asset.category.isNotEmpty ? asset.category : "--"),
        DDetailsRow(
            title: "Customer",
            value: asset.customer?.isNotEmpty == true ? asset.customer! : "--"),
        DDetailsRow(
            title: "Location",
            value: asset.location.isNotEmpty
                ? asset.location
                : "No location data"),
        DDetailsRow(
            title: "Status",
            value: asset.status.isNotEmpty
                ? asset.status.toCapitalized()
                : "No status data"),
        // DDetailsRow(title: "Current Status", value: ""),
        Text(_formatCheckStatus()),
        const DDivider(),
        const DGap(gap: 4),
        _buildStatusSection(),
        const DGap(gap: 8),
      ],
    );
  }

  Widget _buildStatusSection() {
    final asset = widget.assetData;
    final dateText = lastCheckEntry != null
        ? DateFormat('yyyy/MM/dd HH:mm').format(lastCheckEntry!['date'])
        : DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now());

    final text = lastCheckEntry != null
        ? "${lastCheckEntry!['status']} by ${lastCheckEntry!['employee']} on \n$dateText"
        : "Checked in by ${asset.customer} on \n$dateText";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 245, 245),
        borderRadius: BorderRadius.circular(8),
      ),
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(text, style: containerText())),
          AssetStatusButton(
            data: asset,
            ref: ref,
            onStatusChanged: (status) async {
              await _fetchLastCheckEntry();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(
        6,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 20,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToEditPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAssetPage(editAsset: widget.assetData),
      ),
    );

    if (result == true) {
      Navigator.pop(context, true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ViewAssetPage(assetObjectId: widget.assetData.id!),
        ),
      );
    }
  }

  String _formatCheckStatus() {
    if (lastCheckEntry != null) {
      final date = lastCheckEntry!['date'];
      final formattedDate = DateFormat('yyyy/MM/dd HH:mm').format(date);
      return "${lastCheckEntry!['status']} by ${lastCheckEntry!['employee']} on $formattedDate";
    }
    return "Checked In";
  }
}

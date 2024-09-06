import 'package:asset_yug_debugging/features/Assets/data/models/assets_model.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/view_asset_page.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/widgets/checking_btn_widget_assets.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/config/theme/box_shadow_styles.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/features/Main/presentation/riverpod/refresh_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

class AssetsDetailsCard extends ConsumerWidget {
  final AssetsModel data;
  const AssetsDetailsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final assetRepo = AssetsRepositoryImpl();
        final response = await assetRepo.getAssetDetails(data.id!);
        final assetDetails = AssetsModel.fromJson(jsonDecode(response.body));
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ViewAssetPage(assetObjectId: assetDetails.id!),
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: tWhite,
          borderRadius: BorderRadius.circular(dBorderRadius),
          // boxShadow: dBoxShadow(color: Colors.black12),
          border: Border.all(width: D_BORDER_WIDTH, color: Colors.black26),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: dPadding * 2,
          horizontal: dPadding,
        ),
        child: ListTile(
          title: Text(
            data.name,
            style: boldHeading(size: 17),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DGap(gap: dGap / 2),
              Text(
                "Serial No: ${data.serialNumber}",
                style: containerText(weight: FontWeight.w400),
              ),
              const DGap(gap: dGap / 2),
              Text(
                "Customer: ${data.customer}",
                style: containerText(weight: FontWeight.w400),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AssetStatusButton(data: data, ref: ref),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    // Implement your delete functionality here
                    final assetsRepo = AssetsRepositoryImpl();
                    await assetsRepo.removeAsset(data.id!);
                    ref.read(refreshProvider.notifier).state = !ref.read(refreshProvider);
                    print("deleted asset: ${data.id.toString()}");
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ];
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

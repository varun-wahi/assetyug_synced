import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/text_styles.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../core/utils/constants/sizes.dart';
import '../../../Assets/presentation/pages/add_asset_page.dart';
import '../../../Assets/presentation/pages/assets_page.dart';
import '../pages/scan_qr_page.dart';
import 'serial_search_dialog.dart';

class BuildOptionsSection extends ConsumerWidget {
  const BuildOptionsSection({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void searchAsset(String serialNumber) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssetsPage(
            serialNumber: serialNumber,
          ),
        ),
      );
    }

    void showSearchOptions() {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (BuildContext context) {
          return Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text("Scan Asset ID"),
                onTap: () {
                  Navigator.pop(context); // Close the BottomSheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScanCodePage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_2),
                title: const Text("Scan Serial Barcode"),
                onTap: () {
                  Navigator.pop(context); // Close the BottomSheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScanCodePage(), // Add relevant page for serial barcode
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text("Search Asset by Asset ID"),
                onTap: () async {
                  Navigator.pop(context); // Close the BottomSheet
                  String? assetId = await SerialSearchDialog.show(context);
                  if (assetId != null && assetId.isNotEmpty) {
                    searchAsset(assetId);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text("Search Asset by Serial Number"),
                onTap: () async {
                  Navigator.pop(context); // Close the BottomSheet
                  String? serialNumber = await SerialSearchDialog.show(context);
                  if (serialNumber != null && serialNumber.isNotEmpty) {
                    searchAsset(serialNumber);
                  }
                },
              ),
            ],
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: tWhite,
        borderRadius: BorderRadius.circular(dBorderRadius),
        border: Border.all(width: .1, color: lighterGrey),
      ),
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tWhite,
                    foregroundColor: tBlack,
                    elevation: 2.0,
                  ),
                  onPressed: showSearchOptions,
                  child: const Icon(
                    Icons.search,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(
                height: dPadding,
              ),
              Text(
                "Search Asset",
                style: body(),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tWhite,
                    foregroundColor: tBlack,
                    elevation: 2.0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddAssetPage(),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.add,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(
                height: dPadding,
              ),
              Text(
                "Add Asset",
                style: body(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
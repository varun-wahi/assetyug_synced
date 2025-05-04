import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/widgets/my_elevated_button.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/asset_by_serial_dto_model.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Home/presentation/pages/scan_serial_barcode.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';

class SerialSearchDialog {
  static Future<String?> show(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search Asset'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Enter Serial Number',
                  border: OutlineInputBorder(), // Added outline border
                ),
              ),
              const DGap(),
              Text(
                "OR",
                style: subtitle(),
              ),
              DElevatedButton(
                icon: const Icon(Icons.qr_code_2),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScanSerialBarcode(),
                      )),
                  child: const Text("Scan Serial Number"))
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            DElevatedButton(
              child: const Text('Search'),
              onPressed: () async {
                //navigate to that asset
                String serialNumber = searchController.text.trim();
                await searchAsset(serialNumber);
                Navigator.of(context)
                    .pop(serialNumber); // Return the serial number
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> searchAsset(String serialNumber) async {
    var box = await Hive.openBox('auth_data');
    final String companyId = box.get('companyId');
    print("company ID: $companyId");
    Response result = await AssetsRepositoryImpl().assetFromSerialNumber(
        AssetBySerialDTO(companyId: companyId, serialNumber: serialNumber));
    print(result.body);
  }
}


import 'package:asset_yug_debugging/features/Assets/data/repository/assets_mongodb.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_model.dart';
import 'package:asset_yug_debugging/features/Customers/data/models/customers_model.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/view_asset_page.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_divider.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/config/theme/box_shadow_styles.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:flutter/material.dart';

class CustomerAssetsPage extends StatefulWidget {
  final CustomersModel data;
  const CustomerAssetsPage({super.key, required this.data});

  @override
  State<CustomerAssetsPage> createState() => _CustomerAssetsPageState();
}

class _CustomerAssetsPageState extends State<CustomerAssetsPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildCustomerAssetList(widget.data.companyCustomerId),
    );
  }
}

FutureBuilder _buildCustomerAssetList(int customerId) {
  return FutureBuilder(
      future: AssetsMongoDB.fetchCustomerAssets(customerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 220.0,
              child: SizedBox(
                height: 50.0,
                width: 50.0,
                child: Center(child: CircularProgressIndicator()),
              ));
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final data = snapshot.data;
          if (snapshot.hasData && data != null && data.isNotEmpty) {
            //FIX THE LINE BELOW
            

            print("Data Length: ${data.length}");

            return ListView.separated(
                itemBuilder: (context, index) {
                  final customerFilesData = AssetsModel.fromJson(data[index]);
                  return  InkWell(
                    onTap: (){
                      //go to that assets view page
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAssetPage(assetObjectId: customerFilesData.id!)));
                    
                    },
                    child: Container(
                      decoration: BoxDecoration(
                      color: tPrimary,
                        borderRadius: BorderRadius.circular(dBorderRadius),
                        boxShadow:dBoxShadow()
                      ),
                      padding: const EdgeInsets.all(dPadding*2),
                      child: Column(
                        children: [
                          _buildDetailRow("Asset Name:", customerFilesData.name),
                          // _buildDetailRow("Asset ID:", customerFilesData.assetId.toString()),
                          _buildDetailRow("Asset Status:", customerFilesData.status),
                    
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const DGap(),
                itemCount: data.length //!TO FIX LENGTH
                );
          }
          return const NoDataFoundPage();
        }
      });
}

Row _buildDetailRow(String title, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: subheading(color: tWhite),
      ),
      Text(value, style: const TextStyle(color: tWhite),),
    ],
  );
}

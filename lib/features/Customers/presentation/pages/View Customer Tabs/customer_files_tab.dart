
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_mongodb.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/asset_files_model.dart';
import 'package:asset_yug_debugging/features/Customers/data/models/customers_model.dart';
import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/config/theme/box_shadow_styles.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../Assets/domain/usecases/asset_files_functions.dart';

class CustomerFilesPage extends ConsumerWidget {
  final CustomersModel data;
  const CustomerFilesPage({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildAddFileRow(context),
        Expanded(
          child: _buildFilesList(context, ref, data.companyCustomerId),
        ),
      ],
    );
  }

  SizedBox _buildAddFileRow(BuildContext context) {
    return SizedBox(
      height: 50,
      width: MediaQuery.sizeOf(context).width,
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width / 1.2,
          ),
          IconButton(
            onPressed: () {
              //TODO: #1 Add files for customer
              return dSnackBar(context, "Feature coming soon!", TypeSnackbar.info);
            },
            alignment: Alignment.center,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  _buildFilesList(BuildContext context, WidgetRef ref, int customerID) {
    return FutureBuilder(
        future: AssetsMongoDB.fetchCustomerFiles(customerID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
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
              final filesData = snapshot.data;
              // TODO: #3 ADD ASSET ID ALONG WITH IT
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(dPadding),
                  child: ListView.separated(
                    itemCount: filesData!.length,
                    itemBuilder: (context, index) {
                      final data = AssetFilesModel.fromJson(filesData[index]);
                      return _buildFileContainer(data);
                    },
                    separatorBuilder: (context, index) {
                      return const DGap();
                    },
                  ),
                ),
              );
            } 
              return const NoDataFoundPage();
            
          }
        }
        );
  }

  Container _buildFileContainer(AssetFilesModel data) {
    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: dPadding*2, vertical: dPadding),
                      decoration: BoxDecoration(
                      color: tPrimary,
                        border: Border.all(width: D_BORDER_WIDTH, color: lighterGrey),
                        // boxShadow: dBoxShadow(),
                        borderRadius: BorderRadius.circular(dBorderRadius)

                      ),
                      // height: 40,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data.fileName.isNotEmpty
                                ? data.fileName
                                : "Unnamed File",
                            textAlign: TextAlign.center,
                            style: body(weight: FontWeight.w400, size: 16, color: tWhite),
                          ),
                          IconButton(
                              onPressed: () async {
                                // bool isWaitingToLoadFile = false;
                                // setState(() {
                                //   isWaitingToLoadFile = true;
                                // });
                                await AssetFilesFunctions(
                                        binaryString: data.assetFile,
                                        fileName: data.fileName)
                                    .downloadAndOpenFile();
                                // }, icon: isWaitingToLoadFile? const CircularProgressIndicator():const Icon(Icons.download))
                              },
                              icon: const Icon(Icons.download),
                              color: tWhite,
                              )
                        ],
                      ),
                    );
  }
}

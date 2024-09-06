import 'package:asset_yug_debugging/features/Assets/data/repository/assets_mongodb.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/asset_files_model.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/extraFieldsForm.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomersCustomPage extends ConsumerWidget {
  final int assetId;
  const CustomersCustomPage({super.key, required this.assetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildAddFileRow(context),
        Expanded(child: _buildFilesList()),
      ],
    );
  }

  FutureBuilder<List<Map<String, dynamic>>?> _buildFilesList() {
    return FutureBuilder(
      future: AssetsMongoDB.fetchFiles(assetId.toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
                height: 30, width: 30, child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final filesData = snapshot.data;

          if (filesData != null && filesData.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(dPadding),
                child: ListView.separated(
                  itemCount: filesData.length,
                  itemBuilder: (context, index) {
                    final data = AssetFilesModel.fromJson(filesData[index]);
                    return NoDataFoundPage();
                  },
                  separatorBuilder: (context, index) {
                    return const DGap();
                  },
                ),
              ),
            );
          } else {
            return const NoDataFoundPage();
          }
        } else {
          return const NoDataFoundPage();
        }
      },
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
              showCreateCustomFieldDialog(context); 
              // return dSnackBar(context, "Feature coming soon!");
            },
            alignment: Alignment.center,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }


  void showCreateCustomFieldDialog(BuildContext context){
    showDialog( builder: (context) {
      return Dialog(
        backgroundColor: tBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dBorderRadius)),
        child: AssetCreateCustomField(assetId: assetId.toString()),
      );
      
    }, context: context);
  }
}




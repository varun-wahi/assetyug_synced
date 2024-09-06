import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:flutter/material.dart';

// ... (keep other imports commented)

class AssetWOsPage extends StatefulWidget {
  final String objectId;
  const AssetWOsPage({super.key, required this.objectId});

  @override
  State<AssetWOsPage> createState() => _AssetWOsPageState();
}

class _AssetWOsPageState extends State<AssetWOsPage> {
  @override
  Widget build(BuildContext context) {
    return const NoDataFoundPage();

    // Comment out the existing FutureBuilder
    /*
    return FutureBuilder(
      future: AssetsRepositoryImpl().getWorkOrders(widget.objectId),
      builder: (context, snapshot) {
        // ... (existing code)
      },
    );
    */
  }

  // Keep this method commented
  /*
  Column buildWODetailsContainer(WorkOrdersModel data) {
    // ... (existing code)
  }
  */
}

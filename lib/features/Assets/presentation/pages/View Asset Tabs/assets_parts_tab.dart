

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AssetPartsPage extends StatefulWidget {
  final int serialNo;
  const AssetPartsPage({super.key, required this.serialNo});

  @override
  State<AssetPartsPage> createState() => _AssetPartsPageState();
}

class _AssetPartsPageState extends State<AssetPartsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Parts Tab for Asset ID: ${widget.serialNo}'),
    );
  }
}

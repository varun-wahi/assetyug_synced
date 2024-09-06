

import 'package:asset_yug_debugging/features/Customers/data/models/customers_model.dart';
import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerWOsPage extends StatefulWidget {
  final CustomersModel data;
  const CustomerWOsPage({super.key, required this.data});

  @override
  State<CustomerWOsPage> createState() => _CustomerWOsPageState();
}

class _CustomerWOsPageState extends State<CustomerWOsPage> {
  //TODO: FIX THIS TAB
  @override
  Widget build(BuildContext context) {
    return const NoDataFoundPage();
  }
}

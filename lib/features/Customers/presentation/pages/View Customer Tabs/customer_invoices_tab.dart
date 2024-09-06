
import 'package:asset_yug_debugging/features/Customers/data/models/customers_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerInvoicesPage extends StatefulWidget {
  final CustomersModel data;
  const CustomerInvoicesPage({super.key, required this.data});

  @override
  State<CustomerInvoicesPage> createState() => _CustomerInvoicesPageState();
}

class _CustomerInvoicesPageState extends State<CustomerInvoicesPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Invoices Tab for Customer ${widget.data.name}'),
    );
  }
}

import 'package:asset_yug_debugging/core/usecases/capitalize_string.dart';
import 'package:asset_yug_debugging/features/Customers/data/models/customers_model.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_divider.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:flutter/material.dart';

import '../../../domain/usecases/extract_initials.dart';

class CustomerDetailsPage extends StatefulWidget {
  final CustomersModel data;
  const CustomerDetailsPage({super.key, required this.data});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      color: tOrange,
                      width: 100,
                      height: 100,
                      child: Center(child: Text(extractInitials(widget.data.name), style: headline(color: tWhite,),)),
                    ),
                  ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: dPadding * 3, vertical: dPadding * 2),
            color: tWhite,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DGap(),
                _buildDetailRow("Customer Name: ", widget.data.name),
                const DDivider(),
                 _buildDetailRow(
                    "Email: ",
                    widget.data.address.isNotEmpty == true
                        ? widget.data.email
                        : "No location data"),
                const DDivider(),
                _buildDetailRow(
                    "Phone: ",
                    widget.data.address.isNotEmpty == true
                        ? widget.data.phone.toString()
                        : "--"),
                        const DDivider(),
                _buildDetailRow(
                    "Address: ",
                    widget.data.address.isNotEmpty == true
                        ? widget.data.address
                        : "--"),
                const DDivider(),
                _buildDetailRow(
                    "Apartment: ", widget.data.apartment.toString()),
                const DDivider(),
                _buildDetailRow(
                    "City: ",
                    widget.data.city.isNotEmpty == true
                        ? widget.data.city
                        : "--"),
                const DDivider(),
                _buildDetailRow(
                    "State: ",
                    widget.data.state.isNotEmpty == true
                        ? widget.data.state
                        : "--"),
                const DDivider(),
                _buildDetailRow(
                    "Zip Code: ",
                    widget.data.zipCode.toString().isNotEmpty == true
                        ? widget.data.zipCode.toString()
                        : "--"),
                const DDivider(),
                _buildDetailRow(
                    "Category: ",
                    widget.data.category.isNotEmpty == true
                        ? widget.data.category
                        : "No status data"),
                const DDivider(),
               
                _buildDetailRow(
                    "Status: ",
                    widget.data.status.isNotEmpty == true
                        ? widget.data.status.toUpperCase()
                        : "No status data"),
                const DGap(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Row _buildDetailRow(String title, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: containerText(size: 16, weight: FontWeight.w600),
      ),
      Text(value),
    ],
  );
}

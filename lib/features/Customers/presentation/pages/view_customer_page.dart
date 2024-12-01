import 'dart:convert';

import 'package:asset_yug_debugging/features/Customers/data/models/customers_model.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/company_customer_repository_impl.dart';
import 'View Customer Tabs/customer_assets_tab.dart';
import 'View Customer Tabs/customer_custom_tab.dart';
import 'View Customer Tabs/customer_details_tab.dart';
import 'View Customer Tabs/customer_files_tab.dart';
import 'View Customer Tabs/customer_wO_tab.dart';

class ViewCustomerPage extends ConsumerWidget {
  final String customerObjectId;
  const ViewCustomerPage({super.key, required this.customerObjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerRepo = CompanyCustomerRepositoryImpl();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Customer Details"),
          centerTitle: true,
          actions: const [
            IconButton(onPressed: null, icon: Icon(Icons.more_vert))
          ],
        ),
        body: Center(
          child: FutureBuilder(
            future: customerRepo.getCompanyCustomerDetails(customerObjectId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final customerData = snapshot.data;
                if (customerData != null) {
                  final customerMap =
                      jsonDecode(customerData.body) as Map<String, dynamic>;

                  return BuildCustomerDetailCard(
                      customerData:
                          customerMap); // Replace with your data field
                } else {
                  return const Text('Customer not found');
                }
              }
            },
          ),
        ));
  }
}

class BuildCustomerDetailCard extends StatefulWidget {
  const BuildCustomerDetailCard({
    super.key,
    required this.customerData,
  });

  final Map<String, dynamic>? customerData;

  @override
  State<BuildCustomerDetailCard> createState() =>
      _BuildCustomerDetailCardState();
}

class _BuildCustomerDetailCardState extends State<BuildCustomerDetailCard> {
  @override
  Widget build(BuildContext context) {
    var data = CustomersModel.fromJson(widget.customerData!);
    return DefaultTabController(
      length: 5,
      // length: 6,
      child: Column(
        children: [
          TabBar(
              tabAlignment: TabAlignment.center,
              indicatorSize:
                  TabBarIndicatorSize.tab, // Ensure indicator fills tab width

              // Custom properties for equal width and gap
              labelPadding: const EdgeInsets.symmetric(
                  horizontal: 2 * dPadding), // Adjust padding as needed
              indicatorPadding: const EdgeInsets.symmetric(
                  horizontal: dPadding / 2), // 5px gap on each side
              dividerHeight: 0.2,
              automaticIndicatorColorAdjustment: true,
              isScrollable: true,
              indicatorColor: tPrimary,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(
                    width: 5.0, color: tPrimary), // Adjust thickness and color
                // insets: EdgeInsets.symmetric(horizontal: dPadding),
              ),
              // indicator: BoxDecoration(
              //   color: tPrimary,
              //   border: Border.all(color: tBlack),
              //   borderRadius: BorderRadius.circular(dBorderRadius),
              // ),
              // labelColor: tWhite,
              labelColor: tBlack,
              labelStyle: boldHeading(size: 14),
              dividerColor: tBlack,
              // unselectedLabelColor: tBlack,
              unselectedLabelColor: lighterGrey,
              onTap: (value) {
                //DO SOMETHING HERE
              },
              tabs: const [
                Tab(
                    child: SizedBox(
                        width: 100,
                        child: Center(child: Text("View Details")))),
                Tab(
                    child: SizedBox(
                        width: 100, child: Center(child: Text("Assets")))),
                Tab(
                    child: SizedBox(
                        width: 100, child: Center(child: Text("Files")))),
                Tab(
                    child: SizedBox(
                        width: 100, child: Center(child: Text("WOs")))),
                // Tab(
                //     child: SizedBox(
                //         width: 100, child: Center(child: Text("Invoices")))),
                // Tab(
                //     child: SizedBox(
                //         width: 100, child: Center(child: Text("Custom")))),
              ]),
          const SizedBox(height: dGap),
          /**
           * CONTENT INSIDE EACH TAB,,,
           */
          Expanded(
            child: TabBarView(
              children: [
                CustomerDetailsPage(data: data),
                CustomerAssetsPage(data: data),
                CustomerFilesPage(objectId: widget.customerData?['id']),
                CustomerWOsPage(data: data),
                // CustomerInvoicesPage(data: data),
                // CustomersCustomPage(
                //   companyId: widget.customerData?['companyId'],
                //   customerId: widget.customerData?['id'],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

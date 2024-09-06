// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:asset_yug_debugging/features/Customers/presentation/riverpod/customer_filter_notifier.dart';
import 'package:asset_yug_debugging/features/Customers/presentation/riverpod/customer_sorting_notifier.dart';
import 'package:asset_yug_debugging/features/Customers/presentation/riverpod/cutomer_search_notifier.dart';
import 'package:asset_yug_debugging/features/Customers/data/repository/customer_mongodb.dart';
import 'package:asset_yug_debugging/features/Customers/domain/usecases/customer_show_filters_modal_sheet.dart';
import 'package:asset_yug_debugging/features/Customers/domain/usecases/extract_initials.dart';
import 'package:asset_yug_debugging/features/Customers/presentation/pages/view_customer_page.dart';
import 'package:asset_yug_debugging/features/Customers/data/models/customers_model.dart';
import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:asset_yug_debugging/core/utils/constants/pageFilters.dart';
import 'package:asset_yug_debugging/config/theme/box_shadow_styles.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_searchbar.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_selected_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/widgets/my_elevated_button.dart';
import '../../../../core/utils/widgets/d_gap.dart';

class CustomersPage extends ConsumerWidget {
  const CustomersPage({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: tBackground,
      appBar: AppBar(
        title: const Text("Customers"),
        centerTitle: true,
       
      ),
      body: Center(
        child: Container(
          height: MediaQuery.sizeOf(context).height - 100,
          padding: const EdgeInsets.all(dPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BuildSearchSection(),
              const DGap(gap: dGap),
              const BuildFiltersSection(),
              const BuildCustomerListSection()
            ],
          ),
        ),
      ),
    );
  }
}

class BuildFiltersSection extends ConsumerWidget {
  const BuildFiltersSection({super.key});

  void _clearFilters(BuildContext context, WidgetRef ref) {
    //CLEAR FILTERS
    print("Cleared Filters");

    //REMOVE FILTERS FROM PROVIDER
    // TODO: Update the tab index
    ref.read(customerFiltersProvider.notifier).clearFilters();

    //POP
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilters = ref.watch(customerFiltersProvider.notifier).selectedFilters;

    return Row(
      children: [
        //LIST OF SELECTED FILTERS
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(dPadding),
            height: 70,
            width: 200,
            child: ListView.separated(
              padding: const EdgeInsets.all(dPadding),
              itemBuilder: (context, index) {
                String filterKey = customerFilters.keys.elementAt(index);
                return DSelectedFilterItem(
                    selectedOption: selectedFilters[filterKey] ?? '',
                    isDropdown: true,
                    title: filterKey,
                    onPressed: () {
                      onTap:
                      // () => FocusScope.of(context).unfocus();
                      CustomerShowFiltersModalSheet.showFilterOptions(context, filterKey, selectedFilters[filterKey],customerFilters, ref);
                      //SEND REQUEST TO ASSETS MONGODB
                    });
              },
              itemCount: customerFilters.length,

              // itemCount: 1,
              separatorBuilder: (context, index) {
                return const SizedBox(width: dPadding);
              },
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
        //FILTER BUTTON
         Expanded(
          child: IconButton(
            
            
              // onPressed: () => _buildAdvancedFilters(context, ref),
              onPressed: null,
              icon: const Icon(
                Icons.filter_alt,
                // size: 40,
                // color: darkGrey,
              )),
        ),
      ],
    );
  }

  void _buildAdvancedFilters(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(2 * dPadding),
          decoration: const BoxDecoration(
              color: tWhite,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0))),
          height: 500,
          // width: MediaQuery.sizeOf(context).width - 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            // mainAxisSize: MainAxisSize.min,
            children: [
              //HEADING ROW
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Select Filters',
                      style: boldHeading(),
                    ),
                    TextButton(
                        onPressed: () => _clearFilters(context, ref),
                        child: Text(
                          "CLEAR",
                          style: boldHeading(size: 16),
                        )),
                  ],
                ),
              ),

              SizedBox(
                height: 40,
                child: DElevatedButton(
                  buttonColor: tBlack,
                  textColor: tWhite,
                  child: const Text('Apply Filters'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
    );
  }
}

class BuildSearchSection extends ConsumerWidget {
  final searchTextFieldController = TextEditingController();

  BuildSearchSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void searchCustomer() {
      final String search = searchTextFieldController.text;
      ref.read(customerSearchTermProvider.notifier).updateSearchTerm(search);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: DSearchBar(
            hintText: "Search all customers",
            controller: searchTextFieldController,
            onChanged: (value) => searchCustomer(),
          ),
        ),
        const DGap(vertical: false),
      ],
    );
  }
}

class BuildCustomerListSection extends ConsumerWidget {
  const BuildCustomerListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, dynamic> selectedFilters = ref.watch(customerFiltersProvider);
    Map<String, int> selectedSort = ref.watch(customerSortingProvider);
    print("Filters: $selectedFilters");
    String searchTerm = ref.watch(customerSearchTermProvider);

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(dBorderRadius),
          color: tBackground,
          border: Border.all(width: .2, color: lighterGrey),
        ),
        // height: 500,
        padding: const EdgeInsets.all(dPadding),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          /*/
              
                    A P P L Y F I L T E R S
              
                  */
          // stream: WorkOrdersMongodb.getWorkOrdersDataStream(""),
          future: CustomerMongoDb.getCustomerDataStream(searchTerm: searchTerm,
              filter: selectedFilters, sortOption: selectedSort),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              if (snapshot.hasData) {
                var totalData = snapshot.data?.length;
                print("Customer Data Length: " + totalData.toString());

                if (totalData != 0) {
                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: totalData!,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: dGap),
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      //
                      //ITEM BUILDER
                      return buildCustomersCard(
                          CustomersModel.fromJson(snapshot.data![index]),
                          context);
                    },
                  );
                } else {
                  return const NoDataFoundPage();
                }
              } else {
                return const NoDataFoundPage();
              }
            }
          },
        ),
      ),
    );
  }

  GestureDetector buildCustomersCard(
      CustomersModel data, BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Tapped");
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                ViewCustomerPage(customerObjectId: data.id.toString())));
      },
      child: Container(
          decoration: BoxDecoration(
              color: tWhite,
              borderRadius: BorderRadius.circular(dBorderRadius),
              boxShadow: dBoxShadow(color: Colors.black12)),
          padding: const EdgeInsets.all(dPadding * 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      color: tOrange,
                      width: 40,
                      height: 40,
                      child: Center(child: Text(extractInitials(data.name), style: containerText(color: tWhite, weight: FontWeight.w700),)),
                    ),
                  ),
                  const DGap(gap: dGap*2 ,vertical: false),

                  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _buildDetailsRow("ID: ", data.companyCustomerId.toString()),
                  _buildDetailsRow("Name: ", data.name),
                  _buildDetailsRow("Email: ", data.email),
                  
                ],
              ),
                ],
              ),
              
              //Press arrow
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ViewCustomerPage(customerObjectId: data.id.toString())));
                  },
                  icon: const Icon(Icons.arrow_forward_ios_rounded))
            ],
          )),
    );
  }

  RichText _buildDetailsRow(String title, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: tBlack),
        children: [
          TextSpan(
            text: title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: value,
          ),
        ],
      ),
    );
  }
}

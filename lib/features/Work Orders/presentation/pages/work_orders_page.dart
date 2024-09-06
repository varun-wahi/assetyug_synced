// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:asset_yug_debugging/features/Work%20Orders/domain/usecases/wo_show_filters_modal_sheet.dart';
import 'package:asset_yug_debugging/features/Work%20Orders/data/repository/work_orders_mongodb.dart';
import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:asset_yug_debugging/core/utils/constants/pageFilters.dart';
import 'package:asset_yug_debugging/features/Work%20Orders/presentation/riverpod/wo_filter_notifier.dart';
import 'package:asset_yug_debugging/features/Work%20Orders/presentation/riverpod/wo_search_notifier.dart';
import 'package:asset_yug_debugging/features/Work%20Orders/presentation/riverpod/wo_sorting_notifier.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_selected_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/usecases/WorkOrderColors.dart';
import '../../data/models/work_orders_model.dart';
import '../../../../config/theme/container_styles.dart';
import '../../../../core/utils/widgets/d_divider.dart';
import '../../../../core/utils/widgets/d_searchbar.dart';
import '../../../../core/utils/widgets/my_elevated_button.dart';
import '../../../../core/utils/widgets/d_gap.dart';
import '../../../../core/utils/widgets/d_text_field.dart';
import '../../../Customers/presentation/pages/customers_page.dart';

class WorkOrdersPage extends ConsumerWidget {
  const WorkOrdersPage({super.key});

  //FIX LATER USING BLOC or GETX

  //+++++++++++++++++++ ADVANCED FILTERS +++++++++++++++++++++++

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Work Orders"),
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: tBackground,
        body: Center(
          child: Container(
            height: MediaQuery.sizeOf(context).height - 100,
            padding: const EdgeInsets.all(dPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BuildSearchSection(),
                //List of Filters
                const BuildFiltersSection(),
                const DGap(gap: dGap),

                BuildWOListSection()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BuildSearchSection extends ConsumerWidget {
  final searchTextFieldController = TextEditingController();

  BuildSearchSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void searchWorkOrder() {
      String search = searchTextFieldController.text;
      ref.read(woSearchTermProvider.notifier).updateSearchTerm(search);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // SEARCH BAR
        Expanded(
            flex: 4,
            child: DSearchBar(
                hintText: "Search all work orders",
                controller: searchTextFieldController,
                onChanged: (value) => searchWorkOrder())),
        const DGap(
          vertical: false,
        ),
      ],
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
    ref.read(woFiltersProvider.notifier).clearFilters();

    //POP
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilters =
        ref.watch(woFiltersProvider.notifier).selectedFilters;

    return Row(
      children: [
        //LIST OF SELECTED FILTERS
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(dPadding),
            height: 70,
            // width: 150,
            child: ListView.separated(
              padding: const EdgeInsets.all(dPadding),
              itemBuilder: (context, index) {
                String filterKey = workOrderFilters.keys.elementAt(index);
                return DSelectedFilterItem(
                  selectedOption: selectedFilters[filterKey] ?? '',
                    isDropdown: true,
                    title: filterKey,
                    onPressed: () {
                      //TODO: SEND REQUEST TO ASSETS MONGODB
                      WOShowFiltersModalSheet.showFilterOptions(
                          context,
                          filterKey,
                          selectedFilters[filterKey],
                          workOrderFilters,
                          ref);
                    });
              },
              itemCount: workOrderFilters.length,
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
              onPressed: () => showAdvancedFilters(context, ref),
              icon: const Icon(
                Icons.filter_alt,
                // size: 40,
                color: darkGrey,
              )),
        ),
      ],
    );
  }

  void showAdvancedFilters(BuildContext context, WidgetRef ref) {
    //USE DATABASE INSTEAD
    var filterOptions = ["My Work", "Due Date", "Status", "Priority"];
    var statusOptions = ["Open", "In Progress", "On Hold", "Complete"];
    var priorityOptions = ["Low", "Medium", "High"];

    //FIX LATER USING BLOC or GETX
    List<Map<String, dynamic>> selectedFilters = [
      {"Status": "Open"},
      {"Sort": "Low-to-high"},
      {"Id": "Low-to-high"},
    ];

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
                      style: headline(),
                    ),
                    TextButton(
                        onPressed: () => _clearFilters(context, ref),
                        child: Text(
                          "CLEAR",
                          style: headline(size: 16),
                        )),
                  ],
                ),
              ),

              //FILTERS CONTAINER
              SizedBox(
                // height: MediaQuery.sizeOf(context).height - 400,
                height: 350,
                // width: 310,

                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      //SEARCH FIELDS
                      const DTextField(
                          icon: Icon(Icons.person),
                          hintText: "Work Order Title"),

                      const DGap(),

                      //PRIORITY LIST
                      Container(
                        padding: const EdgeInsets.all(dPadding),
                        decoration: dBoxDecoration(color: tBackground),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Priority",
                              style: headline(color: tBlack),
                            ),
                            const DGap(),

                            //LISTVIEW GENERATOR
                            Container(
                              padding: const EdgeInsets.all(dPadding),
                              height: 50,
                              child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 3,
                                  separatorBuilder: (context, index) =>
                                      const DGap(
                                        vertical: false,
                                      ),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      // height: 20,
                                      width: 100,
                                      padding: const EdgeInsets.all(dPadding),

                                      decoration: dBoxDecoration(
                                        color: tWhite,
                                      ),
                                      child: Center(
                                          child: Text(
                                        priorityOptions[index],
                                        style: containerText(
                                            color: tBlack,
                                            weight: FontWeight.w400),
                                      )),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                      const DGap(),

                      //STATUS LIST
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Status",
                            style: headline(color: tBlack),
                          ),
                          const DGap(),

                          //LISTVIEW GENERATOR
                          Container(
                            padding: const EdgeInsets.all(dPadding),
                            height: 50,
                            child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: 4,
                                separatorBuilder: (context, index) =>
                                    const DGap(
                                      vertical: false,
                                    ),
                                itemBuilder: (context, index) {
                                  return Container(
                                    // height: 20,
                                    width: 100,
                                    padding: const EdgeInsets.all(dPadding),
                                    decoration: dBoxDecoration(
                                      color: tPrimary,
                                    ),
                                    child: Center(
                                        child: Text(
                                      statusOptions[index],
                                      style: body(color: tWhite, size: 14),
                                    )),
                                  );
                                }),
                          ),
                        ],
                      ),

                      const DDivider(),

                      //ASSIGNED TO AND DATES
                      ListTile(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CustomersPage(),
                            )),
                        tileColor: tWhite, // Set background color to light grey
                        shape: const RoundedRectangleBorder(
                          side: BorderSide(
                            color: blackGrey, // Set border color to darker grey
                            width: 2.0, // Set border width to 1px
                          ),
                        ),
                        title: const Text("Technician Assigned to",
                            style: TextStyle(color: tBlack)),
                        trailing:
                            const Icon(Icons.arrow_forward_ios, color: tBlack),
                      ),
                      const DDivider(
                        gap: 0,
                      ),

                      //CUSTOMER ASSIGNED
                      ListTile(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CustomersPage(),
                            )),
                        tileColor: tWhite, // Set background color to light grey
                        shape: const RoundedRectangleBorder(
                          side: BorderSide(
                            color: blackGrey, // Set border color to darker grey
                            width: 2.0, // Set border width to 1px
                          ),
                        ),
                        title: const Text("Customer Assigned to",
                            style: TextStyle(color: tBlack)),
                        trailing:
                            const Icon(Icons.arrow_forward_ios, color: tBlack),
                      ),

                      const DDivider(),

                      //DUE DATE RANGE
                      Text("Due Date",
                          style: body(size: 15, weight: FontWeight.w400)),
                      SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            //START
                            GestureDetector(
                              // onTap: () =>
                              // setState(() => showModalBottomSheet(
                              //       context: context,
                              //     //   builder: (context) => CalendarPopup(
                              //     //       initialDate: DateTime.now()),
                              //     // )),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Start"),
                                  DGap(
                                    vertical: false,
                                    gap: dGap * 2,
                                  ),
                                  Icon(Icons.arrow_forward_ios),
                                ],
                              ),
                            ),

                            //STOP
                            GestureDetector(
                              // onTap: () =>
                              //     setState(() => showModalBottomSheet(
                              //           context: context,
                              //           builder: (context) => CalendarPopup(
                              //               initialDate: DateTime.now()),
                              //         )),
                              child: const Row(
                                children: [
                                  Text("Stop"),
                                  DGap(
                                    vertical: false,
                                    gap: dGap * 2,
                                  ),
                                  Icon(Icons.arrow_forward_ios),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const DDivider(),

                      // CREATED DATE RANGE

                      Text("Created Date",
                          style: body(size: 15, weight: FontWeight.w400)),
                      SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            //START
                            GestureDetector(
                              // onTap: () =>
                              //     setState(() => showModalBottomSheet(
                              //           context: context,
                              //           builder: (context) => CalendarPopup(
                              //               initialDate: DateTime.now()),
                              //         )),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Start"),
                                  DGap(
                                    vertical: false,
                                    gap: dGap * 2,
                                  ),
                                  Icon(Icons.arrow_forward_ios),
                                ],
                              ),
                            ),

                            //STOP
                            GestureDetector(
                              // onTap: () =>
                              //     setState(() => showModalBottomSheet(
                              //           context: context,
                              //           builder: (context) => CalendarPopup(
                              //               initialDate: DateTime.now()),
                              //         )),
                              child: Container(
                                  child: const Row(
                                children: [
                                  Text("Stop"),
                                  DGap(vertical: false, gap: dGap * 2),
                                  Icon(Icons.arrow_forward_ios),
                                ],
                              )),
                            ),
                          ],
                        ),
                      ),

                      const DDivider(),
                      //Additional Filters
                      Container(
                        decoration: dBoxDecoration(color: tBackground),
                        child: Column(
                          children: [
                            const DGap(),
                            Text(
                              "Additional Filters",
                              style: headline(color: tBlack, size: 16),
                            ),
                            const DGap(),
                            //ARCHIVED
                            CheckboxListTile.adaptive(
                                title: const Text("Archived",
                                    style: TextStyle(color: tBlack)),
                                value: false,
                                onChanged: (value) {}),

                            //UNARCHIVED
                            CheckboxListTile.adaptive(
                                title: const Text("Unarchived",
                                    style: TextStyle(color: tBlack)),
                                value: false,
                                onChanged: (value) {}),

                            //ASSETS CREATED BY YOU
                            CheckboxListTile.adaptive(
                                title: const Text("Created by you",
                                    style: TextStyle(color: tBlack)),
                                value: false,
                                onChanged: (value) {}),
                          ],
                        ),
                      ),
                      //ADDITIONAL FILTERS
                    ],
                  ),
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

class BuildWOListSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, dynamic> selectedFilters = ref.watch(woFiltersProvider);
    String searchTerm = ref.watch(woSearchTermProvider);
    Map<String, int> selectedSort = ref.watch(woSortingProvider);

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(dBorderRadius),
            color: tBackground,
            border: Border.all(width: .2, color: lighterGrey)),
        // height: 500,
        padding: const EdgeInsets.all(dPadding),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          // stream: MongoDatabase.getWorkOrdersDataStream(filters: {'priority': 'High'}),
          future: WorkOrdersMongodb.getWorkOrdersDataStream(
              searchTerm: searchTerm,
              filter: selectedFilters,
              sortOption: selectedSort),
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
                print("Data Length: " + totalData.toString());
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
                      return BuildWorkOrdersCard(
                          data:
                              WorkOrdersModel.fromJson(snapshot.data![index]));
                    },
                  );
                } else {
                  return const NoDataFoundPage();
                }

                // if()
              } else {
                return const NoDataFoundPage();
              }
            }
          },
        ),
      ),
    );
  }
}

class BuildWorkOrdersCard extends StatelessWidget {
  const BuildWorkOrdersCard({
    super.key,
    required this.data,
  });

  final WorkOrdersModel data;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: tWhite,
          borderRadius: BorderRadius.circular(dBorderRadius),
        ),
        padding: const EdgeInsets.all(dPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //TOP ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //ID AND PRIORITY
                Container(
                  padding: const EdgeInsets.all(dPadding),
                  decoration: BoxDecoration(
                      // color: Color.fromARGB(255, 249, 249, 158),
                      color: WorkOrderColors.getColorForPriority(
                          data.priority), // Get color based on priority
                      borderRadius: BorderRadius.circular(dBorderRadius)),
                  child: Text(
                    data.priority,
                    style: subtitle(color: tWhite),
                  ),
                ),

                //STATUS
                Container(
                  padding: const EdgeInsets.all(dPadding),
                  decoration: BoxDecoration(
                      color: WorkOrderColors.getColorForStatus(
                          data.status), // Get color based on priority
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    data.status,
                    style: subtitle(weight: FontWeight.w500, color: tWhite),
                  ),
                ),
              ],
            ),

            const DGap(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //WORK ORDER NUMBER
                Container(
                  // padding: EdgeInsets.all(dPadding),
                  /*
                    WORK ORDER NUMBER HERE
                   */
                  child: Text(
                    "#001",
                    style: body(weight: FontWeight.w500),
                  ),
                  // decoration: BoxDecoration(
                  //     color: lighterGrey, borderRadius: BorderRadius.circular(8)),
                ),

                //ASSET DETAILS
                Row(
                  children: [
                    const Icon(
                      Icons.card_giftcard,
                    ),
                    const SizedBox(
                      width: dGap,
                    ),
                    Text(
                      data.assetDetails,
                      style: body(weight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),

            const DGap(),

            //DESCRIPTION, DUE DATE, ASSET
            Text(
              data.description,
              style: headline(),
            ),

            const SizedBox(
              height: dGap,
            ),
            //CUSTOMER NAME,DUE DATE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //CUSTOMER NAME
                Row(
                  children: [
                    const Icon(
                      Icons.person_2_outlined,
                    ),
                    const SizedBox(
                      width: dGap,
                    ),
                    Text(
                      /*
                        CHANGE TO CUSTOMER NAME
                       */
                      data.customerName,
                      style: body(weight: FontWeight.w500),
                    ),
                  ],
                ),

                //DUE DATE
                Text(
                  // data.dueDate.toIso8601String(),
                  'Due: ' + DateFormat('MM-dd-yyyy').format(data.dueDate),
                  // "Due: 12-25-2024", //PUT REAL DATE HERE
                  style: body(color: tRed, weight: FontWeight.w400),
                ),
              ],
            ),
            const DGap(),
            //LAST UPDATED DATE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Last Updated: " +
                      DateFormat('MMMM d, y').format(data.lastDate),
                  style: containerText(weight: FontWeight.w400),
                ),
                const IconButton(
                    onPressed: null, icon: Icon(Icons.more_vert_outlined))
              ],
            ),
          ],
        ));
  }
}

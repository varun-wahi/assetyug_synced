// import 'package:asset_yug/widgets/features/WorkOrders/calender.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_divider.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/container_styles.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../core/utils/constants/sizes.dart';
import '../../../../core/utils/widgets/my_elevated_button.dart';
import '../../../../core/utils/widgets/d_gap.dart';
import '../../../../core/utils/widgets/d_text_field.dart';
import '../../../Customers/presentation/pages/customers_page.dart';

class AdvancedFiltersPage extends StatefulWidget {
  const AdvancedFiltersPage({super.key});

  @override
  State<AdvancedFiltersPage> createState() => _AdvancedFiltersPageState();
}

class _AdvancedFiltersPageState extends State<AdvancedFiltersPage> {
  var statusOptions = ["Open", "In Progress", "On Hold", "Complete"];
  var priorityOptions = ["Low", "Medium", "High"];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: tWhite,
          resizeToAvoidBottomInset: false,
          body: Container(
            padding: const EdgeInsets.all(2 * dPadding),
            decoration: const BoxDecoration(
                color: tWhite,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0))),
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
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
                          onPressed: () => clearFilters(),
                          child: Text(
                            "CLEAR",
                            style: boldHeading(size: 16),
                          )),
                    ],
                  ),
                ),

                //FILTERS CONTAINER
                SizedBox(
                  height: MediaQuery.sizeOf(context).height - 300,
                  // width: 310,

                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        //SEARCH FIELDS
                        const DTextField(
                            icon: Icon(Icons.person), hintText: "Work Order Title"),

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
                                style: boldHeading(color: tBlack, size: 18),
                              ),
                              const DGap(),

                              //LISTVIEW GENERATOR
                              Container(
                                padding: const EdgeInsets.all(dPadding),
                                height: 50,
                                child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 3,
                                    separatorBuilder: (context, index) => const DGap(
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
                              style: boldHeading(color: tBlack, size: 18),
                            ),
                            const DGap(),

                            //LISTVIEW GENERATOR
                            Container(
                              padding: const EdgeInsets.all(dPadding),
                              height: 50,
                              child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 4,
                                  separatorBuilder: (context, index) => const DGap(
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
                                        style: containerText(
                                            color: tWhite,
                                            weight: FontWeight.w400),
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
                                builder: (context) =>  CustomersPage(),
                              )),
                          tileColor:
                              tWhite, // Set background color to light grey
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(
                              color:
                                  blackGrey, // Set border color to darker grey
                              width: 2.0, // Set border width to 1px
                            ),
                          ),
                          title: const Text("Technician Assigned to"),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                        const DDivider(gap: 0,),

                        //CUSTOMER ASSIGNED
                        ListTile(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>  CustomersPage(),
                              )),
                          tileColor:
                              tWhite, // Set background color to light grey
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(
                              color:
                                  blackGrey, // Set border color to darker grey
                              width: 2.0, // Set border width to 1px
                            ),
                          ),
                          title: const Text("Customer Assigned to"),
                          trailing: const Icon(Icons.arrow_forward_ios),
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
                                child: const Row(
                                                                  children: [
                                Text("Stop"),
                                DGap(vertical: false, gap: dGap * 2),
                                Icon(Icons.arrow_forward_ios),
                                                                  ],
                                                                ),
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
                                style: boldHeading(color: tBlack, size: 18),
                              ),
                              const DGap(),
                              //ARCHIVED
                              CheckboxListTile.adaptive(
                                  title: const Text("Archived"),
                                  value: false,
                                  onChanged: (value) {}),

                              //UNARCHIVED
                              CheckboxListTile.adaptive(
                                  title: const Text("Unarchived"),
                                  value: false,
                                  onChanged: (value) {}),

                              //ASSETS CREATED BY YOU
                              CheckboxListTile.adaptive(
                                  title: const Text("Created by you"),
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
          ),
        ),
      ),
    );
  }

  clearFilters() {
    Navigator.pop(context);
  }
}

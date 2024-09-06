import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/features/Auth/presentation/pages/login_page.dart';
import 'package:asset_yug_debugging/features/Home/presentation/pages/notifications_page.dart';
import 'package:asset_yug_debugging/features/Customers/presentation/pages/customers_page.dart';
import 'package:asset_yug_debugging/features/Home/presentation/pages/scan_qr_page.dart';
import 'package:asset_yug_debugging/features/Home/data/data_sources/quick_actions.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_mongodb.dart';
import 'package:asset_yug_debugging/features/Work%20Orders/data/repository/work_orders_mongodb.dart';
import 'package:asset_yug_debugging/features/Inventory/presentation/pages/inventory_page.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:badges/badges.dart' as badges;

import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/add_asset_page.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../../Auth/data/repository/firebase_authentication.dart';
import '../widgets/home_checkedout_out_home.dart';
import '../widgets/wo_tile_widget_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int count = 12; //notification count
  static bool isLoading = true;
  String companyName = "";
  late Box box;

  @override
  void initState() {
    super.initState();
    _fetchCompanyName();
    _connectToDb();
  }
  Future<void> _fetchCompanyName() async {
    box = await Hive.openBox('auth_data');
    companyName = box.get('companyName');
    if (companyName != null) {
      setState(() {
        companyName = companyName;
      });
    }
  }

  void _connectToDb() async {
    try {
      await WorkOrdersMongodb.connect();
      await AssetsMongoDB.connect();
      // print("Connected to both DBs");

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        dSnackBar(context, "Failed to connect to DB",TypeSnackbar.error);
      }
      print("Failed to connect to DB: $e");
    }
  }

  //LOGOUT FUNCTION
  Future<bool> _showLogoutDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(dPadding * 2),
          shape:
              BeveledRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          title: Text(
            'Log Out',
            style: subheading(weight: FontWeight.bold, size: 18),
          ),
          content: Text('Are you sure you want to log out?',
              style: body(color: darkGrey)),
          actions: <Widget>[
            // Yes button with rounded corners and custom color
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: tPrimary, // Adjust color as needed
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(dBorderRadius),
                          // Adjust corner radius
                        ),
                      ),
                      child: Text(
                        'Yes',
                        style: body(color: tWhite),
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .pop(true); // Close dialog and initiate logout
                      },
                    ),
                  ),
                  const SizedBox(
                    width: dGap,
                  ),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: tWhite, // Adjust color as needed
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1.0, color: tGreyLight),
                          borderRadius: BorderRadius.circular(
                              dBorderRadius), // Adjust corner radius
                        ),
                      ),
                      child: Text(
                        'No',
                        style: body(),
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .pop(false); // Close dialog without logging out
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _logoutButtonPressed() async {
    // Call the dialog and await user confirmation
    final bool shouldLogout = await _showLogoutDialog(context);
    if (shouldLogout) {
      // Perform logout logic here (e.g., call an API or service to log out)
      print('User confirmed logout');
      // Optionally, navigate to a login screen
      await AuthServices().logoutUser();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          )); // Replace current screen with login
    }
  }

// BUILD FUNCTION
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tBackground,

      appBar: AppBar(
        //NOTIFICATIONS BADGE
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: badges.Badge(
            position: badges.BadgePosition.topEnd(top: 0, end: 9),
            badgeAnimation: const badges.BadgeAnimation.slide(
                // disappearanceFadeAnimationDuration: Duration(milliseconds: 200),
                // curve: Curves.easeInCubic,
                ),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: tRed,
            ),
            badgeContent: Text(
              count.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 9),
            ),
            child: IconButton(
                icon: const Icon(
                  Icons.notifications,
                  size: 30,
                ),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ))),
          ),
        ),

        //TITLE
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("AssetYug"),
        ),

        actions: [
          //LOGOUT
          IconButton(
              onPressed: () => _logoutButtonPressed(),
              icon: const Icon(
                Icons.logout,
                color: tBlack,
              )),
        ],
      ),

      //++++++++++ MAIN BODY ++++++++++++
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(dPadding * 2),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Greetings
              _buildGreetingsSection(),
              const SizedBox(
                height: dPadding * 2,
              ),

              //quick actions
              _buildQuickActionsSection(),

              //Scan or Add Asset Container
              _buildOptionsSection(context),

              const DGap(gap: dGap * 2),

              //Work Orders by status
              _buildWoCategorisedSection(),

              //Checked Out Assets
              const BuildCheckOutAssetsContainer(),

              const DGap(gap: dGap * 2),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildGreetingsSection() {
    return Container(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome $companyName",
                      style: boldHeading(size: 24),
                    ),
                    const DGap(),
                    Text(
                        DateFormat('MMMM d, y').format(DateTime
                            .now()), //Update Date and Time whenever user logs in
                        style: body(size: 18)),
                  ],
                ));
  }

  Padding _buildWoCategorisedSection() {
    return Padding(
      padding: const EdgeInsets.all(dPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Work Order Dashboard",
            style: boldHeading(size: 20),
          ),
          const DGap(),
          SizedBox(
            height: 690,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: dPadding,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                BuildWorkOrderTile(
                    colorByStatus: tBlack,
                    category: "status",
                    value: "All Pending",
                    myIcon: Icons.timer_outlined,
                    isLoading: isLoading),
                BuildWorkOrderTile(
                    colorByStatus: tPurple,
                    category: "status",
                    value: "Open",
                    myIcon: Icons.warning_amber_outlined,
                    isLoading: isLoading),
                BuildWorkOrderTile(
                    colorByStatus: tGreen,
                    category: "status",
                    value: "In Progress",
                    myIcon: Icons.work_history_outlined,
                    isLoading: isLoading),
                BuildWorkOrderTile(
                    colorByStatus: tGreyLight,
                    category: "status",
                    value: "On Hold",
                    myIcon: Icons.pause_circle_outline_outlined,
                    isLoading: isLoading),
                BuildWorkOrderTile(
                    colorByStatus: tRed,
                    category: "status",
                    value: "Past Due",
                    myIcon: Icons.pending_actions,
                    iconColor: tRed,
                    isLoading: isLoading),
                BuildWorkOrderTile(
                    colorByStatus: Colors.orange,
                    category: "status",
                    value: "Due Today",
                    myIcon: Icons.access_time,
                    isLoading: isLoading),
                BuildWorkOrderTile(
                    colorByStatus: tRed,
                    category: "priority",
                    value: "High",
                    myIcon: Icons.priority_high_rounded,
                    iconColor: tRed,
                    isLoading: isLoading),
              ],
            ),
          )
        ],
      ),
    );
  }

  Container _buildOptionsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: tWhite,
          borderRadius: BorderRadius.circular(dBorderRadius),
          border: Border.all(width: .1, color: lighterGrey)),
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, //** */
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: tWhite,
                      foregroundColor: tBlack,
                      elevation: 2.0),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScanCodePage(),
                        ));
                  },
                  child: const Icon(
                    Icons.qr_code,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(
                height: dPadding,
              ),
              Text(
                "Scan Asset",
                style: body(),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: tWhite,
                      foregroundColor: tBlack,
                      elevation: 2.0),
                  onPressed: () {
                    // Navigate to the second page when the button is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddAssetPage()),
                    );
                  },
                  child: const Icon(
                    Icons.add,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(
                height: dPadding,
              ),
              Text(
                "Add Asset",
                style: body(),
              )
            ],
          ),
        ],
      ),
    );
  }

  Container _buildQuickActionsSection() {
    return Container(
      padding: const EdgeInsets.all(dPadding),
      height: 75,
      child: ListView.separated(
        padding: const EdgeInsets.all(dPadding),
        itemBuilder: (context, index) {
          return SizedBox(
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(dBorderRadius * 2),
                      ),
                  backgroundColor: tPrimary,// Background color
                  // backgroundColor: tWhite,// Background color
                  foregroundColor: tWhite, // Text color
                  // foregroundColor: tPrimary, // Text color
                ),
                onPressed: () {
                  if (index == 0) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InventoryPage(),
                        ));
                  } else {
                    dSnackBar(context, "Feature coming to mobile later.",TypeSnackbar.info);
                  }
                },
                child: Text(
                  QUICK_ACTIONS[index],
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13.0),
                ),
              ));
        },
        itemCount: QUICK_ACTIONS.length,
        separatorBuilder: (context, index) {
          return const DGap(vertical: false);
        },
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}




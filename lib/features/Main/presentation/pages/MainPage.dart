import 'dart:io';

import 'package:asset_yug_debugging/features/Main/presentation/riverpod/tab_notifier.dart';
import 'package:asset_yug_debugging/features/More%20Options/presentation/pages/more_options_page.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/assets_page.dart';
import 'package:asset_yug_debugging/features/Customers/presentation/pages/customers_page.dart';
import 'package:asset_yug_debugging/features/Home/presentation/pages/home_page.dart';
import 'package:asset_yug_debugging/features/Inventory/presentation/pages/inventory_page.dart';
import 'package:asset_yug_debugging/features/Work%20Orders/presentation/pages/work_orders_page.dart';
import 'package:asset_yug_debugging/core/utils/widgets/my_elevated_button.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTabIndex = ref.watch(tabProvider);

    //List of Pages
    final pages = [
      const HomePage(),
      const AssetsPage(),
      const WorkOrdersPage(),
      const CustomersPage(),
      MoreOptionsPage(),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if(currentTabIndex !=0){
          ref.read(tabProvider.notifier).setTab(0);
          return;
        }
        if (didPop) {
          return;
        }

        _showExitDialog(context);
      },
      child: Scaffold(
        backgroundColor: tWhite,
        resizeToAvoidBottomInset: false,
        body: pages[currentTabIndex],
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentTabIndex,
            backgroundColor: tBackground,
            selectedItemColor: blackGrey,
            unselectedItemColor: darkGrey,
            onTap: (index) {
              // Update the tab index
              ref.read(tabProvider.notifier).setTab(index);
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet), label: "Assets"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.work), label: "Work Orders"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.people_alt), label: "Customers"),
              BottomNavigationBarItem(icon: Icon(Icons.menu), label: "More"),
            ]),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(dPadding * 2),
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        title: Text(
          'Exit App',
          style: subheading(weight: FontWeight.bold, size: 18),
        ),
        content:
            Text('Do you want to exit the app?', style: body(color: darkGrey)),

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
                        Navigator.of(context).pop(true);
                        _exitApp();
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
                            .pop(); // Close dialog without logging out
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        // actions: [
        //   DElevatedButton(
        //     buttonColor: tWhite,
        //     textColor: tBlack,
        //     onPressed: () => Navigator.of(context).pop(),
        //     child: const Text('No'),
        //   ),
        //   DElevatedButton(
        //     onPressed: () => Navigator.of(context).pop(true),
        //     child: const Text('Yes'),
        //   ),
        // ],
      ),
    ).then((value) {
      if (value == true) {
        // If user confirms exit, close the app
        Navigator.of(context).pop(true);
      }
    });
  }

  void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      // For iOS, we'll just exit to the home screen
      SystemNavigator.pop();
    }
  }
}

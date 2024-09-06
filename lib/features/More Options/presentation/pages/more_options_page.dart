import 'dart:convert';
import 'dart:typed_data';

import 'package:asset_yug_debugging/features/Main/presentation/riverpod/tab_notifier.dart';
import 'package:asset_yug_debugging/features/Customers/data/repository/customer_mongodb.dart';
import 'package:asset_yug_debugging/features/Auth/data/repository/firebase_authentication.dart';
import 'package:asset_yug_debugging/features/Customers/data/models/company_info_model.dart';
import 'package:asset_yug_debugging/features/Auth/presentation/pages/login_page.dart';
import 'package:asset_yug_debugging/features/Home/presentation/pages/notifications_page.dart';
import 'package:asset_yug_debugging/features/More%20Options/presentation/pages/terms%20and%20privacy/privacy_policy_page.dart';
import 'package:asset_yug_debugging/features/More%20Options/presentation/pages/terms%20and%20privacy/terms_of_use_page.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_divider.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/widgets/my_elevated_button.dart';
import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:asset_yug_debugging/core/utils/widgets/loading_animated_container.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoreOptionsPage extends StatelessWidget {
  const MoreOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: tWhite,
        title:const  Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FutureBuilder(
              future: CustomerMongoDb.fetchCompanyInfo("3214"),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(dPadding*2),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(60)),
                          child: LoadingAnimatedContainer(height: 120, width:120)),
                          DGap(),
                          LoadingAnimatedContainer(height: 30,),
                            DGap(gap:dGap*2),
                            LoadingAnimatedContainer(height: 40)
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  Map<String, dynamic>? companyData = snapshot.data;
                  if (companyData == null) {
                    return const NoDataFoundPage();
                  }
                  return _buildUserProfileSection(companyData, context);
                }
              },
            ),
            // User profile section

            // Divider
            const DDivider(),
            // Extra settings buttons
            const BuildExtraSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileSection(
      Map<String, dynamic> companyData, BuildContext context) {
    var data = CompanyInfoModel.fromJson(companyData);
    // Convert the binary string to Uint8List
    Uint8List imageData = base64Decode(data.companyImage);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
              radius: 60.0,
              // backgroundImage: data.companyImage,
              backgroundImage: MemoryImage(imageData)),
          const SizedBox(height: dGap),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                data.companyName,
                style: boldHeading(size: 18),
              ),
              const DGap(),
              DElevatedButton(
                onPressed: () {
                  showCustomSizedPopup(context, data);
                },
                buttonColor: tPrimary,
                // textColor: tWhite,
                child: Text(
                  'View Profile',
                  style: containerText(color: tWhite),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showCustomSizedPopup(BuildContext context, CompanyInfoModel data) {
    Uint8List imageData = base64Decode(data.companyImage);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.5,
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CircleAvatar(
                        radius: 60.0,
                        // backgroundImage: data.companyImage,
                        backgroundImage: MemoryImage(imageData)),
                    const SizedBox(height: dGap),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //COMPANY NAME
                        Text(
                          "Company Name",
                          style: boldHeading(size: 18),
                        ),
                        Text(
                          data.companyName,
                          style: body(size: 16),
                        ),
                        const DGap(),
                        //COMPANY EMAIL
                        Text(
                          "Company Email",
                          style: boldHeading(size: 18),
                        ),
                        Text(
                          data.companyEmail,
                          style: body(size: 16),
                        ),
                        const DGap(),
                        //COMPANY ID
                        Text(
                          "Company ID",
                          style: boldHeading(size: 18),
                        ),
                        Text(
                          data.companyID,
                          style: body(size: 16),
                        ),
                        const DGap(),
                        //CLOSE BUTTON
                        DElevatedButton(
                            onPressed: Navigator.of(context).pop,
                            child: const Text("Close"))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BuildExtraSettingsSection extends ConsumerWidget {
  const BuildExtraSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void _logout(BuildContext context) async {
      await AuthServices().logoutUser();
      
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          )); 
          // Replace current screen with login

          ref.read(tabProvider.notifier).setTab(0);
    }

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.notifications, color: tBlack),
          title: Text(
            'Notifications',
            style: containerText(),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: tBlack),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage())),
        ),
        const DDivider(),
        ListTile(
          leading: const Icon(Icons.note_alt_rounded, color: tBlack),
          title: Text('Terms of Use', style: containerText()),
          trailing: const Icon(Icons.arrow_forward_ios, color: tBlack),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsOfUsePage())),
        ),
        const DDivider(),
        ListTile(
          leading: const Icon(Icons.privacy_tip, color: tBlack),
          title: Text('Privacy Policy', style: containerText()),
          trailing: const Icon(Icons.arrow_forward_ios, color: tBlack),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyPage())),
        ),
        const DDivider(),
        ListTile(
          leading: const Icon(Icons.logout, color: tBlack),
          title: Text('Logout', style: containerText()),
          trailing: const Icon(Icons.arrow_forward_ios, color: tBlack),
          onTap: () => {_logout(context)},
        ),
        const DDivider(),
      ],
    );
  }
}

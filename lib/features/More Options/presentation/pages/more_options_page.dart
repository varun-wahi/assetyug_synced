import 'package:asset_yug_debugging/features/Main/presentation/riverpod/tab_notifier.dart';
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
import 'package:hive/hive.dart';

class MoreOptionsPage extends StatefulWidget {
  const MoreOptionsPage({super.key});

  @override
  State<MoreOptionsPage> createState() => _MoreOptionsPageState();
}

class _MoreOptionsPageState extends State<MoreOptionsPage> {
  static const String _defaultCompanyImage = 
      "https://image.shutterstock.com/image-photo/image-260nw-452062024.jpg";
  
  Box? _box;
  
  @override
  void initState() {
    super.initState();
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    try {
      _box = await Hive.openBox("auth_data");
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error initializing Hive box: $e");
    }
  }

  Future<Map<String, dynamic>?> _fetchCompanyInfo() async {
    try {
      _box ??= await Hive.openBox("auth_data");

      final companyId = _box!.get("companyId").toString() as String?;
      final companyName = _box!.get("companyName") as String?;
      final companyEmail = _box!.get("email") as String?;

      // Validate that we have the required data
      if (companyId == null || companyName == null || companyEmail == null) {
        debugPrint("Missing company data - ID: $companyId, Name: $companyName, Email: $companyEmail");
        return null;
      }

      return {
        "companyID": companyId,
        "companyName": companyName,
        "companyEmail": companyEmail,
      };
    } catch (e) {
      debugPrint("Error fetching company info: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: tWhite,
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Company profile section
            FutureBuilder<Map<String, dynamic>?>(
              future: _fetchCompanyInfo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingSection();
                }
                
                if (snapshot.hasError) {
                  return _buildErrorSection(snapshot.error.toString());
                }
                
                final companyData = snapshot.data;
                if (companyData == null) {
                  return _buildNoDataSection();
                }
                
                return _buildUserProfileSection(companyData);
              },
            ),
            
            // Divider
            const DDivider(),
            
            // Settings options
            const _BuildExtraSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return const Padding(
      padding: EdgeInsets.all(dPadding * 2),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(60)),
            child: LoadingAnimatedContainer(height: 120, width: 120),
          ),
          DGap(),
          LoadingAnimatedContainer(height: 30),
          DGap(gap: dGap * 2),
          LoadingAnimatedContainer(height: 40),
        ],
      ),
    );
  }

  Widget _buildErrorSection(String error) {
    return Padding(
      padding: const EdgeInsets.all(dPadding * 2),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          const DGap(),
          Text(
            'Error loading profile',
            style: boldHeading(size: 18),
          ),
          const DGap(),
          Text(
            'Please try again later',
            style: body(size: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataSection() {
    return const Padding(
      padding: EdgeInsets.all(dPadding * 2),
      child: NoDataFoundPage(),
    );
  }

  Widget _buildUserProfileSection(Map<String, dynamic> companyData) {
    final data = CompanyInfoModel.fromJson(companyData);
    
    return Padding(
      padding: const EdgeInsets.all(dPadding * 2),
      child: Column(
        children: [
          // Profile image
          CircleAvatar(
            radius: 60.0,
            backgroundColor: tGreyLight,
            backgroundImage: const NetworkImage(_defaultCompanyImage),
            onBackgroundImageError: (exception, stackTrace) {
              debugPrint("Error loading company image: $exception");
            },
          ),
          
          const SizedBox(height: dGap),
          
          // Company info
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                data.companyName,
                style: boldHeading(size: 18),
                textAlign: TextAlign.center,
              ),
              const DGap(),
              DElevatedButton(
                onPressed: () => _showCompanyProfileDialog(context, data),
                buttonColor: tPrimary,
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

  void _showCompanyProfileDialog(BuildContext context, CompanyInfoModel data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dBorderRadius),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            padding: const EdgeInsets.all(dPadding * 2),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button at top
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Company Profile',
                        style: boldHeading(size: 20),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  
                  const DGap(),
                  
                  // Profile image
                  CircleAvatar(
                    radius: 60.0,
                    backgroundColor: tGreyLight,
                    foregroundImage: const NetworkImage(_defaultCompanyImage),
                    onForegroundImageError: (exception, stackTrace) {
                      debugPrint("Error loading company image: $exception");
                    },
                  ),
                  
                  const DGap(gap: dGap * 2),
                  
                  // Company details
                  _buildProfileDetail('Company Name', data.companyName),
                  const DGap(),
                  _buildProfileDetail('Company Email', data.companyEmail),
                  const DGap(),
                  _buildProfileDetail('Company ID', data.companyID),
                  
                  const DGap(gap: dGap * 3),
                  
                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: DElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      buttonColor: tPrimary,
                      child: Text(
                        'Close',
                        style: containerText(color: tWhite),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: boldHeading(size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: body(size: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _BuildExtraSettingsSection extends ConsumerWidget {
  const _BuildExtraSettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildSettingsTile(
          context: context,
          icon: Icons.notifications,
          title: 'Notifications',
          onTap: () => _navigateToPage(context, const NotificationsPage()),
        ),
        const DDivider(),
        
        _buildSettingsTile(
          context: context,
          icon: Icons.note_alt_rounded,
          title: 'Terms of Use',
          onTap: () => _navigateToPage(context, const TermsOfUsePage()),
        ),
        const DDivider(),
        
        _buildSettingsTile(
          context: context,
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          onTap: () => _navigateToPage(context, const PrivacyPolicyPage()),
        ),
        const DDivider(),
        
        _buildSettingsTile(
          context: context,
          icon: Icons.logout,
          title: 'Logout',
          onTap: () => _showLogoutDialog(context, ref),
          isDestructive: true,
        ),
        const DDivider(),
      ],
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : tBlack,
      ),
      title: Text(
        title,
        style: containerText(
          color: isDestructive ? Colors.red : tBlack,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: isDestructive ? Colors.red : tBlack,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
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
                        _performLogout(context, ref);
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
        // return AlertDialog(
        //   title: const Text('Logout'),
        //   content: const Text('Are you sure you want to logout?'),
        //   actions: [
        //     TextButton(
        //       onPressed: () => Navigator.of(context).pop(),
        //       child: const Text('Cancel'),
        //     ),
        //     TextButton(
        //       onPressed: () {
        //         Navigator.of(context).pop();
        //         _performLogout(context, ref);
        //       },
        //       child: const Text(
        //         'Logout',
        //         style: TextStyle(color: Colors.red),
        //       ),
        //     ),
        //   ],
        // );
      },
    );
  }

  Future<void> _performLogout(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final box = await Hive.openBox('auth_data');
      final email = box.get('email') as String?;

      if (email != null) {
        await AuthServices().logoutUser(email);
      }

      // Clear all stored data
      await box.clear();

      // Reset tab state
      ref.read(tabProvider.notifier).setTab(0);

      // Navigate to login page
      if (context.mounted) {
        Navigator.of(context).pop(); // Remove loading dialog
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error during logout: $e");
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Remove loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
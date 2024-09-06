import 'dart:math';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(dPadding),
        child: ListView.separated(itemBuilder: (context, index) {
          return _buildNotificationTile(index);
        
          
        }, separatorBuilder: (context, index) => const DGap(), itemCount: 12),
      ),
    );
  }
  
  ListTile _buildNotificationTile(int index) {
    var notificationTypes = ['wo_alert','new_customer', 'new_assets', 'new_login'];
    //RANDOM NOTIFICATION FOR NOW
    String selection = notificationTypes[Random().nextInt(notificationTypes.length)];

    switch(selection){
      case "wo_alert":{
        return _buildDefaultNotificationTile(index,"Work Order #221 deadline tomorrow" );

      }
      case "new_customer":{
        return _buildDefaultNotificationTile(index,"New Customer added successfully!");

      }case "new_assets":{
        return _buildDefaultNotificationTile(index,"New Asset added successfully!");

      }case "new_login":{
        return _buildDefaultNotificationTile(index,"New User login from location ...");

      }default:{
        return _buildDefaultNotificationTile(index,"This is a Test Notification");
      }

    }
  
  }

  ListTile _buildDefaultNotificationTile(int index, String title) {
    return ListTile(
      tileColor: tBackground,
    //TODO: #2 MAKE FUNCTION FOR NOTIFICATION TILE TAP
    onTap: null,
    title: Text("$title", style: containerText(weight: FontWeight.w400),),
    leading: Text((index+1).toString(), style: containerText(weight: FontWeight.w500)),
    trailing: const Icon(Icons.arrow_forward_ios, size: 20,color: tPrimary,),
  );
  }
}
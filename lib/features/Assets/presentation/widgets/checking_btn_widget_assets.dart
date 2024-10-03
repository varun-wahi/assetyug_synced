import 'dart:convert';

import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/widgets/my_elevated_button.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Customers/data/data_sources/customer_names_data.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_dropdown.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/assets_mongodb.dart';
import '../../domain/usecases/switch_asset_status_string.dart';
import '../../data/models/assets_model.dart';
import '../../../../core/utils/constants/strings.dart';
import '../../../../core/utils/constants/colors.dart';
import 'package:intl/intl.dart';

class AssetStatusButton extends ConsumerStatefulWidget {
  final AssetsModel data;
  final WidgetRef ref;

  const AssetStatusButton({Key? key, required this.data, required this.ref})
      : super(key: key);

  @override
  _AssetStatusButtonState createState() => _AssetStatusButtonState();
}

class _AssetStatusButtonState extends ConsumerState<AssetStatusButton> {
  late Future<dynamic> _statusFuture;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _selectedEmployee;

  @override
  void initState() {
    super.initState();
    // Fetch check-in/out status from the repository
    _statusFuture = _fetchCheckInOutStatus();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<String> _fetchCheckInOutStatus() async {
    final repository = AssetsRepositoryImpl();
    try {
      final response = await repository.getCheckInOutList(widget.data.id!);
      // print("response: ${response.body}");
      if (response.statusCode == 202) {
        final List<dynamic> checkInOutList = json.decode(response.body);
        // print("checkInOutList: $checkInOutList");
        final status = checkInOutList.last['status'];
        // print("status: $status for widget ${widget.data.id.oid}");
        // If the list is empty, the asset is checked in
        return status;
      } else {
        throw Exception('Failed to fetch check-in/out status');
      }
    } catch (e) {
      print('Error fetching check-in/out status: $e');
      return checkInString; // Default to checked in if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _fetchCheckInOutStatus(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 50.0,
            width: 50.0,
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final assetCheckingStatus = snapshot.data;

          return DElevatedButton(
            borderRadius: 30,
            buttonColor: (assetCheckingStatus == checkInString)
                ? tCheckOutColor
                : tCheckInColor,
            onPressed: () async {
              await showCheckInOutDialog(context, assetCheckingStatus);
            },
            child: (assetCheckingStatus == checkInString)
                ?  Text("Check Out", style: subtitle(weight: FontWeight.w500, color: tWhite))
                : Text("Check In", style: subtitle(weight: FontWeight.w500, color: tWhite)),
          );
        }
        return const SizedBox();
      },
    );
  }

  Future<void> showCheckInOutDialog(BuildContext context, var assetCheckingStatus) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Check In/Out Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DDropdown(
                label: "Employee",
                items: customerNamesMenuItems,
                onChanged: (newValue) {
                  setState(() {
                    _selectedEmployee = newValue;
                  });
                },
              ),
              const DGap(),
              DTextField(
                hasLabel: true,
                hintText: "Notes",
                maxLines: 3,
                padding: 0,
                controller: _notesController,
              ),
              const DGap(),
              DTextField(
                hasLabel: true,
                hintText: "Location",
                padding: 0,
                controller: _locationController,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () async {
                Navigator.of(context).pop();

                // Prepare the data for addCheckInOut
                final data = {
                  'assetId': widget.data.id!,
                  'status': switchAssetCheckingStatus(assetCheckingStatus),
                  'employee': _selectedEmployee,
                  'notes': _notesController.text,
                  'location': _locationController.text,
                  'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                };

                // Call addCheckInOut method
                final repository = AssetsRepositoryImpl();
                try {
                  final response = await repository.addCheckInOut(json.encode(data));
                  print("data: $data");
                  if (response.statusCode == 200) {
                    print("response: ${response.body}");
                    print('Check in/out successful');
                  } else {
                    print('Failed to check in/out: ${response.body}');
                  }
                } catch (e) {
                  print('Error during check in/out: $e');
                }

                // Check if the widget is still mounted before calling setState
                if (mounted) {
                  setState(() {
                    _statusFuture = _fetchCheckInOutStatus();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }
}

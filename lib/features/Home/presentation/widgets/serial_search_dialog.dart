import 'package:asset_yug_debugging/core/utils/widgets/my_elevated_button.dart';
import 'package:flutter/material.dart';

class SerialSearchDialog {
  static Future<String?> show(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search Asset by Serial Number'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Enter Serial Number',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            DElevatedButton(
              child: const Text('Search'),
              onPressed: () {
                String serialNumber = searchController.text.trim();
                Navigator.of(context).pop(serialNumber); // Return the serial number
              },
            ),
          ],
        );
      },
    );
  }
}
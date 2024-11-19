import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/features/Assets/data/data_sources/asset_field_types_data.dart';
import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/widgets/custom_text_field.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_dropdown.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/core/utils/widgets/my_elevated_button.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/features/Customers/data/models/customers_extra_fields_model.dart';
import 'package:asset_yug_debugging/features/Customers/data/repository/company_customer_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/customer_extra_field_names_model.dart';

class CustomerCreateCustomField extends StatefulWidget {
  final String customerId;
  CustomerCreateCustomField({super.key, required this.customerId});

  @override
  State<CustomerCreateCustomField> createState() => _CustomerCreateCustomFieldState();
}

class _CustomerCreateCustomFieldState extends State<CustomerCreateCustomField> {
  final _fieldNameController = TextEditingController();

  // final _companyEmailController = TextEditingController();
  String _fieldType = 'Text';

  bool isRequired = false;
  bool isLoading = false;
  String companyId = '';

  void _changeFieldTypeValue(String option) {
    _fieldType = option;
  }

  void _changeRequiredValue(bool option) => isRequired = option;

  void initState() {
    super.initState();
    _fetchCompanyData();
  }

  Future<void> _fetchCompanyData() async {
    //fetch companyDATA
    try {
      final box = await Hive.openBox('auth_data');

      companyId = box.get('companyId');
      print("---------------------");
      print("Company ID: $companyId");
      print("---------------------");
    } catch (_) {
      print("error: ${_.toString()}");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: dPadding * 5, horizontal: dPadding * 2),
      child: SingleChildScrollView(
        child: Column(
          //TEXT FIELDS COLUMN
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Add New Custom Field",
              style: headline(),
            ),
            const DGap(gap: dGap * 2),
            buildCustomTextField(
                "Field Name", TextInputType.text, _fieldNameController, false),
            const DGap(
              gap: dGap * 2,
            ),
            DDropdown(
              label: "Field Type",
              items: assetFieldTypeMenuItems,
              onChanged: (value) => _changeFieldTypeValue(value),
            ),
            const DGap(gap: dGap * 2),

            // DDropdown(label: "Required (replace w checkbox)",items: assetRequiredMenuItems, onChanged: (value) => _changeRequiredValue(value),),
            // const DGap(gap: dGap*2),
            DElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                try {
                  // TODO: Add input validation here

                  // Initialize the repository
                  final customerRepositoryImpl = CompanyCustomerRepositoryImpl();

                  // Fetch the latest company data
                  await _fetchCompanyData();

                  // Create a model for the new extra field name
                  final model = CustomerExtraFieldNamesModel(
                    name: _fieldNameController.text,
                    type: _fieldType,
                    companyId: companyId,
                  );
                  print(
                      "Name: ${model.name} Type: ${model.type} Company ID: ${model.companyId}");

                  // Step 1: Add the new extra field name to the company's field list
                  final response = await customerRepositoryImpl.addExtraFieldsName(
                      CustomerExtraFieldNamesModelToJson(model));
                      
                  print("Add Extra Field Name Response Status: ${response.statusCode}");
                  print("Add Extra Field Name Response Body: ${response.body}");

                  if (response.statusCode == 200) {
                    // Step 2: If the field name was added successfully, create the field for this specific asset
                    final extraFieldData = CustomerExtraFieldModel(
                      companyId: companyId,
                      customerId: widget.customerId,
                      email:
                          "ayushwahi0530@gmail.com", // TODO: Make this dynamic, possibly fetch from user session
                      value: _getInitialValueForFieldType(_fieldType),
                      name: _fieldNameController.text,
                      type: _fieldType,
                    );
                    print("Extra Field Data Entered: ${extraFieldData.toJson()}");

                    // Add the extra field with its initial value to the asset
                    final addExtraFieldResponse =
                        await customerRepositoryImpl.addExtraFieldsWithValue(
                            CustomerExtraFieldModelToJson(extraFieldData));
                    print(
                        "Add Extra Field Value Response: ${addExtraFieldResponse.statusCode}");

                    if (addExtraFieldResponse.statusCode == 200) {
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.pop(context);
                      // Both operations successful, show success message
                      dSnackBar(
                          context,
                          "Inserted new field: ${_fieldNameController.text}",
                          TypeSnackbar.success);
                    } else {
                      setState(() {
                        isLoading = false;
                      });
                      // Field name added, but field value failed
                      throw Exception(
                          "Failed to add extra field value to asset");
                    }
                  } else {
                    setState(() {
                      isLoading = false;
                    });
                    // Print more details about the error response
                    print("Error status code: ${response.statusCode}");
                    print("Error response body: ${response.body}");
                    throw Exception("Failed to add extra field name to company. Status: ${response.statusCode}, Body: ${response.body}");
                  }
                } catch (e) {
                  setState(() {
                    isLoading = false;
                  });
                  // Handle any errors that occurred during the process
                  print("Error details: $e");
                  dSnackBar(context, "An error occurred: ${e.toString()}",
                      TypeSnackbar.error);
                }
              },
              child: isLoading ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(color: tWhite,),
              ) : const Text("Add Field"),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitialValueForFieldType(String fieldType) {
    switch (fieldType) {
      case 'Text':
        return '';
      case 'Number':
        return '0';
      case 'Date':
        print("adding date ${DateTime.now().toString().substring(0, 10)}");
        return DateTime.now().toString().substring(0, 10); // Format: yyyy-MM-dd
      case 'Checkbox':
        return 'false';
      default:
        return '';
    }
  }
}

import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_divider.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_extra_field_names_model.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_extra_fields_model.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/extraFieldsForm.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../../config/theme/snackbar__types_enum.dart';

class AssetCustomPage extends ConsumerStatefulWidget {
  final String companyId;
  final String assetId;
  const AssetCustomPage({super.key, required this.companyId, required this.assetId});

  @override
  ConsumerState<AssetCustomPage> createState() => _AssetCustomPageState();
}

class _AssetCustomPageState extends ConsumerState<AssetCustomPage> {
 
  @override
  void initState() {
    super.initState();
    //companyId or assetId or objectid
    print("-----------------------------------");
    print("Asset ID ${widget.assetId}");
    print("Company ID ${widget.companyId}");
    print("-----------------------------------");
  }

    Future<String> getAllExtraFieldsData(String assetId) async { //could be objectId
    try {
      final response = await AssetsRepositoryImpl().getExtraFields(assetId);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        print("Error fetching extra field data: ${response.statusCode}");
        return "Error fetching extra field data: ${response.statusCode}";
      }
    } catch (e) {
      print("Exception in getExtraFieldData: $e");
      return "Error fetching extra field data: $e";
    }
  }

  Future<String> deleteExtraField(String objectId) async {
    try {
      final response = await AssetsRepositoryImpl().removeExtraField(objectId);
      if (response.statusCode == 200) {
        print("Extra field deleted successfully");
        setState(() {
          dSnackBar(context, "Extra field deleted successfully", TypeSnackbar.success);
        });
        return "Extra field deleted successfully";
      } else {
        print("Error deleting extra field: ${response.statusCode}");
        setState(() {
          dSnackBar(context, "Error deleting extra field: ${response.statusCode}", TypeSnackbar.error);
        });
        return "Error deleting extra field: ${response.statusCode}";
      }
    } catch (e) {
      print("Exception in deleteExtraField: $e");
      setState(() {
        dSnackBar(context, "Error deleting extra field: $e", TypeSnackbar.error);
      });
      return "Error deleting extra field: $e";
    }
  }
 
 
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAddExtraFieldRow(context),
        Expanded(child: _buildFilesList()),
      ],
    );
  }

  FutureBuilder<String> _buildFilesList() {
    return FutureBuilder(
      future: getAllExtraFieldsData(widget.assetId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
                height: 30, width: 30, child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final responseBody = snapshot.data;
          if (responseBody != null && !responseBody.startsWith("Error")) {
            try {
              if (responseBody.isNotEmpty) {
                final fieldsData = jsonDecode(responseBody) as List<dynamic>;
                final reversedFieldsData = fieldsData.reversed.toList();

                if (fieldsData.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(dPadding),
                      child: ListView.separated(
                        itemCount: fieldsData.length,
                        itemBuilder: (context, index) {
                          final data = AssetExtraFieldModel.fromJson(
                              reversedFieldsData[index]);
                          return Card(
                            elevation: 0,
                            // color: tPrimary,
                            color: tWhite,
                            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              onTap: () async {
                                final extraFieldData = await getAllExtraFieldsData(widget.assetId);
                                if (extraFieldData.startsWith("Error")) {
                                  // Handle error case
                                  dSnackBar(context, extraFieldData, TypeSnackbar.error);
                                } else {
                                  final Map<String, dynamic> jsonData = json.decode(extraFieldData)[reversedFieldsData.length - 1 - index];
                                print("Extra Field Data ${jsonData}");

                                  final AssetExtraFieldModel fieldModel = AssetExtraFieldModel.fromJson(jsonData);
                                  
                                  _showEditFieldDialog(
                                    context,
                                    fieldModel,
                                  );
                                }
                              },
                              title: Text(
                                data.name,
                                // style: const TextStyle(color: tWhite, fontWeight: FontWeight.bold),
                                style: const TextStyle(
                                    color: tBlack, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                data.type,
                                // style: TextStyle(color: tWhite.withOpacity(0.7)),
                                style:
                                    TextStyle(color: tBlack.withOpacity(0.7)),
                              ),
                              trailing: PopupMenuButton<String>(
                                icon:
                                    const Icon(Icons.more_vert, color: tBlack),
                                color: tPrimary,
                                onSelected: (value) async{
                                  if (value == 'edit') {
                                    print("Edit ${data.id}");
                                
                                final extraFieldData = await getAllExtraFieldsData(widget.assetId);
                                if (extraFieldData.startsWith("Error")) {
                                  // Handle error case
                                  dSnackBar(context, extraFieldData, TypeSnackbar.error);
                                } else {
                                  final Map<String, dynamic> jsonData = json.decode(extraFieldData)[reversedFieldsData.length - 1 - index];
                                print("Extra Field Data ${jsonData}");

                                  final AssetExtraFieldModel fieldModel = AssetExtraFieldModel.fromJson(jsonData);
                                  
                                  _showEditFieldDialog(
                                    context,
                                    fieldModel,
                                  );
                                }
                              
                                  } else if (value == 'delete') {
                                    print("Delete ${data.id}");
                                    deleteExtraField(data.id!);
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Text('Edit',
                                        style: TextStyle(color: tWhite)),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Delete',
                                        style: TextStyle(color: tWhite)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          // return const SizedBox(height: 4);
                          return const DDivider();
                        },
                      ),
                    ),
                  );
                } else {
                  return const NoDataFoundPage();
                }
              } else {
                print("Response body is empty");
                return const NoDataFoundPage();
              }
            } catch (e) {
              print("Error decoding JSON: $e");
              return Text('Error decoding data: $e');
            }
          } else {
            print("Invalid response: $responseBody");
            return const NoDataFoundPage();
          }
        } else {
          return const NoDataFoundPage();
        }
      },
    );
  }

  SizedBox _buildAddExtraFieldRow(BuildContext context) {
    return SizedBox(
      height: 30,
      width: MediaQuery.sizeOf(context).width,
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width / 1.2,
          ),
          IconButton(
            onPressed: () {
              showCreateCustomFieldDialog(context);
              // return dSnackBar(context, "Feature coming soon!");
            },
            alignment: Alignment.center,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showEditFieldDialog(BuildContext context, AssetExtraFieldModel field) {
    String editedValue = "";
    bool showField = false;
    bool isMandatory = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Column(
                children: [
                  Text(field.name),
                  const SizedBox(height: 4),
                  Text(field.type, style: subtitle()),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldEditWidget(field, (value) => editedValue = value, context),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Show Field'),
                      value: showField,
                      onChanged: (value) => setState(() => showField = value!),
                    ),
                    CheckboxListTile(
                      title: const Text('Is Mandatory'),
                      value: isMandatory,
                      onChanged: (value) =>
                          setState(() => isMandatory = value!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Submit'),
                  onPressed: () {
                    // TODO: Implement submit functionality
                    // Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFieldEditWidget(AssetExtraFieldModel field, Function(String) onChanged, BuildContext context) {
    switch (field.type.toLowerCase()) {
      case 'text':
        return TextField(
          decoration: InputDecoration(
            labelText: 'Value',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(dBorderRadius),
            ),
          ),
          onChanged: (value) => onChanged(value),
          controller: TextEditingController(text: field.value),
        );
      case 'checkbox':
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            bool isChecked = field.value.toLowerCase() == "true";
            return CheckboxListTile(
              title: const Text('Value'),
              value: isChecked,
              onChanged: (bool? newValue) {
                setState(() {
                  isChecked = newValue ?? false;
                });
                onChanged(isChecked.toString());
              },
            );
          },
        );
      case 'number':
        return TextField(
          decoration: InputDecoration(
            labelText: 'Value',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(dBorderRadius),
            ),
          ),
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          controller: TextEditingController(text: field.value),
        );
      case 'date':
        return InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.tryParse(field.value) ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              onChanged(picked.toIso8601String().split('T')[0]);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Select Date',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(dBorderRadius),
              ),
            ),
            child: Text(field.value.isNotEmpty ? field.value : 'Select a date'),
          ),
        );
      default:
        return Text('Unsupported field type: ${field.type}');
    }
  }

//ADD EXTRA FIELD DIALOG
  void showCreateCustomFieldDialog(BuildContext context) {
    showDialog(
        builder: (context) {
          return Dialog(
            backgroundColor: tBackground,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(dBorderRadius)),
            child: AssetCreateCustomField(assetId: widget.assetId),
          );
        },
        context: context);
  }


}

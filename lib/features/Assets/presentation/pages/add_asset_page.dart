import 'dart:convert';
import 'dart:io';

import 'package:asset_yug_debugging/core/usecases/capitalize_string.dart';
import 'package:asset_yug_debugging/core/utils/constants/strings.dart';
import 'package:asset_yug_debugging/features/Assets/data/data_sources/asset_status_data.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Auth/data/repository/auth_token_repository_impl.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_model.dart';
import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/core/utils/widgets/custom_text_field.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_dropdown.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/features/Customers/data/repository/company_customer_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/utils/widgets/async_dropdown_search_widget.dart';
import '../../../../core/utils/widgets/my_elevated_button.dart';
import '../widgets/custom_text_field.dart';

class LocationBinOption {
  final String locationId;
  final String? binId;
  final String label;

  LocationBinOption(
      {required this.locationId, this.binId, required this.label});
}

class AddAssetPage extends StatefulWidget {
  final AssetsModel? editAsset; // Add this parameter

  const AddAssetPage({super.key, this.editAsset});

  @override
  State<AddAssetPage> createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final _serialField = TextEditingController();
  final _nameField = TextEditingController();
  final _assetLocationField = TextEditingController();

  File? _image;
  String? base64Image;
  String? _assetStatus = activeStatusString;
  String? _assetCategory;
  String? _customer;
  LocationBinOption? _selectedLocationBin;

  List<String> categoryList = [];
  List<String> customerList = [];
  List<LocationBinOption> locationBinOptions = [];

  bool loadingAssetInsertion = false;

  late String companyId;
  late String userEmail;
  late Box box;

  // Add getter to check if we're in edit mode
  bool get isEditMode => widget.editAsset != null;

  @override
  void initState() {
    super.initState();
    createBox();
  }

  void createBox() async {
    // Pre-populate fields if in edit mode
    if (isEditMode) {
      _populateFieldsForEdit();
    }
    box = await Hive.openBox('auth_data');
    await _fetchUserInfo();
    await _fetchDropdownData();
    await _fetchLocationBinOptions();

  }

  void _populateFieldsForEdit() {
    final asset = widget.editAsset!;

    _nameField.text = asset.name;
    _serialField.text = asset.serialNumber;
    _assetStatus = asset.status.toCapitalized();
    _assetCategory = asset.category.isNotEmpty ? asset.category : null;
    _customer = (asset.customer?.isNotEmpty ?? false) ? asset.customer : null;

    //! Handle location - you might need to adjust this based on your location format
    if (asset.location.isNotEmpty && asset.location != "Not Specified") {
      // Try to find matching location in options
      // This is a simplified approach - you might need more complex matching
      _selectedLocationBin = locationBinOptions.firstWhere(
        (option) => option.label == asset.location,
        orElse: () =>
            LocationBinOption(locationId: "unknown", label: asset.location),
      );
    }

    // Handle existing image
    if (asset.image != null && asset.image!.isNotEmpty) {
      base64Image = asset.image;
      // Note: You can't convert base64 back to File easily for display
      // You might want to show the existing image differently
    }

    setState(() {});
  }

  Future<void> _fetchUserInfo() async {
    userEmail = box.get('email');
    companyId = box.get('companyId');
  }

  Future<void> _fetchDropdownData() async {
    final repo = AssetsRepositoryImpl();
    final customerRepo = CompanyCustomerRepositoryImpl();
    try {
      final categoriesResponse = await repo.getActiveCategories(companyId);
      if (categoriesResponse.statusCode == 200) {
        final categories = jsonDecode(categoriesResponse.body) as List;
        categoryList = categories.map((e) => e['name'].toString()).toList();
      }
      final customerResponse = await customerRepo.getCompanyCustomer(companyId);
      if (customerResponse.statusCode == 200) {
        final customers = jsonDecode(customerResponse.body) as List;
        customerList = customers.map((e) => e['name'].toString()).toList();
      }
      if (mounted) setState(() {});
    } catch (e) {
      print("Error fetching dropdown data: $e");
    }
  }

  Future<void> _fetchLocationBinOptions() async {
    try {
      final response = await CompanyCustomerRepositoryImpl()
          .getCustomerLocationsAndBins(companyId);
      final List<dynamic> data = jsonDecode(response.body);
      final List<LocationBinOption> parsed = [];

      for (var location in data) {
        final locName = location['name'];
        final locId = location['id'];
        final bins = location['bins'] ?? [];

        if (bins.isEmpty) {
          parsed.add(LocationBinOption(
              locationId: locId, binId: null, label: locName));
        } else {
          for (var bin in bins) {
            parsed.add(LocationBinOption(
              locationId: locId,
              binId: bin['id'],
              label: '$locName -> ${bin['binNumber']}',
            ));
          }
        }
      }

      setState(() {
        locationBinOptions = parsed;
      });
    } catch (e) {
      print('Failed to load locations and bins: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title:
                Text(isEditMode ? "Edit Asset" : "Add Asset") // Dynamic title
            ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(dPadding * 2),
            child: Column(
              children: [
                buildAssetImageCard(),
                Column(
                  children: [
                    buildCustomTextField(
                        "Asset Name", TextInputType.text, _nameField, true),
                    const DGap(),
                    buildCustomTextField("Serial Number", TextInputType.text,
                        _serialField, true),
                    const DGap(),
                    AsyncDropdownField<Map<String, dynamic>>(
                      label: "Category",
                      asyncItemsFetcher: () async {
                        final repo = AssetsRepositoryImpl();
                        try {
                          final categoriesResponse =
                              await repo.getActiveCategories(companyId);
                          if (categoriesResponse.statusCode == 200) {
                            final categories =
                                jsonDecode(categoriesResponse.body) as List;
                            return categories
                                .map((e) => e as Map<String, dynamic>)
                                .toList();
                          }
                        } catch (e) {
                          print("Error fetching categories: $e");
                        }
                        return [];
                      },
                      displayString: (category) => category['name'].toString(),
                      onChanged: (value) => setState(
                          () => _assetCategory = value?['name'].toString()),
                      selectedItem: _assetCategory != null
                          ? {'name': _assetCategory}
                          : null,
                    ),
                    const DGap(),
                    AsyncDropdownField<Map<String, dynamic>>(
                      label: "Customer",
                      asyncItemsFetcher: () async {
                        final customerRepo = CompanyCustomerRepositoryImpl();
                        try {
                          final customerResponse =
                              await customerRepo.getCompanyCustomer(companyId);
                          if (customerResponse.statusCode == 200) {
                            final customers =
                                jsonDecode(customerResponse.body) as List;
                            return customers
                                .map((e) => e as Map<String, dynamic>)
                                .toList();
                          }
                        } catch (e) {
                          print("Error fetching customers: $e");
                        }
                        return [];
                      },
                      displayString: (customer) => customer['name'].toString(),
                      onChanged: (value) =>
                          setState(() => _customer = value?['name'].toString()),
                      selectedItem:
                          _customer != null ? {'name': _customer} : null,
                    ),
                    const DGap(),
                    AsyncDropdownField<LocationBinOption>(
                      label: "Location",
                      asyncItemsFetcher: () async {
                        try {
                          final response = await CompanyCustomerRepositoryImpl()
                              .getCustomerLocationsAndBins(companyId);
                          print(response.body);
                          final List<dynamic> data = jsonDecode(response.body);
                          final List<LocationBinOption> parsed = [];

                          for (var location in data) {
                            final locName = location['name'];
                            final locId = location['id'];
                            final bins = location['bins'] ?? [];

                            // Always add location itself
                            parsed.add(LocationBinOption(
                              locationId: locId,
                              binId: null,
                              label: locName,
                            ));

                            // Then add all bins under it
                            for (var bin in bins) {
                              parsed.add(LocationBinOption(
                                locationId: locId,
                                binId: bin['id'],
                                label: '$locName -> ${bin['binNumber']}',
                              ));
                            }
                          }

                          return parsed;
                        } catch (e) {
                          print('Failed to load locations and bins: $e');
                          return [];
                        }
                      },
                      displayString: (locationBin) => locationBin.label,
                      onChanged: (value) =>
                          setState(() => _selectedLocationBin = value),
                      selectedItem: _selectedLocationBin,
                    ),
                    const DGap(),
                    DDropdown(
                      label: "Status",
                      items: assetStatusMenuItems,
                      value: _assetStatus,
                      onChanged: (value) =>
                          setState(() => _assetStatus = value),
                      isMandatory: true,
                    ),
                  ],
                ),
                const DGap(),
                DElevatedButton(
                  buttonColor: tPrimary,
                  textColor: tWhite,
                  onPressed: _submitAsset,
                  child: loadingAssetInsertion
                      ? const SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: CircularProgressIndicator(color: tWhite))
                      : Text(isEditMode
                          ? "Update Asset"
                          : "Add Asset"), // Dynamic button text
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column buildAssetImageCard() {
    // Show existing image for edit mode if available
    Widget imageWidget;

    if (_image != null) {
      // New image selected
      imageWidget = ClipOval(
        child: Image.file(_image!, height: 150, width: 150, fit: BoxFit.cover),
      );
    } else if (isEditMode &&
        widget.editAsset!.image != null &&
        widget.editAsset!.image!.isNotEmpty) {
      // Show existing image in edit mode
      try {
        final rawBase64 = widget.editAsset!.image!.split(',').last;
        final bytes = base64.decode(rawBase64);
        imageWidget = ClipOval(
          child:
              Image.memory(bytes, height: 150, width: 150, fit: BoxFit.cover),
        );
      } catch (e) {
        imageWidget = ClipOval(
          child: Container(
            color: Colors.grey[300],
            height: 150,
            width: 150,
            child: Icon(Icons.camera_alt, size: 50, color: Colors.grey[800]),
          ),
        );
      }
    } else {
      // Default placeholder
      imageWidget = ClipOval(
        child: Container(
          color: Colors.grey[300],
          height: 150,
          width: 150,
          child: Icon(Icons.camera_alt, size: 50, color: Colors.grey[800]),
        ),
      );
    }

    return Column(
      children: [
        imageWidget,
        const DGap(),
        DElevatedButton(
          onPressed: () => _showImageSourceActionSheet(context),
          child: Text(isEditMode ? "Change Image" : "Add Image"),
        ),
        const DGap(),
      ],
    );
  }

  void _submitAsset() async {
    setState(() => loadingAssetInsertion = true);
    if (!validateFields([
      _serialField.text,
      _nameField.text,
      _customer ?? "",
      _assetStatus ?? ""
    ])) {
      setState(() => loadingAssetInsertion = false);
      return dSnackBar(context, "Fill all required fields", TypeSnackbar.error);
    }
    try {
      if (isEditMode) {
        await _updateAssetData();
      } else {
        await _insertAssetData(
          _nameField.text,
          _serialField.text,
          _assetCategory ?? "",
          _customer ?? "",
          _selectedLocationBin?.label ?? "",
          _assetStatus ?? "",
        );
      }
    } catch (e) {
      setState(() => loadingAssetInsertion = false);
      dSnackBar(context, "Unknown error occurred: $e", TypeSnackbar.error);
    }
  }

  // New method for updating asset
  Future<void> _updateAssetData() async {
    final repo = AssetsRepositoryImpl();

    // If new image selected, encode it
    if (_image != null) {
      base64Image = base64Encode(await _image!.readAsBytes());
    } else if (widget.editAsset!.image != null) {
      // Keep existing image
      base64Image = widget.editAsset!.image;
    }

    // Create update payload matching your API format
    final updateData = {
      "email": userEmail,
      "assetId": widget.editAsset!.assetId,
      "id": widget.editAsset!.id,
      "name": _nameField.text,
      "serialNumber": _serialField.text,
      "category": _assetCategory ?? "",
      "customer": _customer ?? "",
      "customerId": widget.editAsset!.customerId, // Keep existing customerId
      "location": "${_selectedLocationBin?.label}" ?? "",
      // "locationName": _selectedLocationBin?.label??,
      // "locationName": _selectedLocationBin?.label??,
      "status": _assetStatus?.toLowerCase() ?? "",
      "image": base64Image,
      "companyId": int.parse(companyId),
      "updatedAt": DateTime.now().toIso8601String(),
    };

    final response = await repo.updateAsset(updateData);

    if (response.statusCode == 200) {
      if (mounted) {
        dSnackBar(context, "Asset Updated Successfully", TypeSnackbar.success);
        Navigator.pop(context, true); // Return true to indicate success
      }
    } else {
      if (mounted)
        dSnackBar(context, "Failed to update asset", TypeSnackbar.error);
    }
    setState(() => loadingAssetInsertion = false);
  }

  bool validateFields(List<String> values) =>
      values.every((value) => value.isNotEmpty);

  Future<void> _insertAssetData(String name, String serialNumber,
      String category, String customer, String location, String status) async {
    final repo = AssetsRepositoryImpl();
    if (_image != null) base64Image = base64Encode(await _image!.readAsBytes());
    final data = AssetsModel(
      name: name,
      serialNumber: serialNumber,
      category: category,
      customer: customer,
      customerId: "1",
      location: location,
      status: status,
      image: base64Image,
      companyId: companyId,
    );
    final response = await repo.addNewAsset(json.encode(data.toJson()));
    if (response.statusCode == 200) {
      final id = jsonDecode(response.body)["id"];
      final checkInData = {
        'assetId': id,
        'status': checkInString,
        'companyId': companyId,
        'employee': customer,
        'notes': null,
        'location': location,
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      };
      await repo.addCheckInOut(json.encode(checkInData));
      if (mounted)
        dSnackBar(context, "Asset Inserted Successfully", TypeSnackbar.success);
      clearFields();
    } else {
      if (mounted)
        dSnackBar(context, "Failed to insert asset", TypeSnackbar.error);
    }
    setState(() => loadingAssetInsertion = false);
  }

  void clearFields() {
    _nameField.clear();
    _serialField.clear();
    _assetLocationField.clear();
    _assetCategory = null;
    _customer = null;
    _selectedLocationBin = null;
    _assetStatus = activeStatusString;
    _image = null;
    setState(() {});
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      final compressed = await _compressImage(File(image.path));
      setState(() => _image = compressed);
    }
  }

  Future<File> _compressImage(File file) async {
    final decoded = img.decodeImage(file.readAsBytesSync())!;
    final resized = img.copyResize(decoded, width: 500);
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/compressed.jpg';
    return File(path)..writeAsBytesSync(img.encodeJpg(resized, quality: 55));
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take picture'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';

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

  LocationBinOption({required this.locationId, this.binId, required this.label});
}

class AddAssetPage extends StatefulWidget {
  const AddAssetPage({super.key});

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

  @override
  void initState() {
    super.initState();
    createBox();
  }

  void createBox() async {
    box = await Hive.openBox('auth_data');
    await _fetchUserInfo();
    await _fetchDropdownData();
    await _fetchLocationBinOptions();
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
      final response = await CompanyCustomerRepositoryImpl().getCustomerLocationsAndBins(companyId);
      final List<dynamic> data = jsonDecode(response.body);
      final List<LocationBinOption> parsed = [];

      for (var location in data) {
        final locName = location['name'];
        final locId = location['id'];
        final bins = location['bins'] ?? [];

        if (bins.isEmpty) {
          parsed.add(LocationBinOption(locationId: locId, binId: null, label: locName));
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
        appBar: AppBar(centerTitle: true, title: const Text("Add Asset")),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(dPadding * 2),
            child: Column(
              children: [
                buildAssetImageCard(),
                Column(
                  children: [
                    buildCustomTextField("Asset Name", TextInputType.text, _nameField, true),
                    const DGap(),
                    buildCustomTextField("Serial Number", TextInputType.text, _serialField, true),
                    const DGap(),
                    AsyncDropdownField<Map<String, dynamic>>(
  label: "Category",
  asyncItemsFetcher: () async {
    final repo = AssetsRepositoryImpl();
    try {
      final categoriesResponse = await repo.getActiveCategories(companyId);
      if (categoriesResponse.statusCode == 200) {
        final categories = jsonDecode(categoriesResponse.body) as List;
        return categories.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
    return [];
  },
  displayString: (category) => category['name'].toString(),
  onChanged: (value) => setState(() => _assetCategory = value?['name'].toString()),
  selectedItem: categoryList.isNotEmpty && _assetCategory != null 
      ? {'name': _assetCategory} 
      : null,
),
                    const DGap(),
                    AsyncDropdownField<Map<String, dynamic>>(
  label: "Customer",
  asyncItemsFetcher: () async {
    final customerRepo = CompanyCustomerRepositoryImpl();
    try {
      final customerResponse = await customerRepo.getCompanyCustomer(companyId);
      if (customerResponse.statusCode == 200) {
        final customers = jsonDecode(customerResponse.body) as List;
        return customers.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print("Error fetching customers: $e");
    }
    return [];
  },
  displayString: (customer) => customer['name'].toString(),
  onChanged: (value) => setState(() => _customer = value?['name'].toString()),
  selectedItem: customerList.isNotEmpty && _customer != null 
      ? {'name': _customer} 
      : null,
),
                    const DGap(),
                    AsyncDropdownField<LocationBinOption>(
  label: "Location",
  asyncItemsFetcher: () async {
    try {
      final response = await CompanyCustomerRepositoryImpl().getCustomerLocationsAndBins(companyId);
      final List<dynamic> data = jsonDecode(response.body);
      final List<LocationBinOption> parsed = [];

      for (var location in data) {
        final locName = location['name'];
        final locId = location['id'];
        final bins = location['bins'] ?? [];

        if (bins.isEmpty) {
          parsed.add(LocationBinOption(locationId: locId, binId: null, label: locName));
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
      return parsed;
    } catch (e) {
      print('Failed to load locations and bins: $e');
      return [];
    }
  },
  displayString: (locationBin) => locationBin.label,
  onChanged: (value) => setState(() => _selectedLocationBin = value),
  selectedItem: _selectedLocationBin,
),
                    const DGap(),
                    DDropdown(
                      label: "Status",
                      items: assetStatusMenuItems,
                      value: _assetStatus,
                      onChanged: (value) => setState(() => _assetStatus = value),
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
                      ? const SizedBox(height: 20.0, width: 20.0, child: CircularProgressIndicator(color: tWhite))
                      : const Text("Add Asset"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column buildAssetImageCard() {
    return Column(
      children: [
        _image == null
            ? ClipOval(
                child: Container(
                  color: Colors.grey[300],
                  height: 150,
                  width: 150,
                  child: Icon(Icons.camera_alt, size: 50, color: Colors.grey[800]),
                ),
              )
            : ClipOval(
                child: Image.file(_image!, height: 150, width: 150, fit: BoxFit.cover),
              ),
        const DGap(),
        DElevatedButton(
          onPressed: () => _showImageSourceActionSheet(context),
          child: const Text("Add Image"),
        ),
        const DGap(),
      ],
    );
  }

  void _submitAsset() async {
    setState(() => loadingAssetInsertion = true);
    if (!validateFields([_serialField.text, _nameField.text, _customer ?? "", _assetStatus ?? ""])) {
      setState(() => loadingAssetInsertion = false);
      return dSnackBar(context, "Fill all required fields", TypeSnackbar.error);
    }
    try {
      await _insertAssetData(
        _nameField.text,
        _serialField.text,
        _assetCategory ?? "",
        _customer ?? "",
        _selectedLocationBin?.label ?? "",
        _assetStatus ?? "",
      );
    } catch (e) {
      setState(() => loadingAssetInsertion = false);
      dSnackBar(context, "Unknown error occurred: $e", TypeSnackbar.error);
    }
  }

  bool validateFields(List<String> values) => values.every((value) => value.isNotEmpty);

  Future<void> _insertAssetData(String name, String serialNumber, String category, String customer, String location, String status) async {
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
      if (mounted) dSnackBar(context, "Asset Inserted Successfully", TypeSnackbar.success);
      clearFields();
    } else {
      if (mounted) dSnackBar(context, "Failed to insert asset", TypeSnackbar.error);
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
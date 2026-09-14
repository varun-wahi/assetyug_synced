import 'dart:convert';
import 'dart:io';

import 'package:asset_yug_debugging/core/usecases/capitalize_string.dart';
import 'package:asset_yug_debugging/core/utils/constants/strings.dart';
import 'package:asset_yug_debugging/features/Assets/data/data_sources/asset_status_data.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_model.dart';
import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_dropdown.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/features/Customers/data/repository/company_customer_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/models/custom_field_model.dart';
import '../../../../core/utils/widgets/custom_fields_section.dart';
import '../../../../core/utils/location/device_location_utils.dart';
import '../../../Main/presentation/riverpod/refresh_provider.dart';
import '../../../../core/utils/widgets/async_dropdown_search_widget.dart';
import '../../../../core/utils/widgets/my_elevated_button.dart';
import '../riverpod/asset_custom_fields_provider.dart';
import '../widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../riverpod/technical_users_provider.dart';
import 'view_asset_page.dart';

class LocationBinOption {
  final String locationId;
  final String? binId;
  final String label;

  LocationBinOption(
      {required this.locationId, this.binId, required this.label});
}

class AddAssetPage extends ConsumerStatefulWidget {
  final AssetsModel? editAsset; // Add this parameter

  const AddAssetPage({super.key, this.editAsset});

  @override
  ConsumerState<AddAssetPage> createState() => _AddAssetPageState();
}

class _AddAssetPageState extends ConsumerState<AddAssetPage> {
  final _serialField = TextEditingController();
  final _nameField = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _detailsScrollController = ScrollController();
  final _customFieldsScrollController = ScrollController();
  final _assetLocationField = TextEditingController();
  final Map<String, TextEditingController> _customFieldControllers = {};

  File? _image;
  String? base64Image;
  String? _assetStatus = activeStatusString;
  String? _assetCategory;
  String? _customer;
  String? _customerId;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePage();
    });
  }

  Future<void> _initializePage() async {
    if (isEditMode) {
      _populateFieldsForEdit();
    }

    box = await Hive.openBox('auth_data');
    await _fetchUserInfo();

    if (isEditMode) {
      ref.invalidate(assetCustomFieldsProvider);
      await ref
          .read(assetCustomFieldsProvider.notifier)
          .loadExtraFieldsForEdit(widget.editAsset!.id!, companyId);
    } else {
      ref.invalidate(assetCustomFieldsProvider);
      await ref
          .read(assetCustomFieldsProvider.notifier)
          .loadCustomFields(companyId);
    }

    await _fetchDropdownData();
    await _fetchLocationBinOptions();
  }

  void _populateFieldsForEdit() {
    final asset = widget.editAsset!;

    bool isMissing(String? value) {
      if (value == null) return true;
      final text = value.trim();
      if (text.isEmpty) return true;
      final lower = text.toLowerCase();
      return lower == 'null' ||
          lower == 'unassigned' ||
          lower == 'n/a' ||
          lower == 'not specified' ||
          lower == 'unknown customer id';
    }

    _nameField.text = asset.name;
    _serialField.text =
        isMissing(asset.serialNumber) ? '' : asset.serialNumber;
    _assetStatus = isMissing(asset.status)
        ? null
        : asset.status.toCapitalized();
    _assetCategory =
        isMissing(asset.category) ? null : asset.category;
    _customer = isMissing(asset.customer) ? null : asset.customer;
    _customerId = isMissing(asset.customerId) ? null : asset.customerId;

    if (!isMissing(asset.location)) {
      _selectedLocationBin = locationBinOptions.firstWhere(
        (option) => option.label == asset.location,
        orElse: () =>
            LocationBinOption(locationId: "unknown", label: asset.location),
      );
    }

    // Handle existing image
    if (asset.image != null && asset.image!.isNotEmpty) {
      base64Image = asset.image;
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
  void dispose() {
    _nameField.dispose();
    _nameFocusNode.dispose();
    _detailsScrollController.dispose();
    _customFieldsScrollController.dispose();
    _serialField.dispose();
    _assetLocationField.dispose();
    for (var controller in _customFieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(isEditMode ? "Edit Asset" : "Add Asset"),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Details'),
                Tab(text: 'Custom Fields'),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildDetailsTab(),
                      _buildAssetCustomFieldsTab(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: dPadding * 2, vertical: dPadding),
                  child: DElevatedButton(
                    buttonColor: tPrimary,
                    textColor: tWhite,
                    onPressed: _submitAsset,
                    child: loadingAssetInsertion
                        ? const SizedBox(
                            height: 20.0,
                            width: 20.0,
                            child: CircularProgressIndicator(color: tWhite),
                          )
                        : Text(isEditMode ? "Update Asset" : "Add Asset"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      controller: _detailsScrollController,
      padding: const EdgeInsets.all(dPadding * 2),
      child: Column(
        children: [
          buildAssetImageCard(),
          buildCustomTextField(
            "Asset Name",
            TextInputType.text,
            _nameField,
            true,
            autofocus: true,
            focusNode: _nameFocusNode,
          ),
          buildCustomTextField(
              "Serial Number", TextInputType.text, _serialField, false),
          AsyncDropdownField<Map<String, dynamic>>(
            label: "Category",
            asyncItemsFetcher: () async {
              final repo = AssetsRepositoryImpl();
              try {
                final categoriesResponse =
                    await repo.getActiveCategories(companyId);
                if (categoriesResponse.statusCode == 200) {
                  final categories = jsonDecode(categoriesResponse.body) as List;
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
            onChanged: (value) {
              setState(() => _assetCategory = value?['name'].toString());
              FocusScope.of(context).unfocus();
            },
            selectedItem:
                _assetCategory != null ? {'name': _assetCategory} : null,
          ),
          AsyncDropdownField<Map<String, dynamic>>(
            label: "Customer",
            asyncItemsFetcher: () async {
              final customerRepo = CompanyCustomerRepositoryImpl();
              try {
                final customerResponse =
                    await customerRepo.getCompanyCustomer(companyId);
                if (customerResponse.statusCode == 200) {
                  final customers = jsonDecode(customerResponse.body) as List;
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
            onChanged: (value) {
              setState(() {
                _customer = value?['name'].toString();
                _customerId = value?['id'].toString();
              });
              FocusScope.of(context).unfocus();
            },
            selectedItem: _customer != null ? {'name': _customer} : null,
          ),
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

                  parsed.add(LocationBinOption(
                      locationId: locId, binId: null, label: locName));
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
            onChanged: (value) {
              setState(() => _selectedLocationBin = value);
              FocusScope.of(context).unfocus();
            },
            selectedItem: _selectedLocationBin,
          ),
          DDropdown(
            label: "Status",
            items: addAssetStatusMenuItems,
            value: _assetStatus,
            onChanged: (value) {
              setState(() => _assetStatus = value);
              FocusScope.of(context).unfocus();
            },
            isMandatory: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCustomFieldsTab() {
    return SingleChildScrollView(
      controller: _customFieldsScrollController,
      padding: const EdgeInsets.all(dPadding * 2),
      child: Consumer(builder: (context, ref, _) {
        final customFields = ref
            .watch(assetCustomFieldsProvider)
            .where((f) => f.show)
            .toList();

        final visibleIds = customFields.map((f) => f.id).toSet();
        _customFieldControllers.removeWhere((id, controller) {
          if (visibleIds.contains(id)) return false;
          controller.dispose();
          return true;
        });

        if (isEditMode) {
          for (final f in customFields) {
            if (f is CustomFieldWithValue) {
              _customFieldControllers.putIfAbsent(
                f.id,
                () => TextEditingController(text: f.value),
              );
              if (_customFieldControllers[f.id]?.text.isEmpty ?? false) {
                _customFieldControllers[f.id]?.text = f.value;
              }
            }
          }
        }

        if (customFields.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: dPadding * 4),
            child: Center(
              child: Text("No custom fields configured for this company."),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Custom Fields",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor1,
                ),
              ),
            ),
            const DGap(),
            CustomFieldsSection(
              customFields: customFields,
              controllers: _customFieldControllers,
              respectMandatory: true,
              showClearButton: false,
            ),
          ],
        );
      }),
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

  List<CustomField> _visibleCustomFields() => ref
      .read(assetCustomFieldsProvider)
      .where((f) => f.show)
      .toList();

  /// Flat map of visible custom field name → value.
  Map<String, String> _buildCustomFieldPayload() {
    final customFields = _visibleCustomFields();
    return {
      for (var field in customFields)
        field.name: _customFieldControllers[field.id]?.text ?? ''
    };
  }

  /// Matches web/API format:
  /// top-level custom keys + nested `extraFields` with the same map.
  /// Empty optional fields (`customer`, `location`, `image`) are sent as null.
  Map<String, dynamic> _buildAssetSubmitPayload(Map<String, dynamic> base) {
    final customFields = _buildCustomFieldPayload();
    final payload = <String, dynamic>{
      ...base,
      ...customFields,
      'extraFields': customFields,
    };

    for (final key in const ['customer', 'customerId', 'location', 'locationName', 'image']) {
      final value = payload[key];
      if (value == null || (value is String && value.trim().isEmpty)) {
        payload[key] = null;
      }
    }

    return payload;
  }

  /// Parses addNewAssets / update error bodies, especially UNIQUE_FIELD_VIOLATION.
  String _assetApiErrorMessage(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      if (body is! Map) return fallback;

      if (body['error'] == 'UNIQUE_FIELD_VIOLATION') {
        final fieldNames = body['fieldNames'];
        final names = fieldNames is List
            ? fieldNames.map((e) => e.toString()).join(', ')
            : '';
        if (names.isNotEmpty) {
          return 'Unique field constraint violated for: $names';
        }
        return body['message']?.toString() ??
            'Unique field constraint violated';
      }

      return body['message']?.toString() ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  /// Matches web `FileReader.readAsDataURL` format for API compatibility.
  String _toDataUri(File file) =>
      'data:image/jpeg;base64,${base64Encode(file.readAsBytesSync())}';

  void _submitAsset() async {
    setState(() => loadingAssetInsertion = true);

    // Validate static required fields
    if (!validateFields([
      _nameField.text,
    ])) {
      setState(() => loadingAssetInsertion = false);
      return dSnackBar(context, "Fill all required fields", TypeSnackbar.error);
    }

    // ✅ Validate mandatory custom fields (show fields only)
    final customFields = _visibleCustomFields();
    for (var field in customFields) {
      if (field.mandatory) {
        final value = _customFieldControllers[field.id]?.text ?? '';
        if (value.trim().isEmpty) {
          setState(() => loadingAssetInsertion = false);
          return dSnackBar(
            context,
            "${field.name} is required",
            TypeSnackbar.error,
          );
        }
      }
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
          _customerId ?? "",
          _selectedLocationBin?.label ?? "",
          _assetStatus?.toLowerCase() ?? "",
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

    // If a new image was selected, include it in the update payload using the
    // same data-uri format used when creating assets. This avoids calling the
    // separate `imageUpload` endpoint which expects a different format and
    // causes inconsistent/corrupted images after edit.
    if (_image != null) {
      base64Image = _toDataUri(_image!);
    }

    // Prefer newly selected customer id; fall back to existing when unchanged.
    final resolvedCustomerId = (_customerId != null && _customerId!.isNotEmpty)
        ? _customerId
        : widget.editAsset!.customerId;
    final resolvedCustomer =
        (_customer != null && _customer!.trim().isNotEmpty) ? _customer : null;

    final updateData = _buildAssetSubmitPayload({
      "email": userEmail,
      "assetId": widget.editAsset!.assetId,
      "id": widget.editAsset!.id,
      "name": _nameField.text,
      "serialNumber": _serialField.text,
      "category": _assetCategory ?? "",
      "customer": resolvedCustomer,
      "customerId": resolvedCustomer == null ? null : resolvedCustomerId,
      "location": _selectedLocationBin?.label,
      "locationName": _selectedLocationBin?.label,
      // Include image in update payload; if no new image selected keep
      // existing image value from the asset so server retains it.
      "image": base64Image ?? widget.editAsset!.image,
      "status": _assetStatus?.toLowerCase() ?? "",
      "companyId": int.parse(companyId),
      "updatedAt": DateTime.now().toIso8601String(),
    });

    final response = await repo.updateAsset(updateData);

    if (response.statusCode == 200) {
      // ← Add this block before the snackbar
      final customFields = _visibleCustomFields();
      for (final field in customFields) {
        if (field is CustomFieldWithValue) {
          final newValue =
              _customFieldControllers[field.id]?.text ?? field.value;
          final payload = field.toUpdateJson(newValue);
          try {
            await repo.addExtraFieldsWithValue(payload);
          } catch (e) {
            print('⚠️ Failed to update extra field ${field.name}: $e');
            // Non-fatal — continue saving other fields
          }
        }
      }

      if (mounted) {
        ref.read(refreshProvider.notifier).state = !ref.read(refreshProvider);
        dSnackBar(context, "Asset Updated Successfully", TypeSnackbar.success);
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        dSnackBar(
          context,
          _assetApiErrorMessage(response, "Failed to update asset"),
          TypeSnackbar.error,
        );
      }
    }
    setState(() => loadingAssetInsertion = false);
  }

  bool validateFields(List<String> values) =>
      values.every((value) => value.isNotEmpty);

  Future<void> _insertAssetData(
      String name,
      String serialNumber,
      String category,
      String customer,
      String customerId,
      String location,
      String status) async {
    final repo = AssetsRepositoryImpl();

    if (_image != null) base64Image = _toDataUri(_image!);

    final data = AssetsModel(
      name: name,
      serialNumber: serialNumber,
      category: category,
      email: userEmail,
      customer: customer,
      customerId: customerId,
      location: location,
      status: status,
      image: base64Image,
      companyId: companyId,
    );

    print("ASSET DATA: ${data.toJson()}");

    final payloadMap = _buildAssetSubmitPayload(data.toJson());
    final payloadBody = json.encode(payloadMap);

    // Log payload without dumping full base64 image.
    final logPayload = Map<String, dynamic>.from(payloadMap);
    final imageValue = logPayload['image'];
    if (imageValue is String && imageValue.isNotEmpty) {
      logPayload['image'] =
          '<base64 omitted, length=${imageValue.length}>';
    }
    print('📤 addNewAssets payload: ${json.encode(logPayload)}');
    print('📤 addNewAssets custom fields: ${_buildCustomFieldPayload()}');

    final response = await repo.addNewAsset(payloadBody);
    print(
      '📥 addNewAssets response: status=${response.statusCode} body=${response.body}',
    );

    if (response.statusCode == 200) {
      final id = jsonDecode(response.body)["id"];

      // Determine default employee after we have the asset id: prefer first technical user
      String? defaultEmployee = customer;
      try {
        final techUsers = await ref.read(technicalUsersProvider(companyId).future);
        if (techUsers.isNotEmpty) defaultEmployee = techUsers.first;
      } catch (e) {
        print('Could not fetch technical users, using customer as employee: $e');
      }

      DeviceLocationPayload? locationPayload;
      try {
        locationPayload = await DeviceLocationUtils.captureRequired();
      } catch (e) {
        print('Could not capture location for initial check-in: $e');
      }

      if (locationPayload != null) {
        final checkInData = {
          'assetId': id,
          'status': checkInString,
          'companyId': companyId,
          'employee': defaultEmployee,
          'notes': null,
          'location': location,
          'date': DateTime.now().toIso8601String(),
          ...locationPayload.toJson(),
        };
        final payload = json.encode(checkInData);
        print('addCheckInOut payload: $payload');

        try {
          await repo.addCheckInOut(payload);
        } catch (e) {
          print('Failed to add initial check-in: $e');
        }
      }

      if (mounted) {
        // Trigger global refresh for dashboard/home
        ref.read(refreshProvider.notifier).state = !ref.read(refreshProvider);
        dSnackBar(context, "Asset Inserted Successfully", TypeSnackbar.success);

        // Open the newly created asset's details and return true to the assets list
        final shouldRefresh = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => ViewAssetPage(
              assetObjectId: id.toString(),
              refreshOnPop: true,
            ),
          ),
        );

        if (mounted && shouldRefresh == true) {
          Navigator.of(context).pop(true);
        }
      }
    } else {
      if (mounted) {
        dSnackBar(
          context,
          _assetApiErrorMessage(
            response,
            "Failed to insert asset",
          ),
          TypeSnackbar.error,
        );
      }
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
    final XFile? image =
        await picker.pickImage(source: source, imageQuality: 70);
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../core/utils/constants/sizes.dart';
import '../../../../core/utils/widgets/async_dropdown_search_widget.dart';
import '../../../../core/utils/widgets/custom_fields_section.dart';
import '../../../../core/utils/widgets/d_dropdown.dart';
import '../../../../core/utils/widgets/d_gap.dart';
import '../../../../core/utils/widgets/d_text_field.dart';
import '../../../../core/utils/widgets/my_elevated_button.dart';
import '../../../Customers/data/repository/company_customer_repository_impl.dart';
import '../../data/data_sources/asset_status_data.dart';
import '../../data/repository/assets_repository_impl.dart';
import '../pages/add_asset_page.dart';
import '../riverpod/asset_custom_fields_provider.dart';
import '../riverpod/asset_filter_notifier.dart';

class AssetFilterForm extends ConsumerStatefulWidget {
  final AssetFilterData initialData;
  final Function(AssetFilterData) onApplyFilters;
  final VoidCallback onClearFilters;

  const AssetFilterForm({
    super.key,
    required this.initialData,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  ConsumerState<AssetFilterForm> createState() => _AssetFilterFormState();
}

class _AssetFilterFormState extends ConsumerState<AssetFilterForm> {
  late final TextEditingController _assetIdController;
  late final TextEditingController _assetNameController;
  late final TextEditingController _serialNumberController;
  late final TextEditingController _locationController;
  late final TextEditingController _customerController;

  String? _assetStatus;
  String? _assetCategory;
  String? _customer;
  String? _checkingStatus;
  LocationBinOption? _selectedLocationBin;

  final Map<String, TextEditingController> _customFieldControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _assetIdController =
        TextEditingController(text: widget.initialData.assetId);
    _assetNameController = TextEditingController(text: widget.initialData.name);
    _serialNumberController =
        TextEditingController(text: widget.initialData.serialNumber);
    _locationController =
        TextEditingController(text: widget.initialData.location);
    _customerController =
        TextEditingController(text: widget.initialData.customer);

    _assetStatus = widget.initialData.status;
    _assetCategory = widget.initialData.category;
    _customer = widget.initialData.customer;
    _checkingStatus = widget.initialData.checkingStatus;

    widget.initialData.customFieldValues.forEach((key, value) {
      _customFieldControllers[key] = TextEditingController(text: value);
    });
  }

  @override
  void dispose() {
    _assetIdController.dispose();
    _assetNameController.dispose();
    _serialNumberController.dispose();
    _locationController.dispose();
    _customerController.dispose();
    for (var c in _customFieldControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2 * dPadding),
      decoration: const BoxDecoration(
        color: tWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildFormFields()),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Select Filters', style: boldHeading()),
          TextButton(
            onPressed: _clearFilters,
            child: Text("CLEAR", style: boldHeading(size: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCustomFields(),
          _buildStaticFields(),
          const DGap(),
        ],
      ),
    );
  }

  Widget _buildCustomFields() {
    final customFields = ref.watch(assetCustomFieldsProvider);
    return CustomFieldsSection(
      customFields: customFields,
      controllers: _customFieldControllers,
      showClearButton: true,
    );
  }

  Widget _buildStaticFields() {
    return Column(
      children: [
        DTextField(
          icon: const Icon(Icons.tag),
          hintText: "Asset ID",
          controller: _assetIdController,
        ),
        DTextField(
          icon: const Icon(Icons.label),
          hintText: "Asset Name",
          controller: _assetNameController,
        ),
        AsyncDropdownField<Map<String, dynamic>>(
          label: "Customer",
          asyncItemsFetcher: () async {
            try {
              final response = await CompanyCustomerRepositoryImpl()
                  .getCompanyCustomer(widget.initialData.companyId);
              if (response.statusCode == 200) {
                final customers = jsonDecode(response.body) as List;
                return customers.map((e) => e as Map<String, dynamic>).toList();
              }
            } catch (e) {
              print("Error fetching customers: $e");
            }
            return [];
          },
          displayString: (customer) => customer['name'].toString(),
          onChanged: (value) => setState(() {
            _customer = value?['name'].toString();
            _customerController.text = _customer ?? '';
          }),
          selectedItem: _customer != null ? {'name': _customer} : null,
        ),
        DTextField(
          icon: const Icon(Icons.confirmation_number),
          hintText: "Serial Number",
          controller: _serialNumberController,
        ),
        AsyncDropdownField<Map<String, dynamic>>(
          label: "Category",
          asyncItemsFetcher: () async {
            try {
              final response = await AssetsRepositoryImpl()
                  .getActiveCategories(widget.initialData.companyId);
              if (response.statusCode == 200) {
                final categories = jsonDecode(response.body) as List;
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
          onChanged: (value) => setState(() {
            _assetCategory = value?['name'].toString();
          }),
          selectedItem:
              _assetCategory != null ? {'name': _assetCategory} : null,
        ),
        AsyncDropdownField<LocationBinOption>(
          label: "Location",
          asyncItemsFetcher: () async {
            try {
              final response = await CompanyCustomerRepositoryImpl()
                  .getCustomerLocationsAndBins(widget.initialData.companyId);
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
              print('Failed to load locations: $e');
              return [];
            }
          },
          displayString: (locationBin) => locationBin.label,
          onChanged: (value) => setState(() {
            _selectedLocationBin = value;
            _locationController.text = value?.label ?? '';
          }),
          selectedItem: _selectedLocationBin,
        ),
        DDropdown(
          padding: const EdgeInsets.symmetric(horizontal: dPadding),
          label: "Status",
          items: assetStatusMenuItems,
          value: _assetStatus,
          onChanged: (value) => setState(() => _assetStatus = value),
        ),
        const DGap(),
        DDropdown(
          padding: const EdgeInsets.symmetric(horizontal: dPadding),
          label: "Checking Status",
          items: const [
            DropdownMenuItem(value: "All", child: Text("All")),
            DropdownMenuItem(value: "Checked In", child: Text("Checked In")),
            DropdownMenuItem(value: "Checked Out", child: Text("Checked Out")),
          ],
          value: _checkingStatus ?? 'All',
          onChanged: (value) => setState(() => _checkingStatus = value),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return SizedBox(
      height: 40,
      child: DElevatedButton(
        buttonColor: tBlack,
        textColor: tWhite,
        onPressed: _applyFilters,
        child: const Text('Apply Filters'),
      ),
    );
  }

  void _applyFilters() {
    final customFields = ref.read(assetCustomFieldsProvider);
    final Map<String, String> customValues = {};
    for (var field in customFields) {
      customValues[field.id] = _customFieldControllers[field.id]?.text ?? '';
    }

    widget.onApplyFilters(AssetFilterData(
      companyId: widget.initialData.companyId,
      assetId: _assetIdController.text,
      name: _assetNameController.text,
      customer: _customerController.text,
      serialNumber: _serialNumberController.text,
      category: _assetCategory ?? '',
      location: _locationController.text,
      status: _assetStatus ?? '',
      checkingStatus: _checkingStatus ?? 'All',
      customFieldValues: customValues,
      customFieldNames: {for (var f in customFields) f.id: f.name},
    ));
  }

  void _clearFilters() {
    setState(() {
      _assetIdController.clear();
      _assetNameController.clear();
      _customerController.clear();
      _serialNumberController.clear();
      _locationController.clear();
      _assetStatus = '';
      _assetCategory = null;
      _customer = null;
      _checkingStatus = 'All';
      _selectedLocationBin = null;
      for (var c in _customFieldControllers.values) {
        c.clear();
      }
    });
    widget.onClearFilters();
  }
}

// ───────────────────────────────────────────────
// Data class
// ───────────────────────────────────────────────

class AssetFilterData {
  final String companyId;
  final String assetId;
  final String name;
  final String customer;
  final String serialNumber;
  final String category;
  final String location;
  final String status;
  final String checkingStatus;
  final Map<String, String> customFieldValues;
  final Map<String, String> customFieldNames;

  const AssetFilterData({
    required this.companyId,
    this.assetId = '',
    this.name = '',
    this.customer = '',
    this.serialNumber = '',
    this.category = '',
    this.location = '',
    this.status = 'Active',
    this.checkingStatus = 'All',
    this.customFieldValues = const {},
    this.customFieldNames = const {},
  });

  Map<String, dynamic> toFilterForm() {
    final form = <String, dynamic>{
      'assetId': assetId,
      'name': name,
      'customer': customer,
      'serialNumber': serialNumber,
      'category': category,
      'location': location,
      'status': status,
      'email': '',
      'companyId': companyId,
    };

    customFieldValues.forEach((fieldId, value) {
      final fieldName = customFieldNames[fieldId];
      if (fieldName != null && fieldName.isNotEmpty) {
        form[fieldName] = value;
      }
    });

    return form;
  }
}

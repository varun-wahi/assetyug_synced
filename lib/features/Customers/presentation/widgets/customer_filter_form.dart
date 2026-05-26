import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/container_styles.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../core/utils/constants/sizes.dart';
import '../../../../core/utils/widgets/d_dropdown.dart';
import '../../../../core/utils/widgets/d_gap.dart';
import '../../../../core/utils/widgets/d_text_field.dart';
import '../../../../core/utils/widgets/my_elevated_button.dart';
import '../riverpod/customer_category_provider.dart';
import '../riverpod/customer_custom_fields_provider.dart';
import '../../data/data_sources/customer_status_data.dart';
import '../../data/repository/company_customer_repository_impl.dart';

class CustomerFilterForm extends ConsumerStatefulWidget {
  final CustomerFilterData initialData;
  final Function(CustomerFilterData) onApplyFilters;
  final VoidCallback onClearFilters;

  const CustomerFilterForm({
    super.key,
    required this.initialData,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  ConsumerState<CustomerFilterForm> createState() => _CustomerFilterFormState();
}

class _CustomerFilterFormState extends ConsumerState<CustomerFilterForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  String? _selectedCategory;
  String? _selectedStatus;

  // Dynamic custom field controllers keyed by field id
  final Map<String, TextEditingController> _customFieldControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // Load custom fields after frame to avoid provider mutation during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomFields();
    });
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.initialData.name);
    _addressController =
        TextEditingController(text: widget.initialData.address);
    _phoneController = TextEditingController(text: widget.initialData.phone);
    _selectedCategory = widget.initialData.category;
    _selectedStatus = widget.initialData.status;

    // Restore custom field values from initialData
    widget.initialData.customFieldValues.forEach((key, value) {
      _customFieldControllers[key] = TextEditingController(text: value);
    });
  }

  Future<void> _loadCustomFields() async {
    final notifier = ref.read(customerCustomFieldsProvider.notifier);
    final repo = CompanyCustomerRepositoryImpl();
    final companyId = await repo.getCompanyId();
    if (companyId != null) {
      await notifier.loadCustomFields(companyId);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
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
          // --- Dynamic custom fields from server ---
          Consumer(builder: (context, ref, _) {
            final customFields = ref.watch(customerCustomFieldsProvider);
            return Column(
              children: customFields.map((field) {
                // Ensure a controller exists for each field
                if (!_customFieldControllers.containsKey(field.id)) {
                  _customFieldControllers[field.id] = TextEditingController();
                }
                final controller = _customFieldControllers[field.id]!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: dPadding),
                  child: DTextField(
                    icon: const Icon(Icons.tune),
                    hintText: field.name,
                    controller: controller,
                    textInputType: field.type == "number"
                        ? TextInputType.number
                        : TextInputType.text,
                  ),
                );
              }).toList(),
            );
          }),
          // --- Static fields ---
          DTextField(
            icon: const Icon(Icons.tag),
            hintText: "Name",
            controller: _nameController,
          ),
          DTextField(
            icon: const Icon(Icons.person),
            hintText: "Address",
            controller: _addressController,
          ),
          DTextField(
            icon: const Icon(Icons.confirmation_number),
            hintText: "Phone Number",
            controller: _phoneController,
          ),
          ref.watch(customerCategoriesProvider).when(
                data: (categories) => DDropdown(
                  padding: const EdgeInsets.symmetric(horizontal: dPadding),
                  label: "Category",
                  items: categories
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                  value: _selectedCategory,
                ),
                loading: () => DDropdown(
                  padding: const EdgeInsets.symmetric(horizontal: dPadding),
                  label: "Category",
                  items: const [],
                  onChanged: (val) {},
                  value: null,
                ),
                error: (err, stack) => const DTextField(
                  hintText: "Error loading categories",
                  enabled: false,
                ),
              ),
          const DGap(),
          DDropdown(
            padding: const EdgeInsets.symmetric(horizontal: dPadding),
            label: "Status",
            items: customerStatusMenuItems,
            onChanged: (value) => setState(() => _selectedStatus = value),
            value: _selectedStatus,
          ),
          const DGap(),
        ],
      ),
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
    // Collect custom field values
    final Map<String, String> customValues = {};
    final customFields = ref.read(customerCustomFieldsProvider);
    for (var field in customFields) {
      final controller = _customFieldControllers[field.id];
      customValues[field.id] = controller?.text ?? '';
    }

    final filterData = CustomerFilterData(
      name: _nameController.text,
      address: _addressController.text,
      phone: _phoneController.text,
      category: _selectedCategory,
      status: _selectedStatus,
      customFieldValues: customValues,
      customFieldNames: {
        for (var f in customFields) f.id: f.name,
      },
    );
    widget.onApplyFilters(filterData);
  }

  void _clearFilters() {
    setState(() {
      _nameController.clear();
      _addressController.clear();
      _phoneController.clear();
      _selectedCategory = null;
      _selectedStatus = null;
      for (var c in _customFieldControllers.values) {
        c.clear();
      }
    });
    widget.onClearFilters();
  }
}

class CustomerFilterData {
  final String name;
  final String address;
  final String phone;
  final String? category;
  final String? status;
  // Custom field values keyed by field id
  final Map<String, String> customFieldValues;
  // Custom field names keyed by field id (for building the filter form payload)
  final Map<String, String> customFieldNames;

  const CustomerFilterData({
    this.name = '',
    this.address = '',
    this.phone = '',
    this.category,
    this.status,
    this.customFieldValues = const {},
    this.customFieldNames = const {},
  });

  Map<String, String> toFilterForm(String companyId) {
    final form = {
      "name": name,
      "companyId": companyId,
      "category": category ?? "",
      "status": status ?? "",
      "phone": phone,
      "email": "",
      "address": address,
      "apartment": "",
      "city": "",
      "state": "",
      "zipCode": ""
    };

    // Append dynamic custom fields using field name as key
    customFieldValues.forEach((fieldId, value) {
      final fieldName = customFieldNames[fieldId];
      if (fieldName != null && fieldName.isNotEmpty) {
        form[fieldName] = value;
      }
    });

    return form;
  }

  CustomerFilterData copyWith({
    String? name,
    String? address,
    String? phone,
    String? category,
    String? status,
    Map<String, String>? customFieldValues,
    Map<String, String>? customFieldNames,
  }) {
    return CustomerFilterData(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      category: category ?? this.category,
      status: status ?? this.status,
      customFieldValues: customFieldValues ?? this.customFieldValues,
      customFieldNames: customFieldNames ?? this.customFieldNames,
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../config/theme/container_styles.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../core/utils/constants/sizes.dart';
import '../../../../core/utils/widgets/d_dropdown.dart';
import '../../../../core/utils/widgets/d_gap.dart';
import '../../../../core/utils/widgets/d_text_field.dart';
import '../../../../core/utils/widgets/my_elevated_button.dart';
import '../../data/data_sources/customer_category_data.dart';
import '../../data/data_sources/customer_status_data.dart';

class CustomerFilterForm extends StatefulWidget {
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
  State<CustomerFilterForm> createState() => _CustomerFilterFormState();
}

class _CustomerFilterFormState extends State<CustomerFilterForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  String? _selectedCategory;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.initialData.name);
    _addressController = TextEditingController(text: widget.initialData.address);
    _phoneController = TextEditingController(text: widget.initialData.phone);
    _selectedCategory = widget.initialData.category;
    _selectedStatus = widget.initialData.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
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
      height: 500,
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
          DDropdown(
            padding: const EdgeInsets.symmetric(horizontal: dPadding),
            label: "Category",
            items: customerCategoryTypeMenuItems,
            onChanged: (value) => setState(() => _selectedCategory = value),
            value: _selectedCategory,
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
          _buildPlaceholderSection(),
        ],
      ),
    );
  }

  Widget _buildPlaceholderSection() {
    return Container(
      decoration: dBoxDecoration(color: tBackground),
      child: Text("Extra fields to be added soon", style: subtitle()),
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
    final filterData = CustomerFilterData(
      name: _nameController.text,
      address: _addressController.text,
      phone: _phoneController.text,
      category: _selectedCategory,
      status: _selectedStatus,
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

  const CustomerFilterData({
    this.name = '',
    this.address = '',
    this.phone = '',
    this.category,
    this.status,
  });

  Map<String, String> toFilterForm(String companyId) {
    return {
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
  }

  CustomerFilterData copyWith({
    String? name,
    String? address,
    String? phone,
    String? category,
    String? status,
  }) {
    return CustomerFilterData(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      category: category ?? this.category,
      status: status ?? this.status,
    );
  }
}
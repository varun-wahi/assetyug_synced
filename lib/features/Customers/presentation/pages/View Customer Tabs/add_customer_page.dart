import 'package:asset_yug_debugging/features/Customers/data/data_sources/customer_category_data.dart';
import 'package:asset_yug_debugging/features/Main/presentation/pages/MainPage.dart';
import 'package:asset_yug_debugging/features/Main/presentation/riverpod/tab_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

import '../../../../../config/theme/snackbar__types_enum.dart';
import '../../../../../core/utils/constants/colors.dart';
import '../../../../../core/utils/constants/sizes.dart';
import '../../../../../core/utils/widgets/d_dropdown.dart';
import '../../../../../core/utils/widgets/d_gap.dart';
import '../../../../../core/utils/widgets/d_snackbar.dart';
import '../../../../../core/utils/widgets/my_elevated_button.dart';
import '../../../../Assets/presentation/widgets/custom_text_field.dart';
import '../../../../Main/presentation/riverpod/refresh_provider.dart';
import '../../../data/repository/company_customer_repository_impl.dart';

import 'package:http/http.dart' as http;

class AddCustomerPage extends ConsumerStatefulWidget { 
  final bool fromCustomersPage;

  const AddCustomerPage({super.key, this.fromCustomersPage = false});// Change to ConsumerStatefulWidget
  @override
  // ignore: library_private_types_in_public_api
  _AddCustomerPageState createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends ConsumerState<AddCustomerPage> {  // Update to use ConsumerState
  final _nameField = TextEditingController();
  final _phoneField = TextEditingController();
  final _emailField = TextEditingController();
  final _addressField = TextEditingController();
  final _cityField = TextEditingController();
  final _stateField = TextEditingController();
  final _zipCodeField = TextEditingController();

  String? _category;
  String? _status = "Active";

  late final String companyId;
  bool loadingCustomerInsertion = false;

  final CompanyCustomerRepositoryImpl _customerRepo = CompanyCustomerRepositoryImpl();

  void _changeCategoryValue(String? option) => _category = option;
  void _changeStatusValue(String? option) => _status = option;

  @override
  void initState() {
    super.initState();
    getCompanyId();
  }

  Future<void> getCompanyId() async {
    var box = await Hive.openBox('auth_data');
    setState(() {
      companyId = box.get('companyId');
    });
  }

  @override
  Widget build(BuildContext context) {
    final WidgetRef ref = this.ref; // Get the `ref` inside the build method

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Add Customer"),
          leading: IconButton(
  onPressed: () {
    if (widget.fromCustomersPage) {
      // Wrap in a function to delay execution
      ref.read(tabProvider.notifier).setTab(3);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else {
      Navigator.pop(context);
    }
  },
  icon: const Icon(Icons.arrow_back_ios_new),
),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(dPadding * 2),
              padding: const EdgeInsets.all(dPadding * 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildCustomTextField(
                          "Name", TextInputType.text, _nameField, true),
                      const DGap(),
                      DDropdown(
                        label: "Category",
                        items: customerCategoryTypeMenuItems,
                        onChanged: (value) => _changeCategoryValue(value),
                        value: _category,
                      ),
                      const DGap(),
                      DDropdown(
                        label: "Status",
                        items: const [
                          DropdownMenuItem(value: 'Active', child: Text('Active')),
                          DropdownMenuItem(value: 'InActive', child: Text('Inactive')),
                        ],
                        onChanged: (value) => _changeStatusValue(value),
                        value: _status,
                      ),
                      const DGap(),
                      buildCustomTextField(
                          "Phone", TextInputType.phone, _phoneField, true),
                      const DGap(),
                      buildCustomTextField(
                          "Email", TextInputType.emailAddress, _emailField, true),
                      const DGap(),
                      buildCustomTextField(
                          "Address", TextInputType.text, _addressField, true),
                      const DGap(),
                      buildCustomTextField(
                          "City", TextInputType.text, _cityField, true),
                      const DGap(),
                      buildCustomTextField(
                          "State", TextInputType.text, _stateField, true),
                      const DGap(),
                      buildCustomTextField(
                          "ZipCode", TextInputType.number, _zipCodeField, true),
                      const DGap(),
                    ],
                  ),
                  const DGap(),
                  DElevatedButton(
                    buttonColor: tPrimary,
                    textColor: tWhite,
                    onPressed: () {
                      setState(() {
                        loadingCustomerInsertion = true;
                      });
                      // Submit form data
                      _submitCustomerData(ref);  // Pass ref to _submitCustomerData
                    },
                    child: loadingCustomerInsertion
                        ? const SizedBox(
                            height: 20.0,
                            width: 20.0,
                            child: CircularProgressIndicator(color: tWhite),
                          )
                        : const Text("Add Customer"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitCustomerData(WidgetRef ref) async {
    if (_nameField.text.isEmpty ||
        _category == null ||
        _status == null ||
        _phoneField.text.isEmpty ||
        _emailField.text.isEmpty) {
      setState(() {
        loadingCustomerInsertion = false;
      });
      dSnackBar(context, "Fill all required fields", TypeSnackbar.error);
      return;
    }

    Map<String, dynamic> customerData = {
      'name': _nameField.text,
      'companyId': companyId,
      'category': _category,
      'status': _status,
      'phone': _phoneField.text,
      'email': _emailField.text,
      'address': _addressField.text,
      'city': _cityField.text,
      'state': _stateField.text,
      'zipCode': _zipCodeField.text,
    };

    try {
      http.Response response = await _customerRepo.addCompanyCustomer(customerData);
      if (response.statusCode == 200) {
        dSnackBar(context, "Customer Added Successfully", TypeSnackbar.success);
        clearFields();
        // Notify the app to refresh customer list
        ref.read(refreshProvider.notifier).state = !ref.read(refreshProvider);
      } else {
        dSnackBar(context, "Failed to add customer", TypeSnackbar.error);
      }
    } catch (e) {
      dSnackBar(context, "Error: ${e.toString()}", TypeSnackbar.error);
    }

    setState(() {
      loadingCustomerInsertion = false;
    });
  }

  void clearFields() {
    setState(() {
      _nameField.clear();
      _category = null;
      _status = null;
      _phoneField.clear();
      _emailField.clear();
      _addressField.clear();
      _cityField.clear();
      _stateField.clear();
      _zipCodeField.clear();
    });
  }
}
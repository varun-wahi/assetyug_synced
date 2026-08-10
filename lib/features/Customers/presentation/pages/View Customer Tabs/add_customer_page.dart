import 'dart:convert';

import 'package:asset_yug_debugging/features/Main/presentation/pages/MainPage.dart';
import 'package:asset_yug_debugging/features/Main/presentation/riverpod/tab_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

import '../../../../../config/theme/snackbar__types_enum.dart';
import '../../../../../core/utils/constants/colors.dart';
import '../../../../../core/utils/constants/sizes.dart';
import '../../../../../core/utils/widgets/custom_fields_section.dart';
import '../../../../../core/utils/widgets/d_dropdown.dart';
import '../../../../../core/utils/widgets/d_gap.dart';
import '../../../../../core/utils/widgets/d_snackbar.dart';
import '../../../../../core/utils/widgets/my_elevated_button.dart';
import '../../../../Assets/presentation/widgets/custom_text_field.dart';
import '../../../../Main/presentation/riverpod/refresh_provider.dart';
import '../../riverpod/customer_category_provider.dart';
import '../../../data/repository/company_customer_repository_impl.dart';

import 'package:http/http.dart' as http;

import '../../riverpod/customer_custom_fields_provider.dart';
import '../view_customer_page.dart';

class AddCustomerPage extends ConsumerStatefulWidget {
  final bool fromCustomersPage;

  const AddCustomerPage(
      {super.key,
      this.fromCustomersPage = false}); // Change to ConsumerStatefulWidget
  @override
  // ignore: library_private_types_in_public_api
  _AddCustomerPageState createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends ConsumerState<AddCustomerPage> {
  // Update to use ConsumerState
  final _nameField = TextEditingController();
  final _phoneField = TextEditingController();
  final _emailField = TextEditingController();
  final _addressField = TextEditingController();
  final _cityField = TextEditingController();
  final _stateField = TextEditingController();
  final _zipCodeField = TextEditingController();
  final _locationField = TextEditingController();
  final Map<String, TextEditingController> _customFieldControllers = {};

  List<DropdownMenuItem<String>> _stateItems = [];
  String? _selectedState;

  String? _category;
  String? _status = "Active";

  // late final String companyId;
  String? companyId;
  bool loadingCustomerInsertion = false;

  final CompanyCustomerRepositoryImpl _customerRepo =
      CompanyCustomerRepositoryImpl();

  void _changeCategoryValue(String? option) => _category = option;
  void _changeStatusValue(String? option) => _status = option;
  bool _hasLoadedDropdowns = false;
  @override
  void dispose() {
    _nameField.dispose();
    _phoneField.dispose();
    _emailField.dispose();
    _addressField.dispose();
    _cityField.dispose();
    _stateField.dispose();
    _zipCodeField.dispose();
    _locationField.dispose();

    // ✅ Dispose custom field controllers
    for (var c in _customFieldControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCustomerPage();
    });
  }

  Future<void> _initializeCustomerPage() async {
    var box = await Hive.openBox('auth_data');
    final id = box.get('companyId');
    setState(() {
      companyId = id;
    });
    await fetchDropdownData();

    if (companyId != null && mounted) {
      ref.invalidate(customerCustomFieldsProvider);
      await ref
          .read(customerCustomFieldsProvider.notifier)
          .loadCustomFields(companyId!);
    }
  }

  Future<void> initCompanyData() async {
    var box = await Hive.openBox('auth_data');
    final id = box.get('companyId');
    setState(() {
      companyId = id;
    });
    await fetchDropdownData(); // safe now — context is ready
  }

  Future<void> fetchDropdownData() async {
    if (companyId == null) return;

    try {
      // final catRes =
      //     await _customerRepo.getActiveCustomerCategories(companyId!);
      final stateRes = await _customerRepo.statelist();

      // if (catRes.statusCode == 200) {
      //   final List<dynamic> categoryList = jsonDecode(catRes.body);
      //   setState(() {
      //     _categoryItems = categoryList.map<DropdownMenuItem<String>>((item) {
      //       return DropdownMenuItem(
      //         value: item['name'], // ← FIXED from item['categoryName']
      //         child: Text(item['name']),
      //       );
      //     }).toList();
      //   });
      // }

      if (stateRes.statusCode == 200) {
        final List<dynamic> stateList = jsonDecode(stateRes.body);
        setState(() {
          _stateItems = stateList.map<DropdownMenuItem<String>>((state) {
            return DropdownMenuItem(
              value: state,
              child: Text(state),
            );
          }).toList();
        });
      }
    } catch (e) {
      dSnackBar(context, "Failed to load dropdowns: ${e.toString()}",
          TypeSnackbar.error);
    }
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

    return DefaultTabController(
      length: 2,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Add Customer"),
            leading: IconButton(
              onPressed: () {
                if (widget.fromCustomersPage) {
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
                      _buildDetailsTab(ref),
                      _buildCustomFieldsTab(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: dPadding * 2, vertical: dPadding),
                  child: DElevatedButton(
                    buttonColor: tPrimary,
                    textColor: tWhite,
                    onPressed: () {
                      setState(() {
                        loadingCustomerInsertion = true;
                      });
                      _submitCustomerData(ref);
                    },
                    child: loadingCustomerInsertion
                        ? const SizedBox(
                            height: 20.0,
                            width: 20.0,
                            child: CircularProgressIndicator(color: tWhite),
                          )
                        : const Text("Add Customer"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(dPadding * 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildCustomTextField("Name", TextInputType.text, _nameField, true),
          const DGap(),
          ref.watch(customerCategoriesProvider).when(
                data: (categories) => DDropdown(
                  label: "Category",
                  items: categories
                      .map((cat) => DropdownMenuItem(
                          value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) => _changeCategoryValue(value),
                  value: _category,
                ),
                loading: () => DDropdown(
                  label: "Category",
                  items: const [],
                  onChanged: (val) {},
                  value: null,
                ),
                error: (err, stack) => const Text("Error"),
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
          buildCustomTextField("Phone", TextInputType.phone, _phoneField, false),
          const DGap(),
          buildCustomTextField("Email", TextInputType.emailAddress,
              _emailField, false),
          const DGap(),
          buildCustomTextField("Address", TextInputType.text, _addressField, false),
          const DGap(),
          buildCustomTextField("City", TextInputType.text, _cityField, false),
          const DGap(),
          DDropdown(
            label: "State",
            items: _stateItems,
            onChanged: (value) => setState(() => _selectedState = value),
            value: _selectedState,
          ),
          const DGap(),
          buildCustomTextField("Zip Code", TextInputType.number,
              _zipCodeField, false),
        ],
      ),
    );
  }

  Widget _buildCustomFieldsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(dPadding * 2),
      child: Consumer(builder: (context, ref, _) {
        final customFields = ref.watch(customerCustomFieldsProvider);
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
            const Text(
              "Custom Fields",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const DGap(),
            CustomFieldsSection(
              customFields: customFields,
              controllers: _customFieldControllers,
              showClearButton: false,
              respectMandatory: true,
            ),
          ],
        );
      }),
    );
  }

  void _submitCustomerData(WidgetRef ref) async {
    String phone = _phoneField.text.trim();
    String email = _emailField.text.trim();

    if (_nameField.text.isEmpty) {
      setState(() {
        loadingCustomerInsertion = false;
      });
      dSnackBar(context, "Customer name is required", TypeSnackbar.error);
      return;
    }

    final phoneRegex = RegExp(r'^\d{10}$');
    if (phone.isNotEmpty && !phoneRegex.hasMatch(phone)) {
      setState(() {
        loadingCustomerInsertion = false;
      });
      dSnackBar(
        context,
        "Enter a valid 10-digit phone number or leave it blank",
        TypeSnackbar.error,
      );
      return;
    }

    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (email.isNotEmpty && !emailRegex.hasMatch(email)) {
      setState(() {
        loadingCustomerInsertion = false;
      });
      dSnackBar(
        context,
        "Enter a valid email address or leave it blank",
        TypeSnackbar.error,
      );
      return;
    }

    final customFields = ref.read(customerCustomFieldsProvider);
    for (var field in customFields) {
      if (field.mandatory) {
        final value = _customFieldControllers[field.id]?.text ?? '';
        if (value.trim().isEmpty) {
          setState(() => loadingCustomerInsertion = false);
          dSnackBar(context, "${field.name} is required", TypeSnackbar.error);
          return;
        }
      }
    }

    final Map<String, dynamic> customerData = {
      'name': _nameField.text,
      'companyId': companyId,
      'category': _category,
      'status': _status,
      'phone': _phoneField.text,
      'email': _emailField.text,
      'address': _addressField.text,
      'apartment': null,
      'city': _cityField.text,
      'state': _selectedState,
      'zipCode': _zipCodeField.text,
      'Customer Location': _locationField.text,

      // ✅ Append custom fields by name
      for (var field in customFields)
        field.name: _customFieldControllers[field.id]?.text ?? '',
    };
    try {
      http.Response response =
          await _customerRepo.addCompanyCustomer(customerData);
      if (response.statusCode == 200) {
        dSnackBar(context, "Customer Added Successfully", TypeSnackbar.success);
        clearFields();
        // Notify the app to refresh customer list in the caller
        ref.read(refreshProvider.notifier).state = !ref.read(refreshProvider);

        String? customerId;
        try {
          final body = jsonDecode(response.body);
          customerId = body['id']?.toString() ?? body['data']?['id']?.toString();
        } catch (e) {
          print('Failed to parse new customer id: $e');
        }

        if (customerId != null && customerId.isNotEmpty) {
          final shouldRefresh = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => ViewCustomerPage(
                customerObjectId: customerId!,
                refreshOnPop: true,
              ),
            ),
          );
          if (mounted && shouldRefresh == true) {
            Navigator.of(context).pop(true);
          }
        }
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
      _locationField.clear();

      // ✅ Clear custom fields
      for (var c in _customFieldControllers.values) {
        c.clear();
      }
    });
  }
}

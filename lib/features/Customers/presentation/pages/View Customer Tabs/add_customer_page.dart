import 'dart:convert';

import 'package:asset_yug_debugging/features/Main/presentation/pages/MainPage.dart';
import 'package:asset_yug_debugging/features/Main/presentation/riverpod/tab_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

import '../../../../../config/theme/snackbar__types_enum.dart';
import '../../../../../core/utils/constants/colors.dart';
import '../../../../../core/utils/constants/countries.dart';
import '../../../../../core/utils/constants/sizes.dart';
import '../../../../../core/utils/widgets/custom_fields_section.dart';
import '../../../../../core/utils/widgets/d_dropdown.dart';
import '../../../../../core/utils/widgets/d_gap.dart';
import '../../../../../core/utils/widgets/d_snackbar.dart';
import '../../../../../core/utils/widgets/my_elevated_button.dart';
import '../../../../../core/utils/widgets/phone_number_field.dart';
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
  final _emailField = TextEditingController();
  final _addressField = TextEditingController();
  final _cityField = TextEditingController();
  final _stateField = TextEditingController();
  final _zipCodeField = TextEditingController();
  final _locationField = TextEditingController();
  final Map<String, TextEditingController> _customFieldControllers = {};

  List<DropdownMenuItem<String>> _stateItems = [];
  String? _selectedState;

  // Country dropdown - drives which states get loaded and the phone
  // field's default dial code.
  final List<DropdownMenuItem<String>> _countryItems = kNorthAmericaCountries
      .map((c) => DropdownMenuItem(value: c.name, child: Text(c.name)))
      .toList();
  String? _selectedCountry = kDefaultCountryName;

  // Phone number - kept as plain state (rather than a TextEditingController)
  // since IntlPhoneField manages its own internal controller.
  String _phoneNumber = '';
  bool _phoneValid = true;

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

    // Force fresh network data every time this page is opened.
    ref.invalidate(customerCategoriesProvider);
    ref.invalidate(customerCustomFieldsProvider);

    await fetchDropdownData();
    await _fetchStatesForCountry(_selectedCountry ?? kDefaultCountryName);

    if (companyId != null && mounted) {
      await ref
          .read(customerCustomFieldsProvider.notifier)
          .loadCustomFields(companyId!.toString());
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
    } catch (e) {
      dSnackBar(context, "Failed to load dropdowns: ${e.toString()}",
          TypeSnackbar.error);
    }
  }

  // Loads the state/province list for the selected country.
  //
  // NOTE: this assumes CompanyCustomerRepositoryImpl.statelist() is updated
  // to accept a `country` argument (e.g. `Future<http.Response>
  // statelist(String country)`) and hits a per-country states endpoint.
  // Update the repository/API side to match this signature.
  Future<void> _fetchStatesForCountry(String country) async {
    setState(() {
      _stateItems = [];
      _selectedState = null;
    });

    try {
      final stateRes = await _customerRepo.getStatesByCountry(country);

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
      if (mounted) {
        dSnackBar(context, "Failed to load states: ${e.toString()}",
            TypeSnackbar.error);
      }
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
    // Keep the autoDispose provider alive while this page is open.
    // TabBarView only builds the Custom Fields tab when selected, so without
    // this watch the notifier is disposed mid-fetch.
    ref.watch(customerCustomFieldsProvider);

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
          DDropdown(
            label: "Status",
            items: const [
              DropdownMenuItem(value: 'Active', child: Text('Active')),
              DropdownMenuItem(value: 'InActive', child: Text('Inactive')),
            ],
            onChanged: (value) => _changeStatusValue(value),
            value: _status,
          ),
          // Country - selecting a different country reloads the states
          // dropdown below and updates the phone field's default dial code.
          DDropdown(
            label: "Country",
            items: _countryItems,
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedCountry = value);
              _fetchStatesForCountry(value);
            },
            value: _selectedCountry,
          ),
          PhoneNumberField(
            // Rebuild when the address country changes so the dial code
            // picker defaults to match (user can still override it).
            key: ValueKey(_selectedCountry),
            initialCountryCode: isoCodeForCountry(_selectedCountry),
            enableCountryPicker: false,
            onChanged: (number, valid) {
              _phoneNumber = number;
              _phoneValid = valid;
            },
          ),
          buildCustomTextField("Email", TextInputType.emailAddress,
              _emailField, false),
          buildCustomTextField(
              "Address", TextInputType.text, _addressField, false),
          buildCustomTextField("City", TextInputType.text, _cityField, false),
          DDropdown(
            label: "State",
            items: _stateItems,
            onChanged: (value) => setState(() => _selectedState = value),
            value: _selectedState,
          ),
          buildCustomTextField(
              "Zip Code", TextInputType.number, _zipCodeField, false),
        ],
      ),
    );
  }

  Widget _buildCustomFieldsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(dPadding * 2),
      child: Consumer(builder: (context, ref, _) {
        // Only render fields explicitly marked as show.
        final customFields = ref
            .watch(customerCustomFieldsProvider)
            .where((f) => f.show)
            .toList();

        // Drop controllers for fields that are no longer visible.
        final visibleIds = customFields.map((f) => f.id).toSet();
        _customFieldControllers.removeWhere((id, controller) {
          if (visibleIds.contains(id)) return false;
          controller.dispose();
          return true;
        });

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
    String email = _emailField.text.trim();

    if (_nameField.text.isEmpty) {
      setState(() {
        loadingCustomerInsertion = false;
      });
      dSnackBar(context, "Customer name is required", TypeSnackbar.error);
      return;
    }

    if (_phoneNumber.isNotEmpty && !_phoneValid) {
      setState(() {
        loadingCustomerInsertion = false;
      });
      dSnackBar(
        context,
        "Enter a valid phone number or leave it blank",
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

    final customFields = ref
        .read(customerCustomFieldsProvider)
        .where((f) => f.show)
        .toList();
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

    final customFieldValues = {
      for (var field in customFields)
        field.name: _customFieldControllers[field.id]?.text ?? '',
    };

    final Map<String, dynamic> customerData = {
      'name': _nameField.text,
      'companyId': companyId,
      'category': _category,
      'status': _status,
      'phone': _phoneNumber,
      'email': _emailField.text,
      'address': _addressField.text,
      'apartment': null,
      'city': _cityField.text,
      'state': _selectedState,
      'country': _selectedCountry,
      'zipCode': _zipCodeField.text,
      'Customer Location': _locationField.text,

      // Top-level custom keys + nested extraFields (same pattern as assets).
      ...customFieldValues,
      'extraFields': customFieldValues,
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
        dSnackBar(
          context,
          _customerApiErrorMessage(response, "Failed to add customer"),
          TypeSnackbar.error,
        );
      }
    } catch (e) {
      dSnackBar(context, "Error: ${e.toString()}", TypeSnackbar.error);
    }

    setState(() {
      loadingCustomerInsertion = false;
    });
  }

  /// Handles UNIQUE_FIELD_VIOLATION (and generic message) when backend adds it.
  String _customerApiErrorMessage(http.Response response, String fallback) {
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

  void clearFields() {
    setState(() {
      _nameField.clear();
      _category = null;
      _status = null;
      _phoneNumber = '';
      _phoneValid = true;
      _emailField.clear();
      _addressField.clear();
      _cityField.clear();
      _stateField.clear();
      _zipCodeField.clear();
      _locationField.clear();
      _selectedCountry = kDefaultCountryName;
    });
    _fetchStatesForCountry(kDefaultCountryName);

    // ✅ Clear custom fields
    for (var c in _customFieldControllers.values) {
      c.clear();
    }
  }
}
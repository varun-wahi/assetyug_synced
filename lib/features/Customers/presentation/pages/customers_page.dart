import 'dart:async';
import 'dart:convert';

import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/features/Customers/data/data_sources/customer_category_data.dart';
import 'package:asset_yug_debugging/features/Customers/data/models/customers_model.dart';
import 'package:asset_yug_debugging/features/Customers/data/repository/company_customer_repository_impl.dart';
import 'package:asset_yug_debugging/features/Customers/presentation/pages/View%20Customer%20Tabs/add_customer_page.dart';
import 'package:asset_yug_debugging/features/Customers/presentation/pages/view_customer_page.dart';
import 'package:asset_yug_debugging/features/Customers/presentation/riverpod/customer_sorting_notifier.dart';
import 'package:asset_yug_debugging/features/Main/presentation/riverpod/refresh_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../config/theme/container_styles.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../core/utils/constants/pageFilters.dart';
import '../../../../core/utils/constants/sizes.dart';
import '../../../../core/utils/widgets/d_dropdown.dart';
import '../../../../core/utils/widgets/d_gap.dart';
import '../../../../core/utils/widgets/d_searchbar.dart';
import '../../../../core/utils/widgets/d_selected_filter.dart';
import '../../../../core/utils/widgets/d_text_field.dart';
import '../../../../core/utils/widgets/my_elevated_button.dart';
import '../../../../core/utils/widgets/no_data_found.dart';
import '../../data/data_sources/customer_status_data.dart';
import '../../domain/usecases/customer_show_filters_modal_sheet.dart';
import '../riverpod/customer_filter_notifier.dart';

class CustomersPage extends ConsumerWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildAppBar(context, ref),
      resizeToAvoidBottomInset: false,
      backgroundColor: tBackground,
      body: const Padding(
        padding: EdgeInsets.all(dPadding),
        child: CustomersSearchAndList(),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text("Customers"),
      actions: [
        IconButton(
          onPressed: () => {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AddCustomerPage(fromCustomersPage: true,),
              ),
            )
          },
          icon: const Icon(Icons.person_add),
        ),
      ],
    );
  }
}

class CustomersSearchAndList extends ConsumerStatefulWidget {
  const CustomersSearchAndList({super.key});

  @override
  _CustomersSearchAndListState createState() => _CustomersSearchAndListState();
}

class _CustomersSearchAndListState
    extends ConsumerState<CustomersSearchAndList> {
  final searchTextFieldController = TextEditingController();
  List<dynamic> customers = [];
  bool isLoading = true;
  bool isDeleting = false;
  bool hasMore = true;
  int currentPage = 0;
  static const int pageSize = 10;
  String sortingCategory = '';
  final ScrollController _scrollController = ScrollController();
  String? companyId;
  Timer? _debounce;

  final customerNameController = TextEditingController();
  final addressController = TextEditingController();
  final customerController = TextEditingController();
  final phoneNumberController = TextEditingController();

  String? _customerStatus;
  String? _customerCategory;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    fetchCompanyId();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    searchTextFieldController.dispose();
    _debounce?.cancel();
    customerNameController.dispose();
    customerController.dispose();
    addressController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> fetchCompanyId() async {
    final box = await Hive.openBox('auth_data');
    companyId = box.get('companyId');
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    ref.watch(refreshProvider);
    setState(() {
      isLoading = true;
      currentPage = 0;
      customers.clear();
    });
    await _fetchCustomersPage();
  }

  Future<void> _fetchMoreCustomers() async {
    if (!hasMore || isLoading) return;
    setState(() {
      isLoading = true;
    });
    currentPage++;
    await _fetchCustomersPage();
  }

  Future<void> _fetchCustomersPage() async {
    try {
      final customersRepo = CompanyCustomerRepositoryImpl();
      final searchTerm = searchTextFieldController.text;

      if (companyId == null) {
        throw Exception("Company ID not found");
      }

      final filterForm = {
        "name": customerNameController.text,
        "companyId": companyId,
        "category": _customerCategory ?? "",
        "status": _customerStatus ?? "",
        "phone": phoneNumberController.text,
        "email": "",
        "address": addressController.text,
        "apartment": "",
        "city": "",
        "state": "",
        "zipCode": ""
      };
      print("Advanced filters being updated");

      final response = await customersRepo.advanceFilter(
        filterForm,
        currentPage,
        pageSize,
        sortingCategory,
        searchTerm,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> customerList = responseData['data'];

        setState(() {
          // customers.addAll(customerList); // Append the new list
          customers.addAll(customerList
              .map((e) => json.decode(e))
              .toList()); // Append the new list
          isLoading = false;
          hasMore = customers.length < responseData['totalRecords'];
        });
      } else {
        throw Exception("Failed to load customers");
      }
    } catch (e) {
      if (mounted) {
        dSnackBar(context, e.toString(), TypeSnackbar.error);
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        hasMore) {
      _fetchMoreCustomers();
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(refreshProvider.notifier).state = !ref.read(refreshProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(refreshProvider);

    final sortingCategory = ref.watch(customerSortingProvider);

    if (sortingCategory != this.sortingCategory) {
      this.sortingCategory = sortingCategory;
      _fetchCustomers();
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          _buildSearchBar(),
          Container(
            padding: const EdgeInsets.all(dPadding),
            height: 70,
            child: _buildFiltersSection(),
          ),
          Expanded(
            child: _buildCustomersList(),
          ),
        ],
      );
    });
  }

  Widget _buildSearchBar() {
    return DSearchBar(
      hintText: "Search all customers",
      controller: searchTextFieldController,
      onChanged: _onSearchChanged,
    );
  }

  Widget _buildFiltersSection() {
    final selectedFilters =
        ref.watch(customerFiltersProvider.notifier).selectedFilters;
    return SizedBox(
      height: 70,
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: _buildSelectedFilters(selectedFilters),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {
                ref.read(refreshProvider.notifier).state =
                    !ref.read(refreshProvider);
                _fetchCustomers();
              },
              icon: const Icon(Icons.refresh, color: darkGrey),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () => _buildAdvancedFilters(),
              icon: const Icon(Icons.filter_alt, color: darkGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFilters(Map<String, dynamic> selectedFilters) {
    return ListView.separated(
      padding: const EdgeInsets.all(dPadding),
      scrollDirection: Axis.horizontal,
      itemCount: assetsFilters.length,
      separatorBuilder: (context, index) => const SizedBox(width: dPadding),
      itemBuilder: (context, index) {
        String filterKey = assetsFilters.keys.elementAt(index);
        return DSelectedFilterItem(
          selectedOption: selectedFilters[filterKey] ?? '',
          isDropdown: true,
          title: filterKey,
          onPressed: () {
            print("Building selected filter");

            CustomerShowFiltersModalSheet.showFilterOptions(
              context,
              filterKey,
              selectedFilters[filterKey],
              customerFilters,
              ref,
            );
          },
        );
      },
    );
  }

  void _buildAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return _buildFilterModalContent();
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
    );
  }

  Widget _buildFilterModalContent() {
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildFilterModalHeader(),
            _buildFilterModalBody(),
            _buildFilterModalFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterModalHeader() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Select Filters', style: boldHeading()),
          TextButton(
            onPressed: () => _clearFilters(),
            child: Text("CLEAR", style: boldHeading(size: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterModalBody() {
    print("Customer Category Items: $customerCategoryTypeMenuItems");
    print("Selected Customer Category: $_customerCategory");
    print("Customer Status Items: $customerStatusMenuItems");
    print("Selected Customer Status: $_customerStatus");

    return SizedBox(
      height: 350,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                DTextField(
                    icon: const Icon(Icons.tag),
                    hintText: "Name",
                    controller: customerNameController),
                DTextField(
                    icon: const Icon(Icons.person),
                    hintText: "Address",
                    controller: addressController),
                DTextField(
                    icon: const Icon(Icons.confirmation_number),
                    hintText: "Phone Number",
                    controller: phoneNumberController),
                DDropdown(
                  padding: const EdgeInsets.symmetric(horizontal: dPadding),
                  label: "Category",
                  items: customerCategoryTypeMenuItems,
                  onChanged: (value) => setState(() {
                    _customerCategory = value;
                  }),
                  value:
                      _customerCategory, // Ensure value is either null or one of the valid items
                ),
                const DGap(),
                DDropdown(
                  padding: const EdgeInsets.symmetric(horizontal: dPadding),
                  label: "Status",
                  items: customerStatusMenuItems,
                  onChanged: (value) => setState(() {
                    _customerStatus = value;
                  }),
                  value:
                      _customerStatus, // Ensure value is either null or one of the valid items
                ),
              ],
            ),
            const DGap(),
            _buildAdditionalFilters(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalFilters() {
    return Container(
      decoration: dBoxDecoration(color: tBackground),
      child: Text("Extra fields to be added soon", style: subtitle()),
    );
  }

  Widget _buildFilterModalFooter() {
    return SizedBox(
      height: 40,
      child: DElevatedButton(
        buttonColor: tBlack,
        textColor: tWhite,
        child: const Text('Apply Filters'),
        onPressed: () => setState(() {
          _fetchCustomers();
          ref.read(refreshProvider.notifier).state =
              !ref.read(refreshProvider); // Trigger refresh
          Navigator.pop(context);
        }),
      ),
    );
  }

  void _clearFilters() {
    ref.read(customerFiltersProvider.notifier).clearFilters();

    _customerCategory = null;
    _customerStatus = null;

    customerNameController.clear();
    addressController.clear();
    phoneNumberController.clear();

    setState(() {});

    searchTextFieldController.clear();
    _fetchCustomers();
    Navigator.pop(context);
  }

  Widget _buildCustomersList() {
    ref.watch(refreshProvider);

    if (customers.isEmpty && !isLoading) {
      return const NoDataFoundPage();
    }

    return ListView.separated(
      controller: _scrollController,
      itemCount: customers.length +
          (hasMore ? 1 : 0), // Add 1 item for the loading indicator
      separatorBuilder: (context, index) => const SizedBox(height: dGap),
      itemBuilder: (context, index) {
        if (index < customers.length) {
          var customerData = CustomersModel.fromJson(customers[index]);
          return buildCustomerDetailsCard(customerData);
        } else if (hasMore) {
          return const Center(
              child:
                  CircularProgressIndicator()); // Loading indicator when fetching more customers
        } else {
          return const SizedBox.shrink(); // No more data to load
        }
      },
    );
  }

  Widget buildCustomerDetailsCard(CustomersModel data) {
    return GestureDetector(
      onTap: () async {
        final customerRepo = CompanyCustomerRepositoryImpl();
        final response = await customerRepo.getCompanyCustomerDetails(data.id!);
        print("CUSTOMER DETAILS: ${response.body}");

        final customerDetails =
            CustomersModel.fromJson(jsonDecode(response.body));
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              ViewCustomerPage(customerObjectId: data.id.toString()),
        ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: dPadding),
        decoration: BoxDecoration(
          color: tWhite,
          borderRadius: BorderRadius.circular(dBorderRadius),
          border: Border.all(color: tGreyLight),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: tPrimary, // Set the background color of the circle
            child: Text(
              data.name![0]
                  .toUpperCase(), // Get the first letter and make it uppercase
              style: boldHeading(
                  size: 17, color: tWhite), // Style the initial letter
            ),
          ),
          title: Text(data.name!, style: boldHeading(size: 16)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Email: ${data.email}",
                  style: containerText(weight: FontWeight.w400)),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'delete') {
                // Handle delete action here
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Delete Customer'),
                      content: const Text(
                          'Are you sure you want to delete this customer?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // Perform the delete action here
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: const Text('Cancel'),
                        ),
                        DElevatedButton(
                          onPressed: () async {
                            setState(() {
                            isDeleting = true;
                            });
                            final response =
                                await CompanyCustomerRepositoryImpl()
                                    .deleteCompanyCustomer(data.id!);
                            if (response.statusCode == 200) {
                              dSnackBar(context, "Customer deleted successlly",
                                  TypeSnackbar.info);
                            } else {
                              dSnackBar(
                                  context,
                                  "Some error occured while deleting customer",
                                  TypeSnackbar.error);
                            }
                            ref.read(refreshProvider.notifier).state =
                                !ref.read(refreshProvider);

                            setState(() async {
                              _fetchCustomers();
                              customers.remove(data);
                              isDeleting = false;
                              Navigator.of(context).pop(); // Close the dialog
                            });


                          },
                          child: !isDeleting? const Text('Delete'): const SizedBox.square(dimension: 20.0,child: CircularProgressIndicator(),),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ),
      ),
    );
  }
}

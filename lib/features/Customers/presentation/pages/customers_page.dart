import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../config/theme/snackbar__types_enum.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../core/utils/constants/pageFilters.dart';
import '../../../../core/utils/constants/sizes.dart';
import '../../../../core/utils/widgets/d_searchbar.dart';
import '../../../../core/utils/widgets/d_selected_filter.dart';
import '../../../../core/utils/widgets/d_snackbar.dart';
import '../../../../core/utils/widgets/no_data_found.dart';
import '../../../Main/presentation/riverpod/refresh_provider.dart';
import '../../data/models/customers_model.dart';
import '../../domain/repository/customer_service.dart';
import '../../domain/usecases/customer_show_filters_modal_sheet.dart';
import '../pages/View%20Customer%20Tabs/add_customer_page.dart';
import '../riverpod/customer_filter_notifier.dart';
import '../riverpod/customer_sorting_notifier.dart';
import '../widgets/customer_details_card.dart';
import '../widgets/customer_filter_form.dart';

class CustomersPage extends ConsumerWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customers")),
      resizeToAvoidBottomInset: false,
      backgroundColor: tBackground,
      body: const Padding(
        padding: EdgeInsets.all(dPadding),
        child: CustomersView(),
      ),
    );
  }
}

class CustomersView extends ConsumerStatefulWidget {
  const CustomersView({super.key});

  @override
  ConsumerState<CustomersView> createState() => _CustomersViewState();
}

class _CustomersViewState extends ConsumerState<CustomersView> {
  // Services and Controllers
  final _customerService = CustomerService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  
  // State Management
  final _customerState = CustomerState();
  Timer? _debounce;
  
  // Filter Data
  CustomerFilterData _filterData = const CustomerFilterData(status: "Active");

  @override
  void initState() {
    super.initState();
    _initializeView();
  }

  @override
  void dispose() {
    _disposeResources();
    super.dispose();
  }

  void _initializeView() {
    _scrollController.addListener(_onScroll);
    _loadCustomers();
  }

  void _disposeResources() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
  }

void _onScroll() {
  if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 && // <= give 100px buffer
      !_customerState.isLoading &&
      _customerState.hasMore) {
    _loadMoreCustomers();
  }
}


Future<void> _loadCustomers() async {
  _customerState.reset();
  await _fetchCustomersData();
  if (mounted) setState(() {});  // Only update UI once done
}

Future<void> _loadMoreCustomers() async {
  if (!_customerState.hasMore || _customerState.isLoading) return;

  _customerState.incrementPage();
  await _fetchCustomersData();
  if (mounted) setState(() {});  // Only update UI once done
}


  Future<void> _fetchCustomersData() async {
  _customerState.setLoading(true);

  try {
    final companyId = await _customerService.getCompanyId();
    if (companyId == null) throw Exception("Company ID not found");

    final response = await _customerService.fetchCustomers(
      companyId: companyId,
      filterForm: _filterData.toFilterForm(companyId),
      page: _customerState.currentPage,
      pageSize: CustomerService.defaultPageSize,
      sortingCategory: ref.read(customerSortingProvider),
      searchTerm: _searchController.text,
    );

    if (response.isSuccess) {
      _customerState.addCustomers(response.customers!, response.totalRecords!);
    } else {
      _showError(response.error!);
    }
  } catch (e) {
    _showError(e.toString());
  }

  _customerState.setLoading(false);
}


  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(refreshProvider.notifier).state = !ref.read(refreshProvider);
    });
  }

  void _showError(String message) {
    if (mounted) {
      dSnackBar(context, message, TypeSnackbar.error);
    }
  }

  void _onCustomerDeleted() {
    _loadCustomers();
  }

  void _onFiltersApplied(CustomerFilterData filterData) {
    setState(() => _filterData = filterData);
    _loadCustomers();
    ref.read(refreshProvider.notifier).state = !ref.read(refreshProvider);
    Navigator.pop(context);
  }

  void _onFiltersClear() {
    ref.read(customerFiltersProvider.notifier).clearFilters();
    setState(() => _filterData = const CustomerFilterData(status: "Active"));
    _searchController.clear();
    _loadCustomers();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _watchForChanges();

    return Scaffold(
      floatingActionButton: _buildFloatingActionButton(),
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildSearchSection(),
          _buildFiltersSection(),
          Expanded(child: _buildCustomersList()),
        ],
      ),
    );
  }

  void _watchForChanges() {
    ref.watch(refreshProvider);
    final newSortingCategory = ref.watch(customerSortingProvider);
    
    if (newSortingCategory != ref.read(customerSortingProvider)) {
      _loadCustomers();
    }
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: tPrimary,
      onPressed: () async {
        final shouldRefresh = await Navigator.push<bool?>(
          context,
          MaterialPageRoute(
            builder: (context) => const AddCustomerPage(fromCustomersPage: true),
          ),
        );
        if (mounted && shouldRefresh == true) {
          _loadCustomers();
        }
      },
      child: const Icon(Icons.person_add),
    );
  }

  Widget _buildSearchSection() {
    return DSearchBar(
      hintText: "Search all customers",
      controller: _searchController,
      onChanged: _onSearchChanged,
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(dPadding),
      height: 70,
      child: Row(
        children: [
          Expanded(flex: 4, child: _buildSelectedFilters()),
          Expanded(child: _buildRefreshButton()),
          Expanded(child: _buildFilterButton()),
        ],
      ),
    );
  }

  Widget _buildSelectedFilters() {
    final selectedFilters = ref.watch(customerFiltersProvider.notifier).selectedFilters;
    
    return ListView.separated(
      padding: const EdgeInsets.all(dPadding),
      scrollDirection: Axis.horizontal,
      itemCount: customerFilters.length,
      separatorBuilder: (context, index) => const SizedBox(width: dPadding),
      itemBuilder: (context, index) {
        final filterKey = customerFilters.keys.elementAt(index);
        return DSelectedFilterItem(
          selectedOption: selectedFilters[filterKey] ?? '',
          isDropdown: true,
          title: filterKey,
          onPressed: () => _showQuickFilter(filterKey, selectedFilters),
        );
      },
    );
  }

  Widget _buildRefreshButton() {
    return IconButton(
      onPressed: () {
        ref.read(refreshProvider.notifier).state = !ref.read(refreshProvider);
        _loadCustomers();
      },
      icon: const Icon(Icons.refresh, color: darkGrey),
    );
  }

  Widget _buildFilterButton() {
    return IconButton(
      onPressed: _showAdvancedFilters,
      icon: const Icon(Icons.filter_alt, color: darkGrey),
    );
  }

  void _showQuickFilter(String filterKey, Map<String, dynamic> selectedFilters) {
    CustomerShowFiltersModalSheet.showFilterOptions(
      context,
      filterKey,
      selectedFilters[filterKey],
      customerFilters,
      ref,
    );
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
            showDragHandle: true,
      isScrollControlled: true,
      context: context,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.55,
        child: CustomerFilterForm(
          initialData: _filterData,
          onApplyFilters: _onFiltersApplied,
          onClearFilters: _onFiltersClear,
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
    );
  }

Widget _buildCustomersList() {
  // 1) No items at all?
  if (_customerState.customers.isEmpty) {
    // • still loading? → show a centered spinner
    if (_customerState.isLoading) {
       return SingleChildScrollView(
         child: Column(
                children: List.generate(
                6,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(dBorderRadius),
                    ),
                  ),
                  ),
                ),
                ),
              ),
       );
    }
    // • done loading (but zero results)? → show “no data”
    return const NoDataFoundPage();
  }

  // 2) We have at least one item: now we _can_ show a loader at the bottom if hasMore
  return ListView.separated(
    controller: _scrollController,
    itemCount: _customerState.customers.length + (_customerState.hasMore ? 1 : 0),
    separatorBuilder: (_, __) => const SizedBox(height: dGap),
    itemBuilder: (context, index) {
      if (index < _customerState.customers.length) {
        // safe to index into your list
        final raw = _customerState.customers[index];
        final customerData = CustomersModel.fromJson(raw);
        return CustomerDetailsCard(
          data: customerData,
          onCustomerDeleted: _onCustomerDeleted,
        );
      }

      // index == customers.length && hasMore == true → loader cell
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    },
  );
}
}


// State management class for customers
class CustomerState {
  List<dynamic> _customers = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 0;

  List<dynamic> get customers => _customers;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  void reset() {
    _customers.clear();
    _currentPage = 0;
    _hasMore = true;
    _isLoading = true;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
  }

  void incrementPage() {
    _currentPage++;
    _isLoading = true;
  }



void addCustomers(List<dynamic> newCustomers, int totalRecords) {
  if (newCustomers.isEmpty) {
    _hasMore = false;
  } else {
    _customers.addAll(newCustomers);
    _hasMore = _customers.length < totalRecords;
  }
  _isLoading = false;
}


}
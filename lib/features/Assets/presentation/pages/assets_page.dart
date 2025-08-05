import 'dart:async';
import 'dart:convert';
import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Assets/domain/usecases/assets_show_filters_modal_sheet.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/add_asset_page.dart';
import 'package:asset_yug_debugging/features/Customers/presentation/pages/View%20Customer%20Tabs/customer_files_tab.dart';
import 'package:asset_yug_debugging/features/Home/presentation/pages/scan_qr_page.dart';
import 'package:asset_yug_debugging/core/utils/constants/pageFilters.dart';
import 'package:asset_yug_debugging/config/theme/container_styles.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_model.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_searchbar.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_selected_filter.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_text_field.dart';
import 'package:asset_yug_debugging/features/Main/presentation/riverpod/refresh_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/widgets/async_dropdown_search_widget.dart';
import '../../../../core/utils/widgets/d_dropdown.dart';
import '../../../Customers/data/data_sources/customer_names_data.dart';
import '../../../Customers/data/repository/company_customer_repository_impl.dart';
import '../../data/data_sources/asset_category_data.dart';
import '../../data/data_sources/asset_status_data.dart';
import '../riverpod/asset_filter_notifier.dart';
import '../../../../core/utils/widgets/my_elevated_button.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/view_asset_page.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/widgets/checking_btn_widget_assets.dart';
import '../riverpod/asset_sorting_notifier.dart';
import 'package:asset_yug_debugging/core/utils/widgets/icon_text_row.dart';

class AssetsPage extends ConsumerWidget {
  const AssetsPage({
    super.key,
    this.predefinedFilters,
  });

  final Map<String, dynamic>? predefinedFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Merge legacy serialNumber with new predefinedFilters
    final Map<String, dynamic> finalFilters = {
      ...?predefinedFilters,
    };

    print('Applied filters: $finalFilters');

    return Scaffold(
      appBar: _buildAppBar(context),
      resizeToAvoidBottomInset: false,
      backgroundColor: tBackground,
      body: Padding(
        padding: const EdgeInsets.all(dPadding),
        child: AssetsSearchAndList(
          predefinedFilters: finalFilters,
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text("Assets"),
      actions: [
        // IconButton(
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => const AddAssetPage(),
        //       ),
        //     );
        //   },
        //   icon: const Icon(Icons.add_circle_outline_rounded),
        // ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ScanCodePage(),
              ),
            );
          },
          icon: const Icon(Icons.qr_code_scanner_rounded),
        ),
      ],
    );
  }
}

class AssetsSearchAndList extends ConsumerStatefulWidget {
  const AssetsSearchAndList({
    super.key,
    this.predefinedFilters,
  });

  final Map<String, dynamic>? predefinedFilters;

  @override
  _AssetsSearchAndListState createState() => _AssetsSearchAndListState();
}

class _AssetsSearchAndListState extends ConsumerState<AssetsSearchAndList> {
  final searchTextFieldController = TextEditingController();
  List<dynamic> assets = [];
  bool isLoading = true;
  bool hasMore = true;
  int currentPage = 0;
  static const int pageSize = 10; // Increased page size for better performance
  String sortingCategory = '';
  final ScrollController _scrollController = ScrollController();
  String? companyId;
  Timer? _debounce;

  final assetIdController = TextEditingController();
  final assetNameController = TextEditingController();
  final customerController = TextEditingController();
  final serialNumberController = TextEditingController();
  final categoryController = TextEditingController();
  final locationController = TextEditingController();
  final statusController = TextEditingController();

  String? _assetStatus = 'Active';
  String? _assetCategory;
  String? _customer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    // Handle backward compatibility
    final newFilters = widget.predefinedFilters ?? {};

    // Merge legacy and new filters
    final finalFilters = {
      ...newFilters,
    };

    _initializeFiltersFromMap(finalFilters);
    fetchCompanyId();
  }

  void _initializeFiltersFromMap(Map<String, dynamic> filters) {
    assetIdController.text = filters['assetId']?.toString() ?? '';
    assetNameController.text = filters['name']?.toString() ?? '';
    customerController.text = filters['customer']?.toString() ?? '';
    serialNumberController.text = filters['serialNumber']?.toString() ?? '';
    categoryController.text = filters['category']?.toString() ?? '';
    locationController.text = filters['location']?.toString() ?? '';

    _assetStatus = filters['status']?.toString() ?? 'Active';
    _assetCategory = filters['category']?.toString();
    _customer = filters['customer']?.toString();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    searchTextFieldController.dispose();
    _debounce?.cancel();
    assetIdController.dispose();
    assetNameController.dispose();
    customerController.dispose();
    serialNumberController.dispose();
    categoryController.dispose();
    locationController.dispose();
    statusController.dispose();
    super.dispose();
  }

  Future<void> fetchCompanyId() async {
    final box = await Hive.openBox('auth_data');
    companyId = box.get('companyId');
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    setState(() {
      isLoading = true;
      currentPage = 0;
      assets.clear();
      hasMore = true;
    });
    await _fetchAssetsPage();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !isLoading &&
        hasMore) {
      print("Fetching more assets...");
      _fetchMoreAssets();
    }
  }

  Future<void> _fetchMoreAssets() async {
    if (!hasMore || isLoading) return;

    setState(() {
      isLoading = true;
    });

    await _fetchAssetsPage();
  }

  Future<void> _fetchAssetsPage() async {
    try {
      print("🔄 Fetching assets for page: $currentPage");

      final assetsRepo = AssetsRepositoryImpl();
      final searchTerm = searchTextFieldController.text;

      if (companyId == null) {
        throw Exception("❌ Company ID not found");
      }

      final Map<String, dynamic> filterForm = {
        'assetId': assetIdController.text,
        'name': assetNameController.text,
        'customer': customerController.text ?? '',
        'serialNumber': serialNumberController.text,
        'category': _assetCategory ?? '',
        'location': locationController.text,
        'status': _assetStatus ?? '',
        'email': '',
        'companyId': companyId.toString(),
      };

      print("📤 Sending filterForm: ${jsonEncode(filterForm)}");

      final response = await assetsRepo.advanceFilter(
        json.encode(filterForm),
        currentPage,
        pageSize,
        sortingCategory,
        searchTerm.isEmpty ? '' : searchTerm,
      );

      print("Filters form: ${jsonEncode(filterForm)}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is! Map<String, dynamic>) {
          throw Exception("Invalid response format: ${response.body}");
        }

        final data = decoded['data'];
        final totalRecords = decoded['totalRecords'] ?? 0;

        List<Map<String, dynamic>> newAssetsParsed = [];

        if (data is List) {
          print("📦 Data is a List with ${data.length} items");

          for (var item in data) {
            try {
              // Decode if item is a JSON string
              final parsedItem = item is String
                  ? json.decode(item) as Map<String, dynamic>
                  : item;

              if (parsedItem is Map<String, dynamic>) {
                newAssetsParsed.add(parsedItem);
              } else {
                print("⚠️ Skipped non-map parsed item: $parsedItem");
              }
            } catch (e) {
              print("❌ Failed to parse item: $e");
            }
          }
        } else {
          throw Exception("Unexpected 'data' format: ${data.runtimeType}");
        }

        final newAssets = newAssetsParsed.where((item) {
          final newId = item['id'];
          return !assets.any((existing) => existing['id'] == newId);
        }).toList();

        print("📥 New assets parsed: ${newAssets.length}");

        setState(() {
          assets.addAll(newAssets);
          isLoading = false;
          hasMore = assets.length < totalRecords;
          currentPage += 1;
        });
      } else {
        throw Exception(
            "Failed to load assets. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("❗ Error fetching assets: $e");
      if (mounted) {
        _showErrorSnackBar(e.toString());
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    dSnackBar(context, message, TypeSnackbar.error);
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchAssets();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(refreshProvider);
    final sortingCategory = ref.watch(assetSortingProvider);

    if (sortingCategory != this.sortingCategory) {
      this.sortingCategory = sortingCategory;
      _fetchAssets();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Column(
              children: [
                _buildSearchBar(),
                Container(
                  padding: const EdgeInsets.all(dPadding),
                  height: 70,
                  child: _buildFiltersSection(),
                ),
                Expanded(
                  child: _buildAssetsList(),
                ),
              ],
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddAssetPage(),
                    ),
                  );
                },
                backgroundColor: tPrimary,
                tooltip: 'Add Asset',
                child: const Icon(Icons.add, color: tWhite),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return DSearchBar(
      hintText: "Search all assets",
      controller: searchTextFieldController,
      onChanged: _onSearchChanged,
    );
  }

  Widget _buildFiltersSection() {
    final selectedFilters =
        ref.watch(assetFiltersProvider.notifier).selectedFilters;
    return SizedBox(
      height: 70,
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: _buildSelectedFilters(selectedFilters),
          ),
          Expanded(child: _buildRefreshButton()),
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
            AssetsShowFiltersModalSheet.showFilterOptions(
              context,
              filterKey,
              selectedFilters[filterKey],
              assetsFilters,
              ref,
            );
          },
        );
      },
    );
  }

  Widget _buildRefreshButton() {
    return IconButton(
      onPressed: () {
        ref.read(refreshProvider.notifier).state = !ref.read(refreshProvider);
        _fetchAssets();
      },
      icon: const Icon(Icons.refresh, color: darkGrey),
    );
  }

  void _buildAdvancedFilters() {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        final height = MediaQuery.of(context).size.height * 0.75;
        return SizedBox(
          height: height,
          child: _buildFilterModalContent(),
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
    );
  }

  Widget _buildFilterModalContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2 * dPadding),
      decoration: const BoxDecoration(
        color: tWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      // height: 500,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
      // height: 40,
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
    LocationBinOption? selectedLocationBin;

    return SizedBox(
      // height: 350,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                DTextField(
                  icon: const Icon(Icons.tag),
                  hintText: "Asset ID",
                  controller: assetIdController,
                ),
                DTextField(
                  icon: const Icon(Icons.person),
                  hintText: "Asset Name",
                  controller: assetNameController,
                ),

                /// AsyncDropdown for Customer
                AsyncDropdownField<Map<String, dynamic>>(
                  label: "Customer",
                  asyncItemsFetcher: () async {
                    final customerRepo = CompanyCustomerRepositoryImpl();
                    try {
                      final response = await customerRepo
                          .getCompanyCustomer(companyId ?? "");
                      if (response.statusCode == 200) {
                        final customers = jsonDecode(response.body) as List;
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
                  onChanged: (value) => setState(() {
                    _customer = value?['name'].toString();
                    customerController.text = _customer ?? ''; // Add this line
                  }),
                  selectedItem: _customer != null ? {'name': _customer} : null,
                ),

                DTextField(
                  icon: const Icon(Icons.confirmation_number),
                  hintText: "Serial Number",
                  controller: serialNumberController,
                ),

                /// AsyncDropdown for Category
                AsyncDropdownField<Map<String, dynamic>>(
                  label: "Category",
                  asyncItemsFetcher: () async {
                    final repo = AssetsRepositoryImpl();
                    try {
                      final response =
                          await repo.getActiveCategories(companyId ?? "");
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
                    categoryController.text =
                        _assetCategory ?? ''; // Add this line
                  }),
                  selectedItem:
                      _assetCategory != null ? {'name': _assetCategory} : null,
                ),

                /// AsyncDropdown for Location with Bins
                AsyncDropdownField<LocationBinOption>(
                  label: "Location",
                  asyncItemsFetcher: () async {
                    try {
                      final response = await CompanyCustomerRepositoryImpl()
                          .getCustomerLocationsAndBins(companyId ?? "");
                      final List<dynamic> data = jsonDecode(response.body);
                      final List<LocationBinOption> parsed = [];

                      for (var location in data) {
                        final locName = location['name'];
                        final locId = location['id'];
                        final bins = location['bins'] ?? [];

                        // Always add location itself
                        parsed.add(LocationBinOption(
                          locationId: locId,
                          binId: null,
                          label: locName,
                        ));

                        // Then add bins
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
                  onChanged: (value) => setState(() {
                    selectedLocationBin = value;
                    locationController.text =
                        value?.label ?? ''; // Add this line
                  }),
                  selectedItem: selectedLocationBin,
                ),

                /// Static Dropdown for Asset Status
                DDropdown(
                  padding: const EdgeInsets.symmetric(horizontal: dPadding),
                  label: "Status",
                  items: assetStatusMenuItems,
                  value: _assetStatus,
                  onChanged: (value) => setState(() {
                    _assetStatus = value;
                  }),
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
          _fetchAssets();
          Navigator.pop(context);
        }),
      ),
    );
  }

  void _clearFilters() {
    ref.read(assetFiltersProvider.notifier).clearFilters();

    assetIdController.clear();
    assetNameController.clear();
    _customer = null;
    customerController.clear();
    serialNumberController.clear();
    _assetCategory = null;
    locationController.clear();
    _assetStatus = null;

    setState(() {});

    searchTextFieldController.clear();
    _fetchAssets();
    Navigator.pop(context);
  }

  Widget _buildAssetsList() {
    ref.watch(refreshProvider);

    if (assets.isEmpty && !isLoading) {
      return const NoDataFoundPage();
    }

    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: assets.length + (hasMore ? 1 : 0),
      separatorBuilder: (context, index) => const DGap(gap: 8),
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        if (index < assets.length) {
          // var assetData = AssetsModel.fromJson(assets[index]);
          var assetData = AssetsModel.fromJson(assets[index]);

          return assetsDetailsCard(data: assetData, ref: ref);
        } else {
            // Show shimmer placeholders while loading more assets
            return Column(
              children: List.generate(
              4,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(dBorderRadius),
                  ),
                ),
                ),
              ),
              ),
            );
        }
      },
    );
  }

  Widget assetsDetailsCard(
      {required AssetsModel data, required WidgetRef ref}) {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ViewAssetPage(assetObjectId: data.id!),
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: tWhite,
          borderRadius: BorderRadius.circular(dBorderRadius),
          border: Border.all(width: D_BORDER_WIDTH, color: Colors.black26),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: dPadding * 2,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: dPadding * 2, right: 0),
          title: Text(
            data.name,
            style: boldHeading(size: 19),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DGap(gap: 2),
              Text(
                "Serial No: ${data.serialNumber}",
                style: containerText(weight: FontWeight.w400),
              ),
              const DGap(gap: 2),
              Text(
                "Category: ${data.category}",
                style: containerText(weight: FontWeight.w400),
              ),
              const DGap(gap: 8),
              IconTextRow(
                icon: Icons.person,
                text: data.customer ?? "No Customer",
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
          trailing: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              AssetStatusButton(data: data, ref: ref),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text(
                            'Are you sure you want to delete this asset?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pop(false), // Cancel
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pop(true), // Confirm
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true) {
                      final assetsRepo = AssetsRepositoryImpl();
                      await assetsRepo.removeAsset(data.id!);

                      // Local state update
                      setState(() {
                        assets.remove(data);
                      });

                      // Trigger refreshProvider
                      ref.read(refreshProvider.notifier).state =
                          !ref.read(refreshProvider);

                      // Refetch assets
                      await _fetchAssets();

                      print("Deleted asset: ${data.id.toString()}");
                    }
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ];
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

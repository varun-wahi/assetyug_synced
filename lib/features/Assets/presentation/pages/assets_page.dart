import 'dart:async';
import 'dart:convert';
import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Assets/domain/usecases/assets_show_filters_modal_sheet.dart';
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
import '../../../../core/utils/widgets/d_dropdown.dart';
import '../../../Customers/data/data_sources/customer_names_data.dart';
import '../../data/data_sources/asset_category_data.dart';
import '../../data/data_sources/asset_status_data.dart';
import '../riverpod/asset_filter_notifier.dart';
import '../../../../core/utils/widgets/my_elevated_button.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/view_asset_page.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/widgets/checking_btn_widget_assets.dart';
import '../riverpod/asset_sorting_notifier.dart';
import 'package:asset_yug_debugging/core/utils/widgets/icon_text_row.dart';

class AssetsPage extends ConsumerWidget {
  const AssetsPage({super.key, this.serialNumber});

  final String? serialNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('Searching asset with serial number: $serialNumber');

    return Scaffold(
      appBar: _buildAppBar(context),
      resizeToAvoidBottomInset: false,
      backgroundColor: tBackground,
      body: Padding(
        padding: const EdgeInsets.all(dPadding),
        child: AssetsSearchAndList(
          predefinedSerialNumber: serialNumber ?? "",
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text("Assets"),
      actions: [
        // IconButton(
        //   onPressed: () async {
        //     String? serialNumber = await SerialSearchDialog.show(context);
        //     if (serialNumber != null && serialNumber.isNotEmpty) {
        //       searchAsset(serialNumber);
        //     }
        //   },
        //   icon: const Icon(Icons.numbers),
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
  const AssetsSearchAndList({super.key, this.predefinedSerialNumber});
  final String? predefinedSerialNumber;

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

  String? _assetStatus;
  String? _assetCategory;
  String? _customer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    serialNumberController.text = widget.predefinedSerialNumber ?? '';
    fetchCompanyId();
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
    });
    await _fetchAssetsPage();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
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

    // Fetch next page of assets
    await _fetchAssetsPage();
  }

  Future<void> _fetchAssetsPage() async {
    try {
      print("Fetching assets for page: $currentPage");
      final assetsRepo = AssetsRepositoryImpl();
      final searchTerm = searchTextFieldController.text;

      if (companyId == null) {
        throw Exception("Company ID not found");
      }

      final Map<String, dynamic> filterForm = {
        'assetId': assetIdController.text,
        'name': assetNameController.text,
        'customer': _customer ?? '',
        'serialNumber': serialNumberController.text,
        'category': _assetCategory ?? '',
        'location': locationController.text,
        'status': _assetStatus ?? '',
        'email': '',
        'companyId': companyId!,
      };
// http://assetyug-lb-551711242.us-east-1.elb.amazonaws.com:8080/assets/advanceFilter/0/10?category=&search=&asc=true
// http://assetyug-lb-551711242.us-east-1.elb.amazonaws.com:8080/assets/advanceFilter/0/10?category=&search=&asc=true

      final response = await assetsRepo.advanceFilter(
        json.encode(filterForm),
        currentPage,
        pageSize,
        sortingCategory,
        searchTerm.isEmpty ? '' : searchTerm,
      );

      if (response.statusCode == 200) {
        print("Assets fetched successfully");
        final responseBody = json.decode(response.body);
        if (responseBody is Map<String, dynamic>) {
          final newAssets = responseBody['data'] as List<dynamic>;
          final totalRecords = responseBody['totalRecords'] as int;
          setState(() {
            assets.addAll(newAssets);
            isLoading = false;
            hasMore = assets.length <
                totalRecords; // Check if more assets are available
          });
        } else {
          throw Exception("Invalid response format: ${response.body}");
        }
      } else {
        throw Exception(
            "Failed to load assets. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching assets: $e");
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

    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          _buildSearchBar(),
          Container(
              padding: const EdgeInsets.all(dPadding),
              height: 70,
              child: _buildFiltersSection()),
          Expanded(
            child: _buildAssetsList(),
          ),
        ],
      );
    });
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

  void _buildAdvancedFilters() {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
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
      padding: const EdgeInsets.symmetric(horizontal: 2 * dPadding),
      decoration: const BoxDecoration(
        color: tWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      height: 500,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildFilterModalHeader(),
              _buildFilterModalBody(),
              _buildFilterModalFooter(),
            ],
          ),
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
    return SizedBox(
      height: 350,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                DTextField(
                    icon: const Icon(Icons.tag),
                    hintText: "Asset ID",
                    controller: assetIdController),
                DTextField(
                    icon: const Icon(Icons.person),
                    hintText: "Asset Name",
                    controller: assetNameController),
                DDropdown(
                  padding: const EdgeInsets.symmetric(horizontal: dPadding),
                  label: "Customer",
                  items: customerNamesMenuItems,
                  onChanged: (value) => setState(() {
                    _customer = value;
                  }),
                  value: _customer,
                ),
                DTextField(
                    icon: const Icon(Icons.confirmation_number),
                    hintText: "Serial Number",
                    controller: serialNumberController),
                DDropdown(
                  padding: const EdgeInsets.symmetric(horizontal: dPadding),
                  label: "Category",
                  items: assetCategoryTypeMenuItems,
                  onChanged: (value) => setState(() {
                    _assetCategory = value;
                  }),
                  value: _assetCategory,
                ),
                DTextField(
                    icon: const Icon(Icons.location_on),
                    hintText: "Location",
                    controller: locationController),
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
      itemCount: assets.length +
          (hasMore ? 1 : 0), // Add one more item if more assets are available
      separatorBuilder: (context, index) => const DGap(gap: 8),
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        if (index < assets.length) {
          var assetData =
              AssetsModel.fromJson(jsonDecode(assets.reversed.toList()[index]));
          return assetsDetailsCard(data: assetData, ref: ref);
        } else if (hasMore) {
          return const Center(
              child:
                  CircularProgressIndicator()); // Show loading indicator when fetching more assets
        } else {
          return const SizedBox.shrink(); // If no more data, show nothing
        }
      },
    );
  }

  Widget assetsDetailsCard(
      {required AssetsModel data, required WidgetRef ref}) {
    return GestureDetector(
      onTap: () async {
        final assetRepo = AssetsRepositoryImpl();
        final response = await assetRepo.getAssetDetails(data.id!);
        final assetDetails = AssetsModel.fromJson(jsonDecode(response.body));
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ViewAssetPage(assetObjectId: assetDetails.id!),
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

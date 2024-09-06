import 'dart:async';

import 'dart:convert';

import 'package:asset_yug_debugging/config/theme/box_shadow_styles.dart';
import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_divider.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/core/utils/widgets/loading_animated_container.dart';
import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Main/presentation/riverpod/refresh_provider.dart';
import 'package:asset_yug_debugging/features/Assets/domain/usecases/assets_show_filters_modal_sheet.dart';
import 'package:asset_yug_debugging/features/Home/presentation/pages/scan_qr_page.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/widgets/asset_card.dart';
import 'package:asset_yug_debugging/core/utils/constants/pageFilters.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/riverpod/asset_search_notifier.dart';
import 'package:asset_yug_debugging/config/theme/container_styles.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_model.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_searchbar.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_selected_filter.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../riverpod/asset_filter_notifier.dart';
import '../../../../core/utils/widgets/my_elevated_button.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/view_asset_page.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/widgets/checking_btn_widget_assets.dart';
import '../riverpod/asset_sorting_notifier.dart';
import 'package:asset_yug_debugging/core/utils/widgets/icon_text_row.dart';

class AssetsPage extends ConsumerWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(context),
        resizeToAvoidBottomInset: false,
        backgroundColor: tBackground,
        body: const Padding(
          padding: EdgeInsets.all(dPadding),
          child: AssetsSearchAndList(),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text("Assets"),
      actions: [
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
  const AssetsSearchAndList({super.key});

  @override
  _AssetsSearchAndListState createState() => _AssetsSearchAndListState();
}

class _AssetsSearchAndListState extends ConsumerState<AssetsSearchAndList> {
  final searchTextFieldController = TextEditingController();
  List<dynamic> assets = [];
  bool isLoading = true;
  bool hasMore = true;
  int currentPage = 0;
  static const int pageSize = 5;
  String sortingCategory = '';
  final ScrollController _scrollController = ScrollController();
  String? companyId;
  Timer? _debounce;

  // Add these controllers
  final assetIdController = TextEditingController();
  final assetNameController = TextEditingController();
  final customerController = TextEditingController();
  final serialNumberController = TextEditingController();
  final categoryController = TextEditingController();
  final locationController = TextEditingController();
  final statusController = TextEditingController();

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
    
    // Dispose the new controllers
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

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        hasMore &&
        !isLoading) {
      _fetchMoreAssets();
    }
  }

  Future<void> _fetchAssets() async {
    setState(() {
      isLoading = true;
      currentPage = 0;
      assets.clear();
    });
    await _fetchAssetsPage();
  }

  Future<void> _fetchMoreAssets() async {
    if (!hasMore || isLoading) return;
    setState(() {
      isLoading = true;
    });
    currentPage++;
    await _fetchAssetsPage();
  }

  Future<void> _fetchAssetsPage() async {
    try {
      final assetsRepo = AssetsRepositoryImpl();
      final searchTerm = searchTextFieldController.text;

      if (companyId == null) {
        throw Exception("Company ID not found");
      }
      final Map<String, dynamic> filterForm = {
        'assetId': assetIdController.text,
        'name': assetNameController.text,
        'customer': customerController.text,
        'serialNumber': serialNumberController.text,
        'category': categoryController.text,
        'location': locationController.text,
        'status': statusController.text,
        'email': '',
        'companyId': companyId!,
      };

      final response = await assetsRepo.advanceFilter(
        json.encode(filterForm),
        currentPage,
        pageSize,
        sortingCategory,
        searchTerm.isEmpty ? 'null' : searchTerm,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody is Map<String, dynamic>) {
          final newAssets = responseBody['data'] as List<dynamic>;
          final totalRecords = responseBody['totalRecords'] as int;
          
          setState(() {
            assets.addAll(newAssets);
            isLoading = false;
            hasMore = assets.length < totalRecords;
          });
        } else {
          throw Exception("Invalid response format: ${response.body}");
        }
      } else {
        throw Exception("Failed to load assets. Status code: ${response.statusCode}");
      }
    } catch (e) {
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
    // Watch both refreshProvider and assetSortingProvider
    ref.watch(refreshProvider);
    final sortingCategory = ref.watch(assetSortingProvider);

    // Update sortingCategory when it changes
    if (sortingCategory != this.sortingCategory) {
      this.sortingCategory = sortingCategory;
      _fetchAssets();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            _buildSearchBar(),
            Container(
              padding: const EdgeInsets.all(dPadding),
              height: 70, child: _buildFiltersSection()),
            Expanded(
              child: _buildAssetsList(),
            ),
          ],
        );
      }
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
    final selectedFilters = ref.watch(assetFiltersProvider.notifier).selectedFilters;
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


  //!TO FIX
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

//ADVANCE FILTERS
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
    return SizedBox(
      height: 350,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                DTextField(icon: const Icon(Icons.tag), hintText: "Asset ID", controller: assetIdController),
                DTextField(icon: const Icon(Icons.person), hintText: "Asset Name", controller: assetNameController),
                DTextField(icon: const Icon(Icons.business), hintText: "Customer", controller: customerController),
                DTextField(icon: const Icon(Icons.confirmation_number), hintText: "Serial Number", controller: serialNumberController),
                DTextField(icon: const Icon(Icons.category), hintText: "Category", controller: categoryController),
                DTextField(icon: const Icon(Icons.location_on), hintText: "Location", controller: locationController),
                DTextField(icon: const Icon(Icons.info), hintText: "Status", controller: statusController),
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
    //TODO: Show extra fields
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
    
    // Clear all text fields
    assetIdController.clear();
    assetNameController.clear();
    customerController.clear();
    serialNumberController.clear();
    categoryController.clear();
    locationController.clear();
    statusController.clear();
    
    // Optionally, you can also clear the search field
    searchTextFieldController.clear();

    // Refresh the asset list with cleared filters
    _fetchAssets();

    Navigator.pop(context);
  }


//*         ASSETS LIST         *//
//
//
  Widget _buildAssetsList() {
    // Add this line to watch the refreshProvider
    ref.watch(refreshProvider);
    
    if (assets.isEmpty && !isLoading) {
      return const NoDataFoundPage();
    }

    return Container(
      // padding: const EdgeInsets.all(dPadding),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(dBorderRadius),
        // boxShadow: dBoxShadow(),
        border: Border.all(color: tGreyLight),
      ),
      child: (isLoading) ?  const SingleChildScrollView(
        child: Column(
          children: [
            LoadingAnimatedContainer(height: 130,width: double.infinity),
            DGap(gap: 10),
            LoadingAnimatedContainer(height: 130,width: double.infinity),
            DGap(gap: 10),
            LoadingAnimatedContainer(height: 130,width: double.infinity),

            DGap(gap: 10),
            LoadingAnimatedContainer(height: 130,width: double.infinity),

            DGap(gap: 10),
            LoadingAnimatedContainer(height: 130,width: double.infinity),
            
          ],
        ),
      ) : ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        itemCount: assets.length + (hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const DGap(gap:8),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          if (index < assets.length) {
            var assetData = AssetsModel.fromJson(jsonDecode(assets.reversed.toList()[index]));
            return AssetsDetailsCard(data: assetData, ref: ref);
          } else if (hasMore) {
            return const Expanded(child: Center(child: CircularProgressIndicator()));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget AssetsDetailsCard({required AssetsModel data, required WidgetRef ref}) {
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
          contentPadding: const EdgeInsets.only(left: dPadding*2, right: 0),
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
              
              const DGap(gap:8),
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
                    final assetsRepo = AssetsRepositoryImpl();
                    await assetsRepo.removeAsset(data.id!);
                    setState(() {
                      assets.remove(data);
                    });
                    print("deleted asset: ${data.id.toString()}");
                    // Trigger the refresh
                    ref.read(refreshProvider.notifier).state = !ref.read(refreshProvider);
                    // Add this line to fetch assets after deletion
                    await _fetchAssets();
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

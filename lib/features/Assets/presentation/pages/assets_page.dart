import 'dart:async';
import 'dart:convert';
import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Assets/domain/usecases/assets_show_filters_modal_sheet.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/add_asset_page.dart';
import 'package:asset_yug_debugging/features/Home/presentation/pages/scan_qr_page.dart';
import 'package:asset_yug_debugging/core/utils/constants/pageFilters.dart';
import 'package:asset_yug_debugging/core/utils/constants/strings.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_model.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_searchbar.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_selected_filter.dart';
import 'package:asset_yug_debugging/features/Main/presentation/riverpod/refresh_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../riverpod/asset_custom_fields_provider.dart';
import '../riverpod/asset_filter_notifier.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/view_asset_page.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/widgets/checking_btn_widget_assets.dart';
import '../riverpod/asset_sorting_notifier.dart';
import 'package:asset_yug_debugging/core/utils/widgets/icon_text_row.dart';

import '../widgets/assets_filter_form.dart';

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

  // Track check-in status for each asset since it's fetched asynchronously
  final Map<String, String> _assetCheckingStatusMap = {};
  bool isCheckingStatusLoading = false;

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

  // Controllers for dynamic custom fields
  final Map<String, TextEditingController> _customFieldControllers = {};

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

    final checkingStatus = filters['Checking Status']?.toString();
    if (checkingStatus != null && checkingStatus.isNotEmpty) {
      Future.microtask(() {
        if (mounted) {
          ref.read(assetFiltersProvider.notifier).updateFilter(
            {checkingStatus: checkingStatus},
            "Checking Status",
          );
        }
      });
    }
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

    // ✅ Now companyId is guaranteed to be set
    if (companyId != null && mounted) {
      ref
          .read(assetCustomFieldsProvider.notifier)
          .loadCustomFields(companyId.toString());
    }

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

      // Build base filter form
      final Map<String, dynamic> filterForm = {
        'assetId': assetIdController.text,
        'name': assetNameController.text,
        'customer': customerController.text,
        'serialNumber': serialNumberController.text,
        'category': _assetCategory ?? '',
        'location': locationController.text,
        'status': _assetStatus ?? '',
        'email': '',
        'companyId': companyId.toString(),
      };

      // Append dynamic custom fields
      final customFields = ref.read(assetCustomFieldsProvider);
      for (var field in customFields) {
        final controller = _customFieldControllers[field.id];
        filterForm[field.name] = controller?.text ?? '';
      }

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

        // Load check-in/out statuses for newly fetched assets (batch)
        _loadStatusesForAssets(newAssets);
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

  Future<void> _loadStatusesForAssets(List<dynamic> assetsPage) async {
    if (assetsPage.isEmpty) return;

    final ids = assetsPage
        .map((e) => e['id']?.toString())
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    if (ids.isEmpty) return;

    setState(() => isCheckingStatusLoading = true);

    final repo = AssetsRepositoryImpl();
    final futures = ids.map((id) async {
      try {
        final resp = await repo.getCheckInOutList(id);
        if (resp.statusCode == 200 || resp.statusCode == 202) {
          final List<dynamic> list = json.decode(resp.body);
          if (list.isNotEmpty) {
            // Pick the most recent entry by parsing dates, fallback to last
            DateTime? latestDate;
            dynamic latestEntry;
            for (var entry in list) {
              final dateStr = entry['date']?.toString();
              DateTime? dt;
              try {
                dt = dateStr != null ? DateTime.parse(dateStr) : null;
              } catch (_) {
                dt = null;
              }
              if (dt != null) {
                if (latestDate == null || dt.isAfter(latestDate)) {
                  latestDate = dt;
                  latestEntry = entry;
                }
              }
            }
            final chosen = latestEntry ?? list.last;
            final status = chosen['status'] ?? checkInString;
            return MapEntry(id, status.toString());
          }
        }
      } catch (e) {
        print('Error loading status for $id: $e');
      }
      return MapEntry(id, checkInString);
    }).toList();

    try {
      final results = await Future.wait(futures);
      if (mounted) {
        setState(() {
          _assetCheckingStatusMap.addEntries(results);
        });
      }
    } catch (e) {
      print('Error during batch status load: $e');
    } finally {
      if (mounted) setState(() => isCheckingStatusLoading = false);
    }
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
                onPressed: () async {
                  final shouldRefresh = await Navigator.push<bool?>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddAssetPage(),
                    ),
                  );
                  if (mounted && shouldRefresh == true) {
                    _fetchAssets();
                  }
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _buildAdvancedFilters(),
                  icon: const Icon(Icons.filter_alt, color: darkGrey),
                ),
                if (isCheckingStatusLoading)
                  SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
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
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: AssetFilterForm(
            initialData: AssetFilterData(
              companyId: companyId ?? '',
              assetId: assetIdController.text,
              name: assetNameController.text,
              customer: customerController.text,
              serialNumber: serialNumberController.text,
              category: _assetCategory ?? '',
              location: locationController.text,
              status: _assetStatus ?? '',
              checkingStatus: ref
                      .read(assetFiltersProvider.notifier)
                      .selectedFilters['Checking Status'] ??
                  'All',
            ),
            onApplyFilters: (filterData) {
              setState(() {
                assetIdController.text = filterData.assetId;
                assetNameController.text = filterData.name;
                customerController.text = filterData.customer;
                serialNumberController.text = filterData.serialNumber;
                _assetCategory =
                    filterData.category.isEmpty ? null : filterData.category;
                locationController.text = filterData.location;
                _assetStatus = filterData.status;
              });
              ref.read(assetFiltersProvider.notifier).updateFilter(
                {filterData.checkingStatus: filterData.checkingStatus},
                "Checking Status",
              );
              _fetchAssets();
              Navigator.pop(context);
            },
            onClearFilters: () {
              ref.read(assetFiltersProvider.notifier).clearFilters();
              setState(() {
                assetIdController.clear();
                assetNameController.clear();
                customerController.clear();
                serialNumberController.clear();
                _assetCategory = null;
                locationController.clear();
                _assetStatus = '';
                _customer = null;
              });
              _fetchAssets();
              Navigator.pop(context);
            },
          ),
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
    );
  }

  Widget _buildAssetsList() {
    ref.watch(refreshProvider);
    final selectedFilters =
        ref.watch(assetFiltersProvider.notifier).selectedFilters;
    final checkingFilter = selectedFilters['Checking Status'];

    // Filter list locally based on check-in status if filter is active
    final filteredAssets = assets.where((asset) {
      if (checkingFilter == null ||
          checkingFilter == 'All' ||
          checkingFilter == '') return true;
      final assetId = asset['id']?.toString();
      if (assetId == null) return true; // Can't filter if no ID
      final status = _assetCheckingStatusMap[assetId];
      // When a specific checking filter is active, hide assets with unknown
      // status until their status is loaded. This avoids showing incorrect
      // results while per-item async loads complete.
      if (status == null) return false;
      return status == checkingFilter;
    }).toList();

    if (filteredAssets.isEmpty && !isLoading) {
      return const NoDataFoundPage();
    }

    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: filteredAssets.length + (hasMore ? 1 : 0),
      separatorBuilder: (context, index) => const DGap(gap: 8),
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        if (index < filteredAssets.length) {
          var assetData = AssetsModel.fromJson(filteredAssets[index]);
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
          title: Row(
            children: [
              Flexible(
                child: Text(
                  data.name,
                  style: boldHeading(size: 19),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (data.status.toLowerCase() ==
                  inactiveStatusString.toLowerCase()) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: tRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: tRed, width: 0.5),
                  ),
                  child: const Text(
                    "INACTIVE",
                    style: TextStyle(
                      color: tRed,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
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
              AssetStatusButton(
                data: data,
                ref: ref,
                onStatusChanged: (newStatus) {
                  final assetId = data.id;
                  if (assetId == null) return;

                  // Only update if status actually changed to avoid rebuild loops
                  if (_assetCheckingStatusMap[assetId] != newStatus) {
                    Future.microtask(() {
                      if (mounted) {
                        setState(() {
                          _assetCheckingStatusMap[assetId] = newStatus;
                        });
                      }
                    });
                  }
                },
              ),
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

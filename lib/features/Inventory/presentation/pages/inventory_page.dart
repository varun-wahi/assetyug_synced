
import 'dart:async';
import 'dart:convert';

import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/features/Inventory/data/models/inventory_model.dart';
import 'package:asset_yug_debugging/features/Inventory/data/repository/inventory_repository.dart';
import 'package:asset_yug_debugging/features/inventory/presentation/pages/view_inventory_page.dart';
import 'package:asset_yug_debugging/features/inventory/presentation/riverpod/inventory_sorting_notifier.dart';
import 'package:asset_yug_debugging/features/Main/presentation/riverpod/refresh_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shimmer/shimmer.dart';

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
import '../../../inventory/presentation/riverpod/inventory_filter_notifier.dart';
import 'add_inventory_page.dart';


class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildAppBar(context, ref),
      resizeToAvoidBottomInset: false,
      backgroundColor: tBackground,
      body: const Padding(
        padding: EdgeInsets.all(dPadding),
        child: inventorySearchAndList(),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text("Inventory"),
      // actions: [
      //   IconButton(
      //     onPressed: () => {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => const AddinventoryPage(frominventoryPage: true,),
      //         ),
      //       )
      //     },
      //     icon: const Icon(Icons.person_add),
      //   ),
      // ],
    );
  }
}

class inventorySearchAndList extends ConsumerStatefulWidget {
  const inventorySearchAndList({super.key});

  @override
  _inventorySearchAndListState createState() => _inventorySearchAndListState();
}

class _inventorySearchAndListState
    extends ConsumerState<inventorySearchAndList> {
  final searchTextFieldController = TextEditingController();

  List<dynamic> inventory = [];
  bool isLoading = true;
  bool isDeleting = false;
  bool hasMore = true;
  int currentPage = 0;
  static const int pageSize = 10;
  String sortingCategory = '';
  final ScrollController _scrollController = ScrollController();
  String? companyId;
  Timer? _debounce;

  final inventoryNameController = TextEditingController();
  final addressController = TextEditingController();
  final inventoryController = TextEditingController();
  final phoneNumberController = TextEditingController();

  String? _inventorytatus = "Active";
  String? _inventoryCategory;

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
    inventoryNameController.dispose();
    inventoryController.dispose();
    addressController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> fetchCompanyId() async {
    final box = await Hive.openBox('auth_data');
    companyId = box.get('companyId');
    _fetchinventory();
  }

  Future<void> _fetchinventory() async {
    ref.watch(refreshProvider);
    setState(() {
      isLoading = true;
      currentPage = 0;
      inventory.clear();
    });
    await _fetchinventoryPage();
  }

  Future<void> _fetchMoreinventory() async {
    if (!hasMore || isLoading) return;
    setState(() {
      isLoading = true;
    });
    currentPage++;
    await _fetchinventoryPage();
  }

  Future<void> _fetchinventoryPage() async {
    try {
      final inventoryRepo = InventoryRepository();
      final searchTerm = searchTextFieldController.text;

      if (companyId == null) {
        throw Exception("Company ID not found");
      }

      final filterForm = {
        "name": inventoryNameController.text,
        "companyId": companyId.toString(),
        "category": _inventoryCategory ?? "",
        "status": _inventorytatus ?? "",
        "phone": phoneNumberController.text,
        "email": "",
        "address": addressController.text,
        "apartment": "",
        "city": "",
        "state": "",
        "zipCode": ""
      };
      // print("Advanced filters being updated");
      // print(filterForm);

      final response = await inventoryRepo.advanceFilter(
        filterForm,
        currentPage,
        pageSize,
        sortingCategory,
        searchTerm,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> inventoryList = responseData['data'];

        setState(() {
          // inventory.addAll(inventoryList); // Append the new list
          inventory.addAll(inventoryList
              .map((e) => json.decode(e))
              .toList()); // Append the new list
          isLoading = false;
          hasMore = inventory.length < responseData['totalRecords'];
        });
      } else {
        throw Exception("Failed to load inventory");
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
      _fetchMoreinventory();
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

    final sortingCategory = ref.watch(inventorySortingProvider);

    // if (sortingCategory != this.sortingCategory) {
      // this.sortingCategory = sortingCategory as String;
      // _fetchinventory();
    // }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: tPrimary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddInventoryPage(),
            ),
          );
        },
        child: const Icon(Icons.add_task),
      ),
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(builder: (context, constraints) {
        return Column(
          children: [
            _buildSearchBar(),
            // Container(
            //   padding: const EdgeInsets.all(dPadding),
            //   height: 70,
            //   child: _buildFiltersSection(),
            // ),
            Expanded(
              child: _buildinventoryList(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchBar() {
    return DSearchBar(
      hintText: "Search all inventory",
      controller: searchTextFieldController,
      onChanged: _onSearchChanged,
    );
  }

  // Widget _buildFiltersSection() {
  //   final selectedFilters =
  //       ref.watch(inventoryFiltersProvider.notifier).selectedFilters;
  //   return SizedBox(
  //     height: 70,
  //     child: Row(
  //       children: [
  //         Expanded(
  //           flex: 4,
  //           child: _buildSelectedFilters(selectedFilters),
  //         ),
  //         Expanded(
  //           child: IconButton(
  //             onPressed: () {
  //               ref.read(refreshProvider.notifier).state =
  //                   !ref.read(refreshProvider);
  //               _fetchinventory();
  //             },
  //             icon: const Icon(Icons.refresh, color: darkGrey),
  //           ),
  //         ),
  //         Expanded(
  //           child: IconButton(
  //             onPressed: () => _buildAdvancedFilters(),
  //             icon: const Icon(Icons.filter_alt, color: darkGrey),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildSelectedFilters(Map<String, dynamic> selectedFilters) {
  //   return ListView.separated(
  //     padding: const EdgeInsets.all(dPadding),
  //     scrollDirection: Axis.horizontal,
  //     itemCount: assetsFilters.length,
  //     separatorBuilder: (context, index) => const SizedBox(width: dPadding),
  //     itemBuilder: (context, index) {
  //       String filterKey = assetsFilters.keys.elementAt(index);
  //       return DSelectedFilterItem(
  //         selectedOption: selectedFilters[filterKey] ?? '',
  //         isDropdown: true,
  //         title: filterKey,
  //         onPressed: () {
  //           print("Building selected filter");

  //           inventoryShowFiltersModalSheet.showFilterOptions(
  //             context,
  //             filterKey,
  //             selectedFilters[filterKey],
  //             inventoryFilters,
  //             ref,
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // void _buildAdvancedFilters() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return _buildFilterModalContent();
  //     },
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
  //     ),
  //   );
  // }

  // Widget _buildFilterModalContent() {
  //   return Container(
  //     padding: const EdgeInsets.all(2 * dPadding),
  //     decoration: const BoxDecoration(
  //       color: tWhite,
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(30.0),
  //         topRight: Radius.circular(30.0),
  //       ),
  //     ),
  //     height: 500,
  //     child: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: <Widget>[
  //           _buildFilterModalHeader(),
  //           _buildFilterModalBody(),
  //           _buildFilterModalFooter(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildFilterModalHeader() {
  //   return SizedBox(
  //     height: 40,
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //         Text('Select Filters', style: boldHeading()),
  //         TextButton(
  //           onPressed: () => _clearFilters(),
  //           child: Text("CLEAR", style: boldHeading(size: 16)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildFilterModalBody() {
  //   print("inventory Category Items: $inventoryCategoryTypeMenuItems");
  //   print("Selected inventory Category: $_inventoryCategory");
  //   print("inventory Status Items: $inventorytatusMenuItems");
  //   print("Selected inventory Status: $_inventorytatus");

  //   return SizedBox(
  //     height: 350,
  //     child: SingleChildScrollView(
  //       child: Column(
  //         children: [
  //           Column(
  //             children: [
  //               DTextField(
  //                   icon: const Icon(Icons.tag),
  //                   hintText: "Name",
  //                   controller: inventoryNameController),
  //               DTextField(
  //                   icon: const Icon(Icons.person),
  //                   hintText: "Address",
  //                   controller: addressController),
  //               DTextField(
  //                   icon: const Icon(Icons.confirmation_number),
  //                   hintText: "Phone Number",
  //                   controller: phoneNumberController),
                
               
  //             ],
  //           ),
  //           const DGap(),
  //           _buildAdditionalFilters(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildAdditionalFilters() {
  //   return Container(
  //     decoration: dBoxDecoration(color: tBackground),
  //     child: Text("Extra fields to be added soon", style: subtitle()),
  //   );
  // }

  // Widget _buildFilterModalFooter() {
  //   return SizedBox(
  //     height: 40,
  //     child: DElevatedButton(
  //       buttonColor: tBlack,
  //       textColor: tWhite,
  //       child: const Text('Apply Filters'),
  //       onPressed: () => setState(() {
  //         _fetchinventory();
  //         ref.read(refreshProvider.notifier).state =
  //             !ref.read(refreshProvider); // Trigger refresh
  //         Navigator.pop(context);
  //       }),
  //     ),
  //   );
  // }

  // void _clearFilters() {
  //   ref.read(inventoryFiltersProvider.notifier).clearFilters();

  //   _inventoryCategory = null;
  //   _inventorytatus = null;

  //   inventoryNameController.clear();
  //   addressController.clear();
  //   phoneNumberController.clear();

  //   setState(() {});

  //   searchTextFieldController.clear();
  //   _fetchinventory();
  //   Navigator.pop(context);
  // }

  Widget _buildinventoryList() {
    ref.watch(refreshProvider);

    if (inventory.isEmpty && !isLoading) {
      return const NoDataFoundPage();
    }else if (isLoading && inventory.isEmpty) {
      return ListView.separated(
        itemCount: 10, // Show 10 shimmer placeholders
        separatorBuilder: (context, index) => const SizedBox(height: dGap),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(dBorderRadius),
              ),
            ),
          );
        },
      );
    }

    return ListView.separated(
      controller: _scrollController,
      itemCount: inventory.length +
          (hasMore ? 1 : 0), // Add 1 item for the loading indicator
      separatorBuilder: (context, index) => const SizedBox(height: dGap),
      itemBuilder: (context, index) {
        if (index < inventory.length) {
          var inventoryData = InventoryModel.fromJson(inventory[index]);
          return buildInventoryDetailsCard(inventoryData);
        } else if (hasMore) {
          return const Center(
              child:
                  CircularProgressIndicator()); // Loading indicator when fetching more inventory
        } else {
          return const SizedBox.shrink(); // No more data to load
        }
      },
    );
  }

  Widget buildInventoryDetailsCard(InventoryModel data) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ViewInventoryPage(inventoryId: data.partId),
      ));
    },
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: (data.imageBase64 != null)
                  ? MemoryImage(base64Decode(data.imageBase64!))
                  : null,
              child: (data.imageBase64 == null)
                  ? Text(
                      data.partName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.partName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("ID: ${data.partId}"),
                  Text("Category: ${data.category}"),
                  Text("Quantity: ${data.quantity}"),
                  Text("Price: ₹${data.price.toStringAsFixed(2)}"),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'delete') {
                  _showDeleteDialog(data);
                }
              },
              itemBuilder: (BuildContext context) => const [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}


void _showDeleteDialog(InventoryModel data) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Delete Inventory'),
          content: const Text('Are you sure you want to delete this inventory item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isDeleting
                  ? null
                  : () async {
                      setState(() => isDeleting = true);
                      final response = await InventoryRepository().deleteCompanyCustomer(data.partId);
                      if (response.statusCode == 200) {
                        dSnackBar(context, "Inventory deleted successfully", TypeSnackbar.info);
                      } else {
                        dSnackBar(context, "Failed to delete inventory", TypeSnackbar.error);
                      }
                      ref.read(refreshProvider.notifier).state = !ref.read(refreshProvider);
                      Navigator.of(context).pop();
                      setState(() => isDeleting = false);
                    },
              child: isDeleting
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Delete'),
            ),
          ],
        ),
      );
    },
  );
}


}

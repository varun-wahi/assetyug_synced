import 'dart:convert';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_model.dart';
import 'package:asset_yug_debugging/features/Customers/data/models/customers_model.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/view_asset_page.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/config/theme/box_shadow_styles.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/features/Customers/data/repository/company_customer_details_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomerAssetsPage extends StatefulWidget {
  final CustomersModel data;
  const CustomerAssetsPage({super.key, required this.data});

  @override
  State<CustomerAssetsPage> createState() => _CustomerAssetsPageState();
}

class _CustomerAssetsPageState extends State<CustomerAssetsPage> {
  final List<AssetsModel> _assetsList = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  int _currentPage = 0;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final CompanyCustomerDetailsService _service =
      CompanyCustomerDetailsService();

  @override
  void initState() {
    super.initState();
    _fetchAssets();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isFetchingMore &&
        _hasMore) {
      _fetchAssets(isLoadMore: true);
    }
  }

  Future<void> _fetchAssets({bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() => _isFetchingMore = true);
    } else {
      setState(() => _isLoading = true);
      _currentPage = 0;
      _assetsList.clear();
    }

    try {
      final response = await _service.getAssetByCustomerId(
        widget.data.id!,
        _currentPage,
      );

      debugPrint("📦 Customer Assets Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        final List<dynamic> rawDataList = decodedBody['data'] ?? [];
        final int totalRecords = decodedBody['totalRecords'] ?? 0;

        final List<AssetsModel> newAssets = rawDataList.map((item) {
          // Double-decode if the item is a string
          final Map<String, dynamic> assetMap =
              item is String ? json.decode(item) : item;
          debugPrint("🏷️ Processing Asset: ${assetMap['name']}");
          return AssetsModel.fromJson(assetMap);
        }).toList();

        setState(() {
          _assetsList.addAll(newAssets);
          _currentPage++;
          _hasMore = _assetsList.length < totalRecords;
        });
      }
    } catch (e) {
      debugPrint("Error fetching customer assets: $e");
    } finally {
      setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (_assetsList.isEmpty) {
      return const NoDataFoundPage();
    }

    return RefreshIndicator(
      onRefresh: () => _fetchAssets(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(dPadding * 2),
        itemCount: _assetsList.length + (_isFetchingMore ? 1 : 0),
        separatorBuilder: (context, index) => const DGap(),
        itemBuilder: (context, index) {
          if (index < _assetsList.length) {
            final asset = _assetsList[index];
            return _buildAssetCard(asset);
          } else {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAssetCard(AssetsModel asset) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewAssetPage(assetObjectId: asset.id!),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: tPrimary,
          borderRadius: BorderRadius.circular(dBorderRadius),
          boxShadow: dBoxShadow(),
        ),
        padding: const EdgeInsets.all(dPadding * 2),
        child: Column(
          children: [
            _buildDetailRow("Asset Name:", asset.name),
            _buildDetailRow("Serial Number:", asset.serialNumber),
            _buildDetailRow("Asset Status:", asset.status),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: subheading(color: tWhite),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: tWhite),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      padding: const EdgeInsets.all(dPadding * 2),
      itemCount: 5,
      separatorBuilder: (context, index) => const DGap(),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(dBorderRadius),
          ),
        ),
      ),
    );
  }
}

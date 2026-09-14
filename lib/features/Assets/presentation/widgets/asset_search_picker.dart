import 'dart:async';
import 'dart:convert';

import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_searchbar.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_model.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:flutter/material.dart';

class AssetSearchPicker extends StatefulWidget {
  final String companyId;
  final AssetsModel? selectedAsset;
  final ValueChanged<AssetsModel?> onChanged;
  final String hintText;

  const AssetSearchPicker({
    super.key,
    required this.companyId,
    required this.onChanged,
    this.selectedAsset,
    this.hintText = 'Search by name, serial, or category...',
  });

  @override
  State<AssetSearchPicker> createState() => _AssetSearchPickerState();
}

class _AssetSearchPickerState extends State<AssetSearchPicker> {
  final TextEditingController _searchController = TextEditingController();
  final AssetsRepositoryImpl _repo = AssetsRepositoryImpl();

  Timer? _debounce;
  int _requestId = 0;

  List<AssetsModel> _results = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetchAssets();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchAssets();
    });
  }

  Future<void> _fetchAssets() async {
    final currentRequest = ++_requestId;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final searchTerm = _searchController.text.trim();
      final filterForm = {
        'assetId': '',
        'name': searchTerm,
        'customer': '',
        'serialNumber': '',
        'category': '',
        'location': null,
        'status': '',
        'email': null,
        'companyId': widget.companyId,
        'sortDirection': 'DESC',
        'sortField': 'updatedAt',
        'pageNumber': 0,
        'pageSize': 10,
        'customFields': <String, String>{},
      };

      final response = await _repo.advanceFilter(filterForm);

      if (currentRequest != _requestId || !mounted) return;

      if (response.statusCode != 200) {
        throw Exception('Failed to search assets (${response.statusCode})');
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid assets response');
      }

      final data = decoded['assets'] ?? decoded['data'];
      final results = <AssetsModel>[];

      if (data is List) {
        for (final item in data) {
          try {
            final parsed = item is String
                ? json.decode(item) as Map<String, dynamic>
                : item;
            if (parsed is Map<String, dynamic>) {
              results.add(AssetsModel.fromJson(parsed));
            }
          } catch (_) {
            continue;
          }
        }
      }

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      if (currentRequest != _requestId || !mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _results = [];
      });
    }
  }

  void _selectAsset(AssetsModel asset) {
    FocusScope.of(context).unfocus();
    _searchController.clear();
    widget.onChanged(asset);
  }

  void _clearSelection() {
    widget.onChanged(null);
    _fetchAssets();
  }

  bool _hasValidAssetId(AssetsModel asset) {
    final assetId = asset.assetId?.trim();
    return assetId != null && assetId.isNotEmpty && assetId != '000';
  }

  bool _hasValidCategory(AssetsModel asset) {
    final category = asset.category.trim();
    return category.isNotEmpty &&
        category.toLowerCase() != 'unassigned' &&
        category.toLowerCase() != 'null';
  }

  Widget? _buildAssetMetaRow(AssetsModel asset) {
    final hasCategory = _hasValidCategory(asset);
    final hasAssetId = _hasValidAssetId(asset);

    return Row(
      children: [
        Icon(Icons.category_outlined, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            hasCategory ? asset.category : 'No category',
            style: body(size: 12, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (hasAssetId) ...[
          const SizedBox(width: 8),
          Text(
            '#${asset.assetId!.trim()}',
            style: body(size: 12, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selectedAsset;

    if (selected != null) {
      final meta = _buildAssetMetaRow(selected);
      return InputDecorator(
        decoration: InputDecoration(
          labelText: 'Asset *',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: tBlack),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: tBlack),
          ),
          suffixIcon: IconButton(
            onPressed: _clearSelection,
            icon: const Icon(Icons.close),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(selected.name, style: body(weight: FontWeight.w600)),
            if (meta != null) ...[
              const SizedBox(height: 2),
              meta,
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Asset *', style: body(weight: FontWeight.w600, size: 13)),
        DSearchBar(
          controller: _searchController,
          hintText: widget.hintText,
          textStyle: body(size: 13, color: Colors.black),
          onChanged: _onSearchChanged,
          onSubmitted: (_) => _fetchAssets(),
        ),
        _buildResults(),
      ],
    );
  }

  Widget _buildResults() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: tWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tGreyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Could not load assets',
                    style: body(size: 13, color: tRed),
                  ),
                )
              : _results.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No assets found',
                        style: body(size: 13, color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _results.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 0.1, color: tGreyLight),
                      itemBuilder: (context, index) {
                        final asset = _results[index];
                        return ListTile(
                          dense: true,
                          title: Text(asset.name, style: body(size: 13, color: Colors.black, weight: FontWeight.w600)),
                          subtitle: _buildAssetMetaRow(asset),
                          onTap: () => _selectAsset(asset),
                        );
                      },
                    ),
    );
  }
}

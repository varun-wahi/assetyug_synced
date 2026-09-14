import 'dart:convert';

import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_model.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/inspection models/inspection_template_model.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/add_inspection_page.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/widgets/asset_search_picker.dart';
import 'package:flutter/material.dart';

class CreateInspectionPage extends StatefulWidget {
  final String companyId;

  const CreateInspectionPage({
    super.key,
    required this.companyId,
  });

  @override
  State<CreateInspectionPage> createState() => _CreateInspectionPageState();
}

class _CreateInspectionPageState extends State<CreateInspectionPage> {
  final AssetsRepositoryImpl _repo = AssetsRepositoryImpl();
  final TextEditingController _categoryController = TextEditingController();

  AssetsModel? _selectedAsset;
  List<AssetInspectionTemplateModel> _templates = [];
  bool _isLoadingTemplates = false;
  String? _templatesError;

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _onAssetChanged(AssetsModel? asset) async {
    setState(() {
      _selectedAsset = asset;
      _categoryController.text = asset?.category ?? '';
      _templates = [];
      _templatesError = null;
      _isLoadingTemplates = asset != null;
    });

    if (asset == null) return;
    await _loadTemplates(asset);
  }

  Future<void> _loadTemplates(AssetsModel asset) async {
    final selectedId = asset.id;

    try {
      final response = await _repo.getAssetInspectionsByCategory(
        widget.companyId,
        asset.category,
      );

      if (!mounted || _selectedAsset?.id != selectedId) return;

      if (response.statusCode != 200) {
        throw Exception('Failed to load templates (${response.statusCode})');
      }

      final responseBody = utf8.decode(response.bodyBytes);
      final templates = <AssetInspectionTemplateModel>[];

      if (responseBody.isNotEmpty) {
        final jsonData = json.decode(responseBody);
        if (jsonData is List) {
          templates.addAll(
            jsonData.map(
              (data) => AssetInspectionTemplateModel.fromJson(data),
            ),
          );
        }
      }

      setState(() {
        _templates = templates;
        _isLoadingTemplates = false;
        _templatesError = templates.isEmpty
            ? 'No inspection templates available for this category'
            : null;
      });
    } catch (e) {
      if (!mounted || _selectedAsset?.id != selectedId) return;
      setState(() {
        _templates = [];
        _isLoadingTemplates = false;
        _templatesError = 'Error loading templates: $e';
      });
    }
  }

  Future<void> _continueToForm() async {
    final asset = _selectedAsset;
    final assetId = asset?.id;

    if (asset == null || assetId == null || assetId.isEmpty) {
      dSnackBar(context, 'Please select an asset', TypeSnackbar.warning);
      return;
    }

    if (asset.category.trim().isEmpty) {
      dSnackBar(
        context,
        'Selected asset has no category',
        TypeSnackbar.warning,
      );
      return;
    }

    if (_isLoadingTemplates) return;

    if (_templates.isEmpty) {
      dSnackBar(
        context,
        _templatesError ??
            'No inspection templates available for this category',
        TypeSnackbar.info,
      );
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddInspectionPage(
          assetId: assetId,
          companyId: widget.companyId,
          availableTemplates: _templates,
        ),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _selectedAsset != null &&
        !_isLoadingTemplates &&
        _templates.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Inspection',
          style: body(weight: FontWeight.w600, size: 15),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(dPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select an asset, then choose inspection template(s) available for that asset's category.",
              style: body(size: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            AssetSearchPicker(
              companyId: widget.companyId,
              selectedAsset: _selectedAsset,
              onChanged: _onAssetChanged,
            ),
            const SizedBox(height: 16),
            TextFormField(
              enabled: false,
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Asset Category',
                hintText: 'Select an asset first',
                filled: true,
                fillColor: tGreyLight.withOpacity(0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: tGreyLight),
                ),
              ),
            ),
            if (_isLoadingTemplates) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ] else if (_templatesError != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _templatesError!,
                  style: body(size: 13, color: tRed),
                ),
              ),
            ] else if (_selectedAsset != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${_templates.length} template(s) available for this category.',
                  style: body(size: 13, color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(dPadding * 2),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                  child: Text('Cancel', style: body()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: canContinue ? _continueToForm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tPrimary,
                    foregroundColor: tWhite,
                    minimumSize: const Size(0, 48),
                  ),
                  child: Text(
                    'Continue',
                    style: body(color: tWhite),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

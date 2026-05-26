import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/add_inspection_page.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/widgets/inspection_instance_card.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'dart:convert';

import '../../../data/models/inspection models/asset_inspection_instance__model.dart';
import '../../../data/models/inspection models/inspection_template_model.dart';

final assetsRepositoryProvider =
    Provider<AssetsRepositoryImpl>((ref) => AssetsRepositoryImpl());

class AssetInspectionPage extends ConsumerStatefulWidget {
  final String assetId;
  final String category;
  final String companyId;

  const AssetInspectionPage({
    super.key,
    required this.assetId,
    required this.category,
    required this.companyId,
  });

  @override
  ConsumerState<AssetInspectionPage> createState() =>
      _AssetInspectionPageState();
}

class _AssetInspectionPageState extends ConsumerState<AssetInspectionPage>
    with SingleTickerProviderStateMixin {
  List<AssetInspectionInstanceModel> inspectionInstances = [];
  List<AssetInspectionTemplateModel> availableTemplates = [];
  bool isLoadingInstances = true;
  bool isLoadingTemplates = true;
  String? error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadInspectionInstances(),
      _loadAvailableTemplates(),
    ]);
  }

  Future<void> _loadInspectionInstances() async {
    try {
      final repository = ref.read(assetsRepositoryProvider);
      final response = await repository.getAssetInspectionInstancesByAssetId(
        widget.assetId,
      );

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        if (responseBody.isNotEmpty) {
          final List<dynamic> jsonData = json.decode(responseBody);
          setState(() {
            inspectionInstances = jsonData
                .map((data) => AssetInspectionInstanceModel.fromJson(data))
                .toList();
            isLoadingInstances = false;
          });
        } else {
          setState(() {
            inspectionInstances = [];
            isLoadingInstances = false;
          });
        }
      } else {
        throw Exception('Failed to load inspections: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = 'Error loading inspections: $e';
        isLoadingInstances = false;
      });
    }
  }

  Future<void> _loadAvailableTemplates() async {
    try {
      final repository = ref.read(assetsRepositoryProvider);
      final response = await repository.getAssetInspectionsByCategory(
        widget.companyId,
        widget.category,
      );

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        if (responseBody.isNotEmpty) {
          final List<dynamic> jsonData = json.decode(responseBody);
          setState(() {
            availableTemplates = jsonData
                .map((data) => AssetInspectionTemplateModel.fromJson(data))
                .toList();
            isLoadingTemplates = false;
          });
        } else {
          setState(() {
            availableTemplates = [];
            isLoadingTemplates = false;
          });
        }
      } else {
        throw Exception('Failed to load templates: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = 'Error loading templates: $e';
        isLoadingTemplates = false;
      });
    }
  }

  Future<void> _navigateToAddInspection() async {
    if (availableTemplates.isEmpty) {
      dSnackBar(
        context,
        'No inspection templates available for this category',
        TypeSnackbar.info,
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddInspectionPage(
          assetId: widget.assetId,
          companyId: widget.companyId,
          availableTemplates: availableTemplates,
        ),
      ),
    );

    if (result == true) {
      _loadInspectionInstances();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: tPrimary,
        onPressed: _navigateToAddInspection,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Completed'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInspectionList(isPending: true),
                _buildInspectionList(isPending: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionList({required bool isPending}) {
    if (isLoadingInstances) {
      return const Center(
        child: SizedBox(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Center(child: Text('Error: $error'));
    }

    final filteredInstances = inspectionInstances
        .where((instance) => isPending
            ? instance.status == 'PENDING'
            : instance.status == 'COMPLETED')
        .toList();

    if (filteredInstances.isEmpty) {
      return const NoDataFoundPage();
    }

    return Padding(
      padding: const EdgeInsets.all(dPadding),
      child: ListView.separated(
        itemCount: filteredInstances.length,
        itemBuilder: (context, index) {
          final instance = filteredInstances[index];

          return InspectionInstanceCard(
            instance: instance,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddInspectionPage(
                    assetId: widget.assetId,
                    companyId: widget.companyId,
                    availableTemplates: availableTemplates,

                    // EDIT MODE
                    existingInspection: instance,
                  ),
                ),
              );

              // REFRESH AFTER UPDATE
              if (result == true) {
                _loadInspectionInstances();
              }
            },
          );
        },
        separatorBuilder: (_, __) => const DGap(),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

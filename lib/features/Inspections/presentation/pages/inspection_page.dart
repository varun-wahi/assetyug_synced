import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../data/models/inspection_models.dart';
import '../../data/repository/inspection_repository.dart';
import 'create_inspection_page.dart';
import '../widgets/inspection_advanced_filter_sheet.dart';
import '../widgets/inspection_detail_widget.dart';
import '../widgets/inspection_filter_data.dart';
import '../widgets/inspection_list_card.dart';
import '../widgets/inspection_pagination.dart';
import '../widgets/inspection_search_bar.dart';
import '../widgets/inspection_stats_section.dart';

class InspectionsPage extends StatefulWidget {
  const InspectionsPage({super.key});

  @override
  State<InspectionsPage> createState() => _InspectionsPageState();
}

class _InspectionsPageState extends State<InspectionsPage> {
  final InspectionRepositoryImpl _repo = InspectionRepositoryImpl();
  final TextEditingController _searchController = TextEditingController();

  static const int _itemsPerPage = 10;

  String? _companyId;
  bool _isLoading = true;
  String? _error;

  InspectionStats _stats = const InspectionStats(
    total: 0,
    byEmployee: [],
  );
  List<InspectionSummary> _allInspections = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalRecords = 0;

  InspectionFilterData _filters = InspectionFilterData.empty;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final box = await Hive.openBox('auth_data');
    final companyId = box.get('companyId')?.toString();
    if (!mounted) return;

    if (companyId == null || companyId.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Company ID not found. Please log in again.';
      });
      return;
    }

    setState(() => _companyId = companyId);
    await _loadInspections(page: 1);
  }

  void _onSearchChanged(String value) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      setState(() {
        _filters = _filters.copyWith(
          assetName: value.trim(),
          clearAssetName: value.trim().isEmpty,
        );
      });
      _loadInspections(page: 1);
    });
  }

  Future<void> _openFilters() async {
    final companyId = _companyId;
    if (companyId == null || companyId.isEmpty) return;

    final result = await showInspectionAdvancedFilterSheet(
      context: context,
      companyId: companyId,
      initialData: _filters,
    );

    if (result == null || !mounted) return;

    setState(() {
      _filters = result;
      _searchController.text = result.assetName ?? '';
    });
    await _loadInspections(page: 1);
  }

  Future<void> _loadInspections({required int page}) async {
    final companyId = _companyId;
    if (companyId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final pageNumber = page - 1;
      final filterPayload = _filters.toPayload(
        pageNumber: pageNumber,
        pageSize: _itemsPerPage,
      );

      final results = await Future.wait([
        _repo.getInspectionStatusCount(companyId),
        _repo.getIncompleteInspectionsByPerformer(companyId),
        _repo.getDetailedInspections(
          companyId,
          pageNumber: pageNumber,
          pageSize: _itemsPerPage,
          payload: filterPayload,
        ),
      ]);

      final statusRes = results[0];
      final performerRes = results[1];
      final detailedRes = results[2];

      print('Inspection status-count [${statusRes.statusCode}]: ${statusRes.body}');
      print(
          'Inspection incomplete-by-performer [${performerRes.statusCode}]: ${performerRes.body}');
      print('Inspection detailed [${detailedRes.statusCode}]: ${detailedRes.body}');
      print('Inspection detailed payload: $filterPayload');

      if (statusRes.statusCode != 200 ||
          performerRes.statusCode != 200 ||
          detailedRes.statusCode != 200) {
        throw Exception(
          'Failed to load inspections '
          '(status: ${statusRes.statusCode}, '
          'performers: ${performerRes.statusCode}, '
          'list: ${detailedRes.statusCode})',
        );
      }

      final statusJson =
          json.decode(statusRes.body) as Map<String, dynamic>? ?? {};
      final performerJson =
          json.decode(performerRes.body) as Map<String, dynamic>? ?? {};
      final detailedJson =
          json.decode(detailedRes.body) as Map<String, dynamic>? ?? {};

      final byEmployee = performerJson['performerCounts'] is List
          ? (performerJson['performerCounts'] as List)
              .whereType<Map>()
              .map((item) => EmployeeInspectionCount.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList()
          : <EmployeeInspectionCount>[];

      final inspections = detailedJson['data'] is List
          ? (detailedJson['data'] as List)
              .whereType<Map>()
              .map((item) => InspectionSummary.fromDetailedJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList()
          : <InspectionSummary>[];

      if (!mounted) return;
      setState(() {
        _stats = InspectionStats.fromApi(
          statusCountJson: statusJson,
          byEmployee: byEmployee,
        );
        _allInspections = inspections;
        _currentPage = page;
        _totalRecords = parseInspectionCount(detailedJson['totalRecords']);
        final apiPages = parseInspectionCount(detailedJson['totalPages']);
        _totalPages = apiPages > 0 ? apiPages : 1;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('❌ Failed to load inspections: $e');
      print(stackTrace);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _openDetail(InspectionSummary summary) {
    showInspectionDetail(context, summary.toDetail());
  }

  Future<void> _applyStatusFilter(String? statusLabel) async {
    setState(() {
      if (statusLabel == null || statusLabel.trim().isEmpty) {
        _filters = _filters.copyWith(status: 'All', clearStatus: true);
      } else {
        _filters = _filters.copyWith(status: statusLabel);
      }
    });
    await _loadInspections(page: 1);
  }

  Future<void> _openCreateInspection() async {
    final companyId = _companyId;
    if (companyId == null || companyId.isEmpty) {
      return;
    }

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateInspectionPage(companyId: companyId),
      ),
    );

    if (created == true && mounted) {
      await _loadInspections(page: 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadInspections(page: _currentPage),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Inspections',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _openCreateInspection,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Inspection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B1E40),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFB91C1C)),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => _loadInspections(page: _currentPage),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else ...[
                InspectionStatsSection(
                  stats: _stats,
                  selectedStatus: _filters.status,
                  onStatusSelected: _applyStatusFilter,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All inspections',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      '$_totalRecords results',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InspectionSearchBar(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onFiltersTap: _openFilters,
                  activeFilterCount: _filters.activeCount,
                ),
                const SizedBox(height: 12),
                if (_allInspections.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No inspections found',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                  )
                else
                  for (int i = 0; i < _allInspections.length; i++) ...[
                    InspectionListCard(
                      inspection: _allInspections[i],
                      onTap: () => _openDetail(_allInspections[i]),
                    ),
                    if (i != _allInspections.length - 1)
                      const SizedBox(height: 12),
                  ],
                const SizedBox(height: 20),
                InspectionPagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  itemsPerPage: _itemsPerPage,
                  totalItems: _totalRecords,
                  onPageSelected: (page) => _loadInspections(page: page),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

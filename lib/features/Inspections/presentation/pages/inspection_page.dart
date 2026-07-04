import 'package:flutter/material.dart';

import '../../data/models/inspection_models.dart';
import '../widgets/inspection_detail_widget.dart';
import '../widgets/inspection_list_card.dart';
import '../widgets/inspection_pagination.dart';
import '../widgets/inspection_search_bar.dart';
import '../widgets/inspection_stats_section.dart';

/// Top-level "Inspections" screen matching the first mockup:
/// header + "+ Inspection" button, stat cards, by-employee bars,
/// search/filters, and the paginated list of inspection cards.
///
/// Replace [_dummyStats] / [_dummySummaries] with data from your
/// repo/provider later — the widget itself doesn't care where it
/// comes from.
class InspectionsPage extends StatefulWidget {
  const InspectionsPage({super.key});

  @override
  State<InspectionsPage> createState() => _InspectionsPageState();
}

class _InspectionsPageState extends State<InspectionsPage> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  static const int _itemsPerPage = 4;

  // ---- Dummy data (swap for Provider/repo data later) ----
  final InspectionStats _stats = const InspectionStats(
    total: 8,
    pending: 3,
    ongoing: 2,
    completed: 3,
    byEmployee: [
      EmployeeInspectionCount(name: 'Unassigned', count: 3),
      EmployeeInspectionCount(name: 'Kenji Tanaka', count: 1),
      EmployeeInspectionCount(name: 'Sara Khan', count: 1),
    ],
  );

  final List<InspectionSummary> _allInspections = [
    InspectionSummary(
      id: '1',
      assetName: 'Test asset new',
      templateName: 'Temp 1',
      customer: 'Abhishek',
      location: 'Bangalore',
      performedBy: 'Varun Wahi',
      dueDate: DateTime(2026, 5, 26),
      status: InspectionStatus.completed,
    ),
    InspectionSummary(
      id: '2',
      assetName: 'Forklift FL-200',
      templateName: 'Temp 1',
      customer: 'Maria Lopez',
      location: 'Austin',
      performedBy: 'Varun Wahi',
      dueDate: DateTime(2026, 5, 26),
      status: InspectionStatus.completed,
    ),
    InspectionSummary(
      id: '3',
      assetName: 'HVAC Unit 12',
      templateName: 'New inspection',
      customer: 'Kenji Tanaka',
      location: 'Osaka',
      performedBy: 'Kenji Tanaka',
      dueDate: DateTime(2026, 6, 10),
      status: InspectionStatus.ongoing,
    ),
    InspectionSummary(
      id: '4',
      assetName: 'Generator GX-9',
      templateName: 'Temp 1',
      customer: 'Sara Khan',
      location: 'Dubai',
      performedBy: 'Sara Khan',
      dueDate: DateTime(2026, 6, 8),
      status: InspectionStatus.ongoing,
    ),
    InspectionSummary(
      id: '5',
      assetName: 'Conveyor Belt C-3',
      templateName: 'Temp 1',
      customer: 'Unassigned',
      location: 'Berlin',
      performedBy: 'Unassigned',
      dueDate: DateTime(2026, 6, 15),
      status: InspectionStatus.pending,
    ),
    InspectionSummary(
      id: '6',
      assetName: 'Crane CR-7',
      templateName: 'Temp 1',
      customer: 'Unassigned',
      location: 'Toronto',
      performedBy: 'Unassigned',
      dueDate: DateTime(2026, 6, 20),
      status: InspectionStatus.pending,
    ),
    InspectionSummary(
      id: '7',
      assetName: 'Boiler B-1',
      templateName: 'Temp 1',
      customer: 'Unassigned',
      location: 'Mumbai',
      performedBy: 'Unassigned',
      dueDate: DateTime(2026, 6, 22),
      status: InspectionStatus.pending,
    ),
    InspectionSummary(
      id: '8',
      assetName: 'Pump P-22',
      templateName: 'Temp 1',
      customer: 'Maria Lopez',
      location: 'Austin',
      performedBy: 'Sara Khan',
      dueDate: DateTime(2026, 6, 1),
      status: InspectionStatus.completed,
    ),
  ];

  List<InspectionSummary> get _filteredInspections {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _allInspections;
    return _allInspections
        .where((i) => i.assetName.toLowerCase().contains(query))
        .toList();
  }

  List<InspectionSummary> get _pagedInspections {
    final filtered = _filteredInspections;
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, filtered.length);
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end);
  }

  int get _totalPages {
    final filtered = _filteredInspections;
    if (filtered.isEmpty) return 1;
    return (filtered.length / _itemsPerPage).ceil();
  }

  void _openDetail(InspectionSummary summary) {
    showInspectionDetail(context, _detailFor(summary));
  }

  // Builds a fuller detail object from the tapped summary. With a real
  // repo this would instead be a fetch-by-id call.
  InspectionDetail _detailFor(InspectionSummary summary) {
    return InspectionDetail(
      templateName: summary.templateName,
      status: summary.status,
      assetName: summary.assetName,
      serialNumber: '5665',
      category: 'Asset cat 2',
      customer: summary.customer ?? 'Unassigned',
      location: summary.location,
      performedBy: summary.performedBy,
      createdAt: summary.dueDate.subtract(const Duration(minutes: 10)),
      dueAt: summary.dueDate,
      steps: const [
        InspectionStep(
            label: 'Check', type: InspectionStepType.checkbox, value: 'true'),
        InspectionStep(
            label: 'Num', type: InspectionStepType.number, value: '7'),
        InspectionStep(
            label: 'Text', type: InspectionStepType.text, value: 'df'),
      ],
      notes: 'Kjbkj',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paged = _pagedInspections;
    final filteredCount = _filteredInspections.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                  onPressed: () {
                    // Hook up to create-inspection flow later.
                  },
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
            InspectionStatsSection(stats: _stats),
            const SizedBox(height: 20),
            InspectionSearchBar(
              controller: _searchController,
              onChanged: (_) => setState(() => _currentPage = 1),
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
                  '$filteredCount results',
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (paged.isEmpty)
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
              for (int i = 0; i < paged.length; i++) ...[
                InspectionListCard(
                  inspection: paged[i],
                  onTap: () => _openDetail(paged[i]),
                ),
                if (i != paged.length - 1) const SizedBox(height: 12),
              ],
            const SizedBox(height: 20),
            InspectionPagination(
              currentPage: _currentPage,
              totalPages: _totalPages,
              itemsPerPage: _itemsPerPage,
              totalItems: filteredCount,
              onPageSelected: (page) => setState(() => _currentPage = page),
            ),
          ],
        ),
      ),
    );
  }
}

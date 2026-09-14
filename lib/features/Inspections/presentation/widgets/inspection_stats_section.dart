import 'package:flutter/material.dart';
import '../../data/models/inspection_models.dart';

/// Summary cards at the top of the inspections list. Status boxes are
/// driven by the API `statusCounts` list and only shown when count > 0.
class InspectionStatsSection extends StatelessWidget {
  final InspectionStats stats;
  final String? selectedStatus;
  final ValueChanged<String?>? onStatusSelected;

  const InspectionStatsSection({
    super.key,
    required this.stats,
    this.selectedStatus,
    this.onStatusSelected,
  });

  bool _isSelected(String? statusLabel) {
    final selected = (selectedStatus ?? '').trim().toLowerCase();
    if (selected.isEmpty || selected == 'all') {
      return statusLabel == null;
    }
    return selected == (statusLabel ?? '').trim().toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final visibleCounts = stats.visibleStatusCounts;
    final rows = <List<InspectionStatusCount>>[];
    for (var i = 0; i < visibleCounts.length; i += 2) {
      rows.add(visibleCounts.sublist(
        i,
        i + 2 > visibleCounts.length ? visibleCounts.length : i + 2,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (stats.total > 0) ...[
          _AllInspectionsCard(
            count: stats.total,
            selected: _isSelected(null),
            onTap: onStatusSelected == null
                ? null
                : () => onStatusSelected!(null),
          ),
          if (rows.isNotEmpty || stats.byEmployee.isNotEmpty)
            const SizedBox(height: 12),
        ],
        for (var i = 0; i < rows.length; i++) ...[
          _StatusCountRow(
            items: rows[i],
            selectedStatus: selectedStatus,
            onStatusSelected: onStatusSelected,
          ),
          if (i != rows.length - 1 || stats.byEmployee.isNotEmpty)
            const SizedBox(height: 12),
        ],
        if (stats.byEmployee.isNotEmpty)
          _ByEmployeeCard(entries: stats.byEmployee),
      ],
    );
  }
}

class _StatusCountRow extends StatelessWidget {
  final List<InspectionStatusCount> items;
  final String? selectedStatus;
  final ValueChanged<String?>? onStatusSelected;

  const _StatusCountRow({
    required this.items,
    this.selectedStatus,
    this.onStatusSelected,
  });

  bool _isSelected(String label) {
    final selected = (selectedStatus ?? '').trim().toLowerCase();
    if (selected.isEmpty || selected == 'all') return false;
    return selected == label.trim().toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    if (items.length == 1) {
      return _StatCard(
        item: items.first,
        fullWidth: true,
        selected: _isSelected(items.first.label),
        onTap: onStatusSelected == null
            ? null
            : () => onStatusSelected!(items.first.label),
      );
    }

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(
            child: _StatCard(
              item: items[i],
              selected: _isSelected(items[i].label),
              onTap: onStatusSelected == null
                  ? null
                  : () => onStatusSelected!(items[i].label),
            ),
          ),
          if (i != items.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _AllInspectionsCard extends StatelessWidget {
  final int count;
  final bool selected;
  final VoidCallback? onTap;

  const _AllInspectionsCard({
    required this.count,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1E40),
            borderRadius: BorderRadius.circular(16),
            border: selected
                ? Border.all(color: const Color(0xFF60A5FA), width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'All inspections',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Across every asset',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final InspectionStatusCount item;
  final bool fullWidth;
  final bool selected;
  final VoidCallback? onTap;

  const _StatCard({
    required this.item,
    this.fullWidth = false,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = item.status;
    final textColor = status.foregroundColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: status.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? textColor : status.borderColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(status.icon, color: textColor, size: 22),
                  if (fullWidth)
                    Text(
                      '${item.count}',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!fullWidth)
                    Text(
                      '${item.count}',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                status.subtitle,
                style:
                    TextStyle(color: textColor.withOpacity(0.8), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ByEmployeeCard extends StatelessWidget {
  final List<EmployeeInspectionCount> entries;

  const _ByEmployeeCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    final maxCount = entries.isEmpty
        ? 1
        : entries.map((e) => e.count).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people_outline, color: Color(0xFF374151), size: 20),
              SizedBox(width: 8),
              Text(
                'Inspections by employee',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < entries.length; i++) ...[
            _EmployeeBar(
              entry: entries[i],
              ratio: maxCount == 0 ? 0 : entries[i].count / maxCount,
              isFirst: i == 0,
            ),
            if (i != entries.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _EmployeeBar extends StatelessWidget {
  final EmployeeInspectionCount entry;
  final double ratio;
  final bool isFirst;

  const _EmployeeBar({
    required this.entry,
    required this.ratio,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final barColor =
        isFirst ? const Color(0xFFF59E0B) : const Color(0xFF2563EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              entry.name,
              style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
            ),
            Text(
              '${entry.count}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
      ],
    );
  }
}

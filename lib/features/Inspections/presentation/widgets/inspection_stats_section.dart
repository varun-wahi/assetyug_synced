import 'package:flutter/material.dart';
import '../../data/models/inspection_models.dart';

/// The block of summary cards at the top of the inspections list:
/// the big navy "All inspections" card, the pending/ongoing pair,
/// the green "Completed" card, and the "Inspections by employee" bars.
class InspectionStatsSection extends StatelessWidget {
  final InspectionStats stats;

  const InspectionStatsSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AllInspectionsCard(count: stats.total),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFF8A5A14),
                backgroundColor: const Color(0xFFFDECC8),
                count: stats.pending,
                title: 'Pending',
                subtitle: 'Awaiting action',
                textColor: const Color(0xFF8A5A14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.sync_rounded,
                iconColor: const Color(0xFF1D4ED8),
                backgroundColor: const Color(0xFFDCEAFE),
                count: stats.ongoing,
                title: 'Ongoing',
                subtitle: 'In progress now',
                textColor: const Color(0xFF1D4ED8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatCard(
          icon: Icons.check_rounded,
          iconColor: const Color(0xFF3A6B23),
          backgroundColor: const Color(0xFFDDEAD2),
          count: stats.completed,
          title: 'Completed',
          subtitle: 'Finished inspections',
          textColor: const Color(0xFF3A6B23),
          fullWidth: true,
        ),
        const SizedBox(height: 12),
        _ByEmployeeCard(entries: stats.byEmployee),
      ],
    );
  }
}

class _AllInspectionsCard extends StatelessWidget {
  final int count;

  const _AllInspectionsCard({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1E40),
        borderRadius: BorderRadius.circular(16),
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
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color textColor;
  final int count;
  final String title;
  final String subtitle;
  final bool fullWidth;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.textColor,
    required this.count,
    required this.title,
    required this.subtitle,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 22),
              if (fullWidth)
                Text(
                  '$count',
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
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!fullWidth)
                Text(
                  '$count',
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
            subtitle,
            style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12),
          ),
        ],
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
          Row(
            children: [
              const Icon(Icons.people_outline,
                  color: Color(0xFF374151), size: 20),
              const SizedBox(width: 8),
              const Text(
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
    // First bar (highest count in the mockup) is highlighted orange,
    // the rest are blue — matching the screenshot's "Unassigned" emphasis.
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

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../data/models/inspection_models.dart';
import 'status_badge.dart';

/// Helper to present [InspectionDetailWidget] as a modal bottom sheet,
/// matching the floating-card look in the second mockup. Call this from
/// wherever a row/card is tapped.
Future<void> showInspectionDetail(
    BuildContext context, InspectionDetail detail) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: InspectionDetailWidget(
        detail: detail,
        onClose: () => Navigator.of(context).pop(),
      ),
    ),
  );
}

/// Self-contained inspection detail card matching the second mockup:
/// navy header with template name/status/close icon, a two-column grid
/// of asset metadata, a created/due row, the inspection steps list, and
/// a notes box. Independent of [InspectionsPage] — feed it any
/// [InspectionDetail] and it renders on its own.
class InspectionDetailWidget extends StatelessWidget {
  final InspectionDetail detail;
  final VoidCallback? onClose;

  const InspectionDetailWidget({
    super.key,
    required this.detail,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(detail: detail, onClose: onClose),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetadataGrid(detail: detail),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 16),
                  _DateRow(detail: detail),
                  const SizedBox(height: 20),
                  const Text(
                    'Inspection steps',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _StepsList(steps: detail.steps),
                  const SizedBox(height: 20),
                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      detail.notes,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF111827)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final InspectionDetail detail;
  final VoidCallback? onClose;

  const _Header({required this.detail, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      decoration: const BoxDecoration(color: Color(0xFF0B1E40)),
      child: Row(
        children: [
          Text(
            detail.templateName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          StatusBadge(status: detail.status),
          const Spacer(),
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataGrid extends StatelessWidget {
  final InspectionDetail detail;

  const _MetadataGrid({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Field(label: 'Asset', value: detail.assetName)),
            Expanded(
                child:
                    _Field(label: 'Serial number', value: detail.serialNumber)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Field(label: 'Category', value: detail.category)),
            Expanded(child: _Field(label: 'Customer', value: detail.customer)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Field(label: 'Location', value: detail.location)),
            Expanded(
                child:
                    _Field(label: 'Performed by', value: detail.performedBy)),
          ],
        ),
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  final InspectionDetail detail;

  const _DateRow({required this.detail});

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('MMM d, yyyy, h:mm a');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Field(
              label: 'Created',
              value: format.format(detail.createdAt),
              small: true),
        ),
        Expanded(
          child: _Field(
              label: 'Due', value: format.format(detail.dueAt), small: true),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final bool small;

  const _Field({required this.label, required this.value, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: small ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

class _StepsList extends StatelessWidget {
  final List<InspectionStep> steps;

  const _StepsList({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          for (int i = 0; i < steps.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: i == steps.length - 1
                    ? null
                    : const Border(
                        bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${i + 1}. ${steps[i].label}',
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF111827)),
                  ),
                  _StepValue(step: steps[i]),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StepValue extends StatelessWidget {
  final InspectionStep step;

  const _StepValue({required this.step});

  @override
  Widget build(BuildContext context) {
    switch (step.type) {
      case InspectionStepType.checkbox:
        final checked = step.value.toLowerCase() == 'true';
        return Icon(
          checked ? Icons.check_box : Icons.check_box_outline_blank,
          color: checked ? const Color(0xFF1D4ED8) : const Color(0xFF9CA3AF),
          size: 22,
        );
      case InspectionStepType.number:
      case InspectionStepType.text:
        return Text(
          step.value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        );
    }
  }
}

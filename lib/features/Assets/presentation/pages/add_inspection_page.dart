import 'dart:convert';

import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/widgets/inspection_form_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/inspection models/asset_inspection_instance__model.dart';
import '../../data/models/inspection models/inspection_step_model.dart';
import '../../data/models/inspection models/inspection_template_model.dart';

final assetsRepositoryProvider =
    Provider<AssetsRepositoryImpl>((ref) => AssetsRepositoryImpl());

class AddInspectionPage extends ConsumerStatefulWidget {
  final String assetId;
  final String companyId;
  final List<AssetInspectionTemplateModel> availableTemplates;

  // EDIT MODE
  final AssetInspectionInstanceModel? existingInspection;

  const AddInspectionPage({
    super.key,
    required this.assetId,
    required this.companyId,
    required this.availableTemplates,
    this.existingInspection,
  });

  @override
  ConsumerState<AddInspectionPage> createState() => _AddInspectionPageState();
}

class _AddInspectionPageState extends ConsumerState<AddInspectionPage> {
  final TextEditingController _notesController = TextEditingController();
  bool get isReadOnly => widget.existingInspection?.status == 'COMPLETED';

  final TextEditingController _performedByController = TextEditingController();

  List<AssetInspectionTemplateModel> selectedTemplates = [];

  Map<String, dynamic> fieldValues = {};

  bool isSubmitting = false;

  bool get isEditMode => widget.existingInspection != null;

  @override
  void initState() {
    super.initState();

    _prefillData();
  }

  void _prefillData() {
    final existing = widget.existingInspection;

    if (existing == null) return;

    _performedByController.text = existing.actionPerformedBy;

    _notesController.text = existing.notes;

    // PREFILL TEMPLATES
    selectedTemplates = widget.availableTemplates.where((template) {
      return existing.selectedItemList.any(
        (item) => item.id == template.id,
      );
    }).toList();

    // PREFILL STEP VALUES
    for (final step in existing.stepValues) {
      final key = '${step.name}_${step.type}';

      fieldValues[key] = step.value;
    }

    setState(() {});
  }

  void _showTemplateSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Select Inspections',
            style: body(
              weight: FontWeight.w600,
              size: 15,
            ),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.availableTemplates.length,
              itemBuilder: (context, index) {
                final template = widget.availableTemplates[index];

                final isSelected = selectedTemplates.contains(
                  template,
                );

                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      setDialogState(() {
                        if (value == true) {
                          selectedTemplates.add(
                            template,
                          );
                        } else {
                          selectedTemplates.remove(
                            template,
                          );
                        }
                      });
                    },
                    title: Text(
                      template.name,
                      style: body(),
                    ),
                    subtitle: Text(
                      '${template.steps.length} steps',
                      style: body(
                        size: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: body(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: tPrimary,
                foregroundColor: tWhite,
              ),
              child: Text(
                'Done',
                style: body(color: tWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<InspectionStepModel> _getAllSteps() {
    final List<InspectionStepModel> allSteps = [];

    for (var template in selectedTemplates) {
      allSteps.addAll(template.steps);
    }

    return allSteps;
  }

  Future<void> _submitInspection(
    String status,
  ) async {
    if (selectedTemplates.isEmpty) {
      dSnackBar(
        context,
        'Please select at least one inspection template',
        TypeSnackbar.warning,
      );
      return;
    }

    if (_performedByController.text.trim().isEmpty) {
      dSnackBar(
        context,
        'Please enter who performed the inspection',
        TypeSnackbar.warning,
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final now = DateTime.now().toUtc().toIso8601String();

      final allSteps = _getAllSteps();

      final stepValues = allSteps.map((step) {
        final key = '${step.name}_${step.type}';

        return {
          'name': step.name,
          'inspectionStepId': step.inspectionStepId,
          'value': fieldValues[key] ?? (step.type == 'CHECKBOX' ? false : ''),
          'type': step.type,
        };
      }).toList();

      final inspectionTemplates = selectedTemplates.map((template) {
        return {
          'inspectionName': template.name,
          'stepValues': template.steps.map((step) {
            final key = '${step.name}_${step.type}';

            return {
              'name': step.name,
              'inspectionStepId': step.inspectionStepId,
              'value':
                  fieldValues[key] ?? (step.type == 'CHECKBOX' ? false : ''),
              'type': step.type,
            };
          }).toList(),
        };
      }).toList();

      final selectedItemList = selectedTemplates.map((template) {
        return {
          'id': template.id,
          'name': template.name,
        };
      }).toList();

      final payload = {
        if (isEditMode) 'id': widget.existingInspection!.id,
        if (isEditMode)
          'assetCategoryInspectionInstanceId':
              widget.existingInspection!.assetCategoryInspectionId,
        'assetId': widget.assetId,
        'companyId': widget.companyId,
        'assetCategoryInspectionName':
            selectedTemplates.map((t) => t.name).join(', '),
        'actionPerformedBy': _performedByController.text.trim(),
        'notes': _notesController.text.trim(),
        'createdAt': isEditMode ? widget.existingInspection!.createdAt : now,
        'updatedAt': now,
        'status': status,
        'stepValues': stepValues,
        'inspectionTemplates': inspectionTemplates,
        'selectedItemList': selectedItemList,
      };

      print(
        "PAYLOAD: ${jsonEncode(payload)}",
      );

      final repository = ref.read(assetsRepositoryProvider);

      final response = await repository.addAssetInspectionInstance(
        payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        dSnackBar(
          context,
          isEditMode
              ? 'Inspection updated successfully'
              : 'Inspection ${status == 'PENDING' ? 'saved' : 'submitted'} successfully',
          TypeSnackbar.success,
        );

        Navigator.pop(context, true);
      } else {
        throw Exception(
          'Failed to save inspection: ${response.statusCode}',
        );
      }
    } catch (e) {
      dSnackBar(
        context,
        'Error saving inspection: $e',
        TypeSnackbar.error,
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allSteps = _getAllSteps();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Inspection' : 'Add Inspection',
          style: body(
            weight: FontWeight.w600,
            size: 15,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(dPadding * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: isEditMode ? null : _showTemplateSelectionDialog,
                  icon: const Icon(Icons.checklist),
                  label: Text(
                    selectedTemplates.isEmpty
                        ? 'Select Inspections'
                        : '${selectedTemplates.length} inspection(s) selected',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tPrimary,
                    foregroundColor: tWhite,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                if (selectedTemplates.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Selected Inspections:',
                    style: body(
                      weight: FontWeight.w600,
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...selectedTemplates.map(
                    (template) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 4,
                      ),
                      child: Text(
                        '• ${template.name}',
                        style: body(
                          size: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                TextFormField(
                  enabled: !isReadOnly,
                  controller: _performedByController,
                  decoration: InputDecoration(
                    labelText: 'Performed By *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  enabled: !isReadOnly,
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                    ),
                  ),
                ),
                if (allSteps.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Inspection Fields',
                    style: body(
                      weight: FontWeight.w600,
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...allSteps.map((step) {
                    final key = '${step.name}_${step.type}';

                    return InspectionFormField(
                      step: step,
                      isReadOnly: isReadOnly,

                      // IMPORTANT
                      initialValue: fieldValues[key],

                      onValueChanged: (value) {
                        fieldValues[key] = value;
                      },
                    );
                  }),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
          if (isSubmitting)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: dPadding,
            vertical: dPadding * 2,
          ),
          decoration: BoxDecoration(
            color: tWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                  child: Text(
                    'Cancel',
                    style: body(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () => _submitInspection(
                            'PENDING',
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: tBlack,
                    minimumSize: const Size(0, 48),
                  ),
                  child: Text(
                    'Save',
                    style: body(color: tWhite),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () => _submitInspection(
                            'COMPLETED',
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tPrimary,
                    foregroundColor: tWhite,
                    minimumSize: const Size(0, 48),
                  ),
                  child: Text(
                    isEditMode ? 'Update' : 'Submit',
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

  @override
  void dispose() {
    _notesController.dispose();
    _performedByController.dispose();
    super.dispose();
  }
}

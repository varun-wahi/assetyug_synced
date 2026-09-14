import 'dart:convert';

import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_dropdown.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/riverpod/technical_users_provider.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/widgets/inspection_form_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../data/models/inspection models/asset_inspection_instance__model.dart';
import '../../data/models/inspection models/inspection_step_model.dart';
import '../../data/models/inspection models/inspection_template_model.dart';

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
  bool _isAdmin = false;

  /// Completed inspections are read-only for non-admins; ADMIN can still edit/save.
  bool get isReadOnly =>
      widget.existingInspection?.status == 'COMPLETED' && !_isAdmin;

  String? _selectedPerformer;
  DateTime? _dueDate;

  List<AssetInspectionTemplateModel> selectedTemplates = [];

  Map<String, dynamic> fieldValues = {};

  bool isSubmitting = false;

  bool get isEditMode => widget.existingInspection != null;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _prefillData();
  }

  Future<void> _loadUserRole() async {
    final box = await Hive.openBox('auth_data');
    final role = box.get('role')?.toString().toUpperCase();
    if (!mounted) return;
    setState(() => _isAdmin = role == 'ADMIN');
  }

  void _prefillData() {
    final existing = widget.existingInspection;

    if (existing == null) return;

    _selectedPerformer = existing.actionPerformedBy;

    _notesController.text = existing.notes;

    if (existing.dueDate.isNotEmpty) {
      _dueDate = DateTime.tryParse(existing.dueDate)?.toLocal();
    }

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setDialogState(() {
                        final allSelected = selectedTemplates.length ==
                            widget.availableTemplates.length;
                        selectedTemplates
                          ..clear()
                          ..addAll(
                            allSelected ? [] : widget.availableTemplates,
                          );
                      });
                    },
                    child: Text(
                      selectedTemplates.length ==
                              widget.availableTemplates.length
                          ? 'Deselect all'
                          : 'Select all',
                      style: body(color: tPrimary, weight: FontWeight.w600),
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.availableTemplates.length,
                    itemBuilder: (context, index) {
                      final template = widget.availableTemplates[index];

                      final isSelected = selectedTemplates.any(
                        (item) => item.id == template.id,
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
                                if (!selectedTemplates
                                    .any((item) => item.id == template.id)) {
                                  selectedTemplates.add(template);
                                }
                              } else {
                                selectedTemplates.removeWhere(
                                  (item) => item.id == template.id,
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
              ],
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

  List<Widget> _buildGroupedTemplateSteps() {
    return [
      for (int templateIndex = 0;
          templateIndex < selectedTemplates.length;
          templateIndex++) ...[
        _buildTemplateSection(selectedTemplates[templateIndex]),
        if (templateIndex != selectedTemplates.length - 1)
          const SizedBox(height: 16),
      ],
    ];
  }

  Widget _buildTemplateSection(AssetInspectionTemplateModel template) {
    final steps = template.steps;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tPrimary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Text(
              'Inspection Name : ${template.name}',
              style: body(weight: FontWeight.w600, size: 14, color: tWhite),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            decoration: BoxDecoration(
              color: tWhite,
              borderRadius: BorderRadius.circular(8),
            ),
            child: steps.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'No steps in this template',
                      style: body(size: 13, color: Colors.grey),
                    ),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < steps.length; i++) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                          child: InspectionFormField(
                            step: steps[i],
                            isReadOnly: isReadOnly,
                            initialValue: fieldValues[
                                '${steps[i].name}_${steps[i].type}'],
                            onValueChanged: (value) {
                              fieldValues[
                                  '${steps[i].name}_${steps[i].type}'] = value;
                            },
                          ),
                        ),
                        if (i != steps.length - 1)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: tGreyLight,
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
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

    if ((_selectedPerformer ?? '').trim().isEmpty) {
      dSnackBar(
        context,
        'Please select who performed the inspection',
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
        'actionPerformedBy': _selectedPerformer!.trim(),
        'notes': _notesController.text.trim(),
        'createdAt': isEditMode ? widget.existingInspection!.createdAt : now,
        'updatedAt': now,
        'dueDate': _dueDate == null
            ? null
            : DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day)
                .toUtc()
                .toIso8601String(),
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
                _buildInspectionsDropdown(),
                if (selectedTemplates.isNotEmpty) ...[
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
                    ..._buildGroupedTemplateSteps(),
                  ],
                  const SizedBox(height: 24),
                  _buildDueDateField(),
                  const SizedBox(height: 16),
                  _buildPerformedByDropdown(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      enabled: !isReadOnly,
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
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
      bottomNavigationBar: isReadOnly
          ? null
          : SafeArea(
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

  Widget _buildInspectionsDropdown() {
    final label = selectedTemplates.isEmpty
        ? 'Select Inspections'
        : selectedTemplates.length == 1
            ? selectedTemplates.first.name
            : '${selectedTemplates.length} inspections selected';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: isEditMode || isReadOnly ? null : _showTemplateSelectionDialog,
        borderRadius: BorderRadius.circular(10),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Select Inspections*',
            enabled: !isEditMode && !isReadOnly,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: tBlack),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: tBlack),
            ),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          child: Text(
            label,
            style: body(
              color: selectedTemplates.isEmpty ? Colors.grey : tBlack,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    if (isReadOnly) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Widget _buildDueDateField() {
    final label = _dueDate == null
        ? 'Select due date'
        : DateFormat('MM/dd/yyyy').format(_dueDate!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: isReadOnly ? null : _pickDueDate,
        borderRadius: BorderRadius.circular(10),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Due Date',
            enabled: !isReadOnly,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: tBlack),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: tBlack),
            ),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          child: Text(
            label,
            style: body(
              color: _dueDate == null ? Colors.grey : tBlack,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerformedByDropdown() {
    final usersAsync = ref.watch(technicalUsersProvider(widget.companyId));

    return usersAsync.when(
      data: (users) {
        if (users.isNotEmpty &&
            (_selectedPerformer == null ||
                !users.contains(_selectedPerformer))) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _selectedPerformer = users.first);
          });
        }

        return IgnorePointer(
          ignoring: isReadOnly,
          child: DDropdown(
            label: 'Performed By',
            isMandatory: true,
            value:
                users.contains(_selectedPerformer) ? _selectedPerformer : null,
            items: users
                .map(
                    (name) => DropdownMenuItem(value: name, child: Text(name)))
                .toList(),
            onChanged: (value) => setState(() => _selectedPerformer = value),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Text('Error loading technical users'),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

import 'dart:convert';

import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/widgets/async_dropdown_search_widget.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_dropdown.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_text_field.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/add_asset_page.dart';
import 'package:asset_yug_debugging/features/Customers/data/repository/company_customer_repository_impl.dart';
import 'package:asset_yug_debugging/features/Inspections/presentation/widgets/inspection_filter_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<InspectionFilterData?> showInspectionAdvancedFilterSheet({
  required BuildContext context,
  required String companyId,
  required InspectionFilterData initialData,
}) {
  return showModalBottomSheet<InspectionFilterData>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: tWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: InspectionAdvancedFilterSheet(
          companyId: companyId,
          initialData: initialData,
        ),
      );
    },
  );
}

class InspectionAdvancedFilterSheet extends StatefulWidget {
  final String companyId;
  final InspectionFilterData initialData;

  const InspectionAdvancedFilterSheet({
    super.key,
    required this.companyId,
    required this.initialData,
  });

  @override
  State<InspectionAdvancedFilterSheet> createState() =>
      _InspectionAdvancedFilterSheetState();
}

class _InspectionAdvancedFilterSheetState
    extends State<InspectionAdvancedFilterSheet> {
  late final TextEditingController _assetNameController;
  late final TextEditingController _assetCustomerController;
  late final TextEditingController _serialController;
  late final TextEditingController _assetIdController;

  String? _inspectionName;
  String? _status;
  String? _performedBy;
  String _sortField = 'createdAt';
  String _sortDirection = 'DESC';

  Map<String, dynamic>? _selectedCustomer;
  String? _customerCategory;
  String? _assetCategory;
  LocationBinOption? _selectedLocation;

  DateTimeRange? _createdRange;
  DateTimeRange? _dueRange;

  bool _loadingOptions = true;
  String? _optionsError;

  List<String> _templates = [];
  List<String> _performers = [];
  List<Map<String, dynamic>> _customers = [];
  List<String> _customerCategories = [];
  List<String> _assetCategories = [];
  List<LocationBinOption> _locations = [];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;

    _assetNameController = TextEditingController(text: initial.assetName ?? '');
    _assetCustomerController =
        TextEditingController(text: initial.assetCustomer ?? '');
    _serialController =
        TextEditingController(text: initial.serialNumber ?? '');
    _assetIdController = TextEditingController(text: initial.assetId ?? '');

    _inspectionName = initial.inspectionName;
    _status = (initial.status == null || initial.status!.isEmpty)
        ? 'All'
        : initial.status;
    _performedBy = initial.performedBy;
    _sortField = initial.sortField;
    _sortDirection = initial.sortDirection;
    _customerCategory = initial.customerCategory;
    _assetCategory = initial.assetCategory;

    if (initial.customerId != null && initial.customerId!.isNotEmpty) {
      _selectedCustomer = {
        'id': initial.customerId,
        'name': initial.customerName ?? initial.customerId,
      };
    }

    if (initial.createdDateFrom != null || initial.createdDateTo != null) {
      _createdRange = DateTimeRange(
        start: initial.createdDateFrom ?? initial.createdDateTo!,
        end: initial.createdDateTo ?? initial.createdDateFrom!,
      );
    }
    if (initial.dueDateFrom != null || initial.dueDateTo != null) {
      _dueRange = DateTimeRange(
        start: initial.dueDateFrom ?? initial.dueDateTo!,
        end: initial.dueDateTo ?? initial.dueDateFrom!,
      );
    }

    _loadOptions();
  }

  @override
  void dispose() {
    _assetNameController.dispose();
    _assetCustomerController.dispose();
    _serialController.dispose();
    _assetIdController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    setState(() {
      _loadingOptions = true;
      _optionsError = null;
    });

    try {
      final assetsRepo = AssetsRepositoryImpl();
      final customerRepo = CompanyCustomerRepositoryImpl();

      final results = await Future.wait([
        assetsRepo.getAllAssetInspections(widget.companyId),
        assetsRepo.getActiveUsers(widget.companyId),
        customerRepo.getCompanyCustomer(widget.companyId),
        customerRepo.getActiveCustomerCategories(widget.companyId),
        assetsRepo.getActiveCategories(widget.companyId),
        customerRepo.getCustomerLocationsAndBins(widget.companyId),
      ]);

      final templatesRes = results[0];
      final usersRes = results[1];
      final customersRes = results[2];
      final customerCatsRes = results[3];
      final assetCatsRes = results[4];
      final locationsRes = results[5];

      final templates = <String>[];
      if (templatesRes.statusCode == 200 && templatesRes.body.isNotEmpty) {
        final decoded = jsonDecode(templatesRes.body);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map && item['name'] != null) {
              final name = item['name'].toString().trim();
              if (name.isNotEmpty) templates.add(name);
            }
          }
        }
      }

      final performers = <String>[];
      if (usersRes.statusCode == 200 && usersRes.body.isNotEmpty) {
        final decoded = jsonDecode(usersRes.body);
        if (decoded is List) {
          for (final user in decoded) {
            if (user is Map) {
              final first = (user['firstName'] ?? '').toString().trim();
              final last = (user['lastName'] ?? '').toString().trim();
              final full = '$first $last'.trim();
              if (full.isNotEmpty) performers.add(full);
            }
          }
        }
      }

      final customers = <Map<String, dynamic>>[];
      if (customersRes.statusCode == 200 && customersRes.body.isNotEmpty) {
        final decoded = jsonDecode(customersRes.body);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              customers.add(item);
            } else if (item is Map) {
              customers.add(Map<String, dynamic>.from(item));
            }
          }
        }
      }

      final customerCategories = <String>[];
      if (customerCatsRes.statusCode == 200 &&
          customerCatsRes.body.isNotEmpty) {
        final decoded = jsonDecode(customerCatsRes.body);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map && item['name'] != null) {
              final name = item['name'].toString().trim();
              if (name.isNotEmpty) customerCategories.add(name);
            }
          }
        }
      }

      final assetCategories = <String>[];
      if (assetCatsRes.statusCode == 200 && assetCatsRes.body.isNotEmpty) {
        final decoded = jsonDecode(assetCatsRes.body);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map && item['name'] != null) {
              final name = item['name'].toString().trim();
              if (name.isNotEmpty) assetCategories.add(name);
            }
          }
        }
      }

      final locations = <LocationBinOption>[];
      if (locationsRes.statusCode == 200 && locationsRes.body.isNotEmpty) {
        final decoded = jsonDecode(locationsRes.body);
        if (decoded is List) {
          for (final location in decoded) {
            if (location is! Map) continue;
            final locId = location['id']?.toString() ?? '';
            final locName = location['name']?.toString() ?? '';
            if (locId.isEmpty || locName.isEmpty) continue;

            locations.add(LocationBinOption(
              locationId: locId,
              binId: null,
              label: locName,
            ));

            final bins = location['bins'];
            if (bins is List) {
              for (final bin in bins) {
                if (bin is! Map) continue;
                final binId = bin['id']?.toString();
                final binNumber = bin['binNumber']?.toString() ?? '';
                if (binId == null || binId.isEmpty) continue;
                locations.add(LocationBinOption(
                  locationId: locId,
                  binId: binId,
                  label: '$locName -> $binNumber',
                ));
              }
            }
          }
        }
      }

      // Restore selected location from initial payload value.
      LocationBinOption? selectedLocation;
      final initialLocation = widget.initialData.assetLocation;
      if (initialLocation != null && initialLocation.isNotEmpty) {
        for (final opt in locations) {
          final matches = opt.binId != null
              ? initialLocation == 'bin:${opt.binId}'
              : initialLocation == 'location:${opt.locationId}';
          if (matches) {
            selectedLocation = opt;
            break;
          }
        }
        if (selectedLocation == null) {
          final label = widget.initialData.assetLocationLabel;
          if (label != null && label.isNotEmpty) {
            selectedLocation = LocationBinOption(
              locationId: 'unknown',
              label: label,
            );
          }
        }
      }

      // Restore customer object from loaded list when possible.
      Map<String, dynamic>? selectedCustomer = _selectedCustomer;
      final customerId = widget.initialData.customerId;
      if (customerId != null && customerId.isNotEmpty) {
        for (final customer in customers) {
          if (customer['id']?.toString() == customerId) {
            selectedCustomer = customer;
            break;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _templates = templates;
        _performers = performers;
        _customers = customers;
        _customerCategories = customerCategories;
        _assetCategories = assetCategories;
        _locations = locations;
        _selectedLocation = selectedLocation;
        _selectedCustomer = selectedCustomer;
        _loadingOptions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingOptions = false;
        _optionsError = e.toString();
      });
    }
  }

  InspectionFilterData _buildFilterData() {
    String? locationValue;
    String? locationLabel;
    final loc = _selectedLocation;
    if (loc != null) {
      locationLabel = loc.label;
      if (loc.binId != null && loc.binId!.isNotEmpty) {
        locationValue = 'bin:${loc.binId}';
      } else if (loc.locationId.isNotEmpty && loc.locationId != 'unknown') {
        locationValue = 'location:${loc.locationId}';
      }
    }

    return InspectionFilterData(
      inspectionName: _inspectionName,
      status: _status,
      performedBy: _performedBy,
      sortField: _sortField,
      sortDirection: _sortDirection,
      customerId: _selectedCustomer?['id']?.toString(),
      customerName: _selectedCustomer?['name']?.toString(),
      customerCategory: _customerCategory,
      assetName: _assetNameController.text.trim(),
      assetCustomer: _assetCustomerController.text.trim(),
      serialNumber: _serialController.text.trim(),
      assetId: _assetIdController.text.trim(),
      assetCategory: _assetCategory,
      assetLocation: locationValue,
      assetLocationLabel: locationLabel,
      createdDateFrom: _createdRange?.start,
      createdDateTo: _createdRange?.end,
      dueDateFrom: _dueRange?.start,
      dueDateTo: _dueRange?.end,
    );
  }

  void _resetFilters() {
    setState(() {
      _inspectionName = null;
      _status = 'All';
      _performedBy = null;
      _sortField = 'createdAt';
      _sortDirection = 'DESC';
      _selectedCustomer = null;
      _customerCategory = null;
      _assetCategory = null;
      _selectedLocation = null;
      _createdRange = null;
      _dueRange = null;
      _assetNameController.clear();
      _assetCustomerController.clear();
      _serialController.clear();
      _assetIdController.clear();
    });
  }

  void _applyFilters() {
    Navigator.pop(context, _buildFilterData());
  }

  Future<void> _pickCreatedRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _createdRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: tPrimary,
              onPrimary: tWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _createdRange = picked);
  }

  Future<void> _pickDueRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _dueRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: tPrimary,
              onPrimary: tWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dueRange = picked);
  }

  String _formatRange(DateTimeRange? range) {
    if (range == null) return '';
    final fmt = DateFormat('M/d/yyyy');
    return '${fmt.format(range.start)} - ${fmt.format(range.end)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _loadingOptions
              ? const Center(child: CircularProgressIndicator())
              : _optionsError != null
                  ? _buildErrorState()
                  : _buildForm(),
        ),
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Text('Add Filter', style: boldHeading(size: 20)),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3F4F6),
            ),
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Could not load filter options',
              style: body(weight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _optionsError ?? '',
              style: body(size: 12, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: _loadOptions, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          _buildSection(
            title: 'INSPECTION',
            child: Column(
              children: [
                _stringDropdown(
                  label: 'Inspection Template',
                  value: _inspectionName,
                  items: _templates,
                  onChanged: (v) => setState(() => _inspectionName = v),
                ),
                DDropdown(
                  label: 'Status',
                  value: _status,
                  items: kInspectionStatusOptions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _status = v?.toString()),
                ),
                _stringDropdown(
                  label: 'Performed By',
                  value: _performedBy,
                  items: _performers,
                  onChanged: (v) => setState(() => _performedBy = v),
                ),
                DDropdown(
                  label: 'Sort Field',
                  value: _sortField,
                  items: kInspectionSortFields
                      .map((e) => DropdownMenuItem(
                            value: e.value,
                            child: Text(e.key),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _sortField = v.toString());
                  },
                ),
                DDropdown(
                  label: 'Sort Direction',
                  value: _sortDirection,
                  items: kInspectionSortDirections
                      .map((e) => DropdownMenuItem(
                            value: e.value,
                            child: Text(e.key),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _sortDirection = v.toString());
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSection(
            title: 'CUSTOMER',
            child: Column(
              children: [
                AsyncDropdownField<Map<String, dynamic>>(
                  label: 'Customer',
                  asyncItemsFetcher: () async => _customers,
                  displayString: (c) => c['name']?.toString() ?? '',
                  selectedItem: _selectedCustomer,
                  compareFn: (a, b) =>
                      a['id']?.toString() == b['id']?.toString(),
                  onChanged: (value) => setState(() {
                    _selectedCustomer = value;
                  }),
                ),
                _stringDropdown(
                  label: 'Customer Category',
                  value: _customerCategory,
                  items: _customerCategories,
                  onChanged: (v) => setState(() => _customerCategory = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSection(
            title: 'ASSET',
            child: Column(
              children: [
                DTextField(
                  hintText: 'Asset Name',
                  hasLabel: true,
                  controller: _assetNameController,
                ),
                DTextField(
                  hintText: 'Asset Customer',
                  hasLabel: true,
                  controller: _assetCustomerController,
                ),
                DTextField(
                  hintText: 'Serial Number',
                  hasLabel: true,
                  controller: _serialController,
                ),
                DTextField(
                  hintText: 'Asset ID',
                  hasLabel: true,
                  controller: _assetIdController,
                ),
                _stringDropdown(
                  label: 'Asset Category',
                  value: _assetCategory,
                  items: _assetCategories,
                  onChanged: (v) => setState(() => _assetCategory = v),
                ),
                AsyncDropdownField<LocationBinOption>(
                  label: 'Asset Location',
                  asyncItemsFetcher: () async => _locations,
                  displayString: (loc) => loc.label,
                  selectedItem: _selectedLocation,
                  compareFn: (a, b) =>
                      a.locationId == b.locationId && a.binId == b.binId,
                  onChanged: (value) => setState(() {
                    _selectedLocation = value;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSection(
            title: 'DATE RANGES',
            child: Column(
              children: [
                _dateRangeField(
                  label: 'Created Date Range',
                  hint: 'Select created date range',
                  value: _formatRange(_createdRange),
                  onTap: _pickCreatedRange,
                  onClear: () => setState(() => _createdRange = null),
                ),
                _dateRangeField(
                  label: 'Due Date Range',
                  hint: 'Select due date range',
                  value: _formatRange(_dueRange),
                  onTap: _pickDueRange,
                  onClear: () => setState(() => _dueRange = null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      decoration: BoxDecoration(
        color: tWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _stringDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final effectiveValue =
        value != null && items.contains(value) ? value : null;

    return DDropdown(
      label: label,
      value: effectiveValue,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (v) => onChanged(v?.toString()),
    );
  }

  Widget _dateRangeField({
    required String label,
    required String hint,
    required String value,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: tBlack),
            ),
            suffixIcon: value.isEmpty
                ? const Icon(Icons.calendar_today_outlined, size: 18)
                : IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: onClear,
                  ),
          ),
          child: Text(
            value.isEmpty ? hint : value,
            style: body(
              size: 14,
              color: value.isEmpty ? Colors.grey : tBlack,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: tWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _resetFilters,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Reset', style: body(weight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _loadingOptions ? null : _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tPrimary,
                  foregroundColor: tWhite,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: body(color: tWhite, weight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

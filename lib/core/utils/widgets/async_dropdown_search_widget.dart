import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'form_field_decoration.dart';

class AsyncDropdownField<T> extends StatefulWidget {
  final String label;
  final Future<List<T>> Function() asyncItemsFetcher;
  final String Function(T) displayString;
  final void Function(T?) onChanged;
  final T? selectedItem;
  final String? hintText;
  final bool enabled;
  final bool isMandatory;
  final bool Function(T, T)? compareFn;
  final EdgeInsetsGeometry? padding;

  const AsyncDropdownField({
    super.key,
    required this.label,
    required this.asyncItemsFetcher,
    required this.displayString,
    required this.onChanged,
    this.selectedItem,
    this.hintText,
    this.enabled = true,
    this.isMandatory = false,
    this.compareFn,
    this.padding,
  });

  @override
  State<AsyncDropdownField<T>> createState() => _AsyncDropdownFieldState<T>();
}

class _AsyncDropdownFieldState<T> extends State<AsyncDropdownField<T>> {
  late final TextEditingController _searchController;
  List<T>? _cachedItems;
  // ignore: unused_field - reserved for future loading UI
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<T>> _getItems(String? filter) async {
    if (_cachedItems == null) {
      setState(() => _isLoading = true);
      try {
        _cachedItems = await widget.asyncItemsFetcher();
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }

    if (filter == null || filter.isEmpty) {
      return _cachedItems!;
    }

    return _cachedItems!.where((item) {
      final displayText = widget.displayString(item).toLowerCase();
      return displayText.contains(filter.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? FormFieldStyles.padding,
      child: DropdownSearch<T>(
        selectedItem: widget.selectedItem,
        items: (filter, loadProps) => _getItems(filter),
        itemAsString: widget.displayString,
        onChanged: widget.enabled ? widget.onChanged : null,
        compareFn: widget.compareFn ??
            (item1, item2) {
              return widget.displayString(item1) ==
                  widget.displayString(item2);
            },
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            controller: _searchController,
            style: FormFieldStyles.textStyle,
            decoration: FormFieldStyles.decoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          loadingBuilder: (context, _) => const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          ),
          emptyBuilder: (context, _) => const Padding(
            padding: EdgeInsets.all(12),
            child: Text('No items found'),
          ),
        ),
        decoratorProps: DropDownDecoratorProps(
          baseStyle: FormFieldStyles.textStyle,
          decoration: FormFieldStyles.decoration(
            label: FormFieldStyles.mandatoryLabel(
              widget.label,
              isMandatory: widget.isMandatory,
            ),
            hintText: widget.hintText,
            enabled: widget.enabled,
          ),
        ),
      ),
    );
  }
}

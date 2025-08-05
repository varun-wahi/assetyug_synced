import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AsyncDropdownField<T> extends StatefulWidget {
  final String label;
  final Future<List<T>> Function() asyncItemsFetcher;
  final String Function(T) displayString;
  final void Function(T?) onChanged;
  final T? selectedItem;
  final String? hintText;
  final bool enabled;
  final bool Function(T, T)? compareFn;

  const AsyncDropdownField({
    super.key,
    required this.label,
    required this.asyncItemsFetcher,
    required this.displayString,
    required this.onChanged,
    this.selectedItem,
    this.hintText,
    this.enabled = true,
    this.compareFn,
  });

  @override
  State<AsyncDropdownField<T>> createState() => _AsyncDropdownFieldState<T>();
}

class _AsyncDropdownFieldState<T> extends State<AsyncDropdownField<T>> {
  late final TextEditingController _searchController;
  List<T>? _cachedItems;
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
        setState(() => _isLoading = false);
      }
    }

    if (filter == null || filter.isEmpty) {
      return _cachedItems!;
    }

    // Filter items based on display string
    return _cachedItems!.where((item) {
      final displayText = widget.displayString(item).toLowerCase();
      return displayText.contains(filter.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      selectedItem: widget.selectedItem,
      items: (filter, loadProps) => _getItems(filter),
      itemAsString: widget.displayString,
      onChanged: widget.enabled ? widget.onChanged : null,
      compareFn: widget.compareFn ?? (item1, item2) {
        // Default comparison using display string
        return widget.displayString(item1) == widget.displayString(item2);
      },
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
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
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          enabled: widget.enabled,
        ),
      ),
    );
  }
}
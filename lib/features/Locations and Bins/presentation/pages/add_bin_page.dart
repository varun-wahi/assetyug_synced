// screens/add_bin_screen.dart
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/features/Locations%20and%20Bins/presentation/riverpod/location_bin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import your providers and models
// import '../providers/location_bin_providers.dart';
// import '../models/location_model.dart';

class AddBinScreen extends ConsumerStatefulWidget {
  final String companyId;

  const AddBinScreen({
    Key? key,
    required this.companyId,
  }) : super(key: key);

  @override
  ConsumerState<AddBinScreen> createState() => _AddBinScreenState();
}

class _AddBinScreenState extends ConsumerState<AddBinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _binNumberController = TextEditingController();
  
  String? _selectedLocationId;
  bool _isLoading = false;

  @override
  void dispose() {
    _binNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveBin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final binData = {
      'locationId': _selectedLocationId!,
      'binNumber': _binNumberController.text.trim(),
      'status': 'active',
      'companyId': widget.companyId,
    };

    try {
      final success = await ref
          .read(binsProvider(widget.companyId).notifier)
          .addBin(binData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bin added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add bin'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(locationsForDropdownProvider(widget.companyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bin'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  text: 'Bin Number ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _binNumberController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter bin number',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bin number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              RichText(
                text: const TextSpan(
                  text: 'Location ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLocationId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Location1',
                ),
                items: locations.map((location) => DropdownMenuItem<String>(
                  value: location.id,
                  child: Text(location.name),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLocationId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveBin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tPrimary
                        ,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
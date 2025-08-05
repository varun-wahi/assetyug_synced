import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/features/Locations%20and%20Bins/presentation/riverpod/location_bin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/bin_model.dart';

class BinCard extends ConsumerWidget {
  final BinModel bin;
  final String companyId;

  const BinCard({
    super.key,
    required this.bin,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Colors.grey.shade100,

      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(bin.binNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text('Location: ${bin.locationName}', style: const TextStyle(fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              bin.status.toUpperCase(),
              style: TextStyle(
                color: bin.status.toLowerCase() == 'active' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bin'),
        content: Text('Are you sure you want to delete bin ${bin.binNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteBin(ref);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBin(WidgetRef ref) async {
    final repository = ref.read(companyCustomerRepositoryProvider);
    final response = await repository.deleteBin(bin.id);
    
    if (response.statusCode == 200) {
      // Refresh the bins list
      ref.read(binsProvider(companyId).notifier).loadBins();
    }
  }
}
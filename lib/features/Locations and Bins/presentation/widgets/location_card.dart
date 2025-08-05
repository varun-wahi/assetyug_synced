// Updated LocationCard with delete functionality
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/features/Locations%20and%20Bins/presentation/riverpod/location_bin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/location_model.dart';

class LocationCard extends ConsumerWidget {
  final LocationModel location;
  final String companyId;

  const LocationCard({
    super.key,
    required this.location,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          location.name ?? 'Unnamed Location',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Parent: ${location.address ?? "N/A"}',
          style: const TextStyle(fontSize: 14, ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (location.status ?? "inactive").toUpperCase(),
              style: TextStyle(
                color: location.status?.toLowerCase() == 'active'
                    ? Colors.green
                    : Colors.red,
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
        title: const Text('Delete Location'),
        content: Text('Are you sure you want to delete location ${location.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteLocation(ref);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLocation(WidgetRef ref) async {
    final repository = ref.read(companyCustomerRepositoryProvider);
    final response = await repository.deleteLocation(location.id);
    
    if (response.statusCode == 200) {
      // Refresh the locations list
      ref.read(locationsProvider(companyId).notifier).loadLocations();
    }
  }
}
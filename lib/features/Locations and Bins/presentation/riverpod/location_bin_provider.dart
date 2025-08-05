// providers/location_bin_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../Customers/data/repository/company_customer_repository_impl.dart';
import '../../data/models/bin_model.dart';
import '../../data/models/location_model.dart';
// Import your models and repository
// import '../models/location_model.dart';
// import '../models/bin_model.dart';
// import '../repository/company_customer_repository_impl.dart';

// // Repository provider
final companyCustomerRepositoryProvider = Provider<CompanyCustomerRepositoryImpl>((ref) {
  return CompanyCustomerRepositoryImpl();
});

// Locations state notifier
class LocationsNotifier extends StateNotifier<AsyncValue<List<LocationModel>>> {
  final CompanyCustomerRepositoryImpl _repository;
  final String companyId;

  LocationsNotifier(this._repository, this.companyId) : super(const AsyncValue.loading()) {
    loadLocations();
  }

  Future<void> loadLocations() async {
    try {
      state = const AsyncValue.loading();
      final response = await _repository.getAllLocations(companyId);
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final locations = jsonList.map((json) => LocationModel.fromJson(json)).toList();
        state = AsyncValue.data(locations);
      } else {
        state = AsyncValue.error('Failed to load locations', StackTrace.current);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addLocation(Map<String, dynamic> locationData) async {
    try {
      final response = await _repository.addLocation(locationData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadLocations();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteLocation(String id) async {
    try {
      final response = await _repository.deleteLocation(id);
      
      if (response.statusCode == 200) {
        await loadLocations();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

class BinsNotifier extends StateNotifier<AsyncValue<List<BinModel>>> {
  final CompanyCustomerRepositoryImpl _repository;
  final String companyId;

  BinsNotifier(this._repository, this.companyId) : super(const AsyncValue.loading()) {
    loadBins();
  }

  Future<void> loadBins() async {
    try {
      state = const AsyncValue.loading();
      final response = await _repository.getAllBins(companyId);
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final bins = jsonList.map((json) => BinModel.fromJson(json)).toList();
        state = AsyncValue.data(bins);
      } else {
        state = AsyncValue.error('Failed to load bins', StackTrace.current);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addBin(Map<String, dynamic> binData) async {
    try {
      final response = await _repository.addbin(binData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadBins();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBin(String id) async {
    try {
      final response = await _repository.deleteBin(id);
      print("respomse: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        await loadBins();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

// Providers
final locationsProvider = StateNotifierProvider.family<LocationsNotifier, AsyncValue<List<LocationModel>>, String>(
  (ref, companyId) {
    final repository = ref.watch(companyCustomerRepositoryProvider);
    return LocationsNotifier(repository, companyId);
  },
);

final binsProvider = StateNotifierProvider.family<BinsNotifier, AsyncValue<List<BinModel>>, String>(
  (ref, companyId) {
    final repository = ref.watch(companyCustomerRepositoryProvider);
    return BinsNotifier(repository, companyId);
  },
);

// Helper provider for getting locations for dropdown
final locationsForDropdownProvider = Provider.family<List<LocationModel>, String>((ref, companyId) {
  final locationsAsync = ref.watch(locationsProvider(companyId));
  return locationsAsync.when(
    data: (locations) => locations,
    loading: () => [],
    error: (_, __) => [],
  );
});
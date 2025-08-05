import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/repository/company_customer_repository_impl.dart';

class CustomerService {
  static const int defaultPageSize = 10;
  
  final CompanyCustomerRepositoryImpl _repository = CompanyCustomerRepositoryImpl();

  Future<String?> getCompanyId() async {
    final box = await Hive.openBox('auth_data');
    return box.get('companyId');
  }

  Future<CustomerServiceResponse> fetchCustomers({
    required String companyId,
    required Map<String, String> filterForm,
    required int page,
    required int pageSize,
    required String sortingCategory,
    required String searchTerm,
  }) async {
    try {
      final response = await _repository.advanceFilter(
        filterForm,
        page,
        pageSize,
        sortingCategory,
        searchTerm,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final customerList = responseData['data'] as List<dynamic>;
        final totalRecords = responseData['totalRecords'] as int;

        return CustomerServiceResponse.success(
          customers: customerList.map((e) => json.decode(e)).toList(),
          totalRecords: totalRecords,
        );
      } else {
        return CustomerServiceResponse.error("Failed to load customers");
      }
    } catch (e) {
      return CustomerServiceResponse.error(e.toString());
    }
  }

  Future<bool> deleteCustomer(int customerId) async {
    try {
      final response = await _repository.deleteCompanyCustomer(customerId as String);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

class CustomerServiceResponse {
  final bool isSuccess;
  final List<dynamic>? customers;
  final int? totalRecords;
  final String? error;

  CustomerServiceResponse._({
    required this.isSuccess,
    this.customers,
    this.totalRecords,
    this.error,
  });

  factory CustomerServiceResponse.success({
    required List<dynamic> customers,
    required int totalRecords,
  }) {
    return CustomerServiceResponse._(
      isSuccess: true,
      customers: customers,
      totalRecords: totalRecords,
    );
  }

  factory CustomerServiceResponse.error(String error) {
    return CustomerServiceResponse._(
      isSuccess: false,
      error: error,
    );
  }
}
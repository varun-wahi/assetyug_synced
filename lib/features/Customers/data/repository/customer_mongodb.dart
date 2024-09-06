//  *****************************************      C U S T O M E R S     *****************************************
import 'dart:developer';

import 'package:asset_yug_debugging/features/Assets/data/models/assets_extra_field_names_model.dart';
import 'package:asset_yug_debugging/core/utils/constants/mongo_constants.dart';
import 'package:mongo_dart/mongo_dart.dart';

class CustomerMongoDb {
  static var customersDb, customerCollection;

  //FUNCTION TO CONNECT TO DATABASE
  static Future<void> connect() async {
    customersDb = await Db.create(CUSTOMER_DB_CONN_URL);
    await customersDb.open();
    customerCollection = customersDb.collection(CUSTOMER_COLLECTION);
    print("Connected to Customer DB");
  }

  static Future<Map<String, dynamic>?> fetchCustomer(String objectId) async {
    var customerCollection = customersDb.collection(CUSTOMER_COLLECTION);

    final filter = {'_id': ObjectId.fromHexString(objectId)};
    final customerData = await customerCollection.findOne(filter);
    print(customerData);
    return customerData;
  }

  //FUNCTION TO FETCH INDIVIDUAL COMPANY'S DATA
  static Future<Map<String, dynamic>?> fetchCompanyInfo(
      String companyID) async {
    customersDb = await Db.create(CUSTOMER_DB_CONN_URL);
    print("Created Connection with Company DB");
    await customersDb.open();
    inspect(customersDb);
    var companyCollection = customersDb.collection(COMPANY_COLLECTION);

    final filter = {'companyID': companyID};
    final companyData = await companyCollection.findOne(filter);
    return companyData;
  }

      static Future<String> insertCustomField(
      AssetExtraFieldNamesModel data) async {
        //TODO: CHANGE TO 
        var extraFieldNamesCollection =
          customersDb.collection(CUSTOMER_EXTRA_FIELD_NAMES_COLLECTION);
    try {
      
      await connect();
      var result = await extraFieldNamesCollection.insertOne(data.toJson());
      if (result.isSuccess) {
        return "Data Inserted";
      } else {
        return "Something Wrong while inserting data.";
      }
    } catch (e) {
      return e.toString();
    }
  }
  //! ------------------------  TEST FETCH CUSTOMERS STREAM  -----------------------------------------

    static Future<List<Map<String, dynamic>>> getCustomerDataStream(
    {
    String searchTerm = '',
    Map<String, dynamic>? filter,
    Map<String, int>? sortOption,
  }) async {
      if (customersDb == null || customersDb.state == State.opening ||
        customersDb.databaseName != "QuantamMaintenanceCustomer") {
      await connect();
    }

    var documents;


    try {
      if (filter != null && filter.isNotEmpty) {
        print("reached 1");
        // Execute the aggregation pipeline
        // Fetch documents matching the search term and category
        documents = await customerCollection.find({
          'name': {r'$regex': searchTerm, r'$options': 'i'},
          filter.keys.first: filter.values.first
          // 'status': desiredStatus
        }).toList();
      } else {
        print("reached 2");

        documents = await customerCollection.find({
          'name': {r'$regex': searchTerm, r'$options': 'i'},
        }).toList();
      }

      // if(sortOption != null && sortOption.isNotEmpty){
      // documents.sort([sortOption]); // 1 for ascending (A-Z)
      // }

      // Handle sorting if sortOption is provided
      if (sortOption != null && sortOption.isNotEmpty) {
        final sortField = sortOption.keys.first;
        final sortOrder = sortOption.values.first;

        
         if(sortField == "Newest first"){
            if(sortOrder == 1){
              documents = documents.toList().reversed.toList();
            }

          }


        // Sort documents by the specified field and order
        documents.sort((a, b) {
          final valueA = a[sortField] as String?;
          final valueB = b[sortField] as String?;
          if (valueA == null || valueB == null) return 0;

          return sortOrder == 1
              ? valueA.compareTo(valueB)
              : valueB.compareTo(valueA);
        });
      }

      return documents;
    } catch (e) {
      print("Error fetching customers: $e");
      return [];
    }
  }


  // static Stream<List<Map<String, dynamic>>> getCustomerDataStream(
  //   {String? searchTerm,
  //   Map<String, dynamic>? filters,
  //   Map<String, int>? sortOption,
  // }) async* {
  //     await connect();
  

  //   print("Fetch CUSTOMER data called");
  //   customersDb = await Db.create(CUSTOMER_DB_CONN_URL);
  //   print("Created Connection with customer DB");
  //   await customersDb.open();
  //   inspect(customersDb);
  //   var customerCollection = customersDb.collection(CUSTOMER_COLLECTION);

  //   var whereClause = <String, dynamic>{};

  //   whereClause = {"name": RegExp(searchTerm!)}; //.toLowerCase ??
  //   whereClause["\$or"] = [
  //     {"name": RegExp(searchTerm)},
  //     {"companyID": RegExp(searchTerm)},
  //     {"email": RegExp(searchTerm)},
  //   ];

  //   if (filters != null && filters.isNotEmpty) {
  //     // Implement logic to include additional filters in whereClause
  //     // based on filters list (not shown here for brevity)
  //   }
  //   print("Customers WhereClause: $whereClause");
  //   // print("Filters: $filters");

  //   var customerStream =
  //       customerCollection.find(whereClause); // Get the stream of documents

  //   List<Map<String, dynamic>> documents = [];
  //   await for (var document in customerStream) {
  //     // No need to check for searchTerm here as it's already filtered
  //     documents.add(document as Map<String, dynamic>);
  //     yield documents;
  //   }
  // }
}

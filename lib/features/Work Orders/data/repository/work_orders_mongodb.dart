import 'dart:async';
import 'dart:developer';
import 'package:asset_yug_debugging/core/utils/constants/mongo_constants.dart';
import 'package:mongo_dart/mongo_dart.dart';

class WorkOrdersMongodb {
  static var workOrderDb,  workOrderCollection;

  //FUNCTION TO CONNECT TO DATABASE
  static connect() async {
    workOrderDb = await Db.create(WO_DB_CONN_URL);
    
    await workOrderDb.open();
    inspect(workOrderDb);
    workOrderCollection = workOrderDb.collection(WO_COLLECTION);
    // print("Created Connection with WO DB");
  }
  


  //  *****************************************       W O R K   O R D E R S     *****************************************
    //! ------------------------  TEST FETCH ASSETS STREAM  -----------------------------------------

  static Future<List<Map<String, dynamic>>> getWorkOrdersDataStream({
    String searchTerm = '',
    Map<String, dynamic>? filter,
    Map<String, int>? sortOption,
  }) async {
    // Ensure the database connection is open
    if (workOrderDb.state == State.opening ||
        workOrderDb.databaseName != "QuantamMaintenanceWorkOrder") {
      await connect();
    }

    var documents;

    try {
      if (filter != null && filter.isNotEmpty) {
        print("reached 1");
        // Execute the aggregation pipeline
        // Fetch documents matching the search term and category
        documents = await workOrderCollection.find({
          'description': {r'$regex': searchTerm, r'$options': 'i'},
          filter.keys.first: filter.values.first
          // 'status': desiredStatus
        }).toList();
      } else {
        print("reached 2");

        documents = await workOrderCollection.find({
          'description': {r'$regex': searchTerm, r'$options': 'i'},
        }).toList();
      }

      // if(sortOption != null && sortOption.isNotEmpty){
      // documents.sort([sortOption]); // 1 for ascending (A-Z)
      // }

      // // Handle sorting if sortOption is provided
      // if (sortOption != null && sortOption.isNotEmpty) {
      //   final sortField = sortOption.keys.first;
      //   final sortOrder = sortOption.values.first;

        
      //    if(sortField == "Newest first"){

      //       if(sortOrder == 1){
      //         documents = documents.toList().reversed.toList();
      //       }

      //     }
      //   // Sort documents by the specified field and order
      //   documents.sort((a, b) {
      //   print("Entered sorting");

      //     final valueA = a[sortField] as String?;
      //     final valueB = b[sortField] as String?;
      //     if (valueA == null || valueB == null) return 0;

      //     return sortOrder == 1
      //         ? valueA.compareTo(valueB)
      //         : valueB.compareTo(valueA);
      //   });
      // }

      return documents;
    } catch (e) {
      print("Error fetching work orders: $e");
      return [];
    }
  }

  //! ------------------------  FINISH TEST HERE  -----------------------------------------
  
  /*
   * WORK ORDERS STREAM
   */

  static Stream<List<Map<String, dynamic>>> oldGetWorkOrdersDataStream(
  String searchTerm, {
  Map<String, dynamic>? filters,
  Map<String, int>? sortOption,
}) async* {
  if (workOrderDb.state == State.opening ||
      workOrderDb.databaseName != "QuantamMaintenanceWorkOrder") {
    await connect();
  }

  var selector = where;

  // Apply search term
  // if (searchTerm.isNotEmpty) {
  //   selector = selector.or([
  //     where.match('description', searchTerm, caseInsensitive: true),
  //     where.match('customerName', searchTerm, caseInsensitive: true),
  //     where.match('assignedTechnician', searchTerm, caseInsensitive: true),
  //     where.match('assetDetails', searchTerm, caseInsensitive: true),
  //   ]);
  // }
  

  // Apply filters
  if (filters != null && filters.isNotEmpty) {
    filters.forEach((key, value) {
      if (value is String) {
        selector = selector.match(key, value, caseInsensitive: true);
      } else if (value is List) {
        selector = selector.oneFrom(key, value);
      } else {
        selector = selector.eq(key, value);
      }
    });
  }

  // Apply sorting
  if (sortOption != null && sortOption.isNotEmpty) {
    sortOption.forEach((key, value) {
      selector = selector.sortBy(key, descending: value == -1);
    });
  }

  print("SELECTOR: ${selector.map}");

  try {
    var documents = await workOrderCollection.find(selector).toList();
    yield documents;
  } catch (e) {
    print("Error fetching assets: $e");
    yield [];
  }
}

  // static Stream<List<Map<String, dynamic>>> getWorkOrdersDataStream(
  //   String searchTerm, {
  //   List<Map<String, dynamic>>? filters,
  // }) async* {
  //   print("Fetch Work Orders data called");

  //   if(db.state == State.opening || db.databaseName != "QuantamMaintenanceWorkOrder"){
  //     await connect();
  //   }

  //   var whereClause = <String, dynamic>{};
  //   // whereClause = {"description":  RegExp(searchTerm) }; //.toLowerCase ??
  //   whereClause["\$or"] = [
  //     {"description": RegExp(searchTerm)},
  //     {"customerName": RegExp(searchTerm)},
  //     {"assignedTechnician": RegExp(searchTerm)},
  //     {"assetDetails": RegExp(searchTerm)},
  //   ];

  //   // // Adding filters to whereClause */
  //   // if (filters != null && filters.isNotEmpty) {
  //   //   filters.forEach((key, value) {
  //   //     if (value is String) {
  //   //       whereClause[key] = RegExp(value, caseSensitive: false);
  //   //     } else if (value is List) {
  //   //       whereClause[key] = {'\$in': value};
  //   //     } else {
  //   //       whereClause[key] = value;
  //   //     }
  //   //   });
  //   // }

  //   print("WhereClause: $whereClause");
  //   print("Filters: $filters");

  //   var workOrderstream =
  //       workOrderCollection.find(whereClause); // Get the stream of documents

  //   List<Map<String, dynamic>> documents = [];
  //   await for (var document in workOrderstream) {
  //     // No need to check for searchTerm here as it's already filtered
  //     documents.add(document as Map<String, dynamic>);
  //     yield documents;
  //   }
  // }

    static Future<List<Map<String, dynamic>>> fetchWorkOrdersByAssetId(
      int assetId) async {
    await connect();
    final filter = {"assetId": assetId};
    var results = await workOrderCollection.find(filter).toList();
    // print("$category: $value, Items: ${results.length}");
    print("WOs RELATED TO ASSET $assetId : $results");
    return results;
    
  }

  static Future<List<Map<String, dynamic>>> fetchWorkOrdersByCategory(
      String category, String value) async {
        // await connect();
    final filter = {category: value};
    var results = await workOrderCollection.find(filter).toList();
    // print("$category: $value, Items: ${results.length}");
    return results;
  }

}

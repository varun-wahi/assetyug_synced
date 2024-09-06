import 'dart:async';
import 'dart:developer';
import 'package:asset_yug_debugging/core/utils/constants/mongo_constants.dart';
import 'package:mongo_dart/mongo_dart.dart';

class InventoryMongoDB {
  static var db, inventoryCollection;

  //FUNCTION TO CONNECT TO DATABASE
  static connect() async {
    db = await Db.create(MONGO_CONN_URL);
    print("Created Connection");
    await db.open();
    inspect(db);

    inventoryCollection = db.collection(INVENTORY_COLLECTION);
  }

  

  //  *****************************************      I N V E N T O R Y     *****************************************

  /*
   * ADD DEBOUNCE TIME TO LIMIT SEARCHES PER SECOND
   */

  static Stream<List<Map<String, dynamic>>> getInventoryDataStream(
      String searchTerm,
      {Map<String, dynamic>? filters}) async* {
    print("Fetch inventory data called");

    var whereClause = <String, dynamic>{};

    // whereClause = {"Asset Name":  RegExp(searchTerm) }; //.toLowerCase ??
    whereClause["\$or"] = [
      {"assetName": RegExp(searchTerm)},
      {"customerName": RegExp(searchTerm)},
      {"isCheckedIn": RegExp(searchTerm)},
      {"category": RegExp(searchTerm)},
      {"location": RegExp(searchTerm)},
      {"status": RegExp(searchTerm)},
    ];

    if (filters != null && filters.isNotEmpty) {
      // Implement logic to include additional filters in whereClause
      // based on filters list (not shown here for brevity)
    }
    print("WhereClause: $whereClause");
    print("Filters: $filters");

    var inventoryStream =
        inventoryCollection.find(whereClause); // Get the stream of documents

    List<Map<String, dynamic>> documents = [];
    await for (var document in inventoryStream) {
      // No need to check for searchTerm here as it's already filtered
      documents.add(document as Map<String, dynamic>);
      yield documents;
    }
  }
}

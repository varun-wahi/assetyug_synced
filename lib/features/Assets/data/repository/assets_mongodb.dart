import 'package:asset_yug_debugging/features/Assets/data/models/assets_check_in_out_model.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_checking_details_model.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_extra_field_names_model.dart';
import 'package:asset_yug_debugging/core/utils/constants/mongo_constants.dart';
import 'package:asset_yug_debugging/core/utils/constants/strings.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../models/assets_model.dart';

class AssetsMongoDB {
  static var assetDb, assetsCollection;

  //FUNCTION TO CONNECT TO DATABASE
  static Future<void> connect() async {
    assetDb = await Db.create(ASSETS_DB_CONN_URL);
    await assetDb.open();
    assetsCollection = assetDb.collection(ASSETS_COLLECTION);

    // print("Connected to ASSETS assetDb");
  }

  //  *****************************************       A S S E T S     *****************************************
  //FUNCTION TO INSERT ASSET DATA
  // static Future<String> insertEntry(
  //     AssetsModel data, String checkingStatus) async {
  //   try {
  //     await connect();
  //     var result = await assetsCollection.insertOne(data.toJson());
  //     if (result.isSuccess) {
  //       //TODO : COPY THIS TO SWITCH ASSET STATUS ALSO
  //       await insertCheckInOut(data.assetId.toString(), data.location,
  //           data.customerName, checkingStatus);
  //       return "Data Inserted";
  //     } else {
  //       return "Something Wrong while inserting data.";
  //     }
  //   } catch (e) {
  //     return e.toString();
  //   }
  // }

    static Future<String> insertCustomField(
      AssetExtraFieldNamesModel data) async {
        var extraFieldNamesCollection =
          assetDb.collection(ASSET_EXTRA_FIELD_NAMES_COLLECTION);
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

  //FUNCTION TO FETCH INDIVIDUAL ASSET'S DATA
  static Future<Map<String, dynamic>?> fetchAsset(String objectId) async {
    // await connect();
    final filter = {'id': ObjectId.fromHexString(objectId)};
    final assetData = await assetsCollection.findOne(filter);
    // print(assetData);
    // fetchCheckInOut(AssetCheckInOutModel.fromJson(assetData). );
    return assetData;
  }

  //*         FUNCTION TO CHANGE ASSET STATUS
  // Function to change asset status
  static Future<bool> switchAssetStatus(
    AssetsModel assetData,
    String assetCheckingStatus,
  ) async {
    try {
      // Ensure database connection is open and correct
      if (assetDb.state == State.opening ||
          assetDb.databaseName != "QuantamMaintenanceAssets") {
        await connect();
      }

      var checkInOutCollection =
          assetDb.collection(ASSET_CHECKINOUT_COLLECTION);

      // Create new detail entry using AssetCheckingDetailsModel and convert it to Map
      var newDetail = AssetCheckingDetailsModel(
        // id: Object(),Id
        // checkInOutDateTime: DateTime.now(),
        // employee: assetData.customerId,
        employee: "1",
        // assetId: "2",
        location: assetData.location,
        status: assetCheckingStatus, date: DateTime.now(), notes: "",
      ).toJson();

      // Prepare bulk operations
      var bulkOps = [
        {
          'updateMany': {
            'filter': {'assetId': "2"},
            'update': {
              r'$set': {'status': assetCheckingStatus},
              r'$push': {'detailsList': newDetail}
            }
          }
        }
      ];

      // Execute bulk operations
      var result = await checkInOutCollection.bulkWrite(bulkOps);

      return result.isSuccess;
      // return true;
    } catch (e) {
      print("Error updating asset status: $e");
      return false;
    }
  }

  //*             Function to check whether asset is checked in
  static Future<String> checkAssetStatus(String assetId) async {
    //Enter database
    try {
      if (assetDb.state == State.opening ||
          assetDb.databaseName != "QuantamMaintenanceAssets") {
        await connect();
      }
      var data = await fetchCheckInOut(assetId);
      if (data != null) {
        final status = AssetCheckInOutModel.fromJson(data).status;
        return status ?? "";
      } else {
        return "No data";
      }
    } catch (e) {
      return "Error";
    }
  }

  //*         FUNCTION TO FETCH INDIVIDUAL ASSET CHECK IN/OUT TAB DATA
  static Future<Map<String, dynamic>?> fetchCheckInOut(String assetId) async {
    try {
      var checkInOutCollection =
          assetDb.collection(ASSET_CHECKINOUT_COLLECTION);
      final filter = {'assetId': assetId.toString()};

      var checkInOutData = await checkInOutCollection.findOne(filter);
      return checkInOutData;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //*         FUNCTION TO PUT CHECK_IN_OUT DATA
  static Future<String> insertCheckInOut(String assetId, String location,
      String employee, String currentCheckingStatus) async {
    try {
      print("REACHED INSIDE INSERT CHECKINOUT FUNCTION");
      //CREATING DATA MODEL
      var data = AssetCheckInOutModel(
        // id: ObjectId(),
        assetId: assetId,
        detailsList: [
          AssetCheckingDetailsModel(
              status: (currentCheckingStatus.isEmpty)
                  ? checkInString
                  : checkOutString,
              location: location,
              employee: employee, date: DateTime.now(), notes: ''),
        ],
        //update
        status:
            (currentCheckingStatus.isEmpty) ? checkInString : checkOutString, id: '',
      );

      var checkInOutCollection =
          await assetDb.collection(ASSET_CHECKINOUT_COLLECTION);
      //MAKE FIRST ENTRY

      var result = await checkInOutCollection.insertOne(data.toJson());
      if (result.isSuccess) {
        print("Inserted CHECK IN OUT Successfully");
        return "Data Inserted";
      } else {
        return "Something Wrong while inserting data.";
      }
    } catch (e) {
      print("Error: $e");
      return e.toString();
    }
  }

  //! ------------------------  TEST FETCH ASSETS STREAM  -----------------------------------------

  static Future<List<Map<String, dynamic>>> getAssetDataStream({
    String searchTerm = '',
    Map<String, dynamic>? filter,
    Map<String, int>? sortOption,
  }) async {
    // Ensure the database connection is open
    if (assetDb.state == State.opening ||
        assetDb.databaseName != "QuantamMaintenanceAssets") {
      await connect();
    }

    var documents;

    try {
      if (filter != null && filter.isNotEmpty) {
        print("reached 1");
        // Execute the aggregation pipeline
        // Fetch documents matching the search term and category
        documents = await assetsCollection.find({
          'assetName': {r'$regex': searchTerm, r'$options': 'i'},
          filter.keys.first: filter.values.first
          // 'status': desiredStatus
        }).toList();
      } else {
        print("reached 2");

        documents = await assetsCollection.find({
          'assetName': {r'$regex': searchTerm, r'$options': 'i'},
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
      print("Error fetching assets: $e");
      return [];
    }
  }

  //! ------------------------  FINISH TEST HERE  -----------------------------------------

//*             FUNCTION TO GET ALL ASSETS

  static Stream<List<Map<String, dynamic>>> TESTgetAssetDataStream(
    String searchTerm, {
    Map<String, dynamic>? filters,
    Map<String, int>? sortOption,
  }) async* {
    // Ensure the database connection is open
    if (assetDb.state == State.opening ||
        assetDb.databaseName != "QuantamMaintenanceAssets") {
      await connect();
    }

    var query = <String, dynamic>{};

    // Apply search term
    if (searchTerm.isNotEmpty) {
      query[r'$or'] = [
        {
          'assetName': {r'$regex': searchTerm, r'$options': 'i'}
        },
        {
          'customerName': {r'$regex': searchTerm, r'$options': 'i'}
        },
        {
          'isCheckedIn': {r'$regex': searchTerm, r'$options': 'i'}
        },
        {
          'category': {r'$regex': searchTerm, r'$options': 'i'}
        },
        {
          'location': {r'$regex': searchTerm, r'$options': 'i'}
        },
        {
          'status': {r'$regex': searchTerm, r'$options': 'i'}
        },
      ];
    }

    // Apply filters
    if (filters != null && filters.isNotEmpty) {
      filters.forEach((key, value) {
        if (value is String) {
          query[key] = {
            r'$regex': value,
            // r'$options': 'i',
          };
        } else if (value is List) {
          query[key] = {r'$in': value};
        } else {
          query[key] = value;
        }
      });
    }

    print("QUERY: $query");

    try {
      var cursor = await assetsCollection.find(query).toList();

      // Apply sorting
      // !TO FIX: SORTING

      var documents = await cursor.toList();
      //! TO FIX: Attach check in check out data
      for (var document in documents) {
        var checkingData = "Checked In";
            // await checkAssetStatus(AssetsModel.fromJson(document).assetId);
        // Optionally, attach `checkingData` to the document if needed
      }

      yield documents;
    } catch (e) {
      print("Error fetching assets: $e");
      yield [];
    }
  }

//   *          FUNCTION TO GET  ASSETS BY CATEGORY (HOME PAGE)
  static Future<List<Map<String, dynamic>>> fetchAssetsByCategory() async {
    try {
      // Ensure the database connection is open
      if (assetDb == null) {
        print("reached");
        await connect();
        // throw Exception("Database is not initialized.");
      }

      if (assetDb.state == State.opening ||
          assetDb.databaseName != "QuantamMaintenanceAssets") {
        print("reached");
        await connect();
      }

      var checkInOutCollection =
          assetDb.collection(ASSET_CHECKINOUT_COLLECTION);
      final filter = {"status": checkOutString};
      var resultsStream = await checkInOutCollection.find(filter);
      final resultsData = await resultsStream.toList();

      // print("Checked out assets: ${resultsData.length}");
      return resultsData;
    } catch (e) {
      print("Error fetching assets: $e");
      return []; // Return an empty list in case of an error
    }
  }

//*             FUNCTION TO FETCH FILES IN/OUT TAB DATA
  static Future<List<Map<String, dynamic>>?> fetchFiles(String assetId) async {
    try {
      print("REACHED INSIDE FILES FUNCTION with AssetID: $assetId");
      var filesCollection = assetDb.collection(ASSET_FILES_COLLECTION);
      final filter = {'assetId': assetId};

      var filesDataStream = filesCollection.find(filter);
      var filesData = await filesDataStream.toList();
      print("FILESDATA: ${filesData.length}");
      return filesData;
    } catch (e) {
      print("ERROR IN ASSETS MONGOassetDb: ${e.toString()}");
      return null;
    }
  }

  //*         FUNCTION TO FETCH INDIVIDUAL ASSET CHECK IN/OUT TAB DATA
  static Future<List<Map<String, dynamic>>?> fetchCustomerAssets(
      String customerId) async {
    try {
      var assetsCollection = assetDb.collection(ASSETS_COLLECTION);
      final filter = {'customerId': customerId.toString()};

      var customerAssetsStream = await assetsCollection.find(filter).toList();
      var customerAssetsList = await customerAssetsStream.toList();
      return customerAssetsList;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> fetchCustomerFiles(
      int customerId) async {
    try {
      //connect to asset database
      var assetsCollection = assetDb.collection(ASSETS_COLLECTION);
      final filter = {'customerId': customerId.toString()};

      //THIS RETURNS ASSETS ASSOCIATED TO THE CUSTOMER (Could be multiple assets)
      var customerAssetsData = await assetsCollection.find(filter).toList();
      print("ASSETS FOUND: ${customerAssetsData.length}");

      //loop through the assets and find all files related to the
      final List<Map<String, dynamic>> files = [];
      var data;
      for (Map<String, dynamic> asset in customerAssetsData) {
        //fetch files related to asset
        // data = await fetchFiles(AssetsModel.fromJson(asset).assetId);
        data = await fetchFiles("2");
        files.addAll(data);
      }
      print("NO OF FILES: ${files.length}");
      return files;

      //return all files here
    } catch (e) {
      print("ERROR $e");
      return null;
    }
  }
}

// import 'package:asset_yug/services/settings/mongo_constants.dart';
import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:asset_yug_debugging/core/utils/constants/pageFilters.dart';
import 'package:asset_yug_debugging/config/theme/container_styles.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/features/Inventory/data/repository/inventory_mongodb.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_model.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_selected_filter.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_text_field.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../../core/utils/widgets/d_searchbar.dart';
import '../../../../core/utils/widgets/my_elevated_button.dart';
import '../../../Assets/presentation/pages/view_asset_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  var box;


  @override
  void initState(){
    super.initState();
    openHiveBox();
  }

  //FIX LATER USING BLOC or GETX
  List<Map<String, dynamic>> selectedFilters  = [
    {"Status":"Open"},
    {"Sort":"Low-to-high"},
    {"Id":"Low-to-high"},
    
    ];

  Future<void> openHiveBox() async {
    box = await Hive.openBox('filters');
    if(box.get('inventoryFilters') == null){
      //PUT INITIAL LIST
      box.put('inventoryFilters',[{"":""}]);
    }
  }
  Future<void> putNewFilter(String key, String value) async {

    //PUT KEY VALUE PAIR 

    box.put(putNewFilter('$key', '$value'));

    //refresh page with new results
  }
  Future<void> fetchFilters() async {
    box.get();
  }



  var searchTextFieldController = TextEditingController();
  var searchTerm = "";
  /*

   SEARCHING FOR ASSETS

   */
  void searchInventory() {
    String search = searchTextFieldController.text;
    print("Searching... $search");
    
    setState(() {
     searchTerm = search; 
    });
    return;
  }

  void showFilters() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(2 * dPadding),
            decoration: const BoxDecoration(
                color: tWhite,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0))),
            height: 500,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  //HEADING ROW
                  Container(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Select Filters',
                          style: boldHeading(),
                        ),
                        TextButton(
                            onPressed: () => clearFilters(),
                            child: Text(
                              "CLEAR",
                              style: boldHeading(size: 16),
                            )),
                      ],
                    ),
                  ),

                  //FILTERS CONTAINER
                  Container(
                    height: 350,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          //SEARCH FIELDS
                          Container(
                            child: const Column(
                              children: [
                                //ASSET NAME
                                DTextField(
                                    icon: Icon(Icons.person), hintText: "Asset Name"),

                                //ASSET MODEL
                                DTextField(
                                    icon: Icon(Icons.numbers),
                                    hintText: "Asset Model"),

                                //ASSET BARCODE
                                DTextField(
                                    icon: Icon(Icons.qr_code),
                                    hintText: "Asset Barcode"),

                                //ASSET CATEGORY
                                DTextField(
                                    icon: Icon(Icons.category),
                                    hintText: "Asset Category"),
                              ],
                            ),
                          ),
                          const DGap(),

                          //Additional Filters
                          Container(
                            decoration: dBoxDecoration(color: tBackground),
                            child: Column(
                              children: [
                                const DGap(),
                                Text(
                                  "Additional Filters",
                                  style: boldHeading(color: tBlack, size: 18),
                                ),
                                const DGap(),
                                //ARCHIVED
                                CheckboxListTile.adaptive(
                                    title: const Text("Archived"),
                                    value: false,
                                    onChanged: (value) {}),

                                //UNARCHIVED
                                CheckboxListTile.adaptive(
                                    title: const Text("Unarchived"),
                                    value: false,
                                    onChanged: (value) {}),

                                //ASSETS CREATED BY YOU
                                CheckboxListTile.adaptive(
                                    title: const Text("Created by you"),
                                    value: false,
                                    onChanged: (value) {}),
                              ],
                            ),
                          ),
                          //ADDITIONAL FILTERS
                          Container(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: DElevatedButton(
                      buttonColor: tBlack,
                      textColor: tWhite,
                      child: const Text('Apply Filters'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0))));
  }

  void clearFilters() {
    //CLEAR FILTERS
    print("Cleared Filters");

    //POP MENU
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //ON TAPPING OUTSIDE DESELCT TEXTFORMFIELDS
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
      appBar: AppBar(title: const Text("Inventory"),  leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new)),),
      
        resizeToAvoidBottomInset: false,
        backgroundColor: tBackground,
        body: Container(
          height: MediaQuery.sizeOf(context).height - 100,
          padding: const EdgeInsets.all(dPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
      
              // Search and Filter
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SEARCH BAR
                  Expanded(
                    flex: 3,
                    child: DSearchBar(
                      hintText: "Search inventory",
                      
                          controller: searchTextFieldController,
                          onChanged: (value) => searchInventory())
                  ),
                  const DGap(
                    vertical: false,
                  ),
                ],
              ),
      
              //List of Filters
              const DGap(gap: dGap),
              Row(
                children: [
                  //LIST OF SELECTED FILTERS
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(dPadding),
                      height: 70,
                      width: 200,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(dPadding),
                        itemBuilder: (context, index) {
                          String filterKey = inventoryFilters.keys.elementAt(index);
                          return DSelectedFilterItem(
                            selectedOption: '',
                              isDropdown: true,   
                              title: filterKey,
                              onPressed: () {                                
                                // ShowFiltersModalSheet.showFilterOptions(context, filterKey, inventoryFilters);
                                //SEND REQUEST TO ASSETS MONGODB
                              });
                          // return DSelectedFilterItem(isDropdown: true, title: inventoryFilters[index], onPressed: (){});
                        },
                        itemCount: inventoryFilters.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(width: dPadding);
                        },
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  ),
                  //FILTER BUTTON
                  Expanded(
                    child: IconButton(
                        onPressed: () => showFilters(),
                        icon: const Icon(
                          Icons.filter_alt,
                          // size: 40,
                          color: darkGrey,
                        )),
                  ),
                ],
              ),
              const DGap(gap: dGap),
      
              //LIST OF ITEMS FUTURE BUILDER
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(dBorderRadius),
                      color: tBackground,
                      border: Border.all(width: .2, color: lighterGrey)),
                  // height: 500,
                  padding: const EdgeInsets.all(dPadding),
                  //STREAM BUILDER HERE
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: InventoryMongoDB.getInventoryDataStream(
                        searchTerm),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        print(snapshot.error);
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        if (snapshot.hasData) {
                          var totalData = snapshot.data?.length;
                          if(totalData !=0){
      
                            return ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: totalData!,
                            separatorBuilder: (context, index) => const DGap(),
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              //ITEM BUILDER
                              return buildAssetCard(
                                  AssetsModel.fromJson(snapshot.data![index]));
                            },
                          );
      
                          }else{
                            return const NoDataFoundPage();
                          }
                          
                        } else {
                          return const NoDataFoundPage();
                        }
                      }
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector buildAssetCard(AssetsModel data) {
    return GestureDetector(
      onTap: () {
        print("Tapped");
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ViewAssetPage(assetObjectId: data.id!))); //use $oid if error 
      },
      child: Container(
        decoration: BoxDecoration(
          color: tWhite,
          borderRadius: BorderRadius.circular(dBorderRadius),
        ),
        // padding: EdgeInsets.all(dPadding),
        padding:
            const EdgeInsets.symmetric(vertical: dPadding * 2, horizontal: dPadding),
        child: ListTile(
          // leading: Image.asset(
          //   'assets/images/no-image.png',
          //   height: 60,
          //   width: 60,
          // ),
          title: Text(
            data.name, //ASSET NAME
            style: boldHeading(size: 19),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DGap(gap: dGap / 2),
              Text(
                "Serial No: ${data.serialNumber}",
                style: containerText(weight: FontWeight.w400),
              ), //SERIAL NUMBER
              const DGap(gap: dGap / 2),
              Text("Customer: ${data.customer}",
                  style:
                      containerText(weight: FontWeight.w400)), //CUSTOMER NAME
            ],
          ),
          // trailing: ElevatedButton(
          //   style: data.isCheckedIn
          //       ? ElevatedButton.styleFrom(
          //           backgroundColor: const Color.fromARGB(255, 255, 100, 100),
          //           foregroundColor: tWhite)
          //       : ElevatedButton.styleFrom(
          //           backgroundColor: const Color.fromARGB(255, 91, 215, 100),
          //           foregroundColor: tWhite),
          //   onPressed: () {
          //     AssetsMongodb.switchAssetStatus(data.id, data.isCheckedIn);
          //     setState(() {
                
          //     });},
          //   child: data.isCheckedIn ? const Text("Check Out") : const Text("Check In"),
          //   //Style Button
          // ),
        ),
      ),
    );
  }
}

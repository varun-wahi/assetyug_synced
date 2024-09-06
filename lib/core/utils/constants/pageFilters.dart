//*                     LIST OF FILTERS FOR EACH PAGE

//KEY WILL BE THE UI TEXT, AND VALUE BE THE MONGODB COMMAND

import 'package:asset_yug_debugging/core/utils/constants/strings.dart';



// const Map<String, Map<String, dynamic>> assetsFilters = {
//   "Sort by": {
//     'Newest first' : {'Newest first': 1 },
//     'Oldest First' : {'Newest first': -1},
//     'Name (A-Z)': {"assetName": 1},
//     'Name (Z-A)': {"assetName": -1},
//     'Category (A-Z)': {"category": 1},
//     'Category (Z-A)': {"category": -1},
//   },
//   "Status": {
//     'All': null,
//     activeStatusString: {"status": activeStatusString},
//     inactiveStatusString: {"status": inactiveStatusString},
//     //!TO FIX COMMANDS
//     // checkInString: {"status": checkInString},
//     // checkOutString: {"status": checkOutString}
//   }
// };
const Map<String, Map<String, String>> assetsFilters = {
  "Sort by": {
    'Asset Name': 'name',
    'Status': 'status',
    'Category': 'category',
    'Location': 'location',
    'Asset ID': 'id',
    'Customer': 'customer',
    'Serial Number': 'serialNumber',
  },

};

const Map<String, Map<String, dynamic>> workOrderFilters = {
  "Sort by": {
    //!TO FIX COMMANDS
    "Newest first": {"lastDate": 1},
    "Oldest first": {"lastDate": 1},
    // "Due Date (Newest first)": {"dueDate": 1},
    // "Due Date (Oldest first)": {"dueDate": -1},
    // "Start Date": {"dueDate": -1},
    "Priority": {"priority": 1},
  },
  "Status": {
    "All": null,
    "Open": {"status": "Open"},
    "In Progress": {"status": "In Progress"},
    "On Hold": {"status": "On Hold"},
    "Complete": {"status": "Complete"}
  },
  "Due Date": {
    "All(default)": {},
    "Today": {},
    "Tomorrow": {},
    "Past Due": {},
    "Next 7 days": {},
  },
  // "My Work": {
  //   "Assigned to me": {},
  // }
};

const Map<String, Map<String, dynamic>> customerFilters = {
    "Sort by": {
    'Newest first' : {'Newest first': 1 },
    'Oldest First' : {'Newest first': -1},
    'Name (A-Z)': {"name": 1},
    'Name (Z-A)': {"name": -1},
    'Category (A-Z)': {"category": 1},
    'Category (Z-A)': {"category": -1},

  },
};
const Map<String, Map<String, dynamic>> inventoryFilters = {
  "Sort by": {
    'Name (A-Z)': {"assetName": 1},
    'Name (Z-A)': {"assetName": -1},
    'Category (A-Z)': {"category": 1},
    'Category (Z-A)': {"category": -1},
  },
  "Status": {
    'All': {"": ""},
    checkInString: {"status": checkInString},
    checkOutString: {"status": checkOutString}
  }
};

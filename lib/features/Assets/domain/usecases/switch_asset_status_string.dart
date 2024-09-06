import 'package:asset_yug_debugging/core/utils/constants/strings.dart';

String switchAssetCheckingStatus(String currentStatus) {
      if (currentStatus == checkInString) {
        return checkOutString;
      } else if ((currentStatus == checkOutString)) {
        return checkInString;
      } else {
        print("\n\nERROR: Wrong param provided\n\n");
        print(currentStatus);
        return "Wrong param provided";
      }
    }
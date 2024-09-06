
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:flutter/material.dart';

class NoDataFoundPage extends StatelessWidget {
  const NoDataFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.do_not_disturb_alt_outlined, size: dNoDataIconSize,color: tGreyLight,),
          const DGap(),
          Text("No data found", style: body(),)
        ],
      ),
    );
  }
}
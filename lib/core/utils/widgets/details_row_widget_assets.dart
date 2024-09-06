import 'package:asset_yug_debugging/core/utils/widgets/d_text_field.dart';
import 'package:flutter/material.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';



class DDetailsRow extends StatelessWidget {
  final String title;
  final String value;
  final double? titleFontSize;
  final double? valueFontSize;
  const DDetailsRow({
    super.key,
    required this.title,
    required this.value,
    this.titleFontSize,
    this.valueFontSize
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: containerText(size: titleFontSize ?? 16.0 , weight: FontWeight.w600),
        ),
        Text(value, style: TextStyle(fontSize: valueFontSize),),
        //TODO : Use this later
        // SizedBox(
        //   width: 180,
        //   child: DTextField(hintText: value, textAlignment: TextAlign.center,text: value,enabled: false,),
        //   ),
      ],
    );
  }
}
